local TestEZ = require(script.Parent.TestEZ)

local function gatherSpecs(folder)
    local modules = {}
    for _, child in ipairs(folder:GetChildren()) do
        if child:IsA("ModuleScript") then
            table.insert(modules, child)
        end
    end

    table.sort(modules, function(a, b)
        return a.Name < b.Name
    end)

    return modules
end

local TestRunner = {}

function TestRunner.run()
    local specsFolder = script.Parent:FindFirstChild("specs")
    if not specsFolder then
        error("No specs folder found for tests")
    end

    local specs = gatherSpecs(specsFolder)
    TestEZ.run(specs)
end

return TestRunner
