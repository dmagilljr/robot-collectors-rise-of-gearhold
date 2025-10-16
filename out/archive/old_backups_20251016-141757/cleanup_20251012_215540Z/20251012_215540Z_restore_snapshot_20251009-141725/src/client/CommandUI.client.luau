--!strict
-- Listens for ReplicatedStorage.RC_Remotes.OpenCommandUI and spawns a simple UI
local RS = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local remotes = RS:WaitForChild("RC_Remotes")
local openEvt = remotes:WaitForChild("OpenCommandUI")

local function ensureUI()
	local pg = Players.LocalPlayer:WaitForChild("PlayerGui")
	local gui = pg:FindFirstChild("RC_CommandUI") :: ScreenGui?
	if not gui then
		gui = Instance.new("ScreenGui")
		gui.Name = "RC_CommandUI"; gui.ResetOnSpawn = false; gui.IgnoreGuiInset = true
		gui.Parent = pg
		local frame = Instance.new("Frame"); frame.Name="Main"; frame.Size=UDim2.new(0, 540, 0, 360); frame.Position=UDim2.new(0.5,-270, 0.5,-180)
		frame.BackgroundColor3 = Color3.fromRGB(18,22,28); frame.BorderSizePixel = 0; frame.Parent = gui
		local title = Instance.new("TextLabel"); title.Name="Title"; title.Text="Command Console"; title.Font=Enum.Font.GothamBold; title.TextSize=22
		title.Size=UDim2.new(1, -16, 0, 36); title.Position=UDim2.new(0, 8, 0, 8); title.TextColor3=Color3.fromRGB(220,235,255); title.BackgroundTransparency=1; title.Parent = frame
		local tabs = Instance.new("TextLabel"); tabs.Name="Tabs"; tabs.Text="Robots   Upgrades   Inventory (coming soon)"; tabs.Font=Enum.Font.Gotham; tabs.TextSize=16
		tabs.Size=UDim2.new(1, -16, 0, 24); tabs.Position=UDim2.new(0, 8, 0, 48); tabs.TextColor3=Color3.fromRGB(180,195,220); tabs.BackgroundTransparency=1; tabs.Parent = frame
		local hatchBtn = Instance.new("TextButton")
		hatchBtn.Name = "Hatch"
		hatchBtn.Text = "Hatch Robot"
		hatchBtn.Font = Enum.Font.Gotham
		hatchBtn.TextSize = 16
		hatchBtn.Size = UDim2.new(0, 140, 0, 32)
		hatchBtn.Position = UDim2.new(0, 14, 0, 84)
		hatchBtn.BackgroundColor3 = Color3.fromRGB(40,120,80)
		hatchBtn.TextColor3 = Color3.fromRGB(240,246,255)
		hatchBtn.Parent = frame
		local hatchEvt = remotes:WaitForChild("HatchRobot")
		hatchBtn.MouseButton1Click:Connect(function()
			hatchEvt:FireServer()
		end)

		local close = Instance.new("TextButton"); close.Name="Close"; close.Text="Close [Esc]"; close.Font=Enum.Font.Gotham; close.TextSize=14
		close.Size=UDim2.new(0, 100, 0, 28); close.Position=UDim2.new(1, -110, 0, 10); close.BackgroundColor3=Color3.fromRGB(40,48,60); close.TextColor3=Color3.fromRGB(230,236,255); close.Parent = frame
		close.MouseButton1Click:Connect(function() gui.Enabled = false end)
		game:GetService("UserInputService").InputBegan:Connect(function(inp,gp)
			if gp then return end
			if inp.KeyCode == Enum.KeyCode.Escape then gui.Enabled = false end
		end)
	end
	return gui
end

openEvt.OnClientEvent:Connect(function()
	local gui = ensureUI()
	gui.Enabled = true
end)
