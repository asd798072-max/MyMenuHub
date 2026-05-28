--// BlockSpin Pro - Final Secured Edition
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

--// 1. UI Key System
local ScreenGui = Instance.new("ScreenGui", CoreGui)
local KeyFrame = Instance.new("Frame", ScreenGui); KeyFrame.Size = UDim2.new(0, 250, 0, 150); KeyFrame.Position = UDim2.new(0.5, -125, 0.5, -75); KeyFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
local KeyInput = Instance.new("TextBox", KeyFrame); KeyInput.Size = UDim2.new(0.8, 0, 0, 40); KeyInput.Position = UDim2.new(0.1, 0, 0.15, 0); KeyInput.PlaceholderText = "Enter Key..."; KeyInput.Text = ""
local SubmitBtn = Instance.new("TextButton", KeyFrame); SubmitBtn.Size = UDim2.new(0.8, 0, 0, 40); SubmitBtn.Position = UDim2.new(0.1, 0, 0.55, 0); SubmitBtn.Text = "Submit"; SubmitBtn.BackgroundColor3 = Color3.fromRGB(0, 150, 0); SubmitBtn.TextColor3 = Color3.new(1,1,1)

local MainFrame = Instance.new("Frame", ScreenGui); MainFrame.Size = UDim2.new(0, 200, 0, 250); MainFrame.Position = UDim2.new(0.5, -100, 0.5, -125); MainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 20); MainFrame.Visible = false; MainFrame.Draggable = true

--// Key Logic
SubmitBtn.MouseButton1Click:Connect(function()
    local Input = KeyInput.Text
    local success, response = pcall(function() return game:HttpGet("https://raw.githubusercontent.com/asd798072-max/key.txt/refs/heads/main/key.txt", true) end)
    
    if success and string.find(tostring(response), Input) and Input ~= "" then
        KeyFrame.Visible = false
        MainFrame.Visible = true
    else
        SubmitBtn.Text = "Wrong Key!"
        task.wait(1)
        SubmitBtn.Text = "Submit"
    end
end)

--// UI Functions
getgenv().Settings = { Silent = false, Tracer = false, FovCircle = false, FovRadius = 150, Prediction = 0.16 }

local function CreateBtn(name, setting)
    local btn = Instance.new("TextButton", MainFrame); btn.Size = UDim2.new(1, 0, 0, 40); btn.Position = UDim2.new(0, 0, 0, #MainFrame:GetChildren() * 45)
    btn.Text = name .. ": OFF"; btn.BackgroundColor3 = Color3.fromRGB(40, 40, 40); btn.TextColor3 = Color3.new(1,1,1)
    btn.MouseButton1Click:Connect(function()
        getgenv().Settings[setting] = not getgenv().Settings[setting]
        btn.Text = name .. ": " .. (getgenv().Settings[setting] and "ON" or "OFF")
    end)
end
CreateBtn("Silent", "Silent"); CreateBtn("Tracer", "Tracer"); CreateBtn("FOV Circle", "FovCircle")

--// Silent Aim Engine
local Hook; Hook = hookmetamethod(game, "__namecall", function(self, ...)
    local Args = {...}
    if getgenv().Settings.Silent and getnamecallmethod() == "FireServer" then
        local Target = nil
        local MinDist = 150
        for _, v in pairs(Players:GetPlayers()) do
            if v ~= LocalPlayer and v.Character and v.Character:FindFirstChild("HumanoidRootPart") then
                local Pos, OnScreen = Camera:WorldToViewportPoint(v.Character.HumanoidRootPart.Position)
                local Dist = (Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y/2) - Vector2.new(Pos.X, Pos.Y)).Magnitude
                if OnScreen and Dist < MinDist then MinDist = Dist; Target = v.Character.HumanoidRootPart end
            end
        end
        if Target then
            Args[1] = Target.Position + (Target.Velocity * getgenv().Settings.Prediction)
            return self.FireServer(self, unpack(Args))
        end
    end
    return Hook(self, ...)
end)
