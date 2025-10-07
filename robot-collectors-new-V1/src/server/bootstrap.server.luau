--!strict
local SSS = game:GetService("ServerScriptService")

-- Defer so Rojo has time to materialize ServerScriptService/World tree
task.defer(function()
	print(("🤖 server init: %d"):format(os.time()))

	local ok, mod = pcall(function()
		local world = SSS:WaitForChild("World")
		local wb = world:WaitForChild("WorldBoot")
		return require(wb)
	end)

	if ok and mod and type(mod) == "table" and type(mod.run) == "function" then
		mod.run()
	else
		warn("[init] WorldBoot missing or invalid:", ok, mod)
	end
end)
