--!strict

local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local ModalManager = require(script.Parent.ModalManager)
local UIFactory = require(script.Parent.Parent.ui.UIFactory)
local RobotUIManager = require(script.Parent.RobotUIManager)
local HatchUI = require(script.Parent.HatchUI)

local player = Players.LocalPlayer
local Remotes = ReplicatedStorage:WaitForChild("Remotes")
local RobotCountChanged: RemoteEvent = Remotes:WaitForChild("RobotCountChanged")

local AssignUI = {}

local remotesBundle: {[string]: RemoteEvent} = {}
local card: Frame?
local emptyState: Frame?
local populatedState: Frame?
local robotListFrame: ScrollingFrame?
local resourceBoard: ScrollingFrame?
local hasRobots = false

local function clearChildren(frame: GuiObject)
    for _, child in ipairs(frame:GetChildren()) do
        if not child:IsA("UIBase") then
            child:Destroy()
        end
    end
end

local function ensureEmptyState(container: Frame)
    if emptyState then
        return
    end

    local frame = Instance.new("Frame")
    frame.BackgroundTransparency = 1
    frame.LayoutOrder = 1
    frame.Size = UDim2.new(1, 0, 0, 160)
    frame.Parent = container

    local layout = Instance.new("UIListLayout")
    layout.FillDirection = Enum.FillDirection.Vertical
    layout.SortOrder = Enum.SortOrder.LayoutOrder
    layout.Padding = UDim.new(0, 8)
    layout.Parent = frame

    local title = UIFactory.smallLabel("No robots yet.")
    title.Font = Enum.Font.GothamSemibold
    title.TextSize = 20
    title.LayoutOrder = 1
    title.Parent = frame

    local detail = UIFactory.smallLabel("Hatch a bot to assemble your first task force.")
    detail.TextColor3 = Color3.fromRGB(196, 205, 220)
    detail.TextSize = 16
    detail.LayoutOrder = 2
    detail.Parent = frame

    local openButton = UIFactory.button("primary", "Open Hatch")
    openButton.Size = UDim2.fromOffset(160, 40)
    openButton.LayoutOrder = 3
    openButton.Parent = frame
    openButton.MouseButton1Click:Connect(function()
        ModalManager.close()
        HatchUI.open()
    end)

    emptyState = frame
end

local function ensurePopulatedState(container: Frame)
    if populatedState then
        return
    end

    local frame = Instance.new("Frame")
    frame.BackgroundTransparency = 1
    frame.LayoutOrder = 2
    frame.Size = UDim2.new(1, 0, 1, -200)
    frame.Parent = container

    local layout = Instance.new("UIListLayout")
    layout.FillDirection = Enum.FillDirection.Vertical
    layout.SortOrder = Enum.SortOrder.LayoutOrder
    layout.Padding = UDim.new(0, 10)
    layout.Parent = frame

    local rosterLabel = UIFactory.smallLabel("Task Force")
    rosterLabel.Font = Enum.Font.GothamSemibold
    rosterLabel.TextSize = 18
    rosterLabel.LayoutOrder = 1
    rosterLabel.Parent = frame

    robotListFrame = Instance.new("ScrollingFrame")
    robotListFrame.Name = "RobotList"
    robotListFrame.LayoutOrder = 2
    robotListFrame.Size = UDim2.new(1, 0, 0, 260)
    robotListFrame.BackgroundTransparency = 1
    robotListFrame.ScrollBarThickness = 6
    robotListFrame.AutomaticCanvasSize = Enum.AutomaticSize.Y
    robotListFrame.CanvasSize = UDim2.new()
    robotListFrame.Parent = frame

    local robotLayout = Instance.new("UIListLayout")
    robotLayout.SortOrder = Enum.SortOrder.LayoutOrder
    robotLayout.Padding = UDim.new(0, 8)
    robotLayout.Parent = robotListFrame

    local assignmentsLabel = UIFactory.smallLabel("Assignments")
    assignmentsLabel.Font = Enum.Font.GothamSemibold
    assignmentsLabel.TextSize = 18
    assignmentsLabel.LayoutOrder = 3
    assignmentsLabel.Parent = frame

    resourceBoard = Instance.new("ScrollingFrame")
    resourceBoard.Name = "ResourceBoard"
    resourceBoard.LayoutOrder = 4
    resourceBoard.Size = UDim2.new(1, 0, 0, 180)
    resourceBoard.BackgroundTransparency = 1
    resourceBoard.ScrollBarThickness = 6
    resourceBoard.AutomaticCanvasSize = Enum.AutomaticSize.Y
    resourceBoard.CanvasSize = UDim2.new()
    resourceBoard.Parent = frame

    local resourceLayout = Instance.new("UIListLayout")
    resourceLayout.SortOrder = Enum.SortOrder.LayoutOrder
    resourceLayout.Padding = UDim.new(0, 8)
    resourceLayout.Parent = resourceBoard

    populatedState = frame
end

local function updateState()
    if not card then
        return
    end

    if emptyState then
        emptyState.Visible = not hasRobots
    end
    if populatedState then
        populatedState.Visible = hasRobots
    end

    if hasRobots and robotListFrame and resourceBoard then
        RobotUIManager.renderOperations(robotListFrame, resourceBoard, remotesBundle)
    elseif robotListFrame and resourceBoard then
        clearChildren(robotListFrame)
        clearChildren(resourceBoard)
    end
end

local function computeCurrentRobotCount(): number
    local count = 0
    for _, child in ipairs(Workspace:GetChildren()) do
        if child:IsA("Folder") then
            local ownerValue = child:FindFirstChild("Owner")
            local stateValue = child:FindFirstChild("RobotState")
            if ownerValue and ownerValue.Value == player and stateValue and stateValue.Value ~= "garage_idle" then
                count += 1
            end
        end
    end
    return count
end

local function ensureCard(): Frame
    if card and card.Parent then
        return card
    end

    local frame = UIFactory.card("Assignments")

    ensureEmptyState(frame)
    ensurePopulatedState(frame)

    card = frame
    return frame
end

local function setRobotCount(count: number)
    hasRobots = count > 0
    updateState()
end

function AssignUI.init(remotes: {[string]: RemoteEvent})
    remotesBundle = remotes
    ensureCard()
    setRobotCount(computeCurrentRobotCount())
    RobotCountChanged.OnClientEvent:Connect(function(count)
        setRobotCount(count)
    end)
end

function AssignUI.open()
    local frame = ensureCard()
    updateState()
    ModalManager.open("assign", frame)
end

function AssignUI.close()
    if ModalManager.getCurrentKey() == "assign" then
        ModalManager.close()
    end
end

function AssignUI.toggle()
    if ModalManager.getCurrentKey() == "assign" then
        AssignUI.close()
    else
        AssignUI.open()
    end
end

function AssignUI.refresh()
    updateState()
end

return AssignUI
