--!strict
local RS = game:GetService("ReplicatedStorage")
local rem = RS:WaitForChild("RC_Remotes"):WaitForChild("HatchFX")

rem.OnClientEvent:Connect(function()
	-- very simple: flash the screen briefly
	local pg = game:GetService("Players").LocalPlayer:WaitForChild("PlayerGui")
	local gui = Instance.new("ScreenGui"); gui.Name="RC_HatchFlash"; gui.ResetOnSpawn=false; gui.Parent=pg
	local f = Instance.new("Frame"); f.Size=UDim2.fromScale(1,1); f.BackgroundColor3=Color3.fromRGB(80,160,255); f.BackgroundTransparency=0.7; f.Parent=gui
	task.delay(0.15, function() gui:Destroy() end)
end)
