-- Robot Collectors: Rise of Gearhold - Client Entry Point
-- VERSION: v3.0-modern (2025-09-27)
print("🎮 Robot Collectors: Client Starting... v3.1-SYNC-TEST (2025-09-27 22:05)")

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")
local ProximityPromptService = game:GetService("ProximityPromptService")

local Player = Players.LocalPlayer
local PlayerGui = Player:WaitForChild("PlayerGui")


-- Wait for remotes
local Remotes = ReplicatedStorage:WaitForChild("Remotes")
local HatchRobotEvent = Remotes:WaitForChild("HatchRobot")
local SetRobotStateEvent = Remotes:WaitForChild("SetRobotState")
local ManualMineEvent = Remotes:WaitForChild("ManualMine")
local AssignRobotToResourceEvent = Remotes:WaitForChild("AssignRobotToResource")
local GarageStatusEvent = Remotes:WaitForChild("GarageStatus")

local RobotUIManager = require(script.modules.RobotUIManager)
local UIStyle = require(script.modules.UIStyle)
local GarageUI = require(script.modules.GarageUI)
local RobotTypes = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("config"):WaitForChild("RobotTypes"))

local remotesBundle = {
    SetRobotState = SetRobotStateEvent,
    AssignRobotToResource = AssignRobotToResourceEvent,
}

print("✅ Client: Remote events loaded")

-- Create main GUI
local mainGui = Instance.new("ScreenGui")
mainGui.Name = "RobotCollectorsGUI"
mainGui.Parent = PlayerGui

-- Resource Display Panel (Top Left) - Made taller for 4 currencies
local resourcePanel = Instance.new("Frame")
resourcePanel.Name = "ResourcePanel"
resourcePanel.Size = UDim2.new(0, 280, 0, 160)  -- Increased height for 4 currencies
resourcePanel.Position = UDim2.new(0, 10, 0, 10)
resourcePanel.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
resourcePanel.BackgroundTransparency = 0.1
resourcePanel.Parent = mainGui

local resourceCorner = Instance.new("UICorner")
resourceCorner.CornerRadius = UDim.new(0, 12)
resourceCorner.Parent = resourcePanel

-- Disable hatch buttons until the garage handles hatching
hatchButton = nil
advancedButton = nil

-- Resource labels (4 currencies now)
local gearbitLabel = Instance.new("TextLabel")
gearbitLabel.Size = UDim2.new(1, 0, 0.25, 0)
gearbitLabel.Position = UDim2.new(0, 0, 0, 5)
gearbitLabel.BackgroundTransparency = 1
gearbitLabel.Text = "⚙️ Gearbits: 0"
gearbitLabel.TextColor3 = Color3.fromRGB(0, 212, 255)
gearbitLabel.TextScaled = true
gearbitLabel.Font = Enum.Font.GothamBold
gearbitLabel.Parent = resourcePanel

local ionLabel = Instance.new("TextLabel")
ionLabel.Size = UDim2.new(1, 0, 0.25, 0)
ionLabel.Position = UDim2.new(0, 0, 0.25, 0)
ionLabel.BackgroundTransparency = 1
ionLabel.Text = "⚡ Ion Shards: 0"
ionLabel.TextColor3 = Color3.fromRGB(150, 0, 255)
ionLabel.TextScaled = true
ionLabel.Font = Enum.Font.GothamBold
ionLabel.Parent = resourcePanel

local metalLabel = Instance.new("TextLabel")
metalLabel.Size = UDim2.new(1, 0, 0.25, 0)
metalLabel.Position = UDim2.new(0, 0, 0.5, 0)
metalLabel.BackgroundTransparency = 1
metalLabel.Text = "🥇 Rare Metals: 0"
metalLabel.TextColor3 = Color3.fromRGB(255, 215, 0)
metalLabel.TextScaled = true
metalLabel.Font = Enum.Font.GothamBold
metalLabel.Parent = resourcePanel

local crystalLabel = Instance.new("TextLabel")
crystalLabel.Size = UDim2.new(1, 0, 0.25, 0)
crystalLabel.Position = UDim2.new(0, 0, 0.75, 0)
crystalLabel.BackgroundTransparency = 1
crystalLabel.Text = "💎 Crystals: 0"
crystalLabel.TextColor3 = Color3.fromRGB(255, 100, 255)
crystalLabel.TextScaled = true
crystalLabel.Font = Enum.Font.GothamBold
crystalLabel.Parent = resourcePanel

-- Robot Management Panel (Right Side)
local operationsPanel = UIStyle.createPanel(mainGui, {
    name = "OperationsPanel",
    size = UDim2.new(0, 420, 0, 520),
    position = UDim2.new(1, -440, 0.5, -260),
    padding = {top = 16, bottom = 16, left = 16, right = 16},
})

local operationsLayout = Instance.new("UIListLayout")
operationsLayout.FillDirection = Enum.FillDirection.Vertical
operationsLayout.HorizontalAlignment = Enum.HorizontalAlignment.Left
operationsLayout.SortOrder = Enum.SortOrder.LayoutOrder
operationsLayout.Padding = UDim.new(0, 12)
operationsLayout.Parent = operationsPanel

local function createSectionHeader(text)
    local header = UIStyle.createLabel(operationsPanel, {
        text = text,
        textSize = 18,
        font = Enum.Font.GothamBold,
        size = UDim2.new(1, 0, 0, 28),
        automaticSize = Enum.AutomaticSize.None,
    })
    header.LayoutOrder = 0
    return header
end

local rosterHeader = createSectionHeader("🤖 Task Force")

local rosterContainer = Instance.new("Frame")
rosterContainer.Size = UDim2.new(1, 0, 0, 0)
rosterContainer.AutomaticSize = Enum.AutomaticSize.Y
rosterContainer.BackgroundTransparency = 1
rosterContainer.LayoutOrder = 1
rosterContainer.Parent = operationsPanel

local rosterLayout = Instance.new("UIListLayout")
rosterLayout.FillDirection = Enum.FillDirection.Vertical
rosterLayout.Padding = UDim.new(0, 8)
rosterLayout.Parent = rosterContainer

local robotListFrame = Instance.new("ScrollingFrame")
robotListFrame.Name = "RobotList"
robotListFrame.Size = UDim2.new(1, 0, 0, 320)
robotListFrame.BackgroundTransparency = 1
robotListFrame.BorderSizePixel = 0
robotListFrame.ScrollBarThickness = 6
robotListFrame.Parent = rosterContainer

local robotListLayout = Instance.new("UIListLayout")
robotListLayout.SortOrder = Enum.SortOrder.LayoutOrder
robotListLayout.Padding = UDim.new(0, 6)
robotListLayout.Parent = robotListFrame

local divider = UIStyle.createDivider(operationsPanel)
divider.LayoutOrder = 2

local resourceHeader = createSectionHeader("⛏️ Assignments")
resourceHeader.LayoutOrder = 3

local resourceDrawer = Instance.new("Frame")
resourceDrawer.Name = "ResourceDrawer"
resourceDrawer.Size = UDim2.new(1, 0, 0, 0)
resourceDrawer.AutomaticSize = Enum.AutomaticSize.Y
resourceDrawer.BackgroundTransparency = 1
resourceDrawer.LayoutOrder = 4
resourceDrawer.Parent = operationsPanel

local resourceBoard = Instance.new("ScrollingFrame")
resourceBoard.Name = "ResourceBoard"
resourceBoard.Size = UDim2.new(1, 0, 0, 180)
resourceBoard.BackgroundTransparency = 1
resourceBoard.BorderSizePixel = 0
resourceBoard.ScrollBarThickness = 6
resourceBoard.Parent = resourceDrawer

local resourceLayout = Instance.new("UIListLayout")
resourceLayout.SortOrder = Enum.SortOrder.LayoutOrder
resourceLayout.Padding = UDim.new(0, 6)
resourceLayout.Parent = resourceBoard

local function playerHasResources(definition)
    local leaderstats = Player:FindFirstChild("leaderstats")
    if not leaderstats then
        return false
    end
    for currency, amount in pairs(definition.Cost or {}) do
        local stat = leaderstats:FindFirstChild(currency)
        if not stat or stat.Value < amount then
            return false
        end
    end
    return true
end

local function attemptGarageHatch(robotType, definition)
    definition = definition or RobotTypes[robotType]
    if not definition then
        return false
    end

    if not playerHasResources(definition) then
        GarageUI.showInsufficientResources()
        return false
    end

    HatchRobotEvent:FireServer(robotType, 1)
    return true
end

local function openGarageMenu()
    local definitions = {}
    for name, def in pairs(RobotTypes) do
        definitions[name] = def
    end

    GarageUI.open(definitions, function(robotType, definition)
        return attemptGarageHatch(robotType, definition)
    end)
end

local garageStatusLabel
local openGarageButton
local quickButtons = {}
local garageStatusText = "Garage ready"
local garageStatusToken = 0

local function refreshQuickButtons()
    local busy = GarageUI.isBusy()
    for _, entry in ipairs(quickButtons) do
        local button = entry.button
        local baseColor = entry.baseColor
        local affordable = playerHasResources(entry.definition)
        local enabled = affordable and not busy
        button.AutoButtonColor = enabled
        button.BackgroundColor3 = enabled and baseColor or Color3.fromRGB(90, 90, 110)
        button.TextTransparency = enabled and 0 or 0.25
    end

    if openGarageButton then
        local enabled = not busy
        local baseColor = openGarageButton:GetAttribute("BaseColor") or UIStyle.colors.accent
        openGarageButton.AutoButtonColor = enabled
        openGarageButton.BackgroundColor3 = enabled and baseColor or Color3.fromRGB(90, 90, 110)
        openGarageButton.TextTransparency = enabled and 0 or 0.25
    end
end

local function setGarageStatus(text)
    if text then
        garageStatusText = text
    end

    garageStatusToken += 1
    if garageStatusLabel then
        garageStatusLabel.Text = garageStatusText
    end
    refreshQuickButtons()
    return garageStatusToken
end

local function resetGarageStatusAfter(delaySeconds, token)
    task.delay(delaySeconds, function()
        if garageStatusToken == token and not GarageUI.isBusy() then
            garageStatusText = "Garage ready"
            setGarageStatus()
        end
    end)
end

local garageHeader = createSectionHeader("🏭 Garage Console")
garageHeader.LayoutOrder = 5

local garageContainer = Instance.new("Frame")
garageContainer.Name = "GarageContainer"
garageContainer.Size = UDim2.new(1, 0, 0, 0)
garageContainer.AutomaticSize = Enum.AutomaticSize.Y
garageContainer.BackgroundTransparency = 1
garageContainer.LayoutOrder = 6
garageContainer.Parent = operationsPanel

local garageLayout = Instance.new("UIListLayout")
garageLayout.FillDirection = Enum.FillDirection.Vertical
garageLayout.Padding = UDim.new(0, 6)
garageLayout.SortOrder = Enum.SortOrder.LayoutOrder
garageLayout.Parent = garageContainer

garageStatusLabel = UIStyle.createLabel(garageContainer, {
    name = "GarageStatusLabel",
    text = garageStatusText,
    textSize = 14,
    color = UIStyle.colors.textSecondary,
    automaticSize = Enum.AutomaticSize.X,
})
garageStatusLabel.LayoutOrder = 1

openGarageButton = UIStyle.createButton(garageContainer, {
    name = "OpenGarageButton",
    text = "Open Console",
    size = UDim2.new(0, 180, 0, 36),
    textSize = 15,
})
openGarageButton:SetAttribute("BaseColor", openGarageButton.BackgroundColor3)
openGarageButton.LayoutOrder = 2
openGarageButton.Activated:Connect(function()
    openGarageMenu()
    refreshQuickButtons()
end)

local quickHint = UIStyle.createLabel(garageContainer, {
    name = "GarageQuickHint",
    text = "Quick hatch using available blueprints:",
    textSize = 13,
    color = UIStyle.colors.textSecondary,
})
quickHint.LayoutOrder = 3

local quickRow = Instance.new("Frame")
quickRow.Name = "GarageQuickRow"
quickRow.Size = UDim2.new(1, 0, 0, 0)
quickRow.AutomaticSize = Enum.AutomaticSize.Y
quickRow.BackgroundTransparency = 1
quickRow.LayoutOrder = 4
quickRow.Parent = garageContainer

local quickLayout = Instance.new("UIGridLayout")
quickLayout.CellSize = UDim2.new(0, 130, 0, 40)
quickLayout.CellPadding = UDim2.new(0, 8, 0, 8)
quickLayout.FillDirectionMaxCells = 3
quickLayout.HorizontalAlignment = Enum.HorizontalAlignment.Left
quickLayout.SortOrder = Enum.SortOrder.LayoutOrder
quickLayout.Parent = quickRow

local quickOrder = {"Basic", "Advanced", "Elite"}
for _, robotType in ipairs(quickOrder) do
    local definition = RobotTypes[robotType]
    if definition then
        local button = UIStyle.createButton(quickRow, {
            name = robotType .. "QuickHatch",
            text = "Hatch " .. definition.Name,
            textSize = 14,
            size = UDim2.new(0, 130, 0, 40),
            backgroundColor = Color3.fromRGB(70, 140, 100),
        })
        button:SetAttribute("BaseColor", button.BackgroundColor3)

        table.insert(quickButtons, {
            button = button,
            definition = definition,
            robotType = robotType,
            baseColor = button.BackgroundColor3,
        })

        button.Activated:Connect(function()
            if GarageUI.isBusy() then
                openGarageMenu()
                return
            end

            if not playerHasResources(definition) then
                GarageUI.showInsufficientResources()
                refreshQuickButtons()
                return
            end

            if not GarageUI.requestHatch(robotType) then
                refreshQuickButtons()
                return
            end

            local success = attemptGarageHatch(robotType, definition)
            if not success then
                GarageUI.handleStatus("failed", {
                    robotType = robotType,
                    message = "Garage request could not be sent.",
                })
            end
            refreshQuickButtons()
        end)
    end
end

setGarageStatus("Garage ready")

local robotConnections = {}

local function disconnectRobot(folder)
    local connections = robotConnections[folder]
    if not connections then
        return
    end

    for _, connection in ipairs(connections) do
        connection:Disconnect()
    end
    robotConnections[folder] = nil
end

local function refreshOperations()
    RobotUIManager.renderOperations(robotListFrame, resourceBoard, remotesBundle)
end

local function observeRobot(folder)
    if robotConnections[folder] then
        return
    end

    local connections = {}

    local function bind(signal)
        local conn = signal:Connect(refreshOperations)
        table.insert(connections, conn)
    end

    bind(folder:GetAttributeChangedSignal("TaskState"))
    bind(folder:GetAttributeChangedSignal("CargoAmount"))
    bind(folder:GetAttributeChangedSignal("CargoCurrency"))

    local robotState = folder:FindFirstChild("RobotState")
    if robotState then
        table.insert(connections, robotState.Changed:Connect(refreshOperations))
    end

    local targetValue = folder:FindFirstChild("TargetResource")
    if targetValue then
        table.insert(connections, targetValue.Changed:Connect(refreshOperations))
    end

    table.insert(connections, folder.ChildAdded:Connect(function(child)
        if child.Name == "RobotState" or child.Name == "TargetResource" then
            if child:IsA("ValueBase") then
                table.insert(connections, child.Changed:Connect(refreshOperations))
            end
            refreshOperations()
        end
    end))

    table.insert(connections, folder.Destroying:Connect(function()
        disconnectRobot(folder)
        refreshOperations()
    end))

    robotConnections[folder] = connections
end

local function isPlayerRobotFolder(instance)
    if not instance:IsA("Folder") then
        return false
    end

    local ownerValue = instance:FindFirstChild("Owner")
    if not ownerValue or ownerValue.Value ~= Player then
        return false
    end

    return instance:FindFirstChild("RobotState") ~= nil
end

for _, child in ipairs(Workspace:GetChildren()) do
    if isPlayerRobotFolder(child) then
        observeRobot(child)
    end
end

Workspace.ChildAdded:Connect(function(child)
    if isPlayerRobotFolder(child) then
        observeRobot(child)
        refreshOperations()
    end
end)

Workspace.ChildRemoved:Connect(function(child)
    if robotConnections[child] then
        disconnectRobot(child)
        refreshOperations()
    end
end)

refreshOperations()

local function attachLeaderstats(leaderstats)
    leaderstats.ChildAdded:Connect(function(child)
        if child:IsA("IntValue") then
            child.Changed:Connect(refreshQuickButtons)
            refreshQuickButtons()
        end
    end)

    leaderstats.ChildRemoved:Connect(refreshQuickButtons)

    for _, stat in ipairs(leaderstats:GetChildren()) do
        if stat:IsA("IntValue") then
            stat.Changed:Connect(refreshQuickButtons)
        end
    end

    refreshQuickButtons()
end

local existingLeaderstats = Player:FindFirstChild("leaderstats")
if existingLeaderstats then
    attachLeaderstats(existingLeaderstats)
end

Player.ChildAdded:Connect(function(child)
    if child.Name == "leaderstats" and child:IsA("Folder") then
        attachLeaderstats(child)
    end
end)

GarageStatusEvent.OnClientEvent:Connect(function(status, payload)
    payload = payload or {}

    GarageUI.handleStatus(status, payload)

    local token

    if status == "started" then
        local robotType = payload.robotType
        local definition = robotType and RobotTypes[robotType]
        local label = definition and definition.Name or robotType or "Robot"
        token = setGarageStatus("Constructing " .. label .. "…")
    elseif status == "completed" then
        local robotName = payload.robotName or "Robot"
        token = setGarageStatus(robotName .. " deployed.")
        resetGarageStatusAfter(4, token)
        refreshOperations()
    elseif status == "failed" then
        local message = payload.message or "Garage unavailable."
        token = setGarageStatus(message)
        resetGarageStatusAfter(4, token)
    end

    refreshQuickButtons()
end)

local function bindGaragePrompt(prompt)
    if prompt.Name ~= "GaragePrompt" then
        return
    end
    if prompt:GetAttribute("GarageBound") then
        return
    end

    prompt:SetAttribute("GarageBound", true)
    prompt.ActionText = "Hatch Robot"
    prompt.ObjectText = "Garage Console"
    prompt.RequiresLineOfSight = false
    prompt.MaxActivationDistance = 9
    prompt.HoldDuration = 0.5

    prompt.Triggered:Connect(function(otherPlayer)
        if otherPlayer and otherPlayer ~= Player then
            return
        end
        openGarageMenu()
    end)

    prompt.TriggerEnded:Connect(function()
        GarageUI.close()
    end)
end

for _, descendant in ipairs(Workspace:GetDescendants()) do
    if descendant:IsA("ProximityPrompt") then
        bindGaragePrompt(descendant)
    end
end

Workspace.DescendantAdded:Connect(function(descendant)
    if descendant:IsA("ProximityPrompt") then
        bindGaragePrompt(descendant)
    end
end)

ProximityPromptService.PromptHidden:Connect(function(prompt)
    if prompt.Name == "GaragePrompt" then
        GarageUI.close()
    end
end)
