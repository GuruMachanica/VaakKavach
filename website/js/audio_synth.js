/**
 * VaakKavach - Web Audio API Synthetic Stream Generator
 * Simulates genuine vocal resonance vs adversarial deepfake buzz
 */
class VaakAudioSynth {
  constructor() {
    this.ctx = null;
    this.osc1 = null;
    this.osc2 = null;
    this.gain = null;
    this.isPlaying = false;
    this.mode = 'safe'; // 'safe' | 'threat'
  }

  init() {
    if (!this.ctx) {
      const AudioCtx = window.AudioContext || window.webkitAudioContext;
      this.ctx = new AudioCtx();
    }
    if (this.ctx.state === 'suspended') {
      this.ctx.resume();
    }
  }

  toggle(onStateChange) {
    if (this.isPlaying) {
      this.stop();
      if (onStateChange) onStateChange(false);
    } else {
      this.start();
      if (onStateChange) onStateChange(true);
    }
  }

  start() {
    this.init();
    this.gain = this.ctx.createGain();
    this.gain.gain.setValueAtTime(0.08, this.ctx.currentTime);
    this.gain.connect(this.ctx.destination);

    this.osc1 = this.ctx.createOscillator();
    this.osc2 = this.ctx.createOscillator();
    this.applyFrequencies();

    this.osc1.connect(this.gain);
    this.osc2.connect(this.gain);
    this.osc1.start();
    this.osc2.start();
    this.isPlaying = true;
  }

  setMode(mode) {
    this.mode = mode;
    if (this.isPlaying) this.applyFrequencies();
  }

  applyFrequencies() {
    if (!this.ctx || !this.osc1 || !this.osc2) return;
    const now = this.ctx.currentTime;
    if (this.mode === 'safe') {
      this.osc1.type = 'sine';
      this.osc1.frequency.setValueAtTime(196, now); // Natural vocal fundamental
      this.osc2.type = 'triangle';
      this.osc2.frequency.setValueAtTime(392, now); // Second harmonic
    } else {
      this.osc1.type = 'sawtooth';
      this.osc1.frequency.setValueAtTime(310, now); // Robotic vocoder carrier
      this.osc2.type = 'square';
      this.osc2.frequency.setValueAtTime(620, now); // Harsh synthetic jitter
    }
  }

  stop() {
    try {
      if (this.osc1) { this.osc1.stop(); this.osc1.disconnect(); this.osc1 = null; }
      if (this.osc2) { this.osc2.stop(); this.osc2.disconnect(); this.osc2 = null; }
    } catch (e) { /* ignore */ }
    this.isPlaying = false;
  }
}

window.VaakAudioSynth = VaakAudioSynth;
