--!strict

local RunService = game:GetService("RunService")

local Theme = require(script.Parent.Parent.ui.Theme)

local Taskbar = {}

export type Callbacks = {
    onGarage: () -> (),
    onHatch: () -> (),
    onAssign: () -> (),
    garageEnabled: (() -> boolean)?,
    garageHint: (() -> string)?,
}

local container: Frame?
local hintOverlay: TextLabel?
local buttons: {[string]: TextButton} = {}
local callbacks: Callbacks?
local updateConnection: RBXScriptConnection?

local function applyCorner(instance: GuiObject)
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, Theme.radius)
    corner.Parent = instance
end

local function createButton(label: string, hotkey: string): TextButton
    local button = Instance.new("TextButton")
    button.Name = label .. "Button"
    button.Size = UDim2.fromOffset(160, 40)
    button.BackgroundColor3 = Theme.colors.primary
    button.AutoButtonColor = true
    button.TextColor3 = Color3.new(1, 1, 1)
    button.Text = string.format("%s (%s)", label, hotkey)
    button.Font = Enum.Font.GothamMedium
    button.TextSize = Theme.text.sub
    applyCorner(button)
    return button
end

local function updateGarageState()
    if not callbacks or not buttons.Garage then
        return
    end

    local enabled = callbacks.garageEnabled and callbacks.garageEnabled() or true
    local hint = callbacks.garageHint and callbacks.garageHint() or ""

    buttons.Garage.AutoButtonColor = enabled
    buttons.Garage.Active = enabled
    buttons.Garage.BackgroundColor3 = enabled and Theme.colors.primary or Theme.colors.muted
    buttons.Garage.TextTransparency = enabled and 0 or 0.3

    Taskbar.setHint(hint)
end

function Taskbar.setHint(text: string?)
    if not hintOverlay then
        return
    end
    local message = text or ""
    hintOverlay.Text = message
    hintOverlay.Visible = #message > 0
end

function Taskbar.init(mainGui: ScreenGui, taskCallbacks: Callbacks)
    callbacks = taskCallbacks

    if container then
        container:Destroy()
    end

    container = Instance.new("Frame")
    container.Name = "Taskbar"
    container.AnchorPoint = Vector2.new(0.5, 1)
    container.Position = UDim2.fromScale(0.5, 1)
    container.Size = UDim2.new(0.6, 0, 0, 72)
    container.BackgroundColor3 = Theme.colors.card
    container.BackgroundTransparency = 0.15
    container.BorderSizePixel = 0
    container.Parent = mainGui

    applyCorner(container)

    local sizeConstraint = Instance.new("UISizeConstraint")
    sizeConstraint.MinSize = Vector2.new(560, 72)
    sizeConstraint.MaxSize = Vector2.new(920, 72)
    sizeConstraint.Parent = container

    local padding = Instance.new("UIPadding")
    padding.PaddingTop = UDim.new(0, Theme.padding.md)
    padding.PaddingBottom = UDim.new(0, Theme.padding.sm)
    padding.PaddingLeft = UDim.new(0, Theme.padding.lg)
    padding.PaddingRight = UDim.new(0, Theme.padding.lg)
    padding.Parent = container

    local layout = Instance.new("UIListLayout")
    layout.FillDirection = Enum.FillDirection.Horizontal
    layout.HorizontalAlignment = Enum.HorizontalAlignment.Center
    layout.VerticalAlignment = Enum.VerticalAlignment.Center
    layout.Padding = UDim.new(0, Theme.padding.md)
    layout.Parent = container

    buttons = {}

    local garageButton = createButton("Garage", "G")
    garageButton.Parent = container
    garageButton.MouseButton1Click:Connect(function()
        if callbacks and callbacks.onGarage then
            if not callbacks.garageEnabled or callbacks.garageEnabled() then
                callbacks.onGarage()
            end
        end
    end)
    buttons.Garage = garageButton

    local hatchButton = createButton("Hatch", "H")
    hatchButton.Parent = container
    hatchButton.MouseButton1Click:Connect(function()
        if callbacks and callbacks.onHatch then
            callbacks.onHatch()
        end
    end)
    buttons.Hatch = hatchButton

    local assignButton = createButton("Assign", "A")
    assignButton.Parent = container
    assignButton.MouseButton1Click:Connect(function()
        if callbacks and callbacks.onAssign then
            callbacks.onAssign()
        end
    end)
    buttons.Assign = assignButton

    hintOverlay = Instance.new("TextLabel")
    hintOverlay.Name = "GarageHint"
    hintOverlay.BackgroundTransparency = 1
    hintOverlay.Size = UDim2.new(0, 400, 0, 20)
    hintOverlay.TextXAlignment = Enum.TextXAlignment.Right
    hintOverlay.TextYAlignment = Enum.TextYAlignment.Center
    hintOverlay.Position = UDim2.new(0.98, 0, 0.98, 0)
    hintOverlay.AnchorPoint = Vector2.new(1, 1)
    hintOverlay.Font = Enum.Font.Gotham
    hintOverlay.TextSize = Theme.text.body
    hintOverlay.TextColor3 = Color3.fromRGB(210, 220, 235)
    hintOverlay.Text = ""
    hintOverlay.Visible = false
    hintOverlay.ZIndex = container.ZIndex + 1
    hintOverlay.Parent = mainGui

    if updateConnection then
        updateConnection:Disconnect()
    end
    updateConnection = RunService.Heartbeat:Connect(updateGarageState)
    updateGarageState()
end

function Taskbar.destroy()
    if updateConnection then
        updateConnection:Disconnect()
        updateConnection = nil
    end

    for _, button in pairs(buttons) do
        button:Destroy()
    end
    buttons = {}

    if hintOverlay then
        hintOverlay:Destroy()
        hintOverlay = nil
    end

    if container then
        container:Destroy()
        container = nil
    end

    callbacks = nil
end

return Taskbar
