local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")

local M = {}
M.VERSION = "greset-full-"..tostring(os.time())
print("🚪 GarageReset ACTIVE", M.VERSION)

-- helpers
local function ensureModel(parent: Instance, name: string): Model
    local m = parent:FindFirstChild(name)
    if not (m and m:IsA("Model")) then
        if m then m:Destroy() end
        m = Instance.new("Model"); m.Name = name; m.Parent = parent
    end
    return m
end

local function unitXZ(v: Vector3): Vector3
    local u = Vector3.new(v.X,0,v.Z)
    return (u.Magnitude < 1e-4) and Vector3.new(0,0,1) or u.Unit
end

local function cleanDebris(pivot: Vector3, radius: number, garageRoot: Instance?)
    local removed = 0
    local function isThin(p: BasePart): boolean
        local s = p.Size
        return (s.X <= 0.6) or (s.Y <= 0.6) or (s.Z <= 0.6)
    end
    for _, inst in ipairs(workspace:GetDescendants()) do
        if inst:IsA("BasePart") and (not garageRoot or not inst:IsDescendantOf(garageRoot)) then
            local pos = inst.Position
            if (pos - pivot).Magnitude <= radius then
                local n = inst.Name:lower()
                local looks =
                    inst.Material == Enum.Material.Neon
                    or isThin(inst)
                    or n:find("runway")
                    or n:find("padtrim")
                    or n:find("connector")
                    or n:find("beacon")

                local protect =
                    n:find("groundplatform")
                    or n:find("wall")
                    or n:find("terrain")

                if looks and not protect then
                    print("[GarageReset] Removing debris:", inst:GetFullName())
                    pcall(function()
                        inst:Destroy()
                    end)
                    removed += 1
                end
            end
        end
    end
    print(string.format("[GarageReset] Debris cleaned: %d (r=%d)", removed, radius))
end

function M.run()
    -- center (GameConstants if present)
    local CENTER = Vector3.new(0,0,0)
    local ok, GC = pcall(function() return require(ReplicatedStorage.Shared.config.GameConstants) end)
    if ok and GC and GC.CENTER_POS then CENTER = GC.CENTER_POS end

    -- pivot (reuse if exists)
    local pivot = Vector3.new(28, 0.5, 0)
    local existing = workspace:FindFirstChild("Garage")
    if existing and existing:IsA("Model") then
        pivot = (existing.PrimaryPart and existing.PrimaryPart.Position) or existing:GetPivot().Position
    end

    cleanDebris(pivot, 80, existing)

    -- basis
    local outward = unitXZ(pivot - CENTER)
    local up      = Vector3.new(0,1,0)
    local right   = up:Cross(outward).Unit

    -- root + floor
    local Garage = ensureModel(workspace, "Garage")
    local floor = Garage:FindFirstChild("Floor") :: BasePart?
    if not floor then
        floor = Instance.new("Part"); floor.Name="Floor"; floor.Size=Vector3.new(10,0.2,10)
        floor.Anchored=true; floor.Material=Enum.Material.Metal; floor.Color=Color3.fromRGB(45,50,56)
        floor.Parent=Garage
    end
    floor.CFrame = CFrame.new(pivot)

    -- frame (6x6) facing outward
    local frame = Garage:FindFirstChild("DoorFrame") :: BasePart?
    if not frame then
        frame = Instance.new("Part"); frame.Name="DoorFrame"; frame.Anchored=true; frame.CanCollide=false; frame.Parent=Garage
    end
    frame.Size = Vector3.new(6,6,0.2)
    frame.CFrame = CFrame.fromMatrix(pivot + outward*(floor.Size.Z/2 - 0.1) + up*3, right, up, outward)

    -- console + handle + prompt (2 studs out)
    local console = Garage:FindFirstChild("GarageConsole")
    if not (console and console:IsA("Model")) then console = Instance.new("Model"); console.Name="GarageConsole"; console.Parent=Garage end
    local base = console:FindFirstChild("Base") :: BasePart?
    if not base then base = Instance.new("Part"); base.Name="Base"; base.Size=Vector3.new(2.5,1,2); base.Parent=console end
    base.Anchored=true; base.Material=Enum.Material.Metal; base.Color=Color3.fromRGB(60,70,78)
    base.CFrame = CFrame.fromMatrix(pivot + up*0.5 + outward*(floor.Size.Z/2 - 3), right, up, outward)
    console.PrimaryPart = base

    local handle = console:FindFirstChild("DoorHandle") :: BasePart?
    if not handle then handle = Instance.new("Part"); handle.Name="DoorHandle"; handle.Size=Vector3.new(0.5,1.2,0.5); handle.Parent=console end
    handle.Anchored=true; handle.CanCollide=false
    handle.CFrame = CFrame.fromMatrix(frame.CFrame.Position + outward*2 + up*1.2, right, up, outward)
    for _,d in ipairs(handle:GetDescendants()) do if d:IsA("ProximityPrompt") then d:Destroy() end end
    local pp = Instance.new("ProximityPrompt", handle)
    pp.ObjectText="Garage Access"; pp.ActionText="Toggle Door"; pp.KeyboardKeyCode=Enum.KeyCode.F
    pp.HoldDuration=0; pp.RequiresLineOfSight=false; pp.MaxActivationDistance=18
    if pp and pp:IsA("ProximityPrompt") then
        pp.Triggered:Connect(function(player)
            print(("[GarageReset] Prompt triggered by %s"):format(player and player.Name or "unknown"))
            local DoorModel = Garage:FindFirstChild("GarageDoor")
            if DoorModel then
                DoorModel:SetAttribute("IsOpen", not (DoorModel:GetAttribute("IsOpen") == true))
            else
                warn("[GarageReset] No GarageDoor model to toggle")
            end
        end)
    end

    -- door model (clear old slats/track only)
    local Door = Garage:FindFirstChild("GarageDoor")
    if not (Door and Door:IsA("Model")) then Door = Instance.new("Model"); Door.Name="GarageDoor"; Door.Parent=Garage end
    for _,c in ipairs(Door:GetChildren()) do if c:IsA("BasePart") or c:IsA("Attachment") then c:Destroy() end end

    -- build 12 slats aligned to frame
    local FCF = frame.CFrame
    local rightV, upV, fwdV = FCF.RightVector, FCF.UpVector, FCF.LookVector
    local width, height = frame.Size.X, frame.Size.Y
    local depth, offset = 0.3, 0.6
    local center = FCF.Position + (-fwdV * offset)

    local nSlats, hPer = 12, height/12
    for i=1,nSlats do
        local s = Instance.new("Part"); s.Name = string.format("Slat_%02d", i)
        s.Anchored=true; s.Size=Vector3.new(width,hPer,depth); s.Material=Enum.Material.Metal
        s.Color=Color3.fromRGB(130,190,255); s.Parent=Door
        local y = (-height/2) + (hPer*(i-0.5))
        local pos = center + upV*y
        s.CFrame = CFrame.fromMatrix(pos, rightV, upV, fwdV)
    end
    print("[GarageReset] Slats built: 12")

    -- Count and log slats so we know this path executed
    do
        local count = 0
        local proofDoor = Garage:FindFirstChild("GarageDoor")
        if proofDoor then
            for _, c in ipairs(proofDoor:GetChildren()) do
                if c:IsA("BasePart") and c.Name:match("^Slat_") then
                    count += 1
                end
            end
        end
        print(string.format("[GarageReset] Slats built (proof): %d", count))
    end

    -- path attachments A0..A4
    local track = Instance.new("Part"); track.Name="Track"; track.Anchored=true; track.CanCollide=false; track.Transparency=1
    track.Size=Vector3.new(0.5,0.5,0.5); track.Parent=Door
    local function att(name, pos: Vector3) local a=Instance.new("Attachment"); a.Name=name; a.Parent=track; a.WorldPosition=pos; return a end
    local back = 3.0
    local A0 = center + upV * (-height/2 + 0.10)
    local A1 = center + upV * ( height/2 + 0.00)
    local A2 = A1 + (-fwdV * (back * 0.5))
    local A3 = A1 + (-fwdV *  back)
    local A4 = A3 + upV * 0.10
    att("A0",A0); att("A1",A1); att("A2",A2); att("A3",A3); att("A4",A4)

    -- tween helper
    local function cfAlong(t: number): CFrame
        local pts = {A0,A1,A2,A3,A4}
        local seg = math.clamp(math.floor(t*4)+1,1,4)
        local lt  = (t*4)-(seg-1)
        local pA, pB = pts[seg], pts[seg+1]
        local pos = pA:Lerp(pB, lt)
        local nxt = (lt < 0.9) and pA:Lerp(pB, lt+0.1) or pB
        return CFrame.lookAt(pos, nxt, upV)
    end

    Door:SetAttribute("IsOpen", false)
    Door:SetAttribute("Moving", false)

    local function animate(opening: boolean)
        if Door:GetAttribute("Moving") then return end
        Door:SetAttribute("Moving", true)
        local duration, stagger = 1.2, 0.06
        local slats = {}
        for i=1,12 do slats[i] = Door:FindFirstChild(string.format("Slat_%02d", i)) :: BasePart end
        if not opening then table.sort(slats, function(a,b) return a.Name > b.Name end) end
        for idx, s in ipairs(slats) do
            local startT, endT = opening and 0 or 1, opening and 1 or 0
            s.CFrame = cfAlong(startT)
            local info = TweenInfo.new(duration, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, 0, false, (idx-1)*stagger)
            TweenService:Create(s, info, {CFrame = cfAlong(endT)}):Play()
        end
        task.delay(duration + #slats*stagger + 0.05, function()
            for _,s in ipairs(slats) do s.CanCollide = not opening end
            Door:SetAttribute("Moving", false)
        end)
    end

    if not Door:GetAttribute("ListenerBound") then
        Door:SetAttribute("ListenerBound", true)
        Door:GetAttributeChangedSignal("IsOpen"):Connect(function()
            local target = Door:GetAttribute("IsOpen") == true
            print(("[GarageReset] Animating %s"):format(target and "OPEN" or "CLOSE"))
            animate(target)
        end)
    end

    -- remote toggle
    local remotes = ReplicatedStorage:FindFirstChild("Remotes")
    local toggle  = remotes and remotes:FindFirstChild("ToggleGarageDoor")
    if toggle and toggle:IsA("RemoteEvent") then
        toggle.OnServerEvent:Connect(function(player)
            print(("[GarageReset] Toggle request from %s"):format(player.Name))
            Door:SetAttribute("IsOpen", not (Door:GetAttribute("IsOpen")==true))
        end)
    else
        warn("[GarageReset] Missing ToggleGarageDoor")
    end

    Garage.PrimaryPart = floor
    Garage:PivotTo(CFrame.new(pivot))

    -- Run a quick post-setup cleanup on the next tick
    task.delay(1.0, function()
        local g = workspace:FindFirstChild("Garage")
        local postPivot = (g and (g.PrimaryPart and g.PrimaryPart.Position or g:GetPivot().Position)) or pivot
        cleanDebris(postPivot, 80, g)
    end)
end

return M
