--!strict
local RS = game:GetService("ReplicatedStorage")
local folder = RS:FindFirstChild("RC_Remotes") :: Folder?
if not folder then
	folder = Instance.new("Folder")
	folder.Name = "RC_Remotes"
	folder.Parent = RS
end

local function ensureEvent(name: string): RemoteEvent
	local ev  = folder:FindFirstChild(name) :: RemoteEvent?
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

print("[Remotes] ensured RC_Remotes with OpenCommandUI, HatchRobot, HatchFX")
