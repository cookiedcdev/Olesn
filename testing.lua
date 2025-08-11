local lib, env, c = ...

local NoF, KillA, SafeZone = false, false, false

local title = lib:SetTitle("99 Nights In The Forest")

local Mpage = lib:AddPage("Main")
local AFpage = lib:AddPage("Auto Farm")
local Ppage = lib:AddPage("Player")
local Gpage = lib:AddPage("Game")

-- Main

local ShowSZ = Mpage:AddToggle("Show Safe Zone", "Shows you the safe zone.", false)


local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local player = Players.LocalPlayer

local NoFog = Ppage:AddToggle("No Fog", "Turns off fog.", false)

NoFog.OnToggle:Connect(function()
    NoF = Value
    while NoF do
        for _, part in pairs(Workspace.Map.Boundaries:GetChildren()) do
            if part:isA("Part") then
                part:Destroy()
            end
        end
        wait(0.1)
    end
end)

local TPC = Ppage:AddButton("Teleport To Campfire", "Teleports you directly to the campfire.")

TPC.OnClick:Connect(function()
    game.Players.LocalPlayer.Character:WaitForChild("HumanoidRootPart").CFrame = Workspace.Map.Campground.MainFire.PrimaryPart.CFrame
end)

local KillAura = Mpage:AddToggle("Kill Aura", "Activates kill aura for enemies", false)
local SliderDistance = Mpage:AddSlider("Distance For Kill Aura", "Distance for the kill aura to activate", 25, 25, 10000)
local DistanceForKillAura = 25
SliderDistance.ValueUpdated:Connect(function(num)
    DistanceForKillAura = num
    print(num)
end)
KillAura.OnToggle:Connect(function(value)
    KillA = value
    task.spawn(function()
        while KillA do
            local player = game.Players.LocalPlayer
            local character = player.Character or player.CharacterAdded:Wait()
            local hrp = character:WaitForChild("HumanoidRootPart")
            local weapon = (player.Inventory:FindFirstChild("Old Axe") or
                                player.Inventory:FindFirstChild("Good Axe") or
                                player.Inventory:FindFirstChild("Strong Axe") or
                                player.Inventory:FindFirstChild("Chainsaw"))
            task.spawn(function()
                for _, bunny in pairs(workspace.Characters:GetChildren()) do
                    if bunny:IsA("Model") and bunny.PrimaryPart then
                        local distance = (bunny.PrimaryPart.Position - hrp.Position).Magnitude
                        if distance <= DistanceForKillAura then
                            local result =
                                game:GetService("ReplicatedStorage").RemoteEvents.ToolDamageObject:InvokeServer(
                                    bunny, weapon, 999, hrp.CFrame)
                        end
                    end
                end
            end)
            wait(0.1)
        end
    end)
    
end)
local page2 = lib:AddPage("Bring Item")

local button = page2:AddButton("Reset walkspeed", "Resets walkspeed", "Reset")

lib:SetEnabled(true)
