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
local SliderDistance = Mpage:AddSlider("Distance For Kill Aura", "Distance for the kill aura to activate (ONLY WORKS WHEN HOLDING YOUR WEAPON)", 200, 25, 10000)
local DistanceForKillAura = 200
SliderDistance.ValueUpdated:Connect(function(num)
    DistanceForKillAura = num
    print(num)
end)
KillAura.OnToggle:Connect(function(value)
    KillA = value
    task.spawn(function()
        while KillA do
            local p = game.Players.LocalPlayer
            local character = p.Character or p.CharacterAdded:Wait()
            local hrp = character:WaitForChild("HumanoidRootPart")
            local w = (p.Inventory:FindFirstChild("Old Axe") or p.Inventory:FindFirstChild("Good Axe") or p.Inventory:FindFirstChild("Strong Axe") 
                or p.Inventory:FindFirstChild("Chainsaw"))
            task.spawn(function()
                for _, b in pairs(workspace.Characters:GetChildren()) do
                    if b:IsA("Model") and b.PrimaryPart then
                        local distance = (b.PrimaryPart.Position - hrp.Position).Magnitude
                        if distance <= DistanceForKillAura then
                            local res = game:GetService("ReplicatedStorage").RemoteEvents.ToolDamageObject:InvokeServer(b, w, 999, hrp.CFrame)
                        end
                    end
                end
            end)
            wait(0.1)
        end
    end)
    
end)

local TPS = Ppage:AddButton("Teleport To Stronghold", "Teleports you directly to the stronghold.")

TPC.OnClick:Connect(function()
    if Workspace.Map.Landmarks.Stronghold.Building.Exterior then
        game.Players.LocalPlayer.Character:WaitForChild("HumanoidRootPart").CFrame = CFrame.new(Workspace.Map.Landmarks.Stronghold.Building.Exterior:GetChildren()[12].Model.Part.Position + Vector3.new(0, 15, 0))
    end
end)
 
local TPDC = Ppage:AddButton("Teleport To Diamond Chest", "Teleports you directly to the diamond chest.")

TPC.OnClick:Connect(function()
    game.Players.LocalPlayer.Character:WaitForChild("HumanoidRootPart").CFrame = Workspace.Map.Campground.MainFire.PrimaryPart.CFrame
end)

local function gethunger()
    return math.floor(game:GetService("Players").LocalPlayer.PlayerGui.Interface.StatBars.HungerBar.Bar.Size.X.Scale * 100)
end
local chosen = "Carrot"
local type = "Hunger %" 
local food = {
    "Apple",
    "Berry",
    "Carrot",
    "Cake",
    "Chili",
    "Cooked Morsel",
    "Cooked Steak"
}
local CF = AFpage:AddComboBox("Choose Food", "Choose a food to automatically eat.", food, chosen)
CF.OnChanged:Connect(function(v) 
    chosen = v
end)

local AEtype = AFpage:AddComboBox("Auto Eat Food Type", "Choose the type of automation.", {"Hunger %", "Every 3 Seconds"}, type)
AEtype.OnChanged:Connect(function(v) 
    type = v
end)
task.spawn(function()
    local hn = AFpage:AddTextBox("Hunger:", gethunger())
    local chosenfood = AFpage:AddTextBox("Chosen Food:", chosen)
    while true do
        task.wait(0.2)
        hn.Description = gethunger()
        chosenfood.Description = chosen
    end
end)


lib:SetEnabled(true)
