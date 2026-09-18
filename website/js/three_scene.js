/**
 * VaakKavach - Three.js 3D Holographic Acoustic Shield
 * Renders an interactive chiseled titanium cyber-shield with particle vortex
 */
class VaakThreeScene {
  constructor(containerId) {
    this.container = document.getElementById(containerId);
    this.scene = null;
    this.camera = null;
    this.renderer = null;
    this.shieldMesh = null;
    this.particles = null;
    this.mouse = { x: 0, y: 0 };
    this.isThreatMode = false;
  }

  init() {
    if (!this.container || typeof THREE === 'undefined') return;

    const width = this.container.clientWidth || 440;
    const height = this.container.clientHeight || 340;

    this.scene = new THREE.Scene();
    this.camera = new THREE.PerspectiveCamera(45, width / height, 0.1, 1000);
    this.camera.position.z = 5;

    this.renderer = new THREE.WebGLRenderer({ alpha: true, antialias: true });
    this.renderer.setSize(width, height);
    this.renderer.setPixelRatio(Math.min(window.devicePixelRatio, 2));
    this.container.appendChild(this.renderer.domElement);

    // Build 3D Chiseled Shield
    const shieldShape = new THREE.Shape();
    shieldShape.moveTo(0, 1.6);
    shieldShape.lineTo(1.2, 1.2);
    shieldShape.lineTo(1.1, -0.2);
    shieldShape.lineTo(0, -1.6);
    shieldShape.lineTo(-1.1, -0.2);
    shieldShape.lineTo(-1.2, 1.2);
    shieldShape.closePath();

    const extrudeSettings = { depth: 0.25, bevelEnabled: true, bevelSegments: 3, steps: 1, bevelSize: 0.1, bevelThickness: 0.1 };
    const geometry = new THREE.ExtrudeGeometry(shieldShape, extrudeSettings);
    
    const material = new THREE.MeshStandardMaterial({
      color: 0x1e293b,
      metalness: 0.85,
      roughness: 0.2,
      wireframe: false
    });

    this.shieldMesh = new THREE.Mesh(geometry, material);
    this.shieldMesh.position.set(0, 0, -0.1);
    this.scene.add(this.shieldMesh);

    // Wireframe Bezel
    const wireGeo = new THREE.WireframeGeometry(geometry);
    this.wireMesh = new THREE.LineSegments(wireGeo, new THREE.LineBasicMaterial({ color: 0x10b981, transparent: true, opacity: 0.6 }));
    this.scene.add(this.wireMesh);

    // Particle Swarm
    const particleCount = 200;
    const pGeo = new THREE.BufferGeometry();
    const positions = new Float32Array(particleCount * 3);
    for (let i = 0; i < particleCount * 3; i += 3) {
      positions[i] = (Math.random() - 0.5) * 6;
      positions[i + 1] = (Math.random() - 0.5) * 6;
      positions[i + 2] = (Math.random() - 0.5) * 4;
    }
    pGeo.setAttribute('position', new THREE.BufferAttribute(positions, 3));
    this.particles = new THREE.Points(pGeo, new THREE.PointsMaterial({ color: 0x38bdf8, size: 0.04, transparent: true, opacity: 0.8 }));
    this.scene.add(this.particles);

    // Lights
    const ambient = new THREE.AmbientLight(0xffffff, 0.4);
    this.scene.add(ambient);
    this.pointLight = new THREE.PointLight(0x10b981, 2, 10);
    this.pointLight.position.set(2, 2, 4);
    this.scene.add(this.pointLight);

    // Events
    window.addEventListener('resize', () => this.onResize());
    this.container.addEventListener('mousemove', (e) => this.onMouseMove(e));

    this.animate();
  }

  setThreatMode(active) {
    this.isThreatMode = active;
    const color = active ? 0xef4444 : 0x10b981;
    if (this.wireMesh) this.wireMesh.material.color.setHex(color);
    if (this.pointLight) this.pointLight.color.setHex(color);
  }

  onMouseMove(e) {
    const rect = this.container.getBoundingClientRect();
    this.mouse.x = ((e.clientX - rect.left) / rect.width) * 2 - 1;
    this.mouse.y = -((e.clientY - rect.top) / rect.height) * 2 + 1;
  }

  onResize() {
    if (!this.container || !this.renderer) return;
    const width = this.container.clientWidth;
    const height = this.container.clientHeight;
    this.camera.aspect = width / height;
    this.camera.updateProjectionMatrix();
    this.renderer.setSize(width, height);
  }

  animate() {
    requestAnimationFrame(() => this.animate());
    const time = performance.now() * 0.001;

    if (this.shieldMesh) {
      this.shieldMesh.rotation.y = Math.sin(time * 0.8) * 0.15 + (this.mouse.x * 0.3);
      this.shieldMesh.rotation.x = Math.cos(time * 0.8) * 0.1 + (-this.mouse.y * 0.3);
      this.wireMesh.rotation.copy(this.shieldMesh.rotation);
    }
    if (this.particles) {
      this.particles.rotation.y = time * 0.05;
    }
    this.renderer.render(this.scene, this.camera);
  }
}

window.VaakThreeScene = VaakThreeScene;
