(function() {
  let lastScrollY = window.scrollY;
  let ticking = false;
  const threshold = 50; // Mindestens so viele Pixel scrollen, um zu triggern

  window.addEventListener('scroll', () => {
    if (!ticking) {
      window.requestAnimationFrame(() => {
        const currentScrollY = window.scrollY;
        const diff = currentScrollY - lastScrollY;

        // Nur reagieren, wenn wir signifikant gescrollt haben
        if (Math.abs(diff) > 10) {
          // Logik: 
          // Nach unten scrollen (> 0) -> UI verstecken (Hide)
          // Nach oben scrollen (< 0) -> UI zeigen (Show)
          // Ganz oben (currentScrollY < threshold) -> Immer Zeigen

          let action = '';

          if (currentScrollY < threshold) {
            action = 'show_ui';
          } else if (diff > 0) {
            action = 'hide_ui';
          } else if (diff < -5) { // Etwas toleranter beim Hochscrollen
            action = 'show_ui';
          }

          if (action && window.CleanReadApp) {
            window.CleanReadApp.postMessage(JSON.stringify({
              action: 'ui_control',
              data: action
            }));
          }

          lastScrollY = currentScrollY;
        }
        ticking = false;
      });
      ticking = true;
    }
  });
})();
