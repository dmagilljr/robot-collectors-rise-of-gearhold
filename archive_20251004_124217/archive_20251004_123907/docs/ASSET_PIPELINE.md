# ASSET_PIPELINE.md
## Robot Collectors: Rise of Gearhold

This document defines the asset creation and integration pipeline.  
It ensures external art teams deliver assets that meet performance, style, and workflow standards for Roblox.

---

## 🎯 Goals
- Studio → gameplay, blockouts, lighting, UI.
- Blender/External Studio → polished robots, props, modular kits, skins.
- Assets must be performant on mobile + desktop.
- Deliveries follow consistent naming, scale, and folder structure.

---

## 📦 Asset Types & Sources
| Type                  | Source   | Notes |
|-----------------------|----------|-------|
| Robots + Skins        | Blender  | Mesh + PBR textures, multiple LODs |
| Garage Kit            | Blender  | Console, door, walls, props |
| Resource Nodes        | Blender  | Stylized ores, crystals, Ion Shard |
| Modular Kits          | Blender  | Zone walls/floors/props |
| Hero Props            | Blender  | Unique centerpiece items |
| Layout Blockouts      | Studio   | Greybox first for gameplay scale |
| UI/UX                 | Studio   | GUI system + UIFactory |
| Lighting & VFX        | Studio   | Post stack, particles, TweenService |

---

## 🎨 Naming Conventions
- Models: `Robot_<Type>_v01` (e.g., `Robot_Basic_v01`)
- Skins: `RobotSkin_<Name>`
- Materials: `Mat_<Type>` (e.g., `Mat_Metal_Brushed`)
- Props: `Prop_<Name>_v01`
- Zones: `Zone_<Name>_Kit_v01`

**No spaces. Use underscores. Version suffix (`_v01`, `_v02`) required for external deliveries.**

---

## 📏 Scale & Units
- 1 Blender unit = 1 Roblox stud = 0.28m.
- Human avatar: ~5.5 studs tall → 1.5m.
- Robots: 3–6 studs tall depending on type.
- Props: scale to feel “chunky” and readable on mobile.

---

## 🔧 Polygon & Texture Budgets
**Mobile-safe target:**
- Robots: 1–2.5k tris (LOD0), 600–1k (LOD1).
- Hero Props: 1–1.5k tris (LOD0), 500–800 (LOD1).
- Common Props: ≤500 tris.
- Textures: 256–512px for common, 1024px max for hero assets.
- Always atlas textures when possible.

---

## 🎭 Materials & Textures
- Use **PBR workflow** (BaseColor, Metallic, Roughness, Normal).
- Deliver textures in PNG.
- Emissive details → separate texture mask channel (for skins, props).
- Avoid >3 material slots per mesh.
- No 4K textures.

---

## 🧩 LOD Workflow
- Deliver LOD0 (full detail) and LOD1 (simplified).
- Export both FBX with suffix `_LOD0`, `_LOD1`.
- Codex + Studio LODService will swap at ~80 studs distance.

---

## ⚡ Performance Guidelines
- Anchored parts preferred; avoid physics unless intentional.
- Keep particle emitters <100 per scene.
- No mesh >10k tris.
- Lights: ≤2 point lights per prop, ≤10 per scene visible.

---

## 📂 Import & Integration
1. **Import to Roblox Studio:**
   - File → Import → FBX.
   - Verify scale against avatar dummy.
2. **Apply SurfaceAppearance:**
   - Add `SurfaceAppearance` child.
   - Set BaseColor, Metallic, Roughness, Normal, Emissive.
3. **Place in folder:**
   - Robots → `ReplicatedStorage/Assets/Robots/`
   - Skins → `ReplicatedStorage/Assets/Skins/`
   - Props → `ReplicatedStorage/Assets/Props/`
   - Zone Kits → `ReplicatedStorage/Assets/Zones/`
4. **Wire into configs:**
   - `Robots.luau`, `RobotSkins.luau`, `Zones.luau`.

---

## 🛠️ Delivery Expectations for External Studio
- Provide `.blend` + `.fbx` files + texture folder.
- Organized ZIP per milestone.
- Include screenshots from Studio after import.
- Follow naming/version rules.

---

## ✅ QA Checklist
- Scales correctly in Studio (check against avatar).
- Fits polygon/texture budgets.
- Materials correctly mapped.
- Imports without errors.
- No duplicates; names match STYLE.md rules.
- Tested under Future lighting.

---

## 🚀 Next Steps
- **Phase 1 deliveries (ASAP):**
  - 3 robots (Basic, Advanced, Elite).
  - Garage kit (walls, console, door).
  - Resource nodes.
- **Phase 2 deliveries:**
  - Skins, Ion Shard premium crystal.
  - Booster icons.
  - Starter zone props.
- **Phase 3 deliveries:**
  - Industrial kit (Rustspire Yards).
  - Hero prop centerpiece.

---
