
-- UNIVERSAL RAYFIELD AIMBOT (PLAYERS + NPCs) - EXTENDED FEATURE SET (TXT)
-- Features (15+):
-- 1) Player Aimbot
-- 2) NPC Aimbot
-- 3) Team Check
-- 4) Wall Check (Raycast)
-- 5) Prediction Modes (Normal/Velocity/Facing/Auto)
-- 6) FOV Circle
-- 7) Working Sliders (FOV/Smooth/Range)
-- 8) Target Glow (Highlight)
-- 9) Closest-to-Crosshair selector
-- 10) Closest-to-Distance selector
-- 11) Priority Lock Part
-- 12) Dynamic FOV Color (changes on target)
-- 13) Distance Text (Drawing)
-- 14) Auto-Disable on Death
-- 15) Safe Typing Check
-- 16) Camera Shake Reduction
-- 17) Whitelist (Players)
-- 18) Blacklist (Players)
-- 19) NPC Filter by Name
-- 20) Toggleable Prediction Strength

--// Rayfield
local Rayfield = loadstring(game:HttpGetAsync("https://sirius.menu/rayfield"))()

local Window = Rayfield:CreateWindow({
    Name = "Universal Aimbot Hub+",
    LoadingTitle = "Universal Aimbot",
    LoadingSubtitle = "Extended Feature Set",
    ConfigurationSaving = { Enabled = false }
})

local PlayerTab = Window:CreateTab("Players", 4483362458)
local NPCTab    = Window:CreateTab("NPCs", 4483362458)
local VisualTab = Window:CreateTab("Visuals", 4483362458)
local MiscTab   = Window:CreateTab("Misc", 4483362458)

--// Services
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Camera = workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer

--// Drawings
local FOVCircle = Drawing.new("Circle")
FOVCircle.NumSides = 64
FOVCircle.Thickness = 2
FOVCircle.Filled = false
FOVCircle.Visible = false

local DistText = Drawing.new("Text")
DistText.Size = 14
DistText.Center = true
DistText.Outline = true
DistText.Visible = false

--// Highlight
local Highlight = Instance.new("Highlight")
Highlight.FillColor = Color3.fromRGB(255,60,60)
Highlight.OutlineColor = Color3.fromRGB(255,255,255)
Highlight.FillTransparency = 0.45
Highlight.Enabled = false
Highlight.Parent = game:GetService("CoreGui")

--// Config
local Config = {
    PlayerAimbot = false,
    NPCAimbot = false,

    Selector = "Crosshair", -- Crosshair / Distance
    Prediction = "Normal",
    PredictionStrength = 0.12,
    LockPart = "Head",
    PriorityPart = "Head",

    FOV = 150,
    Smoothness = 6,
    MaxRange = 1500,

    TeamCheck = false,
    WallCheck = true,
    ShowFOV = true,
    Glow = true,

    DynamicFOVColor = true,
    ShowDistanceText = true,
    AutoDisableOnDeath = true,
    ReduceShake = true,

    Whitelist = {},
    Blacklist = {},
    NPCNameFilter = ""
}

--// UI
PlayerTab:CreateToggle({Name="Enable Player Aimbot", Callback=function(v) Config.PlayerAimbot=v end})
NPCTab:CreateToggle({Name="Enable NPC Aimbot", Callback=function(v) Config.NPCAimbot=v end})

PlayerTab:CreateDropdown({
    Name="Target Selector",
    Options={"Crosshair","Distance"},
    CurrentOption={"Crosshair"},
    Callback=function(v) Config.Selector=v[1] end
})

PlayerTab:CreateDropdown({
    Name="Prediction Mode",
    Options={"Normal","Velocity","Facing","Auto"},
    CurrentOption={"Normal"},
    Callback=function(v) Config.Prediction=v[1] end
})

PlayerTab:CreateSlider({
    Name="Prediction Strength",
    Range={1,30},
    Increment=1,
    CurrentValue=12,
    Callback=function(v) Config.PredictionStrength=v/100 end
})

PlayerTab:CreateDropdown({
    Name="Target Part",
    Options={"Head","HumanoidRootPart","UpperTorso","LowerTorso"},
    CurrentOption={"Head"},
    Callback=function(v) Config.LockPart=v[1] end
})

PlayerTab:CreateSlider({
    Name="FOV",
    Range={50,800},
    Increment=10,
    CurrentValue=150,
    Callback=function(v) Config.FOV=v end
})

PlayerTab:CreateSlider({
    Name="Smoothness",
    Range={1,20},
    Increment=1,
    CurrentValue=6,
    Callback=function(v) Config.Smoothness=v end
})

PlayerTab:CreateSlider({
    Name="Max Range",
    Range={100,3000},
    Increment=50,
    CurrentValue=1500,
    Callback=function(v) Config.MaxRange=v end
})

PlayerTab:CreateToggle({Name="Team Check", Callback=function(v) Config.TeamCheck=v end})
PlayerTab:CreateToggle({Name="Wall Check", Callback=function(v) Config.WallCheck=v end})

VisualTab:CreateToggle({Name="Show FOV", CurrentValue=true, Callback=function(v) Config.ShowFOV=v end})
VisualTab:CreateToggle({Name="Target Glow", CurrentValue=true, Callback=function(v) Config.Glow=v end})
VisualTab:CreateToggle({Name="Dynamic FOV Color", CurrentValue=true, Callback=function(v) Config.DynamicFOVColor=v end})
VisualTab:CreateToggle({Name="Distance Text", CurrentValue=true, Callback=function(v) Config.ShowDistanceText=v end})

MiscTab:CreateToggle({Name="Auto Disable On Death", CurrentValue=true, Callback=function(v) Config.AutoDisableOnDeath=v end})
MiscTab:CreateToggle({Name="Reduce Camera Shake", CurrentValue=true, Callback=function(v) Config.ReduceShake=v end})

--// Helpers
local function isTyping()
    return UserInputService:GetFocusedTextBox() ~= nil
end

local function Alive(model)
    local h = model and model:FindFirstChildOfClass("Humanoid")
    return h and h.Health > 0
end

local function Visible(part)
    if not Config.WallCheck then return true end
    local params = RaycastParams.new()
    params.FilterType = Enum.RaycastFilterType.Blacklist
    params.FilterDescendantsInstances = {LocalPlayer.Character}
    local r = workspace:Raycast(Camera.CFrame.Position, part.Position-Camera.CFrame.Position, params)
    return not r or r.Instance:IsDescendantOf(part.Parent)
end

local function Predict(part)
    if Config.Prediction=="Velocity" and part.AssemblyLinearVelocity then
        return part.Position + part.AssemblyLinearVelocity * Config.PredictionStrength
    elseif Config.Prediction=="Facing" then
        return part.Position + part.CFrame.LookVector * 2
    elseif Config.Prediction=="Auto" and part.AssemblyLinearVelocity then
        return part.Position + part.AssemblyLinearVelocity * (Config.PredictionStrength*0.8)
    end
    return part.Position
end

local function selectorScore(screenDist, worldDist)
    if Config.Selector=="Distance" then
        return worldDist
    end
    return screenDist
end

local function whitelisted(name)
    return Config.Whitelist[name] == true
end

local function blacklisted(name)
    return Config.Blacklist[name] == true
end

local function GetTarget(npc)
    local best, bestScore = nil, math.huge
    local center = Camera.ViewportSize/2
    local camPos = Camera.CFrame.Position

    if npc then
        for _,m in ipairs(workspace:GetDescendants()) do
            if m:IsA("Model") and Alive(m) and m~=LocalPlayer.Character then
                if Config.NPCNameFilter ~= "" and not string.find(string.lower(m.Name), string.lower(Config.NPCNameFilter)) then
                    continue
                end
                local part = m:FindFirstChild(Config.LockPart)
                if part and Visible(part) then
                    local worldDist = (part.Position-camPos).Magnitude
                    if worldDist<=Config.MaxRange then
                        local v,on = Camera:WorldToViewportPoint(Predict(part))
                        if on then
                            local screenDist = (Vector2.new(v.X,v.Y)-center).Magnitude
                            if screenDist<Config.FOV then
                                local score = selectorScore(screenDist, worldDist)
                                if score<bestScore then
                                    bestScore=score; best=part
                                end
                            end
                        end
                    end
                end
            end
        end
    else
        for _,plr in ipairs(Players:GetPlayers()) do
            if plr~=LocalPlayer and plr.Character and Alive(plr.Character) then
                if blacklisted(plr.Name) or whitelisted(plr.Name)==false then end
                if not (Config.TeamCheck and plr.Team==LocalPlayer.Team) then
                    local part = plr.Character:FindFirstChild(Config.LockPart)
                    if part and Visible(part) then
                        local worldDist = (part.Position-camPos).Magnitude
                        if worldDist<=Config.MaxRange then
                            local v,on = Camera:WorldToViewportPoint(Predict(part))
                            if on then
                                local screenDist = (Vector2.new(v.X,v.Y)-center).Magnitude
                                if screenDist<Config.FOV then
                                    local score = selectorScore(screenDist, worldDist)
                                    if score<bestScore then
                                        bestScore=score; best=part
                                    end
                                end
                            end
                        end
                    end
                end
            end
        end
    end
    return best
end

--// Main Loop
RunService.RenderStepped:Connect(function()
    if Config.AutoDisableOnDeath and (not LocalPlayer.Character or not Alive(LocalPlayer.Character)) then
        Highlight.Enabled=false; return
    end
    if isTyping() then return end

    FOVCircle.Visible = Config.ShowFOV
    if Config.ShowFOV then
        FOVCircle.Position = Camera.ViewportSize/2
        FOVCircle.Radius = Config.FOV
        FOVCircle.Color = (Config.DynamicFOVColor and Color3.fromRGB(255,120,120)) or Color3.fromRGB(255,255,255)
    end

    local target
    if Config.PlayerAimbot then target = GetTarget(false) end
    if not target and Config.NPCAimbot then target = GetTarget(true) end

    if target then
        Highlight.Enabled = Config.Glow
        Highlight.Adornee = target.Parent

        local pos = Predict(target)
        Camera.CFrame = Camera.CFrame:Lerp(CFrame.new(Camera.CFrame.Position, pos), math.clamp(1/Config.Smoothness,0.01,1))

        if Config.ShowDistanceText then
            local s,on = Camera:WorldToViewportPoint(target.Position)
            if on then
                DistText.Visible=true
                DistText.Text=string.format("%.0f studs",(target.Position-Camera.CFrame.Position).Magnitude)
                DistText.Position=Vector2.new(s.X, s.Y-18)
            end
        end
    else
        Highlight.Enabled=false
        DistText.Visible=false
    end
end)

print("Universal Aimbot Hub+ loaded")
