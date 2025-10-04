--!strict
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")

local M = {} ; M.VERSION = "rc-greset-"..tostring(os.time())
print("🚪 RC_GarageReset ACTIVE", M.VERSION)

local function ensureModel(parent: Instance, name: string): Model
    local m = parent:FindFirstChild(name)
    if not (m and m:IsA("Model")) then
        if m then m:Destroy() end
        m = Instance.new("Model"); m.Name = name; m.Parent = parent
    end
    return m
end

-- one-time local cleanup (neon/thin parts within 80 studs of pivot, excluding our Garage)
local function cleanDebris(pivot: Vector3, radius: number, garageRoot: Instance?)
    local removed = 0
    local function thin(p: BasePart)
        local s = p.Size; return (s.X<=0.6 or s.Y<=0.6 or s.Z<=0.6)
    end
    for _, inst in ipairs(workspace:GetDescendants()) do
        if inst:IsA("BasePart") and (not garageRoot or not inst:IsDescendantOf(garageRoot)) then
            if (inst.Position - pivot).Magnitude <= radius then
                local n = inst.Name:lower()
                local looks = inst.Material == Enum.Material.Neon or thin(inst) or n:find("runway") or n:find("padtrim") or n:find("connector") or n:find("beacon")
                local protect = n:find("groundplatform") or n:find("wall") or n:find("terrain")
                if looks and not protect then pcall(function() inst:Destroy(); removed += 1 end) end
            end
        end
    end
    print(string.format("[RC] Debris cleaned: %d (r=%d)", removed, radius))
end

function M.run()
    local pivot = Vector3.new(28, 0.5, 0)
    cleanDebris(pivot, 80, nil)

    local Garage = ensureModel(workspace, "Garage")

    -- Floor
    local floor = Garage:FindFirstChild("RC_Floor") :: BasePart?
    if not floor then
        floor = Instance.new("Part"); floor.Name="RC_Floor"; floor.Size=Vector3.new(10,0.2,10)
        floor.Anchored=true; floor.Material=Enum.Material.Metal; floor.Color=Color3.fromRGB(45,50,56); floor.Parent=Garage
    end
    floor.CFrame = CFrame.new(pivot)

    -- DoorFrame (simple forward facing)
    local frame = Garage:FindFirstChild("RC_DoorFrame") :: BasePart?
    if not frame then frame = Instance.new("Part"); frame.Name="RC_DoorFrame"; frame.Parent=Garage end
    frame.Anchored=true; frame.CanCollide=false; frame.Size=Vector3.new(6,6,0.2)
    frame.CFrame = CFrame.new(28,3,5)

    -- Console + handle
    local console = Garage:FindFirstChild("RC_GarageConsole")
    if not (console and console:IsA("Model")) then console = Instance.new("Model"); console.Name="RC_GarageConsole"; console.Parent=Garage end
    local base = console:FindFirstChild("Base") :: BasePart?
    if not base then base = Instance.new("Part"); base.Name="Base"; base.Size=Vector3.new(2.5,1,2); base.Parent=console end
    base.Anchored=true; base.Material=Enum.Material.Metal; base.Color=Color3.fromRGB(60,70,78)
    base.CFrame = CFrame.new(28,0.5,2) ; console.PrimaryPart = base

    local handle = console:FindFirstChild("DoorHandle") :: BasePart?
    if not handle then handle = Instance.new("Part"); handle.Name="DoorHandle"; handle.Size=Vector3.new(0.5,1.2,0.5); handle.Parent=console end
    handle.Anchored=true; handle.CanCollide=false; handle.CFrame = frame.CFrame * CFrame.new(0,0,-2)

    for _,d in ipairs(handle:GetDescendants()) do if d:IsA("ProximityPrompt") then d:Destroy() end end
    local pp = Instance.new("ProximityPrompt", handle)
    pp.ObjectText="Garage Access"; pp.ActionText="Toggle Door"; pp.KeyboardKeyCode=Enum.KeyCode.F
    pp.HoldDuration=0; pp.RequiresLineOfSight=false; pp.MaxActivationDistance=18

    -- Single-part door to prove toggle; we can swap for slats later
    local door = Garage:FindFirstChild("RC_Door") :: BasePart?
    if not door then
        door = Instance.new("Part"); door.Name="RC_Door"; door.Parent=Garage
        door.Anchored=true; door.CanCollide=true; door.Material=Enum.Material.Metal; door.Color=Color3.fromRGB(130,190,255)
        door.Size = Vector3.new(6,6,0.3)
    end
    door.CFrame = frame.CFrame * CFrame.new(0,0,-0.3)

    -- Toggle handler
    local remotes = ReplicatedStorage:FindFirstChild("Remotes")
    local toggle  = remotes and remotes:FindFirstChild("RC_ToggleGarageDoor")
    if toggle and toggle:IsA("RemoteEvent") then
        toggle.OnServerEvent:Connect(function(player)
            local open = not (door:GetAttribute("IsOpen")==true)
            door:SetAttribute("IsOpen", open)
            print(("[RC] Toggle from %s → %s"):format(player and player.Name or "?", open and "OPEN" or "CLOSE"))
            local openCF = frame.CFrame * CFrame.new(0,3,-3)   -- up & back
            local closeCF= frame.CFrame * CFrame.new(0,0,-0.3) -- down & front
            local info = TweenInfo.new(0.8, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut)
            TweenService:Create(door, info, {CFrame = open and openCF or closeCF}):Play()
            if open then door.CanCollide = false else task.delay(0.85, function() door.CanCollide = true end) end
        end)
    else
        -- also wire the Prompt directly as a fallback
        if pp then
            pp.Triggered:Connect(function(player)
                local r = ReplicatedStorage:FindFirstChild("Remotes")
                local t = r and r:FindFirstChild("RC_ToggleGarageDoor")
                if t and t:IsA("RemoteEvent") then t:FireServer() end
            end)
        end
    end

    -- delayed second cleanup (to beat any late-spawned junk)
    task.delay(0.5, function() cleanDebris((Garage.PrimaryPart and Garage.PrimaryPart.Position) or pivot, 80, Garage) end)
end

return M
