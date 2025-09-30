-- Garage UI controller: handles garage prompt menu and local hatching feedback

local Players = game:GetService("Players")

local player = Players.LocalPlayer

local GarageUI = {}

local isHatching = false
local awaitingServer = false
local pendingRobotType
local uiRoot
local hatchMenu
local lastDefinitions
local lastOnHatch
local balanceLabels = {}

local CURRENCY_ORDER = {"Gearbits", "IonShards", "RareMetals", "Crystals"}
local CURRENCY_ICONS = {
    Gearbits = "⚙️",
    IonShards = "⚡",
    RareMetals = "🥇",
    Crystals = "💎",
}

local function ensureGui()
    if uiRoot and uiRoot.Parent then
        return uiRoot
    end

    uiRoot = Instance.new("ScreenGui")
    uiRoot.Name = "GarageUI"
    uiRoot.ResetOnSpawn = false
    uiRoot.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    uiRoot.Parent = player:WaitForChild("PlayerGui")
    return uiRoot
end

local function showToast(text, duration)
    ensureGui()

    if uiRoot:FindFirstChild("Toast") then
        uiRoot.Toast:Destroy()
    end

    local toast = Instance.new("Frame")
    toast.Name = "Toast"
    toast.Size = UDim2.new(0, 360, 0, 120)
    toast.Position = UDim2.new(0.5, -180, 0.8, -60)
    toast.BackgroundColor3 = Color3.fromRGB(20, 22, 31)
    toast.BackgroundTransparency = 0.15
    toast.BorderSizePixel = 0
    toast.Parent = uiRoot

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 12)
    corner.Parent = toast

    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, -24, 1, -24)
    label.Position = UDim2.new(0, 12, 0, 12)
    label.BackgroundTransparency = 1
    label.TextWrapped = true
    label.Text = text
    label.TextColor3 = Color3.fromRGB(230, 235, 245)
    label.TextSize = 18
    label.Font = Enum.Font.GothamSemibold
    label.Parent = toast

    task.delay(duration or 2, function()
        if toast.Parent then
            toast:Destroy()
        end
    end)
end

local function hideHatchMenu()
    if hatchMenu then
        hatchMenu:Destroy()
        hatchMenu = nil
    end
end

local function resetPending()
    awaitingServer = false
    pendingRobotType = nil
end

local function getCurrencyBalance(currency)
    local leaderstats = player:FindFirstChild("leaderstats")
    if not leaderstats then
        return 0
    end
    local stat = leaderstats:FindFirstChild(currency)
    return stat and stat.Value or 0
end

local function canAffordDefinition(definition)
    for currency, amount in pairs(definition.Cost or {}) do
        if getCurrencyBalance(currency) < amount then
            return false
        end
    end
    return true
end

local function describeCost(definition)
    local segments = {}
    for _, currency in ipairs(CURRENCY_ORDER) do
        local amount = definition.Cost and definition.Cost[currency]
        if amount and amount > 0 then
            local balance = getCurrencyBalance(currency)
            table.insert(segments, string.format("%d %s (You have %d)", amount, currency, balance))
        end
    end
    if #segments == 0 then
        return "Cost: Free"
    end
    return "Cost: " .. table.concat(segments, " • ")
end

local function refreshBalancePanel()
    for _, currency in ipairs(CURRENCY_ORDER) do
        local label = balanceLabels[currency]
        if label then
            local amount = getCurrencyBalance(currency)
            local icon = CURRENCY_ICONS[currency] or ""
            label.Text = string.format("%s %s: %d", icon, currency, amount)
        end
    end
end

local function buildRobotTypeRow(parent, robotType, definition, onSelected)
    local row = Instance.new("Frame")
    row.Size = UDim2.new(1, 0, 0, 70)
    row.BackgroundTransparency = 1
    row.Parent = parent

    local layout = Instance.new("UIListLayout")
    layout.FillDirection = Enum.FillDirection.Horizontal
    layout.Padding = UDim.new(0, 12)
    layout.VerticalAlignment = Enum.VerticalAlignment.Center
    layout.Parent = row

    local info = Instance.new("Frame")
    info.Size = UDim2.new(1, -130, 1, 0)
    info.BackgroundTransparency = 1
    info.Parent = row

    local infoLayout = Instance.new("UIListLayout")
    infoLayout.FillDirection = Enum.FillDirection.Vertical
    infoLayout.Padding = UDim.new(0, 4)
    infoLayout.Parent = info

    local nameLabel = Instance.new("TextLabel")
    nameLabel.BackgroundTransparency = 1
    nameLabel.Size = UDim2.new(1, 0, 0, 26)
    nameLabel.Text = string.format("%s (%s)", definition.Name, definition.Rarity)
    nameLabel.TextColor3 = Color3.fromRGB(240, 245, 255)
    nameLabel.TextSize = 18
    nameLabel.Font = Enum.Font.GothamBold
    nameLabel.TextXAlignment = Enum.TextXAlignment.Left
    nameLabel.Parent = info

    local costLabel = Instance.new("TextLabel")
    costLabel.BackgroundTransparency = 1
    costLabel.Size = UDim2.new(1, 0, 0, 22)
    costLabel.TextColor3 = Color3.fromRGB(200, 205, 220)
    costLabel.TextSize = 16
    costLabel.Font = Enum.Font.Gotham
    costLabel.TextXAlignment = Enum.TextXAlignment.Left
    costLabel.Parent = info

    costLabel.Text = describeCost(definition)

    local button = Instance.new("TextButton")
    button.Size = UDim2.new(0, 110, 0, 36)
    button.BackgroundColor3 = Color3.fromRGB(70, 140, 100)
    button.TextColor3 = Color3.fromRGB(255, 255, 255)
    button.TextSize = 16
    button.Font = Enum.Font.GothamSemibold
    button.Text = "Hatch"
    button.AutoButtonColor = true
    button.Parent = row

    local function refreshButton()
        local affordable = canAffordDefinition(definition)
        local busy = GarageUI.isBusy()
        local enabled = affordable and not busy
        button.BackgroundColor3 = enabled and Color3.fromRGB(70, 140, 100) or Color3.fromRGB(90, 90, 110)
        button.AutoButtonColor = enabled
        button.TextTransparency = enabled and 0 or 0.25
        costLabel.Text = describeCost(definition)
        costLabel.TextColor3 = affordable and Color3.fromRGB(200, 205, 220) or Color3.fromRGB(235, 120, 120)
    end

    refreshButton()

    button.Activated:Connect(function()
        if not onSelected then
            return
        end

        if GarageUI.isBusy() then
            showToast("Garage busy. Please wait…", 1.5)
            return
        end

        if not canAffordDefinition(definition) then
            showToast("Not enough resources for " .. definition.Name .. ".", 2)
            refreshButton()
            refreshBalancePanel()
            return
        end

        if not GarageUI.requestHatch(robotType) then
            refreshButton()
            refreshBalancePanel()
            return
        end

        local success = onSelected and onSelected(robotType, definition)
        if not success then
            resetPending()
            refreshButton()
            refreshBalancePanel()
        else
            refreshButton()
            refreshBalancePanel()
        end
    end)

    local leaderstats = player:FindFirstChild("leaderstats")
    if leaderstats then
        leaderstats.ChildAdded:Connect(function()
            refreshButton()
            refreshBalancePanel()
        end)
        leaderstats.ChildRemoved:Connect(function()
            refreshButton()
            refreshBalancePanel()
        end)
        for _, stat in ipairs(leaderstats:GetChildren()) do
            if stat:IsA("IntValue") then
                stat.Changed:Connect(function()
                    refreshButton()
                    refreshBalancePanel()
                end)
            end
        end
    end

    return button
end

local function toOrderedList(robotTypes)
    local preferredOrder = {"Basic", "Advanced", "Elite"}
    local seen = {}
    local ordered = {}

    for _, name in ipairs(preferredOrder) do
        local def = robotTypes[name]
        if def then
            table.insert(ordered, {name = name, definition = def})
            seen[name] = true
        end
    end

    for name, def in pairs(robotTypes) do
        if not seen[name] then
            table.insert(ordered, {name = name, definition = def})
        end
    end

    table.sort(ordered, function(a, b)
        if a.name == b.name then
            return false
        end
        local aIndex, bIndex = math.huge, math.huge
        for idx, name in ipairs(preferredOrder) do
            if name == a.name then
                aIndex = idx
            end
            if name == b.name then
                bIndex = idx
            end
        end
        if aIndex ~= bIndex then
            return aIndex < bIndex
        end
        return a.name < b.name
    end)

    return ordered
end

local function buildHatchMenu(robotTypes, onHatch)
    ensureGui()
    hideHatchMenu()

    hatchMenu = Instance.new("Frame")
    hatchMenu.Name = "HatchMenu"
    hatchMenu.Size = UDim2.new(0, 420, 0, 260)
    hatchMenu.Position = UDim2.new(0.5, -210, 0.7, -130)
    hatchMenu.BackgroundColor3 = Color3.fromRGB(22, 24, 34)
    hatchMenu.BackgroundTransparency = 0.05
    hatchMenu.BorderSizePixel = 0
    hatchMenu.Parent = uiRoot

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 12)
    corner.Parent = hatchMenu

    local padding = Instance.new("UIPadding")
    padding.PaddingTop = UDim.new(0, 16)
    padding.PaddingBottom = UDim.new(0, 16)
    padding.PaddingLeft = UDim.new(0, 16)
    padding.PaddingRight = UDim.new(0, 16)
    padding.Parent = hatchMenu

    local layout = Instance.new("UIListLayout")
    layout.FillDirection = Enum.FillDirection.Vertical
    layout.Padding = UDim.new(0, 12)
    layout.Parent = hatchMenu

    layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        hatchMenu.Size = UDim2.new(0, 420, 0, math.min(270, layout.AbsoluteContentSize.Y + 32))
    end)

    local header = Instance.new("TextLabel")
    header.BackgroundTransparency = 1
    header.Size = UDim2.new(1, 0, 0, 28)
    header.Text = "Garage Hatch"
    header.TextColor3 = Color3.fromRGB(240, 245, 255)
    header.TextSize = 20
    header.Font = Enum.Font.GothamBold
    header.TextXAlignment = Enum.TextXAlignment.Left
    header.Parent = hatchMenu

    local descriptor = Instance.new("TextLabel")
    descriptor.BackgroundTransparency = 1
    descriptor.Size = UDim2.new(1, 0, 0, 32)
    descriptor.Text = "Step into the garage to assemble a new bot using your resources."
    descriptor.TextWrapped = true
    descriptor.TextColor3 = Color3.fromRGB(200, 205, 220)
    descriptor.TextSize = 16
    descriptor.Font = Enum.Font.Gotham
    descriptor.TextXAlignment = Enum.TextXAlignment.Left
    descriptor.Parent = hatchMenu

    local balancePanel = Instance.new("Frame")
    balancePanel.Name = "BalancePanel"
    balancePanel.Size = UDim2.new(1, 0, 0, 78)
    balancePanel.BackgroundTransparency = 1
    balancePanel.Parent = hatchMenu

    local balanceLayout = Instance.new("UIGridLayout")
    balanceLayout.CellSize = UDim2.new(0, 180, 0, 24)
    balanceLayout.CellPadding = UDim2.new(0, 12, 0, 12)
    balanceLayout.FillDirectionMaxCells = 2
    balanceLayout.HorizontalAlignment = Enum.HorizontalAlignment.Left
    balanceLayout.SortOrder = Enum.SortOrder.LayoutOrder
    balanceLayout.Parent = balancePanel

    balanceLabels = {}
    for _, currency in ipairs(CURRENCY_ORDER) do
        local label = Instance.new("TextLabel")
        label.BackgroundTransparency = 1
        label.Size = UDim2.new(0, 180, 0, 24)
        label.Font = Enum.Font.GothamSemibold
        label.TextColor3 = Color3.fromRGB(220, 225, 235)
        label.TextSize = 16
        label.TextXAlignment = Enum.TextXAlignment.Left
        label.Parent = balancePanel
        balanceLabels[currency] = label
    end
    refreshBalancePanel()

    for _, entry in ipairs(toOrderedList(robotTypes)) do
        local button = buildRobotTypeRow(hatchMenu, entry.name, entry.definition, function(robotType)
            if onHatch then
                return onHatch(robotType, entry.definition)
            end
            return false
        end)
        button.LayoutOrder = #hatchMenu:GetChildren()
    end
end

function GarageUI.isBusy()
    return isHatching or awaitingServer
end

function GarageUI.showInsufficientResources()
    showToast("Not enough resources to hatch.", 2)
end

function GarageUI.open(robotTypes, onHatch)
    if GarageUI.isBusy() then
        showToast("Garage busy. Please wait…", 1.5)
        return
    end

    lastDefinitions = robotTypes
    lastOnHatch = onHatch
    buildHatchMenu(robotTypes, onHatch)
end

function GarageUI.close()
    hideHatchMenu()
    balanceLabels = {}
end

function GarageUI.requestHatch(robotType)
    if GarageUI.isBusy() then
        return false
    end

    awaitingServer = true
    pendingRobotType = robotType
    return true
end

function GarageUI.handleStatus(status, payload)
    payload = payload or {}

    if status == "started" then
        isHatching = true
        awaitingServer = false
        hideHatchMenu()
        local label = payload.robotType or pendingRobotType or "robot"
        showToast("Hatching " .. label .. "…", 2)
    elseif status == "completed" then
        isHatching = false
        awaitingServer = false
        pendingRobotType = nil
        local robotName = payload.robotName or "Robot"
        showToast(robotName .. " ready for duty!", 2.5)
    elseif status == "failed" then
        isHatching = false
        awaitingServer = false
        pendingRobotType = nil
        local message = payload.message or "Garage action failed."
        showToast(message, 2.5)
        if not hatchMenu and lastDefinitions and lastOnHatch then
            task.delay(0.35, function()
                if not GarageUI.isBusy() then
                    buildHatchMenu(lastDefinitions, lastOnHatch)
                end
            end)
        end
    end
    refreshBalancePanel()
end

return GarageUI
