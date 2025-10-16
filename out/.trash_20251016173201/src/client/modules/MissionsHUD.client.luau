--!strict
-- File: MissionsHUD.client.luau
-- v0.6.0-alpha — Minimal mission HUD
-- Autoloaded via Main.client.luau module loader.
-- Listens to RC_Remotes/Missions/MissionUpdate and shows progress + completion toast.
-- Idempotent: reuses GUI if present; echoes first ~60 lines for quick inspection.

print("🏗️ MissionsHUD.client.luau ACTIVE", os.time())

--// Services
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")

local player = Players.LocalPlayer
local PlayerGui = player:WaitForChild("PlayerGui")

--// Remotes
local RC_Remotes = ReplicatedStorage:WaitForChild("RC_Remotes")
local Missions = RC_Remotes:WaitForChild("Missions")
local MissionUpdate = Missions:WaitForChild("MissionUpdate")

--// GUI Construction (build once, reuse thereafter)
local function ensureGui()
	-- Root
	local root = PlayerGui:FindFirstChild("MissionsHUD") :: ScreenGui
	if not root then
		root = Instance.new("ScreenGui")
		root.Name = "MissionsHUD"
		root.ResetOnSpawn = false
		root.IgnoreGuiInset = true
		root.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
		root.Parent = PlayerGui
	end

	-- Panel
	local panel = root:FindFirstChild("Panel") :: Frame
	if not panel then
		panel = Instance.new("Frame")
		panel.Name = "Panel"
		panel.Size = UDim2.fromOffset(280, 92)
		panel.Position = UDim2.new(1, -300, 0, 140) -- top-right (moved down to avoid overlap)
		panel.BackgroundColor3 = Color3.fromRGB(18, 18, 22)
		panel.BackgroundTransparency = 0.15
		panel.BorderSizePixel = 0
		panel.Parent = root

		local uiCorner = Instance.new("UICorner")
		uiCorner.CornerRadius = UDim.new(0, 8)
		uiCorner.Parent = panel

		local uiPadding = Instance.new("UIPadding")
		uiPadding.PaddingLeft = UDim.new(0, 8)
		uiPadding.PaddingTop = UDim.new(0, 6)
		uiPadding.Parent = panel
	end

	-- Title
	local title = panel:FindFirstChild("Title") :: TextLabel
	if not title then
		title = Instance.new("TextLabel")
		title.Name = "Title"
		title.Size = UDim2.new(1, -16, 0, 22)
		title.Position = UDim2.fromOffset(8, 6)
		title.BackgroundTransparency = 1
		title.Font = Enum.Font.GothamBold
		title.TextSize = 16
		title.TextColor3 = Color3.fromRGB(235, 235, 245)
		title.TextXAlignment = Enum.TextXAlignment.Left
		title.Text = "Mission"
		title.Parent = panel
	end

	-- Progress
	local progress = panel:FindFirstChild("Progress") :: TextLabel
	if not progress then
		progress = Instance.new("TextLabel")
		progress.Name = "Progress"
		progress.Size = UDim2.new(1, -16, 0, 20)
		progress.Position = UDim2.fromOffset(8, 32)
		progress.BackgroundTransparency = 1
		progress.Font = Enum.Font.Gotham
		progress.TextSize = 14
		progress.TextColor3 = Color3.fromRGB(210, 210, 220)
		progress.TextXAlignment = Enum.TextXAlignment.Left
		progress.Text = "0 / 0"
		progress.Parent = panel
	end

	-- Subtext (optional hints like length/rarity)
	local sub = panel:FindFirstChild("Sub") :: TextLabel
	if not sub then
		sub = Instance.new("TextLabel")
		sub.Name = "Sub"
		sub.Size = UDim2.new(1, -16, 0, 16)
		sub.Position = UDim2.fromOffset(8, 52)
		sub.BackgroundTransparency = 1
		sub.Font = Enum.Font.Gotham
		sub.TextSize = 12
		sub.TextColor3 = Color3.fromRGB(170, 170, 180)
		sub.TextXAlignment = Enum.TextXAlignment.Left
		sub.Text = ""
		sub.Parent = panel
	end

	-- Toast (fade-in/out)
	local toast = panel:FindFirstChild("Toast") :: TextLabel
	if not toast then
		toast = Instance.new("TextLabel")
		toast.Name = "Toast"
		toast.Size = UDim2.new(1, -16, 0, 18)
		toast.Position = UDim2.fromOffset(8, 72)
		toast.BackgroundTransparency = 1
		toast.Font = Enum.Font.GothamSemibold
		toast.TextSize = 14
		toast.TextColor3 = Color3.fromRGB(120, 255, 160)
		toast.TextXAlignment = Enum.TextXAlignment.Left
		toast.TextTransparency = 1
		toast.Text = "✔ Mission completed"
		toast.Parent = panel
	end

	return root, panel, title, progress, sub, toast
end

local _, panel, titleLbl, progressLbl, subLbl, toastLbl = ensureGui()

-- State
local currentMissionId: string? = nil

-- Toast animation
local function playToast(msg: string)
	toastLbl.Text = msg
	local fadeIn = TweenService:Create(toastLbl, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), { TextTransparency = 0 })
	local fadeOut = TweenService:Create(toastLbl, TweenInfo.new(0.4, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), { TextTransparency = 1 })
	fadeIn:Play()
	fadeIn.Completed:Wait()
	task.delay(1.2, function()
		fadeOut:Play()
	end)
end

-- Pretty length label (optional)
local function lengthLabel(len: any): string
	if len == "SHORT" then return "Short" end
	if len == "MEDIUM" then return "Medium" end
	if len == "LONG" then return "Long" end
	if len == "XL" then return "Long+" end
	if len == "XXL" then return "Very Long" end
	return ""
end

-- Payloads expected from server:
-- { t="mission_started", mission = { id, kind="collect", resourceType, target, progress, length?, reward? } }
-- { t="progress", missionId=string, resourceType=string, progress=number, target=number }
-- { t="mission_completed", mission = {...} }
-- { t="claimed", missionId=string, reward={...} }
MissionUpdate.OnClientEvent:Connect(function(payload)
	if typeof(payload) ~= "table" then
		return
	end

	if payload.t == "mission_started" and payload.mission then
		local m = payload.mission
		currentMissionId = m.id
		titleLbl.Text = string.format("Collect %d %s", tonumber(m.target) or 0, tostring(m.resourceType or "Items"))
		progressLbl.Text = string.format("%d / %d", tonumber(m.progress) or 0, tonumber(m.target) or 0)
		-- Optional sub-hints if server supplies
		local sub = {}
		if m.length then table.insert(sub, lengthLabel(m.length)) end
		if m.dropHint and m.dropHint.rarePct then
			table.insert(sub, string.format("Rare: %d%%", math.floor((m.dropHint.rarePct or 0) * 100 + 0.5)))
		end
		subLbl.Text = table.concat(sub, " · ")
	elseif payload.t == "progress" then
		if currentMissionId == nil or payload.missionId == currentMissionId then
			progressLbl.Text = string.format("%d / %d", tonumber(payload.progress) or 0, tonumber(payload.target) or 0)
		end
	elseif payload.t == "mission_completed" and payload.mission then
		local m = payload.mission
		currentMissionId = m.id
		progressLbl.Text = string.format("%d / %d", tonumber(m.progress) or 0, tonumber(m.target) or 0)
		playToast("✔ Mission completed")
	elseif payload.t == "claimed" then
		playToast("🎁 Rewards claimed")
	end
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
			print(("[MissionsHUD:%02d] %s"):format(n, line))
			if n >= 60 then break end
		end
	end
end
