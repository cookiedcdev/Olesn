local lib, env, c = ...

local InfJump = false

local title = lib:SetTitle("99 Nights In The Forest")

local Ppage = lib:AddPage("Player")

local Toggle = Ppage:AddToggle("Infinite Jump", "Makes your character jump indefinitely.", false)

Toggle.OnToggle:Connect(function(status)
    print(status)

    InfJump = status
    while InfJump do
        local plr = game:GetService('Players').LocalPlayer
        local m = plr:GetMouse()
        if InfJump and input.UserInputType == Enum.UserInputType.Keyboard and input.KeyCode == Enum.KeyCode.Space then -- PC JUMP
            local humanoid = player.Character and player.Character:FindFirstChildOfClass("Humanoid")
            if humanoid then
                humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
            end
        elseif InfJump and input.UserInputType == Enum.UserInputType.Touch then -- MOBILE JUMP
            local humanoid = player.Character and player.Character:FindFirstChildOfClass("Humanoid")
            if humanoid then
                humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
            end
        end
        wait(0.1)
    end
end)
local page2 = lib:AddPage("Page 2")

local button = page2:AddButton("Reset walkspeed", "Resets walkspeed", "Reset")

lib:SetEnabled(true)
