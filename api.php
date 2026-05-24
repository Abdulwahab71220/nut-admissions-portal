<?php

ini_set('display_errors', 1);
ini_set('display_startup_errors', 1);
error_reporting(E_ALL);

// api.php - FIXED v2.2
// ============================================================
if (ob_get_level()) ob_end_clean();
ob_start();


header("Content-Type: application/json");
header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Methods: POST, GET, OPTIONS");
header("Access-Control-Allow-Headers: Content-Type");

if ($_SERVER['REQUEST_METHOD'] == 'OPTIONS') { http_response_code(200); exit(); }

require_once 'config.php';
require_once 'email-service.php';
require_once 'whatsapp-business-api.php';
require_once 'ai-chatbot.php';


// ============================================================
// HELPERS
// ============================================================
function sendJsonResponse($data, $statusCode = 200) {
    ob_clean();
    http_response_code($statusCode);
    echo json_encode($data);
    exit();
}

// Safe interaction log — only runs if table exists
function logInteraction($lead_id, $action_type, $description, $old_val = null, $new_val = null, $admin_id = null) {
    global $conn;
    // Check table exists first to avoid crashes on old DB
    $check = $conn->query("SHOW TABLES LIKE 'lead_interactions'");
    if (!$check || $check->num_rows === 0) return;
    $stmt = $conn->prepare("INSERT INTO lead_interactions (lead_id, admin_id, action_type, description, old_value, new_value) VALUES (?,?,?,?,?,?)");
    if ($stmt) {
        $stmt->bind_param("iissss", $lead_id, $admin_id, $action_type, $description, $old_val, $new_val);
        $stmt->execute();
        $stmt->close();
    }
}

// Safe column check — returns true if column exists in table
function columnExists($table, $column) {
    global $conn;
    $r = $conn->query("SHOW COLUMNS FROM `$table` LIKE '$column'");
    return $r && $r->num_rows > 0;
}

// ============================================================
// CREATE LEAD — works with old and new DB schema
// ============================================================
function createLead() {
    global $conn;

    $input = file_get_contents('php://input');
    $data  = json_decode($input, true);


    // Handle profile picture (base64 to file)
    $profile_picture_path = null;
    if (!empty($data['profile_picture'])) {
        $base64 = $data['profile_picture'];
        if (preg_match('/^data:image\/(\w+);base64,/', $base64, $matches)) {
            $image_type = $matches[1];
            $base64 = substr($base64, strpos($base64, ',') + 1);
            $base64 = base64_decode($base64);
            
            // Create uploads directory if not exists
            $upload_dir = __DIR__ . '/uploads/';
            if (!file_exists($upload_dir)) {
                mkdir($upload_dir, 0777, true);
            }
            
            // Generate unique filename
            $filename = 'profile_' . uniqid() . '.' . $image_type;
            $filepath = $upload_dir . $filename;
            file_put_contents($filepath, $base64);
            $profile_picture_path = 'uploads/' . $filename;
        }
    }

    
    //_____________________________Picture-end________________________//

    if (!$data || json_last_error() !== JSON_ERROR_NONE) {
        sendJsonResponse(['success'=>false,'error'=>'Invalid JSON data'], 400);
    }

    // Required fields
    $required = ['full_name','email','phone','cnic','father_name','address','education','interested_program'];
    foreach ($required as $f) {
        if (empty($data[$f])) {
            sendJsonResponse(['success'=>false,'error'=>'Missing required field: '.$f], 400);
        }
    }

    if (!filter_var($data['email'], FILTER_VALIDATE_EMAIL)) {
        sendJsonResponse(['success'=>false,'error'=>'Invalid email format'], 400);
    }

    $phoneDigits = preg_replace('/[^0-9]/', '', $data['phone']);
    if (strlen($phoneDigits) < 10) {
        sendJsonResponse(['success'=>false,'error'=>'Invalid phone number (minimum 10 digits)'], 400);
    }

    $source = $data['source'] ?? 'website';

    // ===== CALCULATE ACADEMIC PERCENTAGE FROM MARKS =====
    $academic_percentage = null;
    if (!empty($data['inter_total_marks']) && !empty($data['inter_obtained_marks']) && $data['inter_total_marks'] > 0) {
        $academic_percentage = round(($data['inter_obtained_marks'] / $data['inter_total_marks']) * 100, 2);
    }
    
    // Get passing year from form
    $passing_year = null;
    if (!empty($data['inter_passing_year'])) {
        $passing_year = intval($data['inter_passing_year']);
    }
    
    // Get board name and roll number from form
    $board_name = $data['board_university'] ?? null;
    $board_roll_no = $data['inter_roll_no'] ?? null;
    // ===== END CALCULATIONS =====

    // Always-safe base INSERT (columns that always exist)
    $cols = ['full_name','email','phone','cnic','profile_picture','father_name','address','education','interested_program','source','status','score','created_at'];
    $marks = ['?','?','?','?','?','?','?','?','?','?','?','?','NOW()'];
    $types = 'ssssssssssss';  // 12 s's (for 12 string values, created_at is NOW() not a string param)
    $vals = [
        $data['full_name'], 
        $data['email'], 
        $data['phone'], 
        $data['cnic'],
        $profile_picture_path,
        $data['father_name'], 
        $data['address'], 
        $data['education'],
        $data['interested_program'], 
        $source,
        'new',    // status
        10        // score
    ];

    // Optional columns — only add if column exists in DB
    $optionals = [
        // UTM tracking
        'utm_campaign'        => ['s', $data['utm_campaign']        ?? null],
        'utm_medium'          => ['s', $data['utm_medium']          ?? null],
        
        // Academic fields (from form)
        'academic_percentage' => ['d', $academic_percentage],
        'passing_year'        => ['i', $passing_year],
        
        // Board fields (from form)
        'board_name'          => ['s', $board_name],
        'board_roll_no'       => ['s', $board_roll_no],
        
        // NTS fields (optional)
        'nts_reg_no'          => ['s', $data['nts_reg_no']          ?? null],
        'nts_roll_no'         => ['s', $data['nts_roll_no']         ?? null],
        'nts_score'           => ['d', isset($data['prior_test_marks']) && !empty($data['prior_test_total']) ? round(($data['prior_test_marks'] / $data['prior_test_total']) * 100, 2) : null],
        'nts_verified'        => ['i', 0],
    ];

    foreach ($optionals as $col => [$type, $val]) {
        if ($val !== null && $val !== '' && columnExists('leads', $col)) {
            $cols[]  = $col;
            $marks[] = '?';
            $types  .= $type;
            $vals[]  = $val;
        }
    }

    $sql  = "INSERT INTO leads (" . implode(',', $cols) . ") VALUES (" . implode(',', $marks) . ")";
    $stmt = $conn->prepare($sql);

    if (!$stmt) {
        sendJsonResponse(['success'=>false,'error'=>'DB prepare failed: '.$conn->error], 500);
    }

    $stmt->bind_param($types, ...$vals);

    if ($stmt->execute()) {
    $lead_id = $conn->insert_id;
    
    // Handle prior test record
    $prior_test_name = $data['prior_test_name'] ?? '';
    $prior_roll_no = $data['prior_test_roll_no'] ?? '';
    $prior_marks = $data['prior_test_marks'] ?? null;
    $prior_total = $data['prior_test_total'] ?? null;
    
    if ($prior_test_name && $prior_marks && $prior_total && $prior_total > 0) {
        $percentage = round(($prior_marks / $prior_total) * 100, 2);
        
        $stmt2 = $conn->prepare("INSERT INTO prior_test_records (lead_id, test_name, roll_number, obtained_marks, total_marks, percentage, is_verified) VALUES (?, ?, ?, ?, ?, ?, 0)");
        $stmt2->bind_param("issddd", $lead_id, $prior_test_name, $prior_roll_no, $prior_marks, $prior_total, $percentage);
        $stmt2->execute();
        $stmt2->close();
        
        // Auto-set test_score if prior test is valid and not yet set
        if ($percentage >= 50 && empty($data['test_score'])) {
            $conn->query("UPDATE leads SET test_score = $percentage, test_score_source = 'prior_test' WHERE id = $lead_id");
        }
        
        logInteraction($lead_id, 'prior_test', "Prior test submitted: $prior_test_name - $percentage%");
    }

    //==================================NTS Section END============================
        $stmt->close();

        logInteraction($lead_id, 'note', 'Lead created via '.$source);
        
        // Log board info if available
        if ($academic_percentage) {
            logInteraction($lead_id, 'note', 'Academic percentage: '.$academic_percentage.'% (Board: '.$board_name.', Roll: '.$board_roll_no.')');
        }

        // NOTIFICATIONS
        $notifications = ['email'=>'Failed', 'whatsapp'=>'No phone'];

        // Email
        try {
            if (function_exists('sendWelcomeEmail')) {
                $r = sendWelcomeEmail($data['email'], $data['full_name'], $lead_id);
                $notifications['email'] = ($r['success'] ?? false) ? 'Sent' : 'Failed';
                if ($r['success'] ?? false) logInteraction($lead_id, 'email', 'Welcome email sent');
            }
        } catch (Exception $e) { error_log('Email: '.$e->getMessage()); }

        // WhatsApp
        if (strlen($phoneDigits) >= 10) {
            try {
                $wa   = new WhatsAppBusinessAPI();
                $date = date('F j, Y');
                $r    = $wa->sendAdmissionConfirmation(
                    $data['phone'], $data['full_name'], $lead_id,
                    $data['interested_program'], $date
                );
                $notifications['whatsapp'] = ($r['success'] ?? false) ? 'Sent' : 'Failed';
                if ($r['success'] ?? false) logInteraction($lead_id, 'whatsapp', 'WA confirmation sent');
            } catch (Exception $e) { error_log('WA: '.$e->getMessage()); }
        }

        sendJsonResponse([
            'success'       => true,
            'message'       => 'Application submitted successfully!',
            'lead_id'       => $lead_id,
            'notifications' => $notifications,
            'redirect_url'  => 'thankyou.html'
        ]);

    } else {
        $err = $conn->error;
        $no  = $conn->errno;
        $stmt->close();
        if ($no == 1062) {
            sendJsonResponse(['success'=>false,'error'=>'This email or phone number is already registered.'], 400);
        }
        sendJsonResponse(['success'=>false,'error'=>'Database error: '.$err], 500);
    }
}

//========================CREATE LEADS END=============================

//=======================NTS API SECTION STARTS========================

// ============================================================
// GET PRIOR TEST RECORDS FOR A LEAD
// ============================================================
function getPriorTestRecords() {
    global $conn;
    $lead_id = intval($_GET['lead_id'] ?? 0);
    
    if (!$lead_id) {
        sendJsonResponse(['success' => false, 'error' => 'Lead ID required'], 400);
    }
    
    $stmt = $conn->prepare("SELECT * FROM prior_test_records WHERE lead_id = ? ORDER BY created_at DESC");
    $stmt->bind_param("i", $lead_id);
    $stmt->execute();
    $result = $stmt->get_result();
    
    $records = [];
    while ($row = $result->fetch_assoc()) {
        $records[] = $row;
    }
    
    sendJsonResponse(['success' => true, 'records' => $records]);
}

// ============================================================
// VERIFY PRIOR TEST RECORD (Admin)
// ============================================================
function verifyPriorTest() {
    global $conn;
    $data = json_decode(file_get_contents('php://input'), true);
    
    $record_id = $data['record_id'] ?? 0;
    $lead_id = $data['lead_id'] ?? 0;
    $admin_id = $data['admin_id'] ?? 1;
    
    if (!$record_id && !$lead_id) {
        sendJsonResponse(['success' => false, 'error' => 'Record ID or Lead ID required'], 400);
    }
    
    if ($record_id) {
        $stmt = $conn->prepare("UPDATE prior_test_records SET is_verified = 1, verified_by = ?, verification_date = NOW() WHERE id = ?");
        $stmt->bind_param("ii", $admin_id, $record_id);
    } else {
        $stmt = $conn->prepare("UPDATE prior_test_records SET is_verified = 1, verified_by = ?, verification_date = NOW() WHERE lead_id = ?");
        $stmt->bind_param("ii", $admin_id, $lead_id);
    }
    
    if ($stmt->execute()) {
        // Update leads test_score if prior test is now verified
        $conn->query("UPDATE leads l 
                      JOIN prior_test_records ptr ON ptr.lead_id = l.id 
                      SET l.test_score = ptr.percentage, l.test_score_source = 'prior_test', l.test_status = 'passed'
                      WHERE ptr.lead_id = " . ($lead_id ?: "SELECT lead_id FROM prior_test_records WHERE id = $record_id"));
        
        logInteraction($lead_id, 'prior_test_verified', "Prior test verified by admin");
        sendJsonResponse(['success' => true, 'message' => 'Prior test record verified']);
    } else {
        sendJsonResponse(['success' => false, 'error' => $conn->error]);
    }
}

// ============================================================
// VALIDATE PRIOR TEST (Auto-check for fake records)
// ============================================================
function validatePriorTest() {
    global $conn;
    $data = json_decode(file_get_contents('php://input'), true);
    
    $test_name = $data['test_name'] ?? '';
    $roll_number = $data['roll_number'] ?? '';
    $obtained = floatval($data['obtained_marks'] ?? 0);
    $total = floatval($data['total_marks'] ?? 0);
    
    $validation = ['is_valid' => true, 'warnings' => [], 'suspicion_level' => 'LOW'];
    
    // Test-specific validation rules
    if ($test_name == 'nts') {
        if (!preg_match('/^[0-9]{5,10}$/', $roll_number)) {
            $validation['is_valid'] = false;
            $validation['warnings'][] = 'Invalid NTS roll number format (should be 5-10 digits)';
            $validation['suspicion_level'] = 'HIGH';
        }
        
        // Check for duplicate roll number
        $dup_check = $conn->query("SELECT COUNT(*) as cnt FROM prior_test_records WHERE roll_number = '$roll_number' AND test_name = 'nts'");
        $dup = $dup_check->fetch_assoc();
        if ($dup['cnt'] > 0) {
            $validation['warnings'][] = '⚠️ This roll number already exists in system';
            $validation['suspicion_level'] = 'MEDIUM';
        }
    }
    
    if ($test_name == 'ecat') {
        if (!preg_match('/^[0-9]{8,12}$/', $roll_number)) {
            $validation['warnings'][] = 'ECAT roll number should be 8-12 digits';
            $validation['suspicion_level'] = 'MEDIUM';
        }
    }
    
    // Score validation
    if ($obtained > $total) {
        $validation['is_valid'] = false;
        $validation['warnings'][] = 'Obtained marks cannot exceed total marks';
        $validation['suspicion_level'] = 'HIGH';
    }
    
    $percentage = $total > 0 ? round(($obtained / $total) * 100, 2) : 0;
    
    if ($percentage == 100) {
        $validation['warnings'][] = '⚠️ Perfect score detected - manual verification recommended';
        $validation['suspicion_level'] = 'HIGH';
    } elseif ($percentage >= 95) {
        $validation['warnings'][] = 'High score detected - recommended verification';
        $validation['suspicion_level'] = 'MEDIUM';
    }
    
    sendJsonResponse([
        'success' => true,
        'is_valid' => $validation['is_valid'],
        'warnings' => $validation['warnings'],
        'suspicion_level' => $validation['suspicion_level'],
        'percentage' => $percentage
    ]);
}

// ============================================================
// UPDATE MERIT WITH PRIOR TEST (Recalculate all)
// ============================================================
function recalculateMeritWithPriorTests() {
    global $conn;
    
    // Update test_score from verified prior tests
    $conn->query("UPDATE leads l 
                  JOIN prior_test_records ptr ON ptr.lead_id = l.id 
                  SET l.test_score = ptr.percentage, l.test_score_source = 'prior_test'
                  WHERE ptr.is_verified = 1 AND (l.test_score IS NULL OR l.test_score_source != 'online')");
    
    // For leads without prior test, keep online test score
    $conn->query("UPDATE leads SET test_score_source = 'online' WHERE test_score IS NOT NULL AND test_score_source IS NULL");
    
    sendJsonResponse(['success' => true, 'message' => 'Merit recalculated with prior tests']);
}

//====================NTS API SECTION ENDS=========================
//=================================================================
//=================================================================



// ============================================================
// GET LEADS
// ============================================================
function getLeads() {
    global $conn;

    $status  = $_GET['status']  ?? '';
    $source  = $_GET['source']  ?? '';
    $program = $_GET['program'] ?? '';
    $search  = $_GET['search']  ?? '';
    $limit   = min(intval($_GET['limit'] ?? 500), 1000);

    $where  = []; $params = []; $types = '';

    if ($status)  { $where[] = "status = ?";              $params[] = $status;  $types .= 's'; }
    if ($source)  { $where[] = "source = ?";              $params[] = $source;  $types .= 's'; }
    if ($program) { $where[] = "interested_program = ?";  $params[] = $program; $types .= 's'; }
    if ($search)  {
        $where[] = "(full_name LIKE ? OR email LIKE ? OR phone LIKE ?)";
        $s = "%$search%"; $params[] = $s; $params[] = $s; $params[] = $s; $types .= 'sss';
    }

    // Select only columns that exist
    $selectCols = ['id','full_name','email','phone','cnic','profile_picture','father_name','address','education',
               'interested_program','source','status','score','created_at','updated_at'];
    $extraCols  = ['test_status','test_date','test_roll_number','test_type','test_score',
                   'academic_percentage','nts_verified','nts_score'];
    foreach ($extraCols as $col) {
        if (columnExists('leads', $col)) $selectCols[] = $col;
    }

    $sql = "SELECT " . implode(',', $selectCols) . " FROM leads";
    if ($where) $sql .= " WHERE " . implode(' AND ', $where);
    $sql .= " ORDER BY created_at DESC LIMIT $limit";

    if ($params) {
        $stmt = $conn->prepare($sql);
        $stmt->bind_param($types, ...$params);
        $stmt->execute();
        $result = $stmt->get_result();
    } else {
        $result = $conn->query($sql);
    }

    if (!$result) {
        sendJsonResponse(['success'=>false,'error'=>'Query failed: '.$conn->error], 500);
    }

    $leads = [];
    while ($row = $result->fetch_assoc()) $leads[] = $row;
    sendJsonResponse(['success'=>true,'leads'=>$leads,'count'=>count($leads)]);
}

// ============================================================
// GET SINGLE LEAD WITH HISTORY
// ============================================================
function getLead() {
    global $conn;
    $id = intval($_GET['id'] ?? 0);
    if (!$id) sendJsonResponse(['success'=>false,'error'=>'ID required'], 400);

    $stmt = $conn->prepare("SELECT * FROM leads WHERE id = ?");
    $stmt->bind_param("i", $id); $stmt->execute();
    $lead = $stmt->get_result()->fetch_assoc();
    if (!$lead) sendJsonResponse(['success'=>false,'error'=>'Lead not found'], 404);

    $interactions = [];
    $check = $conn->query("SHOW TABLES LIKE 'lead_interactions'");
    if ($check && $check->num_rows > 0) {
        $stmt2 = $conn->prepare("SELECT li.*, a.full_name as admin_name
            FROM lead_interactions li LEFT JOIN admins a ON li.admin_id = a.id
            WHERE li.lead_id = ? ORDER BY li.created_at DESC LIMIT 50");
        $stmt2->bind_param("i", $id); $stmt2->execute();
        $result = $stmt2->get_result();
        while ($row = $result->fetch_assoc()) $interactions[] = $row;
    }

    sendJsonResponse(['success'=>true,'lead'=>$lead,'interactions'=>$interactions]);
}

// ============================================================
// UPDATE LEAD STATUS
// ============================================================
// ============================================================
// UPDATE LEAD STATUS (FULLY AUTOMATED)
// ============================================================
function updateLeadStatus() {
    global $conn;
    $data = json_decode(file_get_contents('php://input'), true);
    if (empty($data['lead_id']) || empty($data['status']))
        sendJsonResponse(['success'=>false,'error'=>'lead_id and status required'], 400);

    $lead_id = $data['lead_id'];
    $new_status = $data['status'];
    
    // Get current status
    $stmt = $conn->prepare("SELECT status, test_status FROM leads WHERE id = ?");
    $stmt->bind_param("i", $lead_id);
    $stmt->execute();
    $old = $stmt->get_result()->fetch_assoc();
    $old_status = $old['status'] ?? '';
    $old_test_status = $old['test_status'] ?? '';

    // Update status
    $stmt2 = $conn->prepare("UPDATE leads SET status = ?, updated_at = NOW() WHERE id = ?");
    $stmt2->bind_param("si", $new_status, $lead_id);
    
    if ($stmt2->execute()) {
        logInteraction($lead_id, 'status_change', "Status: $old_status → $new_status", $old_status, $new_status);
        
        // Auto-update test_status based on new status
        if ($new_status == 'new') {
            // Reset everything
            $conn->query("DELETE FROM online_tests WHERE lead_id = $lead_id");
            $conn->query("UPDATE leads SET 
                test_status = 'pending',
                test_score = NULL,
                test_date = NULL,
                test_type = NULL,
                test_roll_number = NULL,
                test_sent = 0,
                test_reschedule_count = 0,
                test_absent_notified = 0
                WHERE id = $lead_id");
        }
        elseif ($new_status == 'test_scheduled') {
            $conn->query("UPDATE leads SET test_status = 'scheduled' WHERE id = $lead_id");
        }
        elseif ($new_status == 'selected') {
            $conn->query("UPDATE leads SET test_status = 'passed' WHERE id = $lead_id AND test_status != 'passed'");
        }
        elseif ($new_status == 'absent') {
            $conn->query("UPDATE leads SET test_status = 'absent' WHERE id = $lead_id");
        }
        elseif ($new_status == 'rejected') {
            $conn->query("UPDATE leads SET test_status = 'failed' WHERE id = $lead_id");
        }
        
        // Update score
        $scores = ['contacted'=>10, 'applied'=>20, 'test_scheduled'=>15, 'selected'=>30, 'enrolled'=>50];
        if (isset($scores[$new_status])) {
            $conn->query("UPDATE leads SET score = score + {$scores[$new_status]} WHERE id = $lead_id");
        }
        
        sendJsonResponse(['success'=>true, 'message'=>"Status updated to $new_status"]);
    }
    sendJsonResponse(['success'=>false, 'error'=>'Update failed'], 500);
}
// ============================================================
// ADD NOTE
// ============================================================
function addNote() {
    global $conn;
    $data = json_decode(file_get_contents('php://input'), true);
    if (empty($data['lead_id']) || empty($data['note']))
        sendJsonResponse(['success'=>false,'error'=>'lead_id and note required'], 400);
    logInteraction($data['lead_id'], 'note', $data['note']);
    sendJsonResponse(['success'=>true,'message'=>'Note added']);
}

// ============================================================
// SEND TEST SCHEDULE
// ============================================================
function sendTestSchedule() {
    global $conn;
    $data = json_decode(file_get_contents('php://input'), true);
    if (empty($data['lead_id'])||empty($data['test_date'])||empty($data['test_time'])||empty($data['venue']))
        sendJsonResponse(['success'=>false,'error'=>'Missing required fields'], 400);

    $stmt = $conn->prepare("SELECT * FROM leads WHERE id = ?");
    $stmt->bind_param("i", $data['lead_id']); $stmt->execute();
    $lead = $stmt->get_result()->fetch_assoc();
    if (!$lead) sendJsonResponse(['success'=>false,'error'=>'Lead not found'], 404);

    $rollNumber = 'T'.date('Y').str_pad($data['lead_id'],4,'0',STR_PAD_LEFT);

    $conn->query("UPDATE leads SET
        status='test_scheduled',
        updated_at=NOW()
        WHERE id={$data['lead_id']}");

    // Update test fields only if columns exist
    if (columnExists('leads','test_status'))      $conn->query("UPDATE leads SET test_status='scheduled' WHERE id={$data['lead_id']}");
    if (columnExists('leads','test_date'))         $conn->query("UPDATE leads SET test_date='{$data['test_date']}' WHERE id={$data['lead_id']}");
    if (columnExists('leads','test_roll_number'))  $conn->query("UPDATE leads SET test_roll_number='$rollNumber' WHERE id={$data['lead_id']}");

    logInteraction($data['lead_id'], 'test_scheduled', "Test scheduled {$data['test_date']} at {$data['venue']} (Roll: $rollNumber)");

    $notifications = ['whatsapp'=>'Failed','email'=>'Failed'];

    if (!empty($lead['phone'])) {
        try {
            $wa = new WhatsAppBusinessAPI();
            $r  = $wa->sendTestSchedule($lead['phone'],$lead['full_name'],
                date('d M Y',strtotime($data['test_date'])),$data['test_time'],$data['venue'],$rollNumber);
            $notifications['whatsapp'] = $r['success'] ? 'Sent' : 'Failed';
        } catch(Exception $e) { error_log($e->getMessage()); }
    }
    if (!empty($lead['email']) && function_exists('sendTestScheduleEmail')) {
        $r = sendTestScheduleEmail($lead['email'],$lead['full_name'],$rollNumber,$data['test_date'],$data['test_time'],$data['venue']);
        $notifications['email'] = $r ? 'Sent' : 'Failed';
    }

    sendJsonResponse(['success'=>true,'message'=>'Test scheduled','roll_number'=>$rollNumber,'notifications'=>$notifications]);
}


// ============================================================
// CREATE ONLINE TEST - FIXED VERSION
// ============================================================
function createOnlineTest() {
    global $conn;
    $data = json_decode(file_get_contents('php://input'), true);
    if (empty($data['lead_id'])) sendJsonResponse(['success'=>false,'error'=>'lead_id required'], 400);

    $stmt = $conn->prepare("SELECT * FROM leads WHERE id = ?");
    $stmt->bind_param("i",$data['lead_id']); $stmt->execute();
    $lead = $stmt->get_result()->fetch_assoc();
    if (!$lead) sendJsonResponse(['success'=>false,'error'=>'Lead not found'], 404);

    // Check questions table exists
    $chk = $conn->query("SHOW TABLES LIKE 'questions'");
    if (!$chk || $chk->num_rows === 0) {
        sendJsonResponse(['success'=>false,'error'=>'Question bank not set up. Run database_v2.sql first.'], 500);
    }

    $program = $lead['interested_program'];
    $q1 = $conn->query("SELECT * FROM questions WHERE program='$program' AND is_active=1 ORDER BY RAND() LIMIT 40");
    $q2 = $conn->query("SELECT * FROM questions WHERE program='all' AND is_active=1 ORDER BY RAND() LIMIT 10");
    $questions = [];
    while($r=$q1->fetch_assoc()) $questions[] = $r;
    while($r=$q2->fetch_assoc()) $questions[] = $r;
    shuffle($questions);

    if (count($questions) < 10) {
        sendJsonResponse(['success'=>false,'error'=>'Not enough questions in bank for '.$program.'. Add questions first.'], 400);
    }

    $rollNumber = 'OT'.date('Y').str_pad($data['lead_id'],4,'0',STR_PAD_LEFT);
    $token      = bin2hex(random_bytes(32));
    $qJson      = json_encode($questions);

    $chk2 = $conn->query("SHOW TABLES LIKE 'online_tests'");
    if (!$chk2 || $chk2->num_rows === 0) {
        sendJsonResponse(['success'=>false,'error'=>'online_tests table not found. Run database_v2.sql first.'], 500);
    }

    $conn->query("DELETE FROM online_tests WHERE lead_id={$data['lead_id']} AND status='pending'");

    $ins = $conn->prepare("INSERT INTO online_tests (lead_id,program,roll_number,token,questions_json,status,time_limit_minutes) VALUES (?,?,?,?,?,'pending',20)");
    $ins->bind_param("issss",$data['lead_id'],$program,$rollNumber,$token,$qJson);
    $ins->execute();

    $conn->query("UPDATE leads SET status='test_scheduled', updated_at=NOW() WHERE id={$data['lead_id']}");
    if (columnExists('leads','test_status'))     $conn->query("UPDATE leads SET test_status='scheduled' WHERE id={$data['lead_id']}");
    if (columnExists('leads','test_roll_number'))$conn->query("UPDATE leads SET test_roll_number='$rollNumber' WHERE id={$data['lead_id']}");
    if (columnExists('leads','test_type'))       $conn->query("UPDATE leads SET test_type='online' WHERE id={$data['lead_id']}");

    logInteraction($data['lead_id'],'test_scheduled',"Online test created. Roll: $rollNumber");

    $proto    = (isset($_SERVER['HTTPS'])&&$_SERVER['HTTPS']=='on') ? 'https' : 'http';
    $host     = $_SERVER['HTTP_HOST'];
    $dir      = rtrim(dirname($_SERVER['REQUEST_URI']),'/');
    $testLink = "$proto://$host$dir/online-test.html?token=$token";

    $notifications = ['whatsapp'=>'Failed','email'=>'Failed'];
    
    // SEND WHATSAPP USING TEMPLATE (FIXED)
    if (!empty($lead['phone'])) {
        try {
            $wa = new WhatsAppBusinessAPI();
            // USE THE TEMPLATE METHOD INSTEAD OF TEXT MESSAGE
            $r = $wa->sendOnlineTestReady(
                $lead['phone'],
                $lead['full_name'],
                $rollNumber,
                $testLink
            );
            $notifications['whatsapp'] = $r['success'] ? 'Sent' : 'Failed';
            
            // Log the result for debugging
            if (!$r['success']) {
                error_log('WhatsApp template failed: ' . json_encode($r['response'] ?? []));
            }
        } catch(Exception $e) { 
            error_log('WhatsApp error: ' . $e->getMessage()); 
        }
    }
    
    // SEND EMAIL
    if (!empty($lead['email']) && function_exists('sendOnlineTestEmail')) {
        try {
            sendOnlineTestEmail($lead['email'],$lead['full_name'],$rollNumber,$testLink);
            $notifications['email'] = 'Sent';
        } catch(Exception $e) {
            error_log('Email error: ' . $e->getMessage());
        }
    }

    sendJsonResponse(['success'=>true,'roll_number'=>$rollNumber,'token'=>$token,'test_link'=>$testLink,'notifications'=>$notifications]);
}

// ============================================================
// GET ONLINE TEST
// ============================================================
function getOnlineTest() {
    global $conn;
    $token = $_GET['token'] ?? '';
    if (!$token) sendJsonResponse(['success'=>false,'error'=>'Token required'], 400);

    $chk = $conn->query("SHOW TABLES LIKE 'online_tests'");
    if (!$chk || $chk->num_rows === 0) sendJsonResponse(['success'=>false,'error'=>'Online tests not configured'], 500);

    $stmt = $conn->prepare("SELECT ot.*, l.full_name FROM online_tests ot JOIN leads l ON ot.lead_id=l.id WHERE ot.token=?");
    $stmt->bind_param("s",$token); $stmt->execute();
    $test = $stmt->get_result()->fetch_assoc();
    if (!$test) sendJsonResponse(['success'=>false,'error'=>'Invalid test link'], 404);
    if ($test['status']==='expired')   sendJsonResponse(['success'=>false,'error'=>'Test has expired'], 410);
    if ($test['status']==='completed') sendJsonResponse(['success'=>false,'error'=>'Test already submitted'], 409);
    if ($test['status']==='cheating')  sendJsonResponse(['success'=>false,'error'=>'Test cancelled — tab switching detected'], 403);

    $allQ    = json_decode($test['questions_json'], true);
    $clientQ = array_map(fn($q) => [
        'id'=>$q['id'],'question_text'=>$q['question_text'],
        'option_a'=>$q['option_a'],'option_b'=>$q['option_b'],
        'option_c'=>$q['option_c'],'option_d'=>$q['option_d'],'subject'=>$q['subject']
    ], $allQ);

    sendJsonResponse([
        'success'=>true,'test_id'=>$test['id'],'roll_number'=>$test['roll_number'],
        'student_name'=>$test['full_name'],'program'=>$test['program'],
        'time_limit'=>$test['time_limit_minutes'],'status'=>$test['status'],
        'questions'=>$clientQ,'total_questions'=>count($clientQ)
    ]);
}

// ============================================================
// START ONLINE TEST
// ============================================================
function startOnlineTest() {
    global $conn;
    $data  = json_decode(file_get_contents('php://input'), true);
    $token = $data['token'] ?? '';
    if (!$token) sendJsonResponse(['success'=>false,'error'=>'Token required'], 400);

    $stmt = $conn->prepare("SELECT id FROM online_tests WHERE token=? AND status='pending'");
    $stmt->bind_param("s",$token); $stmt->execute();
    $test = $stmt->get_result()->fetch_assoc();
    if (!$test) sendJsonResponse(['success'=>false,'error'=>'Test not available or already started'], 404);

    $conn->query("UPDATE online_tests SET status='started', started_at=NOW() WHERE id={$test['id']}");
    sendJsonResponse(['success'=>true,'message'=>'Test started','started_at'=>date('Y-m-d H:i:s')]);
}

// ============================================================
// SUBMIT ONLINE TEST
// ============================================================
function submitOnlineTest() {
    global $conn;
    $data    = json_decode(file_get_contents('php://input'), true);
    $token   = $data['token']   ?? '';
    $answers = $data['answers'] ?? [];
    if (!$token) sendJsonResponse(['success'=>false,'error'=>'Token required'], 400);

    $stmt = $conn->prepare("SELECT * FROM online_tests WHERE token=? AND status IN ('started','pending')");
    $stmt->bind_param("s",$token); $stmt->execute();
    $test = $stmt->get_result()->fetch_assoc();
    if (!$test) sendJsonResponse(['success'=>false,'error'=>'Test not found or already submitted'], 404);

    $questions = json_decode($test['questions_json'], true);
    $correct   = 0; $total = count($questions);
    foreach ($questions as $q) {
        if (strtolower($answers[$q['id']] ?? '') === strtolower($q['correct_answer'])) $correct++;
    }
    $score      = $total > 0 ? round(($correct/$total)*100, 2) : 0;
    $passed     = $score >= 50;
    $testResult = $passed ? 'passed' : 'failed';

    $aJson = json_encode($answers);
    $upd   = $conn->prepare("UPDATE online_tests SET status='completed',answers_json=?,score=?,completed_at=NOW() WHERE id=?");
    $upd->bind_param("sdi",$aJson,$score,$test['id']); $upd->execute();

    $conn->query("UPDATE leads SET status='".($passed?'selected':'applied')."', updated_at=NOW() WHERE id={$test['lead_id']}");
    if (columnExists('leads','test_status')) $conn->query("UPDATE leads SET test_status='$testResult' WHERE id={$test['lead_id']}");
    if (columnExists('leads','test_score'))  $conn->query("UPDATE leads SET test_score=$score WHERE id={$test['lead_id']}");

    logInteraction($test['lead_id'],'note',"Online test done. Score: $score%. Result: $testResult");

    $lr = $conn->query("SELECT * FROM leads WHERE id={$test['lead_id']}")->fetch_assoc();
    if (!empty($lr['phone'])) {
        try {
            $wa  = new WhatsAppBusinessAPI();
            $msg = ($passed?'✅':'❌')." Test Result for {$lr['full_name']}\n\nRoll: {$test['roll_number']}\nScore: $score%\nResult: ".strtoupper($testResult)."\n\n".($passed?"Congratulations! Our team will contact you shortly.":"You may retake after 30 days.");
            $wa->sendTextMessage($lr['phone'],$msg);
        } catch(Exception $e) {}
    }
    if (!empty($lr['email']) && function_exists('sendResultEmail')) {
        sendResultEmail($lr['email'],$lr['full_name'],$score,$passed,$test['roll_number']);
    }

    sendJsonResponse(['success'=>true,'score'=>$score,'correct'=>$correct,'total'=>$total,'passed'=>$passed,'result'=>$testResult]);
}

// ============================================================
// TAB SWITCH
// ============================================================
function reportTabSwitch() {
    global $conn;
    $data  = json_decode(file_get_contents('php://input'), true);
    $token = $data['token'] ?? '';
    if (!$token) sendJsonResponse(['success'=>false,'error'=>'Token required'], 400);

    $stmt = $conn->prepare("SELECT * FROM online_tests WHERE token=? AND status='started'");
    $stmt->bind_param("s",$token); $stmt->execute();
    $test = $stmt->get_result()->fetch_assoc();
    if (!$test) sendJsonResponse(['success'=>false,'error'=>'Test not found'], 404);

    $newCount = $test['tab_switches'] + 1;
    $conn->query("UPDATE online_tests SET tab_switches=$newCount WHERE id={$test['id']}");
    if ($newCount >= 3) {
        $conn->query("UPDATE online_tests SET status='cheating' WHERE id={$test['id']}");
        if (columnExists('leads','test_status')) $conn->query("UPDATE leads SET test_status='failed' WHERE id={$test['lead_id']}");
        sendJsonResponse(['success'=>true,'cancelled'=>true,'message'=>'Test cancelled — too many tab switches']);
    }
    sendJsonResponse(['success'=>true,'cancelled'=>false,'switches'=>$newCount,'warning'=>"Warning $newCount/3 — do not switch tabs!"]);
}

// ============================================================
// DASHBOARD STATS
// ============================================================
// ============================================================
// DASHBOARD STATS
// ============================================================

function getDashboardStats() {
    global $conn;
    $s = [];

    // Basic stats
    $s['total_leads'] = $conn->query("SELECT COUNT(*) c FROM leads")->fetch_assoc()['c'];
    $s['leads_today'] = $conn->query("SELECT COUNT(*) c FROM leads WHERE DATE(created_at)=CURDATE()")->fetch_assoc()['c'];
    $s['enrolled'] = $conn->query("SELECT COUNT(*) c FROM leads WHERE status='enrolled'")->fetch_assoc()['c'];
    $s['selected'] = $conn->query("SELECT COUNT(*) c FROM leads WHERE status='selected'")->fetch_assoc()['c'];
    $s['tests_scheduled'] = $conn->query("SELECT COUNT(*) c FROM leads WHERE test_status='scheduled'")->fetch_assoc()['c'];
    $s['tests_passed'] = $conn->query("SELECT COUNT(*) c FROM leads WHERE test_status='passed'")->fetch_assoc()['c'];
    $s['acceptance_rate'] = $s['total_leads'] > 0 ? round(($s['enrolled'] / $s['total_leads']) * 100, 1) : 0;

    // Source breakdown
    $r = $conn->query("SELECT source, COUNT(*) count FROM leads GROUP BY source ORDER BY count DESC");
    $s['by_source'] = [];
    while ($row = $r->fetch_assoc()) $s['by_source'][] = $row;

    // Program breakdown
    $r = $conn->query("SELECT interested_program program, COUNT(*) count FROM leads GROUP BY interested_program ORDER BY count DESC");
    $s['by_program'] = [];
    while ($row = $r->fetch_assoc()) $s['by_program'][] = $row;

    // Status breakdown
    $r = $conn->query("SELECT status, COUNT(*) count FROM leads GROUP BY status");
    $s['by_status'] = [];
    while ($row = $r->fetch_assoc()) $s['by_status'][] = $row;

    // TEST STATISTICS PER PROGRAM (for Analytics page)
    $programs = ['bscs', 'bsai', 'bscys', 'bsse'];
    $s['test_stats'] = [];
    
    foreach ($programs as $program) {
        $total = $conn->query("SELECT COUNT(*) c FROM leads WHERE interested_program = '$program'")->fetch_assoc()['c'];
        $passed = $conn->query("SELECT COUNT(*) c FROM leads WHERE interested_program = '$program' AND test_status = 'passed'")->fetch_assoc()['c'];
        $failed = $conn->query("SELECT COUNT(*) c FROM leads WHERE interested_program = '$program' AND test_status = 'failed'")->fetch_assoc()['c'];
        $appeared = $passed + $failed;
        
        $s['test_stats'][] = [
            'program' => $program,
            'total' => $total,
            'appeared' => $appeared,
            'passed' => $passed,
            'failed' => $failed,
            'pass_rate' => $appeared > 0 ? round(($passed / $appeared) * 100, 1) : 0
        ];
    }

    // Monthly leads
    $r = $conn->query("SELECT DATE_FORMAT(created_at,'%Y-%m') month, COUNT(*) count 
                       FROM leads WHERE created_at >= DATE_SUB(NOW(), INTERVAL 6 MONTH) 
                       GROUP BY month ORDER BY month");
    $s['monthly_leads'] = [];
    while ($row = $r->fetch_assoc()) $s['monthly_leads'][] = $row;

    // Weekly leads
    $r = $conn->query("SELECT DATE(created_at) date, COUNT(*) count 
                       FROM leads WHERE created_at >= DATE_SUB(NOW(), INTERVAL 7 DAY) 
                       GROUP BY DATE(created_at) ORDER BY date");
    $s['weekly_leads'] = [];
    while ($row = $r->fetch_assoc()) $s['weekly_leads'][] = $row;

    sendJsonResponse(['success'=>true, 'stats'=>$s]);
}

// ============================================================
// ADMIN LOGIN — supports both MD5 (old) and bcrypt (new)
// ============================================================
function adminLogin() {
    global $conn;
    $data = json_decode(file_get_contents('php://input'), true);

    if (empty($data['username']) || empty($data['password']))
        sendJsonResponse(['success'=>false,'error'=>'Username and password required'], 400);

    $stmt = $conn->prepare("SELECT id, username, password, full_name, role FROM admins WHERE username = ?");
    if (!$stmt) sendJsonResponse(['success'=>false,'error'=>'DB error: '.$conn->error], 500);

    $stmt->bind_param("s", $data['username']);
    $stmt->execute();
    $row = $stmt->get_result()->fetch_assoc();
    $stmt->close();

    if (!$row) sendJsonResponse(['success'=>false,'error'=>'Username not found'], 404);

    $pwd = $data['password'];
    $hash = $row['password'];

    // Support MD5 (old), bcrypt (new), and plain text (dev)
    $valid = password_verify($pwd, $hash)           // bcrypt
          || md5($pwd) === $hash                     // MD5
          || $pwd === $hash;                         // plain (dev only)

    if ($valid) {
        $conn->query("UPDATE admins SET last_login=NOW() WHERE id={$row['id']}");
        sendJsonResponse([
            'success' => true,
            'message' => 'Login successful',
            'user'    => [
                'id'        => $row['id'],
                'username'  => $row['username'],
                'full_name' => $row['full_name'],
                'role'      => $row['role']
            ]
        ]);
    }

    sendJsonResponse(['success'=>false,'error'=>'Incorrect password'], 401);
}

// ============================================================
// CHATBOT
// ============================================================
function chatbot() {
    global $conn;
    
    $data = json_decode(file_get_contents('php://input'), true);
    $message = trim($data['message'] ?? '');
    $session_id = $data['session_id'] ?? uniqid('chat_');
    
    if (!$message) {
        sendJsonResponse(['success' => false, 'error' => 'Message required'], 400);
    }
    
    // ============================================================
    // Get dynamic data from database
    // ============================================================
    // Get seat limits
    $seats = [];
    $seatResult = $conn->query("SELECT program, total_seats, enrolled_count FROM seat_limits WHERE campaign_name = 'Fall 2025'");
    while ($row = $seatResult->fetch_assoc()) {
        $seats[$row['program']] = $row;
    }
    
    // Get program details
    $programs = [
        'bscs' => ['name' => 'BSCS', 'full' => 'Computer Science', 'min' => '60%'],
        'bsai' => ['name' => 'BSAI', 'full' => 'Artificial Intelligence', 'min' => '65%'],
        'bscys' => ['name' => 'BSCyS', 'full' => 'Cyber Security', 'min' => '60%'],
        'bsse' => ['name' => 'BSSE', 'full' => 'Software Engineering', 'min' => '60%']
    ];
    
    // Get campaign dates
    $campaign = $conn->query("SELECT * FROM admission_campaigns WHERE is_active = 1 ORDER BY id DESC LIMIT 1")->fetch_assoc();
    $deadline = $campaign ? date('F j, Y', strtotime($campaign['end_date'])) : 'August 31, 2025';
    
    // Get total leads count
    $totalLeads = $conn->query("SELECT COUNT(*) as cnt FROM leads")->fetch_assoc()['cnt'];
    
    // ============================================================
    // PRIORITY 1: Check for Application ID
    // ============================================================
    if (preg_match('/\b(\d{1,6})\b/', $message, $m)) {
        $id = intval($m[1]);
        $stmt = $conn->prepare("SELECT full_name, status, interested_program, test_score FROM leads WHERE id=?");
        $stmt->bind_param("i", $id);
        $stmt->execute();
        $lead = $stmt->get_result()->fetch_assoc();
        
        if ($lead) {
            $statusMap = [
                'new' => '📋 Received - Under review',
                'contacted' => '📞 Being contacted by admissions team',
                'applied' => '📝 Application being processed',
                'test_scheduled' => '📅 Test has been scheduled',
                'selected' => '🎉 CONGRATULATIONS! You are selected!',
                'enrolled' => '🏫 Enrolled - Welcome to NUT!',
                'rejected' => '❌ Application not selected this year'
            ];
            $reply = "✅ **Application Found!**\n\n👤 Name: {$lead['full_name']}\n🎓 Program: " . strtoupper($lead['interested_program']) . "\n📊 Status: " . ($statusMap[$lead['status']] ?? $lead['status']);
            if ($lead['test_score']) {
                $reply .= "\n📝 Test Score: {$lead['test_score']}%";
            }
            sendJsonResponse(['success' => true, 'reply' => $reply, 'session_id' => $session_id]);
            return;
        } else {
            sendJsonResponse(['success' => true, 'reply' => "❌ No application found with ID #$id.\n\nPlease check your ID or contact admissions@nut.edu.pk", 'session_id' => $session_id]);
            return;
        }
    }
    
    // ============================================================
    // PRIORITY 2: Pre-defined answers with dynamic data
    // ============================================================
    $lower = strtolower($message);
    
    // Build dynamic seat message
    $seatMessage = "🎓 **Seat Availability 2025**\n";
    foreach ($programs as $key => $prog) {
        $total = $seats[$key]['total_seats'] ?? 0;
        $enrolled = $seats[$key]['enrolled_count'] ?? 0;
        $available = $total - $enrolled;
        $status = $available > 0 ? "✅ {$available} available" : "❌ FULL";
        $seatMessage .= "• {$prog['name']} ({$prog['full']}): {$total} seats - {$status}\n";
    }
    
    // Build dynamic program details
    $programDetails = "🎓 **BS Programs - Fall 2025**\n\n";
    foreach ($programs as $key => $prog) {
        $total = $seats[$key]['total_seats'] ?? 0;
        $programDetails .= "**{$prog['name']}** - {$prog['full']}\n";
        $programDetails .= "• Seats: {$total} | Minimum: {$prog['min']}\n";
        $programDetails .= "• Fee: PKR 45,000/semester\n\n";
    }
    
    $predefined = [
        // Greetings
        'hi|hello|hey|salam|assalam o alaikum|good morning|good evening' => "👋 Hello! I'm NUT Admissions Assistant.\n\n📊 Current Stats:\n• Total Applications: {$totalLeads}\n• Deadline: {$deadline}\n\nI can help with:\n• Programs (BSCS, BSAI, BSCyS, BSSE)\n• Seat availability\n• Fee & scholarships\n• Test schedules\n• Application status (send your ID#)",
        
        // Seats - DYNAMIC
        'seats|seat|capacity|intake|availability|how many seats' => $seatMessage . "\n\n⚠️ Seats fill quickly. Apply before {$deadline}!",
        'available seats|seats left|vacancy' => $seatMessage,
        
        // Programs - DYNAMIC
        'programs|which programs|what programs|list of programs' => $programDetails,
        'bscs|computer science program' => "🎓 **BSCS Program**\n• Seats: " . ($seats['bscs']['total_seats'] ?? 60) . " (" . (($seats['bscs']['total_seats'] - ($seats['bscs']['enrolled_count'] ?? 0)) > 0 ? (($seats['bscs']['total_seats'] - ($seats['bscs']['enrolled_count'] ?? 0)) . " available") : "FULL") . ")\n• Minimum: 60% in FSc/ICS\n• Duration: 4 years\n• Focus: Programming, Algorithms, Databases, AI\n• Fee: PKR 45,000/semester",
        'bsai|artificial intelligence program' => "🎓 **BSAI Program**\n• Seats: " . ($seats['bsai']['total_seats'] ?? 40) . " (" . (($seats['bsai']['total_seats'] - ($seats['bsai']['enrolled_count'] ?? 0)) > 0 ? (($seats['bsai']['total_seats'] - ($seats['bsai']['enrolled_count'] ?? 0)) . " available") : "FULL") . ")\n• Minimum: 65% in FSc/ICS\n• Duration: 4 years\n• Focus: Machine Learning, Deep Learning, NLP\n• Fee: PKR 45,000/semester",
        'bscys|cyber security program' => "🎓 **BSCyS Program**\n• Seats: " . ($seats['bscys']['total_seats'] ?? 40) . " (" . (($seats['bscys']['total_seats'] - ($seats['bscys']['enrolled_count'] ?? 0)) > 0 ? (($seats['bscys']['total_seats'] - ($seats['bscys']['enrolled_count'] ?? 0)) . " available") : "FULL") . ")\n• Minimum: 60% in FSc/ICS\n• Duration: 4 years\n• Focus: Ethical Hacking, Cryptography, Network Security\n• Fee: PKR 45,000/semester",
        'bsse|software engineering program' => "🎓 **BSSE Program**\n• Seats: " . ($seats['bsse']['total_seats'] ?? 60) . " (" . (($seats['bsse']['total_seats'] - ($seats['bsse']['enrolled_count'] ?? 0)) > 0 ? (($seats['bsse']['total_seats'] - ($seats['bsse']['enrolled_count'] ?? 0)) . " available") : "FULL") . ")\n• Minimum: 60% in FSc/ICS\n• Duration: 4 years\n• Focus: Software Development, Testing, Project Management\n• Fee: PKR 45,000/semester",
        
        // Fee
        'fee|cost|tuition|price|semester fee|fees|admission fee' => "💰 **Fee Structure**\n• Semester Fee: PKR 45,000\n• Admission Fee: PKR 15,000 (one-time)\n• Security Deposit: PKR 5,000 (refundable)\n\n**Total for 1st Semester:** PKR 65,000\n\n**Scholarships:** Up to 100% for meritorious students",
        
        // Deadlines - DYNAMIC
        'deadline|last date|apply by|closing|when to apply|application deadline' => "📅 **Important Deadlines**\n• Application Deadline: **{$deadline}**\n• Entrance Tests: September 1-10, 2025\n• Merit List: September 15, 2025\n• Enrollment: September 22, 2025\n• Classes Begin: October 1, 2025\n\n⏰ Don't wait until the last day!",
        
        // Test
        'test|entrance|exam|pattern|test pattern|online test' => "📝 **Entrance Test Details**\n• Format: 50 MCQs\n• Duration: 20 minutes\n• Passing Score: 50%\n• Subjects: English, Mathematics, Analytical\n\n⚠️ **Rules:**\n• No tab switching (3 strikes = auto fail)\n• Stable internet required\n• Results available immediately\n\nTest link will be sent via WhatsApp after application submission.",
        
        // Eligibility
        'eligibility|eligible|requirement|criteria|minimum percentage' => "📋 **Eligibility Criteria**\n\n• **BSCS**: 60% in FSc/ICS\n• **BSAI**: 65% in FSc/ICS\n• **BSCyS**: 60% in FSc/ICS\n• **BSSE**: 60% in FSc/ICS\n\nA-Level students: Equivalence certificate required from IBCC (minimum 60%)\n\n**Have your marks?** Tell me your percentage and program to check eligibility!",
        
        // Scholarships
        'scholarship|financial aid|merit scholarship|fee waiver|scholarships' => "🎓 **Scholarships Available**\n\n**Merit-based:**\n• 100% scholarship for 85%+ aggregate\n• 75% for 80-84% aggregate\n• 50% for 75-79% aggregate\n\n**Need-based:** Up to 50% (documentation required)\n**Sports:** Up to 25% (national level)\n**HEC Loan Program:** Available for all students\n\nApply after enrollment confirmation.",
        
        // Contact
        'contact|phone|email|reach|call|office' => "📞 **Contact Admissions Office**\n\n📱 Phone: +92-300-1234567\n📧 Email: admissions@nut.edu.pk\n🕐 Hours: Monday-Saturday, 9am-5pm\n📍 Campus: University Road, Islamabad\n\n**WhatsApp:** +92-300-1234567 (for quick queries)",
        
        // How to apply
        'how to apply|apply|application process|how apply' => "📝 **How to Apply**\n\n1. Fill online application form on our website\n2. Upload profile picture and documents\n3. Submit application (free, no fee)\n4. Receive confirmation via WhatsApp & Email\n5. Admin verifies your documents (24-48 hrs)\n6. Receive online test link\n7. Take entrance test (20 min, 50 MCQs)\n8. Check merit list on September 15\n\n**Ready to apply?** Visit our website and click 'Apply Now'!",
        
        // Documents required
        'documents|required documents|what documents' => "📄 **Documents Required**\n\n**At Application:**\n• Profile picture (recent)\n• CNIC/B-Form\n• Intermediate marksheet (or awaiting)\n\n**After Selection:**\n• Original educational documents\n• CNIC/B-Form copies (2)\n• Domicile certificate\n• 4 passport size photos\n• Character certificate\n\nBring originals for verification at admissions office.",
        
        // Hostel
        'hostel|accommodation|dorm|housing' => "🏠 **Hostel Accommodation**\n\n• Separate hostels for boys and girls\n• Limited seats available (first-come basis)\n• Fee: PKR 25,000 per semester\n• Includes: Mess, WiFi, Security, Sports facilities\n• Apply after enrollment confirmation\n\n**Note:** Hostel allocation based on distance from university.",
        
        // Transport
        'transport|bus|pick and drop|transport fee' => "🚌 **Transport Facility**\n\n• Bus service available for all major sectors\n• Fee: PKR 15,000 per semester\n• Air-conditioned buses with WiFi\n• GPS tracking for parents\n\nRoutes: Rawalpindi, Islamabad, Bahria Town, DHA, Gulberg, Gulshanabad",
        
        // API question
        'api|what is api|application programming interface' => "API stands for Application Programming Interface. It allows different software systems to communicate. In our admissions system, APIs connect the chatbot, form submission, database, and notifications to work together seamlessly!",
        
        // Stats
        'statistics|how many applications|total applications' => "📊 **Current Statistics**\n\n• Total Applications: {$totalLeads}\n• Applications this month: " . ($conn->query("SELECT COUNT(*) as cnt FROM leads WHERE MONTH(created_at) = MONTH(NOW())")->fetch_assoc()['cnt'] ?? 0) . "\n• Enrolled Students: " . ($conn->query("SELECT COUNT(*) as cnt FROM leads WHERE status = 'enrolled'")->fetch_assoc()['cnt'] ?? 0) . "\n• Selected Candidates: " . ($conn->query("SELECT COUNT(*) as cnt FROM leads WHERE status = 'selected'")->fetch_assoc()['cnt'] ?? 0) . "\n\nApply before {$deadline}!",
        
        // Thanks
        'thank|thanks|thank you|thankyou' => "You're welcome! 😊\n\nIs there anything else I can help you with regarding admissions at NUT?",
        
        // Bye
        'bye|goodbye|tata|exit|quit' => "Goodbye! 👋\n\nBest of luck with your admission journey at National University of Technology!\n\nCome back if you have more questions. 📚"
    ];
    
    // Check predefined answers
    foreach ($predefined as $patterns => $reply) {
        foreach (explode('|', $patterns) as $pattern) {
            if (strpos($lower, $pattern) !== false) {
                sendJsonResponse(['success' => true, 'reply' => $reply, 'session_id' => $session_id]);
                return;
            }
        }
    }
    
    // ============================================================
    // PRIORITY 3: Use Groq API for unknown questions only
    // ============================================================
    if (file_exists(__DIR__ . '/ai-chatbot.php')) {
        require_once __DIR__ . '/ai-chatbot.php';
        
        if (function_exists('callGeminiAPI')) {
            $aiResponse = callGeminiAPI($message, '');
            if ($aiResponse['success']) {
                sendJsonResponse(['success' => true, 'reply' => $aiResponse['reply'], 'session_id' => $session_id]);
                return;
            }
        }
    }
    
    // ============================================================
    // PRIORITY 4: Final fallback with dynamic info
    // ============================================================
    sendJsonResponse(['success' => true, 'reply' => "I can help with:\n\n📚 **Programs:** BSCS, BSAI, BSCyS, BSSE\n💰 **Fee:** PKR 45,000/semester\n📅 **Deadline:** {$deadline}\n🎓 **Seats Available:** Check specific program\n🔍 **Status:** Send your Application ID\n🏠 **Hostel & Transport:** Available\n📞 **Contact:** +92-300-1234567\n\nWhat would you like to know?", 'session_id' => $session_id]);
}
// ============================================================
// MERIT LIST
// ============================================================

// ============================================================
// MERIT LIST - FIXED VERSION
// ============================================================
// ============================================================
// GET MERIT LIST
// ============================================================
function getMeritList() {
    global $conn;
    $program = $_GET['program'] ?? '';
    
    $sql = "SELECT 
                id, full_name, email, phone, interested_program,
                COALESCE(academic_percentage, 0) as academic_percentage,
                COALESCE(test_score, 0) as test_score,
                test_roll_number, test_status, status,
                ROUND((COALESCE(academic_percentage, 0) * 0.5) + (COALESCE(test_score, 0) * 0.5), 2) as aggregate
            FROM leads 
            WHERE test_status IN ('passed', 'failed')
            AND status NOT IN ('new', 'absent', 'rejected')";
    
    if ($program) {
        $sql .= " AND interested_program = '$program'";
    }
    
    $sql .= " ORDER BY aggregate DESC";
    
    $result = $conn->query($sql);
    $merit_list = [];
    $rank = 1;
    while ($row = $result->fetch_assoc()) {
        $row['rank'] = $rank++;
        $merit_list[] = $row;
    }
    
    sendJsonResponse(['success' => true, 'merit_list' => $merit_list, 'count' => count($merit_list)]);
}
//================CHEK ABSENT STUDENTS=========================
// ============================================================
// CHECK FOR ABSENT STUDENTS (Run via cron job every hour)
// ============================================================
function checkAbsentStudents() {
    global $conn;
    
    // Find students with test_scheduled status but test date passed
    $absentStudents = $conn->query("
        SELECT l.id, l.full_name, l.email, l.phone, l.test_date, l.test_roll_number, l.test_reschedule_count
        FROM leads l
        WHERE l.status = 'test_scheduled' 
        AND l.test_date IS NOT NULL
        AND l.test_date < NOW()
        AND l.test_absent_notified = 0
        AND l.test_reschedule_count < 1
    ");
    
    $notified = 0;
    while ($student = $absentStudents->fetch_assoc()) {
        // Send notification
        $message = "📢 **Test Absence Notice**\n\n";
        $message .= "Dear {$student['full_name']},\n\n";
        $message .= "You missed your scheduled entrance test on " . date('F j, Y', strtotime($student['test_date'])) . ".\n\n";
        $message .= "📋 **You can request ONE reschedule by replying to this email:**\n";
        $message .= "📧 admissions@nut.edu.pk\n\n";
        $message .= "**Subject Line:** RESCHEDULE REQUEST - ID: {$student['id']}\n\n";
        $message .= "⚠️ Only one reschedule is allowed. If you miss again, your application will be cancelled.\n\n";
        $message .= "Thank you,\nNUT Admissions Office";
        
        // Send WhatsApp
        try {
            $wa = new WhatsAppBusinessAPI();
            $wa->sendTextMessage($student['phone'], $message);
        } catch(Exception $e) {
            error_log("WhatsApp absent notification failed: " . $e->getMessage());
        }
        
        // Send Email
        if (function_exists('sendAbsentNotificationEmail')) {
            sendAbsentNotificationEmail($student['email'], $student['full_name'], $student['id']);
        }
        
        // Mark as notified
        $conn->query("UPDATE leads SET test_absent_notified = 1, last_test_notification_sent = NOW() WHERE id = {$student['id']}");
        
        // Create reschedule request record
        $conn->query("INSERT INTO test_reschedule_requests (lead_id, original_test_date, status) 
                      VALUES ({$student['id']}, '{$student['test_date']}', 'pending')");
        
        $notified++;
    }
    
    sendJsonResponse(['success' => true, 'notified' => $notified, 'message' => "$notified students notified"]);
}

// ============================================================
// PROCESS RESCHEDULE REQUEST (Called by email webhook or admin)
// ============================================================
function processRescheduleRequest() {
    global $conn;
    $data = json_decode(file_get_contents('php://input'), true);
    $lead_id = $data['lead_id'] ?? 0;
    $action = $data['action'] ?? ''; // approve or reject
    
    if (!$lead_id) {
        sendJsonResponse(['success' => false, 'error' => 'Lead ID required'], 400);
    }
    
    // Get reschedule request
    $request = $conn->query("SELECT * FROM test_reschedule_requests WHERE lead_id = $lead_id AND status = 'pending' ORDER BY id DESC LIMIT 1")->fetch_assoc();
    
    if (!$request) {
        sendJsonResponse(['success' => false, 'error' => 'No pending reschedule request'], 404);
    }
    
    if ($action == 'approve') {
        // Check reschedule count
        $lead = $conn->query("SELECT test_reschedule_count FROM leads WHERE id = $lead_id")->fetch_assoc();
        if ($lead['test_reschedule_count'] >= 1) {
            sendJsonResponse(['success' => false, 'error' => 'Student already used their one reschedule'], 400);
        }
        
        // Generate new test token
        $token = bin2hex(random_bytes(32));
        $newTestDate = date('Y-m-d H:i:s', strtotime('+7 days')); // Schedule 7 days later
        
        // Update leads table
        $conn->query("UPDATE leads SET 
            test_date = '$newTestDate',
            test_absent_notified = 0,
            test_reschedule_count = test_reschedule_count + 1,
            status = 'test_scheduled'
            WHERE id = $lead_id");
        
        // Update reschedule request
        $conn->query("UPDATE test_reschedule_requests SET 
            status = 'approved', 
            requested_date = NOW(),
            new_test_link = '$token'
            WHERE id = {$request['id']}");
        
        // Get student details
        $student = $conn->query("SELECT * FROM leads WHERE id = $lead_id")->fetch_assoc();
        
        // Send new test link
        $proto = (isset($_SERVER['HTTPS']) && $_SERVER['HTTPS'] == 'on') ? 'https' : 'http';
        $host = $_SERVER['HTTP_HOST'];
        $dir = rtrim(dirname($_SERVER['REQUEST_URI']), '/');
        $testLink = "$proto://$host$dir/online-test.html?token=$token";
        
        $wa = new WhatsAppBusinessAPI();
        $wa->sendOnlineTestReady($student['phone'], $student['full_name'], $student['test_roll_number'], $testLink);
        
        logInteraction($lead_id, 'test_rescheduled', "Test rescheduled to $newTestDate");
        
        sendJsonResponse(['success' => true, 'message' => 'Test rescheduled', 'new_test_link' => $testLink]);
        
    } elseif ($action == 'reject') {
        $conn->query("UPDATE test_reschedule_requests SET status = 'rejected' WHERE id = {$request['id']}");
        $conn->query("UPDATE leads SET status = 'rejected' WHERE id = $lead_id");
        
        logInteraction($lead_id, 'test_reschedule_rejected', "Reschedule request rejected");
        sendJsonResponse(['success' => true, 'message' => 'Reschedule request rejected']);
    } else {
        sendJsonResponse(['success' => false, 'error' => 'Invalid action'], 400);
    }
}

// ============================================================
// AUTO-RESCHEDULE VIA EMAIL (Simulate email reply detection)
// ============================================================
function autoRescheduleFromEmail() {
    global $conn;
    $data = json_decode(file_get_contents('php://input'), true);
    $email_body = $data['email_body'] ?? '';
    $from_email = $data['from_email'] ?? '';
    
    // Extract lead ID from email (pattern: "RESCHEDULE REQUEST - ID: 123")
    if (preg_match('/ID[:\s]+(\d+)/i', $email_body, $matches)) {
        $lead_id = intval($matches[1]);
        
        // Check if student has reschedule available
        $lead = $conn->query("SELECT test_reschedule_count, status FROM leads WHERE id = $lead_id")->fetch_assoc();
        
        if ($lead && $lead['test_reschedule_count'] < 1 && $lead['status'] == 'test_scheduled') {
            // Auto-approve reschedule
            $request = $conn->query("SELECT * FROM test_reschedule_requests WHERE lead_id = $lead_id AND status = 'pending'")->fetch_assoc();
            
            if ($request) {
                // Generate new test
                $token = bin2hex(random_bytes(32));
                $newTestDate = date('Y-m-d H:i:s', strtotime('+7 days'));
                
                $conn->query("UPDATE leads SET 
                    test_date = '$newTestDate',
                    test_absent_notified = 0,
                    test_reschedule_count = test_reschedule_count + 1
                    WHERE id = $lead_id");
                
                $conn->query("UPDATE test_reschedule_requests SET 
                    status = 'approved', 
                    requested_date = NOW(),
                    new_test_link = '$token'
                    WHERE id = {$request['id']}");
                
                // Send new test link
                $student = $conn->query("SELECT * FROM leads WHERE id = $lead_id")->fetch_assoc();
                $proto = (isset($_SERVER['HTTPS']) && $_SERVER['HTTPS'] == 'on') ? 'https' : 'http';
                $host = $_SERVER['HTTP_HOST'];
                $dir = rtrim(dirname($_SERVER['REQUEST_URI']), '/');
                $testLink = "$proto://$host$dir/online-test.html?token=$token";
                
                $wa = new WhatsAppBusinessAPI();
                $wa->sendOnlineTestReady($student['phone'], $student['full_name'], $student['test_roll_number'], $testLink);
                
                sendJsonResponse(['success' => true, 'message' => 'Auto-rescheduled', 'lead_id' => $lead_id]);
                return;
            }
        }
    }
    
    sendJsonResponse(['success' => false, 'message' => 'No valid reschedule request found']);
}

//=======================ABSENT STUDENT ENDS===========================


// ============================================================
// SEND MERIT OFFER WITH DEADLINE
// ============================================================
function sendMeritOffer() {
    global $conn;
    $data = json_decode(file_get_contents('php://input'), true);
    
    if (empty($data['lead_id'])) {
        sendJsonResponse(['success'=>false,'error'=>'lead_id required'], 400);
    }
    
    $lead_id = $data['lead_id'];
    $deadline = $data['deadline'] ?? date('Y-m-d', strtotime('+7 days'));
    $visit_by = $data['visit_by'] ?? date('Y-m-d', strtotime('+3 days'));
    
    // Get lead details
    $stmt = $conn->prepare("SELECT * FROM leads WHERE id = ?");
    $stmt->bind_param("i", $lead_id);
    $stmt->execute();
    $lead = $stmt->get_result()->fetch_assoc();
    
    if (!$lead) {
        sendJsonResponse(['success'=>false,'error'=>'Lead not found'], 404);
    }
    
    // Update lead status
    $conn->query("UPDATE leads SET status='selected', updated_at=NOW() WHERE id={$lead_id}");
    
    $notifications = ['whatsapp'=>'Failed', 'email'=>'Failed'];
    
    // Send WhatsApp
    if (!empty($lead['phone'])) {
        try {
            $wa = new WhatsAppBusinessAPI();
            $r = $wa->sendMeritOffer(
                $lead['phone'],
                $lead['full_name'],
                strtoupper($lead['interested_program']),
                date('d M Y', strtotime($visit_by)),
                date('d M Y', strtotime($deadline))
            );
            $notifications['whatsapp'] = $r['success'] ? 'Sent' : 'Failed';
        } catch(Exception $e) {
            error_log('WhatsApp error: ' . $e->getMessage());
        }
    }
    
    // Send Email
    if (!empty($lead['email'])) {
        $emailResult = sendMeritOfferEmail(
            $lead['email'],
            $lead['full_name'],
            $lead['interested_program'],
            $visit_by,
            $deadline
        );
        $notifications['email'] = $emailResult ? 'Sent' : 'Failed';
    }
    
    logInteraction($lead_id, 'offer_sent', "Merit offer sent. Deadline: $deadline");
    
    sendJsonResponse([
        'success' => true,
        'message' => 'Merit offer sent successfully',
        'notifications' => $notifications
    ]);
}


// ============================================================
// UPDATE ENROLLMENT - Updates leads AND enrollments table
// ============================================================

function updateEnrollment() {
    global $conn;
    $data = json_decode(file_get_contents('php://input'), true);
    $lead_id = $data['lead_id'] ?? 0;
    $action = $data['action'] ?? '';
    
    if (!$lead_id || $action !== 'confirm') {
        sendJsonResponse(['success' => false, 'error' => 'Invalid request'], 400);
    }
    
    // Get lead details
    $stmt = $conn->prepare("SELECT * FROM leads WHERE id = ?");
    $stmt->bind_param("i", $lead_id);
    $stmt->execute();
    $lead = $stmt->get_result()->fetch_assoc();
    
    if (!$lead) {
        sendJsonResponse(['success' => false, 'error' => 'Lead not found'], 404);
    }
    
    $program = $lead['interested_program'];
    $campaign = 'Fall 2025';
    
    // CHECK SEAT AVAILABILITY FIRST
    $seatCheck = $conn->query("SELECT total_seats, enrolled_count FROM seat_limits 
                                WHERE program = '$program' AND campaign_name = '$campaign'");
    $seat = $seatCheck->fetch_assoc();
    
    if ($seat && $seat['enrolled_count'] >= $seat['total_seats']) {
        sendJsonResponse(['success' => false, 'error' => 'No seats available for ' . strtoupper($program) . ' program'], 400);
    }
    
    // Update leads table status
    $conn->query("UPDATE leads SET status = 'enrolled', updated_at = NOW() WHERE id = $lead_id");
    
    // INCREMENT enrolled count
    $conn->query("UPDATE seat_limits 
                  SET enrolled_count = enrolled_count + 1 
                  WHERE program = '$program' AND campaign_name = '$campaign'");
    
    // Check if enrollment already exists
    $check = $conn->query("SELECT id FROM enrollments WHERE lead_id = $lead_id");
    if ($check->num_rows == 0) {
        $aggregate = ($lead['academic_percentage'] * 0.5) + ($lead['test_score'] * 0.5);
        $stmt2 = $conn->prepare("INSERT INTO enrollments (lead_id, program, aggregate, enrollment_status, created_at) 
                                  VALUES (?, ?, ?, 'confirmed', NOW())");
        $stmt2->bind_param("isd", $lead_id, $lead['interested_program'], $aggregate);
        $stmt2->execute();
        $stmt2->close();
    }
    
    logInteraction($lead_id, 'status_change', "Enrollment confirmed. Seat allotted.");
    
    sendJsonResponse(['success' => true, 'message' => 'Enrollment confirmed', 'seats_left' => ($seat['total_seats'] - $seat['enrolled_count'] - 1)]);
}

// ============================================================
// IMPORT LEADS CSV
// ============================================================
function importLeadsCSV() {
    global $conn;
    if (!isset($_FILES['file'])) sendJsonResponse(['success'=>false,'error'=>'No file uploaded'], 400);

    $handle  = fopen($_FILES['file']['tmp_name'], 'r');
    $headers = array_map('trim', fgetcsv($handle));
    $imported = 0; $skipped = 0; $errors = 0; $errList = [];

    while (($row = fgetcsv($handle)) !== false) {
        $d = []; foreach ($headers as $i=>$h) $d[strtolower(str_replace(' ','_',$h))] = trim($row[$i]??'');
        $name = $d['full_name']??$d['name']??'';
        $email= $d['email']??'';
        if (!$name || !$email || !filter_var($email,FILTER_VALIDATE_EMAIL)) { $errors++; $errList[]="Bad row: $name <$email>"; continue; }
        $phone  = $d['phone']??$d['mobile']??'';
        $cnic   = $d['cnic']??'';
        $father = $d['father_name']??$d['father']??'N/A';
        $addr   = $d['address']??'N/A';
        $edu    = $d['education']??'fsc';
        $prog   = strtolower($d['interested_program']??$d['program']??'bscs');
        $src    = $d['source']??'other';
        $pct    = isset($d['academic_percentage'])&&$d['academic_percentage']!==''?floatval($d['academic_percentage']):null;

        $stmt = $conn->prepare("INSERT IGNORE INTO leads (full_name,email,phone,cnic,father_name,address,education,interested_program,source,status,score,created_at) VALUES (?,?,?,?,?,?,?,?,?,'new',10,NOW())");
        $stmt->bind_param("sssssssss",$name,$email,$phone,$cnic,$father,$addr,$edu,$prog,$src);
        if ($stmt->execute()) {
            if ($conn->affected_rows>0) {
                $lid=$conn->insert_id;
                if ($pct && columnExists('leads','academic_percentage')) {
                    $conn->query("UPDATE leads SET academic_percentage=$pct WHERE id=$lid");
                }
                logInteraction($lid,'note',"Imported from CSV — $src");
                $imported++;
            } else $skipped++;
        } else $errors++;
        $stmt->close();
    }
    fclose($handle);
    sendJsonResponse(['success'=>true,'imported'=>$imported,'skipped'=>$skipped,'errors'=>$errors,'error_list'=>array_slice($errList,0,5),'message'=>"$imported imported, $skipped skipped, $errors errors"]);
}


// ============================================================
// QUESTION STATS
// ============================================================
function getQuestionStats() {
    global $conn;
    $chk=$conn->query("SHOW TABLES LIKE 'questions'");
    if (!$chk||$chk->num_rows===0) sendJsonResponse(['success'=>true,'stats'=>[]]);
    $r=$conn->query("SELECT program, COUNT(*) count FROM questions WHERE is_active=1 GROUP BY program");
    $stats=[];
    while($row=$r->fetch_assoc()) $stats[]=$row;
    sendJsonResponse(['success'=>true,'stats'=>$stats]);
}

// ============================================================
// GET ELIGIBLE STUDENTS FOR BULK TEST (Sorted by priority)
// ============================================================
// ============================================================
// GET ELIGIBLE STUDENTS FOR BULK TEST
// ============================================================
function getEligibleForBulkTest() {
    global $conn;
    $program = $_GET['program'] ?? '';
    $limit = min(intval($_GET['limit'] ?? 100), 500);
    
    $sql = "SELECT 
                id, full_name, email, phone, interested_program, status,
                COALESCE(academic_percentage, 0) as academic_percentage,
                COALESCE(test_score, 0) as test_score
            FROM leads 
            WHERE status IN ('new', 'contacted', 'applied')
            AND (test_status IS NULL OR test_status = 'pending' OR test_status = '')
            AND (test_sent = 0 OR test_sent IS NULL)";
    
    if ($program) {
        $sql .= " AND interested_program = '$program'";
    }
    
    $sql .= " ORDER BY academic_percentage DESC LIMIT $limit";
    
    $result = $conn->query($sql);
    $students = [];
    while ($row = $result->fetch_assoc()) {
        $students[] = $row;
    }
    
    sendJsonResponse(['success' => true, 'students' => $students, 'count' => count($students)]);
}
// ============================================================
// BULK SEND TEST LINKS (Priority order)
// ============================================================
function bulkSendTestLinks() {
    global $conn;
    $data = json_decode(file_get_contents('php://input'), true);
    
    $lead_ids = $data['lead_ids'] ?? [];
    $test_type = $data['test_type'] ?? 'online'; // online or external
    
    if (empty($lead_ids)) {
        sendJsonResponse(['success' => false, 'error' => 'No students selected'], 400);
    }
    
    // First, sort leads by priority score
    $ids_string = implode(',', array_map('intval', $lead_ids));
    $priority_order = $conn->query("
        SELECT id, full_name, email, phone, interested_program,
               COALESCE(academic_percentage, 0) * 0.6 + COALESCE(test_score, 0) * 0.4 as priority_score
        FROM leads 
        WHERE id IN ($ids_string)
        ORDER BY priority_score DESC, academic_percentage DESC
    ");
    
    $results = [];
    $success_count = 0;
    $fail_count = 0;
    
    while ($student = $priority_order->fetch_assoc()) {
        $result = sendIndividualTestLink($student, $test_type);
        $results[] = [
            'id' => $student['id'],
            'name' => $student['full_name'],
            'priority_score' => $student['priority_score'],
            'status' => $result['success'] ? 'sent' : 'failed',
            'message' => $result['message']
        ];
        
        if ($result['success']) {
            $success_count++;
        } else {
            $fail_count++;
        }
        
        // Small delay to avoid rate limiting
        usleep(500000); // 0.5 second delay
    }
    
    sendJsonResponse([
        'success' => true,
        'total' => count($lead_ids),
        'sent' => $success_count,
        'failed' => $fail_count,
        'results' => $results,
        'message' => "Test links sent to $success_count students (priority order)"
    ]);
}

// ============================================================
// SEND INDIVIDUAL TEST LINK (Helper function)
// ============================================================
function sendIndividualTestLink($student, $test_type = 'online') {
    global $conn;
    
    $lead_id = $student['id'];
    $program = $student['interested_program'];
    $rollNumber = 'OT' . date('Y') . str_pad($lead_id, 4, '0', STR_PAD_LEFT);
    $token = bin2hex(random_bytes(32));
    
    if ($test_type == 'online') {
        // Get questions from question bank
        $q1 = $conn->query("SELECT * FROM questions WHERE program='$program' AND is_active=1 ORDER BY RAND() LIMIT 40");
        $q2 = $conn->query("SELECT * FROM questions WHERE program='all' AND is_active=1 ORDER BY RAND() LIMIT 10");
        
        $questions = [];
        while ($r = $q1->fetch_assoc()) $questions[] = $r;
        while ($r = $q2->fetch_assoc()) $questions[] = $r;
        shuffle($questions);
        
        if (count($questions) < 10) {
            return ['success' => false, 'message' => 'Not enough questions in bank'];
        }
        
        $qJson = json_encode($questions);
        
        // Create online test record
        $conn->query("DELETE FROM online_tests WHERE lead_id = $lead_id AND status = 'pending'");
        $ins = $conn->prepare("INSERT INTO online_tests (lead_id, program, roll_number, token, questions_json, status, time_limit_minutes) VALUES (?, ?, ?, ?, ?, 'pending', 20)");
        $ins->bind_param("issss", $lead_id, $program, $rollNumber, $token, $qJson);
        $ins->execute();
        $ins->close();
    }
    
    // Update lead record - only update columns that exist
    $updateFields = [
        "status = 'test_scheduled'",
        "updated_at = NOW()"
    ];
    
    // Check each column before updating
    if (columnExists('leads', 'test_status')) {
        $updateFields[] = "test_status = 'scheduled'";
    }
    if (columnExists('leads', 'test_roll_number')) {
        $updateFields[] = "test_roll_number = '$rollNumber'";
    }
    if (columnExists('leads', 'test_type')) {
        $updateFields[] = "test_type = '$test_type'";
    }
    if (columnExists('leads', 'test_sent')) {
        $updateFields[] = "test_sent = 1";
    }
    if (columnExists('leads', 'test_sent_date')) {
        $updateFields[] = "test_sent_date = NOW()";
    }

    
    $updateSql = "UPDATE leads SET " . implode(', ', $updateFields) . " WHERE id = $lead_id";
    $conn->query($updateSql);
    
    // Generate test link
    $proto = (isset($_SERVER['HTTPS']) && $_SERVER['HTTPS'] == 'on') ? 'https' : 'http';
    $host = $_SERVER['HTTP_HOST'];
    $dir = rtrim(dirname($_SERVER['REQUEST_URI']), '/');
    $testLink = "$proto://$host$dir/online-test.html?token=$token";
    
    // Send WhatsApp notification
    $wa_sent = false;
    if (!empty($student['phone'])) {
        try {
            $wa = new WhatsAppBusinessAPI();
            $result = $wa->sendOnlineTestReady($student['phone'], $student['full_name'], $rollNumber, $testLink);
            $wa_sent = $result['success'] ?? false;
        } catch(Exception $e) {
            error_log("WhatsApp error for {$student['id']}: " . $e->getMessage());
        }
    }
    
    // Send Email notification
    $email_sent = false;
    if (!empty($student['email']) && function_exists('sendOnlineTestEmail')) {
        try {
            sendOnlineTestEmail($student['email'], $student['full_name'], $rollNumber, $testLink);
            $email_sent = true;
        } catch(Exception $e) {
            error_log("Email error for {$student['id']}: " . $e->getMessage());
        }
    }
    
    logInteraction($lead_id, 'bulk_test_sent', "Test link sent");
    
    return [
        'success' => true,
        'message' => "Sent - WA: " . ($wa_sent ? 'OK' : 'Failed') . ", Email: " . ($email_sent ? 'OK' : 'Failed'),
        'roll_number' => $rollNumber,
        'test_link' => $testLink
    ];
}
// ============================================================
// UPDATE PRIORITY SCORES FOR ALL LEADS
// ============================================================
function updateAllPriorityScores() {
    global $conn;
    
    $hasAcademic = columnExists('leads', 'academic_percentage');
    $hasTestScore = columnExists('leads', 'test_score');
    
    if (!$hasAcademic && !$hasTestScore) {
        sendJsonResponse(['success' => true, 'updated' => 0, 'message' => 'No priority columns found']);
        return;
    }
    
    if ($hasAcademic && $hasTestScore) {
        $conn->query("UPDATE leads SET priority_score = COALESCE(academic_percentage, 0) * 0.6 + COALESCE(test_score, 0) * 0.4");
    } elseif ($hasAcademic) {
        $conn->query("UPDATE leads SET priority_score = COALESCE(academic_percentage, 0) * 0.6");
    } else {
        $conn->query("UPDATE leads SET priority_score = COALESCE(test_score, 0) * 0.4");
    }
    
    $updated = $conn->affected_rows;
    
    sendJsonResponse([
        'success' => true,
        'updated' => $updated,
        'message' => "Priority scores updated for $updated leads"
    ]);
}

// ============NEW FUNCTIONS FOR SEAT LIMITATION==================

// ============================================================
// GET SEAT LIMITS
// ============================================================
function getSeatLimits() {
    global $conn;
    $campaign = $_GET['campaign'] ?? 'Fall 2025';
    
    $result = $conn->query("SELECT * FROM seat_limits WHERE campaign_name = '$campaign'");
    $seats = [];
    while ($row = $result->fetch_assoc()) {
        $seats[] = $row;
    }
    
    sendJsonResponse(['success' => true, 'seats' => $seats, 'campaign' => $campaign]);
}

// ============================================================
// UPDATE SEAT LIMIT
// ============================================================
function updateSeatLimit() {
    global $conn;
    $data = json_decode(file_get_contents('php://input'), true);
    
    if (empty($data['program']) || !isset($data['total_seats'])) {
        sendJsonResponse(['success' => false, 'error' => 'Program and total_seats required'], 400);
    }
    
    $program = $data['program'];
    $total_seats = intval($data['total_seats']);
    $campaign = $data['campaign'] ?? 'Fall 2025';
    
    $stmt = $conn->prepare("INSERT INTO seat_limits (program, total_seats, campaign_name) 
                            VALUES (?, ?, ?) 
                            ON DUPLICATE KEY UPDATE total_seats = VALUES(total_seats)");
    $stmt->bind_param("sis", $program, $total_seats, $campaign);
    
    if ($stmt->execute()) {
        sendJsonResponse(['success' => true, 'message' => 'Seat limit updated']);
    } else {
        sendJsonResponse(['success' => false, 'error' => $conn->error]);
    }
}

// ============================================================
// ADD NEW CAMPAIGN
// ============================================================
function addCampaign() {
    global $conn;
    $data = json_decode(file_get_contents('php://input'), true);
    
    $campaign = $data['campaign_name'] ?? '';
    $start = $data['start_date'] ?? null;
    $end = $data['end_date'] ?? null;
    
    if (!$campaign) {
        sendJsonResponse(['success' => false, 'error' => 'Campaign name required']);
    }
    
    $stmt = $conn->prepare("INSERT INTO admission_campaigns (campaign_name, start_date, end_date, is_active) VALUES (?, ?, ?, 1)");
    $stmt->bind_param("sss", $campaign, $start, $end);
    
    if ($stmt->execute()) {
        sendJsonResponse(['success' => true, 'message' => 'Campaign added']);
    } else {
        sendJsonResponse(['success' => false, 'error' => $conn->error]);
    }
}

// ============================================================
// CHECK SEAT AVAILABILITY (called before enrollment)
// ============================================================
function checkSeatAvailability() {
    global $conn;
    $data = json_decode(file_get_contents('php://input'), true);
    $program = $data['program'] ?? '';
    $campaign = $data['campaign'] ?? 'Fall 2025';
    
    if (!$program) {
        sendJsonResponse(['success' => false, 'error' => 'Program required'], 400);
    }
    
    $stmt = $conn->prepare("SELECT total_seats, enrolled_count FROM seat_limits 
                            WHERE program = ? AND campaign_name = ?");
    $stmt->bind_param("ss", $program, $campaign);
    $stmt->execute();
    $result = $stmt->get_result();
    $seat = $result->fetch_assoc();
    
    if (!$seat) {
        sendJsonResponse(['success' => false, 'error' => 'Seat limit not configured for this program']);
    }
    
    $available = $seat['total_seats'] - $seat['enrolled_count'];
    sendJsonResponse([
        'success' => true, 
        'program' => $program,
        'total_seats' => $seat['total_seats'],
        'enrolled_count' => $seat['enrolled_count'],
        'available_seats' => $available,
        'is_available' => $available > 0
    ]);
}

// ============================================================
// INCREMENT ENROLLED COUNT (call after successful enrollment)
// ============================================================
function incrementEnrolledCount() {
    global $conn;
    $data = json_decode(file_get_contents('php://input'), true);
    $program = $data['program'] ?? '';
    $campaign = $data['campaign'] ?? 'Fall 2025';
    
    if (!$program) {
        sendJsonResponse(['success' => false, 'error' => 'Program required'], 400);
    }
    
    $conn->query("UPDATE seat_limits 
                  SET enrolled_count = enrolled_count + 1 
                  WHERE program = '$program' AND campaign_name = '$campaign'
                  AND enrolled_count < total_seats");
    
    if ($conn->affected_rows > 0) {
        sendJsonResponse(['success' => true, 'message' => 'Enrolled count incremented']);
    } else {
        sendJsonResponse(['success' => false, 'error' => 'No seats available or update failed']);
    }
}

// ============================================================
// GET ACTIVE CAMPAIGN
// ============================================================
function getActiveCampaign() {
    global $conn;
    $result = $conn->query("SELECT * FROM admission_campaigns WHERE is_active = 1 ORDER BY id DESC LIMIT 1");
    $campaign = $result->fetch_assoc();
    sendJsonResponse(['success' => true, 'campaign' => $campaign]);
}

// ============================================================
// GET ABSENT STUDENTS (Eligible for Reschedule)
// ============================================================
function getAbsentStudents() {
    global $conn;
    
    $sql = "SELECT * FROM leads 
            WHERE status = 'absent' 
            AND test_status = 'absent' 
            AND test_reschedule_count = 0
            ORDER BY id DESC";
    
    $result = $conn->query($sql);
    
    $students = [];
    while ($row = $result->fetch_assoc()) {
        $students[] = $row;
    }
    
    sendJsonResponse(['success' => true, 'students' => $students, 'count' => count($students)]);
}

// ============================================================
// RESCHEDULE TEST FOR ABSENT STUDENT
// ============================================================
function rescheduleTest() {
    global $conn;
    $data = json_decode(file_get_contents('php://input'), true);
    $lead_id = $data['lead_id'] ?? 0;
    
    if (!$lead_id) {
        sendJsonResponse(['success' => false, 'error' => 'Lead ID required'], 400);
    }
    
    // Get student
    $student = $conn->query("SELECT * FROM leads WHERE id = $lead_id")->fetch_assoc();
    
    if (!$student) {
        sendJsonResponse(['success' => false, 'error' => 'Student not found'], 404);
    }
    
    // Check if already rescheduled
    if ($student['test_reschedule_count'] >= 1) {
        sendJsonResponse(['success' => false, 'error' => 'Student already used their one reschedule'], 400);
    }
    
    // Generate new test
    $rollNumber = 'OT' . date('Y') . str_pad($lead_id, 4, '0', STR_PAD_LEFT);
    $token = bin2hex(random_bytes(32));
    $newTestDate = date('Y-m-d', strtotime('+7 days'));
    
    // Get questions for program
    $program = $student['interested_program'];
    $q1 = $conn->query("SELECT * FROM questions WHERE program='$program' AND is_active=1 ORDER BY RAND() LIMIT 40");
    $q2 = $conn->query("SELECT * FROM questions WHERE program='all' AND is_active=1 ORDER BY RAND() LIMIT 10");
    
    $questions = [];
    while ($r = $q1->fetch_assoc()) $questions[] = $r;
    while ($r = $q2->fetch_assoc()) $questions[] = $r;
    shuffle($questions);
    
    $qJson = json_encode($questions);
    
    // Create online test
    $conn->query("DELETE FROM online_tests WHERE lead_id = $lead_id AND status = 'pending'");
    $ins = $conn->prepare("INSERT INTO online_tests (lead_id, program, roll_number, token, questions_json, status, time_limit_minutes) VALUES (?, ?, ?, ?, ?, 'pending', 20)");
    $ins->bind_param("issss", $lead_id, $program, $rollNumber, $token, $qJson);
    $ins->execute();
    $ins->close();
    
    // Update lead: status to test_scheduled, test_status to scheduled, increment reschedule count
    $conn->query("UPDATE leads SET 
        status = 'test_scheduled',
        test_status = 'scheduled',
        test_date = '$newTestDate',
        test_type = 'online',
        test_roll_number = '$rollNumber',
        test_reschedule_count = test_reschedule_count + 1,
        updated_at = NOW()
        WHERE id = $lead_id");
    
    // Create reschedule record
    $conn->query("INSERT INTO test_reschedule_requests (lead_id, original_test_date, requested_date, status, reschedule_count) 
                  VALUES ($lead_id, '{$student['test_date']}', NOW(), 'approved', 1)");
    
    // Send new test link
    $proto = (isset($_SERVER['HTTPS']) && $_SERVER['HTTPS'] == 'on') ? 'https' : 'http';
    $host = $_SERVER['HTTP_HOST'];
    $dir = rtrim(dirname($_SERVER['REQUEST_URI']), '/');
    $testLink = "$proto://$host$dir/online-test.html?token=$token";
    
    // WhatsApp
    $wa = new WhatsAppBusinessAPI();
    $wa->sendOnlineTestReady($student['phone'], $student['full_name'], $rollNumber, $testLink);
    
    // Email
    if (function_exists('sendOnlineTestEmail')) {
        sendOnlineTestEmail($student['email'], $student['full_name'], $rollNumber, $testLink);
    }
    
    logInteraction($lead_id, 'test_scheduled', "Test rescheduled to $newTestDate (Reschedule #{$student['test_reschedule_count']})");
    
    sendJsonResponse([
        'success' => true,
        'message' => 'Test rescheduled successfully',
        'new_test_link' => $testLink,
        'roll_number' => $rollNumber
    ]);
}

// ============================================================
// ROUTER
// ============================================================
try {
    $action = $_GET['action'] ?? '';
    switch ($action) {
        case 'create_lead':          createLead();              break;
        case 'get_leads':            getLeads();                break;
        case 'get_lead':             getLead();                 break;
        case 'update_status':        updateLeadStatus();        break;
        case 'add_note':             addNote();                 break;
        case 'send_test_schedule':   sendTestSchedule();        break;
        case 'create_online_test':   createOnlineTest();        break;
        case 'get_online_test':      getOnlineTest();           break;
        case 'start_online_test':    startOnlineTest();         break;
        case 'submit_online_test':   submitOnlineTest();        break;
        case 'tab_switch':           reportTabSwitch();         break;
        case 'dashboard_stats':      getDashboardStats();       break;
        case 'admin_login':          adminLogin();              break;
        case 'chatbot':              chatbot();                 break;
        case 'merit_list':           getMeritList();            break;
        case 'import_leads_csv':     importLeadsCSV();          break;
        case 'import_test_results':  importGoogleFormResults(); break;
        case 'import_nts':           importNTSResults();        break;
        case 'question_stats':       getQuestionStats();        break;
        case 'send_merit_offer':     sendMeritOffer();          break;
        case 'send_second_merit':    sendSecondMerit();         break;
        case 'update_enrollment':    updateEnrollment();        break;
        case 'get_seat_limits':      getSeatLimits();           break;
        case 'update_seat_limit':    updateSeatLimit();         break;
        case 'check_seat_availability': checkSeatAvailability(); break;
        case 'increment_enrolled':   incrementEnrolledCount();  break;
        case 'get_active_campaign':  getActiveCampaign();       break;
        case 'add_campaign':         addCampaign();             break;
        case 'get_prior_tests':      getPriorTestRecords();     break;
        case 'verify_prior_test':    verifyPriorTest();         break;
        case 'validate_prior_test':  validatePriorTest();       break;
        case 'recalculate_merit':    recalculateMeritWithPriorTests(); break;
        case 'check_absent_students':     checkAbsentStudents(); break;
        case 'process_reschedule':        processRescheduleRequest(); break;
        case 'auto_reschedule_email':     autoRescheduleFromEmail(); break;
        case 'get_reschedule_requests':   
            $result = $conn->query("SELECT r.*, l.full_name FROM test_reschedule_requests r JOIN leads l ON r.lead_id = l.id WHERE r.status = 'pending' ORDER BY r.created_at DESC");
            $requests = [];
            while ($row = $result->fetch_assoc()) $requests[] = $row;
            sendJsonResponse(['success' => true, 'requests' => $requests]);
            break;
        case 'get_eligible_bulk_test':   getEligibleForBulkTest(); break;
        case 'bulk_send_test_links':     bulkSendTestLinks(); break;
        case 'update_priority_scores':   updateAllPriorityScores(); break;
        case 'get_absent_students':   getAbsentStudents(); break;
        case 'reschedule_test':       rescheduleTest(); break;
        
        default:
            sendJsonResponse(['success'=>false,'error'=>'Invalid action. Valid: create_lead, get_leads, get_lead, update_status, add_note, send_test_schedule, create_online_test, get_online_test, start_online_test, submit_online_test, tab_switch, dashboard_stats, admin_login, chatbot, merit_list, import_leads_csv, import_test_results, import_nts, question_stats'], 400);
    }
} catch (Exception $e) {
    sendJsonResponse(['success'=>false,'error'=>'Server error: '.$e->getMessage()], 500);
}

ob_end_clean();
echo json_encode(['success'=>false,'error'=>'Unexpected end of script']);
exit();
?>
