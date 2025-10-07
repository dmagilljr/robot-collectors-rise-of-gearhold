--!strict

local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local GameConstants = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("config"):WaitForChild("GameConstants"))

local LODService = {}

local registeredModels: { [Model]: {lod0: Model, lod1: Model} } = {}
local connections: {RBXScriptConnection} = {}
local HEARTBEAT_STEP = 0.5
local accumulated = 0

local function attachHeartbeat()
    if #connections > 0 then
        return
    end

    local connection = RunService.Heartbeat:Connect(function(dt)
        if not GameConstants.ENABLE_LOD then
            return
        end
        accumulated += dt
        if accumulated < HEARTBEAT_STEP then
            return
        end
        accumulated = 0

        local players = Players:GetPlayers()
        local removedAny = false
        for model, lodInfo in pairs(registeredModels) do
            if not model.Parent then
                registeredModels[model] = nil
                removedAny = true
                continue
            end

            local lod0 = lodInfo.lod0
            local lod1 = lodInfo.lod1
            if not (lod0 and lod1) then
                registeredModels[model] = nil
                removedAny = true
                continue
            end

            local closest = math.huge
            local lodCenter = lod0:GetPivot().Position
            for _, player in ipairs(players) do
                local character = player.Character
                local root = character and character:FindFirstChild("HumanoidRootPart")
                if root then
                    local distance = (root.Position - lodCenter).Magnitude
                    if distance < closest then
                        closest = distance
                    end
                end
            end

            local useLow = closest == math.huge or closest > 80
            lod0.Parent = useLow and nil or model
            lod1.Parent = useLow and model or nil
        end

        if removedAny and not next(registeredModels) then
            detachHeartbeat()
        end
    end)

    table.insert(connections, connection)
end

local function detachHeartbeat()
    if next(registeredModels) then
        return
    end
    for _, connection in ipairs(connections) do
        connection:Disconnect()
    end
    table.clear(connections)
end

function LODService.register(model: Model, lodInfo: {lod0: Model, lod1: Model})
    if not GameConstants.ENABLE_LOD then
        return
    end
    if registeredModels[model] then
        return
    end

    lodInfo.lod0.Parent = model
    lodInfo.lod1.Parent = nil

    registeredModels[model] = lodInfo
    attachHeartbeat()
end

local function simplifyDescendants(lodModel: Model)
    for _, descendant in ipairs(lodModel:GetDescendants()) do
        if descendant:IsA("BasePart") then
            descendant.Transparency = math.clamp(descendant.Transparency + 0.3, 0, 1)
            descendant.Material = Enum.Material.SmoothPlastic
        elseif descendant:IsA("Decal") then
            descendant.Transparency = math.clamp(descendant.Transparency + 0.4, 0, 1)
        end
    end
end

function LODService.attach(model: Model)
    if not GameConstants.ENABLE_LOD then
        return
    end

    if registeredModels[model] then
        return
    end

    local originalChildren = model:GetChildren()
    if #originalChildren == 0 then
        return
    end

    local lod0 = Instance.new("Model")
    lod0.Name = "LOD0"
    lod0:SetAttribute("GeneratedBySetup", true)

    for _, child in ipairs(originalChildren) do
        child.Parent = lod0
    end

    local lod1 = lod0:Clone()
    lod1.Name = "LOD1"
    simplifyDescendants(lod1)

    lod0.Parent = model
    lod1.Parent = nil

    LODService.register(model, {
        lod0 = lod0,
        lod1 = lod1,
    })
end

return LODService
