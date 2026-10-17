/* RAP EMPIRE v21 — liaison DOM de la zone de consolidation. Amélioration progressive : sans stockage ni script, chaque écran affiche les valeurs de la démo canonique. */
(function () {
  try {
    var KEY = 're21', TTL = 7 * 24 * 60 * 60 * 1000, RE = window.RE21;
    function store(op, v) {
      var r = null;
      try { r = op === 'g' ? localStorage.getItem(KEY) : (v === null ? localStorage.removeItem(KEY) : localStorage.setItem(KEY, v)); if (op === 'g' && r) return r; if (op !== 'g') return; } catch (e) {}
      try { r = op === 'g' ? sessionStorage.getItem(KEY) : (v === null ? sessionStorage.removeItem(KEY) : sessionStorage.setItem(KEY, v)); if (op === 'g' && r) return r; if (op !== 'g') return; } catch (e) {}
      try {
        if (op === 'g') { var m = (window.name || '').match(/re21=(\{.*\})$/); return m ? m[1] : null; }
        window.name = v === null ? '' : 're21=' + v;
      } catch (e) {}
      return null;
    }
    function load() { var j = store('g'); if (!j) return null; try { var s = JSON.parse(j); if (!s || !s.t || Date.now() - s.t > TTL) return null; return s; } catch (e) { return null; } }
    function save(s) { s.t = Date.now(); store('s', JSON.stringify(s)); }
    var S = load(), base = null, scr = null;
    function snap() { if (S) return S; if (!scr) scr = document.querySelector('.scr'); if (!base && scr && scr.getAttribute('data-snap')) { try { base = JSON.parse(decodeURIComponent(escape(atob(scr.getAttribute('data-snap'))))); } catch (e) {} } return base || RE.init(); }
    function toast(msg) {
      var t = document.createElement('div'); t.className = 'toast e top'; t.setAttribute('role', 'alert'); t.textContent = msg;
      var h = document.querySelector('.scr'); if (!h) return; h.appendChild(t); setTimeout(function () { if (t.parentNode) t.parentNode.removeChild(t); }, 2200);
    }
    var ERR = { cash: 'Cash insuffisant', energie: 'Énergie insuffisante : termine la journée', tard: 'Plus assez d\'heures aujourd\'hui : termine la journée', rang: 'Rang de carrière insuffisant', rep: 'Réputation insuffisante', deja: 'Déjà fait', encours: 'Un titre est déjà en cours', pasdetexte: 'Écris d\'abord le texte', pasenregistre: 'Enregistre d\'abord le titre', pasdetitre: 'Aucun titre concerné', maxfeat: 'Deux featurings au maximum', rival: 'Indisponible : rivalité en cours', pop: 'Popularité insuffisante', clipapres: 'Trop tard : un clip se prépare avant la sortie', pasprepare: 'Prépare d\'abord le clip', avantsortie: 'Le clip ne peut sortir qu\'après le titre', pasproduit: 'Tourne d\'abord le clip', charisme: 'Charisme insuffisant', fans: 'Pas assez de fans', single: 'Sors d\'abord un single', romjour: 'Deux actions romantiques par jour : reviens demain', exclusif: 'Tu es en couple : relation exclusive', ex: 'Relation terminée récemment', pasdeconcert: 'Fais d\'abord un concert ou un open mic', seuil: 'Relation encore trop faible', condmariage: 'Conditions du mariage non réunies', mariage: 'Réservé aux couples mariés', pasdecouple: 'Aucune relation officielle', age: 'Pas encore de cet âge', nom: 'Nom de scène invalide', delai: 'Trop tôt : cette date n\'est pas encore disponible', audience: 'Audience insuffisante à Port-Ambre et Sélène', rien: 'Aucun événement en attente', inconnu: 'Action impossible' };
    function get(o, p) { return p.split('.').reduce(function (a, k) { return a == null ? a : a[k]; }, o); }
    function render() {
      var SS = S || snap(); var v = RE.view(SS), i, els;
      els = document.querySelectorAll('[data-b]'); for (i = 0; i < els.length; i++) { var k = els[i].getAttribute('data-b'); if (v[k] !== undefined) els[i].textContent = v[k]; }
      els = document.querySelectorAll('[data-w]'); for (i = 0; i < els.length; i++) { var w = v[els[i].getAttribute('data-w')]; if (w !== undefined) els[i].style.width = w + '%'; }
      els = document.querySelectorAll('[data-if]'); for (i = 0; i < els.length; i++) { var r = els[i].getAttribute('data-if'), neg = r.charAt(0) === '!'; var val = !!v[neg ? r.slice(1) : r]; if (neg) val = !val; if (val) els[i].removeAttribute('hidden'); else els[i].setAttribute('hidden', ''); }
      els = document.querySelectorAll('[data-hr]'); for (i = 0; i < els.length; i++) { var p = els[i].getAttribute('data-hr').split('|'), kv = p[0].split('='); els[i].setAttribute('href', ((String(v[kv[0]]) === kv[1]) ? p[1] : p[2]) + '.dc.html'); }
      els = document.querySelectorAll('[data-path]'); for (i = 0; i < els.length; i++) { if (document.activeElement !== els[i]) { var pv = get(SS, els[i].getAttribute('data-path')); els[i].value = pv == null ? '' : pv; } }
      els = document.querySelectorAll('[data-on]'); for (i = 0; i < els.length; i++) { var q = els[i].getAttribute('data-on').split('='); if (String(get(SS, q[0])) === q[1]) els[i].classList.add('sel'); else els[i].classList.remove('sel'); }
    }
    function run(spec) {
      var c = spec.indexOf(':'), name = c < 0 ? spec : spec.slice(0, c), arg = c < 0 ? undefined : spec.slice(c + 1);
      if (name === 'reset') { S = RE.init(); save(S); render(); return { ok: true }; }
      if (arg !== undefined && arg.indexOf(',') > -1 && name !== 'setp' && name !== 'setui') arg = arg.split(','); 
      if (name === 'write' && !Array.isArray(arg)) arg = [arg];
      var cur = snap(), r;
      if (name === 'write') r = RE.act(cur, 'write', [arg[0], arg[1]]); else r = RE.act(cur, name, arg);
      if (name === 'write' && r.s) { r.s.t = Date.now(); }
      if (r.err) { toast(ERR[r.err] || 'Action impossible'); return { ok: false }; }
      S = r.s; save(S); render(); return { ok: true };
    }
    window.RE21B = { run: run, state: function () { return snap(); }, render: render, toast: toast };
    document.addEventListener('input', function (e) { var t = e.target && e.target.closest ? e.target.closest('[data-model]') : null; if (!t) return; run(t.getAttribute('data-model') + '=' + t.value); }, true);
    document.addEventListener('click', function (e) {
      var t = e.target && e.target.closest ? e.target.closest('[data-act],[data-sel]') : null; if (!t) return;
      var spec = t.getAttribute('data-act') || t.getAttribute('data-sel'), sel = !t.getAttribute('data-act');
      var specs = spec.split(';'), ok = true;
      for (var i = 0; i < specs.length && ok; i++) ok = run(specs[i]).ok;
      if (!ok || sel) { e.preventDefault(); e.stopPropagation(); }
    }, true);
    function auto() { var a = document.querySelector('[data-auto]'); if (!a) return; var p = a.getAttribute('data-auto').split('|'); setTimeout(function () { location.href = p[1] + '.dc.html'; }, +p[0]); }
    var inited = false;
    function ready() { if (!document.querySelector('.scr')) return false; render(); if (!inited) { inited = true; auto(); } return true; }
    var tries = 0, tm = setInterval(function () { tries++; ready(); if (tries > 30) clearInterval(tm); }, 100);
  } catch (err) { /* le prototype reste lisible sans script */ }
})();
