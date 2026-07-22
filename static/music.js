(function(){
  const player = document.getElementById('music-player');
  if (!player) return;
  const audio = document.getElementById('audio');
  if (!audio) return;

  const TRACKS = [
    { title: 'Track 1', artist: 'Lonely Hub', src: '/static/Musics/track1.mp3' },
    { title: 'Track 2', artist: 'Lonely Hub', src: '/static/Musics/track2.mp3' },
    { title: 'Track 3', artist: 'Lonely Hub', src: '/static/Musics/track3.mp3' },
  ];

  let currentIdx = 0;
  let isMuted = false;
  let isMinimized = true;

  const VOL_ON_SVG = '<polygon points="11 5 6 9 2 9 2 15 6 15 11 19 11 5"/><path d="M15.54 8.46a5 5 0 010 7.07"/><path d="M19.07 4.93a10 10 0 010 14.14"/>';
  const VOL_OFF_SVG = '<polygon points="11 5 6 9 2 9 2 15 6 15 11 19 11 5"/><line x1="23" y1="9" x2="17" y2="15"/><line x1="17" y1="9" x2="23" y2="15"/>';

  function $(id){ return document.getElementById(id); }
  function fmtTime(s){ if (!s || isNaN(s)) return '0:00'; return Math.floor(s/60)+':'+String(Math.floor(s%60)).padStart(2,'0'); }
  function setProgFill(pct){ const el=$('prog-fill'); if(el) el.style.width = pct + '%'; }
  function setVolFill(pct){ const el=$('vol-fill'); if(el) el.style.width = pct + '%'; }

  function loadTrack(idx, play){
    currentIdx = idx;
    const t = TRACKS[idx];
    const titleEl=$('mp-title'), artistEl=$('mp-artist'), curEl=$('t-cur'), totEl=$('t-tot'), pi=$('prog-input');
    if (titleEl) titleEl.textContent = t.title;
    if (artistEl) artistEl.textContent = t.artist;
    audio.src = t.src;
    if (curEl) curEl.textContent = '0:00';
    if (totEl) totEl.textContent = '0:00';
    setProgFill(0);
    if (pi) pi.value = 0;
    audio.onerror = ()=>{ if (titleEl) titleEl.textContent = 'Add music to /Musics'; };
    if (play) audio.play().catch(()=>{});
  }

  function togglePlay(){ if (audio.paused) audio.play().catch(()=>{}); else audio.pause(); }
  function prevTrack(){ loadTrack((currentIdx - 1 + TRACKS.length) % TRACKS.length, !audio.paused); }
  function nextTrack(){ loadTrack((currentIdx + 1) % TRACKS.length, !audio.paused); }
  function toggleMute(){ isMuted = !isMuted; audio.muted = isMuted; const ic=$('icon-vol'); if(ic) ic.innerHTML = isMuted ? VOL_OFF_SVG : VOL_ON_SVG; }
  function onSeek(input){ if (audio.duration) audio.currentTime = (input.value / 100) * audio.duration; setProgFill(input.value); }
  function onVolume(input){ audio.volume = input.value; isMuted = false; audio.muted = false; setVolFill(input.value * 100); const ic=$('icon-vol'); if(ic) ic.innerHTML = VOL_ON_SVG; }
  function applyMinimized(){
    player.classList.toggle('minimized', isMinimized);
    const btn=$('mp-minimize');
    if(btn) btn.style.transform = isMinimized ? 'rotate(180deg)' : '';
  }
  function toggleMinimize(){ isMinimized = !isMinimized; applyMinimized(); }

  window.togglePlay = togglePlay;
  window.prevTrack = prevTrack;
  window.nextTrack = nextTrack;
  window.toggleMute = toggleMute;
  window.onSeek = onSeek;
  window.onVolume = onVolume;
  window.toggleMinimize = toggleMinimize;

  audio.addEventListener('timeupdate', ()=>{
    const pct = audio.duration ? (audio.currentTime / audio.duration) * 100 : 0;
    const cur=$('t-cur'); if(cur) cur.textContent = fmtTime(audio.currentTime);
    setProgFill(pct);
    const pi=$('prog-input'); if(pi) pi.value = pct;
  });
  audio.addEventListener('loadedmetadata', ()=>{ const tot=$('t-tot'); if(tot) tot.textContent = fmtTime(audio.duration); });
  audio.addEventListener('ended', nextTrack);
  audio.addEventListener('play', ()=>{ const ic=$('play-icon'); if(ic) ic.innerHTML = '<rect x="5" y="4" width="4" height="16" rx="1.5"/><rect x="15" y="4" width="4" height="16" rx="1.5"/>'; });
  audio.addEventListener('pause', ()=>{ const ic=$('play-icon'); if(ic) ic.innerHTML = '<polygon points="5 3 19 12 5 21 5 3"/>'; });

  audio.volume = 0.7;

  const handle = document.getElementById('drag-handle');
  let dragging = false;
  let startX, startY, origLeft, origTop;
  let moved = false;

  function clamp(v, min, max){ return Math.max(min, Math.min(max, v)); }

  function getLeft(){
    if (player.style.left && player.style.left !== '' && player.style.left !== 'auto') return parseInt(player.style.left);
    return window.innerWidth - player.offsetWidth - 14;
  }
  function getTop(){
    if (player.style.top && player.style.top !== '' && player.style.top !== 'auto') return parseInt(player.style.top);
    return window.innerHeight - player.offsetHeight - 96;
  }

  function onMove(e){
    if (!dragging) return;
    const cx = e.touches ? e.touches[0].clientX : e.clientX;
    const cy = e.touches ? e.touches[0].clientY : e.clientY;
    const dx = cx - startX;
    const dy = cy - startY;
    if (Math.abs(dx) > 3 || Math.abs(dy) > 3) moved = true;
    const maxL = window.innerWidth - player.offsetWidth;
    const maxT = window.innerHeight - player.offsetHeight;
    player.style.left = clamp(origLeft + dx, 0, maxL) + 'px';
    player.style.top = clamp(origTop + dy, 0, maxT) + 'px';
    if (e.cancelable) e.preventDefault();
  }
  function onEnd(){
    if (!dragging) return;
    dragging = false;
    player.classList.remove('dragging');
    document.removeEventListener('mousemove', onMove);
    document.removeEventListener('mouseup', onEnd);
    document.removeEventListener('touchmove', onMove, { passive:false });
    document.removeEventListener('touchend', onEnd);
    document.removeEventListener('touchcancel', onEnd);
    if (moved){
      try {
        localStorage.setItem('mp-pos', JSON.stringify({
          left: parseInt(player.style.left),
          top: parseInt(player.style.top),
        }));
      } catch(e){}
    }
  }
  function onStart(e){
    if (e.target.closest('button')) return;
    const cx = e.touches ? e.touches[0].clientX : e.clientX;
    const cy = e.touches ? e.touches[0].clientY : e.clientY;
    dragging = true;
    moved = false;
    startX = cx; startY = cy;
    origLeft = getLeft();
    origTop = getTop();
    player.style.setProperty('right','auto','important');
    player.style.setProperty('bottom','auto','important');
    player.style.left = origLeft + 'px';
    player.style.top = origTop + 'px';
    player.classList.add('dragging');
    document.addEventListener('mousemove', onMove);
    document.addEventListener('mouseup', onEnd);
    document.addEventListener('touchmove', onMove, { passive:false });
    document.addEventListener('touchend', onEnd);
    document.addEventListener('touchcancel', onEnd);
    if (e.cancelable) e.preventDefault();
  }

  if (handle){
    handle.addEventListener('mousedown', onStart);
    handle.addEventListener('touchstart', onStart, { passive:false });
  }

  window.addEventListener('resize', ()=>{
    if (!player.style.left || player.style.left === 'auto') return;
    const maxL = window.innerWidth - player.offsetWidth;
    const maxT = window.innerHeight - player.offsetHeight;
    player.style.left = clamp(parseInt(player.style.left), 0, maxL) + 'px';
    player.style.top = clamp(parseInt(player.style.top), 0, maxT) + 'px';
  });

  function init(){
    const saved = (function(){ try { return JSON.parse(localStorage.getItem('mp-pos') || 'null'); } catch(e){ return null; } })();
    if (saved && typeof saved.left === 'number' && typeof saved.top === 'number'){
      requestAnimationFrame(()=>{
        const maxL = window.innerWidth - player.offsetWidth;
        const maxT = window.innerHeight - player.offsetHeight;
        player.style.setProperty('right','auto','important');
        player.style.setProperty('bottom','auto','important');
        player.style.left = clamp(saved.left, 0, maxL) + 'px';
        player.style.top = clamp(saved.top, 0, maxT) + 'px';
      });
    }
    loadTrack(0, false);
    setVolFill(70);
    applyMinimized();
    setTimeout(()=>{ player.classList.add('visible'); }, 800);
  }

  if (document.readyState !== 'loading') init();
  else document.addEventListener('DOMContentLoaded', init);
})();
