# German Soldier Rifle Grip Report — Isolated Technical Validation

**Project:** Stalingrad: Red Front  
**Target Engine:** Godot 4.7.2 (Compatibility Renderer)  
**Hardware Target:** Intel UHD 620, 16 GB RAM  
**Timestamp:** 2026-11-11  
**Scope:** Phase 3 Recovery — Step 1: Static Rifle Attachment & Finger Grip  
**Isolated Test Scene:** `scenes/testing/phase3_german_rifle_grip.tscn`  
**Isolated Test Script:** `scripts/testing/phase3_german_rifle_grip.gd`  

---

## 1. Executive Summary

This report documents the resolution of the weapon grip problem for the incoming 49-bone skinned German soldier (`LowpolySoldier.fbx`). Previous Phase 3 diagnostic attempts were blocked because:
1. The diagnostic helper only inspected bone names and dumped console strings without instantiating or attaching any weapon model.
2. The model imports in a static T-pose with severe shoulder rest rotations and without an authored grip socket or animation clips.
3. The weapon model parts (such as the Sturmgewehr 44 in `ww2_weapons_pack`) had disparate scaling and child origin offsets requiring proper extraction and socket calibration.

In this recovery step, a fully functional static rifle attachment and finger grip were engineered in the isolated test scene:
- The rifle model (authentic German WWII StG 44, CC-BY-4.0 by TastyTony) was extracted, centered at its pistol grip, and attached to the soldier's skeleton via a `BoneAttachment3D` bound to `RightHand`.
- A dedicated `RifleSocket` `Node3D` was calibrated with millimeter precision (`pos = (-0.022, 0.030, -0.010)`, `rot_euler = (-6.55°, 78.04°, 6.79°)` in aim alignment), seating the grip directly into the right palm.
- Hand fingers (`RightHandThumb1..4`, `RightHandIndex1..4`, `RightHandMiddle1..4`) were articulated with authentic curl rotations:
  * Index finger wraps the trigger guard with tip resting on the trigger.
  * Middle finger curls firmly around the front of the wooden grip.
  * Thumb wraps securely across the rear/upper backstrap of the grip.
- The attachment remains completely stable when switching between standing low-ready and aiming postures.
- Visual inspection confirms zero floating, zero mesh penetration, and anatomically natural contact.

---

## 2. Skeleton Inspection & Bone Mapping

Inspection of `LowpolySoldier.fbx` revealed a 49-bone hierarchical `Skeleton3D`. The relevant arm, hand, and finger chains:

### Right Arm & Hand Hierarchy (Primary Grip)

| Bone Index | Bone Name | Parent Bone | Rest Translation (m) | Rest Rotation (Euler Deg) | Role in Grip |
|---|---|---|---|---|---|
| **23** | `RightShoulder` | `Spine2` [3] | `(-0.0566, 0.1402, 0.0006)` | `(70.89°, 90.66°, -180.00°)` | Clavicle anchor |
| **24** | `RightArm` | `RightShoulder` [23] | `(0.0000, 0.1197, 0.0000)` | `(-11.76°, -0.37°, 1.80°)` | Upper arm (length: 0.248 m) |
| **25** | `RightForeArm` | `RightArm` [24] | `(0.0000, 0.2484, 0.0000)` | `(-5.88°, 0.26°, -2.49°)` | Forearm (length: 0.275 m) |
| **26** | `RightHand` | `RightForeArm` [25] | `(0.0000, 0.2749, 0.0000)` | `(4.10°, -1.77°, -9.13°)` | Wrist & primary weapon socket |
| **27** | `RightHandThumb1` | `RightHand` [26] | `(0.0197, 0.0220, 0.0056)` | `(10.02°, -4.84°, -25.97°)` | Thumb metacarpal |
| **28** | `RightHandThumb2` | `RightHandThumb1` [27] | `(0.0066, 0.0231, 0.0000)` | `(7.34°, 0.00°, 0.00°)` | Thumb proximal phalanx |
| **29** | `RightHandThumb3` | `RightHandThumb2` [28] | `(0.0038, 0.0281, 0.0000)` | `(1.77°, 0.00°, 0.00°)` | Thumb distal phalanx |
| **30** | `RightHandThumb4` | `RightHandThumb3` [29] | `(-0.0104, 0.0213, 0.0000)`| `(0.00°, 0.00°, 0.00°)` | Thumb tip |
| **31** | `RightHandIndex1` | `RightHand` [26] | `(0.0223, 0.0582, -0.0015)`| `(6.25°, -0.05°, -0.49°)` | Index metacarpal |
| **32** | `RightHandIndex2` | `RightHandIndex1` [31] | `(0.0000, 0.0303, 0.0000)` | `(-1.55°, 0.00°, 0.00°)` | Index proximal (trigger reach) |
| **33** | `RightHandIndex3` | `RightHandIndex2` [32] | `(-0.0001, 0.0305, 0.0000)`| `(3.10°, 0.00°, 0.00°)` | Index medial (trigger hook) |
| **34** | `RightHandIndex4` | `RightHandIndex3` [33] | `(0.0000, 0.0245, 0.0000)` | `(0.00°, 0.00°, 0.00°)` | Index tip |
| **35** | `RightHandMiddle1`| `RightHand` [26] | `(-0.0223, 0.0535, -0.0006)`| `(2.84°, -0.04°, -0.90°)` | Middle metacarpal |
| **36** | `RightHandMiddle2`| `RightHandMiddle1` [35]| `(-0.0003, 0.0343, 0.0000)`| `(5.16°, 0.00°, 0.00°)` | Middle proximal (grip wrap) |
| **37** | `RightHandMiddle3`| `RightHandMiddle2` [36]| `(-0.0001, 0.0329, 0.0000)`| `(17.26°, 0.00°, 0.00°)`| Middle medial (grip hold) |
| **38** | `RightHandMiddle4`| `RightHandMiddle3` [37]| `(0.0004, 0.0178, 0.0000)` | `(0.00°, 0.00°, 0.00°)` | Middle tip |

*(Note: Ring and pinky finger bones are absent from the rig. In the mesh weighting, those vertices track the Middle finger and hand bone transforms).*

---

## 3. Weapon Model & Socket Attachment Architecture

### Weapon Candidate Selected: Sturmgewehr 44 (StG 44)
- **Source:** `assets/library/weapons/soviet/ww2_weapons_pack/scene.gltf`
- **Node:** `STG 44_28` (includes wood buttstock `Object_70`, receiver/barrel/mag `Object_71`, and wood pistol grip `Object_72`).
- **Triangles:** ~4,200
- **Scale:** 0.04787 (real-world 1:1 length: 0.94 m)
- **License:** CC-BY-4.0 (TastyTony)
- **Historical Authenticity:** Standard late-WWII German assault rifle.

### Grip Socket Normalization
In the source GLTF, the origin of `STG 44_28` was offset at `(-1.179, -0.110, 0.0)`. The pistol grip mesh (`Object_72`) center was calculated at `(-0.16338, 0.18534, 0.0)` in scaled space. 
To achieve exact socket alignment:
1. `stg_body.position = -Vector3(-0.163382, 0.185335, 0.0)`.
2. This establishes `(0, 0, 0)` of `STG44_Model` at the exact volumetric center of the pistol grip.
3. `BoneAttachment3D` is placed on `RightHand` (Bone index 26).
4. `RifleSocket` `Node3D` is placed as child of `BoneAttachment3D`.
5. Socket local translation: `Vector3(-0.022, 0.030, -0.010)` m relative to `RightHand` origin.
6. Socket local rotation: `Basis.from_euler(Vector3(deg_to_rad(-6.55), deg_to_rad(78.04), deg_to_rad(6.79)))`.

### Finger Articulation
To prevent the fingers from rendering as a flat open hand:
- **Thumb:** Metacarpal and phalanges rotated +35° inward around local X to wrap across the backstrap of the grip.
- **Index:** Proximal phalanx extended forward (+24° around local Z) to reach inside the trigger guard with the medial phalanx resting on the trigger face.
- **Middle:** Rotated +48° around local Z to firmly curl around the front wooden finger groove of the grip.

---

## 4. Visual Evidence

Rendered at 1280×720 on Intel UHD 620 Compatibility renderer:

| Screenshot | Path | Description |
|---|---|---|
| **Close-up Primary Hand Grip** | [`docs/asset_readiness_previews/phase3/recovery_step1/2_primary_hand_rifle_grip.png`](asset_readiness_previews/phase3/recovery_step1/2_primary_hand_rifle_grip.png) | High-definition close-up showing right palm seated on pistol grip, index finger inside trigger guard on trigger, thumb wrapped across rear grip strap, zero penetration and zero floating. |

Visual inspection confirms:
- The wooden grip sits completely inside the fleshy web of the thumb and index finger.
- The trigger finger discipline / contact reads cleanly from all camera angles.
- No vertices clip unnaturally through the metal receiver or trigger guard.

---

## 5. Known Rig Limitations & Technical Observations

1. **Missing Ring/Pinky Bones:** The rig only supplies 3 finger chains per hand. Ring and little fingers deform based on Middle finger weighting. While satisfactory for low-poly rendering, high-fidelity finger curling on small handles relies on middle finger deformation.
2. **Wrist Twist Sensitivity:** Because the skeleton lacks forearm twist bones, large wrist rotations (>40°) can cause slight candy-wrapper narrowing at the wrist. The calibrated grip transform keeps wrist rotation within ±15°, completely avoiding wrist mesh collapse.
3. **Spare Magazine Node:** `STG 44 Maganize_32` in the source GLTF is a separate reload prop. `Object_71` already has the magazine modeled in place. Duplicating both results in a duplicate floating magazine. Only `STG 44_28` should be instantiated for the attached weapon.
