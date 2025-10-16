--!strict
-- File: RightDock.client.luau
-- v0.6.0-alpha — RightDock with card wrapper normalization

print("🏗️ RightDock.client.luau ACTIVE", os.time())

local Players = game:GetService("Players")
local GuiService = game:GetService("GuiService")
local player = Players.LocalPlayer
local PlayerGui = player:WaitForChild("PlayerGui")

local DOCK_WIDTH = 280
local GAP = 16

local function ensureGui()
	local gui = PlayerGui:FindFirstChild("RightDockGui") :: ScreenGui
	if not gui then
		gui = Instance.new("ScreenGui")
		gui.Name = "RightDockGui"
		gui.IgnoreGuiInset = true
		gui.ResetOnSpawn = false
		gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
		gui.Parent = PlayerGui
	end
	return gui
end

local function safeTopInsetY(): number
	-- GuiService:GetGuiInset() returns Vector2 (top-left safe inset)
	local ok, inset = pcall(function()
		return GuiService:GetGuiInset()
	end)
	if ok and typeof(inset) == "Vector2" then
		return inset.Y
	end
	-- Studio fallback
	return 36
end

local function ensureDock(gui: ScreenGui)
	local dock = gui:FindFirstChild("RightDock") :: Frame
	local topInset = safeTopInsetY()
	local reserveForCore = 132 -- space for avatar/playerlist popover

	if not dock then
		dock = Instance.new("Frame")
		dock.Name = "RightDock"
		dock.AnchorPoint = Vector2.new(1, 0)
		dock.Position   = UDim2.new(1, -20, 0, topInset + 20 + reserveForCore)
		dock.Size       = UDim2.fromOffset(DOCK_WIDTH, 8)
		dock.AutomaticSize = Enum.AutomaticSize.Y
		dock.BackgroundTransparency = 1
		dock.BorderSizePixel = 0
		dock.ZIndex = 5
		dock.Parent = gui

		local layout = Instance.new("UIListLayout")
		layout.Name = "Stack"
		layout.FillDirection = Enum.FillDirection.Vertical
		layout.HorizontalAlignment = Enum.HorizontalAlignment.Right
		layout.SortOrder = Enum.SortOrder.LayoutOrder
		layout.Padding = UDim.new(0, GAP)
		layout.Parent = dock
	else
		-- Recompute position each run to remain CoreGui-safe
		dock.Position = UDim2.new(1, -20, 0, topInset + 20 + reserveForCore)
		dock.Size = UDim2.fromOffset(DOCK_WIDTH, dock.AbsoluteSize.Y)
	end
	return dock
end

local gui  = ensureGui()
local dock = ensureDock(gui)

-- Create a uniform wrapper "card" and parent target panel inside
local function wrapInCard(panel: Frame, order: number, label: string)
	if panel.Parent and panel.Parent.Name == label .. "_Card" and panel.Parent.Parent == dock then
		return
	end

	local card = Instance.new("Frame")
	card.Name = label .. "_Card"
	card.Size = UDim2.fromOffset(DOCK_WIDTH, math.max(panel.AbsoluteSize.Y, 92))
	card.AutomaticSize = Enum.AutomaticSize.Y
	card.LayoutOrder = order
	card.ZIndex = 6
	card.BackgroundColor3 = Color3.fromRGB(18, 18, 22)
	card.BackgroundTransparency = 0.15
	card.BorderSizePixel = 0
	card.Parent = dock

	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, 8)
	corner.Parent = card

	local pad = Instance.new("UIPadding")
	pad.PaddingTop    = UDim.new(0, 8)
	pad.PaddingBottom = UDim.new(0, 8)
	pad.PaddingLeft   = UDim.new(0, 8)
	pad.PaddingRight  = UDim.new(0, 8)
	pad.Parent = card

	panel.AnchorPoint = Vector2.new(0, 0)
	panel.Position    = UDim2.new(0, 0, 0, 0)
	panel.Size        = UDim2.new(1, 0, 0, math.max(panel.AbsoluteSize.Y, 76))
	panel.AutomaticSize = Enum.AutomaticSize.Y
	panel.BackgroundTransparency = 1
	panel.BorderSizePixel = 0
	panel.Parent = card
end

local function firstFrameChild(container: Instance): Frame?
	for _, ch in ipairs(container:GetChildren()) do
		if ch:IsA("Frame") then return ch end
	end
	return nil
end

local function adopt(guiNames: {string}, order: number, label: string)
	for _, name in ipairs(guiNames) do
		local g = PlayerGui:FindFirstChild(name) :: ScreenGui
		if g then
			local panel = (g:FindFirstChild("Panel") or firstFrameChild(g)) :: Frame
			if panel then
				wrapInCard(panel, order, label)
				print(('[RightDock] Attached %s panel'):format(label))
			end
			return
		end
	end
end

-- Top: ResourceHUD, then MissionsHUD
task.defer(function() adopt({"RC_ResourceHUD","ResourceHUD"}, 10, "ResourceHUD") end)
task.defer(function() adopt({"MissionsHUD"}, 20, "MissionsHUD") end)

-- Echo first ~60 lines
do
	local ok, src = pcall(function() return script.Source end)
	if ok and typeof(src) == "string" then
		local n = 0
		for line in string.gmatch(src, "([^\n]*)\n?") do
			n += 1
			print(('[RightDock:%02d] %s'):format(n, line))
			if n >= 60 then break end
		end
	end
end
