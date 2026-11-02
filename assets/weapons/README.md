# Phase 7 combat asset note
# This repository does not include licensed GLB/GLTF firearm source files.
# The assets below are the verified open-license sources we would use for a production-ready weapon set.
# They should be downloaded separately into assets/weapons/ before final art pass.

## Source candidates
- Meshy Firearm Models: https://www.meshy.ai/tags/firearm
  - License: Creative Commons CC0 / royalty-free public domain, as stated by Meshy for the listed firearm models.
- Godot Asset Store — Guns Asset Pack: https://store.godotengine.org/search/?query=%23weapons
  - License: CC0 / public domain for the asset pack.
- GitHub: petroulacl/fps-asset-kit: https://github.com/petroulacl/fps-asset-kit
  - License: CC0 / public domain for referenced assets.
- Sketchfab: Antoine Patel realistic gun collection: https://sketchfab.com/apatel/collections/dl-weapons-guns-realistic-modern-ish-296364604c554e0aa12d25596f05cfe0
  - License: varies by individual model; verify each model license in the Sketchfab listing before publishing.

## Repository status
This branch includes the modular weapon and combat architecture, but it does not ship the final realistic firearm GLB/GLTF files in the repo. They are intentionally omitted because no suitable licensed asset file was available in this environment, and substituting primitive geometry would be misleading.

## Recommended import path
- assets/weapons/pistol.glb
- assets/weapons/assault_rifle.glb
- assets/weapons/materials/
- assets/weapons/textures/
