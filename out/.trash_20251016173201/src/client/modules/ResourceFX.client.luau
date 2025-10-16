--!strict
-- File: ResourceFX.client.luau
-- v0.6.0-alpha — Collection feedback FX
-- Autoloaded LocalScript. Listens to CollectedFX and plays a short particle/light cue.
-- Idempotent and self-contained; echoes first ~60 lines.

print("🏗️ ResourceFX.client.luau ACTIVE", os.time())

--// Services
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local Debris = game:GetService("Debris")

local player = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()

--// Remotes
local RC_Remotes = ReplicatedStorage:WaitForChild("RC_Remotes")
local Missions = RC_Remotes:WaitForChild("Missions")
local CollectedFX = Missions:WaitForChild("CollectedFX")

-- Utility: find nearest BasePart matching resource type hint
local function findNearestNode(resourceType: string, origin: Vector3, radius: number)
	local bestPart: BasePart? = nil
	local bestDist = radius

	local hint = resourceType:lower()

	for _, inst in ipairs(workspace:GetDescendants()) do
		if inst:IsA("BasePart") then
			local nameLower = inst.Name:lower()
			if string.find(nameLower, "scrap") or string.find(nameLower, "crystal") or string.find(nameLower, hint) then
				local d = (inst.Position - origin).Magnitude
				if d < bestDist then
					bestDist = d
					bestPart = inst
				end
			end
		end
	end

	return bestPart
end

local function pulseAt(part: BasePart?)
	-- Clean up any existing RC_FX from previous runs
	for _, gui in ipairs(workspace:GetDescendants()) do
		if gui:IsA("BillboardGui") and gui.Name == "RC_FX" then
			gui:Destroy()
		end
	end
	local guiRoot = Instance.new("BillboardGui")
	guiRoot.Name = "RC_FX"
	guiRoot.Size = UDim2.fromOffset(40, 40)
	guiRoot.LightInfluence = 0
	guiRoot.AlwaysOnTop = true
	guiRoot.StudsOffset = Vector3.new(0, 2.2, 0)

	local dot = Instance.new("Frame")
	dot.Name = "Dot"
	dot.Size = UDim2.fromScale(1, 1)
	dot.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	dot.BackgroundTransparency = 0.2
	dot.BorderSizePixel = 0
	dot.Parent = guiRoot

	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(1, 0)
	corner.Parent = dot

	if part then
		guiRoot.Adornee = part
		guiRoot.Parent = part
	else
		-- Skip FX if we couldn’t find a valid part to attach to
		Debris:AddItem(guiRoot, 0)
		return
	end

	local fadeIn = TweenService:Create(dot, TweenInfo.new(0.12, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
		BackgroundTransparency = 0,
	})
	local fadeOut = TweenService:Create(dot, TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
		BackgroundTransparency = 1,
	})

	fadeIn:Play()
	fadeIn.Completed:Wait()
	fadeOut:Play()

	Debris:AddItem(guiRoot, 0.6)

	if part then
		local light = Instance.new("PointLight")
		light.Name = "RC_FX_Light"
		light.Range = 10
		light.Brightness = 0
		light.Color = Color3.fromRGB(255, 240, 180)
		light.Parent = part

		local up = TweenService:Create(light, TweenInfo.new(0.08, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
			Brightness = 3,
		})
		local down = TweenService:Create(light, TweenInfo.new(0.18, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
			Brightness = 0,
		})

		up:Play()
		up.Completed:Wait()
		down:Play()

		Debris:AddItem(light, 0.5)
	end
end

CollectedFX.OnClientEvent:Connect(function(payload)
	if typeof(payload) ~= "table" then
		return
	end

	local resourceType = tostring(payload.resourceType or "Scrap")

	local origin: Vector3
	local hrp = character:FindFirstChild("HumanoidRootPart")
	if hrp and hrp:IsA("BasePart") then
		origin = hrp.Position
	else
		local camera = workspace.CurrentCamera
		if camera then
			origin = camera.CFrame.Position
		else
			origin = Vector3.zero
		end
	end

	local node = findNearestNode(resourceType, origin, 60)
	pulseAt(node)
end)

-- === ECHO (first ~60 lines) ==================================================
do
	local ok, src = pcall(function()
		return script.Source
	end)
	if ok and typeof(src) == "string" then
		local n = 0
		for line in string.gmatch(src, "([^\n]*)\n?") do
			n += 1
			print(("[ResourceFX:%02d] %s"):format(n, line))
			if n >= 60 then
				break
			end
		end
	end
end
