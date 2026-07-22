(function(){
  const $ = (s)=>document.querySelector(s);
  const $$ = (s)=>document.querySelectorAll(s);

  function fmtTime(ms){
    if (!ms) return '-';
    return new Date(ms).toLocaleString();
  }
  function timeLeft(ms){
    const d = ms - Date.now();
    if (d <= 0) return 'expired';
    const h = Math.floor(d/3600000);
    const m = Math.floor((d%3600000)/60000);
    return `${h}h ${m}m`;
  }

  async function api(path, opts){
    const r = await fetch(path, Object.assign({headers:{'Content-Type':'application/json'}}, opts||{}));
    if (r.status === 401){
      window.location.href = '/api/v3/auth/admin/manager.html';
      throw new Error('unauthorized');
    }
    return r.json();
  }

  async function refresh(){
    const data = await api('/api/v3/auth/admin/api/keys');
    const keys = data.keys || {};
    const blocked = data.blocked || {};

    const keyList = Object.values(keys);
    const activeKeys = keyList.filter(k=>k.expireAt > Date.now());
    const blockList = Object.entries(blocked);

    $('#statKeys').textContent = keyList.length;
    $('#statActive').textContent = activeKeys.length;
    $('#statBlocked').textContent = blockList.length;

    const tbody = $('#keysBody');
    tbody.innerHTML = '';
    keyList.forEach(k=>{
      const tr = document.createElement('tr');
      tr.innerHTML = `
        <td class="mono">${k.key}</td>
        <td>${k.duration||'-'}</td>
        <td class="mono">${k.hwid||'-'}</td>
        <td>${fmtTime(k.createdAt)}</td>
        <td>${fmtTime(k.expireAt)}</td>
        <td>${timeLeft(k.expireAt)}</td>
        <td>
          <button class="btn btn-warn" data-act="extend" data-key="${k.key}">+24h</button>
          <button class="btn" data-act="reduce" data-key="${k.key}">-1h</button>
          <button class="btn btn-danger" data-act="delete" data-key="${k.key}">Delete</button>
        </td>`;
      tbody.appendChild(tr);
    });

    const btbody = $('#blockedBody');
    btbody.innerHTML = '';
    blockList.forEach(([k,v])=>{
      const tr = document.createElement('tr');
      tr.innerHTML = `
        <td class="mono">${k}</td>
        <td>${v.reason||'-'}</td>
        <td>${fmtTime(v.until)}</td>
        <td>${timeLeft(v.until)}</td>
        <td><button class="btn btn-danger" data-act="unblock" data-target="${k}">Clear</button></td>`;
      btbody.appendChild(tr);
    });

    $$('button[data-act]').forEach(btn=>{
      btn.addEventListener('click', async ()=>{
        const act = btn.dataset.act;
        const key = btn.dataset.key;
        const target = btn.dataset.target;
        if (act === 'extend'){
          await api('/api/v3/auth/admin/api/keys/extend',{method:'POST',body:JSON.stringify({key,hours:24})});
        } else if (act === 'reduce'){
          await api('/api/v3/auth/admin/api/keys/reduce',{method:'POST',body:JSON.stringify({key,hours:1})});
        } else if (act === 'delete'){
          if (!confirm('Delete key '+key+'?')) return;
          await api('/api/v3/auth/admin/api/keys/delete',{method:'POST',body:JSON.stringify({key})});
        } else if (act === 'unblock'){
          await api('/api/v3/auth/admin/api/blocked/clear',{method:'POST',body:JSON.stringify({target})});
        }
        refresh();
      });
    });
  }

  const addBtn = $('#addKeyBtn');
  if (addBtn){
    addBtn.addEventListener('click', async ()=>{
      const hours = parseInt($('#addHours').value || '24', 10);
      const hwid = $('#addHwid').value || '';
      const customKey = $('#addKey').value || '';
      const body = {hours, hwid};
      if (customKey) body.key = customKey;
      const r = await api('/api/v3/auth/admin/api/keys/add',{method:'POST',body:JSON.stringify(body)});
      if (r.status === 'ok'){
        $('#addHwid').value = '';
        $('#addKey').value = '';
        refresh();
      }
    });
  }

  refresh();
  setInterval(refresh, 10000);
})();
