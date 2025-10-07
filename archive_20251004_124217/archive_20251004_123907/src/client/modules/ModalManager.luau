--!strict

local UserInputService = game:GetService("UserInputService")
local Lighting = game:GetService("Lighting")

local Theme = require(script.Parent.Parent.ui.Theme)

local ModalManager = {}

local rootGui: ScreenGui?
local overlay: Frame?
local cardHolder: Frame?
local currentKey: string? = nil
local currentContent: GuiObject?
local openState = false
local connections: { RBXScriptConnection } = {}
local blurEffect: BlurEffect?

local function clearConnections()
    for index = #connections, 1, -1 do
        connections[index]:Disconnect()
        table.remove(connections, index)
    end
end

local function ensureOverlay(gui: ScreenGui)
    if overlay and overlay.Parent == gui then
        return
    end

    if overlay then
        overlay:Destroy()
        overlay = nil
    end

    overlay = Instance.new("Frame")
    overlay.Name = "ModalOverlay"
    overlay.BackgroundColor3 = Color3.new(0, 0, 0)
    overlay.BackgroundTransparency = 0.35
    overlay.BorderSizePixel = 0
    overlay.Size = UDim2.fromScale(1, 1)
    overlay.Visible = false
    overlay.ZIndex = 90
    overlay.Parent = gui

    cardHolder = Instance.new("Frame")
    cardHolder.Name = "ModalHolder"
    cardHolder.AnchorPoint = Vector2.new(0.5, 0.5)
    cardHolder.Position = UDim2.fromScale(0.5, 0.5)
    cardHolder.BackgroundTransparency = 1
    cardHolder.Size = UDim2.new(0, 720, 0, 520)
    cardHolder.ZIndex = 91
    cardHolder.Parent = overlay
end

local function ensureBlur()
    if blurEffect and blurEffect.Parent == Lighting then
        return blurEffect
    end
    blurEffect = Instance.new("BlurEffect")
    blurEffect.Name = "ModalBlur"
    blurEffect.Size = 0
    blurEffect.Parent = Lighting
    return blurEffect
end

local function handleOverlayInput(input: InputObject, processed: boolean)
    if processed or not openState then
        return
    end

    if input.KeyCode == Enum.KeyCode.Escape then
        ModalManager.close()
        return
    end

    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        if not overlay or not cardHolder then
            return
        end

        local holderPos = cardHolder.AbsolutePosition
        local holderSize = cardHolder.AbsoluteSize
        local position = input.Position
        local insideX = position.X >= holderPos.X and position.X <= holderPos.X + holderSize.X
        local insideY = position.Y >= holderPos.Y and position.Y <= holderPos.Y + holderSize.Y
        if not (insideX and insideY) then
            ModalManager.close()
        end
    end
end

function ModalManager.init(gui: ScreenGui)
    rootGui = gui
    ensureOverlay(gui)
    ensureBlur()

    clearConnections()
    table.insert(connections, UserInputService.InputBegan:Connect(handleOverlayInput))
end

function ModalManager.open(key: string, content: GuiObject)
    if not rootGui then
        error("ModalManager.init must be called before open")
    end

    ensureOverlay(rootGui)

    if not overlay or not cardHolder then
        return
    end

    if currentContent then
        currentContent.Parent = nil
        currentContent = nil
    end

    cardHolder:ClearAllChildren()
    content.Parent = cardHolder
    content.ZIndex = 92

    overlay.Visible = true
    ensureBlur().Size = 8
    openState = true
    currentKey = key
    currentContent = content
end

function ModalManager.close()
    if not overlay or not cardHolder then
        return
    end

    overlay.Visible = false
    if blurEffect then
        blurEffect.Size = 0
    end
    openState = false
    currentKey = nil

    if currentContent then
        currentContent.Parent = nil
        currentContent = nil
    end

    cardHolder:ClearAllChildren()
end

function ModalManager.isOpen(): boolean
    return openState
end

function ModalManager.getCurrentKey(): string?
    return currentKey
end

return ModalManager
