const EMBEDDED_INDEX_HTML = raw"""<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>Ternary Cognitive AI — Dashboard</title>
  <style>
    :root {
      --bg: #0b1120;
      --card-bg: #1e293b;
      --card-border: #334155;
      --header-bg: #0f172a;
      --text: #f8fafc;
      --text-muted: #94a3b8;
      --accent: #6366f1;
      --accent-hover: #4f46e5;
      --green: #10b981;
      --green-bg: rgba(16, 185, 129, 0.15);
      --red: #f43f5e;
      --red-bg: rgba(244, 63, 94, 0.15);
      --purple: #8b5cf6;
      --cyan: #06b6d4;
      --amber: #f59e0b;
      --amber-bg: rgba(245, 158, 11, 0.15);
      --radius: 10px;
    }
    * { box-sizing: border-box; margin: 0; padding: 0; font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, Helvetica, Arial, sans-serif; }
    body { background-color: var(--bg); color: var(--text); min-height: 100vh; display: flex; flex-direction: column; }
    
    /* Top Navbar */
    header { background: var(--header-bg); border-bottom: 1px solid var(--card-border); padding: 12px 24px; display: flex; align-items: center; justify-content: space-between; flex-wrap: wrap; gap: 12px; }
    .brand { display: flex; align-items: center; gap: 12px; }
    .brand-icon { font-size: 26px; }
    .brand-title { font-size: 19px; font-weight: 700; letter-spacing: -0.5px; }
    .brand-subtitle { font-size: 12px; color: var(--text-muted); }
    
    .nav-tabs { display: flex; gap: 8px; background: #0b1120; padding: 4px; border-radius: 8px; border: 1px solid var(--card-border); }
    .tab-btn { background: transparent; border: none; color: var(--text-muted); padding: 8px 18px; border-radius: 6px; font-size: 14px; font-weight: 600; cursor: pointer; transition: all 0.2s; display: flex; align-items: center; gap: 6px; }
    .tab-btn:hover { color: var(--text); background: rgba(255, 255, 255, 0.05); }
    .tab-btn.active { color: #fff; background: var(--accent); shadow: 0 2px 8px rgba(99, 102, 241, 0.4); }

    .header-pills { display: flex; align-items: center; gap: 8px; flex-wrap: wrap; }
    .pill { background: #1e293b; border: 1px solid var(--card-border); padding: 5px 12px; border-radius: 20px; font-size: 12px; font-weight: 500; display: inline-flex; align-items: center; gap: 6px; }
    .pill-green { color: var(--green); border-color: rgba(16, 185, 129, 0.4); }
    .btn-sm { background: #334155; border: 1px solid #475569; color: var(--text); padding: 5px 12px; border-radius: 6px; font-size: 12px; font-weight: 600; cursor: pointer; transition: background 0.15s; }
    .btn-sm:hover { background: #475569; }

    /* Main Container */
    main { flex: 1; padding: 20px; max-width: 1400px; margin: 0 auto; width: 100%; display: flex; flex-direction: column; }
    .tab-content { display: none; height: 100%; }
    .tab-content.active { display: flex; flex-direction: column; flex: 1; }

    /* Page 1: Chatting Tab */
    .chat-layout { display: flex; flex-direction: column; flex: 1; gap: 14px; height: calc(100vh - 120px); }
    .chat-messages { flex: 1; overflow-y: auto; background: #0f172a; border: 1px solid var(--card-border); border-radius: var(--radius); padding: 20px; display: flex; flex-direction: column; gap: 16px; }
    
    .msg { display: flex; flex-direction: column; max-width: 85%; animation: fadeIn 0.2s ease-in; }
    @keyframes fadeIn { from { opacity: 0; transform: translateY(6px); } to { opacity: 1; transform: translateY(0); } }
    .msg-user { align-self: flex-end; }
    .msg-ai { align-self: flex-start; }
    
    .msg-bubble { padding: 12px 18px; border-radius: 12px; font-size: 15px; line-height: 1.5; }
    .msg-user .msg-bubble { background: var(--accent); color: white; border-bottom-right-radius: 2px; }
    .msg-ai .msg-bubble { background: var(--card-bg); border: 1px solid var(--card-border); color: var(--text); border-bottom-left-radius: 2px; }

    .msg-meta { margin-top: 8px; display: flex; flex-wrap: wrap; gap: 6px; font-size: 12px; align-items: center; }
    .badge { padding: 3px 8px; border-radius: 4px; font-weight: 600; font-size: 11px; text-transform: uppercase; }
    .badge-excellent { background: var(--green-bg); color: var(--green); border: 1px solid rgba(16, 185, 129, 0.4); }
    .badge-good { background: rgba(6, 182, 212, 0.15); color: var(--cyan); border: 1px solid rgba(6, 182, 212, 0.4); }
    .badge-rep { background: rgba(139, 92, 246, 0.15); color: var(--purple); border: 1px solid rgba(139, 92, 246, 0.4); }
    .badge-partial { background: var(--amber-bg); color: var(--amber); border: 1px solid rgba(245, 158, 11, 0.4); }
    .badge-wrong { background: var(--red-bg); color: var(--red); border: 1px solid rgba(244, 63, 94, 0.4); }
    .badge-info { background: #334155; color: #cbd5e1; }

    .trace-accordion { margin-top: 8px; font-size: 12px; }
    .trace-summary { cursor: pointer; color: var(--text-muted); user-select: none; font-weight: 500; display: inline-flex; align-items: center; gap: 4px; }
    .trace-summary:hover { color: var(--text); }
    .trace-body { margin-top: 6px; background: #090d16; border: 1px solid #1e293b; border-radius: 6px; padding: 10px; font-family: monospace; font-size: 11px; max-height: 220px; overflow-y: auto; white-space: pre-wrap; color: #cbd5e1; }

    /* Quick Prompts Bar */
    .quick-prompts { display: flex; gap: 8px; overflow-x: auto; padding-bottom: 2px; }
    .prompt-chip { background: #1e293b; border: 1px solid var(--card-border); color: var(--text-muted); padding: 6px 12px; border-radius: 20px; font-size: 12px; white-space: nowrap; cursor: pointer; transition: all 0.15s; }
    .prompt-chip:hover { background: #334155; color: var(--text); border-color: var(--accent); }

    /* Input Bar */
    .chat-input-bar { display: flex; flex-direction: column; gap: 8px; background: var(--card-bg); border: 1px solid var(--card-border); border-radius: var(--radius); padding: 12px; }
    .input-row { display: flex; gap: 10px; }
    .chat-input { flex: 1; background: #0f172a; border: 1px solid var(--card-border); color: var(--text); border-radius: 8px; padding: 12px 16px; font-size: 15px; outline: none; transition: border-color 0.2s; }
    .chat-input:focus { border-color: var(--accent); }
    .btn-send { background: var(--accent); color: white; border: none; border-radius: 8px; padding: 0 24px; font-size: 15px; font-weight: 600; cursor: pointer; transition: background 0.15s; display: flex; align-items: center; gap: 6px; }
    .btn-send:hover { background: var(--accent-hover); }

    .input-options { display: flex; gap: 16px; font-size: 12px; color: var(--text-muted); align-items: center; }
    .option-label { display: flex; align-items: center; gap: 6px; cursor: pointer; }
    .target-input { background: #0f172a; border: 1px solid var(--card-border); color: var(--text); border-radius: 6px; padding: 4px 8px; font-size: 12px; display: none; width: 260px; }

    /* Page 2: Training Tab */
    .training-grid { display: grid; grid-template-columns: 1.1fr 1fr; gap: 20px; flex: 1; }
    @media (max-width: 900px) { .training-grid { grid-template-columns: 1fr; } }
    
    .panel { background: var(--card-bg); border: 1px solid var(--card-border); border-radius: var(--radius); padding: 20px; display: flex; flex-direction: column; gap: 16px; }
    .panel-header { display: flex; justify-content: space-between; align-items: center; }
    .panel-title { font-size: 16px; font-weight: 700; display: flex; align-items: center; gap: 8px; }

    .dataset-select-row { display: flex; gap: 10px; align-items: center; }
    select, input[type="number"], input[type="text"] { background: #0f172a; border: 1px solid var(--card-border); color: var(--text); border-radius: 6px; padding: 8px 12px; font-size: 13px; outline: none; }
    select:focus, input:focus { border-color: var(--accent); }
    
    .train-editor { width: 100%; flex: 1; min-height: 220px; background: #090d16; border: 1px solid var(--card-border); color: #e2e8f0; border-radius: 6px; padding: 12px; font-family: monospace; font-size: 13px; resize: vertical; line-height: 1.4; outline: none; }
    .train-editor:focus { border-color: var(--accent); }
    
    .btn-train { background: var(--green); color: white; border: none; border-radius: 8px; padding: 12px 20px; font-size: 15px; font-weight: 700; cursor: pointer; transition: opacity 0.15s; display: flex; align-items: center; justify-content: center; gap: 8px; }
    .btn-train:hover { opacity: 0.9; }
    .btn-train:disabled { opacity: 0.5; cursor: not-allowed; }

    /* KPI Metrics Cards */
    .metrics-row { display: grid; grid-template-columns: repeat(auto-fit, minmax(110px, 1fr)); gap: 10px; }
    .kpi-card { background: #0f172a; border: 1px solid var(--card-border); border-radius: 8px; padding: 12px; text-align: center; }
    .kpi-val { font-size: 20px; font-weight: 700; color: #fff; margin-top: 4px; }
    .kpi-lbl { font-size: 11px; color: var(--text-muted); text-transform: uppercase; font-weight: 600; }

    /* Synapse Distribution Visual Bar */
    .synapse-bar { height: 16px; border-radius: 8px; overflow: hidden; display: flex; background: #334155; margin-top: 6px; }
    .synapse-pos { background: var(--green); height: 100%; transition: width 0.3s; }
    .synapse-zero { background: #64748b; height: 100%; transition: width 0.3s; }
    .synapse-neg { background: var(--red); height: 100%; transition: width 0.3s; }

    .train-log { background: #090d16; border: 1px solid var(--card-border); border-radius: 6px; padding: 12px; font-family: monospace; font-size: 12px; height: 180px; overflow-y: auto; white-space: pre-wrap; color: #cbd5e1; }

    /* Modal for Concepts / Relations */
    .modal-overlay { display: none; position: fixed; inset: 0; background: rgba(0,0,0,0.7); align-items: center; justify-content: center; z-index: 100; }
    .modal-overlay.active { display: flex; }
    .modal-box { background: var(--card-bg); border: 1px solid var(--card-border); border-radius: var(--radius); width: 680px; max-width: 90vw; max-height: 80vh; display: flex; flex-direction: column; overflow: hidden; }
    .modal-header { padding: 16px 20px; border-bottom: 1px solid var(--card-border); display: flex; justify-content: space-between; align-items: center; }
    .modal-body { padding: 20px; overflow-y: auto; font-size: 13px; }
  </style>
</head>
<body>

  <!-- Top Header -->
  <header>
    <div class="brand">
      <div class="brand-icon">🧠</div>
      <div>
        <div class="brand-title">Ternary Cognitive AI</div>
        <div class="brand-subtitle">Neuro-Symbolic Discrete {-1, 0, +1} Architecture</div>
      </div>
    </div>

    <!-- Navigation Tabs -->
    <div class="nav-tabs">
      <button class="tab-btn active" onclick="switchTab('chat')">💬 Chatting</button>
      <button class="tab-btn" onclick="switchTab('train')">🎓 Training</button>
    </div>

    <!-- Live System Pills & Controls -->
    <div class="header-pills">
      <div class="pill pill-green"><span id="pill-status">● Ready</span></div>
      <div class="pill" id="pill-scale">Scale: small</div>
      <div class="pill" id="pill-synapses">Synapses: +0 | 0:0 | -0</div>
      <div class="pill" id="pill-concepts">Concepts: 0</div>
      <button class="btn-sm" onclick="showModal('concepts')">Concepts</button>
      <button class="btn-sm" onclick="showModal('relations')">Relations</button>
      <button class="btn-sm" onclick="resetAgent()">🔄 Reset</button>
    </div>
  </header>

  <main>
    <!-- TAB 1: CHATTING -->
    <div id="tab-chat" class="tab-content active">
      <div class="chat-layout">
        <!-- Message Feed -->
        <div class="chat-messages" id="chat-feed">
          <div class="msg msg-ai">
            <div class="msg-bubble">
              Hello! I am the <strong>Ternary Cognitive AI</strong> reasoning engine. You can teach me declarative facts (e.g. <code>sun causes heat</code>), ask deductive questions (e.g. <code>why sun causes expansion</code>), request repetitions, or enforce constraints like JSON structure.
            </div>
            <div class="msg-meta">
              <span class="badge badge-good">System Initialized</span>
              <span style="color: var(--text-muted);">Ready for input</span>
            </div>
          </div>
        </div>

        <!-- Quick Prompts Bar -->
        <div class="quick-prompts">
          <span style="font-size: 12px; color: var(--text-muted); align-self: center;">Try:</span>
          <div class="prompt-chip" onclick="sendQuickPrompt('sun causes heat')">☀️ sun causes heat</div>
          <div class="prompt-chip" onclick="sendQuickPrompt('heat causes expansion')">🔥 heat causes expansion</div>
          <div class="prompt-chip" onclick="sendQuickPrompt('why sun causes expansion')">❓ why sun causes expansion</div>
          <div class="prompt-chip" onclick="sendQuickPrompt('rain causes wet ground')">🌧️ rain causes wet ground</div>
          <div class="prompt-chip" onclick="sendQuickPrompt('why rain causes slippery pavement')">❓ why rain causes slippery pavement</div>
          <div class="prompt-chip" onclick="sendQuickPrompt('repeat this')">🔁 repeat this</div>
          <div class="prompt-chip" onclick="sendQuickPrompt('sun causes heat in json')">📋 in json</div>
        </div>

        <!-- Chat Input Bar -->
        <div class="chat-input-bar">
          <div class="input-row">
            <input type="text" id="chat-input" class="chat-input" placeholder="Enter a statement, query, or command..." autocomplete="off">
            <button class="btn-send" id="btn-send" onclick="handleSendChat()">
              <span>Send</span> ➤
            </button>
          </div>
          <div class="input-options">
            <label class="option-label">
              <input type="checkbox" id="chk-supervised" onchange="toggleSupervised()">
              Supervised Target
            </label>
            <input type="text" id="target-input" class="target-input" placeholder="Expected output (e.g. 'sun causes heat')">
            <span style="margin-left: auto; cursor: pointer; color: var(--text-muted);" onclick="clearChat()">🗑️ Clear Chat</span>
          </div>
        </div>
      </div>
    </div>

    <!-- TAB 2: TRAINING -->
    <div id="tab-train" class="tab-content">
      <div class="training-grid">
        <!-- Left Panel: Data & Training -->
        <div class="panel">
          <div class="panel-header">
            <div class="panel-title">📚 Dataset & Training Controls</div>
          </div>

          <div class="dataset-select-row">
            <label style="font-size: 13px; color: var(--text-muted);">Preset Dataset:</label>
            <select id="dataset-select" onchange="onDatasetSelected()">
              <option value="data/train.txt">data/train.txt (Foundational)</option>
              <option value="data/science.txt">data/science.txt (Science & Physics)</option>
              <option value="data/logic.txt">data/logic.txt (Logic & Deduction)</option>
              <option value="custom">Custom Text Input</option>
            </select>
            <button class="btn-sm" onclick="loadDatasetToEditor()">Reload</button>
          </div>

          <textarea id="train-text" class="train-editor" placeholder="input | expected output | optional quality"></textarea>

          <div style="display: flex; gap: 16px; align-items: center; flex-wrap: wrap;">
            <div style="display: flex; gap: 8px; align-items: center;">
              <label style="font-size: 13px; color: var(--text-muted);">Epochs:</label>
              <input type="number" id="train-epochs" value="3" min="1" max="20" style="width: 70px;">
            </div>
            <button class="btn-train" id="btn-start-train" onclick="startTraining()" style="flex: 1;">
              <span>🚀 Start Training</span>
            </button>
          </div>

          <!-- Quick Teach Section -->
          <div style="border-top: 1px solid var(--card-border); padding-top: 14px; margin-top: 6px;">
            <div style="font-size: 13px; font-weight: 700; margin-bottom: 8px;">⚡ Single-Pair Quick Teach</div>
            <div style="display: flex; gap: 8px;">
              <input type="text" id="quick-teach-input" placeholder="Input (e.g. spark causes fire)" style="flex: 1;">
              <input type="text" id="quick-teach-expected" placeholder="Expected Target" style="flex: 1;">
              <button class="btn-sm" onclick="handleQuickTeach()">Teach</button>
            </div>
          </div>
        </div>

        <!-- Right Panel: Live Metrics & Feedback -->
        <div class="panel">
          <div class="panel-header">
            <div class="panel-title">📊 Cognitive Metrics & Synaptic State</div>
          </div>

          <!-- KPI Cards -->
          <div class="metrics-row">
            <div class="kpi-card">
              <div class="kpi-lbl">Episodes</div>
              <div class="kpi-val" id="kpi-episodes">0</div>
            </div>
            <div class="kpi-card">
              <div class="kpi-lbl">Reward</div>
              <div class="kpi-val" style="color: var(--green);" id="kpi-reward">+0.00</div>
            </div>
            <div class="kpi-card">
              <div class="kpi-lbl">Penalty</div>
              <div class="kpi-val" style="color: var(--red);" id="kpi-punish">-0.00</div>
            </div>
            <div class="kpi-card">
              <div class="kpi-lbl">Corrections</div>
              <div class="kpi-val" id="kpi-corrections">0</div>
            </div>
          </div>

          <!-- Synapse Distribution Bar -->
          <div>
            <div style="display: flex; justify-content: space-between; font-size: 12px; margin-bottom: 4px;">
              <span>Ternary Weights: <strong id="lbl-syn-pos">+1 (0)</strong> · <span id="lbl-syn-zero">0 (0)</span> · <strong id="lbl-syn-neg" style="color: var(--red);">-1 (0)</strong></span>
              <span id="lbl-syn-total">Total: 0</span>
            </div>
            <div class="synapse-bar">
              <div class="synapse-pos" id="bar-pos" style="width: 33%;"></div>
              <div class="synapse-zero" id="bar-zero" style="width: 34%;"></div>
              <div class="synapse-neg" id="bar-neg" style="width: 33%;"></div>
            </div>
          </div>

          <!-- Training Output Console -->
          <div style="display: flex; flex-direction: column; flex: 1;">
            <div style="font-size: 12px; color: var(--text-muted); margin-bottom: 4px;">Live Training Output:</div>
            <div class="train-log" id="train-log">Awaiting training start...</div>
          </div>

          <!-- Model Management Row -->
          <div style="border-top: 1px solid var(--card-border); padding-top: 12px; display: flex; gap: 8px; align-items: center;">
            <input type="text" id="model-file-path" value="data/model.bin" style="flex: 1;" placeholder="data/model.bin">
            <button class="btn-sm" onclick="saveModel()">💾 Save</button>
            <button class="btn-sm" onclick="loadModel()">📂 Load</button>
          </div>
        </div>
      </div>
    </div>
  </main>

  <!-- Modal for Concepts / Relations Inspection -->
  <div class="modal-overlay" id="modal-overlay" onclick="closeModal(event)">
    <div class="modal-box" onclick="event.stopPropagation()">
      <div class="modal-header">
        <div style="font-weight: 700; font-size: 16px;" id="modal-title">Memory Inspection</div>
        <button class="btn-sm" onclick="closeModal()">✕</button>
      </div>
      <div class="modal-body" id="modal-content">Loading...</div>
    </div>
  </div>

  <script>
    // Tab switching
    function switchTab(tabId) {
      document.querySelectorAll('.tab-btn').forEach(b => b.classList.remove('active'));
      document.querySelectorAll('.tab-content').forEach(c => c.classList.remove('active'));
      if (tabId === 'chat') {
        document.querySelectorAll('.tab-btn')[0].classList.add('active');
        document.getElementById('tab-chat').classList.add('active');
      } else {
        document.querySelectorAll('.tab-btn')[1].classList.add('active');
        document.getElementById('tab-train').classList.add('active');
      }
    }

    function toggleSupervised() {
      const chk = document.getElementById('chk-supervised').checked;
      document.getElementById('target-input').style.display = chk ? 'inline-block' : 'none';
    }

    // Refresh Agent Status
    async function refreshStatus() {
      try {
        const res = await fetch('/api/status');
        const data = await res.json();
        document.getElementById('pill-scale').innerText = 'Scale: ' + data.scale;
        document.getElementById('pill-concepts').innerText = 'Concepts: ' + data.concepts;
        document.getElementById('pill-synapses').innerText = `Synapses: +${data.synapses.positive} | 0:${data.synapses.zero} | -${data.synapses.negative}`;
        
        // Update KPIs
        document.getElementById('kpi-episodes').innerText = data.metrics.episodes;
        document.getElementById('kpi-reward').innerText = '+' + data.metrics.total_reward.toFixed(2);
        document.getElementById('kpi-punish').innerText = '-' + data.metrics.total_punishment.toFixed(2);
        document.getElementById('kpi-corrections').innerText = data.metrics.self_corrections;

        // Update Synapse bar
        const total = data.synapses.total || 1;
        const pctPos = (data.synapses.positive / total) * 100;
        const pctZero = (data.synapses.zero / total) * 100;
        const pctNeg = (data.synapses.negative / total) * 100;
        document.getElementById('bar-pos').style.width = pctPos + '%';
        document.getElementById('bar-zero').style.width = pctZero + '%';
        document.getElementById('bar-neg').style.width = pctNeg + '%';
        document.getElementById('lbl-syn-pos').innerText = `+1 (${data.synapses.positive})`;
        document.getElementById('lbl-syn-zero').innerText = `0 (${data.synapses.zero})`;
        document.getElementById('lbl-syn-neg').innerText = `-1 (${data.synapses.negative})`;
        document.getElementById('lbl-syn-total').innerText = `Total: ${data.synapses.total}`;
      } catch (err) {
        console.error('Failed to fetch status:', err);
      }
    }

    // Send Chat
    async function handleSendChat() {
      const inputEl = document.getElementById('chat-input');
      const text = inputEl.value.trim();
      if (!text) return;

      const isSupervised = document.getElementById('chk-supervised').checked;
      const expected = isSupervised ? document.getElementById('target-input').value.trim() : null;

      // Add user message to UI
      appendUserMessage(text);
      inputEl.value = '';

      const btn = document.getElementById('btn-send');
      btn.disabled = true;

      try {
        const payload = { input: text };
        if (expected) payload.expected = expected;

        const res = await fetch('/api/chat', {
          method: 'POST',
          headers: { 'Content-Type': 'application/json' },
          body: JSON.stringify(payload)
        });
        const data = await res.json();
        appendAIMessage(data);
        refreshStatus();
      } catch (err) {
        appendAIMessage({ output: 'Error communicating with reasoning engine: ' + err.message, quality: 'WRONG' });
      } finally {
        btn.disabled = false;
        inputEl.focus();
      }
    }

    function sendQuickPrompt(promptText) {
      document.getElementById('chat-input').value = promptText;
      handleSendChat();
    }

    function appendUserMessage(text) {
      const feed = document.getElementById('chat-feed');
      const div = document.createElement('div');
      div.className = 'msg msg-user';
      div.innerHTML = `<div class="msg-bubble">${escapeHtml(text)}</div>`;
      feed.appendChild(div);
      feed.scrollTop = feed.scrollHeight;
    }

    function appendAIMessage(data) {
      const feed = document.getElementById('chat-feed');
      const div = document.createElement('div');
      div.className = 'msg msg-ai';

      let qualityClass = 'badge-info';
      if (data.quality === 'EXCELLENT') qualityClass = 'badge-excellent';
      else if (data.quality === 'GOOD') qualityClass = 'badge-good';
      else if (data.quality === 'REQUESTED_REPETITION') qualityClass = 'badge-rep';
      else if (data.quality === 'PARTIAL') qualityClass = 'badge-partial';
      else if (data.quality === 'WRONG' || (data.quality && data.quality.includes('FAILURE'))) qualityClass = 'badge-wrong';

      const sigStr = data.reward > 0 ? `+${data.reward.toFixed(2)} Reward` :
                     data.punishment > 0 ? `-${data.punishment.toFixed(2)} Penalty` : `0.00`;

      let traceHtml = '';
      if (data.trace && data.trace.length > 0) {
        traceHtml = `
          <details class="trace-accordion">
            <summary class="trace-summary">🔍 View Reasoning Trace (${data.trace.length} steps)</summary>
            <div class="trace-body">${escapeHtml(data.trace.join('\n'))}</div>
          </details>
        `;
      }

      div.innerHTML = `
        <div class="msg-bubble">${escapeHtml(data.output)}</div>
        <div class="msg-meta">
          <span class="badge ${qualityClass}">${data.quality || 'OUTPUT'}</span>
          <span class="badge badge-info">Conf: ${((data.confidence || 0) * 100).toFixed(0)}%</span>
          <span class="badge badge-info">${sigStr}</span>
          <span class="badge badge-info">${data.synaptic_changes || 0} transitions</span>
          ${data.contradiction ? '<span class="badge badge-wrong">Contradiction Backtracked</span>' : ''}
        </div>
        ${traceHtml}
      `;
      feed.appendChild(div);
      feed.scrollTop = feed.scrollHeight;
    }

    function clearChat() {
      document.getElementById('chat-feed').innerHTML = `
        <div class="msg msg-ai">
          <div class="msg-bubble">Chat cleared. Ready for your input.</div>
        </div>
      `;
    }

    // Dataset Management
    async function loadDatasetToEditor() {
      const select = document.getElementById('dataset-select');
      const filename = select.value;
      if (filename === 'custom') return;
      try {
        const res = await fetch('/api/dataset?name=' + encodeURIComponent(filename));
        const data = await res.json();
        document.getElementById('train-text').value = data.content || '';
      } catch (err) {
        alert('Failed to load dataset: ' + err.message);
      }
    }

    function onDatasetSelected() {
      loadDatasetToEditor();
    }

    // Training Process
    async function startTraining() {
      const text = document.getElementById('train-text').value.trim();
      if (!text) {
        alert('Please enter or load training data.');
        return;
      }
      const epochs = parseInt(document.getElementById('train-epochs').value) || 1;
      const btn = document.getElementById('btn-start-train');
      const logEl = document.getElementById('train-log');

      btn.disabled = true;
      btn.innerText = '⏳ Training...';
      logEl.innerText = `Starting training for ${epochs} epoch(s)...\n`;

      try {
        const res = await fetch('/api/train', {
          method: 'POST',
          headers: { 'Content-Type': 'application/json' },
          body: JSON.stringify({ text: text, epochs: epochs })
        });
        const data = await res.json();
        logEl.innerText = data.logs || 'Training completed successfully.';
        refreshStatus();
      } catch (err) {
        logEl.innerText += '\n[Error] Training failed: ' + err.message;
      } finally {
        btn.disabled = false;
        btn.innerText = '🚀 Start Training';
      }
    }

    async function handleQuickTeach() {
      const inp = document.getElementById('quick-teach-input').value.trim();
      const exp = document.getElementById('quick-teach-expected').value.trim();
      if (!inp || !exp) {
        alert('Please provide both input and expected target.');
        return;
      }
      try {
        const res = await fetch('/api/teach', {
          method: 'POST',
          headers: { 'Content-Type': 'application/json' },
          body: JSON.stringify({ input: inp, expected: exp })
        });
        const data = await res.json();
        alert(`Learned: "${inp}" -> "${data.output}" (Quality: ${data.quality})`);
        document.getElementById('quick-teach-input').value = '';
        document.getElementById('quick-teach-expected').value = '';
        refreshStatus();
      } catch (err) {
        alert('Teach error: ' + err.message);
      }
    }

    async function resetAgent() {
      if (!confirm('Reset the agent to fresh state?')) return;
      try {
        await fetch('/api/reset', { method: 'POST', headers: { 'Content-Type': 'application/json' }, body: JSON.stringify({ scale: 'small' }) });
        refreshStatus();
        clearChat();
        alert('Agent reinitialized.');
      } catch (err) {
        alert('Reset failed: ' + err.message);
      }
    }

    async function saveModel() {
      const path = document.getElementById('model-file-path').value.trim();
      if (!path) return;
      try {
        const res = await fetch('/api/save', { method: 'POST', headers: { 'Content-Type': 'application/json' }, body: JSON.stringify({ path: path }) });
        const data = await res.json();
        alert(data.message || 'Saved successfully');
      } catch (err) {
        alert('Save error: ' + err.message);
      }
    }

    async function loadModel() {
      const path = document.getElementById('model-file-path').value.trim();
      if (!path) return;
      try {
        const res = await fetch('/api/load', { method: 'POST', headers: { 'Content-Type': 'application/json' }, body: JSON.stringify({ path: path }) });
        const data = await res.json();
        alert(data.message || 'Loaded successfully');
        refreshStatus();
      } catch (err) {
        alert('Load error: ' + err.message);
      }
    }

    // Modal Inspection
    async function showModal(type) {
      const overlay = document.getElementById('modal-overlay');
      const title = document.getElementById('modal-title');
      const content = document.getElementById('modal-content');
      overlay.classList.add('active');
      content.innerHTML = 'Loading...';

      if (type === 'concepts') {
        title.innerText = 'Semantic Memory: Known Concepts';
        const res = await fetch('/api/concepts');
        const list = await res.json();
        if (!list || list.length === 0) {
          content.innerHTML = '<em>No concepts learned yet.</em>';
          return;
        }
        let html = '<table style="width:100%; border-collapse:collapse;">';
        html += '<tr style="border-bottom:1px solid #334155; text-align:left; color:#94a3b8;"><th>ID</th><th>Concept</th><th>Reliability</th><th>Successes</th><th>Failures</th><th>Freq</th></tr>';
        list.forEach(c => {
          html += `<tr style="border-bottom:1px solid #1e293b;"><td style="padding:6px;">${c.id}</td><td style="font-weight:600; color:#fff;">${escapeHtml(c.name)}</td><td>${c.reliability.toFixed(2)}</td><td>${c.successes}</td><td>${c.failures}</td><td>${c.frequency}</td></tr>`;
        });
        html += '</table>';
        content.innerHTML = html;
      } else if (type === 'relations') {
        title.innerText = 'Semantic Memory: Stored & Deduced Relations';
        const res = await fetch('/api/relations');
        const list = await res.json();
        if (!list || list.length === 0) {
          content.innerHTML = '<em>No relations stored yet.</em>';
          return;
        }
        let html = '<table style="width:100%; border-collapse:collapse;">';
        html += '<tr style="border-bottom:1px solid #334155; text-align:left; color:#94a3b8;"><th>Subject</th><th>Predicate</th><th>Object</th><th>Provenance</th></tr>';
        list.forEach(r => {
          html += `<tr style="border-bottom:1px solid #1e293b;"><td style="padding:6px; font-weight:600;">${escapeHtml(r.subject)}</td><td style="color:#6366f1;">${escapeHtml(r.predicate)}</td><td style="font-weight:600;">${escapeHtml(r.object)}</td><td style="color:#94a3b8;">${escapeHtml(r.provenance)}</td></tr>`;
        });
        html += '</table>';
        content.innerHTML = html;
      }
    }

    function closeModal() {
      document.getElementById('modal-overlay').classList.remove('active');
    }

    function escapeHtml(str) {
      if (!str) return '';
      return String(str).replace(/&/g, '&amp;').replace(/</g, '&lt;').replace(/>/g, '&gt;').replace(/"/g, '&quot;');
    }

    // Keyboard enter in chat
    document.getElementById('chat-input').addEventListener('keydown', e => {
      if (e.key === 'Enter') {
        e.preventDefault();
        handleSendChat();
      }
    });

    // Initialize
    window.addEventListener('load', () => {
      refreshStatus();
      loadDatasetToEditor();
    });
  </script>
</body>
</html>
"""

const EMBEDDED_TRAIN_TXT = raw"""# Foundational Knowledge Training Data
# Format: input | expected output | optional quality

sun causes heat | sun causes heat
heat causes expansion | heat causes expansion
why sun causes expansion | sun causes expansion
rain causes wet ground | rain causes wet ground
wet ground causes slippery pavement | wet ground causes slippery pavement
why rain causes slippery pavement | rain causes slippery pavement
spark causes fire | spark causes fire
fire causes smoke | fire causes smoke
why spark causes smoke | spark causes smoke
water prevents fire | water prevents fire
"""

const EMBEDDED_LOGIC_TXT = raw"""# Logic and Deduction Dataset for Ternary Cognitive AI
# Format: input | expected output | optional quality

a causes b | a causes b
b causes c | b causes c
c causes d | c causes d
why a causes c | a causes c
why b causes d | b causes d
why a causes d | a causes d
x prevents y | x prevents y
y causes z | y causes z
repeat this | why a causes d | REQUESTED_REPETITION
"""

const EMBEDDED_SCIENCE_TXT = raw"""# Science Reasoning Dataset for Ternary Cognitive AI
# Format: input | expected output | optional quality

sun causes heat | sun causes heat
heat causes evaporation | heat causes evaporation
evaporation causes clouds | evaporation causes clouds
clouds cause rain | clouds cause rain
rain causes wet ground | rain causes wet ground
wet ground causes slippery pavement | wet ground causes slippery pavement
gravity causes attraction | gravity causes attraction
friction causes resistance | friction causes resistance
resistance causes deceleration | resistance causes deceleration
ice prevents heat | ice prevents heat
why sun causes evaporation | sun causes evaporation
why evaporation causes rain | evaporation causes rain
why rain causes slippery pavement | rain causes slippery pavement
why friction causes deceleration | friction causes deceleration
"""

const EMBEDDED_DATASETS = Dict{String,String}(
    "data/train.txt" => EMBEDDED_TRAIN_TXT,
    "train.txt" => EMBEDDED_TRAIN_TXT,
    "data/logic.txt" => EMBEDDED_LOGIC_TXT,
    "logic.txt" => EMBEDDED_LOGIC_TXT,
    "data/science.txt" => EMBEDDED_SCIENCE_TXT,
    "science.txt" => EMBEDDED_SCIENCE_TXT,
)
