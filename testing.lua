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
        m.KeyDown:connect(function(k)
            if InfJump then
                if k:byte() == 32 then
                    humanoid = game:GetService 'Players'.LocalPlayer.Character:FindFirstChildOfClass('Humanoid')
                    humanoid:ChangeState('Jumping')
                    wait()
                    humanoid:ChangeState('Seated')
                end
            end
        end)
        wait(0.1)
    end
end)
local page2 = lib:AddPage("Page 2")

local button = page2:AddButton("Reset walkspeed", "Resets walkspeed", "Reset")

lib:SetEnabled(true)
