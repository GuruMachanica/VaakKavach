/**
 * VaakKavach - Orchestrator Main Entrypoint
 * Coordinates Three.js, Pixi.js, Phaser.js, Anime.js, and React.js
 */
document.addEventListener('DOMContentLoaded', () => {
  // 1. Web Audio Synth
  window.synth = new window.VaakAudioSynth();

  // 2. Three.js 3D Holographic Shield
  try {
    window.threeScene = new window.VaakThreeScene('threejs-shield-container');
    window.threeScene.init();
  } catch (err) {
    console.warn('Three.js initialization notice:', err);
  }

  // 3. Pixi.js Spectrogram Waterfall
  try {
    window.pixiSpectrogram = new window.VaakPixiSpectrogram('pixi-canvas-container');
    window.pixiSpectrogram.init();
  } catch (err) {
    console.warn('Pixi.js initialization notice:', err);
  }

  // 4. Anime.js Entrance & Micro-interactions
  try {
    if (window.VaakAnimeEffects) {
      window.VaakAnimeEffects.initStaggerEntrance();
    }
  } catch (err) {
    console.warn('Anime.js initialization notice:', err);
  }

  // 6. React 18 Dynamic Threat Lab UI
  try {
    if (window.initReactThreatLab) {
      window.initReactThreatLab('react-threat-lab-root');
    }
  } catch (err) {
    console.warn('React Threat Lab initialization notice:', err);
  }
});
