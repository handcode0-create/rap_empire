// Extrait les SVG inline des planches v21 vers assets/svg/ (un fichier par élément, nom explicite).
// Usage : node tool/extract_svg21.js [travail]   (sans argument : tous les travaux ; sinon celui dont le nom correspond)
// Chaque travail : planche source, expression qui sélectionne les SVG, fonction de nommage. Les SVG sont recopiés tels quels
// (xmlns ajouté, aria-hidden retiré) : on n'invente aucune image.
'use strict';
const fs = require('fs');
const path = require('path');

const root = path.resolve(__dirname, '..');
const boards = path.join(root, 'docs', 'design-ref', 'v21');
const outDir = path.join(root, 'assets', 'svg');
fs.mkdirSync(outDir, { recursive: true });

function allSvgs(html) {
  const res = [];
  const re = /<svg\b[\s\S]*?<\/svg>/g;
  let m;
  while ((m = re.exec(html))) res.push(m[0]);
  return res;
}
function clean(svg) {
  let s = svg.replace(/\saria-hidden="true"/g, '').replace(/\sstyle="[^"]*"/, (x) => x);
  if (!/xmlns=/.test(s)) s = s.replace('<svg', '<svg xmlns="http://www.w3.org/2000/svg"');
  return s + '\n';
}

const jobs = {
  // Pochettes du catalogue : huit dégradés (cv0 à cv7), même disque
  pochettes: () => {
    const html = fs.readFileSync(path.join(boards, '21-A0-Catalogue.dc.html'), 'utf8');
    const out = [];
    for (const svg of allSvgs(html)) {
      const m = /id="cv(\d)"/.exec(svg);
      if (m) out.push([`pochette-${m[1]}.svg`, svg]);
    }
    return out;
  },
};

const only = process.argv[2];
let n = 0;
for (const [name, job] of Object.entries(jobs)) {
  if (only && !name.includes(only)) continue;
  for (const [file, svg] of job()) {
    fs.writeFileSync(path.join(outDir, file), clean(svg));
    n++;
  }
}
console.log(n, 'SVG écrits dans', outDir);
