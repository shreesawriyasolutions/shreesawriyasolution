// Shop App service worker. Scope sirf /app* hai, isliye baaki website pages par koi asar nahi.
// Supabase ka data kabhi cache nahi hota; sirf app ka page aur icons offline ke liye rakhe jaate hain.
const CACHE = 'sss-shop-app-v1';
const SHELL = ['/app.html', '/logo.png', '/icons/app-192.png', '/icons/app-512.png'];

self.addEventListener('install', (e) => {
  e.waitUntil(caches.open(CACHE).then((c) => c.addAll(SHELL)).then(() => self.skipWaiting()));
});

self.addEventListener('activate', (e) => {
  e.waitUntil(
    caches.keys()
      .then((keys) => Promise.all(keys.filter((k) => k.startsWith('sss-shop-app-') && k !== CACHE).map((k) => caches.delete(k))))
      .then(() => self.clients.claim())
  );
});

self.addEventListener('fetch', (e) => {
  const req = e.request;
  if (req.method !== 'GET') return;
  const url = new URL(req.url);
  if (url.origin !== self.location.origin) return; // Supabase, fonts, CDN: seedha network

  // App page: pehle network (taaki naya version mile), net na ho to cache
  if (req.mode === 'navigate' || url.pathname === '/app.html') {
    e.respondWith(
      fetch(req)
        .then((res) => {
          if (res.ok) { const copy = res.clone(); caches.open(CACHE).then((c) => c.put('/app.html', copy)); }
          return res;
        })
        .catch(() => caches.match('/app.html'))
    );
    return;
  }

  // Logo aur icons: cache se, warna network
  if (SHELL.includes(url.pathname)) {
    e.respondWith(caches.match(url.pathname).then((hit) => hit || fetch(req)));
  }
});
