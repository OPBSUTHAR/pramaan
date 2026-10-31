// Self-terminating service worker.
//
// Why: the older (Vercel-provisioned) flutter_service_worker.js cached
// main.dart.js against an asset manifest whose hashes no longer existed,
// which showed up as a blank white canvas for ~1s after reload. Every new
// deploy therefore ships a tiny worker that, on first load, evicts every
// cache Vercel/Flutter ever wrote and unregisters itself. The result is
// that all subsequent loads are genuinely fresh (no offline cube, but
// no stale-asset blank screen either).
self.addEventListener('install', function () {
  self.skipWaiting();
});
self.addEventListener('activate', function (event) {
  event.waitUntil(
    (async function () {
      var keys = [];
      try { keys = await caches.keys(); } catch (e) {}
      await Promise.all(keys.map(function (k) { return caches.delete(k).catch(function () {}); }));
      try { await self.registration.unregister(); } catch (e) {}
      var clients = [];
      try { clients = await self.clients.matchAll({ includeUncontrolled: true }); } catch (e) {}
      clients.forEach(function (client) { client.postMessage('pw-cleaned'); });
    })()
  );
});
self.addEventListener('message', function (event) {
  // Allow the host page to ask for cleanup on demand.
  if (event && event.data === 'purge') {
    caches.keys().then(function (keys) {
      return Promise.all(keys.map(function (k) { return caches.delete(k); }));
    }).then(function () {
      self.registration.unregister().finally(function () {
        event.source && event.source.postMessage('pw-purged');
      });
    });
  }
});
