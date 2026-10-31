// Tiny Chrome DevTools Protocol driver used to verify the web build.
// Requires a Chrome started with --remote-debugging-port=9222.
// Usage: node tools/shot.js <url> <out.png> [localStorageMode]
const fs = require('fs');

const [, , url, out, mode] = process.argv;
const PORT = process.env.CDP_PORT || '9222';

const sleep = (ms) => new Promise((r) => setTimeout(r, ms));

async function main() {
  const list = await (await fetch(`http://127.0.0.1:${PORT}/json/list`)).json();
  const page =
    list.find((t) => t.type === 'page' && t.url.includes('127.0.0.1:8080')) ||
    list.find((t) => t.type === 'page');
  if (!page) throw new Error('no page target');

  const ws = new WebSocket(page.webSocketDebuggerUrl);
  let id = 0;
  const pending = new Map();

  ws.addEventListener('message', (ev) => {
    const msg = JSON.parse(ev.data);
    if (msg.id && pending.has(msg.id)) {
      pending.get(msg.id)(msg);
      pending.delete(msg.id);
    } else if (msg.method === 'Runtime.consoleAPICalled') {
      const text = (msg.params.args || []).map((a) => a.value ?? a.description).join(' ');
      console.log('[console]', text.slice(0, 300));
    } else if (msg.method === 'Runtime.exceptionThrown') {
      console.log('[exception]', JSON.stringify(msg.params.exceptionDetails).slice(0, 400));
    } else if (msg.method === 'Log.entryAdded') {
      console.log('[log]', msg.params.entry.level, msg.params.entry.text.slice(0, 300));
    }
  });

  await new Promise((res, rej) => {
    ws.addEventListener('open', res);
    ws.addEventListener('error', rej);
  });

  const send = (method, params = {}) =>
    new Promise((resolve) => {
      const mid = ++id;
      pending.set(mid, resolve);
      ws.send(JSON.stringify({ id: mid, method, params }));
    });

  await send('Page.enable');
  await send('Runtime.enable');
  await send('Log.enable');
  await send('Emulation.setDeviceMetricsOverride', {
    width: 1280,
    height: 900,
    deviceScaleFactor: 1,
    mobile: false,
  });

  await send('Page.navigate', { url });
  await sleep(9000);

  if (mode) {
    await send('Runtime.evaluate', {
      expression: `localStorage.setItem('flutter.pramaan.preview.mode', '${mode}')`,
    });
    await send('Page.reload');
    await sleep(10000);
  }

  const info = await send('Runtime.evaluate', {
    expression:
      "JSON.stringify({title: document.title, flt: !!document.querySelector('flt-glass-pane'), canvases: document.querySelectorAll('canvas').length, bodyLen: document.body.innerHTML.length})",
    returnByValue: true,
  });
  console.log('[state]', info.result?.result?.value);

  const shot = await send('Page.captureScreenshot', { format: 'png' });
  fs.writeFileSync(out, Buffer.from(shot.result.data, 'base64'));
  console.log('saved', out);
  ws.close();
}

main().catch((e) => {
  console.error('ERR', e.message);
  process.exit(1);
});
