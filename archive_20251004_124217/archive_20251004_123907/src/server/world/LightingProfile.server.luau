--!strict

local Lighting = game:GetService("Lighting")

local LightingProfile = {}

local function ensureEffect(className: string, name: string)
    local existing = Lighting:FindFirstChild(name)
    if existing and existing:IsA(className) then
        return existing
    end

    if existing then
        existing:Destroy()
    end

    local effect = Instance.new(className)
    effect.Name = name
    effect.Parent = Lighting
    return effect
end

function LightingProfile.apply()
    pcall(function()
        Lighting.Technology = Enum.Technology.Future
    end)
    Lighting.Brightness = 2.5
    Lighting.ShadowSoftness = 0.4
    Lighting.Ambient = Color3.fromRGB(15, 18, 22)
    Lighting.OutdoorAmbient = Color3.fromRGB(35, 40, 48)

    local colorCorrection = ensureEffect("ColorCorrectionEffect", "WorldColorCorrection")
    colorCorrection.TintColor = Color3.fromRGB(220, 235, 255)
    colorCorrection.Contrast = 0.06
    colorCorrection.Saturation = 0.02

    local bloom = ensureEffect("BloomEffect", "WorldBloom")
    bloom.Intensity = 0.1
    bloom.Size = 24
    bloom.Threshold = 1

    local depthOfField = ensureEffect("DepthOfFieldEffect", "WorldDepthOfField")
    local hasFNumber = pcall(function()
        return depthOfField.FNumber
    end)
    if hasFNumber then
        pcall(function()
            depthOfField.FNumber = 10
        end)
    else
        depthOfField.NearIntensity = 0.1
        depthOfField.FarIntensity = 0.5
    end
    depthOfField.FocusDistance = 0
    depthOfField.InFocusRadius = 10
end

LightingProfile.apply()

return LightingProfile
