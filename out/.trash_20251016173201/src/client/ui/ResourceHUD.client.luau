--!strict

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local player = Players.LocalPlayer
local pg = player:WaitForChild("PlayerGui")

local rem = ReplicatedStorage:WaitForChild("RC_Remotes") :: Folder
local syncEvt = rem:WaitForChild("ResourceSync") :: RemoteEvent
local deltaEvt = rem:WaitForChild("ResourceDelta") :: RemoteEvent

local function ensureGui()
	local g = pg:FindFirstChild("RC_ResourceHUD") :: ScreenGui?
	if g then
		return g
	end

	g = Instance.new("ScreenGui")
	g.Name = "RC_ResourceHUD"
	g.ResetOnSpawn = false
	g.IgnoreGuiInset = true
	g.Parent = pg

	local frame = Instance.new("Frame")
	frame.Name = "Panel"
	frame.AnchorPoint = Vector2.new(1, 0)
	frame.Size = UDim2.new(0, 180, 0, 72)
	local hasDock = (player.PlayerGui:FindFirstChild("RightDockGui") ~= nil)
	if not hasDock then
		frame.Position = UDim2.new(1, -16, 0, 16)
	end
	frame.BackgroundColor3 = Color3.fromRGB(22, 26, 34)
	frame.BorderSizePixel = 0
	frame.Parent = g

	local uic = Instance.new("UICorner")
	uic.CornerRadius = UDim.new(0, 8)
	uic.Parent = frame

	local scrap = Instance.new("TextLabel")
	scrap.Name = "Scrap"
	scrap.Size = UDim2.new(1, -12, 0, 30)
	scrap.Position = UDim2.new(0, 6, 0, 6)
	scrap.BackgroundTransparency = 1
	scrap.Font = Enum.Font.GothamBold
	scrap.TextSize = 16
	scrap.TextXAlignment = Enum.TextXAlignment.Right
	scrap.TextColor3 = Color3.fromRGB(220, 235, 255)
	scrap.Text = "Scrap: 0"
	scrap.Parent = frame

	local energy = scrap:Clone()
	energy.Name = "Energy"
	energy.Position = UDim2.new(0, 6, 0, 36)
	energy.Text = "Energy: 0"
	energy.Parent = frame

	return g
end

local gui = ensureGui()
local panel = gui:WaitForChild("Panel") :: Frame
local lblScrap = panel:WaitForChild("Scrap") :: TextLabel
local lblEnergy = panel:WaitForChild("Energy") :: TextLabel

local totals = { Scrap = 0, Energy = 0 }

local function applyTotals(t)
	totals.Scrap = tonumber(t.Scrap) or 0
	totals.Energy = tonumber(t.Energy) or 0
	lblScrap.Text = ("Scrap: %d"):format(totals.Scrap)
	lblEnergy.Text = ("Energy: %d"):format(totals.Energy)
end

syncEvt.OnClientEvent:Connect(function(state)
	applyTotals(state or totals)
end)

deltaEvt.OnClientEvent:Connect(function(payload)
	if typeof(payload) ~= "table" then
		return
	end
	if payload.totals then
		applyTotals(payload.totals)
	end
end)

print("[ResourceHUD] Ready")
