

--!strict
-- ZoneToast.client.luau
-- Listens for RC_Remotes.ZoneChanged and shows a small top-center toast.

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")

local player = Players.LocalPlayer
local pg = player:WaitForChild("PlayerGui")

local remotes = ReplicatedStorage:WaitForChild("RC_Remotes") :: Folder
local zoneChanged = remotes:WaitForChild("ZoneChanged") :: RemoteEvent

-- screen container (one per player)
local gui = Instance.new("ScreenGui")
gui.Name = "RC_ZoneToast"
gui.ResetOnSpawn = false
gui.IgnoreGuiInset = true
gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
gui.Parent = pg

local queue: {string} = {}
local showing = false

local function makeToastFrame(text: string): Frame
	local f = Instance.new("Frame")
	f.Name = "Toast"
	f.AnchorPoint = Vector2.new(0.5, 0)
	f.Position = UDim2.new(0.5, 0, 0.08, 0)
	f.Size = UDim2.new(0, 520, 0, 42)
	f.BackgroundColor3 = Color3.fromRGB(30, 36, 48)
	f.BackgroundTransparency = 0.1
	f.BorderSizePixel = 0
	f.Parent = gui

	local uic = Instance.new("UICorner")
	uic.CornerRadius = UDim.new(0, 8)
	uic.Parent = f

	local label = Instance.new("TextLabel")
	label.Name = "Label"
	label.BackgroundTransparency = 1
	label.Size = UDim2.new(1, -20, 1, 0)
	label.Position = UDim2.new(0, 10, 0, 0)
	label.Font = Enum.Font.GothamBold
	label.TextSize = 18
	label.TextColor3 = Color3.fromRGB(220, 235, 255)
	label.TextXAlignment = Enum.TextXAlignment.Center
	label.Text = text
	label.Parent = f

	f.Transparency = 1
	label.TextTransparency = 1
	return f
end

local function showNext()
	if showing then return end
	if #queue == 0 then return end
	showing = true
	local text = table.remove(queue, 1)
	local toast = makeToastFrame(text)
	-- fade in
	TweenService:Create(toast, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Transparency = 0}):Play()
	TweenService:Create(toast.Label, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {TextTransparency = 0}):Play()
	-- hold, then fade out
	task.delay(2.0, function()
		TweenService:Create(toast.Label, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {TextTransparency = 1}):Play()
		local t = TweenService:Create(toast, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {Transparency = 1})
		t.Completed:Connect(function()
			toast:Destroy()
			showing = false
			showNext()
		end)
		t:Play()
	end)
end

zoneChanged.OnClientEvent:Connect(function(payload)
	local name = (payload and payload.name) or "Unknown Zone"
	local tier = (payload and payload.tier) or 0
	table.insert(queue, string.format("Entering %s (Tier %d)", name, tier))
	showNext()
end)

print("[ZoneToast] Ready (listening for ZoneChanged)")