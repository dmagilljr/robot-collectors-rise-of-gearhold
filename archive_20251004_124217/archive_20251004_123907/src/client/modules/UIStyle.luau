-- Shared UI styling helpers for Robot Collectors client modules

local UIStyle = {}

UIStyle.colors = {
    panel = Color3.fromRGB(20, 22, 31),
    panelHighlight = Color3.fromRGB(35, 40, 55),
    textPrimary = Color3.fromRGB(220, 225, 235),
    textSecondary = Color3.fromRGB(180, 185, 200),
    accent = Color3.fromRGB(70, 130, 180),
}

local function applyCorner(parent, radius)
    local existing = parent:FindFirstChildOfClass("UICorner")
    if not existing then
        existing = Instance.new("UICorner")
        existing.Parent = parent
    end
    existing.CornerRadius = UDim.new(0, radius or 8)
end

local function applyPadding(parent, padding)
    if not padding then
        return
    end

    local uiPadding = parent:FindFirstChildOfClass("UIPadding")
    if not uiPadding then
        uiPadding = Instance.new("UIPadding")
        uiPadding.Parent = parent
    end

    uiPadding.PaddingTop = UDim.new(0, padding.top or 0)
    uiPadding.PaddingBottom = UDim.new(0, padding.bottom or 0)
    uiPadding.PaddingLeft = UDim.new(0, padding.left or 0)
    uiPadding.PaddingRight = UDim.new(0, padding.right or 0)
end

function UIStyle.createPanel(parent, props)
    local frame = Instance.new("Frame")
    frame.Name = props.name or "Panel"
    frame.Size = props.size or UDim2.new(0, 300, 0, 300)
    frame.Position = props.position or UDim2.new()
    frame.BackgroundColor3 = props.backgroundColor or UIStyle.colors.panel
    frame.BackgroundTransparency = props.backgroundTransparency or 0.05
    frame.BorderSizePixel = 0
    frame.Parent = parent

    if props.cornerRadius ~= 0 then
        applyCorner(frame, props.cornerRadius or 12)
    end

    if props.padding then
        applyPadding(frame, props.padding)
    end

    return frame
end

function UIStyle.createLabel(parent, props)
    local label = Instance.new("TextLabel")
    label.Name = props.name or "Label"
    label.BackgroundTransparency = 1
    label.Size = props.size or UDim2.new(1, 0, 0, 0)
    label.AutomaticSize = props.automaticSize or Enum.AutomaticSize.Y
    label.Text = props.text or ""
    label.TextColor3 = props.color or UIStyle.colors.textPrimary
    label.Font = props.font or Enum.Font.Gotham
    label.TextSize = props.textSize or 16
    label.TextScaled = props.textScaled or false
    label.TextXAlignment = props.textXAlignment or Enum.TextXAlignment.Left
    label.TextYAlignment = props.textYAlignment or Enum.TextYAlignment.Center
    label.Parent = parent
    return label
end

function UIStyle.createButton(parent, props)
    local button = Instance.new("TextButton")
    button.Name = props.name or "Button"
    button.Size = props.size or UDim2.new(0, 120, 0, 36)
    button.Text = props.text or ""
    button.Font = props.font or Enum.Font.GothamSemibold
    button.TextSize = props.textSize or 16
    button.TextColor3 = props.textColor or Color3.fromRGB(255, 255, 255)
    button.BackgroundColor3 = props.backgroundColor or UIStyle.colors.accent
    button.BackgroundTransparency = props.backgroundTransparency or 0
    button.AutoButtonColor = false
    button.Parent = parent

    applyCorner(button, props.cornerRadius or 8)

    if props.padding then
        applyPadding(button, props.padding)
    end

    return button
end

function UIStyle.createDivider(parent)
    local divider = Instance.new("Frame")
    divider.Name = "Divider"
    divider.Size = UDim2.new(1, 0, 0, 1)
    divider.BackgroundColor3 = Color3.fromRGB(60, 65, 80)
    divider.BackgroundTransparency = 0.3
    divider.BorderSizePixel = 0
    divider.Parent = parent
    return divider
end

return UIStyle
