--!strict
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

local RC_Remotes = ReplicatedStorage:WaitForChild("RC_Remotes")
local BackpackUpdated = RC_Remotes:WaitForChild("BackpackUpdated") :: RemoteEvent

local screen = Instance.new("ScreenGui")
screen.Name = "BackpackHUD"
screen.IgnoreGuiInset = true
screen.ResetOnSpawn = true
screen.Parent = playerGui

local container = Instance.new("Frame")
container.Name = "Container"
container.AnchorPoint = Vector2.new(1, 0)
container.Position = UDim2.new(1, -20, 0, 20)
container.Size = UDim2.new(0, 240, 0, 64)
container.BackgroundTransparency = 0.3
container.BorderSizePixel = 0
container.Parent = screen

local title = Instance.new("TextLabel")
title.Name = "Title"
title.Size = UDim2.new(1, 0, 0, 22)
title.BackgroundTransparency = 1
title.Font = Enum.Font.GothamBold
title.TextSize = 16
title.TextColor3 = Color3.fromRGB(245, 245, 245)
title.TextXAlignment = Enum.TextXAlignment.Left
title.Text = "Backpack"
title.Parent = container

local summary = Instance.new("TextLabel")
summary.Name = "Summary"
summary.Position = UDim2.new(0, 0, 0, 24)
summary.Size = UDim2.new(1, 0, 1, -24)
summary.BackgroundTransparency = 1
summary.Font = Enum.Font.Gotham
summary.TextSize = 14
summary.TextColor3 = Color3.fromRGB(230, 230, 230)
summary.TextXAlignment = Enum.TextXAlignment.Left
summary.TextYAlignment = Enum.TextYAlignment.Top
summary.TextWrapped = true
summary.Text = "—"
summary.Parent = container

local function render(payload: { [string]: any })
	local used = payload.slots or 0
	local total = payload.total or 0
	local counts = payload.counts or {}

	local lines = {}
	for resource, amount in pairs(counts) do
		if amount > 0 then
			table.insert(lines, string.format("%s:%d", resource, amount))
		end
	end
	table.sort(lines)

	if #lines == 0 then
		summary.Text = string.format("%d/%d  |  empty", used, total)
	else
		summary.Text = string.format("%d/%d  |  %s", used, total, table.concat(lines, ", "))
	end
end

BackpackUpdated.OnClientEvent:Connect(render)

