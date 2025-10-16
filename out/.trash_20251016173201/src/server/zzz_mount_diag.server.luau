local RS = game:GetService("ReplicatedStorage")
local SSS = game:GetService("ServerScriptService")
local okShared = RS:FindFirstChild("shared") ~= nil
local okModules = SSS:FindFirstChild("Modules") ~= nil
print(('[MOUNT] shared=%s  Modules=%s'):format(okShared and 'OK' or 'MISSING', okModules and 'OK' or 'MISSING'))
if okModules then
  local hasQS = SSS.Modules:FindFirstChild("QuestService") ~= nil
  local hasPR = SSS.Modules:FindFirstChild("ProgressionService") ~= nil
  print(('[MOUNT] QuestService=%s  ProgressionService=%s'):format(hasQS and 'OK' or 'MISSING', hasPR and 'OK' or 'MISSING'))
end
