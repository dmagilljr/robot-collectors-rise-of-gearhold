-- Robot Collectors: Robot Operations Console
-- Builds the robot roster and resource assignment UI

local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")

local Player = Players.LocalPlayer

local UIStyle = require(script.Parent.UIStyle)

local RobotUIManager = {}

local targetingRobot = nil

local RESOURCE_ICONS = {
    Gearbit = "⚙️",
    ["Ion Shard"] = "⚡",
    ["Rare Metal"] = "🥇",
    Crystal = "💎",
}

local function clearGui(parent)
    for _, child in ipairs(parent:GetChildren()) do
        if child:IsA("GuiObject") then
            child:Destroy()
        end
    end
end

local function createLabel(parent, text, color, textSize, size)
    local props = {
        text = text,
        color = color,
        textSize = textSize,
    }

    if size then
        props.size = size
        props.automaticSize = Enum.AutomaticSize.None
    end

    return UIStyle.createLabel(parent, props)
end

local function primaryButton(parent, text, size)
    return UIStyle.createButton(parent, {
        text = text,
        size = size,
        textSize = 14,
    })
end

local function stateChip(parent, text, color)
    local chip = Instance.new("Frame")
    chip.Size = UDim2.new(0, 110, 0, 26)
    chip.BackgroundColor3 = color
    chip.BackgroundTransparency = 0.1
    chip.Parent = parent

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 6)
    corner.Parent = chip

    local label = Instance.new("TextLabel")
    label.BackgroundTransparency = 1
    label.Size = UDim2.new(1, 0, 1, 0)
    label.Text = text
    label.TextColor3 = Color3.fromRGB(255, 255, 255)
    label.TextScaled = false
    label.TextSize = 14
    label.Font = Enum.Font.GothamSemibold
    label.Parent = chip
    return chip
end

local function formatCargo(amount, currency)
    if not amount or amount <= 0 or not currency or currency == "" then
        return "Cargo: –"
    end
    return string.format("Cargo: %d %s", amount, currency)
end

local function gatherRobots()
    local robots = {}
    for _, obj in ipairs(Workspace:GetChildren()) do
        if obj:IsA("Folder") and obj:FindFirstChild("Owner") and obj:FindFirstChild("RobotState") then
            local owner = obj.Owner.Value
            if owner == Player then
                local unique = obj:FindFirstChild("UniqueId")
                local id = unique and unique.Value:sub(1, 8) or obj.Name
                local state = obj.RobotState.Value
                local taskState = obj:GetAttribute("TaskState") or state
                local targetValue = obj:FindFirstChild("TargetResource")
                local targetName = "None"
                if targetValue and targetValue.Value then
                    targetName = targetValue.Value.Name
                end
                table.insert(robots, {
                    name = obj.Name:split("_")[1],
                    id = id,
                    state = state,
                    taskState = taskState,
                    folder = obj,
                    target = targetName,
                    cargoAmount = obj:GetAttribute("CargoAmount"),
                    cargoCurrency = obj:GetAttribute("CargoCurrency"),
                })
            end
        end
    end
    table.sort(robots, function(a, b)
        return a.name < b.name
    end)
    return robots
end

local function gatherResources(referencePosition)
    local resources = {}
    for _, obj in ipairs(Workspace:GetChildren()) do
        if obj:IsA("BasePart") and obj.Name:match("^Resource_%d+$") then
            local typeValue = obj:FindFirstChild("ResourceType")
            local healthValue = obj:FindFirstChild("ResourceHealth")
            local originalSize = obj:FindFirstChild("OriginalSize")
            if typeValue and healthValue and originalSize then
                local maxHealth = math.max(1, originalSize.Value * 3)
                local distance = referencePosition and (obj.Position - referencePosition).Magnitude or 0
                table.insert(resources, {
                    name = obj.Name,
                    resourceType = typeValue.Value,
                    health = healthValue.Value,
                    maxHealth = maxHealth,
                    distance = distance,
                })
            end
        end
    end

    table.sort(resources, function(a, b)
        return a.distance < b.distance
    end)
    return resources
end

local function buildRobotCard(robotListFrame, resourceBoard, robot, remotes)
    local card = Instance.new("Frame")
    card.Size = UDim2.new(1, 0, 0, 88)
    card.BackgroundColor3 = targetingRobot and targetingRobot.id == robot.id and Color3.fromRGB(55, 70, 100) or Color3.fromRGB(35, 40, 55)
    card.BackgroundTransparency = 0.05
    card.Parent = robotListFrame

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 10)
    corner.Parent = card

    local padding = Instance.new("UIPadding")
    padding.PaddingTop = UDim.new(0, 10)
    padding.PaddingBottom = UDim.new(0, 10)
    padding.PaddingLeft = UDim.new(0, 12)
    padding.PaddingRight = UDim.new(0, 12)
    padding.Parent = card

    local layout = Instance.new("UIListLayout")
    layout.FillDirection = Enum.FillDirection.Horizontal
    layout.HorizontalAlignment = Enum.HorizontalAlignment.Left
    layout.Padding = UDim.new(0, 12)
    layout.Parent = card

    local infoColumn = Instance.new("Frame")
    infoColumn.Size = UDim2.new(1, -130, 1, 0)
    infoColumn.BackgroundTransparency = 1
    infoColumn.Parent = card

    local infoLayout = Instance.new("UIListLayout")
    infoLayout.FillDirection = Enum.FillDirection.Vertical
    infoLayout.Padding = UDim.new(0, 4)
    infoLayout.Parent = infoColumn

    local header = Instance.new("Frame")
    header.Size = UDim2.new(1, 0, 0, 28)
    header.BackgroundTransparency = 1
    header.Parent = infoColumn

    local headerLayout = Instance.new("UIListLayout")
    headerLayout.FillDirection = Enum.FillDirection.Horizontal
    headerLayout.Padding = UDim.new(0, 8)
    headerLayout.Parent = header

    local nameLabel = Instance.new("TextLabel")
    nameLabel.BackgroundTransparency = 1
    nameLabel.Size = UDim2.new(0, 150, 1, 0)
    nameLabel.Text = "🤖 " .. robot.name
    nameLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    nameLabel.TextScaled = false
    nameLabel.TextSize = 16
    nameLabel.Font = Enum.Font.GothamBold
    nameLabel.TextXAlignment = Enum.TextXAlignment.Left
    nameLabel.Parent = header

    local stateColor = robot.state == "auto_mining" and Color3.fromRGB(70, 190, 120) or Color3.fromRGB(120, 130, 150)
    local stateText = robot.state == "auto_mining" and "Auto-mining" or "Following"
    stateChip(header, stateText, stateColor)

    createLabel(infoColumn, "Task: " .. (robot.taskState or "idle"), nil, 14)
    local targetText = robot.target and robot.target ~= "None" and ("Target: " .. robot.target) or "Awaiting assignment"
    createLabel(infoColumn, targetText, UIStyle.colors.textSecondary, 14)

    if robot.cargoAmount and robot.cargoAmount > 0 then
        createLabel(infoColumn, formatCargo(robot.cargoAmount, robot.cargoCurrency), UIStyle.colors.textSecondary, 13)
    end

    local actionsColumn = Instance.new("Frame")
    actionsColumn.Size = UDim2.new(0, 140, 1, 0)
    actionsColumn.BackgroundTransparency = 1
    actionsColumn.Parent = card

    local controlRow = Instance.new("Frame")
    controlRow.Size = UDim2.new(1, 0, 0, 32)
    controlRow.BackgroundTransparency = 1
    controlRow.Parent = actionsColumn

    local controlLayout = Instance.new("UIListLayout")
    controlLayout.FillDirection = Enum.FillDirection.Horizontal
    controlLayout.Padding = UDim.new(0, 4)
    controlLayout.Parent = controlRow

    local followButton = primaryButton(controlRow, "Follow", UDim2.new(0, 64, 1, 0))
    followButton.BackgroundColor3 = robot.state ~= "auto_mining" and Color3.fromRGB(90, 180, 120) or Color3.fromRGB(55, 70, 100)
    followButton.TextSize = 14
    followButton.Activated:Connect(function()
        remotes.SetRobotState:FireServer(robot.id, "following")
        task.delay(0.12, function()
            RobotUIManager.renderOperations(robotListFrame, resourceBoard, remotes)
        end)
    end)

    local autoButton = primaryButton(controlRow, "Auto", UDim2.new(0, 64, 1, 0))
    autoButton.BackgroundColor3 = robot.state == "auto_mining" and Color3.fromRGB(90, 180, 120) or Color3.fromRGB(55, 70, 100)
    autoButton.TextSize = 14
    autoButton.Activated:Connect(function()
        remotes.SetRobotState:FireServer(robot.id, "auto_mining")
        task.delay(0.12, function()
            RobotUIManager.renderOperations(robotListFrame, resourceBoard, remotes)
        end)
    end)

    local quickAssignRow = Instance.new("Frame")
    quickAssignRow.Size = UDim2.new(1, 0, 0, 32)
    quickAssignRow.BackgroundTransparency = 1
    quickAssignRow.Parent = actionsColumn

    local quickLayout = Instance.new("UIListLayout")
    quickLayout.FillDirection = Enum.FillDirection.Horizontal
    quickLayout.Padding = UDim.new(0, 4)
    quickLayout.Parent = quickAssignRow

    createLabel(quickAssignRow, "Auto Assign", Color3.fromRGB(200, 205, 220), 13, UDim2.new(0, 88, 1, 0))

    local quickTypes = {"Gearbit", "Ion Shard", "Rare Metal", "Crystal"}
    for _, option in ipairs(quickTypes) do
        local button = primaryButton(quickAssignRow, RESOURCE_ICONS[option] or option, UDim2.new(0, 36, 1, 0))
        button.BackgroundColor3 = Color3.fromRGB(60, 110, 160)
        button.TextSize = 14
        button.Activated:Connect(function()
            local body = robot.folder:FindFirstChild("RobotBody")
            local reference = body and body.Position or nil
            for _, resource in ipairs(gatherResources(reference)) do
                if resource.resourceType == option then
                local instance = Workspace:FindFirstChild(resource.name)
                    if instance then
                        remotes.AssignRobotToResource:FireServer(robot.id, instance)
                        targetingRobot = nil
                        task.delay(0.05, function()
                            RobotUIManager.renderOperations(robotListFrame, resourceBoard, remotes)
                        end)
                    end
                    break
                end
            end
        end)
    end

    local selectRow = Instance.new("Frame")
    selectRow.Size = UDim2.new(1, 0, 0, 32)
    selectRow.BackgroundTransparency = 1
    selectRow.Parent = actionsColumn

    local selectLayout = Instance.new("UIListLayout")
    selectLayout.FillDirection = Enum.FillDirection.Horizontal
    selectLayout.Padding = UDim.new(0, 4)
    selectLayout.Parent = selectRow

    local selectButton = primaryButton(selectRow, "Select Resource…", UDim2.new(1, 0, 1, 0))
    selectButton.BackgroundColor3 = Color3.fromRGB(90, 140, 210)
    selectButton.TextSize = 14
    selectButton.Activated:Connect(function()
        RobotUIManager.setTargetingRobot(robot)
        RobotUIManager.renderOperations(robotListFrame, resourceBoard, remotes)
    end)
end

function RobotUIManager.renderOperations(robotListFrame, resourceBoard, remotes)
    clearGui(robotListFrame)
    clearGui(resourceBoard)

    local robots = gatherRobots()

    if targetingRobot then
        local refreshedTarget = nil
        for _, robot in ipairs(robots) do
            if robot.id == targetingRobot.id then
                refreshedTarget = robot
                break
            end
        end
        targetingRobot = refreshedTarget
    end

    if #robots == 0 then
        createLabel(robotListFrame, "No robots active yet. Hatch a bot to get started.", Color3.fromRGB(200, 205, 220), 15)
    else
        for _, robot in ipairs(robots) do
            buildRobotCard(robotListFrame, resourceBoard, robot, remotes)
        end
    end

    local robotLayout = robotListFrame:FindFirstChildOfClass("UIListLayout")
    if robotListFrame:IsA("ScrollingFrame") and robotLayout then
        robotListFrame.CanvasSize = UDim2.new(0, 0, 0, robotLayout.AbsoluteContentSize.Y + 12)
    end

    if targetingRobot then
        createLabel(resourceBoard, string.format("Assigning %s", targetingRobot.name), Color3.fromRGB(220, 225, 235), 15)

        local prompt = createLabel(resourceBoard, "Pick a resource from the list or click one in the world.", Color3.fromRGB(180, 185, 200), 13)
        prompt.TextWrapped = true

        createLabel(resourceBoard, "Quick assign:", Color3.fromRGB(200, 205, 220), 13)

        local quickRow = Instance.new("Frame")
        quickRow.Size = UDim2.new(1, 0, 0, 0)
        quickRow.AutomaticSize = Enum.AutomaticSize.Y
        quickRow.BackgroundTransparency = 1
        quickRow.Parent = resourceBoard

        local quickLayout = Instance.new("UIGridLayout")
        quickLayout.CellSize = UDim2.new(0, 130, 0, 48)
        quickLayout.CellPadding = UDim2.new(0, 8, 0, 8)
        quickLayout.FillDirectionMaxCells = 2
        quickLayout.HorizontalAlignment = Enum.HorizontalAlignment.Left
        quickLayout.SortOrder = Enum.SortOrder.LayoutOrder
        quickLayout.Parent = quickRow

        local quickTypes = {"Gearbit", "Ion Shard", "Rare Metal", "Crystal"}
        for _, option in ipairs(quickTypes) do
            local labelText = string.format("%s %s", RESOURCE_ICONS[option] or "", option)
            local button = UIStyle.createButton(quickRow, {
                text = labelText,
                size = UDim2.new(1, 0, 0, 48),
                textSize = 14,
            })
            button.BackgroundColor3 = Color3.fromRGB(90, 140, 210)
            button.TextWrapped = true
            button.Activated:Connect(function()
                local body = targetingRobot and targetingRobot.folder and targetingRobot.folder:FindFirstChild("RobotBody")
                local reference = body and body.Position or nil
                for _, resource in ipairs(gatherResources(reference)) do
                    if resource.resourceType == option then
                        local instance = Workspace:FindFirstChild(resource.name)
                        if instance then
                            remotes.AssignRobotToResource:FireServer(targetingRobot.id, instance)
                            RobotUIManager.setTargetingRobot(nil)
                            task.delay(0.05, function()
                                RobotUIManager.renderOperations(robotListFrame, resourceBoard, remotes)
                            end)
                        end
                        break
                    end
                end
            end)
        end

        local cancelButton = primaryButton(resourceBoard, "Cancel Targeting", UDim2.new(0, 160, 0, 32))
        cancelButton.BackgroundColor3 = Color3.fromRGB(220, 120, 120)
        cancelButton.TextSize = 14
        cancelButton.Activated:Connect(function()
            RobotUIManager.setTargetingRobot(nil)
            RobotUIManager.renderOperations(robotListFrame, resourceBoard, remotes)
        end)
    else
        createLabel(resourceBoard, "Select a robot, then choose 'Select Resource…' to assign duties.", Color3.fromRGB(200, 205, 220), 13)
    end

    local layoutObject = resourceBoard:FindFirstChildOfClass("UIListLayout")
    if not layoutObject then
        layoutObject = resourceBoard:FindFirstChildOfClass("UIGridLayout")
    end
    if layoutObject then
        resourceBoard.CanvasSize = UDim2.new(0, 0, 0, layoutObject.AbsoluteContentSize.Y + 12)
    else
        resourceBoard.CanvasSize = UDim2.new()
    end
end

function RobotUIManager.getTargetingRobot()
    return targetingRobot
end

function RobotUIManager.setTargetingRobot(robot)
    targetingRobot = robot
end

return RobotUIManager
