(function(){
  const snow = document.getElementById('snow');
  if (snow) {
    const ctx = snow.getContext('2d');
    let w, h, flakes;
    function resize(){
      w = snow.width = window.innerWidth;
      h = snow.height = window.innerHeight;
      flakes = Array.from({length:60},()=>({
        x:Math.random()*w,
        y:Math.random()*h,
        r:Math.random()*2.5+0.5,
        s:Math.random()*0.6+0.2,
        d:Math.random()*0.5-0.25
      }));
    }
    function draw(){
      ctx.clearRect(0,0,w,h);
      ctx.fillStyle='rgba(255,255,255,0.7)';
      flakes.forEach(f=>{
        ctx.beginPath();
        ctx.arc(f.x,f.y,f.r,0,Math.PI*2);
        ctx.fill();
        f.y += f.s;
        f.x += f.d;
        if (f.y > h){ f.y = -5; f.x = Math.random()*w; }
        if (f.x > w) f.x = 0;
        if (f.x < 0) f.x = w;
      });
      requestAnimationFrame(draw);
    }
    resize();
    draw();
    window.addEventListener('resize',resize);
  }

  let method = 'linkvertise';

  document.querySelectorAll('.method-btn').forEach(b=>{
    b.addEventListener('click',()=>{
      document.querySelectorAll('.method-btn').forEach(x=>x.classList.remove('active'));
      b.classList.add('active');
      method = b.dataset.method;
    });
  });

  const hasMethodPicker = document.querySelector('.method-btn');
  const cont = document.getElementById('continueBtn');
  if (cont && hasMethodPicker && !cont.dataset.noGlobal) {
    cont.addEventListener('click',()=>{
      cont.classList.add('btn-loading');
      window.location.href = `/verify?method=${method}`;
    });
  }

  function getHwid(){
    let h = localStorage.getItem('lonely_hwid');
    if (!h){
      h = 'hwid_' + Math.random().toString(36).slice(2,12) + Date.now().toString(36);
      localStorage.setItem('lonely_hwid', h);
    }
    return h;
  }

  window.LonelyHub = {
    getHwid,
    async start(method, duration){
      const r = await fetch('/api/v1/auth/getkey/start',{
        method:'POST',
        headers:{'Content-Type':'application/json','X-HWID':getHwid()},
        body:JSON.stringify({hwid:getHwid(),method,duration})
      });
      return r.json();
    },
    async step(sessionId, step, token, payload){
      const r = await fetch('/api/v1/auth/getkey/step',{
        method:'POST',
        headers:{'Content-Type':'application/json','X-HWID':getHwid()},
        body:JSON.stringify({sessionId,step,token,payload:payload||{}})
      });
      return r.json();
    },
    async complete(sessionId, duration){
      const r = await fetch('/api/v1/auth/getkey/complete',{
        method:'POST',
        headers:{'Content-Type':'application/json','X-HWID':getHwid()},
        body:JSON.stringify({sessionId,duration:duration||''})
      });
      return r.json();
    }
  };
})();
