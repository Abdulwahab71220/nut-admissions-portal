console.log("🔥 script.js is loaded");
document.addEventListener('DOMContentLoaded', function() {
    console.log("✅ Script loaded");
});
// AUTO-DETECT SOURCE FROM URL - Add at TOP of script.js
document.addEventListener('DOMContentLoaded', function() {
    // Get source from URL (e.g., ?source=facebook)
    const urlParams = new URLSearchParams(window.location.search);
    const fbclid = urlParams.get('fbclid');
    const source = urlParams.get('source');
    
    if (source) {
        // Set the source dropdown automatically
        const sourceSelect = document.getElementById('source');
        if (sourceSelect) {
            sourceSelect.value = source;
            console.log('🎯 Auto-set source to:', source);
            
            // Show notification for Facebook
            if (fbclid || source === 'facebook') {
                showNotification('🔵 You came from Facebook! Application started via Facebook.');
            }
        }
    }
});


// Notification function - Add this too
function showNotification(message) {
    // Remove any existing notification
    const existing = document.querySelector('.facebook-notification');
    if (existing) existing.remove();
    
    // Create new notification
    const notification = document.createElement('div');
    notification.className = 'facebook-notification';
    notification.style.cssText = `
        position: fixed;
        top: 20px;
        right: 20px;
        background: linear-gradient(to right, #1877f2, #4a90e2);
        color: white;
        padding: 15px 20px;
        border-radius: 8px;
        z-index: 9999;
        font-weight: bold;
        box-shadow: 0 4px 12px rgba(0,0,0,0.2);
        display: flex;
        align-items: center;
        gap: 10px;
        animation: slideIn 0.5s ease;
    `;
    
    notification.innerHTML = `
        <i class="fab fa-facebook" style="font-size: 1.5rem;"></i>
        <div>${message}</div>
    `;
    
    document.body.appendChild(notification);
    
    // Auto-remove after 5 seconds
    setTimeout(() => {
        notification.style.animation = 'slideOut 0.5s ease';
        setTimeout(() => notification.remove(), 500);
    }, 5000);
}

// Add CSS animation
const style = document.createElement('style');
style.textContent = `
    @keyframes slideIn {
        from { transform: translateX(100%); opacity: 0; }
        to { transform: translateX(0); opacity: 1; }
    }
    @keyframes slideOut {
        from { transform: translateX(0); opacity: 1; }
        to { transform: translateX(100%); opacity: 0; }
    }
`;
document.head.appendChild(style);
//++++++++++++++++++++++++++++++++++++++++++++++//

// Get profile picture file
const profilePic = document.getElementById('profile_picture').files[0];
if (!profilePic) {
    alert('Please upload a profile picture');
    submitBtn.disabled = false;
    submitBtn.innerHTML = '<i class="fas fa-paper-plane"></i> Submit Inquiry';
    return;
}

// Show image preview
const reader = new FileReader();
reader.onload = function(e) {
    document.getElementById('imagePreview').innerHTML = '<img src="' + e.target.result + '" style="width:100px;height:100px;object-fit:cover;border-radius:50%;">';
};
reader.readAsDataURL(profilePic);

// Form submission handler
document.getElementById('leadForm').addEventListener('submit', async function(e) {
    e.preventDefault();
    console.log('Form submit triggered'); // Debug log
    
    const form = e.target;
    const submitBtn = form.querySelector('.submit-btn');
    const messageDiv = document.getElementById('formMessage');
    
    // Disable button and show loading
    submitBtn.disabled = true;
    submitBtn.innerHTML = '<i class="fas fa-spinner fa-spin"></i> Processing...';
    messageDiv.style.display = 'none';
    
    // Get form data
    const formData = new FormData(form);
    const data = Object.fromEntries(formData.entries());
    
    // Debug: Show what data is being sent
    console.log('Form data to send:', data);
    
    try {
        // Send to PHP API
        console.log('Sending request to api.php...');
        
        const response = await fetch('api.php?action=create_lead', {
            method: 'POST',
            headers: {
                'Content-Type': 'application/json',
            },
            body: JSON.stringify(data)
        });
        
        console.log('Response received. Status:', response.status);
        
        const result = await response.json();
        console.log('API Response:', result);
        
        if (result.success) {
            // Success message
            messageDiv.innerHTML = `
                <div style="background: #d4edda; color: #155724; padding: 1rem; border-radius: 5px;">
                    <i class="fas fa-check-circle"></i> <strong>Success!</strong><br>
                    ${result.message}<br>
                    <small>Lead ID: ${result.lead_id}</small>
                </div>
            `;
            messageDiv.style.display = 'block';
            
            // Reset form
            form.reset();
            
            // Redirect to thank you page after 2 seconds
            setTimeout(() => {
                window.location.href = result.redirect_url || 'thankyou.html';
            }, 2000);

            // Scroll to message
            messageDiv.scrollIntoView({ behavior: 'smooth' });
            
        } else {
            // Error message
            messageDiv.innerHTML = `
                <div style="background: #f8d7da; color: #721c24; padding: 1rem; border-radius: 5px;">
                    <i class="fas fa-exclamation-triangle"></i> <strong>Error!</strong><br>
                    ${result.error || 'Something went wrong'}
                </div>
            `;
            messageDiv.style.display = 'block';
        }
        
    } catch (error) {
        // Network error
        console.error('Fetch error:', error);
        messageDiv.innerHTML = `
            <div style="background: #f8d7da; color: #721c24; padding: 1rem; border-radius: 5px;">
                <i class="fas fa-exclamation-triangle"></i> <strong>Network Error!</strong><br>
                Please check your connection and try again.<br>
                <small>Error: ${error.message}</small>
            </div>
        `;
        messageDiv.style.display = 'block';
        
    } finally {
        // Re-enable button
        submitBtn.disabled = false;
        submitBtn.innerHTML = '<i class="fas fa-paper-plane"></i> Submit Inquiry';
    }
});

// Form validation
const inputs = document.querySelectorAll('input, select, textarea');
inputs.forEach(input => {
    input.addEventListener('blur', function() {
        if (this.hasAttribute('required') && !this.value.trim()) {
            this.style.borderColor = '#e74c3c';
        } else {
            this.style.borderColor = '#ddd';
        }
    });
});

// Test API connection
async function testAPIConnection() {
    try {
        const response = await fetch('api.php?action=get_leads');
        const result = await response.json();
        console.log('API Connection Test:', result.success ? '✅ Working' : '❌ Failed');
        console.log('Leads in DB:', result.leads?.length || 0);
    } catch (error) {
        console.error('API Connection Test Failed:', error);
    }
}

// Run test on page load
window.addEventListener('load', () => {
    console.log('Page loaded. Testing API connection...');
    testAPIConnection();
});

window.addEventListener('load', function() {
    const params = new URLSearchParams(window.location.search);
    const fbclid  = params.get('fbclid');
    const twclid  = params.get('twclid');
    const igshid  = params.get('igshid');  // Instagram share ID
    const source  = params.get('source');
    const ref     = params.get('ref');
    const select  = document.getElementById('source');

    let detectedSource = null;

    // Auto-detect by platform clid parameters
    if (fbclid) {
        detectedSource = 'facebook';
    } else if (twclid) {
        detectedSource = 'twitter';
    } else if (igshid || document.referrer.includes('instagram.com')) {
        detectedSource = 'instagram';
    } else if (document.referrer.includes('youtube.com') || document.referrer.includes('youtu.be')) {
        detectedSource = 'youtube';
    } else if (document.referrer.includes('twitter.com') || document.referrer.includes('t.co')) {
        detectedSource = 'twitter';
    } else if (document.referrer.includes('facebook.com') || document.referrer.includes('fb.me')) {
        detectedSource = 'facebook';
    }

    // Manual ?source= param overrides everything
    if (source) detectedSource = source;

    // Apply to dropdown
    if (detectedSource && select) {
        select.value = detectedSource;
        console.log('✅ Source detected:', detectedSource);
    }

    // Show Facebook badge only for Facebook
    if (detectedSource === 'facebook') {
        const badge = document.getElementById('facebook-badge');
        if (badge) badge.style.display = 'block';
    }
});