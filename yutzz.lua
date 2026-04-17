local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

-- =============================================
-- CONFIG
-- =============================================
local Config = {
    Players = {
        Killer = {Color = Color3.fromRGB(255, 93, 108)},
        Survivor = {Color = Color3.fromRGB(64, 224, 255)}
    },
    Objects = {
        Generator = {Color = Color3.fromRGB(150, 0, 200)},
        Gate = {Color = Color3.fromRGB(255, 255, 255)},
        Pallet = {Color = Color3.fromRGB(74, 255, 181)},
        Window = {Color = Color3.fromRGB(74, 255, 181)},
        Hook = {Color = Color3.fromRGB(132, 255, 169)}
    }
}

local MaskNames = {
    ["Richard"] = "Rooster", ["Tony"] = "Tiger", ["Brandon"] = "Panther",
    ["Cobra"] = "Cobra", ["Richter"] = "Rat", ["Rabbit"] = "Rabbit", ["Alex"] = "Chainsaw"
}

local MaskColors = {
    ["Richard"] = Color3.fromRGB(255, 0, 0), ["Tony"] = Color3.fromRGB(255, 255, 0),
    ["Brandon"] = Color3.fromRGB(160, 32, 240), ["Cobra"] = Color3.fromRGB(0, 255, 0),
    ["Richter"] = Color3.fromRGB(0, 0, 0), ["Rabbit"] = Color3.fromRGB(255, 105, 180),
    ["Alex"] = Color3.fromRGB(255, 255, 255)
}

-- =============================================
-- SERVICES
-- =============================================
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local VirtualInputManager = game:GetService("VirtualInputManager")
local GuiService = game:GetService("GuiService")
local Lighting = game:GetService("Lighting")

local LocalPlayer = Players.LocalPlayer
local player = LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

-- =============================================
-- VARIABLES
-- =============================================
local ESPEnabled = true
local speedHackEnabled = false
local desiredSpeed = 16
local speedConnections = {}
local IndicatorGui = nil
local LastUpdateTick = 0
local ActiveGenerators = {}

-- =============================================
-- SPEED HACK
-- =============================================
local function applySpeed(humanoid)
    if humanoid and speedHackEnabled then
        humanoid.WalkSpeed = desiredSpeed
    end
end

local function setupSpeedEnforcement(humanoid)
    for _, conn in ipairs(speedConnections) do
        conn:Disconnect()
    end
    speedConnections = {}

    if humanoid then
        applySpeed(humanoid)
        table.insert(speedConnections, humanoid:GetPropertyChangedSignal("WalkSpeed"):Connect(function()
            if speedHackEnabled and humanoid.WalkSpeed ~= desiredSpeed then
                humanoid.WalkSpeed = desiredSpeed
            end
        end))
        table.insert(speedConnections, RunService.Heartbeat:Connect(function()
            if speedHackEnabled and humanoid.WalkSpeed ~= desiredSpeed then
                humanoid.WalkSpeed = desiredSpeed
            end
        end))
    end
end

player.CharacterAdded:Connect(function(character)
    local humanoid = character:WaitForChild("Humanoid", 10)
    if humanoid and speedHackEnabled then
        setupSpeedEnforcement(humanoid)
    end
end)

if player.Character then
    local humanoid = player.Character:FindFirstChildOfClass("Humanoid")
    if humanoid and speedHackEnabled then
        setupSpeedEnforcement(humanoid)
    end
end

-- =============================================
-- CORE ESP FUNCTIONS
-- =============================================
local function SetupGui()
    if PlayerGui:FindFirstChild("ChasedInds") then
        PlayerGui:FindFirstChild("ChasedInds"):Destroy()
    end
    IndicatorGui = Instance.new("ScreenGui")
    IndicatorGui.Name = "ChasedInds"
    IndicatorGui.IgnoreGuiInset = true
    IndicatorGui.DisplayOrder = 999
    IndicatorGui.ResetOnSpawn = false
    IndicatorGui.Parent = PlayerGui
end

local function GetGameValue(obj, name)
    if not obj then return nil end
    local attr = obj:GetAttribute(name)
    if attr ~= nil then return attr end
    local child = obj:FindFirstChild(name)
    if child then
        local success, val = pcall(function() return child.Value end)
        if success then return val end
    end
    return nil
end

local function ApplyHighlight(object, color)
    if not object or not object.Parent then return end
    local h = object:FindFirstChild("H") or Instance.new("Highlight")
    h.Name = "H"
    h.Adornee = object
    h.FillColor = color
    h.OutlineColor = color
    h.FillTransparency = 0.8
    h.OutlineTransparency = 0.3
    h.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
    h.Parent = object
end

local function RemoveHighlight(object)
    if not object then return end
    local h = object:FindFirstChild("H")
    if h then h:Destroy() end
end

local function CreateBillboardTag(text, color, size, textSize)
    local billboard = Instance.new("BillboardGui")
    billboard.Name = "BitchHook"
    billboard.AlwaysOnTop = true
    billboard.Size = size or UDim2.new(0, 120, 0, 30)
    local label = Instance.new("TextLabel")
    label.Name = "BitchHook"
    label.Size = UDim2.new(1, 0, 1, 0)
    label.BackgroundTransparency = 1
    label.Text = text
    label.TextColor3 = color
    label.TextStrokeTransparency = 0
    label.TextStrokeColor3 = Color3.new(0, 0, 0)
    label.Font = Enum.Font.GothamBold
    label.TextSize = textSize or 10
    label.TextWrapped = true
    label.RichText = true
    label.Parent = billboard
    return billboard
end

local function updatePlayerNametag(player)
    if not ESPEnabled then return end
    if not IndicatorGui or not IndicatorGui.Parent then return end
    if not player.Character then
        local m = IndicatorGui:FindFirstChild(player.Name)
        if m then m:Destroy() end
        return
    end

    local rootPart = player.Character:FindFirstChild("HumanoidRootPart")
    local humanoid = player.Character:FindFirstChildOfClass("Humanoid")
    if not rootPart then return end

    local teamName = (player.Team and player.Team.Name:lower()) or ""
    local selectedKillerAttr = GetGameValue(player, "SelectedKiller")
    local rawMask = GetGameValue(player, "Mask") or GetGameValue(player.Character, "Mask")
    local isKnocked = GetGameValue(player.Character, "Knocked")
    local isHooked = GetGameValue(player.Character, "IsHooked")
    local isChased = GetGameValue(player.Character, "IsChased")

    local isKiller = teamName:find("killer") ~= nil
    local color = isKiller and Config.Players.Killer.Color or Config.Players.Survivor.Color

    if isHooked then
        color = Color3.fromRGB(255, 182, 193)
    elseif humanoid and humanoid.Health < humanoid.MaxHealth then
        color = isKnocked and Color3.fromRGB(200, 100, 0) or Color3.fromRGB(200, 200, 0)
    end

    local distance = 0
    if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
        distance = math.floor((rootPart.Position - LocalPlayer.Character.HumanoidRootPart.Position).Magnitude)
    end

    local baseName = (isKiller and selectedKillerAttr and tostring(selectedKillerAttr) ~= "") and tostring(selectedKillerAttr) or player.Name
    local billboard = rootPart:FindFirstChild("BitchHook")
    local nameText = baseName .. "\n[" .. distance .. " studs]"

    if not billboard then
        billboard = CreateBillboardTag(nameText, color)
        billboard.Adornee = rootPart
        billboard.Parent = rootPart
    else
        local lbl = billboard:FindFirstChild("BitchHook") or billboard:FindFirstChildOfClass("TextLabel")
        if lbl then
            lbl.Text = nameText
            lbl.TextColor3 = color
        end
    end

    ApplyHighlight(player.Character, color)

    -- Mask Display
    local hasMask = false
    if isKiller and string.match(tostring(selectedKillerAttr):lower(), "masked") and rawMask then
        local searchMask = tostring(rawMask):lower()
        for key, name in pairs(MaskNames) do
            if key:lower() == searchMask then
                hasMask = true
                local maskBillboard = rootPart:FindFirstChild("MaskHook")
                if not maskBillboard then
                    maskBillboard = CreateBillboardTag(name, MaskColors[key] or Color3.new(1,1,1), UDim2.new(0, 100, 0, 20), 12)
                    maskBillboard.Name = "MaskHook"
                    maskBillboard.StudsOffset = Vector3.new(0, 3, 0)
                    maskBillboard.Adornee = rootPart
                    maskBillboard.Parent = rootPart
                else
                    local lbl = maskBillboard:FindFirstChild("BitchHook") or maskBillboard:FindFirstChildOfClass("TextLabel")
                    if lbl then
                        lbl.Text = name
                        lbl.TextColor3 = MaskColors[key] or Color3.new(1,1,1)
                    end
                end
                break
            end
        end
    end
    if not hasMask then
        local maskBillboard = rootPart:FindFirstChild("MaskHook")
        if maskBillboard then maskBillboard:Destroy() end
    end
end

local function updateGeneratorProgress(generator)
    if not ESPEnabled then return false end
    if not generator or not generator.Parent then return true end
    local percent = GetGameValue(generator, "RepairProgress") or GetGameValue(generator, "Progress") or 0

    local billboard = generator:FindFirstChild("GenBitchHook")
    if percent >= 100 then
        if billboard then billboard:Destroy() end
        local h = generator:FindFirstChild("H")
        if h then h:Destroy() end
        return true
    end

    local cp = math.clamp(percent, 0, 100)
    local finalColor = cp < 50
        and Config.Objects.Generator.Color:Lerp(Color3.fromRGB(180, 180, 0), cp / 50)
        or Color3.fromRGB(180, 180, 0):Lerp(Color3.fromRGB(0, 150, 0), (cp - 50) / 50)
    local percentStr = string.format("[%.2f%%]", percent)

    if not billboard then
        billboard = CreateBillboardTag(percentStr, finalColor)
        billboard.Name = "GenBitchHook"
        billboard.StudsOffset = Vector3.new(0, 2, 0)
        billboard.Adornee = generator:FindFirstChild("defaultMaterial", true) or generator
        billboard.Parent = generator
    else
        local lbl = billboard:FindFirstChild("BitchHook") or billboard:FindFirstChildOfClass("TextLabel")
        if lbl then
            lbl.Text = percentStr
            lbl.TextColor3 = finalColor
        end
    end
    return false
end

local function RefreshESP()
    if not ESPEnabled then return end
    ActiveGenerators = {}
    
    for _, obj in ipairs(workspace:GetDescendants()) do
        if obj.Name == "Window" then
            ApplyHighlight(obj, Config.Objects.Window.Color)
        end
    end
    
    local Map = workspace:FindFirstChild("Map")
    if not Map then return end
    
    for _, obj in ipairs(Map:GetDescendants()) do
        if obj.Name == "Generator" then
            ApplyHighlight(obj, Config.Objects.Generator.Color)
            table.insert(ActiveGenerators, obj)
        elseif obj.Name == "Hook" then
            local m = obj:FindFirstChild("Model")
            if m then
                for _, p in ipairs(m:GetDescendants()) do
                    if p:IsA("MeshPart") then ApplyHighlight(p, Config.Objects.Hook.Color) end
                end
            end
        elseif (obj.Name == "Palletwrong" or obj.Name == "Pallet") then
            ApplyHighlight(obj, Config.Objects.Pallet.Color)
        elseif obj.Name == "Gate" then
            ApplyHighlight(obj, Config.Objects.Gate.Color)
        end
    end
end

local function ClearAllESP()
    if IndicatorGui then
        for _, child in ipairs(IndicatorGui:GetChildren()) do
            child:Destroy()
        end
    end
    
    for _, obj in ipairs(workspace:GetDescendants()) do
        RemoveHighlight(obj)
    end
    
    local Map = workspace:FindFirstChild("Map")
    if Map then
        for _, obj in ipairs(Map:GetDescendants()) do
            RemoveHighlight(obj)
        end
    end
end

-- =============================================
-- RAYFIELD WINDOW
-- =============================================
local Window = Rayfield:CreateWindow({
    Name = "Yutzz",
    LoadingTitle = "VD",
    LoadingSubtitle = "by Yutzz",
    Theme = "Default",
    DisableRayfieldPrompts = false,
    DisableBuildWarnings = false,
    ConfigurationSaving = {
        Enabled = true,
        FolderName = "DBRHub",
        FileName = "Config"
    },
    KeySystem = false,
})

-- =============================================
-- TAB: MAIN
-- =============================================
local MainTab = Window:CreateTab("Main", 4483345998)

MainTab:CreateToggle({
    Name = "ALL ESP",
    CurrentValue = true,
    Flag = "AllESP",
    Callback = function(val)
        ESPEnabled = val
        if val then
            RefreshESP()
            Rayfield:Notify({
                Title = "ESP",
                Content = "All ESP Enabled!",
                Duration = 3,
                Image = 4483345998,
            })
        else
            ClearAllESP()
            Rayfield:Notify({
                Title = "ESP",
                Content = "All ESP Disabled!",
                Duration = 3,
                Image = 4483345998,
            })
        end
    end
})

MainTab:CreateButton({
    Name = "Refresh ESP",
    Callback = function()
        RefreshESP()
        Rayfield:Notify({
            Title = "ESP",
            Content = "ESP Refreshed!",
            Duration = 3,
            Image = 4483345998,
        })
    end
})

-- =============================================
-- TAB: SPEED
-- =============================================
local SpeedTab = Window:CreateTab("Speed", 4483345998)

SpeedTab:CreateParagraph({
    Title = "Speed Hack",
    Content = "Press number keys (1-9) to set walk speed. Press 0 to disable."
})

SpeedTab:CreateInput({
    Name = "Set Speed Value",
    PlaceholderText = "Enter speed number...",
    RemoveTextAfterFocusLost = false,
    Flag = "CustomSpeed",
    Callback = function(input)
        local speed = tonumber(input)
        if speed and speed > 0 then
            desiredSpeed = speed
            speedHackEnabled = true
            local humanoid = player.Character and player.Character:FindFirstChildOfClass("Humanoid")
            if humanoid then
                setupSpeedEnforcement(humanoid)
            end
            Rayfield:Notify({
                Title = "Speed",
                Content = "Speed set to " .. tostring(speed),
                Duration = 3,
                Image = 4483345998,
            })
        else
            Rayfield:Notify({
                Title = "Error",
                Content = "Enter a valid number!",
                Duration = 3,
                Image = 4483345998,
            })
        end
    end
})

SpeedTab:CreateButton({
    Name = "Reset Speed",
    Callback = function()
        speedHackEnabled = false
        desiredSpeed = 16
        local humanoid = player.Character and player.Character:FindFirstChildOfClass("Humanoid")
        if humanoid then
            humanoid.WalkSpeed = 16
        end
        for _, conn in ipairs(speedConnections) do
            conn:Disconnect()
        end
        speedConnections = {}
        Rayfield:Notify({
            Title = "Speed",
            Content = "Speed reset to 16!",
            Duration = 3,
            Image = 4483345998,
        })
    end
})

-- =============================================
-- KEYBOARD SPEED HACK
-- =============================================
local UserInputService = game:GetService("UserInputService")

local speedPresets = {
    [Enum.KeyCode.One] = 50,
    [Enum.KeyCode.Two] = 75,
    [Enum.KeyCode.Three] = 100,
    [Enum.KeyCode.Four] = 150,
    [Enum.KeyCode.Five] = 200,
    [Enum.KeyCode.Six] = 250,
    [Enum.KeyCode.Seven] = 300,
    [Enum.KeyCode.Eight] = 350,
    [Enum.KeyCode.Nine] = 400,
}

UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    
    if input.KeyCode == Enum.KeyCode.Zero then
        speedHackEnabled = false
        local humanoid = player.Character and player.Character:FindFirstChildOfClass("Humanoid")
        if humanoid then humanoid.WalkSpeed = 16 end
        Rayfield:Notify({
            Title = "Speed",
            Content = "Speed disabled",
            Duration = 2,
            Image = 4483345998,
        })
    elseif speedPresets[input.KeyCode] then
        desiredSpeed = speedPresets[input.KeyCode]
        speedHackEnabled = true
        local humanoid = player.Character and player.Character:FindFirstChildOfClass("Humanoid")
        if humanoid then
            setupSpeedEnforcement(humanoid)
        end
        Rayfield:Notify({
            Title = "Speed",
            Content = "Speed: " .. tostring(desiredSpeed),
            Duration = 2,
            Image = 4483345998,
        })
    end
end)

-- =============================================
-- MAIN LOOP
-- =============================================
RunService.Heartbeat:Connect(function()
    local now = tick()
    if now - LastUpdateTick < 0.05 then return end
    LastUpdateTick = now

    if ESPEnabled then
        for _, p in ipairs(Players:GetPlayers()) do
            if p ~= LocalPlayer then
                updatePlayerNametag(p)
            end
        end

        for i = #ActiveGenerators, 1, -1 do
            local g = ActiveGenerators[i]
            if g and g.Parent then
                if updateGeneratorProgress(g) then table.remove(ActiveGenerators, i) end
            else
                table.remove(ActiveGenerators, i)
            end
        end
    end
end)

Players.PlayerRemoving:Connect(function(p)
    if not IndicatorGui then return end
    local m = IndicatorGui:FindFirstChild(p.Name)
    if m then m:Destroy() end
end)

workspace.ChildAdded:Connect(function(c)
    if c.Name == "Map" and ESPEnabled then
        task.wait(1)
        RefreshESP()
    end
end)

LocalPlayer.CharacterAdded:Connect(function(char)
    SetupGui()
    task.wait(0.5)
    if ESPEnabled then RefreshESP() end
    if speedHackEnabled then
        local humanoid = char:WaitForChild("Humanoid", 10)
        if humanoid then setupSpeedEnforcement(humanoid) end
    end
end)

-- =============================================
-- INIT
-- =============================================
SetupGui()
RefreshESP()

Rayfield:Notify({
    Title = "Loaded!",
    Content = "Yutzz VD Loaded! Press 1-9 for speed, 0 to disable",
    Duration = 5,
    Image = 4483345998,
})
