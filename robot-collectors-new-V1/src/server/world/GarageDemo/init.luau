--!strict
local RunService   = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local Lighting     = game:GetService("Lighting")

-- ======= TUNE HERE (door/opening + visual theme) =======
local DOOR_W  = 8.0            -- studs
local DOOR_H  = 8.0            -- studs
local N_SLATS = 16             -- number of slats
local STAGGER = 0.0            -- 0.0 = move together to verify; restore 0.06 for ripple later
local MOVE_AS_SHEET = true     -- when true, the curtain moves as one unit (no stacking)

local PLANE_MARGIN = PLANE_MARGIN or 0.05  -- how far behind the door plane we place front faces

local ENABLE_FORCE_CLEAR = false  -- <<< OFF by default; turn on only for debugging

local FRONT_INSET = 0.20   -- how far to pull shell front faces inside the bay

-- Theme (from STYLE.md)
local THEME = {
    wallGlass    = Color3.fromRGB(22,24,28),   -- smoked glass walls
    hoodMetal    = Color3.fromRGB(60,70,80),   -- hood/trim
    railMetal    = Color3.fromRGB(72,80,92),   -- rails
    doorMetal    = Color3.fromRGB(130,190,255),-- door slats
    floorMetal   = Color3.fromRGB(30,34,39),   -- floor darker than walls
    neonBlue     = Color3.fromRGB(52,132,255), -- accent strips
    promptBlue   = Color3.fromRGB(52,132,255)  -- prompt tint (for later UI)
}

-- Visual toggles
local ENABLE_RIM  = false   -- set true to add blue rim light at the handle
local ENABLE_NEON = false   -- set true to add short neon guide path from spawn
-- =============================================

local M = {} ; M.VERSION = "rollup-styled-"..tostring(os.time())
print("🏗️ GarageDemo ACTIVE", M.VERSION, "W=", DOOR_W, "H=", DOOR_H, "slats=", N_SLATS)

-- --- small helpers ---
local function part(name: string, parent: Instance, size: Vector3, cf: CFrame, props: {[string]: any}?): BasePart
    local p = parent:FindFirstChild(name) :: BasePart?
    if not p then p = Instance.new("Part"); p.Name = name; p.Parent = parent end
    p.Anchored = true; p.Size = size; p.CFrame = cf
    if props then for k,v in pairs(props) do (p :: any)[k] = v end end
    return p
end
local function cfFromBasis(pos: Vector3, right: Vector3, up: Vector3, out: Vector3) return CFrame.fromMatrix(pos, right, up, out) end

-- Style helpers (idempotent)
local function ensureLightingProfile()
    -- Future lighting + subtle post
    pcall(function() Lighting.Technology = Enum.Technology.Future end)
    Lighting.Brightness = 2.5
    Lighting.Ambient    = Color3.fromRGB(15,18,22)
    -- ColorCorrection
    local cc = Lighting:FindFirstChild("RC_CC") :: ColorCorrectionEffect?
    if not cc then cc = Instance.new("ColorCorrectionEffect"); cc.Name = "RC_CC"; cc.Parent = Lighting end
    cc.TintColor = Color3.fromRGB(220,235,255)
    cc.Contrast  = 0.06
    cc.Saturation= 0.02
    -- Bloom
    local bloom = Lighting:FindFirstChild("RC_Bloom") :: BloomEffect?
    if not bloom then bloom = Instance.new("BloomEffect"); bloom.Name = "RC_Bloom"; bloom.Parent = Lighting end
    bloom.Intensity = 0.1
    bloom.Size      = 24
end

local function stylePartGlass(p: BasePart)
    p.Material     = Enum.Material.Glass
    p.Color        = THEME.wallGlass
    p.Transparency = 0.55
end

local function stylePartMetal(p: BasePart, c: Color3)
    p.Material = Enum.Material.Metal
    p.Color    = c
end

local function recedeFrontFace(part: BasePart, inset: number)
    -- Shell is axis-aligned; +Z is outward. Move center back by inset/2 so front face recedes by inset.
    -- (Center shift preserves back face alignment.)
    part.CFrame = part.CFrame * CFrame.new(0, 0, -inset * 0.5)
    -- Increase depth to keep interior seam closed
    part.Size   = Vector3.new(part.Size.X, part.Size.Y, part.Size.Z + inset)
end

local function ensureRimLight(parent: Instance, where: CFrame)
    local n = parent:FindFirstChild("GD_RimLight") :: BasePart?
    if not n then
        n = Instance.new("Part"); n.Name = "GD_RimLight"; n.Parent = parent
        n.Anchored=true; n.CanCollide=false; n.Transparency=1; n.Size=Vector3.new(0.2,0.2,0.2)
        local L = Instance.new("PointLight", n)
        L.Brightness = 1.5; L.Range = 12; L.Color = THEME.neonBlue
    end
    n.CFrame = where
end

local function ensureNeonPath(fromCF: CFrame, toCF: CFrame, parent: Instance)
    -- short 3-segment neon guide
    local segs = {"GD_Path_1","GD_Path_2","GD_Path_3"}
    local p0 = fromCF.Position; local p3 = toCF.Position
    for i, name in ipairs(segs) do
        local t = i/ (#segs+1)
        local pos = p0:Lerp(p3, t)
        local strip = part(name, parent, Vector3.new(4,0.2,0.35), CFrame.new(pos), {})
        strip.CanCollide=false
        strip.Material = Enum.Material.Neon
        strip.Color    = THEME.neonBlue
    end
end

-- Build an invisible box across the doorway (non-colliding). We reuse it to query overlaps.
local function ensurePassageVolume(root: Instance, openCF: CFrame, openingW: number, openingH: number): BasePart
    local pv = root:FindFirstChild("GD_Passage") :: BasePart?
    if not pv then
        pv = Instance.new("Part")
        pv.Name = "GD_Passage"; pv.Parent = root
        pv.Anchored = true; pv.CanCollide = false; pv.Transparency = 1
        pv.Material = Enum.Material.SmoothPlastic
    end
    -- Slightly inside the garage so we don’t catch the outside ground
    local size  = Vector3.new(math.max(0.1, openingW - 0.6), math.max(0.1, openingH + 0.4), 1.0)
    local cf    = openCF * CFrame.new(0, 0, -0.50)
    pv.Size = size; pv.CFrame = cf
    return pv
end

-- Query parts overlapping the Passage Volume, excluding our garage model and door
local function getDoorwayBlockers(pv: BasePart, garageRoot: Instance, doorModel: Instance): {BasePart}
    local params = OverlapParams.new()
    params.FilterType = Enum.RaycastFilterType.Exclude
    params.FilterDescendantsInstances = {garageRoot, doorModel}
    local parts = workspace:GetPartBoundsInBox(pv.CFrame, pv.Size, params)
    local out = {}
    for _,p in ipairs(parts) do
        if p:IsA("BasePart") and p.CanCollide and p.Transparency < 1 then
            table.insert(out, p :: BasePart)
        end
    end
    return out
end

-- Return parts that lie *across the mouth plane* (very thin in Z at the opening), excluding door/rails/handle
local function getMouthPlates(
    openCF: CFrame,
    openingW: number,
    openingH: number,
    root: Instance,
    doorModel: Instance,
    rails: {BasePart},
    handle: BasePart?,
    hood: BasePart?
): {BasePart}
    local width  = math.max(0.1, openingW + 0.40)
    local height = math.max(0.1, openingH + 0.40)
    local depth  = 0.30
    local mouthCF = openCF * CFrame.new(0, 0, 0.002)

    local params = OverlapParams.new()
    params.FilterType = Enum.RaycastFilterType.Exclude
    local excludes = {doorModel}
    for _,r in ipairs(rails) do table.insert(excludes, r) end
    if handle then table.insert(excludes, handle) end
    if hood then table.insert(excludes, hood) end
    params.FilterDescendantsInstances = excludes

    local candidates = workspace:GetPartBoundsInBox(mouthCF, Vector3.new(width, height, depth), params)
    local out = {}
    for _,p in ipairs(candidates) do
        if p:IsA("BasePart") and p.Transparency < 1 then
            local sz = p.Size
            if sz.Z <= 0.35 and sz.X >= width*0.55 and sz.Y >= height*0.45 then
                table.insert(out, p)
            end
        end
    end
    return out
end

local function sanitizeMouth(
    openCF: CFrame,
    openingW: number,
    openingH: number,
    root: Instance,
    doorModel: Instance,
    rails: {BasePart},
    handle: BasePart?,
    hood: BasePart?
)
    local plates = getMouthPlates(openCF, openingW, openingH, root, doorModel, rails, handle, hood)
    local n=0
    for _,p in ipairs(plates) do
        p.CanCollide   = false
        p.Transparency = 1
        n += 1
    end
    if n>0 then
        print(string.format("[GarageDemo] mouth sanitized: hid %d plate(s)", n))
    end
end



local function forceClearMouth(
    openCF: CFrame, openingW: number, openingH: number, floorY: number,
    root: Instance, doorModel: Instance, hood: BasePart?, rails: {BasePart}, handle: BasePart?
)
    if not ENABLE_FORCE_CLEAR then
        print("[GarageDemo] forceClearMouth: disabled")
        return
    end

    local planeZ = openCF.Position.Z    -- door plane (mouth)
    local width  = openingW + 0.40
    local height = openingH + 0.40
    local depth  = 0.30
    local params = OverlapParams.new()
    params.FilterType = Enum.RaycastFilterType.Exclude
    params.FilterDescendantsInstances = {doorModel}

    local WL = {}
    local function mark(x) if x then WL[x] = true end end
    mark(hood); mark(handle)
    for _,r in ipairs(rails) do mark(r) end
    local thresh = root:FindFirstChild("GD_Threshold")
    local apron  = root:FindFirstChild("GD_ApronOutside")
    mark(thresh); mark(apron)

    local moved, hidden = 0, 0
    for _,p in ipairs(workspace:GetPartBoundsInBox(openCF * CFrame.new(0,0, 0.002), Vector3.new(width, height, depth), params)) do
        if p:IsA("BasePart") and p.Transparency < 1 and not WL[p] and not p:IsDescendantOf(doorModel) then
            local sz = p.Size
            local thinZ   = sz.Z <= 0.35
            local shallowY= sz.Y <= (openingH * 0.4)
            local wideX   = sz.X >= (openingW * 0.55)
            if thinZ and shallowY and wideX then
                p.CanCollide   = false
                p.Transparency = 1
                p.CFrame       = p.CFrame * CFrame.new(0, 0, -0.20)
                moved  += 1; hidden += 1
                print("[GarageDemo] forceClear hid:", p:GetFullName(), "size=", sz)
            end
        end
    end
    print(string.format("[GarageDemo] forceClearMouth: hidden=%d moved=%d", hidden, moved))
end

local function findMidHeaderPlates(
    openCF: CFrame,
    openingW: number,
    openingH: number,
    floorY: number,
    doorModel: Instance,
    rails: {BasePart},
    handle: BasePart?
): {BasePart}
    -- A scan box on the doorway plane, from ~10% above floor to ~90% below lintel
    local width  = math.max(0.1, openingW + 0.40)
    local height = math.max(0.1, openingH * 0.8)
    local depth  = 0.30
    -- center the scan vertically at mid-height; keep it on the mouth plane
    local midY   = floorY + (openingH * 0.5)
    local scanCF = openCF * CFrame.new(0, midY - openCF.Position.Y, 0.002)

    local params = OverlapParams.new()
    params.FilterType = Enum.RaycastFilterType.Exclude
    local excludes = {doorModel}
    for _,r in ipairs(rails) do table.insert(excludes, r) end
    if handle then table.insert(excludes, handle) end
    params.FilterDescendantsInstances = excludes

    local out = {}
    for _,p in ipairs(workspace:GetPartBoundsInBox(scanCF, Vector3.new(width, height, depth), params)) do
        if p:IsA("BasePart") and p.Transparency < 1 then
            local sz = p.Size
            -- Plate heuristics: very thin in Z, wide in X, shallow Y (looks like a header bar)
            local thinZ   = sz.Z <= 0.35
            local wideX   = sz.X >= (openingW * 0.6)
            local shallowY= sz.Y <= (openingH * 0.40)
            if thinZ and wideX and shallowY then
                table.insert(out, p)
            end
        end
    end
    return out
end

local function removeMidDoorHeaders(
    openCF: CFrame,
    openingW: number,
    openingH: number,
    floorY: number,
    root: Instance,
    doorModel: Instance,
    rails: {BasePart},
    handle: BasePart?
)
    local plates = findMidHeaderPlates(openCF, openingW, openingH, floorY, doorModel, rails, handle)
    local n = 0
    for _,p in ipairs(plates) do
        -- hide & disable any false header on the doorway plane
        p.CanCollide   = false
        p.Transparency = 1
        n += 1
        print("[GarageDemo] REMOVED mid header:", p:GetFullName(), "size=", p.Size)
    end
    if n == 0 then print("[GarageDemo] mid header scan: none found") end
end

-- We’ll store original collision flags so we can restore on close
local disabledCollision: {BasePart} = {}

local function disableDoorwayColliders(pv: BasePart, garageRoot: Instance, doorModel: Instance, floorY: number)
    disabledCollision = {}
    local blockers = getDoorwayBlockers(pv, garageRoot, doorModel)
    for _,b in ipairs(blockers) do
        local topY = b.Position.Y + b.Size.Y * 0.5
        if topY > floorY + 0.1 then
            b.CanCollide = false
            table.insert(disabledCollision, b)
        end
    end
    print(string.format("[GarageDemo] doorway unblocked; disabled=%d", #disabledCollision))
end

local function restoreDoorwayColliders()
    local n = 0
    for _,b in ipairs(disabledCollision) do
        if b and b.Parent then b.CanCollide = true; n += 1 end
    end
    disabledCollision = {}
    print(string.format("[GarageDemo] doorway restored; reenabled=%d", n))
end

-- clean up any old roll-up artifacts anywhere
local function purgeDoorArtifacts()
    local removed = 0
    for _,x in ipairs(workspace:GetDescendants()) do
        local n = x.Name
        if (x:IsA("Model") and (n == "GD_DoorRollup" or n == "SimpleDoor"))
           or (x:IsA("BasePart") and (n == "GD_Door" or n:match("^Slat_%d+")
                                      or n == "GD_Frame" or n:match("^GD_Path_%d+$") or n == "GD_RimLight")) then
            x:Destroy(); removed += 1
        end
    end
    if removed > 0 then print("[GarageDemo] Purged artifacts:", removed) end
end

-- Raycast floor helper
local function detectFloorY(origin: Vector3): number
    local params = RaycastParams.new()
    params.FilterType = Enum.RaycastFilterType.Exclude
    params.FilterDescendantsInstances = {}
    local ray = workspace:Raycast(origin + Vector3.new(0,200,0), Vector3.new(0,-600,0), params)
    if ray then return ray.Position.Y end
    return 0
end

function M.run()
    local buildCount = (workspace:GetAttribute("GD_BUILD_COUNT") or 0) + 1
    workspace:SetAttribute("GD_BUILD_COUNT", buildCount)
    print("[GarageDemo] BUILD count=", buildCount)
    if workspace:GetAttribute("GD_GarageBuilt") then
        return
    end

    purgeDoorArtifacts()
    workspace:SetAttribute("GD_GarageBuilt", true)
    ensureLightingProfile()

    -- Opening faces +Z; inside = -Z
    local ORIGIN   = Vector3.new(24, 0, 12)
    local openingW = DOOR_W
    local openingH = DOOR_H
    local floorY   = detectFloorY(Vector3.new(ORIGIN.X, 100, ORIGIN.Z))
    local openingCenterY = floorY + (openingH * 0.5)
    local openCF   = CFrame.new(ORIGIN.X, openingCenterY, ORIGIN.Z + 6)
    local rightV, upV, inward = openCF.RightVector, openCF.UpVector, -openCF.LookVector
    local outward = -inward

    -- ===== Shell anchored to the door plane =====
    local WALL_T   = 0.5
    local SHELL_H  = math.max(openingH + 1.5, 8)
    local SHELL_W  = openingW + 8
    local SHELL_D  = math.max(12, openingW + 6)

    local root = Instance.new("Model"); root.Name="GD_Garage"; root.Parent=workspace

    local planeZ = openCF.Position.Z
    local center = openCF.Position
    local function placeBehindFrontFace(size: Vector3, frontMargin: number): CFrame
        return openCF * CFrame.new(0, 0, -(size.Z * 0.5 + frontMargin))
    end

    local interiorH = SHELL_H - WALL_T
    local backSize  = Vector3.new(SHELL_W, interiorH, WALL_T)
    local rearDepth = SHELL_D - (WALL_T * 0.5) + PLANE_MARGIN
    local backCF    = openCF * CFrame.new(0, (floorY + interiorH * 0.5) - openCF.Position.Y, -rearDepth)
    local back = part("GD_Back", root, backSize, backCF, {})
    stylePartGlass(back)
    local frontZ = back.CFrame.Position.Z + back.Size.Z*0.5
    print(string.format("[GarageDemo] back frontZ=%.3f planeZ=%.3f height=%.3f", frontZ, planeZ, back.Size.Y))

    local sideDepth = SHELL_D
    local leftSize  = Vector3.new(WALL_T, SHELL_H, sideDepth)
    local rightSize = Vector3.new(WALL_T, SHELL_H, sideDepth)
    local leftCF  = placeBehindFrontFace(leftSize,  PLANE_MARGIN) * CFrame.new(-(SHELL_W * 0.5 - WALL_T * 0.5), 0, 0)
    local rightCF = placeBehindFrontFace(rightSize, PLANE_MARGIN) * CFrame.new( (SHELL_W * 0.5 - WALL_T * 0.5), 0, 0)
    local left  = part("GD_Left",  root, leftSize,  leftCF,  {})
    local right = part("GD_Right", root, rightSize, rightCF, {})
    stylePartGlass(left); stylePartGlass(right)

    local roofSize = Vector3.new(SHELL_W, WALL_T, sideDepth)
    local roofCF   = placeBehindFrontFace(roofSize, PLANE_MARGIN) * CFrame.new(0, (SHELL_H - WALL_T) * 0.5, 0)
    local roof     = part("GD_Roof", root, roofSize, roofCF, {})
    stylePartGlass(roof)

    local GAP_DEPTH   = 1.20
    local floorSize   = Vector3.new(SHELL_W, 0.2, math.max(0.1, SHELL_D - GAP_DEPTH))
    local floorCF     = placeBehindFrontFace(floorSize, PLANE_MARGIN + GAP_DEPTH * 0.5) * CFrame.new(0, floorY + 0.1 - openCF.Position.Y, 0)
    local floorInt    = part("GD_FloorInterior", root, floorSize, floorCF, {})
    stylePartMetal(floorInt, THEME.floorMetal)

    local threshSize = Vector3.new(openingW, 0.2, GAP_DEPTH)
    local threshCF   = openCF * CFrame.new(0, (floorY + 0.1 - openCF.Position.Y), -(GAP_DEPTH * 0.5))
    local thresh     = part("GD_Threshold", root, threshSize, threshCF, {})
    thresh.CanCollide = false; thresh.Transparency = 1

    local apronSize = Vector3.new(openingW + 2.0, 0.2, 2.0)
    local apronCF   = openCF * CFrame.new(0, (floorY + 0.1 - openCF.Position.Y), 1.0)
    local apron     = part("GD_ApronOutside", root, apronSize, apronCF, {})
    stylePartMetal(apron, THEME.floorMetal)

    local function frontZ(p: BasePart) return p.CFrame.Position.Z + p.Size.Z * 0.5 end
    print(string.format("[GarageDemo] frontZ check: back=%.3f left=%.3f right=%.3f roof=%.3f floor=%.3f planeZ=%.3f",
        frontZ(back), frontZ(left), frontZ(right), frontZ(roof), frontZ(floorInt), planeZ))

    local railThk, railDepth = 0.12, 0.35
    local railH   = openingH + 0.05
    local railL = part("GD_RailL", root, Vector3.new(railThk, railH, railDepth), openCF * CFrame.new(-(openingW/2-railThk/2-0.02), 0, -railDepth/2), {})
    local railR = part("GD_RailR", root, Vector3.new(railThk, railH, railDepth), openCF * CFrame.new( (openingW/2-railThk/2-0.02), 0, -railDepth/2), {})
    stylePartMetal(railL, THEME.railMetal); stylePartMetal(railR, THEME.railMetal)
    railL.CanCollide = false
    railR.CanCollide = false
    local rails = {railL, railR}


    -- ===== Front Frame (visual only; non-colliding) =====
    -- Remove any prior frame group to avoid duplicates
    local oldFrame = root:FindFirstChild("GD_FrontFrame")
    if oldFrame then oldFrame:Destroy() end

    local frameGrp = Instance.new("Folder")
    frameGrp.Name = "GD_FrontFrame"
    frameGrp.Parent = root

    local FASCIA_BACK   = PLANE_MARGIN + 0.03
    local JAMB_THK      = 0.12
    local JAMB_DEPTH    = 0.40
    local LINTEL_THK    = 0.12
    local LINTEL_DEPTH  = 0.40
    local SILL_THK      = 0.10
    local SILL_DEPTH    = 0.40
    local lintelY       = center.Y + (openingH * 0.5)
    local sillY         = floorY + 0.05

    local function newTrim(name, size, cf)
        local p = Instance.new("Part")
        p.Name = name
        p.Parent = frameGrp
        p.Anchored = true
        p.CanCollide = false
        p.Material = Enum.Material.Metal
        p.Color = THEME.hoodMetal
        p.Size = size
        p.CFrame = cf
        return p
    end

    newTrim("GD_FrameJambL",
        Vector3.new(JAMB_THK, openingH + 0.05, JAMB_DEPTH),
        openCF * CFrame.new(-(openingW*0.5 - JAMB_THK*0.5 - 0.02), 0, -FASCIA_BACK)
    )

    newTrim("GD_FrameJambR",
        Vector3.new(JAMB_THK, openingH + 0.05, JAMB_DEPTH),
        openCF * CFrame.new( (openingW*0.5 - JAMB_THK*0.5 - 0.02), 0, -FASCIA_BACK)
    )

    newTrim("GD_FrameLintel",
        Vector3.new(openingW + 0.05, LINTEL_THK, LINTEL_DEPTH),
        openCF * CFrame.new(0, (lintelY - openCF.Position.Y) + 0.02, -FASCIA_BACK)
    )

    newTrim("GD_FrameSill",
        Vector3.new(openingW + 0.05, SILL_THK, SILL_DEPTH),
        openCF * CFrame.new(0, (sillY - openCF.Position.Y), -FASCIA_BACK)
    )

    print(string.format("[GarageDemo] front frame placed @back=%.3f", FASCIA_BACK))

    local hood = part("GD_Hood", root, Vector3.new(openingW + 0.2, 0.3, 1.6), CFrame.new(0,0,0), {})
    hood.Anchored = true; hood.CanCollide = false; hood.Material = Enum.Material.Metal
    hood.Color = THEME.hoodMetal; hood.Transparency = 0.15
    local lintelY = openCF.Position.Y + (openingH * 0.5)
    local hoodBehind  = (hood.Size.Z * 0.5) + PLANE_MARGIN
    hood.CFrame = openCF * CFrame.new(0, (lintelY - openCF.Position.Y) + 0.15, -hoodBehind)
    print("[GarageDemo] planeZ=", planeZ, " hoodFrontZ=", (hood.CFrame.Position.Z + hood.Size.Z*0.5))

    local hoodDepth, hoodHeight = 1.6, 0.7

    -- Door model + slats
    local door      = Instance.new("Model"); door.Name="GD_DoorRollup"; door.Parent=root
    local slatDepth = 0.30
    local doorCenter    = (openCF * CFrame.new(0,0,-0.05)).Position
    local halfH     = openingH/2
    local slatH     = openingH / N_SLATS
    local function withFrame(pos: Vector3) return cfFromBasis(pos, rightV, upV, outward) end

    for i=1,N_SLATS do
        local s = Instance.new("Part"); s.Name=string.format("Slat_%02d", i); s.Parent=door
        s.Anchored=true; s.CanCollide=true
        stylePartMetal(s, THEME.doorMetal)
        s.Size = Vector3.new(openingW, slatH, slatDepth)
        local y = (-halfH) + slatH*(i-0.5)
        s.CFrame = withFrame(doorCenter + upV*y)
    end
    print("[GarageDemo] Slats built:", N_SLATS, "slatHeight:", slatH)

    -- Auto-fit stack to hood
    local stackStep   = 0.05
    local maxInside   = (hoodDepth/2) - 0.08
    local totalStack  = (N_SLATS-1) * stackStep
    if totalStack > (maxInside - 0.25) then
        stackStep  = math.max(0.03, (maxInside - 0.25) / math.max(1, (N_SLATS-1)))
        totalStack = (N_SLATS-1) * stackStep
    end
    local baseBack    = math.clamp(maxInside - totalStack, 0.25, 1.50)
    print(("[GarageDemo] clamp: hoodDepth=%.2f baseBack=%.3f stackStep=%.3f totalStack=%.3f maxInside=%.3f")
          :format(hoodDepth, baseBack, stackStep, totalStack, maxInside))

    -- Phase split: lift to lintel, then translate back under hood
    local LIFT_SPLIT = 0.60

    local function cfAlong(t: number, i: number): CFrame
        -- per-slat base Y (closed): bottom slat at −halfH, top slat at +halfH−slatH
        local baseY = -halfH + slatH * (i - 0.5)
        -- per-slat lintel target: top plane where the sheet should end the lift
        local targetYAtLintel = halfH - slatH * 0.5

        if t <= LIFT_SPLIT then
            -- PHASE 1: lift the curtain so each slat rises exactly to the lintel plane
            local v = t / LIFT_SPLIT
            local y = baseY + v * (targetYAtLintel - baseY)
            local pos = doorCenter + upV * y
            return CFrame.fromMatrix(pos, rightV, upV, outward)
        else
            -- PHASE 2: curl / translate back inside the hood
            local c = (t - LIFT_SPLIT) / (1 - LIFT_SPLIT)

            if MOVE_AS_SHEET then
                -- Entire sheet moves as one unit: keep lintel Y, translate inward uniformly
                local y = targetYAtLintel + 0.05 * c
                local back = c * baseBack
                local pos = doorCenter + upV * y + inward * back
                return CFrame.fromMatrix(pos, rightV, upV, outward)
            else
                -- (Optional) roll/stack variant: add per-slat inward offset
                local y = targetYAtLintel + 0.05 * c
                local back_i = math.min(baseBack + (i - 1) * stackStep, maxInside)
                local pos = doorCenter + upV * y + inward * back_i
                return CFrame.fromMatrix(pos, rightV, upV, outward)
            end
        end
    end

    local passage = ensurePassageVolume(root, openCF, openingW, openingH)

    print(string.format("[GarageDemo] path proof: slatH=%.3f targetYAtLintel=%.3f",
        slatH, (halfH - slatH * 0.5)))

    -- Param driver (no CFrame tween; no tilt)
    local conns, drivers = {}, {}
    local function clearDrivers()
        for _,c in ipairs(conns) do pcall(function() c:Disconnect() end) end
        for _,v in ipairs(drivers) do pcall(function() v:Destroy() end) end
        table.clear(conns); table.clear(drivers)
    end
    local function animate(opening:boolean)
        clearDrivers()
        local slats = {}
        for i=1,N_SLATS do slats[i] = door:FindFirstChild(string.format("Slat_%02d", i)) end
        if not opening then table.sort(slats, function(a,b) return a.Name > b.Name end) end
        local duration, stagger = 1.1, STAGGER
        local startT = opening and 0 or 1
        local endT   = opening and 1 or 0

        -- Collider policy: allow entry as soon as opening begins
        if opening then
            for _,s in ipairs(slats) do s.CanCollide = false end
            disableDoorwayColliders(passage, root, door, floorY)
        end

        -- Snap to START pose for clean motion
        for i,s in ipairs(slats) do
            s.CFrame = cfAlong(startT, i)
            local u = Instance.new("NumberValue"); u.Name="u"; u.Value = startT; u.Parent = s
            table.insert(drivers, u)
            table.insert(conns, RunService.Heartbeat:Connect(function() s.CFrame = cfAlong(u.Value, i) end))
            TweenService:Create(u, TweenInfo.new(duration, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, 0, false, (i-1)*stagger),
                {Value = endT}):Play()
        end

        task.delay(duration + (#slats*stagger) + 0.05, function()
            for i,s in ipairs(slats) do
                s.CanCollide = (not opening)
                s.CFrame = cfAlong(endT, i)
            end
            if opening then
                sanitizeMouth(openCF, openingW, openingH, root, door, {railL, railR}, handle, hood)
                forceClearMouth(openCF, openingW, openingH, floorY, root, door, hood, {railL, railR}, handle)
                removeMidDoorHeaders(openCF, openingW, openingH, floorY, root, door, {railL, railR}, handle)
            else
                restoreDoorwayColliders()
            end
            clearDrivers()
        end)
    end

    -- Handle (non-blocking) + ProximityPrompt
    local handle = part("GD_Handle", root, Vector3.new(0.5,1.2,0.5), openCF * CFrame.new(0,0,-2), {})
    handle.CanCollide   = false
    handle.Transparency = 1
    for _,d in ipairs(handle:GetDescendants()) do if d:IsA("ProximityPrompt") then d:Destroy() end end
    local pp = Instance.new("ProximityPrompt", handle)
    pp.ObjectText="Garage Access"; pp.ActionText="Toggle Door"; pp.KeyboardKeyCode=Enum.KeyCode.F
    pp.HoldDuration=0; pp.RequiresLineOfSight=false; pp.MaxActivationDistance=18

    if ENABLE_RIM then
        ensureRimLight(root, openCF * CFrame.new(0, 1.2, -2))
    end

    local spawn = workspace:FindFirstChildOfClass("SpawnLocation")
    if ENABLE_NEON and spawn then
        ensureNeonPath(spawn.CFrame, openCF, root)
    end

    sanitizeMouth(openCF, openingW, openingH, root, door, rails, handle, hood)
    forceClearMouth(openCF, openingW, openingH, floorY, root, door, hood, rails, handle)
    -- remove any additional mid-door headers that still appear
    removeMidDoorHeaders(openCF, openingW, openingH, floorY, root, door, rails, handle)

    do
        local models, slats = 0, 0
        for _,x in ipairs(workspace:GetDescendants()) do
            if x:IsA("Model") and x.Name=="GD_DoorRollup" then models += 1 end
            if x:IsA("BasePart") and x.Name:match("^Slat_%d+") then slats += 1 end
        end
        print(string.format("[GarageDemo] post-check: doorModels=%d slats=%d", models, slats))
    end

    -- Single F-toggle with 300ms debounce
    local untilT = 0.0
    pp.Triggered:Connect(function(player)
        local t = os.clock(); if t < untilT then print("[GarageDemo] debounced"); return end; untilT = t + 0.30
        local opening = (door:GetAttribute("IsOpen") ~= true)
        door:SetAttribute("IsOpen", opening)
        print(("[GarageDemo] PROMPT toggle %s -> %s"):format(player and player.Name or "?", opening and "OPEN" or "CLOSE"))
        animate(opening)
    end)

    print("✅ GarageDemo ready (styled walls/door/floor + lighting)")
end

return M
