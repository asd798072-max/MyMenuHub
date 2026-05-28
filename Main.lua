--// Red Menu Hub - BlockSpin Optimized
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()
local Camera = workspace.CurrentCamera

getgenv().SilentEnabled = false

--// UI Setup
local ScreenGui = Instance.new("ScreenGui", game:GetService("CoreGui"))
local MainFrame = Instance.new("Frame", ScreenGui)
MainFrame.Size = UDim2.new(0, 200, 0, 150)
MainFrame.Position = UDim2.new(0.5, -100, 0.5, -75)
MainFrame.Visible = false
MainFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)

local MenuBtn = Instance.new("ImageButton", ScreenGui)
MenuBtn.Size = UDim2.new(0, 50, 0, 50)
MenuBtn.Position = UDim2.new(0, 50, 0, 50)
MenuBtn.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
Instance.new("UICorner", MenuBtn).CornerRadius = UDim.new(1, 0)

MenuBtn.MouseButton1Click:Connect(function()
    MainFrame.Visible = not MainFrame.Visible
end)

local ToggleBtn = Instance.new("TextButton", MainFrame)
ToggleBtn.Size = UDim2.new(1, 0, 1, 0)
ToggleBtn.Text = "Silent Aim: OFF"
ToggleBtn.TextColor3 = Color3.new(1, 1, 1)
ToggleBtn.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
ToggleBtn.MouseButton1Click:Connect(function()
    getgenv().SilentEnabled = not getgenv().SilentEnabled
    ToggleBtn.Text = getgenv().SilentEnabled and "Silent Aim: ON" or "Silent Aim: OFF"
end)

--// Silent Aim Logic
local function GetClosest()
    local Closest, Dist = nil, math.huge
    for _, v in pairs(Players:GetPlayers()) do
        if v ~= LocalPlayer and v.Character and v.Character:FindFirstChild("Head") then
            local Pos, OnScreen = Camera:WorldToViewportPoint(v.Character.Head.Position)
            local Mag = (Vector2.new(Mouse.X, Mouse.Y) - Vector2.new(Pos.X, Pos.Y)).Magnitude
            if Mag < Dist then Closest = v.Character.Head; Dist = Mag end
        end
    end
    return Closest
end

local MT = getrawmetatable(game)
local OldIndex = MT.__index
setreadonly(MT, false)
MT.__index = newcclosure(function(self, k)
    if getgenv().SilentEnabled and k == "Hit" and tostring(self) == "Mouse" then
        local Target = GetClosest()
        if Target then return Target.CFrame end
    end
    return OldIndex(self, k)
end)
setreadonly(MT, true)
