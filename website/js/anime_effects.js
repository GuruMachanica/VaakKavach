/**
 * VaakKavach - Anime.js Dynamic Animations & Micro-interactions
 */
class VaakAnimeEffects {
  static initStaggerEntrance() {
    if (typeof anime === 'undefined') return;

    anime({
      targets: '.hero-copy > *',
      translateY: [24, 0],
      opacity: [0, 1],
      delay: anime.stagger(90, { start: 100 }),
      easing: 'easeOutExpo',
      duration: 800
    });

    anime({
      targets: '.feature-card, .trilogy-card',
      translateY: [20, 0],
      opacity: [0, 1],
      delay: anime.stagger(100, { start: 300 }),
      easing: 'easeOutQuad',
      duration: 600
    });
  }

  static animateCounter(elemId, targetVal, duration = 1200) {
    if (typeof anime === 'undefined') return;
    const elem = document.getElementById(elemId);
    if (!elem) return;

    const obj = { val: 0 };
    anime({
      targets: obj,
      val: targetVal,
      round: 1,
      easing: 'easeOutExpo',
      duration: duration,
      update: () => {
        elem.textContent = obj.val;
      }
    });
  }

  static triggerThreatGlitch(targetSelector) {
    if (typeof anime === 'undefined') return;
    anime({
      targets: targetSelector,
      translateX: [
        { value: -4, duration: 40 },
        { value: 4, duration: 40 },
        { value: -2, duration: 40 },
        { value: 0, duration: 40 }
      ],
      easing: 'easeInOutQuad'
    });
  }

  static pulseGlow(targetSelector, isThreat) {
    if (typeof anime === 'undefined') return;
    const shadowColor = isThreat ? 'rgba(239, 68, 68, 0.4)' : 'rgba(16, 185, 129, 0.3)';
    anime({
      targets: targetSelector,
      boxShadow: [
        `0 0 10px ${shadowColor}`,
        `0 0 30px ${shadowColor}`,
        `0 0 10px ${shadowColor}`
      ],
      duration: 1000,
      easing: 'easeInOutSine'
    });
  }
}

window.VaakAnimeEffects = VaakAnimeEffects;
