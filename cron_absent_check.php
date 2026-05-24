<?php
require_once 'config.php';
require_once 'api.php';

// This should be run every hour via cron
checkAbsentStudents();
?>