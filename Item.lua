-- Rayfield UI - Touch Interest, Proximity Prompt, Click Detector
-- Load Rayfield Library
local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

-- Create Window
local Window = Rayfield:CreateWindow({
   Name = "Trigger Manager",
   LoadingTitle = "Loading Triggers...",
   LoadingSubtitle = "by Assistant",
   ConfigurationSaving = {
      Enabled = false,
      FolderName = nil,
      FileName = "TriggerConfig"
   },
   Discord = {
      Enabled = false,
      Invite = "noinvitelink",
      RememberJoins = true
   },
   KeySystem = false
})

-- Variables to store selections
local selectedTouch = nil
local selectedProximity = nil
local selectedClick = nil

-- Helper function to get all instances of a class
local function getAllOfClass(className)
    local instances = {}
    for _, obj in pairs(game:GetDescendants()) do
        if obj:IsA(className) then
            local parent = obj.Parent
            local displayName = parent and parent.Name .. " > " .. obj.Name or obj.Name
            table.insert(instances, {
                name = displayName,
                object = obj
            })
        end
    end
    return instances
end

-- TAB 1: TOUCH INTEREST
local Tab1 = Window:CreateTab("Touch Interest", 4483362458)
local Section1 = Tab1:CreateSection("Touch Interest Manager")

local touchList = getAllOfClass("TouchTransmitter")
local touchNames = {}
local touchObjects = {}

for i, data in ipairs(touchList) do
    table.insert(touchNames, data.name)
    touchObjects[data.name] = data.object
end

if #touchNames == 0 then
    table.insert(touchNames, "No Touch Interests Found")
end

local TouchDropdown = Tab1:CreateDropdown({
   Name = "Select Touch Interest",
   Options = touchNames,
   CurrentOption = touchNames[1] or "None",
   Flag = "TouchDropdown",
   Callback = function(Option)
      selectedTouch = touchObjects[Option]
      Rayfield:Notify({
         Title = "Touch Selected",
         Content = Option,
         Duration = 2,
         Image = 4483362458
      })
   end
})

local TouchButton = Tab1:CreateButton({
   Name = "Fire Touch Interest",
   Callback = function()
      if selectedTouch and selectedTouch.Parent then
         local part = selectedTouch.Parent
         firetouchinterest(game.Players.LocalPlayer.Character.HumanoidRootPart, part, 0)
         wait()
         firetouchinterest(game.Players.LocalPlayer.Character.HumanoidRootPart, part, 1)
         Rayfield:Notify({
            Title = "Touch Fired!",
            Content = "Triggered: " .. part.Name,
            Duration = 2,
            Image = 4483362458
         })
      else
         Rayfield:Notify({
            Title = "Error",
            Content = "No valid Touch Interest selected",
            Duration = 2,
            Image = 4483362458
         })
      end
   end
})

Tab1:CreateButton({
   Name = "Refresh Touch List",
   Callback = function()
      touchList = getAllOfClass("TouchTransmitter")
      touchNames = {}
      touchObjects = {}
      for i, data in ipairs(touchList) do
         table.insert(touchNames, data.name)
         touchObjects[data.name] = data.object
      end
      TouchDropdown:Refresh(touchNames, true)
      Rayfield:Notify({
         Title = "Refreshed",
         Content = "Found " .. #touchNames .. " Touch Interests",
         Duration = 2,
         Image = 4483362458
      })
   end
})

-- TAB 2: PROXIMITY PROMPT
local Tab2 = Window:CreateTab("Proximity Prompt", 4483362458)
local Section2 = Tab2:CreateSection("Proximity Prompt Manager")

local proximityList = getAllOfClass("ProximityPrompt")
local proximityNames = {}
local proximityObjects = {}

for i, data in ipairs(proximityList) do
    table.insert(proximityNames, data.name)
    proximityObjects[data.name] = data.object
end

if #proximityNames == 0 then
    table.insert(proximityNames, "No Proximity Prompts Found")
end

local ProximityDropdown = Tab2:CreateDropdown({
   Name = "Select Proximity Prompt",
   Options = proximityNames,
   CurrentOption = proximityNames[1] or "None",
   Flag = "ProximityDropdown",
   Callback = function(Option)
      selectedProximity = proximityObjects[Option]
      Rayfield:Notify({
         Title = "Proximity Selected",
         Content = Option,
         Duration = 2,
         Image = 4483362458
      })
   end
})

local ProximityButton = Tab2:CreateButton({
   Name = "Fire Proximity Prompt",
   Callback = function()
      if selectedProximity then
         fireproximityprompt(selectedProximity)
         Rayfield:Notify({
            Title = "Proximity Fired!",
            Content = "Triggered: " .. selectedProximity.Name,
            Duration = 2,
            Image = 4483362458
         })
      else
         Rayfield:Notify({
            Title = "Error",
            Content = "No valid Proximity Prompt selected",
            Duration = 2,
            Image = 4483362458
         })
      end
   end
})

Tab2:CreateButton({
   Name = "Refresh Proximity List",
   Callback = function()
      proximityList = getAllOfClass("ProximityPrompt")
      proximityNames = {}
      proximityObjects = {}
      for i, data in ipairs(proximityList) do
         table.insert(proximityNames, data.name)
         proximityObjects[data.name] = data.object
      end
      ProximityDropdown:Refresh(proximityNames, true)
      Rayfield:Notify({
         Title = "Refreshed",
         Content = "Found " .. #proximityNames .. " Proximity Prompts",
         Duration = 2,
         Image = 4483362458
      })
   end
})

-- TAB 3: CLICK DETECTOR
local Tab3 = Window:CreateTab("Click Detector", 4483362458)
local Section3 = Tab3:CreateSection("Click Detector Manager")

local clickList = getAllOfClass("ClickDetector")
local clickNames = {}
local clickObjects = {}

for i, data in ipairs(clickList) do
    table.insert(clickNames, data.name)
    clickObjects[data.name] = data.object
end

if #clickNames == 0 then
    table.insert(clickNames, "No Click Detectors Found")
end

local ClickDropdown = Tab3:CreateDropdown({
   Name = "Select Click Detector",
   Options = clickNames,
   CurrentOption = clickNames[1] or "None",
   Flag = "ClickDropdown",
   Callback = function(Option)
      selectedClick = clickObjects[Option]
      Rayfield:Notify({
         Title = "Click Detector Selected",
         Content = Option,
         Duration = 2,
         Image = 4483362458
      })
   end
})

local ClickButton = Tab3:CreateButton({
   Name = "Fire Click Detector",
   Callback = function()
      if selectedClick then
         fireclickdetector(selectedClick)
         Rayfield:Notify({
            Title = "Click Detector Fired!",
            Content = "Triggered: " .. selectedClick.Name,
            Duration = 2,
            Image = 4483362458
         })
      else
         Rayfield:Notify({
            Title = "Error",
            Content = "No valid Click Detector selected",
            Duration = 2,
            Image = 4483362458
         })
      end
   end
})

Tab3:CreateButton({
   Name = "Refresh Click List",
   Callback = function()
      clickList = getAllOfClass("ClickDetector")
      clickNames = {}
      clickObjects = {}
      for i, data in ipairs(clickList) do
         table.insert(clickNames, data.name)
         clickObjects[data.name] = data.object
      end
      ClickDropdown:Refresh(clickNames, true)
      Rayfield:Notify({
         Title = "Refreshed",
         Content = "Found " .. #clickNames .. " Click Detectors",
         Duration = 2,
         Image = 4483362458
      })
   end
})

-- Notify user that script loaded
Rayfield:Notify({
   Title = "Script Loaded",
   Content = "Trigger Manager Ready!",
   Duration = 3,
   Image = 4483362458
})

print("Trigger Manager loaded successfully!")
