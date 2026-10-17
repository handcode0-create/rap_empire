// Place chaque capture Flutter à côté de sa planche : planche (Edge headless) à gauche, écran Flutter à droite.
// Usage : node tool/compare21.js [dossier des captures] [préfixe]   (par défaut ../captures-v21/flutter)
'use strict';
const fs = require('fs');
const path = require('path');
const { execFileSync } = require('child_process');

const root = path.resolve(__dirname, '..');
const out = process.argv[2] ? path.resolve(process.argv[2]) : path.resolve(root, '..', 'captures-v21');
const flutterDir = path.join(out, 'flutter');
const boardsDir = path.join(out, 'planches');
const cmpDir = path.join(out, 'comparaison');
const only = process.argv[3] || '';
const edge = ['C:/Program Files (x86)/Microsoft/Edge/Application/msedge.exe', 'C:/Program Files/Google/Chrome/Application/chrome.exe'].find(fs.existsSync);
if (!edge) throw new Error('ni Edge ni Chrome');
[boardsDir, cmpDir].forEach((d) => fs.mkdirSync(d, { recursive: true }));

function shot(url, file, w, h) {
  try {
    execFileSync(edge, ['--headless', '--disable-gpu', '--hide-scrollbars', `--screenshot=${file}`, `--window-size=${w},${h}`, '--virtual-time-budget=4000', url], { stdio: 'ignore', timeout: 60000 });
  } catch (e) { /* Edge écrit parfois un code non nul malgré la capture */ }
  if (!fs.existsSync(file)) throw new Error('capture manquante : ' + file);
}
const url = (p) => 'file:///' + p.replace(/\\/g, '/');

for (const f of fs.readdirSync(flutterDir).filter((x) => x.endsWith('.png') && x.startsWith(only))) {
  const board = f.replace(/\.png$/, '');
  const html = path.join(root, 'docs', 'design-ref', 'v21', board + '.dc.html');
  if (!fs.existsSync(html)) { console.log('planche absente pour', board); continue; }
  const bpng = path.join(boardsDir, board + '.png');
  shot(url(html), bpng, 390, 844);
  const page = path.join(cmpDir, board + '.html');
  fs.writeFileSync(page, `<!doctype html><meta charset="utf-8"><body style="margin:0;background:#0C0820;color:#B6B0DD;font:12px Poppins,sans-serif">
<div style="display:flex;gap:16px;padding:12px;width:820px"><div><div style="margin-bottom:6px">PLANCHE · ${board}</div><img src="${url(bpng)}" width="390" height="844"></div>
<div><div style="margin-bottom:6px">FLUTTER · 390 × 844</div><img src="${url(path.join(flutterDir, f))}" width="390" height="844"></div></div>`);
  shot(url(page), path.join(cmpDir, board + '.png'), 836, 912);
  console.log('ok', board);
}
