--!strict
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")

local M = {} ; M.VERSION = "greset-v2-"..tostring(os.time())
print("🚪 GarageReset v2 ACTIVE", M.VERSION)

local function ensureModel(parent: Instance, name: string): Model
    local m = parent:FindFirstChild(name)
    if not (m and m:IsA("Model")) then
        if m then m:Destroy() end
        m = Instance.new("Model"); m.Name = name; m.Parent = parent
    end
    return m
end

function M.run()
    -- Clean area (no name guessing): remove Neon/very thin parts within 80 studs of pivot
    local pivot = Vector3.new(28, 0.5, 0)
    local removed = 0
    for _, inst in ipairs(workspace:GetDescendants()) do
        if inst:IsA("BasePart") and (inst.Position - pivot).Magnitude <= 80 then
            local s = inst.Size
            local thin = (s.X<=0.6 or s.Y<=0.6 or s.Z<=0.6)
            if inst.Material == Enum.Material.Neon or thin then
                if not inst:IsDescendantOf(workspace:FindFirstChild("Garage") or Instance.new("Folder")) then
                    pcall(function() inst:Destroy(); removed += 1 end)
                end
            end
        end
    end
    print(("[v2] Debris cleaned: %d"):format(removed))

    -- Build minimal prefab
    local Garage = ensureModel(workspace, "Garage")
    local floor = Garage:FindFirstChild("Floor") :: BasePart?
    if not floor then
        floor = Instance.new("Part"); floor.Name="Floor"; floor.Size=Vector3.new(10,0.2,10)
        floor.Anchored=true; floor.Material=Enum.Material.Metal; floor.Color=Color3.fromRGB(45,50,56); floor.Parent=Garage
    end
    floor.CFrame = CFrame.new(pivot)

    local frame = Garage:FindFirstChild("DoorFrame") :: BasePart?
    if not frame then frame = Instance.new("Part"); frame.Name="DoorFrame"; frame.Parent=Garage end
    frame.Anchored=true; frame.CanCollide=false; frame.Size=Vector3.new(6,6,0.2)
    frame.CFrame = CFrame.new(28,3,5)

    local console = Garage:FindFirstChild("GarageConsole")
    if not (console and console:IsA("Model")) then console = Instance.new("Model"); console.Name="GarageConsole"; console.Parent=Garage end
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

    -- Simple door (one Part) to prove toggle/animation; replace with slats later
    local door = Garage:FindFirstChild("Door") :: BasePart?
    if not door then
        door = Instance.new("Part"); door.Name="Door"; door.Parent=Garage
        door.Anchored=true; door.CanCollide=true; door.Material=Enum.Material.Metal; door.Color=Color3.fromRGB(130,190,255)
        door.Size = Vector3.new(6,6,0.3)
    end
    door.CFrame = frame.CFrame * CFrame.new(0,0,-0.3)

    -- Toggle: slide up by 6 studs and back by 3 studs (open), reverse to close
    door:SetAttribute("IsOpen", false)
    local function tween(cf: CFrame)
        TweenService:Create(door, TweenInfo.new(0.8, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {CFrame = cf}):Play()
    end
    if pp then
        pp.Triggered:Connect(function(player)
            local open = not (door:GetAttribute("IsOpen")==true)
            door:SetAttribute("IsOpen", open)
            print(("[v2] Prompt by %s → %s"):format(player and player.Name or "?", open and "OPEN" or "CLOSE"))
            if open then
                tween(frame.CFrame * CFrame.new(0,3, -3))  -- up & back
                door.CanCollide = false
            else
                tween(frame.CFrame * CFrame.new(0,0, -0.3)) -- down & front
                task.delay(0.85, function() door.CanCollide = true end)
            end
        end)
    end
end

return M
