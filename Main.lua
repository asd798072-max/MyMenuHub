--// BlockSpin Pro - Ultimate Edition V3
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui")
local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()
local Camera = workspace.CurrentCamera

getgenv().Silent = false
getgenv().ESP = false
getgenv().Tracer = false
getgenv().FovCircle = false
getgenv().FovRadius = 500

local ESP_Drawings = {}
local FOVCircle = Drawing.new("Circle")
FOVCircle.Position = Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y/2)
FOVCircle.Radius = getgenv().FovRadius
FOVCircle.Visible = false
FOVCircle.Color = Color3.fromRGB(255, 255, 255)
FOVCircle.Filled = false
FOVCircle.Thickness = 2

local Tracer = Drawing.new("Line")
Tracer.Visible = false
Tracer.Color = Color3.fromRGB(255, 255, 255)
Tracer.Thickness = 1

local ScreenGui = Instance.new("ScreenGui", CoreGui)
local MainFrame = Instance.new("Frame", ScreenGui); MainFrame.Size = UDim2.new(0, 200, 0, 300); MainFrame.Position = UDim2.new(0.5, -100, 0.5, -150); MainFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30); MainFrame.Visible = false

local function CreateBtn(name, callback)
    local btn = Instance.new("TextButton", MainFrame); btn.Size = UDim2.new(1, 0, 0, 40); btn.Position = UDim2.new(0, 0, 0, #MainFrame:GetChildren() * 45)
    btn.Text = name; btn.MouseButton1Click:Connect(function() callback(btn) end)
end

CreateBtn("Silent: OFF", function(btn) getgenv().Silent = not getgenv().Silent; btn.Text = "Silent: " .. (getgenv().Silent and "ON" or "OFF") end)
CreateBtn("ESP: OFF", function(btn) getgenv().ESP = not getgenv().ESP; btn.Text = "ESP: " .. (getgenv().ESP and "ON" or "OFF") end)
CreateBtn("Tracer: OFF", function(btn) getgenv().Tracer = not getgenv().Tracer; btn.Text = "Tracer: " .. (getgenv().Tracer and "ON" or "OFF") end)
CreateBtn("FOV Circle: OFF", function(btn) getgenv().FovCircle = not getgenv().FovCircle; btn.Text = "FOV: " .. (getgenv().FovCircle and "ON" or "OFF"); FOVCircle.Visible = getgenv().FovCircle end)
CreateBtn("FOV Size +50", function() getgenv().FovRadius = (getgenv().FovRadius >= 500 and 50 or getgenv().FovRadius + 50); FOVCircle.Radius = getgenv().FovRadius end)

local MenuBtn = Instance.new("ImageButton", ScreenGui); MenuBtn.Size = UDim2.new(0, 60, 0, 60); MenuBtn.Position = UDim2.new(0, 20, 0, 20); MenuBtn.BackgroundColor3 = Color3.fromRGB(255, 0, 0); MenuBtn.Draggable = true
Instance.new("UICorner", MenuBtn).CornerRadius = UDim.new(1, 0)
MenuBtn.MouseButton1Click:Connect(function() MainFrame.Visible = not MainFrame.Visible end)

local function GetClosest()
    local Target, MinDist = nil, getgenv().FovRadius
    local Center = Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y/2)
    for _, v in pairs(Players:GetPlayers()) do
        if v ~= LocalPlayer and v.Character and v.Character:FindFirstChild("HumanoidRootPart") and v.Character.Humanoid.Health > 0 then
            local Pos, OnScreen = Camera:WorldToViewportPoint(v.Character.HumanoidRootPart.Position)
            local Dist = (Center - Vector2.new(Pos.X, Pos.Y)).Magnitude
            if OnScreen and Dist < MinDist then MinDist = Dist; Target = v.Character.HumanoidRootPart end
        end
    end
    return Target
end

local MT = getrawmetatable(game); setreadonly(MT, false); local Old = MT.__index
MT.__index = newcclosure(function(self, k)
    if getgenv().Silent and k == "Hit" then
        local Target = GetClosest()
        if Target then return Target.CFrame end
    end
    return Old(self, k)
end)

RunService.RenderStepped:Connect(function()
    FOVCircle.Position = Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y/2)
    local Target = GetClosest()
    Tracer.Visible = (Target and getgenv().Tracer)
    if Target and getgenv().Tracer then
        Tracer.From = Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y/2)
        Tracer.To = Vector2.new(Camera:WorldToViewportPoint(Target.Position).X, Camera:WorldToViewportPoint(Target.Position).Y)
    end
    for _, d in pairs(ESP_Drawings) do d:Remove() end; ESP_Drawings = {}
    if getgenv().ESP then
        for _, v in pairs(Players:GetPlayers()) do
            if v ~= LocalPlayer and v.Character and v.Character:FindFirstChild("HumanoidRootPart") and v.Character.Humanoid.Health > 0 then
                local Pos, Vis = Camera:WorldToViewportPoint(v.Character.HumanoidRootPart.Position)
                if Vis and (Vector2.new(Mouse.X, Mouse.Y) - Vector2.new(Pos.X, Pos.Y)).Magnitude < getgenv().FovRadius then
                    local Line = Drawing.new("Line"); Line.Visible = true; Line.Color = Color3.new(0, 1, 0); Line.From = Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y/2); Line.To = Vector2.new(Pos.X, Pos.Y); table.insert(ESP_Drawings, Line)
                end
            end
        end
    end
end)
