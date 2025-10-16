--!strict

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local ServerScriptService = game:GetService("ServerScriptService")
local HatchShow = require(ServerScriptService.World.Garage.Shows.Hatch)

local folder = ReplicatedStorage:FindFirstChild("RC_Remotes") :: Folder?
if not folder then
	folder = Instance.new("Folder")
	folder.Name = "RC_Remotes"
	folder.Parent = ReplicatedStorage
end

local function ensureEvent(name: string): RemoteEvent
	local ev = folder:FindFirstChild(name) :: RemoteEvent?
	if not ev then
		ev = Instance.new("RemoteEvent")
		ev.Name = name
		ev.Parent = folder
	end
	return ev
end

ensureEvent("OpenCommandUI")
ensureEvent("HatchRobot")
ensureEvent("HatchFX")
ensureEvent("CloseCommandUI")
ensureEvent("OpenMissionUI") -- Added for Mission Console
ensureEvent("ZoneChanged")

if RunService:IsStudio() then
	print("[Remotes] ensured RC_Remotes with OpenCommandUI, HatchRobot, HatchFX, CloseCommandUI, OpenMissionUI, ZoneChanged")
end

-- Connect HatchRobot event to HatchShow.run
local hatchEvt = folder and folder:FindFirstChild("HatchRobot")
local closeEvt = folder and folder:FindFirstChild("CloseCommandUI")
if hatchEvt and hatchEvt:IsA("RemoteEvent") then
  hatchEvt.OnServerEvent:Connect(function(player, payload)
    if closeEvt and closeEvt:IsA("RemoteEvent") then
      closeEvt:FireClient(player)
    end
    HatchShow.run({
      player = player,
      rarity = payload and payload.rarity or "common",
      name = payload and payload.name or nil,
    })
  end)
end
