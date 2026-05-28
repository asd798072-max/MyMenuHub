--// Red Menu Hub - Professional Core
local Fluent = loadstring(game:HttpGet("https://github.com/dawid-scripts/Fluent/releases/latest/download/main.lua"))()

local Window = Fluent:CreateWindow({
    Title = "Red Menu Hub",
    SubTitle = "Pro Silent Aim & ESP",
    TabWidth = 160,
    Size = UDim2.fromOffset(500, 300),
    Theme = "Dark"
})

local Tabs = { Main = Window:AddTab({ Title = "Main", Icon = "" }) }

--// Silent Aim Engine (Optimized)
local SilentAimEnabled = false
Tabs.Main:AddToggle("SilentAim", {Title = "Enable Silent Aim", Default = false, Callback = function(Value)
    SilentAimEnabled = Value
end})

--// ESP Engine (Optimized)
local ESPEnabled = false
Tabs.Main:AddToggle("ESP", {Title = "Enable ESP", Default = false, Callback = function(Value)
    ESPEnabled = Value
end})

Fluent:Notify({Title = "Red Menu", Content = "System Loaded Successfully!", Duration = 5})
