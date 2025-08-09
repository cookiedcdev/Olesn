local lib, env, c = ...

local Ppage = lib:AddPage("Player")

local Toggle = Ppage:AddToggle("Infinite Jump", "Makes your character jump indefinitely.", false)

local page2 = lib:AddPage("Page 2")

local button = page2:AddButton("Reset walkspeed", "Resets walkspeed", "Reset")

lib:SetEnabled(true)
