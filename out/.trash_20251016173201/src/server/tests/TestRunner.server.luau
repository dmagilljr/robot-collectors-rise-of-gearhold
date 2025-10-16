--!strict
-- Minimal test harness: looks for ModuleScripts in ServerScriptService/Server/tests/specs and runs them.
local SSS = game:GetService("ServerScriptService")
local root = SSS:WaitForChild("Server")
local testsFolder = root:FindFirstChild("tests")
if not testsFolder then
	testsFolder = Instance.new("Folder"); testsFolder.Name = "tests"; testsFolder.Parent = root
end
local specs = testsFolder:FindFirstChild("specs")
if not specs then
	specs = Instance.new("Folder"); specs.Name = "specs"; specs.Parent = testsFolder
end

local function ok(name: string)
	print(("✅ PASS: %s"):format(name))
end
local function fail(name: string, msg: string)
	warn(("❌ FAIL: %s :: %s"):format(name, msg))
end

local function runSpec(mod: ModuleScript)
	local name = mod.Name
	local okRun, spec = pcall(require, mod)
	if not okRun then
		fail(name, "require error: ".. tostring(spec))
		return
	end
	if type(spec) ~= "table" or type(spec.run) ~= "function" then
		fail(name, "module must return { run = function() end }")
		return
	end
	local okSpec, msg = pcall(spec.run)
	if okSpec then ok(name) else fail(name, tostring(msg)) end
end

print("🧪 Running server specs…")
for _,m in ipairs(specs:GetChildren()) do
	if m:IsA("ModuleScript") then
		runSpec(m)
	end
end
print("🧪 Done.")
