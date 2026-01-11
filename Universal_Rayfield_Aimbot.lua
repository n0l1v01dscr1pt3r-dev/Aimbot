
-- =========================================================
-- UNIVERSAL RAYFIELD AIMBOT (PLAYERS + NPCs)
-- Prediction Modes + FOV + Smooth Aim
-- =========================================================

local Rayfield = loadstring(game:HttpGetAsync("https://sirius.menu/rayfield"))()

local Window = Rayfield:CreateWindow({
    Name = "Universal Aimbot Hub",
    LoadingTitle = "Aimbot Hub",
    LoadingSubtitle = "Combined Script",
    ConfigurationSaving = { Enabled = false }
})

local PlayerTab = Window:CreateTab("Players", 4483362458)
local NPCTab = Window:CreateTab("NPCs", 4483362458)

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Camera = workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer

local FOVCircle = Drawing.new("Circle")
FOVCircle.NumSides = 64
FOVCircle.Thickness = 2
FOVCircle.Visible = false

local Config = {
    PlayerEnabled = false,
    NPCEnabled = false,
    Prediction = "Normal",
    LockPart = "Head",
    FOV = 150,
    Smoothness = 6,
    ShowFOV = true
}

PlayerTab:CreateToggle({
    Name = "Enable Player Aimbot",
    Callback = function(v) Config.PlayerEnabled = v end
})

NPCTab:CreateToggle({
    Name = "Enable NPC Aimbot",
    Callback = function(v) Config.NPCEnabled = v end
})

PlayerTab:CreateDropdown({
    Name = "Prediction Mode",
    Options = {"Normal","Velocity","Facing","Auto"},
    Callback = function(v) Config.Prediction = v[1] end
})

PlayerTab:CreateDropdown({
    Name = "Target Body Part",
    Options = {"Head","HumanoidRootPart","UpperTorso","LowerTorso"},
    Callback = function(v) Config.LockPart = v[1] end
})

PlayerTab:CreateSlider({
    Name = "FOV",
    Range = {50,600},
    CurrentValue = 150,
    Callback = function(v) Config.FOV = v end
})

PlayerTab:CreateSlider({
    Name = "Smoothness",
    Range = {1,20},
    CurrentValue = 6,
    Callback = function(v) Config.Smoothness = v end
})

PlayerTab:CreateToggle({
    Name = "Show FOV Circle",
    CurrentValue = true,
    Callback = function(v) Config.ShowFOV = v end
})

local function isAlive(model)
    local hum = model:FindFirstChildOfClass("Humanoid")
    return hum and hum.Health > 0
end

local function predictPosition(part)
    if Config.Prediction == "Velocity" and part.AssemblyLinearVelocity then
        return part.Position + part.AssemblyLinearVelocity * 0.12
    elseif Config.Prediction == "Facing" then
        return part.Position + part.CFrame.LookVector * 2
    elseif Config.Prediction == "Auto" and part.AssemblyLinearVelocity then
        return part.Position + part.AssemblyLinearVelocity * 0.1
    end
    return part.Position
end

local function worldToScreen(pos)
    local s, onScreen = Camera:WorldToViewportPoint(pos)
    return Vector2.new(s.X, s.Y), onScreen
end

local function getClosestTarget(isNPC)
    local best, bestDist = nil, math.huge
    local center = Camera.ViewportSize / 2

    if isNPC then
        for _, m in ipairs(workspace:GetDescendants()) do
            if m:IsA("Model") and m ~= LocalPlayer.Character and isAlive(m) then
                local part = m:FindFirstChild(Config.LockPart)
                if part then
                    local screen, vis = worldToScreen(predictPosition(part))
                    if vis then
                        local dist = (screen - center).Magnitude
                        if dist < Config.FOV and dist < bestDist then
                            best, bestDist = part, dist
                        end
                    end
                end
            end
        end
    else
        for _, plr in ipairs(Players:GetPlayers()) do
            if plr ~= LocalPlayer and plr.Character and isAlive(plr.Character) then
                local part = plr.Character:FindFirstChild(Config.LockPart)
                if part then
                    local screen, vis = worldToScreen(predictPosition(part))
                    if vis then
                        local dist = (screen - center).Magnitude
                        if dist < Config.FOV and dist < bestDist then
                            best, bestDist = part, dist
                        end
                    end
                end
            end
        end
    end
    return best
end

RunService.RenderStepped:Connect(function()
    if Config.ShowFOV then
        FOVCircle.Visible = true
        FOVCircle.Position = Camera.ViewportSize / 2
        FOVCircle.Radius = Config.FOV
    else
        FOVCircle.Visible = false
    end

    local target
    if Config.PlayerEnabled then
        target = getClosestTarget(false)
    elseif Config.NPCEnabled then
        target = getClosestTarget(true)
    end

    if target then
        local camPos = Camera.CFrame.Position
        Camera.CFrame = Camera.CFrame:Lerp(
            CFrame.new(camPos, predictPosition(target)),
            math.clamp(1 / Config.Smoothness, 0.01, 1)
        )
    end
end)

print("Universal Rayfield Aimbot Loaded")
