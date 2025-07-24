local repo = 'https://raw.githubusercontent.com/mstudio45/LinoriaLib/main/'

local Library = loadstring(game:HttpGet(repo .. 'Library.lua'))()
local ThemeManager = loadstring(game:HttpGet(repo .. 'addons/ThemeManager.lua'))()
local SaveManager = loadstring(game:HttpGet(repo .. 'addons/SaveManager.lua'))()
local Options = Library.Options
local Toggles = Library.Toggles

Library.ShowToggleFrameInKeybinds = true
Library.ShowCustomCursor = true 
Library.NotifySide = "Left"

local Window = Library:CreateWindow({
    Title = "Econix - Universal Script",
    Footer = "Made with love by Cookie <3",
	Center = true,
	AutoShow = true,
	Resizable = true,
	ShowCustomCursor = true,
	TabPadding = 2,
	MenuFadeTime = 0
})

local Tabs = {
    Main = Window:AddTab("Main", "gamepad-2"),
    Other = Window:AddTab("Other", "settings"),
    Misc = Window:AddTab("Misc", "wrench"),
    Visuals = Window:AddTab("Visuals", "eye"),
}

local Maid = {}
Maid.__index = Maid

function Maid.new()
    return setmetatable({Tasks = {}}, Maid)
end

function Maid:Add(task)
    if typeof(task) == "RBXScriptConnection" or (typeof(task) == "Instance" and task.Destroy) or typeof(task) == "function" then
        table.insert(self.Tasks, task)
    end
    return task
end

function Maid:Clean()
    for _, task in ipairs(self.Tasks) do
		pcall(function()
			if typeof(task) == "RBXScriptConnection" then
				task:Disconnect()
			elseif typeof(task) == "Instance" then
				task:Destroy()
			elseif typeof(task) == "function" then
				task()
			end
		end)
    end
	table.clear(self.Tasks)
    self.Tasks = {}
end

local Players = Services.Players
local Lighting = Services.Lighting
local RunService = Services.RunService
local HttpService = Services.HttpService
local TweenService = Services.TweenService
local UserInputService = Services.UserInputService
local ReplicatedStorage = Services.ReplicatedStorage
local ProximityPromptService = Services.ProximityPromptService

local lplr = Players.LocalPlayer
local localPlayer = lplr

local camera = workspace.CurrentCamera

type ESP = {
    Color: Color3,
    IsEntity: boolean,
    Object: Instance,
    Offset: Vector3,
    Text: string,
    TextParent: Instance,
    Type: string,
}

local Script = {
    GameStateChanged = Instance.new("BindableEvent"),
    GameState = "unknown",
    Services = Services,
    Maid = Maid.new(),
    Connections = {},
    Functions = {},
    ESPTable = {
        Player = {},
        Seeker = {},
        Hider = {},
        Guard = {},
        Door = {},
        None = {},
        Key = {},
        EscapeDoor = {}
    },
    Temp = {}
}

local States = {}

function Script.Functions.Alert(message: string, time_obj: number)
    Library:Notify(message, time_obj or 5)

    --if TogglesNotifySound..Value then
        local sound = Instance.new("Sound", workspace) do
            sound.SoundId = "rbxassetid://4590662766"
            sound.Volume = 2
            sound.PlayOnRemove = true
            sound:Destroy()
        end
    --end
end

function Script.Functions.Warn(message: string)
    warn("WARN - voidware:", message)
end

function Script.Functions.ESP(args: ESP)
    if not args.Object then return Script.Functions.Warn("ESP Object is nil") end

    local ESPManager = {
        Object = args.Object,
        Text = args.Text or "No Text",
        TextParent = args.TextParent,
        Color = args.Color or Color3.new(),
        Offset = args.Offset or Vector3.zero,
        IsEntity = args.IsEntity or false,
        Type = args.Type or "None",

        Highlights = {},
        Humanoid = nil,
        RSConnection = nil,

        Connections = {}
    }

    local tableIndex = #Script.ESPTable[ESPManager.Type] + 1

    if ESPManager.IsEntity and ESPManager.Object.PrimaryPart.Transparency == 1 then
        ESPManager.Object:SetAttribute("Transparency", ESPManager.Object.PrimaryPart.Transparency)
        ESPManager.Humanoid = Instance.new("Humanoid", ESPManager.Object)
        ESPManager.Object.PrimaryPart.Transparency = 0.99
    end

    local highlight = Instance.new("Highlight") do
        highlight.Adornee = ESPManager.Object
        highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
        highlight.FillColor = ESPManager.Color
        highlight.FillTransparency = Options.ESPFillTransparency.Value
        highlight.OutlineColor = ESPManager.Color
        highlight.OutlineTransparency = Options.ESPOutlineTransparency.Value
        highlight.Enabled = Toggles.ESPHighlight.Value
        highlight.Parent = ESPManager.Object
    end

    table.insert(ESPManager.Highlights, highlight)
    

    local billboardGui = Instance.new("BillboardGui") do
        billboardGui.Adornee = ESPManager.TextParent or ESPManager.Object
		billboardGui.AlwaysOnTop = true
		billboardGui.ClipsDescendants = false
		billboardGui.Size = UDim2.new(0, 1, 0, 1)
		billboardGui.StudsOffset = ESPManager.Offset
        billboardGui.Parent = ESPManager.TextParent or ESPManager.Object
	end

    local textLabel = Instance.new("TextLabel") do
		textLabel.BackgroundTransparency = 1
		textLabel.Font = Enum.Font.Oswald
		textLabel.Size = UDim2.new(1, 0, 1, 0)
		textLabel.Text = ESPManager.Text
		textLabel.TextColor3 = ESPManager.Color
		textLabel.TextSize = Options.ESPTextSize.Value
        textLabel.TextStrokeColor3 = Color3.new(0, 0, 0)
        textLabel.TextStrokeTransparency = 0.75
        textLabel.Parent = billboardGui
	end

    function ESPManager.SetColor(newColor: Color3)
        ESPManager.Color = newColor

        for _, highlight in pairs(ESPManager.Highlights) do
            highlight.FillColor = newColor
            highlight.OutlineColor = newColor
        end

        textLabel.TextColor3 = newColor
    end

    function ESPManager.Destroy()
        if ESPManager.RSConnection then
            ESPManager.RSConnection:Disconnect()
        end

        if ESPManager.IsEntity and ESPManager.Object then
            if ESPManager.Object.PrimaryPart then
                ESPManager.Object.PrimaryPart.Transparency = ESPManager.Object.PrimaryPart:GetAttribute("Transparency")
            end
            if ESPManager.Humanoid then
                ESPManager.Humanoid:Destroy()
            end
        end

        for _, highlight in pairs(ESPManager.Highlights) do
            highlight:Destroy()
        end
        if billboardGui then billboardGui:Destroy() end

        if Script.ESPTable[ESPManager.Type][tableIndex] then
            Script.ESPTable[ESPManager.Type][tableIndex] = nil
        end

        for _, conn in pairs(ESPManager.Connections) do
            pcall(function()
                conn:Disconnect()
            end)
        end
        ESPManager.Connections = {}
    end

    ESPManager.RSConnection = RunService.RenderStepped:Connect(function()
        if not ESPManager.Object or not ESPManager.Object:IsDescendantOf(workspace) then
            ESPManager.Destroy()
            return
        end

        for _, highlight in pairs(ESPManager.Highlights) do
            highlight.Enabled = Toggles.ESPHighlight.Value
            highlight.FillTransparency = Options.ESPFillTransparency.Value
            highlight.OutlineTransparency = Options.ESPOutlineTransparency.Value
        end
        textLabel.TextSize = Options.ESPTextSize.Value

        if Toggles.ESPDistance.Value then
            textLabel.Text = string.format("%s\n[%s]", ESPManager.Text, math.floor(Script.Functions.DistanceFromCharacter(ESPManager.Object)))
        else
            textLabel.Text = ESPManager.Text
        end
    end)

    function ESPManager.GiveSignal(signal)
        table.insert(ESPManager.Connections, signal)
    end

    Script.ESPTable[ESPManager.Type][tableIndex] = ESPManager
    return ESPManager
end

function Script.Functions.GuardESP(character)
    if character and character:FindFirstChild("HumanoidRootPart") then
        local esp = Script.Functions.ESP({
            Object = character,
            Text = "Guard",
            Color = Options.GuardEspColor.Value,
            Offset = Vector3.new(0, 3, 0),
            Type = "Guard"
        })
        table.insert(esp.Connections, character.ChildAdded:Connect(function(v)
            if v.Name == "Dead" and v.ClassName == "Folder" then
                esp.Destroy()
            end
        end))
    end
end

function Script.Functions.PlayerESP(player: Player)
    if not (player.Character and player.Character.PrimaryPart and player.Character:FindFirstChild("Humanoid") and player.Character.Humanoid.Health > 0) then return end

    local playerEsp = Script.Functions.ESP({
        Type = "Player",
        Object = player.Character,
        Text = string.format("%s [%s]", player.DisplayName, player.Character.Humanoid.Health),
        TextParent = player.Character.PrimaryPart,
        Color = Options.PlayerEspColor.Value
    })

    playerEsp.GiveSignal(player.Character.Humanoid.HealthChanged:Connect(function(newHealth)
        if newHealth > 0 then
            playerEsp.Text = string.format("%s [%s]", player.DisplayName, newHealth)
        else
            playerEsp.Destroy()
        end
    end))
end

local MAIN_ESP_META = {
    {
        metaName = "PlayerESP",
        text = "Player",
        default = false,
        color = {
            metaName = "PlayerEspColor",
            default = Color3.fromRGB(255, 255, 255)
        },
        func = function()
            for _, player in pairs(Players:GetPlayers()) do
                if player == localPlayer then continue end
                Script.Functions.PlayerESP(player)
            end
        end
    },
    {
        metaName = "GuardESP",
        text = "Guard",
        default = false,
        color = {
            metaName = "GuardEspColor",
            default = Color3.fromRGB(200, 100, 200)
        },
        func = function()
            local live = workspace:FindFirstChild("Live")
            if not live then return end
            for _, descendant in pairs(live:GetChildren()) do
                if descendant:IsA("Model") and descendant.Parent and descendant.Parent.Name == "Live" and descendant:FindFirstChild("TypeOfGuard") then
                    if string.find(descendant.Name, "RebelGuard") or string.find(descendant.Name, "FinalRebel") or string.find(descendant.Name, "HallwayGuard") or string.find(string.lower(descendant.Name), "aggro") then
                        Script.Functions.GuardESP(descendant)
                    end
                end
            end
        end,
        descendantcheck = function(descendant)
            if descendant:IsA("Model") and descendant.Parent and descendant.Parent.Name == "Live" and descendant:FindFirstChild("TypeOfGuard") then
                if string.find(descendant.Name, "RebelGuard") or string.find(descendant.Name, "FinalRebel") or string.find(descendant.Name, "HallwayGuard") or string.find(string.lower(descendant.Name), "aggro") then
                    Script.Functions.GuardESP(descendant)
                end
            end
        end
    }
}

local MainESPGroup = Tabs.Visuals:AddLeftGroupbox("Main ESP", "eye") do
    for _, meta in pairs(MAIN_ESP_META) do
        MainESPGroup:AddToggle(meta.metaName, {
            Text = meta.text,
            Default = meta.default
        }):AddColorPicker(meta.color.metaName, {
            Default = meta.color.default
        })

        Toggles[meta.metaName]:OnChanged(function(call)
            if call then
                if meta.func then
                    meta.func(call)
                end
            else
                for _, esp in pairs(Script.ESPTable[meta.text]) do
                    esp.Destroy()
                end
            end
        end)

        if meta.descendantcheck then
            Library:GiveSignal(workspace.DescendantAdded:Connect(function(descendant)
                if not Toggles[meta.metaName].Value then return end
                meta.descendantcheck(descendant)
            end))
        end
    end
end
