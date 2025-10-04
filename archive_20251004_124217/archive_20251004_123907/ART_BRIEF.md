# Robot Collectors: Rise of Gearhold - 3D Art Brief

## 🎨 Project Overview
Sci-fi robot collection RPG for Roblox. Players collect, upgrade, and battle with robotic companions across 5 unique zones.

## 📋 Art Direction

### **Visual Style**
- **Genre**: Hard sci-fi with industrial/cyberpunk elements
- **Tone**: Serious but accessible, post-apocalyptic future
- **Color Palette**: Cool blues, metallic grays, rust oranges, neon accents
- **Lighting**: High contrast, dramatic shadows, glowing tech elements

---

## 🤖 Robot Asset Requirements

### **Technical Specifications**
- **Format**: .fbx with embedded materials OR .obj + .mtl
- **Polygon Count**: 1,000-3,000 triangles (mobile optimization)
- **Textures**: 512x512 to 1024x1024 PNG/JPG
- **UV Mapping**: Single UV layout per model
- **Pivot Point**: Bottom center of model
- **Scale**: Approximately 2-4 Roblox studs tall

### **Robot Types & Design Guidelines**

#### **1. ASSAULT ROBOTS (Combat-focused)**
- **Aesthetic**: Military, angular, weapon-integrated
- **Proportions**: Balanced, human-like proportions
- **Materials**: Matte metals, carbon fiber, tactical gear
- **Details**: Weapon mounts, armor plating, tactical lights
- **Examples**: CombatBot, BlitzMech, PlasmaWarrior

#### **2. DEFENDER ROBOTS (Tank/Protection)**
- **Aesthetic**: Fortress-like, imposing, heavily armored
- **Proportions**: Wide shoulders, thick limbs, low center of gravity
- **Materials**: Heavy plate armor, reinforced joints
- **Details**: Shield generators, armor panels, defensive spikes
- **Examples**: IronGuardian, SteelFortress

#### **3. SUPPORT ROBOTS (Utility/Healing)**
- **Aesthetic**: Clean, medical, elegant technology
- **Proportions**: Tall, slender, graceful movement
- **Materials**: Clean panels, glass/crystal, soft lighting
- **Details**: Medical equipment, scanning devices, gentle curves
- **Examples**: MediDrone, RepairBot, UniCore

#### **4. SCOUT ROBOTS (Speed/Reconnaissance)**
- **Aesthetic**: Streamlined, lightweight, built for speed
- **Proportions**: Compact, thin limbs, aerodynamic
- **Materials**: Lightweight alloys, exposed tech, transparent panels
- **Details**: Sensors, communication arrays, speed-focused design
- **Examples**: SpeedRunner, StealthOps

#### **5. HEAVY ROBOTS (Power/Destruction)**
- **Aesthetic**: Industrial, massive, intimidating
- **Proportions**: Oversized, bulky, powerful-looking
- **Materials**: Thick metal, exposed machinery, weathered surfaces
- **Details**: Heavy weapons, hydraulics, industrial components
- **Examples**: ApexTitan, Berserker

### **Rarity Visual Progression**
- **Common**: Basic materials, simple designs
- **Uncommon**: Enhanced details, better materials
- **Rare**: Glowing elements, advanced tech
- **Epic**: Particle effects, premium materials
- **Legendary**: Unique designs, animated elements

---

## 🌍 Environment Asset Requirements

### **Zone 1: Corepoint Station**
- **Theme**: Industrial space station hub
- **Architecture**: Modular sci-fi buildings, clean lines
- **Materials**: Brushed metal, glass, illuminated panels
- **Props**: Control consoles, holographic displays, machinery

### **Zone 2: Rustspire Yards**
- **Theme**: Post-apocalyptic salvage yard
- **Architecture**: Scrap metal structures, makeshift buildings
- **Materials**: Rusted metal, weathered concrete, exposed wiring
- **Props**: Scrap piles, broken robots, industrial cranes

### **Zone 3: Voltbay Arena**
- **Theme**: High-tech combat arena
- **Architecture**: Sleek arena design, energy barriers
- **Materials**: Polished metal, energy fields, neon lighting
- **Props**: Spectator stands, holographic scoreboards, weapon racks

### **Zone 4: Bytewind Market**
- **Theme**: Cyberpunk marketplace
- **Architecture**: Vertical city, neon-lit shops
- **Materials**: Dark metals, glowing signs, transparent screens
- **Props**: Vendor stalls, holographic advertisements, crowds

### **Zone 5: Hollow Hex Core**
- **Theme**: Mysterious alien technology
- **Architecture**: Crystalline structures, floating platforms
- **Materials**: Crystal, energy, otherworldly metals
- **Props**: Ancient machinery, energy cores, floating debris

---

## 👤 Character Customization Assets

### **Player Armor Sets**
- **Basic Engineer**: Simple work gear, utility focus
- **Combat Specialist**: Military-grade armor, weapon attachments
- **Tech Commander**: Advanced suit, integrated displays
- **Elite Explorer**: High-end gear, unique materials

### **Accessories**
- Helmets (5-8 variations)
- Backpacks/utility packs
- Weapon holsters
- Tech gadgets

---

## 🔧 Integration Process

### **Asset Upload Workflow**
1. **Artist creates 3D model** following specifications
2. **Upload to Roblox** as mesh/decal assets
3. **Provide asset IDs** (rbxassetid://numbers)
4. **Update AssetManager.lua** with new IDs
5. **Test integration** in-game
6. **Iterate based on feedback**

### **Naming Convention**
- Models: `RC_RobotName_Type` (e.g., `RC_BlitzMech_Assault`)
- Textures: `RC_RobotName_Diffuse` (e.g., `RC_BlitzMech_Diffuse`)
- Animations: `RC_RobotName_Action` (e.g., `RC_BlitzMech_Walk`)

### **Quality Standards**
- Models must import cleanly into Roblox Studio
- Textures should be optimized for mobile performance
- All assets tested on multiple device types
- Consistent art style across all models

---

## 📞 Communication

### **Deliverables Timeline**
- **Week 1-2**: Robot concepts and first 5 models
- **Week 3-4**: Environment assets for 2 zones
- **Week 5-6**: Character customization assets
- **Week 7+**: Additional robots and polish

### **Feedback Process**
- Weekly reviews with gameplay integration
- Performance testing on mobile devices
- Art style consistency checks
- Player feedback incorporation

---

## 🖼️ UI Asset Requirements

### **Icon Design Specifications**
- **Format**: PNG with transparency
- **Sizes**: 64x64px, 128x128px, 256x256px (multiple resolutions)
- **Style**: Consistent flat/outlined style with the game's sci-fi theme
- **Color**: Monochrome designs that can be tinted programmatically

### **UI Icons Needed**
- **Currency**: Gearbits coin, Ion Shards crystal
- **Navigation**: Inventory bag, Hatch egg, Battle sword, Workshop gear, Map location
- **Robot Types**: Assault target, Defender shield, Support cross, Scout eye, Heavy fist
- **Actions**: Close X, Back arrow, Settings gear, Help question, Search magnifier
- **Resources**: Mining pickaxe, Energy lightning, Level star, Experience bar

### **UI Backgrounds & Panels**
- **Format**: PNG with 9-slice borders for scaling
- **Style**: Sci-fi panels with glowing edges, metal textures
- **Transparency**: Alpha channels for layering effects
- **Modularity**: Corner pieces, edges, fills for flexible sizing

### **Button States**
- **Normal**: Default appearance
- **Hover**: Highlighted state (glow effect)
- **Pressed**: Depressed/activated state
- **Disabled**: Grayed out appearance

### **Animated UI Elements**
- **Format**: Sprite sheets or individual frames
- **Frame Rate**: 30fps max for performance
- **Loop Types**: Seamless loops for idle states
- **Particle Effects**: Hatch sparkles, level up celebrations

### **Integration Process**
1. **Artist creates UI assets** following specifications
2. **Upload to Roblox** as ImageLabel assets
3. **Update UIAssets.lua** with new asset IDs
4. **Automatic fallback** to emoji/solid colors if assets not ready
5. **Progressive enhancement** as assets become available

### **Fallback System**
- **Current**: Uses emoji icons and solid colors
- **With Assets**: Seamlessly upgrades to custom graphics
- **Benefits**: Development continues without waiting for art

---

*This brief ensures seamless integration of both 3D models and UI assets into the existing game framework while maintaining visual consistency and technical performance.*