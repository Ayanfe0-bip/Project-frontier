# PROJECT FRONTIER

PROJECT FRONTIER is a planned Android-focused third-person open-world 3D action game built in Godot 4.4.1 using GDScript and the compatibility rendering pipeline.

The project is intentionally structured to support a scalable production workflow from the foundation stage through future combat, exploration, missions, city systems, AI, vehicles, and progression.

## Vision

- Third-person, grounded action gameplay on Android devices
- Open-world city and district traversal
- Player progression through missions, combat, vehicles, and world interaction
- Modular architecture for maintainability as the project grows
- Clean Godot project setup that avoids placeholder systems and over-engineered scaffolding

## Development phases

### Phase 1: Foundation and project setup
Completed in this stage:
- Godot project configuration and settings
- Android-oriented project defaults
- Main scene entry point setup
- Folder structure for gameplay systems and world content
- Base scene for the opening playable environment
- Documentation and project organization baseline

### Phase 2: Player system and locomotion
Implemented in this stage:
- CharacterBody3D player controller with movement, acceleration, sprinting, and jump logic
- Ground detection, gravity, and stable locomotion tuning
- Keyboard input mappings for developer testing
- Reusable animation-ready character hierarchy for future humanoid model integration
- Temporary visual prototype designed to be replaced with final art without changing the gameplay architecture

### Phase 3: Third-person camera system
Implemented in this stage:
- Smooth follow camera for the player
- Third-person behind-character perspective
- Horizontal and vertical camera rotation
- Follow distance and camera height tuning
- Camera smoothing and wall collision avoidance
- Desktop mouse-based rotation setup
- Reusable camera rig ready for future Android drag control integration

### Phase 4: Android mobile controls
Implemented in this stage:
- Left-side virtual movement joystick
- Right-side camera drag area for orbiting the camera
- Jump and sprint touch buttons
- Interact button placeholder for future gameplay systems
- Responsive UI layout for multiple Android screen sizes and aspect ratios
- Multitouch-friendly control handling with clear visual feedback
- Preservation of keyboard and mouse input on desktop

### Phase 5: Planned future work
Not started yet.
- Enemy behaviors and combat AI
- World events and dynamic encounters
- Visual polish, effects, and performance tuning
- Additional mission and city systems
- Android optimization and hardware validation

## Repository structure

- `project.godot` — engine project configuration and startup entry
- `scenes/` — all gameplay and environment scenes
- `scenes/player/` — reusable player scene and character hierarchy
- `scenes/camera/` — reusable third-person camera scene
- `scenes/ui/` — mobile control interface scenes
- `scripts/player/` — player controller logic
- `scripts/camera/` — camera scripting and look behavior
- `scripts/ui/` — mobile control input and UI logic
- `camera/` — camera systems and rig resources
- `city/` — city world content, props, and districts
- `vehicles/` — vehicle systems and assets
- `enemies/` — enemy AI and encounter-related resources
- `missions/` — mission structure and logic
- `scripts/` — shared gameplay logic and utilities
- `ui/` — HUD, menus, and interface elements
- `assets/` — art, audio, and external project resources

## Technical constraints

- Godot Engine 4.4.1
- GDScript only
- Compatibility renderer for broader Android compatibility
- No Unity, Unreal, or external game-engine replacement
- No fake placeholder gameplay systems
- No unnecessary external dependencies

## Notes

Phase 1, Phase 2, and Phase 3 remain intact and are preserved as the production foundation. Phase 4 adds reusable Android mobile controls while keeping desktop input fully available for development and iteration.

## Three.js/Vite foundation migration (Phase 1)

This repository now includes a separate Three.js + Vite foundation for Project Frontier while preserving the original Godot project and its historical documentation. The Godot directories, scenes, scripts, and gameplay architecture remain intact and are not deleted or replaced.

### Migration scope

- Preserve the existing Godot project exactly as-is.
- Preserve the weapon models at `assets/weapons/pistol.glb` and `assets/weapons/rifle.glb` without modification.
- Establish a standalone Vite + Three.js application for future game rendering work.
- Prepare the project for Android-friendly browser rendering and Vercel hosting.

### New application structure

- `package.json` — Vite and Three.js project metadata
- `vite.config.js` — local dev server and Vercel-ready build configuration
- `index.html` — application mount point and loading shell
- `src/main.js` — application bootstrap
- `src/style.css` — premium dark UI styling and loading screen
- `src/core/Game.js` — main scene, camera, lighting, renderer, and animation loop
- `src/core/AssetLoader.js` — GLTF loading for the preserved firearm assets
- `public/favicon.svg` — Project Frontier branding asset

### Asset handling

The original Godot project still contains the working weapon GLB files in `assets/weapons/` and those files are left untouched. The Three.js foundation loads the same assets through a GLTFLoader and keeps them modular for future gameplay integration work.

### Local development

```bash
npm install
npm run dev
```

### Production build

```bash
npm run build
```

### Vercel deployment

This project is set up as a standard Vite application and is suitable for deployment on Vercel with the default Vite build output. The `base: './'` configuration keeps asset paths stable for static hosting and browser-based deployment.

### Notes for Phase 1

This migration is intentionally limited to foundation work: a responsive full-screen 3D setup, premium loading flow, and modular scene architecture. It does not replace the Godot project or claim gameplay systems beyond the initial render foundation.
