--!strict

print("🎮 Robot Collectors: Client Starting... v3.5-UI")

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local ProximityPromptService = game:GetService("ProximityPromptService")
local Workspace = game:GetService("Workspace")
local StarterGui = game:GetService("StarterGui")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

local Remotes = ReplicatedStorage:WaitForChild("Remotes")
local remoteBundle = {
    HatchRobot = Remotes:WaitForChild("HatchRobot"),
    SetRobotState = Remotes:WaitForChild("SetRobotState"),
    ManualMine = Remotes:WaitForChild("ManualMine"),
    AssignRobotToResource = Remotes:WaitForChild("AssignRobotToResource"),
    GarageStatus = Remotes:WaitForChild("GarageStatus"),
    GarageConsole = Remotes:WaitForChild("GarageConsole"),
    ToggleGarageDoor = Remotes:WaitForChild("ToggleGarageDoor"),
}

-- Core modules
local ModalManager = require(script.modules.ModalManager)
local Taskbar = require(script.modules.Taskbar)
local HatchUI = require(script.modules.HatchUI)
local AssignUI = require(script.modules.AssignUI)
local GarageUI = require(script.modules.GarageUI)
local ResourceManager = require(script.modules.ResourceManager)
local InputManager = require(script.modules.InputManager)
local RobotUIManager = require(script.modules.RobotUIManager)

-- Main GUI setup
local mainGui = Instance.new("ScreenGui")
mainGui.Name = "RobotCollectorsUI"
mainGui.ResetOnSpawn = false
mainGui.IgnoreGuiInset = true
mainGui.DisplayOrder = 10
mainGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
mainGui.Parent = playerGui

local RunService = game:GetService("RunService")
local camera = Workspace.CurrentCamera
local scale = Instance.new("UIScale")
scale.Name = "AdaptiveScale"
scale.Parent = mainGui

local function computeScale(viewportSize: Vector2): number
    return math.clamp(math.min(viewportSize.X / 1920, viewportSize.Y / 1080), 0.85, 1.15)
end

local function applyScale()
    local vs = camera and camera.ViewportSize or Vector2.new(1920, 1080)
    scale.Scale = computeScale(vs)
end

if not camera then
    Workspace:GetPropertyChangedSignal("CurrentCamera"):Wait()
    camera = Workspace.CurrentCamera
end

RunService.RenderStepped:Wait()
applyScale()

local lastViewport = camera and camera.ViewportSize or Vector2.new(1920, 1080)
RunService.Heartbeat:Connect(function()
    if not camera then
        camera = Workspace.CurrentCamera
        if not camera then
            return
        end
    end

    local current = camera.ViewportSize
    if current ~= lastViewport then
        lastViewport = current
        applyScale()
    end
end)

-- Resource HUD (top-left)
local resourcePanel = Instance.new("Frame")
resourcePanel.Name = "ResourcePanel"
resourcePanel.Size = UDim2.new(0, 280, 0, 160)
resourcePanel.Position = UDim2.new(0, 12, 0, 12)
resourcePanel.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
resourcePanel.BackgroundTransparency = 0.08
resourcePanel.BorderSizePixel = 0
resourcePanel.Parent = mainGui

local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0, 12)
corner.Parent = resourcePanel

local labels = {}
local labelInfo = {
    {name = "Gearbits", icon = "⚙️", color = Color3.fromRGB(0, 212, 255), order = 0},
    {name = "IonShards", icon = "⚡", color = Color3.fromRGB(150, 0, 255), order = 1},
    {name = "RareMetals", icon = "🥇", color = Color3.fromRGB(255, 215, 0), order = 2},
    {name = "Crystals", icon = "💎", color = Color3.fromRGB(255, 100, 255), order = 3},
}

for _, info in ipairs(labelInfo) do
    local label = Instance.new("TextLabel")
    label.Name = info.name .. "Label"
    label.BackgroundTransparency = 1
    label.Size = UDim2.new(1, 0, 0.25, 0)
    label.Position = UDim2.new(0, 0, info.order * 0.25, 4)
    label.Font = Enum.Font.GothamBold
    label.TextScaled = true
    label.TextColor3 = info.color
    label.Text = string.format("%s %s: 0", info.icon, info.name)
    label.Parent = resourcePanel
    labels[info.name] = label
end

ResourceManager.updateResourceDisplay({
    gearbits = labels.Gearbits,
    ionShards = labels.IonShards,
    rareMetals = labels.RareMetals,
    crystals = labels.Crystals,
})
ResourceManager.connectLeaderstats(function()
    ResourceManager.updateResourceDisplay({
        gearbits = labels.Gearbits,
        ionShards = labels.IonShards,
        rareMetals = labels.RareMetals,
        crystals = labels.Crystals,
    })
end)

-- Modal + feature modules
ModalManager.init(mainGui)

GarageUI.init({
    GarageConsole = remoteBundle.GarageConsole,
    GarageStatus = remoteBundle.GarageStatus,
    ToggleGarageDoor = remoteBundle.ToggleGarageDoor,
})

AssignUI.init({
    AssignRobotToResource = remoteBundle.AssignRobotToResource,
    SetRobotState = remoteBundle.SetRobotState,
    GarageConsole = remoteBundle.GarageConsole,
})

Taskbar.init(mainGui, {
    onGarage = function()
        GarageUI.toggle()
    end,
    onHatch = function()
        HatchUI.toggle()
    end,
    onAssign = function()
        AssignUI.toggle()
    end,
    garageEnabled = function()
        return GarageUI.isInRange()
    end,
    garageHint = function()
        return GarageUI.hint()
    end,
})

-- Hotkeys (G/H/A)
UserInputService.InputBegan:Connect(function(input, processed)
    if processed then
        return
    end

    if input.KeyCode == Enum.KeyCode.G then
        GarageUI.toggle()
    elseif input.KeyCode == Enum.KeyCode.H then
        HatchUI.toggle()
    elseif input.KeyCode == Enum.KeyCode.A then
        AssignUI.toggle()
    end
end)

-- Manual mining + targeting support
local remotesForInput = {
    AssignRobotToResource = remoteBundle.AssignRobotToResource,
    ManualMine = remoteBundle.ManualMine,
}

InputManager.setupMiningInput(remotesForInput, RobotUIManager, function()
    AssignUI.refresh()
end)

-- Keep Roblox leaderboard visible (ensure not disabled elsewhere)
StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.PlayerList, true)

print("🎮 Robot Collectors client initialized with streamlined HUD")
