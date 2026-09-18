/**
 * VaakKavach - Pixi.js Real-time Spectrogram Waterfall
 * High-performance 2D WebGL acoustic frequency stream
 */
class VaakPixiSpectrogram {
  constructor(containerId) {
    this.container = document.getElementById(containerId);
    this.app = null;
    this.bars = [];
    this.numBars = 36;
    this.isThreat = false;
  }

  init() {
    if (!this.container || typeof PIXI === 'undefined') return;

    const width = this.container.clientWidth || 400;
    const height = this.container.clientHeight || 120;

    this.app = new PIXI.Application({
      width: width,
      height: height,
      backgroundAlpha: 0,
      antialias: true
    });

    this.container.appendChild(this.app.view);

    // Create frequency bar graphics
    const barWidth = (width / this.numBars) - 2;
    for (let i = 0; i < this.numBars; i++) {
      const g = new PIXI.Graphics();
      this.app.stage.addChild(g);
      this.bars.push({ graphic: g, x: i * (barWidth + 2), width: barWidth, height: 10 });
    }

    // Grid line
    const grid = new PIXI.Graphics();
    grid.lineStyle(1, 0x334155, 0.4);
    grid.moveTo(0, height - 1);
    grid.lineTo(width, height - 1);
    this.app.stage.addChild(grid);

    this.app.ticker.add((delta) => this.render(delta));
  }

  setThreatMode(threat) {
    this.isThreat = threat;
  }

  render() {
    const time = performance.now() * 0.003;
    const height = this.app.screen.height;

    for (let i = 0; i < this.numBars; i++) {
      const item = this.bars[i];
      let barH;

      if (!this.isThreat) {
        // Organic vocal envelope
        const dist = Math.abs(i - this.numBars / 2);
        const envelope = Math.max(0.1, 1 - dist / (this.numBars / 2));
        const wave = Math.sin(time * 2 + i * 0.3) * 0.4 + 0.6;
        barH = envelope * (height - 15) * wave + Math.random() * 4;
      } else {
        // Jagged synthetic injection with high-frequency clamping
        const noise = Math.random() > 0.3 ? Math.random() * (height - 20) : 10;
        barH = (i % 4 === 0) ? height - 10 : noise;
      }

      item.graphic.clear();
      const color = this.isThreat ? (i % 2 === 0 ? 0xef4444 : 0xf87171) : (i % 2 === 0 ? 0x10b981 : 0x38bdf8);
      item.graphic.beginFill(color, 0.85);
      item.graphic.drawRoundedRect(item.x, height - barH, item.width, barH, 2);
      item.graphic.endFill();
    }
  }

  destroy() {
    if (this.app) {
      this.app.destroy(true, { children: true });
    }
  }
}

window.VaakPixiSpectrogram = VaakPixiSpectrogram;
