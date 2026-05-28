--// BlockSpin Pro - Final Combined Edition
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

--// 1. نظام الحماية المطور (يتحقق من key-511)
local KeyURL = "https://raw.githubusercontent.com/asd798072-max/key.txt/refs/heads/main/key.txt"
local RequiredKey = "key-511"

local success, response = pcall(function() return game:HttpGet(KeyURL) end)
local cleanResponse = string.gsub(response or "", "%s+", "")

if not (success and string.find(cleanResponse, RequiredKey)) then
    LocalPlayer:Kick("Key Error: Access Denied! الرمز غير صحيح.")
    return
end

--// 2. إعدادات السكربت
getgenv().Settings = { Silent = false, Tracer = false, FovCircle = false, FovRadius = 150, Prediction = 0.16 }

--// 3. الواجهة (UI)
local ScreenGui = Instance.new("ScreenGui", CoreGui)
local MainFrame = Instance.new("Frame", ScreenGui); MainFrame.Size = UDim2.new(0, 200, 0, 250); MainFrame.Position = UDim2.new(0.5, -100, 0.5, -125); MainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 20); MainFrame.Visible = false; MainFrame.Draggable = true

local function CreateBtn(name, setting)
    local btn = Instance.new("TextButton", MainFrame); btn.Size = UDim2.new(1, 0, 0, 40); btn.Position = UDim2.new(0, 0, 0, #MainFrame:GetChildren() * 45)
    btn.Text = name .. ": OFF"; btn.BackgroundColor3 = Color3.fromRGB(40, 40, 40); btn.TextColor3 = Color3.new(1,1,1)
    btn.MouseButton1Click:Connect(function()
        getgenv().Settings[setting] = not getgenv().Settings[setting]
        btn.Text = name .. ": " .. (getgenv().Settings[setting] and "ON" or "OFF")
    end)
end
CreateBtn("Silent", "Silent"); CreateBtn("Tracer", "Tracer"); CreateBtn("FOV Circle", "FovCircle")

local MenuBtn = Instance.new("ImageButton", ScreenGui); MenuBtn.Size = UDim2.new(0, 60, 0, 60); MenuBtn.Position = UDim2.new(0, 20, 0, 20); MenuBtn.BackgroundColor3 = Color3.fromRGB(255, 0, 0); MenuBtn.Draggable = true; Instance.new("UICorner", MenuBtn).CornerRadius = UDim.new(1, 0)
MenuBtn.MouseButton1Click:Connect(function() MainFrame.Visible = not MainFrame.Visible end)

--// 4. المحرك القاتل (Silent Aim Engine)
local function GetTarget()
    local Target, MinDist = nil, getgenv().Settings.FovRadius
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

local Hook; Hook = hookmetamethod(game, "__namecall", function(self, ...)
    local Args = {...}
    if getgenv().Settings.Silent and getnamecallmethod() == "FireServer" then
        local Target = GetTarget()
        if Target then
            Args[1] = Target.Position + (Target.Velocity * getgenv().Settings.Prediction)
            return self.FireServer(self, unpack(Args))
        end
    end
    return Hook(self, ...)
end)

--// 5. الرسم (Tracer & FOV)
local FOVCircle = Drawing.new("Circle"); FOVCircle.Radius = getgenv().Settings.FovRadius; FOVCircle.Filled = false; FOVCircle.Thickness = 2; FOVCircle.Visible = false
local TracerLine = Drawing.new("Line"); TracerLine.Thickness = 1; TracerLine.Visible = false

RunService.RenderStepped:Connect(function()
    FOVCircle.Position = Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y/2)
    FOVCircle.Visible = getgenv().Settings.FovCircle
    local Target = GetTarget()
    if getgenv().Settings.Tracer and Target then
        TracerLine.Visible = true; TracerLine.From = Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y/2)
        TracerLine.To = Vector2.new(Camera:WorldToViewportPoint(Target.Position).X, Camera:WorldToViewportPoint(Target.Position).Y)
    else TracerLine.Visible = false end
end)
