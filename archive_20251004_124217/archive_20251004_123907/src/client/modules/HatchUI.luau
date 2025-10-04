--!strict

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local ModalManager = require(script.Parent.ModalManager)
local UIFactory = require(script.Parent.Parent.ui.UIFactory)

local player = Players.LocalPlayer
local Remotes = ReplicatedStorage:WaitForChild("Remotes")
local HatchRobotEvent: RemoteEvent = Remotes:WaitForChild("HatchRobot")

local Shared = ReplicatedStorage:WaitForChild("Shared")
local Config = Shared:WaitForChild("config")
local RobotTypes = require(Config:WaitForChild("RobotTypes"))

local HatchUI = {}

local card: Frame?

local ROBOT_ORDER = {"Basic", "Advanced", "Elite"}

local function formatCost(costs: {[string]: number}?): string
    if not costs then
        return ""
    end
    local segments = {}
    for currency, amount in pairs(costs) do
        table.insert(segments, string.format("%s: %d", currency, amount))
    end
    table.sort(segments)
    return table.concat(segments, "  •  ")
end

local function createEntry(parent: Frame, robotType: string)
    local definition = RobotTypes[robotType]
    if not definition then
        return
    end

    local entry = Instance.new("Frame")
    entry.Name = robotType .. "Entry"
    entry.LayoutOrder = 10
    entry.Size = UDim2.new(1, 0, 0, 118)
    entry.BackgroundTransparency = 1
    entry.Parent = parent

    local layout = Instance.new("UIListLayout")
    layout.FillDirection = Enum.FillDirection.Vertical
    layout.SortOrder = Enum.SortOrder.LayoutOrder
    layout.Padding = UDim.new(0, 6)
    layout.Parent = entry

    local title = UIFactory.smallLabel(definition.Name or robotType)
    title.Font = Enum.Font.GothamSemibold
    title.TextSize = 20
    title.LayoutOrder = 1
    title.Parent = entry

    local detail = UIFactory.smallLabel(definition.Description or "Reliable automated miner")
    detail.TextColor3 = Color3.fromRGB(180, 190, 205)
    detail.TextSize = 16
    detail.LayoutOrder = 2
    detail.Parent = entry

    local costLabel = UIFactory.smallLabel(formatCost(definition.Cost))
    costLabel.TextColor3 = Color3.fromRGB(160, 170, 190)
    costLabel.TextSize = 15
    costLabel.LayoutOrder = 3
    costLabel.Parent = entry

    local buttonRow = Instance.new("Frame")
    buttonRow.BackgroundTransparency = 1
    buttonRow.Size = UDim2.new(1, 0, 0, 40)
    buttonRow.LayoutOrder = 4
    buttonRow.Parent = entry

    local rowLayout = Instance.new("UIListLayout")
    rowLayout.FillDirection = Enum.FillDirection.Horizontal
    rowLayout.VerticalAlignment = Enum.VerticalAlignment.Center
    rowLayout.Padding = UDim.new(0, 8)
    rowLayout.Parent = buttonRow

    local hatchButton = UIFactory.button("primary", "Hatch")
    hatchButton.Size = UDim2.fromOffset(140, 36)
    hatchButton.Parent = buttonRow
    hatchButton.MouseButton1Click:Connect(function()
        HatchRobotEvent:FireServer(robotType, 1)
    end)
end

local function ensureCard(): Frame
    if card and card.Parent then
        return card
    end

    local frame = UIFactory.card("Hatch Robots")

    local intro = UIFactory.smallLabel("Spend resources to grow your task force.")
    intro.LayoutOrder = 1
    intro.Parent = frame

    local contentContainer = Instance.new("Frame")
    contentContainer.BackgroundTransparency = 1
    contentContainer.Size = UDim2.new(1, 0, 1, -120)
    contentContainer.LayoutOrder = 2
    contentContainer.Parent = frame

    local listLayout = Instance.new("UIListLayout")
    listLayout.FillDirection = Enum.FillDirection.Vertical
    listLayout.SortOrder = Enum.SortOrder.LayoutOrder
    listLayout.Padding = UDim.new(0, 12)
    listLayout.Parent = contentContainer

    for _, robotType in ipairs(ROBOT_ORDER) do
        createEntry(contentContainer, robotType)
    end

    card = frame
    return frame
end

function HatchUI.open()
    local frame = ensureCard()
    ModalManager.open("hatch", frame)
end

function HatchUI.close()
    if ModalManager.getCurrentKey() == "hatch" then
        ModalManager.close()
    end
end

function HatchUI.toggle()
    if ModalManager.getCurrentKey() == "hatch" then
        HatchUI.close()
    else
        HatchUI.open()
    end
end

return HatchUI
