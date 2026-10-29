# Caramelo RP — modular Unity city map

The Unity map is now organized as five independent 120m x 120m region modules. The assembler places them into one connected 360m x 240m world layout.

## Modules
- **Favela** — stepped hillside, dense houses, rooftop water tanks, alleys, stairs and a small community court.
- **Residential** — detached houses, front yards, neighborhood square and trees.
- **Commercial** — storefronts, market/feira stalls and a gas station.
- **Recreation** — school, yard, football field, basketball court and park.
- **Landmark** — lookout plaza and an original stylized Christ-like monument silhouette.

## Unity setup
1. Copy the complete `unity/Assets/CarameloRP` folder into the `Assets/` folder of the licensed SanAndreasUnity Unity project.
2. Create an empty GameObject named `CarameloWorld`.
3. Add `CarameloWorldAssembler` from `World/CarameloWorldAssembler.cs`.
4. Press Play. The five modules generate under `CarameloRP_World`.
5. Move the player to the `Suggested_Player_Spawn` child, then connect the player camera and mobile controls as described in the root Unity README.

## Important
This is a procedural greybox map made from Unity primitives. It provides layout, basic primitive colliders and a first pass at the districts; it is not finished art, does not contain GTA San Andreas assets, and has not yet been imported, compiled, profiled or tested in Unity in this repository. Replace primitive buildings, trees and props with optimized original/licensed meshes and materials. The current module implementation intentionally uses separate GameObjects and is a development-stage prototype; production optimization should combine static meshes, add LODs, occlusion culling and baked lighting.

The assembler arranges modules in a 2x2-plus-one layout. Adjacent module borders align on a 120m grid; verify road continuity and adjust district entrances after the first Unity scene review.
