// Página de videos de divulgación (apuntes/videos/): buscador, filtro por tags (deben estar todos
// los activos) y cambio de idioma ES/EN. Las tarjetas las arma Jekyll; acá sólo se muestran u ocultan.
(function () {
  var root = document.getElementById('videos');
  if (!root) return;

  var input = document.getElementById('videos-q');
  var count = document.getElementById('videos-count');
  var clear = document.getElementById('videos-clear');
  var empty = document.getElementById('videos-empty');
  var buttons = [].slice.call(root.querySelectorAll('.video-tag'));
  var lang = 'es';
  var activos = [];

  // Minúsculas y sin acentos, para que "mecanica" encuentre "mecánica".
  function norm(s) {
    return s.normalize('NFD').replace(/[̀-ͯ]/g, '').toLowerCase();
  }

  var cards = [].slice.call(root.querySelectorAll('.video-card')).map(function (el) {
    return { el: el, tags: el.getAttribute('data-tags').split('|'), text: norm(el.getAttribute('data-text')) };
  });

  function tieneTodos(c, tags) {
    return tags.every(function (t) { return c.tags.indexOf(t) >= 0; });
  }

  function update() {
    var palabras = norm(input.value).split(/\s+/).filter(Boolean);
    var porTexto = cards.filter(function (c) {
      return palabras.every(function (p) { return c.text.indexOf(p) >= 0; });
    });
    var visibles = porTexto.filter(function (c) { return tieneTodos(c, activos); });

    cards.forEach(function (c) { c.el.hidden = visibles.indexOf(c) < 0; });

    // Cada botón muestra cuántos videos quedarían si se lo agrega a los filtros actuales.
    buttons.forEach(function (b) {
      var tag = b.getAttribute('data-tag');
      var on = activos.indexOf(tag) >= 0;
      var n = on ? visibles.length : visibles.filter(function (c) { return c.tags.indexOf(tag) >= 0; }).length;
      b.querySelector('.n').textContent = n;
      b.classList.toggle('active', on);
      b.classList.toggle('zero', !on && n === 0);
      b.setAttribute('aria-pressed', on);
    });

    count.textContent = lang === 'es'
      ? visibles.length + ' de ' + cards.length + ' videos'
      : visibles.length + ' of ' + cards.length + ' videos';
    clear.hidden = !palabras.length && !activos.length;
    empty.hidden = visibles.length > 0;
  }

  buttons.forEach(function (b) {
    b.addEventListener('click', function () {
      var tag = b.getAttribute('data-tag');
      var i = activos.indexOf(tag);
      if (i >= 0) activos.splice(i, 1); else activos.push(tag);
      update();
    });
  });

  [].forEach.call(root.querySelectorAll('.video-tag-more'), function (b) {
    b.addEventListener('click', function () {
      b.parentNode.classList.remove('collapsed');
      b.hidden = true;
    });
  });

  input.addEventListener('input', update);

  clear.addEventListener('click', function () {
    input.value = '';
    activos = [];
    update();
  });

  function setLang(l) {
    lang = l;
    root.classList.toggle('lang-es', l === 'es');
    root.classList.toggle('lang-en', l === 'en');
    [].forEach.call(root.querySelectorAll('.videos-lang .btn'), function (b) {
      b.classList.toggle('active', b.getAttribute('data-lang') === l);
    });
    input.placeholder = input.getAttribute('data-ph-' + l);
    try { localStorage.setItem('videos-lang', l); } catch (e) {}
    update();
  }

  [].forEach.call(root.querySelectorAll('.videos-lang .btn'), function (b) {
    b.addEventListener('click', function () { setLang(b.getAttribute('data-lang')); });
  });

  var guardado = null;
  try { guardado = localStorage.getItem('videos-lang'); } catch (e) {}
  setLang(guardado === 'en' ? 'en' : 'es');
})();
