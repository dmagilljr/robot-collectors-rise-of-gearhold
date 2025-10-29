--!strict
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")
local Players = game:GetService("Players")

local RC_Remotes = ReplicatedStorage:WaitForChild("RC_Remotes")
local OpenStorageUI = RC_Remotes:WaitForChild("OpenStorageUI") :: RemoteEvent

local function findGarageConsole(): BasePart?
	local worldFolder = ServerScriptService:FindFirstChild("World")
	if not worldFolder then
		return nil
	end
	local garageFolder = worldFolder:FindFirstChild("Garage")
	if not garageFolder then
		return nil
	end
	for _, inst in ipairs(garageFolder:GetDescendants()) do
		if inst:IsA("BasePart") then
			local lower = string.lower(inst.Name)
			if string.find(lower, "console") then
				return inst
			end
		end
	end
	return nil
end

local console = findGarageConsole()
if console then
	local prompt = console:FindFirstChildOfClass("ProximityPrompt")
	if not prompt then
		prompt = Instance.new("ProximityPrompt")
		prompt.Name = "StoragePrompt"
		prompt.Parent = console
	end
	prompt.ActionText = "Open Storage"
	prompt.ObjectText = "Garage Terminal"
	prompt.HoldDuration = 0.25
	prompt.RequiresLineOfSight = false
	prompt.MaxActivationDistance = 12

	prompt.Triggered:Connect(function(player: Player)
		OpenStorageUI:FireClient(player)
	end)
else
	warn("[StorageTerminal] Garage console not found; storage prompt unavailable")
end

return {}

