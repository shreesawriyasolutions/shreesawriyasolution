/* Shree Sawriya Solutions — scroll reveal, slide sync and hero parallax (no libraries). */
(function () {
  window.SSMotion = true;
  var root = document.documentElement;
  if (!root.classList.contains('mo')) return;

  var SEL = [
    'section h1', 'section h2', 'section .lede', 'section .section-sub', 'section .section-title',
    'section .glass', 'section .card', 'section .course-card', 'section .level-card', 'section .acc-item',
    'section figure', 'section .cta', 'section .hero-buttons', 'section .trainer-box', '.svc > a'
  ].join(',');

  function targets(scope) {
    return Array.prototype.filter.call((scope || document).querySelectorAll(SEL), function (el) {
      return !el.closest('.slide') && !el.classList.contains('in') && !el.__mo;
    });
  }

  function show(el, delay) {
    el.style.setProperty('--d', delay + 's');
    el.classList.add('in');
    el.addEventListener('animationend', function done() {
      el.style.removeProperty('--d');
      el.removeEventListener('animationend', done);
    });
  }

  if (!('IntersectionObserver' in window)) { root.classList.remove('mo'); return; }

  var io = new IntersectionObserver(function (entries) {
    var k = 0;
    entries.forEach(function (e) {
      if (!e.isIntersecting) return;
      io.unobserve(e.target);
      show(e.target, Math.min(k * 0.09, 0.6));
      k++;
    });
  }, { rootMargin: '0px 0px -8% 0px', threshold: 0.12 });

  function watch(scope) { targets(scope).forEach(function (el) { el.__mo = 1; io.observe(el); }); }
  watch();

  // content that arrives later (reviews from JSON, etc.)
  new MutationObserver(function (list) {
    list.forEach(function (m) {
      m.addedNodes.forEach(function (n) { if (n.nodeType === 1) watch(n.parentNode || n); });
    });
  }).observe(document.body, { childList: true, subtree: true });

  // carousels: mark the slide that is currently in view as "on"
  function syncSlides(car) {
    var track = car.querySelector('.slides');
    if (!track) return;
    function update() {
      var m = /translateX\(-?([\d.]+)%\)/.exec(track.style.transform || '');
      var i = m ? Math.round(parseFloat(m[1]) / 100) : 0;
      Array.prototype.forEach.call(track.children, function (s, j) { s.classList.toggle('on', j === i); });
    }
    new MutationObserver(update).observe(track, { attributes: true, attributeFilter: ['style'], childList: true });
    update();
  }
  Array.prototype.forEach.call(document.querySelectorAll('.carousel'), syncSlides);

  // gentle parallax on the hero background lines
  var cracks = document.querySelector('.hero .cracks');
  if (cracks) {
    var ticking = false;
    window.addEventListener('scroll', function () {
      if (ticking) return; ticking = true;
      requestAnimationFrame(function () {
        var y = Math.min(window.scrollY, 900);
        cracks.style.transform = 'translate3d(0,' + (y * 0.28) + 'px,0) rotate(' + (y * 0.01) + 'deg)';
        ticking = false;
      });
    }, { passive: true });
  }
})();
