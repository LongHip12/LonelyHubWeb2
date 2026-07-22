(function(){
  function resetOpacity(){
    document.body.style.opacity = '';
    document.body.style.transition = '';
  }

  window.addEventListener('pageshow', resetOpacity);
  window.addEventListener('beforeunload', resetOpacity);

  const reveal = (entries)=>{
    entries.forEach(en=>{
      if (en.isIntersecting){
        en.target.classList.add('reveal-in');
      }
    });
  };
  if ('IntersectionObserver' in window){
    const io = new IntersectionObserver(reveal, {threshold:0.12});
    document.querySelectorAll('.glass.card, .keys-list .key-card, .step-list li').forEach(el=>{
      el.classList.add('reveal-prep');
      io.observe(el);
    });
  }
})();
