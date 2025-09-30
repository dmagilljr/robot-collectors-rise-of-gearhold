-- Robot Collectors: GUI Management System
-- Handles all UI creation and management

local Players = game:GetService("Players")

local Player = Players.LocalPlayer
local PlayerGui = Player:WaitForChild("PlayerGui")

local GuiManager = {}

function GuiManager.createMainGui()
    local mainGui = Instance.new("ScreenGui")
    mainGui.Name = "RobotCollectorsGUI"
    mainGui.Parent = PlayerGui
    return mainGui
end

function GuiManager.createResourcePanel(parent)
    local resourcePanel = Instance.new("Frame")
    resourcePanel.Name = "ResourcePanel"
    resourcePanel.Size = UDim2.new(0, 280, 0, 160)
    resourcePanel.Position = UDim2.new(0, 10, 0, 10)
    resourcePanel.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
    resourcePanel.BackgroundTransparency = 0.1
    resourcePanel.Parent = parent

    local resourceCorner = Instance.new("UICorner")
    resourceCorner.CornerRadius = UDim.new(0, 12)
    resourceCorner.Parent = resourcePanel

    -- Create resource labels
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

    return {
        panel = resourcePanel,
        labels = {
            gearbits = gearbitLabel,
            ionShards = ionLabel,
            rareMetals = metalLabel,
            crystals = crystalLabel
        }
    }
end

function GuiManager.createRobotPanel(parent)
    local robotPanel = Instance.new("Frame")
    robotPanel.Name = "RobotPanel"
    robotPanel.Size = UDim2.new(0, 320, 0, 420)
    robotPanel.Position = UDim2.new(1, -340, 0.5, -210)
    robotPanel.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
    robotPanel.BackgroundTransparency = 0.1
    robotPanel.Parent = parent

    local robotCorner = Instance.new("UICorner")
    robotCorner.CornerRadius = UDim.new(0, 12)
    robotCorner.Parent = robotPanel

    local robotTitle = Instance.new("TextLabel")
    robotTitle.Size = UDim2.new(1, 0, 0, 40)
    robotTitle.Position = UDim2.new(0, 0, 0, 0)
    robotTitle.BackgroundTransparency = 1
    robotTitle.Text = "🤖 Robot Management"
    robotTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
    robotTitle.TextScaled = true
    robotTitle.Font = Enum.Font.GothamBold
    robotTitle.Parent = robotPanel

    local robotScrollFrame = Instance.new("ScrollingFrame")
    robotScrollFrame.Size = UDim2.new(1, -20, 1, -60)
    robotScrollFrame.Position = UDim2.new(0, 10, 0, 50)
    robotScrollFrame.BackgroundTransparency = 1
    robotScrollFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
    robotScrollFrame.ScrollBarThickness = 8
    robotScrollFrame.Parent = robotPanel

    local listLayout = Instance.new("UIListLayout")
    listLayout.SortOrder = Enum.SortOrder.LayoutOrder
    listLayout.Padding = UDim.new(0, 5)
    listLayout.Parent = robotScrollFrame

    return {
        panel = robotPanel,
        scrollFrame = robotScrollFrame
    }
end

function GuiManager.createHatchPanel(parent)
    local hatchPanel = Instance.new("Frame")
    hatchPanel.Name = "HatchPanel"
    hatchPanel.Size = UDim2.new(0, 250, 0, 100)
    hatchPanel.Position = UDim2.new(0.5, -125, 1, -120)
    hatchPanel.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
    hatchPanel.BackgroundTransparency = 0.1
    hatchPanel.Parent = parent

    local hatchCorner = Instance.new("UICorner")
    hatchCorner.CornerRadius = UDim.new(0, 12)
    hatchCorner.Parent = hatchPanel

    local hatchButton = Instance.new("TextButton")
    hatchButton.Size = UDim2.new(1, -10, 0.5, -5)
    hatchButton.Position = UDim2.new(0, 5, 0, 5)
    hatchButton.BackgroundColor3 = Color3.fromRGB(0, 200, 100)
    hatchButton.Text = "🥚 Hatch Basic Robot (50 ⚙️)"
    hatchButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    hatchButton.TextScaled = true
    hatchButton.Font = Enum.Font.GothamBold
    hatchButton.Parent = hatchPanel

    local hatchButtonCorner = Instance.new("UICorner")
    hatchButtonCorner.CornerRadius = UDim.new(0, 8)
    hatchButtonCorner.Parent = hatchButton

    local advancedButton = Instance.new("TextButton")
    advancedButton.Size = UDim2.new(1, -10, 0.5, -5)
    advancedButton.Position = UDim2.new(0, 5, 0.5, 0)
    advancedButton.BackgroundColor3 = Color3.fromRGB(0, 150, 200)
    advancedButton.Text = "⚡ Hatch Advanced Robot (25 ⚙️ + 15 ⚡)"
    advancedButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    advancedButton.TextScaled = true
    advancedButton.Font = Enum.Font.GothamBold
    advancedButton.Parent = hatchPanel

    local advancedButtonCorner = Instance.new("UICorner")
    advancedButtonCorner.CornerRadius = UDim.new(0, 8)
    advancedButtonCorner.Parent = advancedButton

    return {
        panel = hatchPanel,
        buttons = {
            basic = hatchButton,
            advanced = advancedButton
        }
    }
end

return GuiManager