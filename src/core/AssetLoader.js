import * as THREE from 'three';
import { GLTFLoader } from 'three/examples/jsm/loaders/GLTFLoader.js';

const pistolUrl = new URL('../../assets/weapons/pistol.glb', import.meta.url).href;
const rifleUrl = new URL('../../assets/weapons/rifle.glb', import.meta.url).href;

export default class AssetLoader {
  constructor() {
    this.loader = new GLTFLoader();
    this.cache = new Map();
  }

  async loadGLTF(url, onProgress = null) {
    if (this.cache.has(url)) {
      return this.cache.get(url);
    }

    const gltf = await new Promise((resolve, reject) => {
      this.loader.load(
        url,
        (loadedAsset) => {
          this.cache.set(url, loadedAsset);
          resolve(loadedAsset);
        },
        (progressEvent) => {
          if (onProgress && progressEvent.total) {
            const ratio = progressEvent.loaded / progressEvent.total;
            onProgress(ratio);
          }
        },
        (error) => {
          console.error('GLTF asset failed to load:', error);
          reject(error);
        },
      );
    });

    return gltf;
  }

  async loadGameWeapons(onProgress = null) {
    const pistolPromise = this.loadGLTF(pistolUrl, onProgress);
    const riflePromise = this.loadGLTF(rifleUrl, onProgress);

    const [pistolAsset, rifleAsset] = await Promise.all([pistolPromise, riflePromise]);

    return {
      pistol: pistolAsset,
      rifle: rifleAsset,
    };
  }
}
