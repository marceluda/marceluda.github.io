// Botones "Copiar" de _includes/copy-cmd.html: copian el comando de su recuadro al portapapeles.
(function () {
  function copiar(texto) {
    if (navigator.clipboard && window.isSecureContext) return navigator.clipboard.writeText(texto);
    return new Promise(function (ok, mal) {   // navegadores viejos o http
      var ta = document.createElement('textarea');
      ta.value = texto; ta.setAttribute('readonly', ''); ta.style.position = 'fixed'; ta.style.opacity = '0';
      document.body.appendChild(ta); ta.select();
      try { document.execCommand('copy') ? ok() : mal(); } catch (e) { mal(e); }
      document.body.removeChild(ta);
    });
  }
  [].forEach.call(document.querySelectorAll('.copy-cmd'), function (box) {
    var btn = box.querySelector('.copy-cmd-btn');
    var label = btn.querySelector('span');
    var original = label.textContent;
    btn.addEventListener('click', function () {
      copiar(box.querySelector('code').textContent).then(function () {
        label.textContent = btn.getAttribute('data-copied');
        btn.classList.add('copied');
        setTimeout(function () { label.textContent = original; btn.classList.remove('copied'); }, 2000);
      }, function () {
        // Si no se pudo copiar, dejar el comando seleccionado para copiarlo a mano.
        var r = document.createRange(); r.selectNodeContents(box.querySelector('code'));
        var s = window.getSelection(); s.removeAllRanges(); s.addRange(r);
      });
    });
  });
})();
