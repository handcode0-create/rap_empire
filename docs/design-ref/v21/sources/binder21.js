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
    var ERR = { campagne: 'Cette campagne est déjà en cours', confirm: 'Confirme l\'achat (15 000 cauris ou plus)', indispo: 'Tenue indisponible : une illustration manque', pasachete: 'Achète d\'abord cette tenue', mature: 'Contenu mature désactivé : active-le dans le Profil (16+)', prison: 'Impossible en prison : écris, fais du sport ou termine la journée', garde: 'En garde à vue : paie la caution ou accepte la détention', affaire: 'Une affaire est en cours : attends le procès', proces: 'Le procès n\'a pas encore eu lieu', pistes: 'Nombre de titres incorrect pour ce projet', cash: 'Cash insuffisant', energie: 'Énergie insuffisante : termine la journée', tard: 'Plus assez d\'heures aujourd\'hui : termine la journée', rang: 'Rang de carrière insuffisant', rep: 'Réputation insuffisante', deja: 'Déjà fait', encours: 'Un titre est déjà en cours', pasdetexte: 'Écris d\'abord le texte', pasenregistre: 'Enregistre d\'abord le titre', pasdetitre: 'Aucun titre concerné', maxfeat: 'Deux featurings au maximum', rival: 'Indisponible : rivalité en cours', pop: 'Popularité insuffisante', clipapres: 'Trop tard : un clip se prépare avant la sortie', pasprepare: 'Prépare d\'abord le clip', avantsortie: 'Le clip ne peut sortir qu\'après le titre', pasproduit: 'Tourne d\'abord le clip', charisme: 'Charisme insuffisant', fans: 'Pas assez de fans', single: 'Sors d\'abord un single', romjour: 'Deux actions romantiques par jour : reviens demain', exclusif: 'Tu es en couple : relation exclusive', ex: 'Relation terminée récemment', pasdeconcert: 'Fais d\'abord un concert ou un open mic', seuil: 'Relation encore trop faible', condmariage: 'Conditions du mariage non réunies', mariage: 'Réservé aux couples mariés', pasdecouple: 'Aucune relation officielle', age: 'Pas encore de cet âge', nom: 'Nom de scène invalide', delai: 'Trop tôt : cette date n\'est pas encore disponible', audience: 'Audience insuffisante à Port-Ambre et Sélène', rien: 'Aucun événement en attente', inconnu: 'Action impossible' };
    function get(o, p) { return p.split('.').reduce(function (a, k) { return a == null ? a : a[k]; }, o); }
    function render() {
      var SS = S || snap(); var v = RE.view(SS), i, els;
      els = document.querySelectorAll('[data-b]'); for (i = 0; i < els.length; i++) { var k = els[i].getAttribute('data-b'); if (v[k] !== undefined) els[i].textContent = v[k]; }
      els = document.querySelectorAll('[data-w]'); for (i = 0; i < els.length; i++) { var w = v[els[i].getAttribute('data-w')]; if (w !== undefined) els[i].style.width = w + '%'; }
      els = document.querySelectorAll('[data-src]'); for (i = 0; i < els.length; i++) { var sp = v[els[i].getAttribute('data-src')]; if (sp && els[i].getAttribute('src') !== sp) { els[i].removeAttribute('data-broken'); els[i].setAttribute('src', sp); } }
      els = document.querySelectorAll('[data-if]'); for (i = 0; i < els.length; i++) { var r = els[i].getAttribute('data-if'), neg = r.charAt(0) === '!'; var val = !!v[neg ? r.slice(1) : r]; if (neg) val = !val; if (val) els[i].removeAttribute('hidden'); else els[i].setAttribute('hidden', ''); }
      els = document.querySelectorAll('img[data-broken]'); for (i = 0; i < els.length; i++) fbShow(els[i], true);
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
    /* image de personnage manquante : pas d'image cassée, l'avatar de secours prend la place */
    function fbShow(img, on) { var box = img.closest('[data-fbbox]'); if (!box) return; var f = box.querySelector('.fbx'); img.hidden = on; if (f) { if (on) f.removeAttribute('hidden'); else f.setAttribute('hidden', ''); } }
    document.addEventListener('error', function (e) { var t = e.target; if (t && t.tagName === 'IMG' && t.hasAttribute('data-src')) { t.setAttribute('data-broken', '1'); fbShow(t, true); } }, true);
    document.addEventListener('load', function (e) { var t = e.target; if (t && t.tagName === 'IMG' && t.hasAttribute('data-src')) { t.removeAttribute('data-broken'); var box = t.closest('[data-fbbox]'); if (box && box.getAttribute('data-fbif') && !RE.view(S || snap())[box.getAttribute('data-fbif')]) return; fbShow(t, false); } }, true);
    document.addEventListener('input', function (e) { var t = e.target && e.target.closest ? e.target.closest('[data-model]') : null; if (!t) return; run(t.getAttribute('data-model') + '=' + t.value); }, true);
    document.addEventListener('click', function (e) {
      var t = e.target && e.target.closest ? e.target.closest('[data-act],[data-sel]') : null; if (!t) return;
      var spec = t.getAttribute('data-act') || t.getAttribute('data-sel'), sel = !t.getAttribute('data-act');
      var specs = spec.split(';'), ok = true;
      for (var i = 0; i < specs.length && ok; i++) ok = run(specs[i]).ok;
      if (!ok || sel) { e.preventDefault(); e.stopPropagation(); }
    }, true);
    /* mini-jeu de cabine (04.8, repris de la v20) : 3 prises, le timing fixe la voix */
    function mini() {
      var el = document.getElementById('mg'); if (!el) return;
      var cur = el.querySelector('.mg-cur'), zone = el.querySelector('.mg-zone'), btn = document.getElementById('mg-rec'), msg = document.getElementById('mg-msg'), nxt = document.getElementById('mg-next');
      var ZC = [0.62, 0.34, 0.72], takes = [], t0 = Date.now(), done = false, p = 0;
      function zc() { return ZC[takes.length % 3]; }
      function place() { zone.style.left = (zc() * 100 - 8) + '%'; }
      place();
      function loop() { if (done) return; var t = (Date.now() - t0) / 1000 * 0.85; p = Math.abs(((t % 2) + 2) % 2 - 1); cur.style.left = (p * 100) + '%'; requestAnimationFrame(loop); }
      requestAnimationFrame(loop);
      function hit(e) {
        if (e) { e.preventDefault(); e.stopPropagation(); } if (done) return;
        var sc = Math.max(0, Math.round(100 - Math.abs(p - zc()) * 230)); takes.push(sc);
        var n = takes.length, chip = el.querySelector('.mg-t' + n); if (chip) { chip.textContent = 'Prise ' + n + ' · ' + sc; chip.classList.add('on'); }
        if (msg) msg.textContent = sc >= 70 ? 'Prise propre' : sc >= 45 ? 'Prise correcte' : 'Prise ratée, mais gardée';
        if (n >= 3) { done = true; if (!run('record:' + takes.join(',')).ok) { done = false; takes = []; for (var i = 1; i <= 3; i++) { var c2 = el.querySelector('.mg-t' + i); if (c2) { c2.textContent = 'Prise ' + i; c2.classList.remove('on'); } } return; } if (nxt) { nxt.removeAttribute('hidden'); if (msg) msg.textContent = 'Trois prises enregistrées : écoute ton mix.'; } }
        else { t0 = Date.now(); place(); }
      }
      btn.addEventListener('click', hit, true);
      btn.addEventListener('keydown', function (e) { if (e.key === ' ' || e.key === 'Enter') hit(e); }, true);
    }
    /* battle (06.3, reprise de la v20) : 3 rounds, la bonne réplique dépend de l'attaque de K-Zer */
    function seq() {
      var el = document.getElementById('sq'); if (!el) return; var N = 3, picks = [], wins = 0, nxt = document.getElementById('sq-next');
      var KZ = ['malin', 'agressif', 'cool'], meter = el.querySelector('.sq-fill'), val = el.querySelector('.sq-val'), steps = el.querySelectorAll('.sq-step'), btns = el.querySelectorAll('[data-pick]');
      for (var i = 0; i < btns.length; i++) btns[i].addEventListener('click', function (e) {
        e.preventDefault(); e.stopPropagation(); if (picks.length >= N) return; var pk = this.getAttribute('data-pick'); picks.push(pk);
        var win = pk === KZ[picks.length - 1]; if (win) wins++;
        if (meter) meter.style.width = (wins / N * 100) + '%'; if (val) val.textContent = wins + ' / ' + N;
        var line = el.querySelector('.sq-res' + picks.length); if (line) line.textContent = win ? 'Round gagné' : 'Round perdu';
        for (var j = 0; j < steps.length; j++) { if (j < picks.length) steps[j].classList.add('on'); }
        var nn = el.querySelector('.sq-n'); if (nn) nn.textContent = Math.min(N, picks.length + 1);
        if (picks.length >= N) { if (!run('battle:' + wins).ok) { picks = []; wins = 0; return; } if (nxt) nxt.removeAttribute('hidden'); }
      });
    }
    function auto() { var a = document.querySelector('[data-auto]'); if (!a) return; var p = a.getAttribute('data-auto').split('|'); setTimeout(function () { location.href = p[1] + '.dc.html'; }, +p[0]); }
    var inited = false;
    function ready() { if (!document.querySelector('.scr')) return false; render(); if (!inited) { inited = true; mini(); seq(); auto(); } return true; }
    var tries = 0, tm = setInterval(function () { tries++; ready(); if (tries > 30) clearInterval(tm); }, 100);
  } catch (err) { /* le prototype reste lisible sans script */ }
})();
