--!strict

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")

local ModalManager = require(script.Parent.ModalManager)
local UIFactory = require(script.Parent.Parent.ui.UIFactory)
local Theme = require(script.Parent.Parent.ui.Theme)
local Taskbar = require(script.Parent.Taskbar)

local player = Players.LocalPlayer

local GarageUI = {}

local remotes = {
    GarageConsole = nil :: RemoteEvent?,
    GarageStatus = nil :: RemoteEvent?,
}

local function findGarageItem(name: string): Instance?
    local inst = Workspace:FindFirstChild(name)
    if inst then
        return inst
    end

    local garage = Workspace:FindFirstChild("Garage")
    if not garage or not garage:IsA("Model") then
        return nil
    end

    return garage:FindFirstChild(name, true)
end

local card: Frame?
local statusLabel: TextLabel?
local hintLabel: TextLabel?
local buttons: {TextButton} = {}
local heartbeatConnection: RBXScriptConnection?
local latestStatus = "Garage ready"

local function findConsolePosition(): Vector3?
    local surface = findGarageItem("GarageConsoleSurface")
    if surface and surface:IsA("BasePart") then
        return surface.Position
    end

    local deck = findGarageItem("GarageConsoleDeck")
    if deck and deck:IsA("BasePart") then
        return deck.Position
    end

    return nil
end

local function computeDistance(): (number?, Vector3?)
    local character = player.Character
    if not character then
        return nil, nil
    end

    local root = character:FindFirstChild("HumanoidRootPart")
    if not root then
        return nil, nil
    end

    local consolePosition = findConsolePosition()
    if not consolePosition then
        return nil, root.Position
    end

    return (root.Position - consolePosition).Magnitude, consolePosition
end

local function getRangeState()
    local distance = select(1, computeDistance())
    if not distance then
        return false, "Garage console not found"
    end

    if distance > 20 then
        return false, "Move closer to the garage"
    end

    return true, ""
end

local function setButtonsEnabled(enabled: boolean)
    for _, button in ipairs(buttons) do
        button.Active = enabled
        button.AutoButtonColor = enabled
        local base = button:GetAttribute("BaseColor")
        button.BackgroundColor3 = enabled and (base or Theme.colors.primary) or Theme.colors.muted
        button.BackgroundTransparency = enabled and 0 or 0.35
        button.TextTransparency = enabled and 0 or 0.35
    end
end

local function updateCardState()
    if not card then
        return
    end

    local enabled, hint = getRangeState()
    setButtonsEnabled(enabled)

    if hintLabel then
        hintLabel.Text = hint
        hintLabel.Visible = hint ~= ""
    end

    Taskbar.setHint(hint)

    if statusLabel then
        statusLabel.Text = latestStatus
    end
end

local function ensureCard(): Frame
    if card and card.Parent then
        return card
    end

    local frame = UIFactory.card("Garage Console")

    statusLabel = UIFactory.smallLabel(latestStatus)
    statusLabel.TextColor3 = Color3.fromRGB(220, 230, 245)
    statusLabel.LayoutOrder = 1
    statusLabel.Parent = frame

    hintLabel = UIFactory.smallLabel("")
    hintLabel.TextColor3 = Color3.fromRGB(255, 192, 92)
    hintLabel.LayoutOrder = 2
    hintLabel.Visible = false
    hintLabel.Parent = frame

    local buttonRow = Instance.new("Frame")
    buttonRow.BackgroundTransparency = 1
    buttonRow.Size = UDim2.new(1, 0, 0, 48)
    buttonRow.LayoutOrder = 3
    buttonRow.Parent = frame

    local layout = Instance.new("UIListLayout")
    layout.FillDirection = Enum.FillDirection.Horizontal
    layout.SortOrder = Enum.SortOrder.LayoutOrder
    layout.Padding = UDim.new(0, 10)
    layout.HorizontalAlignment = Enum.HorizontalAlignment.Left
    layout.Parent = buttonRow

    buttons = {}

    local openButton = UIFactory.button("primary", "Open Console")
    openButton.Size = UDim2.fromOffset(180, 40)
    openButton.Parent = buttonRow
    openButton:SetAttribute("BaseColor", openButton.BackgroundColor3)
    openButton.MouseButton1Click:Connect(function()
        if remotes.GarageConsole then
            remotes.GarageConsole:FireServer("open", {
                desiredTab = "Hatch",
            })
        end
    end)
    table.insert(buttons, openButton)

    local refreshButton = UIFactory.button("muted", "Refresh Roster")
    refreshButton.Size = UDim2.fromOffset(180, 40)
    refreshButton.Parent = buttonRow
    refreshButton:SetAttribute("BaseColor", refreshButton.BackgroundColor3)
    refreshButton.MouseButton1Click:Connect(function()
        if remotes.GarageConsole then
            remotes.GarageConsole:FireServer("refresh")
        end
    end)
    table.insert(buttons, refreshButton)

    local toggleDoorButton = UIFactory.button("muted", "Toggle Door")
    toggleDoorButton.Size = UDim2.fromOffset(180, 40)
    toggleDoorButton.Parent = buttonRow
    toggleDoorButton:SetAttribute("BaseColor", toggleDoorButton.BackgroundColor3)
    toggleDoorButton.MouseButton1Click:Connect(function()
        local remoteFolder = game:GetService("ReplicatedStorage"):FindFirstChild("Remotes")
        local toggle = remoteFolder and remoteFolder:FindFirstChild("ToggleGarageDoor")
        if toggle and toggle:IsA("RemoteEvent") then
            toggle:FireServer()
        end
    end)
    table.insert(buttons, toggleDoorButton)

    card = frame
    updateCardState()
    return frame
end

local function startHeartbeat()
    if heartbeatConnection then
        return
    end
    heartbeatConnection = RunService.Heartbeat:Connect(function()
        if ModalManager.getCurrentKey() ~= "garage" then
            stopHeartbeat()
            return
        end
        updateCardState()
    end)
end

local function stopHeartbeat()
    if heartbeatConnection then
        heartbeatConnection:Disconnect()
        heartbeatConnection = nil
    end
end

function GarageUI.init(remoteBundle: {[string]: RemoteEvent})
    remotes.GarageConsole = remoteBundle.GarageConsole
    remotes.GarageStatus = remoteBundle.GarageStatus

    if remotes.GarageStatus then
        remotes.GarageStatus.OnClientEvent:Connect(function(status: string, payload)
            if status == "ready" then
                latestStatus = "Garage ready"
            elseif status == "busy" then
                local message = payload and payload.message or "Garage in use"
                latestStatus = message
            elseif status == "failed" then
                latestStatus = payload and payload.message or "Garage unavailable"
            elseif status == "upgrade_success" then
                latestStatus = payload and payload.message or "Upgrade complete"
            elseif status == "appearance_success" then
                latestStatus = payload and payload.message or "Appearance applied"
            elseif status == "upgrade_failed" or status == "appearance_failed" then
                latestStatus = payload and payload.message or "Action failed"
            elseif status == "completed" then
                latestStatus = payload and payload.message or "Robot deployed"
            elseif status == "hatching" then
                latestStatus = "Hatching in progress"
            end

            if statusLabel then
                statusLabel.Text = latestStatus
            end
        end)
    end

    if remotes.GarageConsole then
        remotes.GarageConsole.OnClientEvent:Connect(function(action: string, _payload: any)
            if action == "open" then
                latestStatus = "Console ready"
                updateCardState()
            elseif action == "close" then
                latestStatus = "Garage closed"
                updateCardState()
                if ModalManager.getCurrentKey() == "garage" then
                    ModalManager.close()
                end
            end
        end)
    end
end

function GarageUI.open()
    local frame = ensureCard()
    updateCardState()
    startHeartbeat()
    ModalManager.open("garage", frame)
end

function GarageUI.close()
    if ModalManager.getCurrentKey() == "garage" then
        ModalManager.close()
    end
    stopHeartbeat()
end

function GarageUI.toggle()
    if ModalManager.getCurrentKey() == "garage" then
        GarageUI.close()
    else
        GarageUI.open()
    end
end

function GarageUI.isInRange(): boolean
    local enabled = select(1, getRangeState())
    return enabled == true
end

function GarageUI.hint(): string
    local enabled, hint = getRangeState()
    if enabled == true then
        return ""
    end
    return hint
end

return GarageUI
