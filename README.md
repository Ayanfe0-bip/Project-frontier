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
- CharacterBody3D player controller with movement, acceleration, and sprint logic
- Ground detection, gravity, and jump behavior
- Keyboard input mappings for developer testing
- Temporary humanoid visual prototype ready for later art replacement
- Reusable player scene for future gameplay integration

### Phase 3: World and progression
Planned work:
- City districts and navigation surfaces
- Mission flow and objective system
- Progression, rewards, and encounter pacing
- Vehicle integration and traversal variations

### Phase 4: AI, enemies, and polish
Planned work:
- Enemy behaviors and combat AI
- World events and dynamic encounters
- Visual polish, effects, and performance tuning
- Android optimization and hardware validation

## Repository structure

- `project.godot` — engine project configuration and startup entry
- `scenes/` — all gameplay and environment scenes
- `player/` — player-related assets and scripts
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

Phase 1 remains intact and is preserved as the project foundation. Phase 2 adds a reusable player character controlled by a dedicated CharacterBody3D script and a temporary humanoid prototype to support rapid iteration before final art is integrated.
