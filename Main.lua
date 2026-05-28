--// BlockSpin Pro - Final Advanced Edition
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

--// UI Setup
local ScreenGui = Instance.new("ScreenGui", CoreGui)
local KeyFrame = Instance.new("Frame", ScreenGui); KeyFrame.Size = UDim2.new(0, 250, 0, 150); KeyFrame.Position = UDim2.new(0.5, -125, 0.5, -75); KeyFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30); KeyFrame.Visible = true
local KeyInput = Instance.new("TextBox", KeyFrame); KeyInput.Size = UDim2.new(0.8, 0, 0, 40); KeyInput.Position = UDim2.new(0.1, 0, 0.15, 0); KeyInput.PlaceholderText = "Key..."; KeyInput.Text = ""
local SubmitBtn = Instance.new("TextButton", KeyFrame); SubmitBtn.Size = UDim2.new(0.8, 0, 0, 40); SubmitBtn.Position = UDim2.new(0.1, 0, 0.55, 0); SubmitBtn.Text = "Submit"; SubmitBtn.BackgroundColor3 = Color3.fromRGB(0, 150, 0); SubmitBtn.TextColor3 = Color3.new(1,1,1)

local MainFrame = Instance.new("Frame", ScreenGui); MainFrame.Size = UDim2.new(0, 200, 0, 350); MainFrame.Position = UDim2.new(0.5, -100, 0.5, -175); MainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 20); MainFrame.Visible = false; MainFrame.Draggable = true
local MenuBtn = Instance.new("ImageButton", ScreenGui); MenuBtn.Size = UDim2.new(0, 60, 0, 60); MenuBtn.Position = UDim2.new(0, 20, 0, 20); MenuBtn.BackgroundColor3 = Color3.fromRGB(255, 0, 0); MenuBtn.Draggable = true; Instance.new("UICorner", MenuBtn).CornerRadius = UDim.new(1, 0); MenuBtn.Visible = false

local MySecretKey = "key-511"
SubmitBtn.MouseButton1Click:Connect(function()
    if KeyInput.Text == MySecretKey then KeyFrame.Visible = false; MainFrame.Visible = true; MenuBtn.Visible = true
    else SubmitBtn.Text = "Wrong Key!"; task.wait(1); SubmitBtn.Text = "Submit" end
end)
MenuBtn.MouseButton1Click:Connect(function() MainFrame.Visible = not MainFrame.Visible end)

--// Settings
getgenv().Settings = { Silent = false, Tracer = false, FovCircle = false, FovRadius = 150, Prediction = 0.16 }

local function CreateBtn(name, setting)
    local btn = Instance.new("TextButton", MainFrame); btn.Size = UDim2.new(1, 0, 0, 40); btn.Position = UDim2.new(0, 0, 0, #MainFrame:GetChildren() * 45 - 45)
    btn.Text = name .. ": OFF"; btn.BackgroundColor3 = Color3.fromRGB(40, 40, 40); btn.TextColor3 = Color3.new(1,1,1)
    btn.MouseButton1Click:Connect(function()
        getgenv().Settings[setting] = not getgenv().Settings[setting]
        btn.Text = name .. ": " .. (getgenv().Settings[setting] and "ON" or "OFF")
    end)
end
CreateBtn("Silent", "Silent"); CreateBtn("Tracer", "Tracer"); CreateBtn("FOV Circle", "FovCircle")

local FovBtn = Instance.new("TextButton", MainFrame); FovBtn.Size = UDim2.new(1, 0, 0, 40); FovBtn.Position = UDim2.new(0, 0, 0, 135); FovBtn.Text = "FOV Size: 150"; FovBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
FovBtn.MouseButton1Click:Connect(function()
    getgenv().Settings.FovRadius = getgenv().Settings.FovRadius + 50
    if getgenv().Settings.FovRadius > 500 then getgenv().Settings.FovRadius = 50 end
    FovBtn.Text = "FOV Size: " .. getgenv().Settings.FovRadius
end)

--// Optimized Engine with KillCheck
local function GetValidTarget()
    local Target, MinDist = nil, getgenv().Settings.FovRadius
    local Center = Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y/2)
    for _, v in pairs(Players:GetPlayers()) do
        if v ~= LocalPlayer and v.Character and v.Character:FindFirstChild("HumanoidRootPart") and v.Character:FindFirstChild("Humanoid") and v.Character.Humanoid.Health > 0 then
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
        local Target = GetValidTarget()
        if Target then
            Args[1] = Target.Position + (Target.Velocity * getgenv().Settings.Prediction)
            return self.FireServer(self, unpack(Args))
        end
    end
    return Hook(self, ...)
end)

local FOVCircle = Drawing.new("Circle"); FOVCircle.Filled = false; FOVCircle.Thickness = 2
local TracerLine = Drawing.new("Line"); TracerLine.Thickness = 1

RunService.RenderStepped:Connect(function()
    FOVCircle.Position = Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y/2)
    FOVCircle.Radius = getgenv().Settings.FovRadius
    FOVCircle.Visible = getgenv().Settings.FovCircle
    
    local Target = GetValidTarget()
    if getgenv().Settings.Tracer and Target then
        TracerLine.Visible = true
        TracerLine.From = Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y/2)
        local Pos = Camera:WorldToViewportPoint(Target.Position)
        TracerLine.To = Vector2.new(Pos.X, Pos.Y)
    else TracerLine.Visible = false end
end)
