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

// Portraits sans équivalent dans assets/characters : K-Zer d'Mabaya (21-B1, « aperçu provisoire »)
jobs.portraits = () => {
  const html = fs.readFileSync(path.join(boards, '21-B1-Battle.dc.html'), 'utf8');
  const svgs = allSvgs(html).filter((x) => /viewBox="20 -14 260 340"/.test(x));
  // le premier est Djo (déjà dans assets/characters), le second K-Zer
  return svgs.length >= 2 ? [['portrait-kzer.svg', svgs[1].replace(/ style="[^"]*"/, '')]] : [];
};

// Directeurs de label (21-X1) : pas de personnage dans assets/characters, un SVG inline par échange (n1, n2) et par fin de scène (dd).
jobs.directeurs = () => {
  const html = fs.readFileSync(path.join(boards, '21-X1-Dialogue.dc.html'), 'utf8');
  const who = { AUB: 'awa', NUG: 'bakary', SIC: 'liv', VAG: 'marius', BLG: 'kre', LYR: 'maze', AMG: 'benedicte', RCD: 'kofi' };
  const out = [];
  const marks = [...html.matchAll(/data-if="((?:dn|dd)_lb_([A-Z]{3})(?:_(n\d))?)"/g)];
  marks.forEach((m, i) => {
    const code = m[2];
    if (!who[code]) return;
    const chunk = html.slice(m.index, i + 1 < marks.length ? marks[i + 1].index : html.length);
    const pc = [...chunk.matchAll(/<div class="pc" style="left:236px[^"]*"[^>]*>(<svg[\s\S]*?<\/svg>)/g)][0];
    if (pc) out.push([`portrait-${who[code]}-${m[3] || 'fin'}.svg`, pc[1].replace(/ style="[^"]*"/, '')]);
  });
  return out;
};

// Labels (21-L2) : dix logos fictifs (64 x 64) et le buste de chaque directeur, dans l'ordre de la planche.
jobs.labels = () => {
  const html = fs.readFileSync(path.join(boards, '21-L2-Labels.dc.html'), 'utf8');
  const order = ['BSR', 'AMG', 'RCD', 'BLG', 'AUB', 'LYR', 'SKP', 'NUG', 'SIC', 'VAG'];
  const who = { BSR: 'orage', AMG: 'benedicte', RCD: 'kofi', BLG: 'kre', AUB: 'awa', LYR: 'maze', SKP: 'kore', NUG: 'bakary', SIC: 'liv', VAG: 'marius' };
  const out = [];
  for (const svg of allSvgs(html)) {
    const logo = /aria-label="Logo ([A-Z]{3}) \(fictif\)"/.exec(svg);
    if (logo) out.push([`logo-${logo[1]}.svg`, svg.replace(/ role="img" aria-label="[^"]*"/, '').replace(/<text[\s\S]*?<\/text>/, '')]);
  }
  const busts = allSvgs(html).filter((x) => /viewBox="40 0 220 250"/.test(x));
  busts.forEach((b, i) => out.push([`portrait-${who[order[i]]}-bust.svg`, b.replace(/ style="[^"]*"/, '')]));
  return out;
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
