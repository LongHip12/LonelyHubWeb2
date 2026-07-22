function nav(id) {
  const el = document.querySelector(id);
  if (el) el.scrollIntoView({ behavior: 'smooth' });
}

window.addEventListener('scroll', () => {
  document.getElementById('site-header')
    .classList.toggle('scrolled', window.scrollY > 20);
});

function openMenu() {
  document.getElementById('menu-backdrop').classList.add('open');
  document.getElementById('side-menu').classList.add('open');
  document.body.style.overflow = 'hidden';
}
function closeMenu() {
  document.getElementById('menu-backdrop').classList.remove('open');
  document.getElementById('side-menu').classList.remove('open');
  document.body.style.overflow = '';
}

const FAQS = [
  { q: 'Is Lonely Hub safe to use?', a: 'Yes! We use advanced bypass techniques updated within hours of any anti-cheat patch. Our team monitors detection methods 24/7 to keep your account safe.' },
  { q: 'How do I get the script?', a: 'Go to the Scripts section, click Copy on your desired script, then paste it into your Roblox executor (DeltaX,ArceusX,CodeX, etc.) and execute.' },
  { q: 'What executors are supported?', a: 'Compatible with DeltaX,ArceusX,CodeX,PunkX, and many more. We test every major executor before each release.' },
  { q: 'How often are scripts updated?', a: 'Within 24–48 hours of any major game update. Join our Discord for instant patch notifications.' },
  { q: 'Is there a free version?', a: 'Yes! Free scripts are available for several popular games. Premium members unlock 100+ scripts, exclusive features, and priority support.' },
];

const REVIEWS = [
  { name: 'NightFury_X',   seed: 'NightFury',   bg: 'b6e3f4', stars: 5, text: 'Absolutely insane hub! Scripts work flawlessly every update. Been using it 6 months and never got banned. 10/10!', game: 'Auto Chest Blox Fruits' },
  { name: 'StarKiller99',  seed: 'StarKiller',  bg: 'ffdfbf', stars: 5, text: 'Best hub I\'ve ever used. Clean UI, smooth scripts, super fast updates. Lonely Hub is on another level.', game: 'Main Silent Assasins' },
  { name: 'ShadowReaper',  seed: 'ShadowReaper',bg: 'd1d4f9', stars: 5, text: 'Tried every hub out there — nothing comes close. Bypass is unreal. No crashes, no lag, just pure power.', game: 'Blox Fruits PVP' },
  { name: 'VoidWalker_Z',  seed: 'VoidWalker', bg: 'c0aede', stars: 5, text: 'Lonely Hub changed how I play Roblox. Scripts run perfectly and support is always ready. Love it!', game: 'Auto Chest Blox Fruit' },
  { name: 'CryptoHunter',  seed: 'CryptoHunter',bg: 'ffd5dc', stars: 5, text: 'The auto-farm scripts are chef\'s kiss. Went from nothing to max in hours. Undetectable and fast.', game: '99 Night In the Forest' },
  { name: 'PhantomBlade7', seed: 'PhantomBlade',bg: 'b6e3f4', stars: 5, text: 'Premium is 100% worth it. So many exclusive scripts, all working perfectly. Auto aimbot is insane.', game: 'Blox Fruits PVP' },
  { name: 'NeonGhost_R',   seed: 'NeonGhost',  bg: 'ffdfbf', stars: 5, text: 'Fast updates, great Discord community, scripts always working. This is the #1 hub for a reason!', game: 'Main Silent Assasins' },
  { name: 'IronClad_V',    seed: 'IronClad',   bg: 'd1d4f9', stars: 5, text: 'Game changer. ESP and wallhack work perfectly. No false detections ever. Keep up the amazing work!', game: 'Blox Fruits PVP' },
];

const VIDEOS = [
  { title: 'Blox Fruits Farm Chest',    desc: 'Auto farm chest with bypass tp no reset beli', videoId: 'aQgVGBt6I9Y', url: 'https://youtube.com' },
  { title: 'Main Silent Assasins',           desc: 'ESP,Speed Hack,Insane kill all player without click',            videoId: 'NosCYiD3tJM', url: 'https://youtube.com' },
  { title: 'Kaitun 99 Night',  desc: 'GodMode,Auto day 100 and diamond farm',       videoId: 'uUjZV2bHLxM', url: 'https://youtube.com' },
  { title: 'Kaitun Blox Fruits 1-1500',   desc: 'Auto farm levels,auto farm money,auto get items',           videoId: 'r6N6FlCXmAw', url: 'https://youtube.com' },
  { title: 'Kaitun Blox Fruits',         desc: 'Auto farm,get items a-z with one click',             videoId: 'stU8S87bjsk', url: 'https://youtube.com' },
]
const FEAT_ICONS = {
  shield: `<svg width="22" height="22" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"><path d="M12 22s8-4 8-10V5l-8-3-8 3v7c0 6 8 10 8 10z"/><polyline points="9 12 11 14 15 10"/></svg>`,
  bolt: `<svg width="22" height="22" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"><polygon points="13 2 3 14 12 14 11 22 21 10 12 10 13 2"/></svg>`,
  refresh: `<svg width="22" height="22" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"><polyline points="23 4 23 10 17 10"/><path d="M20.49 15a9 9 0 1 1-2.12-9.36L23 10"/></svg>`,
  eye: `<svg width="22" height="22" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"><path d="M1 12s4-8 11-8 11 8 11 8-4 8-11 8-11-8-11-8z"/><circle cx="12" cy="12" r="3"/></svg>`,
  crosshair: `<svg width="22" height="22" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"><circle cx="12" cy="12" r="10"/><line x1="22" y1="12" x2="18" y2="12"/><line x1="6" y1="12" x2="2" y2="12"/><line x1="12" y1="6" x2="12" y2="2"/><line x1="12" y1="22" x2="12" y2="18"/><circle cx="12" cy="12" r="3"/></svg>`,
  bot: `<svg width="22" height="22" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"><rect x="3" y="11" width="18" height="10" rx="2"/><path d="M12 11V5"/><circle cx="12" cy="4" r="1.5"/><line x1="8" y1="15" x2="8" y2="15" stroke-width="2.5"/><line x1="12" y1="15" x2="12" y2="15" stroke-width="2.5"/><line x1="16" y1="15" x2="16" y2="15" stroke-width="2.5"/><rect x="7" y="13" width="2.5" height="2.5" rx="1.2"/><rect x="10.75" y="13" width="2.5" height="2.5" rx="1.2"/><rect x="14.5" y="13" width="2.5" height="2.5" rx="1.2"/></svg>`,
  plus: `<svg width="22" height="22" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round"><line x1="12" y1="5" x2="12" y2="19"/><line x1="5" y1="12" x2="19" y2="12"/><circle cx="12" cy="12" r="9"/></svg>`,
};

const FEATURES = [
  { icon: 'shield', title: 'Undetectable Bypass',     desc: 'Advanced anti-detection updated within hours of any patch. Your account stays safe.',            col: '#dc143c' },
  { icon: 'bolt',   title: 'Lightning Fast Execution', desc: 'Zero-lag runtime. Scripts load instantly with no frame drops or game lag.',                      col: '#ff8c00' },
  { icon: 'refresh',title: 'Auto-Update System',        desc: 'Scripts self-patch when a game update is detected. No manual re-injection needed.',              col: '#9b59b6' },
  { icon: 'eye',    title: 'ESP & Wallhack',            desc: 'Full ESP with player names, health, distance, and through-wall vision in custom colors.',        col: '#27ae60' },
  { icon: 'crosshair', title: 'Precision Aimbot',      desc: 'Pixel-perfect aimbot with smoothing, FOV, target priority & humanization.',                      col: '#2980b9' },
  { icon: 'bot',    title: 'Auto Farm Engine',          desc: 'Smart auto-farm with mob detection, path-finding, loot collection, AFK safety 24/7.',            col: '#e67e22' },
  { icon: 'plus',   title: 'And many more...',           desc: 'Speed hacks, infinite jump, no-clip, teleport, god mode, fly, and dozens of game-specific exploits.', col: '#ff6b6b' },
];

const GAMES = [
  { name: 'Blox Fruits', img: 'https://i.imgur.com/K0KOyPo.jpeg', col: '#8b1a00' },
  { name: 'Silent Assasins', img: 'https://i.imgur.com/VxLY6z4.jpeg', col: '#1a0060' },
  { name: 'PVP Blox Fruits', img: 'https://i.imgur.com/K0KOyPo.jpeg', col: '#006400' },
  { name: '99 Night In The Forest',img: 'https://i.imgur.com/8Tr3xap.jpeg', col: '#8b4513' },
  { name: 'Farm Fruits', img: 'https://i.imgur.com/K0KOyPo.jpeg', col: '#006080' },
  { name: 'Main 99 Night', img: 'https://i.imgur.com/8Tr3xap.jpeg', col: '#6b4400' },
];

const SCRIPTS = [
  {
    title: 'Blox Fruits PVP', game: 'Blox Fruits',
    desc: 'Auto bounty,instant kill,visual.',
    code: `loadstring(game:HttpGet("https://raw.githubusercontent.com/LongHip12/LonelyHub/refs/heads/main/LonelyHub-PVP.lua"))()`
  },
  {
    title: 'Main Silent Assasins', game: 'Silent Assasins',
    desc: 'Speed hack, ESP, Killaura, anti-ban bypass.',
    code: `loadstring(game:HttpGet("https://raw.githubusercontent.com/LongHip12/LonelyHub/refs/heads/main/LonelyHub-SilentAssassin.lua"))()`
  },
  {
    title: 'Main 99 Night', game: '99 Night In The Forest',
    desc: 'Auto Bring,Helps Child,Fly,Speed.',
    code: `loadstring(game:HttpGet("https://raw.githubusercontent.com/LongHip12/LonelyHub/refs/heads/main/LonelyHub-99NITF.lua"))()`
  },
  {
    title: 'Kaitun 99 Night', game: '99 Night In The Forest',
    desc: 'Godmode,auto diamond,99 days farm.',
    code: `loadstring(game:HttpGet("https://raw.githubusercontent.com/LongHip12/LonelyHub/refs/heads/main/LonelyHub-99NITFKaitun.lua"))()`
  },
];

function hl(code) {
  code = code
    .replace(/&/g, "&amp;")
    .replace(/</g, "&lt;")
    .replace(/>/g, "&gt;");

  code = code.replace(/(".*?"|'.*?')/g, '<span style="color:#ce9178;">$1</span>');

  code = code.replace(/\b(\d+(\.\d+)?)\b/g, '<span style="color:#b5cea8;">$1</span>');

  code = code.replace(/\b(local|function|end|if|then|else|elseif|return|for|while|do|repeat|until|break|in|and|or|not|true|false|nil)\b/g,
    '<span style="color:#569cd6;">$1</span>');

  code = code.replace(/\b(print|pairs|ipairs|require|game|workspace|loadstring|getgenv|Color3|Enum|Instance|Vector3|wait|spawn|delay|tick|time|typeof|type|getfenv|setfenv|getmetatable|setmetatable|rawget|rawset|rawequal|select|unpack|next|assert|error|tonumber|tostring|pcall|xpcall)\b/g,
    '<span style="color:#dcdcaa;">$1</span>');

  code = code.replace(/--\[\[.*?\]\]/gs, '<span style="color:#6a9955;">$&</span>');

  code = code.replace(/--.*$/gm, '<span style="color:#6a9955;">$&</span>');

  return '<pre style="margin:0;font-family:\'JetBrains Mono\',monospace;font-size:12px;line-height:1.7;color:#e0e0e0;">' + code + '</pre>';
}

function addTilt(el) {
  el.addEventListener('mousemove', e => {
    const r = el.getBoundingClientRect();
    const rx = ((e.clientY - r.top - r.height/2) / r.height) * -10;
    const ry = ((e.clientX - r.left - r.width/2) / r.width) * 10;
    el.style.transform = `perspective(600px) rotateX(${rx}deg) rotateY(${ry}deg) scale(1.03)`;
    el.style.boxShadow = '0 20px 40px rgba(180,0,0,.4)';
  });
  el.addEventListener('mouseleave', () => {
    el.style.transform = '';
    el.style.boxShadow = '';
  });
}

function buildFAQs() {
  const el = document.getElementById('faq-list');
  if (!el) return;
  el.innerHTML = FAQS.map((f, i) => `
    <div class="faq-item liquid-glass" id="faq${i}">
      <button class="faq-q" onclick="toggleFAQ(${i})">
        <span>${f.q}</span>
        <div class="faq-icon">
          <svg width="12" height="12" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5" stroke-linecap="round"><polyline points="6 9 12 15 18 9"/></svg>
        </div>
      </button>
      <div class="faq-ans"><div class="faq-ans-inner">${f.a}</div></div>
    </div>`).join('');
}
function toggleFAQ(i) {
  const item = document.getElementById('faq' + i);
  const open = item.classList.contains('open');
  document.querySelectorAll('.faq-item').forEach(x => x.classList.remove('open'));
  if (!open) item.classList.add('open');
}

function buildReviews() {
  const card = r => `
    <div class="rev-card liquid-glass tiltable">
      <div class="rev-hd">
        <img class="rev-av" src="https://api.dicebear.com/7.x/pixel-art/svg?seed=${r.seed}&backgroundColor=${r.bg}" alt="${r.name}" />
        <div><div class="rev-nm">${r.name}</div><div class="rev-gm">${r.game}</div></div>
        <div class="rev-stars">${'★'.repeat(r.stars)}</div>
      </div>
      <p class="rev-txt">${r.text}</p>
    </div>`;
  const r1 = REVIEWS.slice(0,4), r2 = REVIEWS.slice(4);
  const row1 = document.getElementById('rev-row1');
  const row2 = document.getElementById('rev-row2');
  if (row1) { row1.innerHTML = [...r1,...r1].map(card).join(''); row1.querySelectorAll('.tiltable').forEach(addTilt); }
  if (row2) { row2.innerHTML = [...r2,...r2].map(card).join(''); row2.querySelectorAll('.tiltable').forEach(addTilt); }
}

function buildShowcase() {
  const el = document.getElementById('showcase-track');
  if (!el) return;
  el.innerHTML = [...VIDEOS,...VIDEOS].map(v => `
    <a class="vid-card tiltable" href="${v.url}" target="_blank">
      <div class="vid-thumb">
        <img src="https://img.youtube.com/vi/${v.videoId}/hqdefault.jpg" alt="${v.title}"
          onerror="this.src='https://img.youtube.com/vi/${v.videoId}/mqdefault.jpg'" />
        <div class="vid-overlay"></div>
        <div class="vid-play"><div class="vid-play-icon"></div></div>
      </div>
      <div class="vid-info">
        <div class="vid-title">${v.title}</div>
        <div class="vid-desc">${v.desc}</div>
      </div>
    </a>`).join('');
  el.querySelectorAll('.tiltable').forEach(addTilt);
}

function buildFeatures() {
  const el = document.getElementById('feat-grid');
  if (!el) return;
  el.innerHTML = FEATURES.map(f => `
    <div class="feat-card liquid-glass" style="border-left:2px solid ${f.col}40">
      <div class="feat-icon" style="background:${f.col}20;border:1px solid ${f.col}40;color:${f.col}">${FEAT_ICONS[f.icon]}</div>
      <div class="feat-title">${f.title}</div>
      <div class="feat-desc">${f.desc}</div>
    </div>`).join('');
}

function buildGames() {
  const el = document.getElementById('games-track');
  if (!el) return;
  el.innerHTML = [...GAMES,...GAMES].map(g => `
    <div class="game-card tiltable" style="background:linear-gradient(135deg,${g.col}cc 0%,${g.col}44 100%)">
      <div class="game-thumb-wrap" style="background:linear-gradient(135deg,${g.col}88,#1a0000)">
        <img src="${g.img}" alt="${g.name}" onerror="this.style.display='none';this.nextElementSibling.style.display='flex'" />
        <div class="game-fallback">${g.name[0]}</div>
        <div class="game-overlay"></div>
        <div class="game-badge">● Active</div>
      </div>
      <div class="game-info">
        <div class="game-nm">${g.name}</div>
        <div class="game-av">Script available</div>
      </div>
    </div>`).join('');
  el.querySelectorAll('.tiltable').forEach(addTilt);
}

function buildScripts() {
  const el = document.getElementById('script-list');
  if (!el) return;

  el.innerHTML = SCRIPTS.map((s, i) => `
    <div class="cb">
      <div class="cb-bar">
        <div style="display:flex;align-items:center;flex:1;min-width:0;gap:0">
          <div class="cb-dots">
            <div class="cb-dot" style="background:#ff5f57"></div>
            <div class="cb-dot" style="background:#febc2e"></div>
            <div class="cb-dot" style="background:#28c840"></div>
          </div>
          <span class="cb-name">${s.title}</span>
        </div>
        <button class="cb-copy" id="cbtn${i}" onclick="copyScript(${i})">
          Copy
        </button>
      </div>

      <div class="cb-meta">
        <span class="cb-game">${s.game}</span>
        <span class="cb-desc">${s.desc}</span>
      </div>

      <div class="cb-code">
        <pre><code>${hl(s.code)}</code></pre>
      </div>
    </div>
  `).join('');
}

function copyScript(i) {
  navigator.clipboard.writeText(SCRIPTS[i].code).then(() => {
    const btn = document.getElementById('cbtn' + i);
    btn.classList.add('copied');
    btn.innerHTML = `<svg width="13" height="13" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><polyline points="20 6 9 17 4 12"/></svg> Copied!`;
    setTimeout(() => {
      btn.classList.remove('copied');
      btn.innerHTML = `<svg width="13" height="13" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><rect x="9" y="9" width="13" height="13" rx="2"/><path d="M5 15H4a2 2 0 01-2-2V4a2 2 0 012-2h9a2 2 0 012 2v1"/></svg> Copy`;
    }, 1500);
  });
}

document.addEventListener('DOMContentLoaded', () => {
  buildFAQs();
  buildReviews();
  buildShowcase();
  buildFeatures();
  buildGames();
  buildScripts();
});
