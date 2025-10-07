--!strict

local Bootstrap = {}
Bootstrap.VERSION = "world-" .. tostring(os.time())

local ALLOW = { "GarageReset", "_bootstrap" }

function Bootstrap.cleanStale()
    local world = script.Parent
    local removed = 0

    for _, child in ipairs(world:GetChildren()) do
        if child:IsA("ModuleScript") then
            local ok = false
            for _, name in ipairs(ALLOW) do
                if child.Name == name then
                    ok = true
                    break
                end
            end
            if not ok then
                warn("[BOOT] Removing stale world module: " .. child:GetFullName())
                child:Destroy()
                removed += 1
            end
        end
    end

    print(string.format("[BOOT] Stale world modules removed: %d", removed))
end

return Bootstrap
