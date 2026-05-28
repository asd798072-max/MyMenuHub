--// BlockSpin Pro - Ultimate Edition
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui")
local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()
local Camera = workspace.CurrentCamera

getgenv().Silent = false
getgenv().ESP = false
getgenv().FovRadius = 150

--// Visuals
local FOVCircle = Drawing.new("Circle")
FOVCircle.Position = Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y/2)
FOVCircle.Radius = getgenv().FovRadius
FOVCircle.Visible = false
FOVCircle.Color = Color3.fromRGB(255, 255, 255)
FOVCircle.Thickness = 1

local Tracer = Drawing.new("Line")
Tracer.Visible = false
Tracer.Color = Color3.fromRGB(255, 255, 255)
Tracer.Thickness = 1

--// UI Setup
local ScreenGui = Instance.new("ScreenGui", CoreGui)
local MainFrame = Instance.new("Frame", ScreenGui); MainFrame.Size = UDim2.new(0, 200, 0, 250); MainFrame.Position = UDim2.new(0.5, -100, 0.5, -125); MainFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
MainFrame.Visible = false; MainFrame.Active = true; MainFrame.Draggable = true

local function CreateBtn(name, callback)
    local btn = Instance.new("TextButton", MainFrame); btn.Size = UDim2.new(1, 0, 0, 40); btn.Position = UDim2.new(0, 0, 0, #MainFrame:GetChildren() * 45)
    btn.Text = name; btn.MouseButton1Click:Connect(function() callback(btn) end)
end

CreateBtn("Silent: OFF", function(btn) getgenv().Silent = not getgenv().Silent; btn.Text = "Silent: " .. (getgenv().Silent and "ON" or "OFF"); FOVCircle.Visible = getgenv().Silent end)
CreateBtn("ESP: OFF", function(btn) getgenv().ESP = not getgenv().ESP; btn.Text = "ESP: " .. (getgenv().ESP and "ON" or "OFF") end)
CreateBtn("FOV Size +50", function() getgenv().FovRadius = getgenv().FovRadius + 50; FOVCircle.Radius = getgenv().FovRadius end)

local MenuBtn = Instance.new("ImageButton", ScreenGui); MenuBtn.Size = UDim2.new(0, 60, 0, 60); MenuBtn.Position = UDim2.new(0, 20, 0, 20); MenuBtn.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
Instance.new("UICorner", MenuBtn).CornerRadius = UDim.new(1, 0)
MenuBtn.MouseButton1Click:Connect(function() MainFrame.Visible = not MainFrame.Visible end)

--// Logic
local MT = getrawmetatable(game); setreadonly(MT, false); local Old = MT.__index
MT.__index = newcclosure(function(self, k)
    if getgenv().Silent and k == "Hit" then
        local Target, Min = nil, getgenv().FovRadius
        for _, v in pairs(Players:GetPlayers()) do
            if v ~= LocalPlayer and v.Character and v.Character:FindFirstChild("Head") then
                local Pos, OnScreen = Camera:WorldToViewportPoint(v.Character.Head.Position)
                local Dist = (Vector2.new(Mouse.X, Mouse.Y) - Vector2.new(Pos.X, Pos.Y)).Magnitude
                if OnScreen and Dist < Min then Min = Dist; Target = v.Character.Head end
            end
        end
        if Target then return Target.CFrame end
    end
    return Old(self, k)
end)

RunService.RenderStepped:Connect(function()
    FOVCircle.Position = Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y/2)
    local Target = nil; local MinDist = getgenv().FovRadius
    for _, v in pairs(Players:GetPlayers()) do
        if v ~= LocalPlayer and v.Character and v.Character:FindFirstChild("Head") then
            local Pos, OnScreen = Camera:WorldToViewportPoint(v.Character.Head.Position)
            local Dist = (Vector2.new(Mouse.X, Mouse.Y) - Vector2.new(Pos.X, Pos.Y)).Magnitude
            if OnScreen and Dist < MinDist then MinDist = Dist; Target = v.Character.Head end
        end
    end
    
    if Target and getgenv().Silent then
        Tracer.Visible = true; Tracer.From = Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y/2)
        Tracer.To = Vector2.new(Camera:WorldToViewportPoint(Target.Position).X, Camera:WorldToViewportPoint(Target.Position).Y)
    else
        Tracer.Visible = false
    end
    
    for _, v in pairs(CoreGui:GetChildren()) do if v.Name == "ESP_Line" then v:Destroy() end end
    if getgenv().ESP then
        for _, v in pairs(Players:GetPlayers()) do
            if v ~= LocalPlayer and v.Character and v.Character:FindFirstChild("Head") then
                local Pos, Vis = Camera:WorldToViewportPoint(v.Character.Head.Position)
                if Vis then
                    local Line = Instance.new("Frame", CoreGui); Line.Name = "ESP_Line"; Line.BackgroundColor3 = Color3.fromRGB(0, 255, 0)
                    Line.Size = UDim2.new(0, 2, 0, 30); Line.Position = UDim2.new(0, Pos.X, 0, Pos.Y)
                end
            end
        end
    end
end)
