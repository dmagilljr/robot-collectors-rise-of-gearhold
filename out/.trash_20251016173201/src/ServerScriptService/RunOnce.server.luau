-- same content as above
local Terrain = workspace.Terrain
local BOX_CENTER = Vector3.new(0,0,-40)
local BOX_SIZE   = Vector3.new(80,16,80)
local function inBox(v) return math.abs(v.X-BOX_CENTER.X)<=BOX_SIZE.X/2 and math.abs(v.Y-BOX_CENTER.Y)<=BOX_SIZE.Y/2 and math.abs(v.Z-BOX_CENTER.Z)<=BOX_SIZE.Z/2 end
print("🧩 RunOnce START (SERVER)", os.time(), "box=", BOX_CENTER, "size=", BOX_SIZE)
local hits,killed=0,0
for _,inst in ipairs(workspace:GetDescendants()) do
    if inst:IsA("BasePart") then
        local p = inst.Position
        if inBox(p) then
            hits+=1; print("[HIT]", inst:GetFullName(), inst.Size, inst.Position)
            inst:Destroy(); killed+=1
        end
    end
end
print(("[SCAN] parts_hit=%d killed=%d"):format(hits,killed))
workspace.Terrain:FillBlock(CFrame.new(BOX_CENTER), BOX_SIZE, Enum.Material.Air)
print("[TERRAIN] cleared server box", BOX_CENTER, BOX_SIZE)
print("🧩 RunOnce END (SERVER) — removing script"); script:Destroy()
