-- Robot Collectors: Input Management System
-- Handles mouse clicks, mining, and robot targeting

local Players = game:GetService("Players")

local Player = Players.LocalPlayer

local InputManager = {}

function InputManager.setupMiningInput(remotes, robotUIManager, updateCallback)
    local Mouse = Player:GetMouse()

    Mouse.Button1Down:Connect(function()
        local target = Mouse.Target

        -- Check if clicking on a resource
        if target and target.Name:find("Resource_") and target:IsA("BasePart") then
            local resourceType = target:FindFirstChild("ResourceType")
            if resourceType then
                -- Check if we're in targeting mode
                local targetingRobot = robotUIManager.getTargetingRobot()
                if targetingRobot then
                    -- Assign robot to this resource
                    remotes.AssignRobotToResource:FireServer(targetingRobot.id, target)
                    print("🎯 Assigned robot", targetingRobot.name, "to", resourceType.Value, "resource")

                    -- Exit targeting mode
                    robotUIManager.setTargetingRobot(nil)
                    updateCallback()
                    return
                end

                -- Normal mining mode - check distance first
                local character = Player.Character
                if character and character:FindFirstChild("HumanoidRootPart") then
                    local distance = (character.HumanoidRootPart.Position - target.Position).Magnitude

                    if distance <= 10 then
                        -- Close enough - play resource-specific mining sound and send to server
                        local sound = Instance.new("Sound")
                        -- Select sound based on resource type
                        local soundIds = {
                            ["Gearbit"] = "rbxassetid://119775049787068",
                            ["Ion Shard"] = "rbxassetid://127568947930414",
                            ["Rare Metal"] = "rbxassetid://131285685848776",
                            ["Crystal"] = "rbxassetid://98933401010439"
                        }
                        sound.SoundId = soundIds[resourceType.Value] or "rbxassetid://12221967" -- Fallback to generic sound
                        sound.Volume = 0.6
                        sound.Pitch = 0.8  -- Slightly higher pitch for better mining feel
                        sound.Parent = character.HumanoidRootPart
                        sound:Play()

                        -- Clean up sound after playing
                        sound.Ended:Connect(function()
                            sound:Destroy()
                        end)

                        remotes.ManualMine:FireServer(target)
                        print("🔨 Mining", resourceType.Value, "resource")
                    else
                        -- Too far - no feedback at all
                        print("❌ Too far from resource (", math.floor(distance), "studs)")
                    end
                end
            end
        elseif robotUIManager.getTargetingRobot() then
            -- Clicked somewhere else while in targeting mode - cancel targeting
            robotUIManager.setTargetingRobot(nil)
            print("❌ Targeting cancelled")
            updateCallback()
        end
    end)
end

return InputManager