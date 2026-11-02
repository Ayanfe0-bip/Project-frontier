import * as THREE from 'three';
import AssetLoader from './AssetLoader.js';

export default class Game {
  constructor(container) {
    this.container = container;
    this.clock = new THREE.Clock();

    this.scene = new THREE.Scene();
    this.scene.background = new THREE.Color(0x070b13);
    this.scene.fog = new THREE.Fog(0x070b13, 10, 28);

    this.camera = new THREE.PerspectiveCamera(52, 1, 0.1, 100);
    this.camera.position.set(0, 2.4, 8.2);

    this.renderer = new THREE.WebGLRenderer({
      antialias: true,
      powerPreference: 'high-performance',
      alpha: false,
    });
    this.renderer.setPixelRatio(Math.min(window.devicePixelRatio, 2));
    this.renderer.setClearColor(0x070b13, 1);
    this.renderer.outputColorSpace = THREE.SRGBColorSpace;
    this.renderer.shadowMap.enabled = true;
    this.renderer.shadowMap.type = THREE.PCFSoftShadowMap;

    this.container.appendChild(this.renderer.domElement);

    this.ambient = new THREE.HemisphereLight(0xcfe8ff, 0x070b13, 1.4);
    this.scene.add(this.ambient);

    this.sun = new THREE.DirectionalLight(0xe8f1ff, 1.7);
    this.sun.position.set(6, 8, 5);
    this.scene.add(this.sun);

    this.rimLight = new THREE.DirectionalLight(0x5b8cff, 0.8);
    this.rimLight.position.set(-8, 2, -6);
    this.scene.add(this.rimLight);

    this.world = new THREE.Group();
    this.scene.add(this.world);

    const floor = new THREE.Mesh(
      new THREE.CylinderGeometry(8, 9, 0.8, 32),
      new THREE.MeshStandardMaterial({ color: 0x101922, roughness: 0.9, metalness: 0.2 }),
    );
    floor.position.y = -0.45;
    floor.receiveShadow = true;
    this.world.add(floor);

    const platformGlow = new THREE.Mesh(
      new THREE.RingGeometry(2.4, 4.4, 64),
      new THREE.MeshBasicMaterial({ color: 0x93d5ff, transparent: true, opacity: 0.18, side: THREE.DoubleSide }),
    );
    platformGlow.rotation.x = -Math.PI / 2;
    platformGlow.position.y = 0.02;
    this.world.add(platformGlow);

    this.loadingScreen = document.getElementById('loading-screen');
    this.loadingBarFill = document.getElementById('loading-bar-fill');

    this.assetLoader = new AssetLoader();
    this.weaponGroup = new THREE.Group();
    this.weaponGroup.position.y = 0.25;
    this.scene.add(this.weaponGroup);

    this.resize();
    window.addEventListener('resize', () => this.resize());
  }

  updateLoadingProgress(progress) {
    const value = Math.min(1, Math.max(0, progress));
    this.loadingBarFill.style.width = `${Math.round(value * 100)}%`;
  }

  async start() {
    try {
      this.updateLoadingProgress(0.08);
      const { pistol, rifle } = await this.assetLoader.loadGameWeapons((ratio) => {
        this.updateLoadingProgress(0.18 + ratio * 0.7);
      });

      const pistolModel = pistol.scene;
      pistolModel.scale.setScalar(1.3);
      pistolModel.rotation.y = -Math.PI / 2;
      pistolModel.position.set(-1.65, 0.45, 0.3);
      pistolModel.traverse((child) => {
        if (child.isMesh) {
          child.castShadow = true;
          child.receiveShadow = true;
        }
      });
      this.weaponGroup.add(pistolModel);

      const rifleModel = rifle.scene;
      rifleModel.scale.setScalar(1.15);
      rifleModel.rotation.y = Math.PI / 2;
      rifleModel.position.set(1.7, 0.5, -0.1);
      rifleModel.traverse((child) => {
        if (child.isMesh) {
          child.castShadow = true;
          child.receiveShadow = true;
        }
      });
      this.weaponGroup.add(rifleModel);

      this.updateLoadingProgress(1);
      setTimeout(() => {
        if (this.loadingScreen) {
          this.loadingScreen.classList.add('hidden');
        }
      }, 350);
    } catch (error) {
      console.error('Failed to initialize Project Frontier foundation scene:', error);
      if (this.loadingScreen) {
        this.loadingScreen.querySelector('p').textContent = 'Asset pipeline error. Please check the weapon model files.';
      }
    }

    this.animate = this.animate.bind(this);
    this.renderer.setAnimationLoop(this.animate);
  }

  animate() {
    const elapsed = this.clock.getElapsedTime();
    this.weaponGroup.rotation.y = elapsed * 0.36;
    this.camera.position.x = Math.sin(elapsed * 0.7) * 0.85;
    this.camera.position.y = 2.5 + Math.sin(elapsed * 1.3) * 0.2;
    this.camera.lookAt(0, 0.8, 0);
    this.renderer.render(this.scene, this.camera);
  }

  resize() {
    const width = this.container.clientWidth || window.innerWidth;
    const height = this.container.clientHeight || window.innerHeight;

    this.camera.aspect = width / height;
    this.camera.updateProjectionMatrix();
    this.renderer.setSize(width, height, false);
  }
}
