-- Workspace Item Scanner & Collector Script (Delta Executor Compatible)
-- This script scans the workspace and gives all items to your character

local Players = game:GetService("Players")
local player = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local backpack = player:WaitForChild("Backpack")
local humanoidRootPart = character:WaitForChild("HumanoidRootPart")

local function giveItemsToPlayer()
    local itemsGiven = 0
    local toolsGiven = 0
    
    print("🔍 Starting to collect workspace items...")
    print("👤 Player: " .. player.Name)
    
    -- Collect all workspace items
    for _, obj in ipairs(game.Workspace:GetDescendants()) do
        -- Skip the player's own character and baseplate
        if not obj:IsDescendantOf(character) and obj.Name ~= "Baseplate" then
            local success = pcall(function()
                -- Handle Tools
                if obj:IsA("Tool") then
                    local clone = obj:Clone()
                    clone.Parent = backpack
                    toolsGiven = toolsGiven + 1
                    print("✓ Tool collected: " .. obj.Name)
                    obj:Destroy()
                    
                -- Handle Models (like gear, items, etc)
                elseif obj:IsA("Model") and obj.Parent == game.Workspace then
                    -- Check if it has a handle or primary part
                    if obj.PrimaryPart or obj:FindFirstChild("Handle") then
                        obj:MoveTo(humanoidRootPart.Position)
                        wait(0.1)
                        obj.Parent = character
                        itemsGiven = itemsGiven + 1
                        print("✓ Model collected: " .. obj.Name)
                    end
                    
                -- Handle loose parts that might be collectible items
                elseif obj:IsA("BasePart") and obj.Parent == game.Workspace and not obj.Locked then
                    if not obj.Anchored then
                        obj.CFrame = humanoidRootPart.CFrame
                        obj.Parent = character
                        itemsGiven = itemsGiven + 1
                        print("✓ Part collected: " .. obj.Name)
                    end
                end
            end)
        end
    end
    
    print("\n" .. string.rep("=", 40))
    print("✅ COLLECTION COMPLETE")
    print(string.rep("=", 40))
    print("🎒 Tools given: " .. toolsGiven)
    print("📦 Items given: " .. itemsGiven)
    print("📊 Total: " .. (toolsGiven + itemsGiven))
    print(string.rep("=", 40))
end

-- Execute
giveItemsToPlayer()
