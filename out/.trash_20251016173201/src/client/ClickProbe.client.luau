-- ClickProbe.client.luau
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local GuiService = game:GetService("GuiService")
local RunService = game:GetService("RunService")
local player = Players.LocalPlayer
local mouse = player:GetMouse()

local function fullPath(inst: Instance): string
	if not inst then return "<nil>" end
	local names = {}
	local cur = inst
	while cur and cur ~= game do
		table.insert(names, 1, cur.Name)
		cur = cur.Parent
	end
	return table.concat(names, ".")
end

local function logTarget(tag: string, inst: Instance)
	if not inst then
		print(tag.." <nil>")
		return
	end
	print(string.format("%s %s path=%s", tag, inst.ClassName, fullPath(inst)))
end

-- World click (BaseParts etc.)
mouse.Button1Down:Connect(function()
	logTarget("[CLICK→Target]", mouse.Target)
	-- Also log first GUI object under cursor (if squares are UI)
	local guiObjects = GuiService:GetGuiObjectsAtPosition(mouse.X, mouse.Y)
	if #guiObjects > 0 then
		print("[CLICK→GUI under cursor]")
		for i,obj in ipairs(guiObjects) do
			print(string.format("  #%d %s path=%s", i, obj.ClassName, fullPath(obj)))
		end
	else
		print("[CLICK→GUI under cursor] none")
	end
end)

print("🖱️ ClickProbe ACTIVE — click a square; watch Output for [CLICK→Target] and GUI entries")
