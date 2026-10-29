# Caramelo RP — Unity foundation

This folder is the Caramelo-specific Unity layer intended to be integrated into a licensed working copy of [SanAndreasUnity](https://github.com/in0finite/SanAndreasUnity). It is not a standalone Unity project and does not contain GTA game data.

## Upstream requirements
- SanAndreasUnity upstream branch: `dev`
- Unity 2020.3.26 or newer (use the exact editor version recorded by upstream before opening)
- Clone upstream with submodules: `git clone --depth 1 --recurse-submodules https://github.com/in0finite/SanAndreasUnity`
- Read upstream license and retain its attribution. This repository's code is MIT; GTA assets are not included and must not be redistributed.

## Integration
Copy `Assets/CarameloRP` into the upstream Unity project's `Assets/` directory. Attach:
- `Runtime/CarameloQuality.cs` to a bootstrap object.
- `Mobile/CarameloMobileInput.cs` to the mobile HUD canvas; wire the movement joystick and action buttons in the Inspector.
- `Player/CarameloPlayerMotor.cs` to a player with CharacterController.
- `Camera/CarameloCameraFollow.cs` to the camera and assign the player target.

The scripts form a Caramelo-specific mobile control/quality layer. They do not yet replace the upstream world, player model, vehicles, or networking. Those systems must be integrated and tested in Unity before an APK can be called playable.

## Visual target
Original Brazilian city environment: hillside community, narrow streets, stairs, retaining walls, water tanks, small shops, school, football court and a modern urban district. Use original/licensed meshes and PBR textures, not ripped GTA assets.

## Android performance targets
- Default: 30 FPS cap, URP-compatible materials, baked lighting where possible, one main real-time shadow light.
- Low: 1.0 render scale, shadows off, reduced LOD distance.
- Medium: 1.15 render scale, hard shadows, medium LOD distance.
- High: 1.35 render scale, soft shadows only on supported devices.
- Use texture compression (ASTC where supported, ETC2 fallback), LOD Groups, occlusion culling, GPU instancing and pooled traffic/NPC objects.
- Profile on the target phone; quality presets are starting points, not guarantees.
