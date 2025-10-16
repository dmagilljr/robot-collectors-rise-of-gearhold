--!strict

print("🖥️ robot-collectors-new-V1: client boot OK @", os.time())

-- Autoload client-side modules (HUD, FX, etc.)
local modulesFolder = script:FindFirstChild("modules")
if modulesFolder then
	for _, child in ipairs(modulesFolder:GetChildren()) do
		if child:IsA("ModuleScript") then
			pcall(function()
				require(child)
			end)
		elseif child:IsA("LocalScript") then
			pcall(function()
				require(child)
			end)
		end
	end
end

-- Explicitly require critical modules to guarantee load order
do
    local mods = script.Parent:WaitForChild("modules")
    pcall(function() require(mods:WaitForChild("MissionsHUD")) end)
    pcall(function() require(mods:WaitForChild("ResourceFX")) end)
end
