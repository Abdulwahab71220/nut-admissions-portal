echo "# NUT Admissions Portal

## Complete Admission Management System

### Features:
- Student application form with profile picture upload
- Admin dashboard with leads management
- Online entrance test with anti-cheat detection
- WhatsApp & Email notifications
- AI-powered chatbot (Groq API)
- Merit list generation per program
- Seat management system
- Bulk test link sending
- Test reschedule for absent students

### Tech Stack:
- Frontend: HTML/CSS/JavaScript
- Backend: PHP
- Database: MySQL
- APIs: WhatsApp Cloud API, Gmail SMTP, Groq AI

### Setup Instructions:
1. Import \`database/admission-v3.sql\` to MySQL
2. Copy \`config-sample.php\` to \`config.php\` and update credentials
3. Configure email-service.php with SMTP credentials
4. Configure whatsapp-business-api.php with Meta tokens
5. Run on XAMPP/WAMP/LAMP

### Default Admin Login:
- Username: admin
- Password: admin123

git add README.md
git commit -m "Add README"
git push
