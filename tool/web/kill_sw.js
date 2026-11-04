// Remplace le service worker de Flutter : il gardait d'anciennes versions du jeu (code et images) sur les téléphones,
// y compris l'application ajoutée à l'écran d'accueil. Ce fichier vide les caches, se désinscrit et recharge la page.
self.addEventListener('install', function () { self.skipWaiting(); });
self.addEventListener('activate', function (event) {
  event.waitUntil((async function () {
    var keys = await caches.keys();
    await Promise.all(keys.map(function (k) { return caches.delete(k); }));
    await self.registration.unregister();
    var clients = await self.clients.matchAll({ type: 'window' });
    clients.forEach(function (c) { try { c.navigate(c.url); } catch (e) {} });
  })());
});
self.addEventListener('fetch', function () { /* aucune mise en cache : le réseau répond */ });
