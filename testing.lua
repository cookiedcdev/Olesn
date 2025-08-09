local lib, env, c = ...

local InfJump = false

local title = lib:SetTitle("99 Nights In The Forest")

local Ppage = lib:AddPage("Player")

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local player = Players.LocalPlayer

local Toggle = Ppage:AddToggle("Infinite Jump", "Makes your character jump indefinitely.", false)

UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end

    if InfJump and input.UserInputType == Enum.UserInputType.Touch then
        local humanoid = player.Character and player.Character:FindFirstChildOfClass("Humanoid")
        if humanoid then
            humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
            task.wait()
            humanoid:ChangeState(Enum.HumanoidStateType.Seated)
        end
    end
end)

Toggle.OnToggle:Connect(function(status)
    print(status)

    InfJump = status
end)
local page2 = lib:AddPage("Page 2")

local button = page2:AddButton("Reset walkspeed", "Resets walkspeed", "Reset")

lib:SetEnabled(true)
