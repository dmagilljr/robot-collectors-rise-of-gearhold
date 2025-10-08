--!strict
local M = {} ; M.VERSION = "worldboot-"..tostring(os.time())
print("🌍 WorldBoot ACTIVE", M.VERSION)

local function ensurePart(name: string, parent: Instance, size: Vector3, cframe: CFrame, props: {[string]: any}? )
    local inst = parent:FindFirstChild(name)
    if inst and not inst:IsA("BasePart") then
        inst:Destroy()
        inst = nil
    end
    local part = inst
    if not part then
        part = Instance.new("Part")
        part.Name = name
        part.Parent = parent
    end
    local basePart = part :: BasePart
    basePart.Anchored = true
    basePart.Size = size
    basePart.CFrame = cframe
    if props then
        for k, v in pairs(props) do
            (basePart :: any)[k] = v
        end
    end
    return basePart
end

function M.run()
    ensurePart(
        "RC_Baseplate",
        workspace,
        Vector3.new(512, 1, 512),
        CFrame.new(0, 0, 0),
        {Material = Enum.Material.Granite, Color = Color3.fromRGB(30, 34, 39)}
    )

    local spawn = workspace:FindFirstChild("RC_Spawn")
    if spawn and not spawn:IsA("SpawnLocation") then
        spawn:Destroy()
        spawn = nil
    end
    if not spawn then
        spawn = Instance.new("SpawnLocation")
        spawn.Name = "RC_Spawn"
        spawn.Parent = workspace
    end
    local spawnPart = spawn :: any
    spawnPart.Anchored = true
    spawnPart.Size = Vector3.new(6, 1, 6)
    spawnPart.CFrame = CFrame.new(0, 3.5, 0)
    spawnPart.Neutral = true
    spawnPart.Enabled = true
    spawnPart.Transparency = 0.2

    ensurePart(
        "RC_HELLO_SIGN",
        workspace,
        Vector3.new(12, 1, 0.5),
        CFrame.new(0, 4.25, -8),
        {Material = Enum.Material.Neon, Color = Color3.fromRGB(52, 132, 255)}
    )

    print("✅ WorldBoot.run(): ground + spawn + sign placed.")
end

return M
