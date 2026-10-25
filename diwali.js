/* ==========================================================
   DIWALI 2026 — TEMPORARY FESTIVE THEME
   Diwali (Lakshmi Puja): Sunday, 8 November 2026
   Active from now until the end of 10 November 2026 (IST).
   After that it switches itself OFF automatically — nothing is
   loaded, nothing is shown (the date check below decides).

   To remove it completely later: delete diwali.js + diwali.css and
   the <script src="diwali.js"> line from the public pages.
   ========================================================== */
(function () {
  // 11 Nov 2026, 00:00 IST  ==  10 Nov 2026, 18:30 UTC
  var END = Date.UTC(2026, 10, 10, 18, 30, 0);
  if (Date.now() >= END) return;

  var doc = document, root = doc.documentElement;

  // Styles are loaded only while the theme is active
  var css = doc.createElement('link');
  css.rel = 'stylesheet';
  css.href = 'diwali.css';
  doc.head.appendChild(css);

  function start() {
    var body = doc.body;
    if (!body) return;
    root.classList.add('diwali');

    var diya = '<svg class="dw-diya" viewBox="0 0 32 30" width="28" height="26" aria-hidden="true">' +
      '<path d="M2 15c0 7.5 6 13 14 13s14-5.500 14-13z" fill="#C2410C"/>' +
      '<path d="M2 15h28c-2 2.300-6.500 3.500-14 3.500S4 17.300 2 15z" fill="#F59E0B"/>' +
      '<path class="dw-flame" d="M16 1.500c3.600 3.300 4.800 6.800 0 11.500-4.800-4.700-3.600-8.200 0-11.500z" fill="#FFD54A"/>' +
      '<path class="dw-flame" d="M16 6c1.600 1.600 2.100 3.200 0 5.300-2.100-2.100-1.600-3.700 0-5.300z" fill="#FF7A1A"/></svg>';

    var MSG = {
      en: 'Happy Diwali from Shree Sawriya Solutions',
      hi: 'श्री सावरिया सॉल्यूशंस की ओर से दीपावली की हार्दिक शुभकामनाएँ',
      pa: 'ਸ਼੍ਰੀ ਸਾਵਰੀਆ ਸੋਲਿਊਸ਼ਨਜ਼ ਵੱਲੋਂ ਦੀਵਾਲੀ ਦੀਆਂ ਲੱਖ-ਲੱਖ ਵਧਾਈਆਂ'
    };
    function lang() {
      try { var l = localStorage.getItem('preferredLang'); return MSG[l] ? l : 'en'; } catch (e) { return 'en'; }
    }

    var dismissed = false;
    try { dismissed = sessionStorage.getItem('dw_closed') === '1'; } catch (e) {}

    var strip = null;
    if (!dismissed) {
      strip = doc.createElement('div');
      strip.className = 'dw-strip';
      strip.setAttribute('role', 'note');
      strip.innerHTML = diya + '<span class="dw-msg"></span>' + diya +
        '<button type="button" class="dw-x" aria-label="Close">&times;</button>' +
        '<i class="dw-lights"></i><i class="dw-lights b"></i>';
      body.insertBefore(strip, body.firstChild);

      var msg = strip.querySelector('.dw-msg');
      var fit = function () {
        root.style.setProperty('--dw-h', strip.offsetHeight + 'px');
      };
      var paint = function () { msg.textContent = MSG[lang()]; fit(); };
      paint();
      window.addEventListener('resize', fit);
      if (doc.fonts && doc.fonts.ready) doc.fonts.ready.then(fit);
      // language buttons on the page change the greeting too
      doc.addEventListener('click', function (e) {
        if (e.target.closest && e.target.closest('.lang-btn,.lb')) setTimeout(paint, 80);
      });
      strip.querySelector('.dw-x').addEventListener('click', function () {
        try { sessionStorage.setItem('dw_closed', '1'); } catch (e) {}
        strip.remove();
        root.style.setProperty('--dw-h', '0px');
      });
    }

    // floating golden sparkles (decoration only, sits behind the page content)
    var fx = doc.createElement('div');
    fx.className = 'dw-fx';
    fx.setAttribute('aria-hidden', 'true');
    var n = window.innerWidth < 700 ? 12 : 22, html = '';
    for (var i = 0; i < n; i++) {
      var s = 3 + Math.random() * 6;
      html += '<i style="left:' + (Math.random() * 100).toFixed(1) + '%;width:' + s.toFixed(1) + 'px;height:' + s.toFixed(1) +
        'px;--sx:' + ((Math.random() * 60 - 30) | 0) + 'px;animation-duration:' + (11 + Math.random() * 14).toFixed(1) +
        's;animation-delay:-' + (Math.random() * 25).toFixed(1) + 's"></i>';
    }
    fx.innerHTML = html;
    body.appendChild(fx);
  }

  if (doc.body) start();
  else doc.addEventListener('DOMContentLoaded', start);
})();
