--!strict
local Theme = require(script.Parent.Theme)

local UIFactory = {}

local function applyCorner(instance: GuiObject, radius: number?)
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, radius or Theme.radius)
    corner.Parent = instance
end

local function applyPadding(instance: GuiObject, padding: number)
    local pad = Instance.new("UIPadding")
    pad.PaddingTop = UDim.new(0, padding)
    pad.PaddingBottom = UDim.new(0, padding)
    pad.PaddingLeft = UDim.new(0, padding)
    pad.PaddingRight = UDim.new(0, padding)
    pad.Parent = instance
end

function UIFactory.card(titleText: string)
    local frame = Instance.new("Frame")
    frame.BackgroundColor3 = Theme.colors.card
    frame.BackgroundTransparency = 0.1
    frame.Size = UDim2.fromOffset(720, 520)
    frame.BorderSizePixel = 0
    applyCorner(frame, Theme.radius)

    applyPadding(frame, Theme.padding.lg)

    local layout = Instance.new("UIListLayout")
    layout.Padding = UDim.new(0, Theme.padding.md)
    layout.FillDirection = Enum.FillDirection.Vertical
    layout.SortOrder = Enum.SortOrder.LayoutOrder
    layout.Parent = frame

    local title = Instance.new("TextLabel")
    title.BackgroundTransparency = 1
    title.Text = titleText
    title.TextSize = Theme.text.title
    title.TextColor3 = Color3.new(1, 1, 1)
    title.Font = Enum.Font.GothamSemibold
    title.LayoutOrder = 0
    title.Parent = frame

    return frame
end

function UIFactory.button(kind: string, text: string)
    local button = Instance.new("TextButton")
    button.Size = UDim2.fromOffset(180, 36)
    button.AutoButtonColor = true
    button.Text = text
    button.TextColor3 = Color3.new(1, 1, 1)
    button.Font = Enum.Font.GothamMedium
    button.TextSize = Theme.text.sub
    button.BackgroundColor3 = Theme.colors.muted

    if kind == "primary" then
        button.BackgroundColor3 = Theme.colors.primary
    elseif kind == "success" then
        button.BackgroundColor3 = Theme.colors.success
    end

    applyCorner(button, Theme.radius)
    return button
end

function UIFactory.smallLabel(text: string)
    local label = Instance.new("TextLabel")
    label.BackgroundTransparency = 1
    label.Text = text
    label.TextColor3 = Color3.fromRGB(220, 228, 240)
    label.Font = Enum.Font.Gotham
    label.TextSize = Theme.text.body
    label.TextWrapped = true
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.TextYAlignment = Enum.TextYAlignment.Center
    return label
end

return UIFactory
