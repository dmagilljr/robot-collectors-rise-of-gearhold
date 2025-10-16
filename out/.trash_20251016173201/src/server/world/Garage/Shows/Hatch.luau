

--!strict
local TweenService = game:GetService("TweenService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local HatchShow = {}

type Options = {
	player: Player?,
	rarity: string?,
	name: string?,
}

-- helper to create/ensure a part under a group with optional Neon material
local function ensurePart(grp: Instance, name: string, size: Vector3, cf: CFrame, color: Color3, neon: boolean?): BasePart
	local p = grp:FindFirstChild(name)
	if not (p and p:IsA("BasePart")) then
		p = Instance.new("Part")
		p.Name = name
		p.Parent = grp
	end
	local bp = p :: BasePart
	bp.Anchored = true
	bp.CanCollide = false
	bp.Material = neon and Enum.Material.Neon or Enum.Material.SmoothPlastic
	bp.Color = color
	bp.Size = size
	bp.CFrame = cf
	return bp
end

-- small helper
local function tween(p: Instance, ti: TweenInfo, props: {[string]: any})
	local t = TweenService:Create(p, ti, props)
	t:Play()
	return t
end

-- Garage model lives at ServerScriptService/World/Garage with ModelRef → workspace model
local function getGarageModel(): Model?
	local garageFolder = script.Parent and script.Parent.Parent
	if not garageFolder then return nil end
	local modelRef = garageFolder:FindFirstChild("ModelRef")
	if modelRef and modelRef:IsA("ObjectValue") then
		local m = (modelRef :: any).Value
		if m and typeof(m) == "Instance" and (m :: Instance):IsA("Model") then
			return (m :: any) :: Model
		end
	end
	return nil
end

-- Resolve pad parts from GD_SpawnPad
local function getPadParts(model: Model)
	local padGrp = model:FindFirstChild("GD_SpawnPad", true)
	if not padGrp or not padGrp:IsA("Model") then return nil end
	local function gp(name: string): BasePart?
		local inst = padGrp:FindFirstChild(name)
		return (inst and inst:IsA("BasePart")) and (inst :: BasePart) or nil
	end
	return padGrp :: Model, gp("Pad"), gp("RingTop"), gp("RingBottom"), gp("RimGlow"), gp("Ramp")
end

-- Rarity palette
local rarityColors = {
	common    = Color3.fromRGB(120,170,255),
	rare      = Color3.fromRGB(170,120,255),
	legendary = Color3.fromRGB(255,200,80),
}

function HatchShow.run(opts: Options?)
	local model = getGarageModel()
	if not model then return end
	local padGrp, pad, ringT, ringB, rim, ramp = getPadParts(model)
	if not (padGrp and pad and ringT and ringB and rim and ramp) then return end

	local rarity = (opts and opts.rarity) or "common"
	local col    = rarityColors[rarity] or rarityColors.common

	local tiFast  = TweenInfo.new(0.35, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
	local tiPulse = TweenInfo.new(0.4,  Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, 4, true)

	-- 0.0s: quick pre-roll flash on rim before beam
	if rim then
		rim.Transparency = 0.0
		TweenService:Create(rim, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out, 0, true), { Transparency = 0.4 }):Play()
	end

	-- 0.0s: beam on + brighten rings
	padGrp:SetAttribute("LaserEnabled", true)
	tween(ringT, tiFast, { Color = col, Transparency = 0.0 })
	tween(ringB, tiFast, { Color = col, Transparency = 0.0 })
	tween(rim,   tiFast, { Color = col, Transparency = 0.0 })

	-- 1.2s: pulse rings
	task.delay(1.2, function()
		if ringT then TweenService:Create(ringT, tiPulse, { Transparency = 0.15 }):Play() end
		if ringB then TweenService:Create(ringB, tiPulse, { Transparency = 0.15 }):Play() end
		if rim   then TweenService:Create(rim,   tiPulse, { Transparency = 0.02 }):Play() end
	end)

	-- 1.4s: BillboardGui scanner ring (always circular), sweeps down & up
	local padCenter = (pad :: BasePart).Position
	-- Anchor part for BillboardGui
	local scanAnchor = padGrp:FindFirstChild("ScanBillboardAnchor")
	if not scanAnchor then
		scanAnchor = Instance.new("Part")
		scanAnchor.Name = "ScanBillboardAnchor"
		scanAnchor.Anchored = true
		scanAnchor.CanCollide = false
		scanAnchor.Transparency = 1
		scanAnchor.Size = Vector3.new(0.2,0.2,0.2)
		scanAnchor.Parent = padGrp
	end
	scanAnchor.CFrame = CFrame.new(padCenter)

	-- BillboardGui with a circular stroked frame
	local bbg = padGrp:FindFirstChild("ScanBillboard")
	if not bbg then
		bbg = Instance.new("BillboardGui")
		bbg.Name = "ScanBillboard"
		bbg.AlwaysOnTop = true
		bbg.Size = UDim2.fromOffset(300,300) -- visual diameter
		bbg.LightInfluence = 0
		bbg.MaxDistance = 1000
		bbg.Parent = padGrp
		local frame = Instance.new("Frame")
		frame.Name = "Ring"
		frame.Size = UDim2.fromScale(1,1)
		frame.BackgroundTransparency = 1
		frame.Parent = bbg
		local uic = Instance.new("UICorner")
		uic.CornerRadius = UDim.new(1,0) -- perfect circle
		uic.Parent = frame
		local stroke = Instance.new("UIStroke")
		stroke.Name = "Stroke"
		stroke.Thickness = 6
		stroke.LineJoinMode = Enum.LineJoinMode.Round
		stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
		stroke.Parent = frame
	end
	(bbg :: BillboardGui).Adornee = scanAnchor :: Part
	local ringFrame = (bbg :: BillboardGui):FindFirstChild("Ring") :: Frame
	local stroke = ringFrame and ringFrame:FindFirstChild("Stroke") :: UIStroke
	if stroke then
		stroke.Color = col
		stroke.Transparency = 0.15
	end

	-- Animate: move anchor down, then up, and fade the stroke
	local function tweenAnchorY(deltaY: number, dur: number)
		TweenService:Create(scanAnchor, TweenInfo.new(dur, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
			CFrame = scanAnchor.CFrame * CFrame.new(0, deltaY, 0)
		}):Play()
	end

	-- Down then up sequence
	task.delay(1.4, function()
		tweenAnchorY(-2.6, 0.7)
		task.delay(0.8, function()
			TweenService:Create(scanAnchor, TweenInfo.new(0.7, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
				CFrame = CFrame.new(padCenter)
			}):Play()
			if stroke then
				TweenService:Create(stroke, TweenInfo.new(0.5, Enum.EasingStyle.Sine, Enum.EasingDirection.In), { Transparency = 1.0 }):Play()
			end
		end)
	end)

	-- 2.0s: materialize placeholder robot on pad center
	task.delay(2.0, function()
		local bot = Instance.new("Model"); bot.Name = "GD_HatchBot"; bot.Parent = model
		local torso = Instance.new("Part"); torso.Name="Torso"; torso.Anchored=true; torso.Material=Enum.Material.SmoothPlastic; torso.Color=Color3.fromRGB(130,140,150); torso.Size=Vector3.new(1.6,2.6,1.2); torso.Parent=bot
		local head  = Instance.new("Part"); head.Name ="Head";  head.Anchored=true;  head.Material=Enum.Material.SmoothPlastic;  head.Color =Color3.fromRGB(200,210,220); head.Shape=Enum.PartType.Ball; head.Size=Vector3.new(1,1,1); head.Parent=bot
		local c = (pad :: BasePart).Position
		torso.CFrame = CFrame.new(c + Vector3.new(0,1.6,0))
		head.CFrame  = CFrame.new(c + Vector3.new(0,3.1,0))
		-- light calibration bob
		TweenService:Create(head, TweenInfo.new(0.9, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, 2, true), { CFrame = head.CFrame * CFrame.new(0,0.15,0)}):Play()

		-- 2.2s: capsule appears around the bot and dissolves into the emitter
		local capGrp = Instance.new("Model"); capGrp.Name = "GD_Capsule"; capGrp.Parent = model
		local shellA = ensurePart(capGrp, "ShellA", Vector3.new(0.25, (pad :: BasePart).Size.Y*1.05, (pad :: BasePart).Size.Y*1.05), CFrame.new(c + Vector3.new(0,1.0,0)) * CFrame.Angles(0,0,math.rad(90)), col, false)
		shellA.Transparency = 0.3
		local shellB = ensurePart(capGrp, "ShellB", Vector3.new(0.25, (pad :: BasePart).Size.Y*1.05, (pad :: BasePart).Size.Y*1.05), CFrame.new(c + Vector3.new(0,1.0,0)) * CFrame.Angles(0,0,math.rad(90)) * CFrame.Angles(0, math.rad(25), 0), col, false)
		shellB.Transparency = 0.4
		local upCF = CFrame.new(0, 3.5, 0)
		TweenService:Create(shellA, TweenInfo.new(0.8, Enum.EasingStyle.Sine, Enum.EasingDirection.In), { Transparency = 1.0, CFrame = shellA.CFrame * upCF }):Play()
		TweenService:Create(shellB, TweenInfo.new(0.8, Enum.EasingStyle.Sine, Enum.EasingDirection.In), { Transparency = 1.0, CFrame = shellB.CFrame * upCF * CFrame.Angles(0, math.rad(20), 0) }):Play()
		-- cleanup capsule shortly after
		task.delay(1.0, function() capGrp:Destroy() end)

		-- 4.5s: slide down the ramp toward the door
		task.delay(2.5, function()
			local r = (ramp :: BasePart)
			local fwd = r.CFrame.LookVector
			local dest = r.Position + fwd * (r.Size.Z * 0.5)
			TweenService:Create(torso, TweenInfo.new(1.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), { CFrame = CFrame.new(dest + Vector3.new(0,1.0,0)) }):Play()
			TweenService:Create(head,  TweenInfo.new(1.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), { CFrame = CFrame.new(dest + Vector3.new(0,2.5,0)) }):Play()
		end)

		-- 7.8s: wrap; beam off and client banner
		task.delay(5.8, function()
			padGrp:SetAttribute("LaserEnabled", false)
			TweenService:Create(ringT, tiFast, { Transparency = 0.2 }):Play()
			TweenService:Create(ringB, tiFast, { Transparency = 0.2 }):Play()
			TweenService:Create(rim,   tiFast, { Transparency = 0.0 }):Play()
			local rc = ReplicatedStorage:FindFirstChild("RC_Remotes")
			local fx = rc and rc:FindFirstChild("HatchFX")
			if fx and fx:IsA("RemoteEvent") then
				fx:FireAllClients({ name = (opts and opts.name) or "New Robot", rarity = rarity })
			end
			TweenService:Create(rim, TweenInfo.new(0.25, Enum.EasingStyle.Sine, Enum.EasingDirection.Out, 0, true), { Transparency = 0.1 }):Play()
		end)
	end)
end

return HatchShow