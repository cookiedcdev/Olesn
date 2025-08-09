local lib, env, c = ...

local NoF = false

local title = lib:SetTitle("99 Nights In The Forest")

local Ppage = lib:AddPage("Player")

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local player = Players.LocalPlayer

local NoFog = Ppage:AddToggle("No Fog", "Turns off fog.")

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

local page2 = lib:AddPage("Bring Item")

local button = page2:AddButton("Reset walkspeed", "Resets walkspeed", "Reset")

lib:SetEnabled(true)
