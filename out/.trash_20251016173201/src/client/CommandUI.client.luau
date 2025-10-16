--!strict
-- CommandUI.client.luau (Unified Console)
-- Single UI for Hatch, Missions, Repair, and Design.

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local UIS = game:GetService("UserInputService")

local remotes = ReplicatedStorage:WaitForChild("RC_Remotes") :: Folder
local openEvt = remotes:WaitForChild("OpenCommandUI") :: RemoteEvent
local closeEvt = remotes:WaitForChild("CloseCommandUI") :: RemoteEvent
local openMissionEvt = remotes:WaitForChild("OpenMissionUI") :: RemoteEvent

local hatchEvt = remotes:WaitForChild("HatchRobot") :: RemoteEvent
local startMissionEvt = remotes:FindFirstChild("StartMission") :: RemoteEvent?
local completeMissionEvt = remotes:FindFirstChild("MissionComplete") :: RemoteEvent?

local player = Players.LocalPlayer
local pg = player:WaitForChild("PlayerGui")

-- state
local lastTab: string? = nil

local function ensureUI()
	local gui = pg:FindFirstChild("RC_CommandUI") :: ScreenGui?
	if gui then return gui end

	gui = Instance.new("ScreenGui")
	gui.Name = "RC_CommandUI"
	gui.ResetOnSpawn = false
	gui.IgnoreGuiInset = true
	gui.Enabled = false
	gui.Parent = pg

	local frame = Instance.new("Frame"); frame.Name="Main"; frame.Size=UDim2.new(0, 720, 0, 420); frame.Position=UDim2.new(0.5,-360, 0.5,-210)
	frame.BackgroundColor3 = Color3.fromRGB(18,22,28); frame.BorderSizePixel = 0; frame.Parent = gui

	local title = Instance.new("TextLabel"); title.Name="Title"; title.Text="Command Console"; title.Font=Enum.Font.GothamBold; title.TextSize=22
	title.Size=UDim2.new(1, -16, 0, 36); title.Position=UDim2.new(0, 8, 0, 8); title.TextColor3=Color3.fromRGB(220,235,255); title.BackgroundTransparency=1; title.Parent = frame

	-- Tabs bar
	local tabsBar = Instance.new("Frame"); tabsBar.Name="Tabs"; tabsBar.Size=UDim2.new(1,-16, 0, 32); tabsBar.Position=UDim2.new(0,8,0,48)
	tabsBar.BackgroundTransparency=1; tabsBar.Parent=frame
	local tabsLayout = Instance.new("UIListLayout"); tabsLayout.FillDirection = Enum.FillDirection.Horizontal; tabsLayout.Padding = UDim.new(0,8); tabsLayout.Parent = tabsBar

	local function makeTabButton(name: string): TextButton
		local b = Instance.new("TextButton")
		b.Name = name
		b.Text = name
		b.Size = UDim2.new(0, 140, 1, 0)
		b.BackgroundColor3 = Color3.fromRGB(40,48,60)
		b.TextColor3 = Color3.fromRGB(230,236,255)
		b.Font = Enum.Font.Gotham
		b.TextSize = 16
		b.Parent = tabsBar
		return b
	end

	local tabHatch = makeTabButton("Hatch")
	local tabMissions = makeTabButton("Missions")
	local tabRepair = makeTabButton("Repair")
	local tabDesign = makeTabButton("Design")

	-- Content area
	local content = Instance.new("Frame"); content.Name="Content"; content.Size=UDim2.new(1,-16,1,-(48+32+16)); content.Position=UDim2.new(0,8,0,(48+32+8))
	content.BackgroundColor3 = Color3.fromRGB(22,26,34); content.BorderSizePixel=0; content.Parent=frame

	local function makePane(name: string): Frame
		local f = Instance.new("Frame")
		f.Name = name
		f.Size = UDim2.new(1,0,1,0)
		f.BackgroundTransparency = 1
		f.Visible = false
		f.Parent = content
		return f
	end

	local paneHatch = makePane("PaneHatch")
	local paneMissions = makePane("PaneMissions")
	local paneRepair = makePane("PaneRepair")
	local paneDesign = makePane("PaneDesign")

	-- HATCH PANE
	local hatchBtn = Instance.new("TextButton")
	hatchBtn.Name = "Hatch"
	hatchBtn.Text = "Hatch Robot"
	hatchBtn.Font = Enum.Font.Gotham
	hatchBtn.TextSize = 16
	hatchBtn.Size = UDim2.new(0, 160, 0, 40)
	hatchBtn.Position = UDim2.new(0, 14, 0, 14)
	hatchBtn.BackgroundColor3 = Color3.fromRGB(40,120,80)
	hatchBtn.TextColor3 = Color3.fromRGB(240,246,255)
	hatchBtn.Parent = paneHatch
	hatchBtn.MouseButton1Click:Connect(function()
		-- close immediately on client; server also closes via CloseCommandUI
		gui.Enabled = false
		hatchEvt:FireServer()
	end)

	-- MISSIONS PANE
	local function makeMissionButton(parent: Instance, label: string, missionName: string)
		local btn = Instance.new("TextButton")
		btn.Size = UDim2.new(0, 220, 0, 48)
		btn.BackgroundColor3 = Color3.fromRGB(90, 90, 110)
		btn.Text = label
		btn.TextColor3 = Color3.new(1, 1, 1)
		btn.Font = Enum.Font.Gotham
		btn.TextSize = 16
		btn.Parent = parent
		btn.MouseButton1Click:Connect(function()
			if startMissionEvt then startMissionEvt:FireServer(missionName) end
			btn.Text = missionName .. " Started!"
			btn.BackgroundColor3 = Color3.fromRGB(70, 130, 100)
			-- short client countdown placeholder; server still tracks real time
			task.spawn(function()
				local countdown = 5
				while countdown > 0 do
					btn.Text = string.format("%s (%ds)", missionName, countdown)
					countdown -= 1
					task.wait(1)
				end
				btn.Text = "Claim " .. missionName .. " Reward"
				btn.BackgroundColor3 = Color3.fromRGB(150, 100, 60)
				btn.MouseButton1Click:Connect(function()
					if completeMissionEvt then completeMissionEvt:FireServer(missionName) end
					btn.Text = missionName .. " Complete!"
					btn.BackgroundColor3 = Color3.fromRGB(90, 90, 110)
				end)
			end)
		end)
		return btn
	end

	local grid = Instance.new("UIGridLayout")
	grid.CellSize = UDim2.new(0, 240, 0, 56)
	grid.CellPadding = UDim2.new(0, 12, 0, 12)
	grid.Parent = paneMissions

	makeMissionButton(paneMissions, "Start Scouting Mission", "Scouting")
	makeMissionButton(paneMissions, "Start Harvesting Mission", "Harvesting")
	makeMissionButton(paneMissions, "Start Combat Mission", "Combat")

	-- REPAIR / DESIGN placeholders
	local rlbl = Instance.new("TextLabel")
	rlbl.Text = "Repair (coming soon)"
	rlbl.Size = UDim2.new(0, 280, 0, 28)
	rlbl.Position = UDim2.new(0, 16, 0, 16)
	rlbl.BackgroundTransparency = 1
	rlbl.TextColor3 = Color3.fromRGB(200,210,225)
	rlbl.Font = Enum.Font.Gotham
	rlbl.TextSize = 16
	rlbl.Parent = paneRepair

	local dlbl = rlbl:Clone(); dlbl.Text = "Design (coming soon)"; dlbl.Parent = paneDesign

	-- Tab logic
	local function setTabButtonState(active: TextButton)
		for _,btn in ipairs({tabHatch, tabMissions, tabRepair, tabDesign}) do
			btn.BackgroundColor3 = (btn == active) and Color3.fromRGB(65,78,96) or Color3.fromRGB(40,48,60)
		end
	end

	local function selectTab(name: string)
		paneHatch.Visible = (name == "Hatch")
		paneMissions.Visible = (name == "Missions")
		paneRepair.Visible = (name == "Repair")
		paneDesign.Visible = (name == "Design")
		lastTab = name
		if name == "Hatch" then setTabButtonState(tabHatch)
		elseif name == "Missions" then setTabButtonState(tabMissions)
		elseif name == "Repair" then setTabButtonState(tabRepair)
		else setTabButtonState(tabDesign) end
	end

	tabHatch.MouseButton1Click:Connect(function() selectTab("Hatch") end)
	tabMissions.MouseButton1Click:Connect(function() selectTab("Missions") end)
	tabRepair.MouseButton1Click:Connect(function() selectTab("Repair") end)
	tabDesign.MouseButton1Click:Connect(function() selectTab("Design") end)

	-- Close button
	local close = Instance.new("TextButton"); close.Name="Close"; close.Text="Close [Esc]"; close.Font=Enum.Font.Gotham; close.TextSize=14
	close.Size=UDim2.new(0, 110, 0, 28); close.Position=UDim2.new(1, -120, 0, 10)
	close.BackgroundColor3=Color3.fromRGB(40,48,60); close.TextColor3=Color3.fromRGB(230,236,255); close.Parent = frame
	close.MouseButton1Click:Connect(function() gui.Enabled = false end)

	UIS.InputBegan:Connect(function(inp, gp)
		if gp then return end
		if inp.KeyCode == Enum.KeyCode.Escape then gui.Enabled = false end
	end)

	-- default to Hatch on first open
	selectTab("Hatch")
	return gui, selectTab
end

local function closeUI()
	local gui = ensureUI()
	gui.Enabled = false
end

local function openUI(tab: string?)
	local gui, selectTab = ensureUI()
	gui.Enabled = true
	if tab then selectTab(tab) elseif lastTab then selectTab(lastTab) end
end

if not script:GetAttribute("Bound") then
	openEvt.OnClientEvent:Connect(function() openUI("Hatch") end)
	openMissionEvt.OnClientEvent:Connect(function() openUI("Missions") end)
	closeEvt.OnClientEvent:Connect(closeUI)
	script:SetAttribute("Bound", true)
end