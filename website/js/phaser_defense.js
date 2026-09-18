/**
 * VaakKavach - Phaser.js Autonomous Acoustic Interceptor
 * Interactive mini-sandbox demonstrating packet isolation and threat neutralization
 */
class VaakPhaserDefense {
  constructor(containerId) {
    this.containerId = containerId;
    this.game = null;
    this.interceptCount = 0;
  }

  init() {
    const container = document.getElementById(this.containerId);
    if (!container || typeof Phaser === 'undefined') return;

    const width = container.clientWidth || 600;
    const height = 180;
    const self = this;

    const config = {
      type: Phaser.AUTO,
      parent: this.containerId,
      width: width,
      height: height,
      transparent: true,
      physics: { default: 'arcade', arcade: { gravity: { y: 0 } } },
      scene: {
        preload: function () {},
        create: function () {
          self.scene = this;
          self.createScene(this, width, height);
        },
        update: function () {
          self.updateScene();
        }
      }
    };

    this.game = new Phaser.Game(config);
  }

  createScene(scene, width, height) {
    // Defense Shield Center Node
    this.shield = scene.add.circle(width / 2, height / 2, 28, 0x0f172a);
    this.shield.setStrokeStyle(2, 0x10b981);

    // Rotating Radar Line
    this.radarLine = scene.add.line(0, 0, width / 2, height / 2, width / 2 + 50, height / 2, 0x38bdf8);
    this.radarAngle = 0;

    // Packet Groups
    this.threatPackets = [];
    this.lastSpawn = 0;

    // Text Label
    this.label = scene.add.text(12, 10, 'PHASER DEFENSE KERNEL: LIVE', {
      font: '10px JetBrains Mono',
      fill: '#10b981'
    });

    this.counterText = scene.add.text(width - 160, 10, 'NEUTRALIZED: 0', {
      font: '10px JetBrains Mono',
      fill: '#94a3b8'
    });
  }

  updateScene() {
    if (!this.scene) return;
    const now = performance.now();
    const width = this.scene.scale.width;
    const height = this.scene.scale.height;

    // Rotate Radar
    this.radarAngle += 0.04;
    const rx = width / 2 + Math.cos(this.radarAngle) * 55;
    const ry = height / 2 + Math.sin(this.radarAngle) * 55;
    this.radarLine.setTo(width / 2, height / 2, rx, ry);

    // Spawn audio packet
    if (now - this.lastSpawn > 1200) {
      this.lastSpawn = now;
      const isThreat = Math.random() > 0.4;
      const startX = Math.random() > 0.5 ? 0 : width;
      const startY = 30 + Math.random() * (height - 60);

      const packet = this.scene.add.circle(startX, startY, 7, isThreat ? 0xef4444 : 0x10b981);
      packet.isThreat = isThreat;
      packet.vx = (width / 2 - startX) * 0.015;
      packet.vy = (height / 2 - startY) * 0.015;
      this.threatPackets.push(packet);
    }

    // Move and collide packets
    for (let i = this.threatPackets.length - 1; i >= 0; i--) {
      const p = this.threatPackets[i];
      p.x += p.vx;
      p.y += p.vy;

      const dist = Phaser.Math.Distance.Between(p.x, p.y, width / 2, height / 2);
      if (dist < 32) {
        if (p.isThreat) {
          this.interceptCount++;
          this.counterText.setText(`NEUTRALIZED: ${this.interceptCount}`);
          this.scene.cameras.main.flash(80, 239, 68, 68, 0.1);
        }
        p.destroy();
        this.threatPackets.splice(i, 1);
      }
    }
  }

  destroy() {
    if (this.game) this.game.destroy(true);
  }
}

window.VaakPhaserDefense = VaakPhaserDefense;
