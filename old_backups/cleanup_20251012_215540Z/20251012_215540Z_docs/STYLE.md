# STYLE.md
## 🎨 Visual & UI Style Guide for Robot Collectors

### 1. Color Palette
- **Primary:** #3484FF (Blue)  
- **Accent:** #1DB954 (Green)  
- **Neutral Light:** #E5E7EB (Gray-200)  
- **Neutral Dark:** #11161C (Card backgrounds)  
- **Warning:** #F59E0B (Amber)

### 2. Typography
- **Title:** Gotham / SourceSans Bold, 22pt  
- **Subtitle:** Gotham Medium, 18pt  
- **Body:** Gotham Book / SourceSans Regular, 14pt  

### 3. UI Components
- **Corner Radius:** 12px on all cards & buttons  
- **Spacing:** 8px (tight), 12px (medium), 16px (large)  
- **Buttons:**
  - Primary: Blue background, white text
  - Success: Green background, white text
  - Muted/Disabled: Gray background, 50% transparency

### 4. Effects
- **Lighting:** Future technology, Brightness 2.5, Ambient RGB(15,18,22)  
- **Bloom:** Intensity 0.1, Size 24  
- **ColorCorrection:** Contrast 0.06, Saturation 0.02, Tint light-blue  

### 5. Robots & Assets
- **Poly Budget:** 1–2.5k tris (LOD0), 600–1k (LOD1)  
- **Materials:** Metal, brushed steel, emissive highlights  
- **Readable silhouette:** Always prioritize clarity over detail  

### 6. Environment
- **Floor darker than walls** for contrast  
- **Rim lights near interactables** (range 12, brightness 1.5)  
- **Neon strips** guide player path (spawn → garage → expansion site)

### 7. Cosmetics & Skins
- Skins should never affect stats  
- Store them in `src/shared/config/data/RobotSkins.luau`  
- Seasonal variants = texture swaps + small VFX (particle/trail)

---

### 8. LOD & Performance Budgets
- Mobile: ≤15k active tris per screen; ≤12 dynamic lights; particle spawn ≤250/s, concurrent ≤150.
- Desktop: ≤40k active tris per screen; ≤20 dynamic lights; particle spawn ≤500/s, concurrent ≤300.
- LOD swaps: LOD1 engages beyond 80 studs; LOD2 (billboard/shell) beyond 160 studs when available.
- Budget dashboard must flag when aggregate tris exceed 80% of target; throttle VFX before disabling gameplay loops.

### 9. Input & Ergonomics
- Default bindings: G (Garage), H (Hatch), A (Assign); controller: D-Pad Left/Up/Right; mobile action buttons ≥48px hit area.
- ProximityPrompts: range 8 studs, hold 0.2s, consistent blue tint (#3484FF) with white text/icons.
- Keep primary actions in bottom-centre taskbar; secondary toggles near relevant panels.
- Avoid stacking more than 2 levels of modals; ESC and B-button always back out.

### 10. Store & Monetization UX
- Purchase flow: Preview → Details (drop rates, bonuses) → Confirm (with Robux/funnel) → Success/Error toast.
- Booster timers visible in HUD taskbar; show remaining duration, stack limits, and expiry.
- Refund/Error states must give retry and support link; log failed receipts.
- “No zone paywalls”: gating uses progression, not positional barriers; respect Roblox policy for transparent odds.

### 11. Localization & Copy
- Tone: upbeat, collaborative, tech-forward; avoid slang.
- Length caps: Title ≤ 40 chars; Button ≤ 22 chars; Tooltip ≤ 90 chars; Toast ≤ 120 chars.
- Use printf-style placeholders (e.g., {playerName}) and wrap strings in i18n helpers.
- Reserve space for text expansion (30% for German/Russian); avoid concatenating terms in code.

### 12. Compliance & QA Checklist
- Roblox policy: no randomized sales without odds, no gambling, adhere to community standards.
- QA pre-ship: test on 1280×720 & 1920×1080 & 2560×1440; verify color contrast ≥ targets; confirm audio ≤ −6 dB peak; check door/garage toggles, hatch flow, and monetization edge cases.
- Log accessibility blockers; ensure ProximityPrompt text is localizable.

---

### Changelog
- 2025-02-14 — Added advanced UI/UX, motion, materials, performance, input, and monetization standards.
