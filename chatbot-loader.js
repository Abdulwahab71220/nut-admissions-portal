// chatbot-loader.js - Enhanced with better UI and AI support
(function() {
  const style = document.createElement('style');
  style.textContent = `
    #chatbot-widget { position: fixed; bottom: 24px; right: 24px; z-index: 9999; font-family: 'Plus Jakarta Sans', sans-serif; }
    .chat-toggle { width: 60px; height: 60px; background: linear-gradient(135deg, #0f4c81, #1565c0); border-radius: 50%; display: flex; align-items: center; justify-content: center; cursor: pointer; box-shadow: 0 6px 24px rgba(15,76,129,.4); transition: .3s; position: relative; }
    .chat-toggle:hover { transform: scale(1.1); }
    .chat-toggle i { font-size: 1.4rem; color: #fff; }
    .chat-toggle .badge { position: absolute; top: -4px; right: -4px; background: #e63946; color: #fff; border-radius: 10px; padding: .1rem .4rem; font-size: .7rem; font-weight: 700; border: 2px solid #fff; }
    .chat-window { position: absolute; bottom: 75px; right: 0; width: 380px; max-height: 600px; background: #fff; border-radius: 16px; box-shadow: 0 20px 60px rgba(0,0,0,.2); display: none; flex-direction: column; overflow: hidden; animation: slideUp .3s ease; }
    .chat-window.open { display: flex; }
    @keyframes slideUp { from{ opacity:0; transform: translateY(20px); } to{ opacity:1; transform: translateY(0); } }
    .chat-head { background: linear-gradient(135deg, #0f4c81, #1565c0); color: #fff; padding: 1rem 1.25rem; display: flex; align-items: center; gap: .75rem; }
    .chat-head .avatar { width: 36px; height: 36px; background: rgba(255,255,255,.2); border-radius: 50%; display: flex; align-items: center; justify-content: center; font-size: 1.1rem; }
    .chat-head .info .name { font-weight: 700; font-size: .95rem; }
    .chat-head .info .status { font-size: .75rem; opacity: .8; }
    .chat-head .status-dot { width: 8px; height: 8px; background: #2dc653; border-radius: 50%; display: inline-block; margin-right: .3rem; animation: pulse 2s infinite; }
    @keyframes pulse { 0%,100%{ opacity: 1; } 50%{ opacity: .5; } }
    .chat-head .minimize { margin-left: auto; background: none; border: none; color: #fff; font-size: 1.1rem; cursor: pointer; opacity: .7; }
    .chat-messages { flex: 1; overflow-y: auto; padding: 1rem; display: flex; flex-direction: column; gap: .75rem; background: #f8fafc; max-height: 380px; }
    .msg { display: flex; gap: .5rem; max-width: 85%; animation: fadeIn .3s ease; }
    @keyframes fadeIn { from{ opacity:0; transform: translateY(10px); } to{ opacity:1; transform: translateY(0); } }
    .msg.bot { align-self: flex-start; }
    .msg.user { align-self: flex-end; flex-direction: row-reverse; }
    .msg-bubble { padding: .65rem .9rem; border-radius: 12px; font-size: .875rem; line-height: 1.5; }
    .msg.bot .msg-bubble { background: #fff; border: 1px solid #e2e8f0; color: #1e293b; border-radius: 4px 12px 12px 12px; box-shadow: 0 2px 8px rgba(0,0,0,.05); white-space: pre-wrap; }
    .msg.user .msg-bubble { background: linear-gradient(135deg, #0f4c81, #1565c0); color: #fff; border-radius: 12px 4px 12px 12px; }
    .msg-time { font-size: .65rem; color: #94a3b8; margin-top: .2rem; }
    .bot-avatar { width: 28px; height: 28px; background: linear-gradient(135deg, #0f4c81, #1565c0); border-radius: 50%; display: flex; align-items: center; justify-content: center; color: #fff; font-size: .7rem; flex-shrink: 0; align-self: flex-end; }
    .chat-suggestions { padding: .5rem 1rem; display: flex; flex-wrap: wrap; gap: .4rem; background: #fff; border-top: 1px solid #f0f4f8; }
    .suggest-btn { padding: .3rem .7rem; border: 1px solid #dbeafe; background: #eff6ff; color: #1d4ed8; border-radius: 12px; font-size: .78rem; cursor: pointer; transition: .2s; }
    .suggest-btn:hover { background: #dbeafe; }
    .chat-input-row { display: flex; gap: .5rem; padding: .75rem 1rem; background: #fff; border-top: 1px solid #e2e8f0; }
    .chat-input { flex: 1; border: 1px solid #e2e8f0; border-radius: 20px; padding: .6rem 1rem; font-size: .875rem; outline: none; font-family: inherit; resize: none; max-height: 80px; }
    .chat-input:focus { border-color: #0f4c81; }
    .send-btn { width: 38px; height: 38px; background: linear-gradient(135deg, #0f4c81, #1565c0); border: none; border-radius: 50%; color: #fff; cursor: pointer; display: flex; align-items: center; justify-content: center; transition: .2s; }
    .send-btn:hover { transform: scale(1.1); }
    .typing-indicator { display: flex; align-items: center; gap: 4px; padding: .5rem .75rem; background: #fff; border: 1px solid #e2e8f0; border-radius: 12px; width: fit-content; }
    .typing-dot { width: 6px; height: 6px; background: #94a3b8; border-radius: 50%; animation: typingAnim 1.2s infinite; }
    .typing-dot:nth-child(2) { animation-delay: .2s; }
    .typing-dot:nth-child(3) { animation-delay: .4s; }
    @keyframes typingAnim { 0%,60%,100%{ transform: translateY(0); opacity: .5; } 30%{ transform: translateY(-6px); opacity: 1; } }
    .quick-reply { background: #e8f0fa; border: none; padding: .4rem .8rem; border-radius: 16px; font-size: .75rem; cursor: pointer; margin: .2rem; }
  `;
  document.head.appendChild(style);

  // Widget HTML
  const widget = document.createElement('div');
  widget.id = 'chatbot-widget';
  widget.innerHTML = `
    <div class="chat-toggle" onclick="chatToggle()">
      <i class="fas fa-comments" id="chatIcon"></i>
      <div class="badge" id="chatBadge">1</div>
    </div>
    <div class="chat-window" id="chatWindow">
      <div class="chat-head">
        <div class="avatar">🎓</div>
        <div class="info">
          <div class="name">NUT Admissions Bot</div>
          <div class="status"><span class="status-dot"></span>AI Assistant — Online</div>
        </div>
        <button class="minimize" onclick="chatToggle()"><i class="fas fa-times"></i></button>
      </div>
      <div class="chat-messages" id="chatMessages"></div>
      <div class="chat-suggestions">
        <button class="suggest-btn" onclick="chatSend('What programs are offered?')">📚 Programs</button>
        <button class="suggest-btn" onclick="chatSend('What is the fee?')">💰 Fee</button>
        <button class="suggest-btn" onclick="chatSend('What is the deadline?')">📅 Deadline</button>
        <button class="suggest-btn" onclick="chatSend('Check status 12345')">🔍 Status</button>
        <button class="suggest-btn" onclick="chatSend('What is the test pattern?')">📝 Test</button>
      </div>
      <div class="chat-input-row">
        <textarea class="chat-input" id="chatInput" placeholder="Ask me anything about admissions..." rows="1" onkeydown="if(event.key==='Enter'&&!event.shiftKey){event.preventDefault();chatSendMsg();}" oninput="this.style.height='auto';this.style.height=Math.min(this.scrollHeight,80)+'px'"></textarea>
        <button class="send-btn" onclick="chatSendMsg()"><i class="fas fa-paper-plane"></i></button>
      </div>
    </div>
  `;
  document.body.appendChild(widget);

  let chatOpen = false, sessionId = 'sess_' + Date.now() + '_' + Math.random().toString(36).substr(2, 8);
  
  window.chatToggle = function() {
    chatOpen = !chatOpen;
    document.getElementById('chatWindow').classList.toggle('open', chatOpen);
    document.getElementById('chatIcon').className = chatOpen ? 'fas fa-times' : 'fas fa-comments';
    document.getElementById('chatBadge').style.display = 'none';
    if (chatOpen && document.getElementById('chatMessages').children.length === 0) {
      setTimeout(() => addBotMessage("👋 **Hello! I'm the NUT Admissions AI Assistant**\n\nI can help you with:\n• 📋 Program details & eligibility\n• 💰 Fee structure & scholarships\n• 📅 Deadlines & schedules\n• 🔍 Application status (send your ID)\n• 📝 Test information\n\n**What would you like to know?**"), 300);
    }
  };
  
  window.chatSend = function(text) {
    document.getElementById('chatInput').value = text;
    chatSendMsg();
  };
  
  async function chatSendMsg() {
    const input = document.getElementById('chatInput');
    const text = input.value.trim();
    if (!text) return;
    input.value = '';
    input.style.height = 'auto';
    addUserMessage(text);
    
    try {
      const response = await fetch('api.php?action=chatbot', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ message: text, session_id: sessionId })
      });
      const data = await response.json();
      addBotMessage(data.reply || "Sorry, I couldn't process that. Please try again.");
    } catch(e) {
      addBotMessage("⚠️ Connection error. Please check your internet and try again.");
    }
  }
  
  window.chatSendMsg = chatSendMsg;
  
  function addUserMessage(text) {
    const messages = document.getElementById('chatMessages');
    const div = document.createElement('div');
    div.className = 'msg user';
    div.innerHTML = `<div><div class="msg-bubble">${escapeHtml(text)}</div><div class="msg-time">${new Date().toLocaleTimeString([], {hour:'2-digit',minute:'2-digit'})}</div></div>`;
    messages.appendChild(div);
    messages.scrollTop = messages.scrollHeight;
  }
  
  function addBotMessage(text) {
    const messages = document.getElementById('chatMessages');
    const typing = document.createElement('div');
    typing.className = 'msg bot';
    typing.id = 'typingIndicator';
    typing.innerHTML = `<div class="bot-avatar"><i class="fas fa-robot"></i></div><div class="typing-indicator"><div class="typing-dot"></div><div class="typing-dot"></div><div class="typing-dot"></div></div>`;
    messages.appendChild(typing);
    messages.scrollTop = messages.scrollHeight;
    
    setTimeout(() => {
      const typingEl = document.getElementById('typingIndicator');
      if (typingEl) typingEl.remove();
      const div = document.createElement('div');
      div.className = 'msg bot';
      div.innerHTML = `<div class="bot-avatar"><i class="fas fa-robot"></i></div><div><div class="msg-bubble">${formatBotMessage(escapeHtml(text))}</div><div class="msg-time">${new Date().toLocaleTimeString([], {hour:'2-digit',minute:'2-digit'})}</div></div>`;
      messages.appendChild(div);
      messages.scrollTop = messages.scrollHeight;
    }, 800);
  }
  
  function formatBotMessage(text) {
    return text.replace(/\*\*(.*?)\*\*/g, '<strong>$1</strong>')
               .replace(/\n/g, '<br>')
               .replace(/•/g, '•');
  }
  
  function escapeHtml(text) {
    return text.replace(/&/g, '&amp;').replace(/</g, '&lt;').replace(/>/g, '&gt;');
  }
})();