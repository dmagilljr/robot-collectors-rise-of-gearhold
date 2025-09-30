-- Lightweight TestEZ-style runner for quick module checks

local TestEZ = {}

local contextStack = {}
local anyFailures = false

local function prefixDescription(testName)
    if #contextStack == 0 then
        return testName
    end
    return table.concat(contextStack, " :: ") .. " :: " .. testName
end

function TestEZ.describe(description, callback)
    table.insert(contextStack, description)
    local ok, err = pcall(callback)
    if not ok then
        warn("[DESCRIBE ERROR] " .. prefixDescription("<setup>") .. " => " .. err)
        anyFailures = true
    end
    table.remove(contextStack)
end

function TestEZ.it(description, callback)
    local fullName = prefixDescription(description)
    local ok, err = pcall(callback)
    if ok then
        print("[PASS] " .. fullName)
    else
        warn("[FAIL] " .. fullName .. " => " .. err)
        anyFailures = true
    end
end

function TestEZ.expect(value)
    local expectation = {}

    function expectation.toEqual(expected)
        if value ~= expected then
            error(string.format("expected %s but got %s", tostring(expected), tostring(value)))
        end
    end

    function expectation.toBeTruthy()
        if not value then
            error("expected value to be truthy")
        end
    end

    function expectation.toBeInstanceOf(className)
        if typeof(value) ~= "Instance" or not value:IsA(className) then
            error(string.format("expected instance of %s", className))
        end
    end

    return expectation
end

function TestEZ.run(specModules)
    anyFailures = false
    for _, moduleScript in ipairs(specModules) do
        local spec = require(moduleScript)
        if typeof(spec) == "function" then
            spec(TestEZ)
        end
    end

    if anyFailures then
        error("One or more tests failed")
    end

    print("✅ All tests passed")
end

return TestEZ
