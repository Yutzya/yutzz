-- Orion UI + ESP Script
-- Orion Library by shlexware

local OrionLib = loadstring(game:HttpGet("https://raw.githubusercontent.com/shlexware/Orion/main/source"))()

-- ============================================================
--  CONFIG
-- ============================================================
local Config = {
    Players = {
        Killer   = {Color = Color3.fromRGB(255, 93, 108)},
        Survivor = {Color = Color3.fromRGB(64, 224, 255)}
    },
    Objects = {
        Generator = {Color = Color3.fromRGB(150, 0, 200)},
        Gate      = {Color = Color3.fromRGB(255, 255, 255)},
        Pallet    = {Color = Color3.fromRGB(74, 255, 181)},
        Window    = {Color = Color3.fromRGB(74, 255, 181)},
        Hook      = {Color = Color3.fromRGB(132, 255, 169)}
    }
}

-- ============================================================
--  FEATURE FLAGS  (toggled by Orion UI)
-- ============================================================
local Flags = {
    ESP_Players      = true,
    ESP_Generators   = true,
    ESP_Hooks        = true,
    ESP_Pallets      = true,
    ESP_Windows      = true,
    ESP_Gates        = true,
    Fullbright       = true,
    KillerWarning    = true,
    KillerWarnRange  = 99,
    AutoSkillCheck   = true,
    ShowNextKiller   = true,
    ShowChaseIndicator = true,
    ShowMaskInfo     = true,
}

-- ============================================================
--  MASK DATA
-- ============================================================
local MaskNames = {
    ["Richard"] = "Rooster",  ["Tony"]    = "Tiger",
    ["Brandon"] = "Panther",  ["Cobra"]   = "Cobra",
    ["Richter"] = "Rat",      ["Rabbit"]  = "Rabbit",
    ["Alex"]    = "Chainsaw"
}
local MaskColors = {
    ["Richard"] = Color3.fromRGB(255, 0, 0),    ["Tony"]    = Color3.fromRGB(255, 255, 0),
    ["Brandon"] = Color3.fromRGB(160, 32, 240),  ["Cobra"]   = Color3.fromRGB(0, 255, 0),
    ["Richter"] = Color3.fromRGB(0, 0, 0),       ["Rabbit"]  = Color3.fromRGB(255, 105, 180),
    ["Alex"]    = Color3.fromRGB(255, 255, 255)
}

-- ============================================================
--  SERVICES & LOCALS
-- ============================================================
local Players           = game:GetService("Players")
local RunService        = game:GetService("RunService")
local VirtualInputManager = game:GetService("VirtualInputManager")
local GuiService        = game:GetService("GuiService")
local Lighting          = game:GetService("Lighting")

local LocalPlayer    = Players.LocalPlayer
local PlayerGui      = LocalPlayer:WaitForChild("PlayerGui")
local ActiveGenerators = {}
local LastUpdateTick = 0
local LastFullESPRefresh = 0

local TouchID    = 8822
local ActionPath = "Survivor-mob.Controls.action.check"
local HeartbeatConnection  = nil
local VisibilityConnection = nil
local IndicatorGui = nil

-- ============================================================
--  HELPERS
-- ============================================================
local function SetupGui()
    if PlayerGui:FindFirstChild("ChasedInds") then
        PlayerGui:FindFirstChild("ChasedInds"):Destroy()
    end
    IndicatorGui = Instance.new("ScreenGui")
    IndicatorGui.Name            = "ChasedInds"
    IndicatorGui.IgnoreGuiInset  = true
    IndicatorGui.DisplayOrder    = 999
    IndicatorGui.Parent          = PlayerGui
end

local function GetGameValue(obj, name)
    if not obj then return nil end
    local attr = obj:GetAttribute(name)
    if attr ~= nil then return attr end
    local child = obj:FindFirstChild(name)
    if child then
        local ok, val = pcall(function() return child.Value end)
        if ok then return val end
    end
    return nil
end

local function ApplyHighlight(object, color)
    local h = object:FindFirstChild("H") or Instance.new("Highlight")
    h.Name               = "H"
    h.Adornee            = object
    h.FillColor          = color
    h.OutlineColor       = color
    h.FillTransparency   = 0.8
    h.OutlineTransparency = 0.3
    h.DepthMode          = Enum.HighlightDepthMode.AlwaysOnTop
    h.Parent             = object
end

local function RemoveHighlight(object)
    local h = object:FindFirstChild("H")
    if h then h:Destroy() end
end

local function CreateBillboardTag(text, color, size, textSize)
    local billboard = Instance.new("BillboardGui")
    billboard.Name        = "BitchHook"
    billboard.AlwaysOnTop = true
    billboard.Size        = size or UDim2.new(0, 120, 0, 30)

    local label = Instance.new("TextLabel")
    label.Name                 = "BitchHook"
    label.Size                 = UDim2.new(1, 0, 1, 0)
    label.BackgroundTransparency = 1
    label.Text                 = text
    label.TextColor3           = color
    label.TextStrokeTransparency = 0
    label.TextStrokeColor3     = Color3.new(0, 0, 0)
    label.Font                 = Enum.Font.GothamBold
    label.TextSize             = textSize or 10
    label.TextWrapped          = true
    label.RichText             = true
    label.Parent               = billboard

    return billboard
end

-- ============================================================
--  PLAYER NAMETAG / ESP
-- ============================================================
local function updatePlayerNametag(player)
    if not Flags.ESP_Players then
        -- clean up if disabled
        if player.Character then
            local root = player.Character:FindFirstChild("HumanoidRootPart")
            if root then
                local b = root:FindFirstChild("BitchHook") if b then b:Destroy() end
                local m = root:FindFirstChild("MaskHook")  if m then m:Destroy() end
                local w = root:FindFirstChild("KillerWarn") if w then w:Destroy() end
            end
            RemoveHighlight(player.Character)
        end
        return
    end

    if not IndicatorGui or not IndicatorGui.Parent then return end
    if not player.Character then
        local m = IndicatorGui:FindFirstChild(player.Name)            if m then m:Destroy() end
        local c = IndicatorGui:FindFirstChild(player.Name.."_Chased") if c then c:Destroy() end
        local k = IndicatorGui:FindFirstChild(player.Name.."_Killer") if k then k:Destroy() end
        return
    end

    local rootPart = player.Character:FindFirstChild("HumanoidRootPart")
    local humanoid = player.Character:FindFirstChildOfClass("Humanoid")
    if not rootPart then return end

    local teamName          = (player.Team and player.Team.Name:lower()) or ""
    local selectedKillerAttr = GetGameValue(player, "SelectedKiller")
    local rawMask           = GetGameValue(player, "Mask") or GetGameValue(player.Character, "Mask")
    local isKnocked         = GetGameValue(player.Character, "Knocked")
    local isHooked          = GetGameValue(player.Character, "IsHooked")
    local isChased          = GetGameValue(player.Character, "IsChased")
    local isKiller          = teamName:find("killer") ~= nil

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

    local baseName  = (isKiller and selectedKillerAttr and tostring(selectedKillerAttr) ~= "") and tostring(selectedKillerAttr) or player.Name
    local nameText  = baseName .. "\n[" .. distance .. " studs]"

    local billboard = rootPart:FindFirstChild("BitchHook")
    if not billboard then
        billboard          = CreateBillboardTag(nameText, color)
        billboard.Adornee  = rootPart
        billboard.Parent   = rootPart
    else
        local lbl = billboard:FindFirstChild("BitchHook") or billboard:FindFirstChildOfClass("TextLabel")
        if lbl then lbl.Text = nameText; lbl.TextColor3 = color end
    end

    ApplyHighlight(player.Character, color)

    -- Mask tag
    if Flags.ShowMaskInfo then
        local hasMask = false
        if isKiller and string.match(tostring(selectedKillerAttr):lower(), "masked") and rawMask then
            local searchMask = tostring(rawMask):lower()
            for key, name in pairs(MaskNames) do
                if key:lower() == searchMask then
                    hasMask = true
                    local maskBillboard = rootPart:FindFirstChild("MaskHook")
                    if not maskBillboard then
                        maskBillboard = CreateBillboardTag(name, MaskColors[key] or Color3.new(1,1,1), UDim2.new(0,100,0,20), 12)
                        maskBillboard.Name        = "MaskHook"
                        maskBillboard.StudsOffset = Vector3.new(0, 3, 0)
                        maskBillboard.Adornee     = rootPart
                        maskBillboard.Parent      = rootPart
                    else
                        local lbl = maskBillboard:FindFirstChild("BitchHook") or maskBillboard:FindFirstChildOfClass("TextLabel")
                        if lbl then lbl.Text = name; lbl.TextColor3 = MaskColors[key] or Color3.new(1,1,1) end
                    end
                    break
                end
            end
        end
        if not hasMask then
            local mb = rootPart:FindFirstChild("MaskHook") if mb then mb:Destroy() end
        end
    else
        local mb = rootPart:FindFirstChild("MaskHook") if mb then mb:Destroy() end
    end

    -- Chase indicator
    local chasedLabel2D = IndicatorGui:FindFirstChild(player.Name.."_Chased")
    if Flags.ShowChaseIndicator and isChased then
        local ct3 = billboard:FindFirstChild("ChasedLabel")
        if not ct3 then
            ct3 = Instance.new("TextLabel", billboard)
            ct3.Name = "ChasedLabel"
            ct3.Size, ct3.Position, ct3.BackgroundTransparency = UDim2.new(1,0,1,0), UDim2.new(0,0,-1.2,0), 1
            ct3.Font, ct3.TextSize = Enum.Font.GothamBold, 24
        end
        ct3.Text, ct3.TextColor3, ct3.TextStrokeTransparency = "!!", color, 0

        if not chasedLabel2D then
            chasedLabel2D = Instance.new("TextLabel", IndicatorGui)
            chasedLabel2D.Name = player.Name.."_Chased"
            chasedLabel2D.BackgroundTransparency = 1
            chasedLabel2D.Font, chasedLabel2D.TextSize, chasedLabel2D.TextStrokeTransparency = Enum.Font.GothamBold, 24, 0
            chasedLabel2D.AnchorPoint = Vector2.new(0.5, 0.5)
        end
        chasedLabel2D.Text, chasedLabel2D.TextColor3 = "!!", color

        local screenPos, onScreen = workspace.CurrentCamera:WorldToScreenPoint(rootPart.Position)
        if onScreen then
            chasedLabel2D.Visible = false
        else
            chasedLabel2D.Visible = true
            local vc  = workspace.CurrentCamera.ViewportSize / 2
            local dir = Vector2.new(screenPos.X, screenPos.Y) - vc
            if screenPos.Z < 0 then dir = -dir end
            local ms  = math.max(math.abs(dir.X)/(vc.X-30), math.abs(dir.Y)/(vc.Y-30))
            chasedLabel2D.Position = UDim2.new(0, vc.X+dir.X/(ms==0 and 1 or ms), 0, vc.Y+dir.Y/(ms==0 and 1 or ms))
        end
    else
        if chasedLabel2D then chasedLabel2D:Destroy() end
        local ct3 = billboard:FindFirstChild("ChasedLabel") if ct3 then ct3:Destroy() end
    end

    -- Off-screen killer arrow
    local killerLabel2D = IndicatorGui:FindFirstChild(player.Name.."_Killer")
    if isKiller then
        if not killerLabel2D then
            killerLabel2D = Instance.new("TextLabel", IndicatorGui)
            killerLabel2D.Name = player.Name.."_Killer"
            killerLabel2D.BackgroundTransparency = 1
            killerLabel2D.Font, killerLabel2D.TextSize, killerLabel2D.TextStrokeTransparency = Enum.Font.GothamBold, 10, 0
            killerLabel2D.Size, killerLabel2D.RichText, killerLabel2D.AnchorPoint = UDim2.new(0,120,0,30), true, Vector2.new(0.5,0.5)
        end
        killerLabel2D.Text = baseName.."\n["..distance.." studs]"
        killerLabel2D.TextColor3 = color

        local screenPos, onScreen = workspace.CurrentCamera:WorldToScreenPoint(rootPart.Position)
        if not onScreen then
            killerLabel2D.Visible = true
            local vc  = workspace.CurrentCamera.ViewportSize / 2
            local dir = Vector2.new(screenPos.X, screenPos.Y) - vc
            if screenPos.Z < 0 then dir = -dir end
            local ms  = math.max(math.abs(dir.X)/(vc.X-30), math.abs(dir.Y)/(vc.Y-30))
            killerLabel2D.Position = UDim2.new(0, vc.X+dir.X/(ms==0 and 1 or ms), 0, vc.Y+dir.Y/(ms==0 and 1 or ms))
        else
            killerLabel2D.Visible = false
        end
    elseif killerLabel2D then killerLabel2D:Destroy() end
end

-- ============================================================
--  GENERATOR PROGRESS
-- ============================================================
local function updateGeneratorProgress(generator)
    if not generator or not generator.Parent then return true end
    if not Flags.ESP_Generators then
        local b = generator:FindFirstChild("GenBitchHook") if b then b:Destroy() end
        RemoveHighlight(generator)
        return false
    end

    local percent = GetGameValue(generator, "RepairProgress") or GetGameValue(generator, "Progress") or 0
    local billboard = generator:FindFirstChild("GenBitchHook")
    if percent >= 100 then
        if billboard then billboard:Destroy() end
        local h = generator:FindFirstChild("H") if h then h:Destroy() end
        return true
    end

    local cp = math.clamp(percent, 0, 100)
    local finalColor = cp < 50
        and Config.Objects.Generator.Color:Lerp(Color3.fromRGB(180,180,0), cp/50)
        or  Color3.fromRGB(180,180,0):Lerp(Color3.fromRGB(0,150,0), (cp-50)/50)

    local percentStr = string.format("[%.2f%%]", percent)
    if not billboard then
        billboard = CreateBillboardTag(percentStr, finalColor)
        billboard.Name, billboard.StudsOffset = "GenBitchHook", Vector3.new(0,2,0)
        billboard.Adornee = generator:FindFirstChild("defaultMaterial", true) or generator
        billboard.Parent  = generator
    else
        local lbl = billboard:FindFirstChild("BitchHook") or billboard:FindFirstChildOfClass("TextLabel")
        if lbl then lbl.Text = percentStr; lbl.TextColor3 = finalColor end
    end
    return false
end

-- ============================================================
--  NEXT KILLER DISPLAY
-- ============================================================
local function updateNextKillerDisplay()
    if not Flags.ShowNextKiller then
        if IndicatorGui then
            local l = IndicatorGui:FindFirstChild("NextKillerDisplay") if l then l:Destroy() end
        end
        return
    end
    if not IndicatorGui or not IndicatorGui.Parent then return end
    local label   = IndicatorGui:FindFirstChild("NextKillerDisplay")
    local teamName = (LocalPlayer.Team and LocalPlayer.Team.Name:lower()) or ""
    if teamName:find("spectator") or teamName:find("lobby") then
        if not label then
            label = Instance.new("TextLabel", IndicatorGui)
            label.Name                 = "NextKillerDisplay"
            label.Size, label.Position = UDim2.new(0,220,0,30), UDim2.new(0.5,0,0,45)
            label.AnchorPoint          = Vector2.new(0.5, 0)
            label.BackgroundTransparency, label.BackgroundColor3 = 0.5, Color3.new(0,0,0)
            label.TextColor3, label.Font, label.TextSize, label.RichText = Color3.new(1,1,1), Enum.Font.GothamBold, 14, true
            label.Text = "Next Killer: Calculating..."
        end
        local players = Players:GetPlayers()
        table.sort(players, function(a, b)
            local aA = GetGameValue(a, "AllowKiller") or false
            local bA = GetGameValue(b, "AllowKiller") or false
            if aA ~= bA then return aA == true end
            return (GetGameValue(a, "KillerChance") or 0) > (GetGameValue(b, "KillerChance") or 0)
        end)
        local nk = players[1]
        if nk then
            label.Text = "Next Killer: <font color=\"rgb(255,0,0)\">"
                .. (nk == LocalPlayer and "YOU" or tostring(GetGameValue(nk, "SelectedKiller") or nk.Name))
                .. "</font>"
        end
    elseif label then label:Destroy() end
end

-- ============================================================
--  REFRESH ESP (objects)
-- ============================================================
local function RefreshESP()
    ActiveGenerators = {}
    for _, obj in ipairs(workspace:GetDescendants()) do
        if obj.Name == "Window" then
            if Flags.ESP_Windows then ApplyHighlight(obj, Config.Objects.Window.Color)
            else RemoveHighlight(obj) end
        end
    end
    local Map = workspace:FindFirstChild("Map")
    if not Map then return end
    for _, obj in ipairs(Map:GetDescendants()) do
        if obj.Name == "Generator" then
            if Flags.ESP_Generators then ApplyHighlight(obj, Config.Objects.Generator.Color) table.insert(ActiveGenerators, obj)
            else RemoveHighlight(obj) end
        elseif obj.Name == "Hook" then
            local m = obj:FindFirstChild("Model")
            if m then for _, p in ipairs(m:GetDescendants()) do
                if p:IsA("MeshPart") then
                    if Flags.ESP_Hooks then ApplyHighlight(p, Config.Objects.Hook.Color)
                    else RemoveHighlight(p) end
                end
            end end
        elseif obj.Name == "Palletwrong" or obj.Name == "Pallet" then
            if Flags.ESP_Pallets then ApplyHighlight(obj, Config.Objects.Pallet.Color)
            else RemoveHighlight(obj) end
        elseif obj.Name == "Gate" then
            if Flags.ESP_Gates then ApplyHighlight(obj, Config.Objects.Gate.Color)
            else RemoveHighlight(obj) end
        end
    end
end

-- ============================================================
--  AUTO SKILL CHECK
-- ============================================================
local function GetActionTarget()
    local current = PlayerGui
    for segment in string.gmatch(ActionPath, "[^%.]+") do
        current = current and current:FindFirstChild(segment)
    end
    return current
end

local function TriggerMobileButton()
    local b = GetActionTarget()
    if b and b:IsA("GuiObject") then
        local p, s, i = b.AbsolutePosition, b.AbsoluteSize, GuiService:GetGuiInset()
        local cx, cy  = p.X+(s.X/2)+i.X, p.Y+(s.Y/2)+i.Y
        pcall(function()
            VirtualInputManager:SendTouchEvent(TouchID, 0, cx, cy)
            task.wait(0.01)
            VirtualInputManager:SendTouchEvent(TouchID, 2, cx, cy)
        end)
    end
end

local function InitializeAutobuy()
    if not Flags.AutoSkillCheck then return end
    task.spawn(function()
        local prompt = PlayerGui:WaitForChild("SkillCheckPromptGui", 10)
        local check  = prompt and prompt:WaitForChild("Check", 10)
        if not check then return end
        local line, goal = check:WaitForChild("Line"), check:WaitForChild("Goal")
        if VisibilityConnection then VisibilityConnection:Disconnect() end
        VisibilityConnection = check:GetPropertyChangedSignal("Visible"):Connect(function()
            if not Flags.AutoSkillCheck then return end
            if LocalPlayer.Team and LocalPlayer.Team.Name == "Survivors" and check.Visible then
                if HeartbeatConnection then HeartbeatConnection:Disconnect() end
                HeartbeatConnection = RunService.Heartbeat:Connect(function()
                    local lr, gr = line.Rotation % 360, goal.Rotation % 360
                    local ss, se = (gr+101)%360, (gr+115)%360
                    if (ss > se and (lr >= ss or lr <= se)) or (lr >= ss and lr <= se) then
                        TriggerMobileButton()
                        if HeartbeatConnection then HeartbeatConnection:Disconnect() HeartbeatConnection = nil end
                    end
                end)
            elseif HeartbeatConnection then HeartbeatConnection:Disconnect() HeartbeatConnection = nil end
        end)
    end)
end

-- ============================================================
--  EVENTS
-- ============================================================
workspace.ChildAdded:Connect(function(c)
    if c.Name == "Map" then task.wait(1) RefreshESP() end
end)

LocalPlayer.CharacterAdded:Connect(function()
    if HeartbeatConnection  then HeartbeatConnection:Disconnect()  end
    if VisibilityConnection then VisibilityConnection:Disconnect() end
    SetupGui()
    task.wait(1)
    InitializeAutobuy()
end)

-- ============================================================
--  HEARTBEAT
-- ============================================================
RunService.Heartbeat:Connect(function()
    local now = tick()
    if now - LastUpdateTick < 0.05 then return end
    LastUpdateTick = now

    -- Fullbright
    if Flags.Fullbright then
        Lighting.Ambient       = Color3.fromRGB(255,255,255)
        Lighting.OutdoorAmbient = Color3.fromRGB(255,255,255)
        Lighting.Brightness    = 2
        Lighting.ClockTime     = 14
        Lighting.GlobalShadows = false
        Lighting.FogEnd        = 9e9
    end

    if now - LastFullESPRefresh > 5 then LastFullESPRefresh = now RefreshESP() end
    updateNextKillerDisplay()

    local myChar  = LocalPlayer.Character
    local myRoot  = myChar and myChar:FindFirstChild("HumanoidRootPart")
    local killerNearby = false

    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= LocalPlayer then
            updatePlayerNametag(p)
            if Flags.KillerWarning then
                local pTeam = p.Team and p.Team.Name:lower() or ""
                if pTeam:find("killer") and myRoot and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
                    if (p.Character.HumanoidRootPart.Position - myRoot.Position).Magnitude < Flags.KillerWarnRange then
                        killerNearby = true
                    end
                end
            end
        end
    end

    if myRoot then
        local warn = myRoot:FindFirstChild("KillerWarn")
        if killerNearby and Flags.KillerWarning then
            if not warn then
                warn = CreateBillboardTag("!", Color3.fromRGB(255,0,0), UDim2.new(0,50,0,50), 40)
                warn.Name, warn.StudsOffset, warn.Adornee, warn.Parent = "KillerWarn", Vector3.new(0,4,0), myRoot, myRoot
            end
        elseif warn then warn:Destroy() end
    end

    for i = #ActiveGenerators, 1, -1 do
        local g = ActiveGenerators[i]
        if g and g.Parent then
            if updateGeneratorProgress(g) then table.remove(ActiveGenerators, i) end
        else
            table.remove(ActiveGenerators, i)
        end
    end
end)

Players.PlayerRemoving:Connect(function(p)
    if not IndicatorGui then return end
    for _, n in ipairs({p.Name.."_Chased", p.Name.."_Killer", p.Name}) do
        local obj = IndicatorGui:FindFirstChild(n) if obj then obj:Destroy() end
    end
end)

-- ============================================================
--  ORION UI
-- ============================================================
local Window = OrionLib:MakeWindow({
    Name           = "ESP & Utils",
    HidePremium    = false,
    SaveConfig     = true,
    ConfigFolder   = "ESPConfig",
    IntroEnabled   = true,
    IntroText      = "ESP Loaded",
})

-- ── TAB 1: ESP ───────────────────────────────────────────────
local ESPTab = Window:MakeTab({ Name = "ESP", Icon = "rbxassetid://4483345998", PremiumOnly = false })

ESPTab:AddToggle({
    Name    = "Player ESP",
    Default = Flags.ESP_Players,
    Save    = true,
    Flag    = "ESP_Players",
    Callback = function(v) Flags.ESP_Players = v end
})

ESPTab:AddToggle({
    Name    = "Generator ESP",
    Default = Flags.ESP_Generators,
    Save    = true,
    Flag    = "ESP_Generators",
    Callback = function(v) Flags.ESP_Generators = v RefreshESP() end
})

ESPTab:AddToggle({
    Name    = "Hook ESP",
    Default = Flags.ESP_Hooks,
    Save    = true,
    Flag    = "ESP_Hooks",
    Callback = function(v) Flags.ESP_Hooks = v RefreshESP() end
})

ESPTab:AddToggle({
    Name    = "Pallet ESP",
    Default = Flags.ESP_Pallets,
    Save    = true,
    Flag    = "ESP_Pallets",
    Callback = function(v) Flags.ESP_Pallets = v RefreshESP() end
})

ESPTab:AddToggle({
    Name    = "Window ESP",
    Default = Flags.ESP_Windows,
    Save    = true,
    Flag    = "ESP_Windows",
    Callback = function(v) Flags.ESP_Windows = v RefreshESP() end
})

ESPTab:AddToggle({
    Name    = "Gate ESP",
    Default = Flags.ESP_Gates,
    Save    = true,
    Flag    = "ESP_Gates",
    Callback = function(v) Flags.ESP_Gates = v RefreshESP() end
})

ESPTab:AddDivider()

ESPTab:AddColorPicker({
    Name     = "Killer Color",
    Default  = Config.Players.Killer.Color,
    Flag     = "KillerColor",
    Save     = true,
    Callback = function(v) Config.Players.Killer.Color = v end
})

ESPTab:AddColorPicker({
    Name     = "Survivor Color",
    Default  = Config.Players.Survivor.Color,
    Flag     = "SurvivorColor",
    Save     = true,
    Callback = function(v) Config.Players.Survivor.Color = v end
})

ESPTab:AddColorPicker({
    Name     = "Generator Color",
    Default  = Config.Objects.Generator.Color,
    Flag     = "GenColor",
    Save     = true,
    Callback = function(v) Config.Objects.Generator.Color = v RefreshESP() end
})

ESPTab:AddColorPicker({
    Name     = "Hook Color",
    Default  = Config.Objects.Hook.Color,
    Flag     = "HookColor",
    Save     = true,
    Callback = function(v) Config.Objects.Hook.Color = v RefreshESP() end
})

ESPTab:AddColorPicker({
    Name     = "Pallet/Window Color",
    Default  = Config.Objects.Pallet.Color,
    Flag     = "PalletColor",
    Save     = true,
    Callback = function(v)
        Config.Objects.Pallet.Color = v
        Config.Objects.Window.Color = v
        RefreshESP()
    end
})

-- ── TAB 2: VISUAL ────────────────────────────────────────────
local VisualTab = Window:MakeTab({ Name = "Visual", Icon = "rbxassetid://4483345998", PremiumOnly = false })

VisualTab:AddToggle({
    Name     = "Fullbright",
    Default  = Flags.Fullbright,
    Save     = true,
    Flag     = "Fullbright",
    Callback = function(v) Flags.Fullbright = v end
})

VisualTab:AddToggle({
    Name     = "Chase Indicator (!!)",
    Default  = Flags.ShowChaseIndicator,
    Save     = true,
    Flag     = "ShowChaseIndicator",
    Callback = function(v) Flags.ShowChaseIndicator = v end
})

VisualTab:AddToggle({
    Name     = "Show Mask Info",
    Default  = Flags.ShowMaskInfo,
    Save     = true,
    Flag     = "ShowMaskInfo",
    Callback = function(v) Flags.ShowMaskInfo = v end
})

VisualTab:AddToggle({
    Name     = "Show Next Killer (Lobby)",
    Default  = Flags.ShowNextKiller,
    Save     = true,
    Flag     = "ShowNextKiller",
    Callback = function(v) Flags.ShowNextKiller = v end
})

-- ── TAB 3: KILLER WARN ───────────────────────────────────────
local WarnTab = Window:MakeTab({ Name = "Warning", Icon = "rbxassetid://4483345998", PremiumOnly = false })

WarnTab:AddToggle({
    Name     = "Killer Nearby Warning",
    Default  = Flags.KillerWarning,
    Save     = true,
    Flag     = "KillerWarning",
    Callback = function(v) Flags.KillerWarning = v end
})

WarnTab:AddSlider({
    Name    = "Warning Range (studs)",
    Min     = 10,
    Max     = 300,
    Default = Flags.KillerWarnRange,
    Color   = Color3.fromRGB(255, 93, 108),
    Increment = 5,
    ValueName = "studs",
    Save    = true,
    Flag    = "KillerWarnRange",
    Callback = function(v) Flags.KillerWarnRange = v end
})

-- ── TAB 4: AUTO ──────────────────────────────────────────────
local AutoTab = Window:MakeTab({ Name = "Auto", Icon = "rbxassetid://4483345998", PremiumOnly = false })

AutoTab:AddToggle({
    Name     = "Auto Skill Check",
    Default  = Flags.AutoSkillCheck,
    Save     = true,
    Flag     = "AutoSkillCheck",
    Callback = function(v)
        Flags.AutoSkillCheck = v
        if v then
            InitializeAutobuy()
        else
            if HeartbeatConnection  then HeartbeatConnection:Disconnect()  HeartbeatConnection  = nil end
            if VisibilityConnection then VisibilityConnection:Disconnect() VisibilityConnection = nil end
        end
    end
})

AutoTab:AddButton({
    Name     = "Force Refresh ESP",
    Callback = function() RefreshESP() end
})

-- ── TAB 5: MISC ──────────────────────────────────────────────
local MiscTab = Window:MakeTab({ Name = "Misc", Icon = "rbxassetid://4483345998", PremiumOnly = false })

MiscTab:AddLabel("Made with Orion UI by shlexware")
MiscTab:AddLabel("ESP + Auto Skill Check loaded ✓")

MiscTab:AddButton({
    Name     = "Destroy GUI",
    Callback = function() OrionLib:Destroy() end
})

-- ============================================================
--  INIT
-- ============================================================
SetupGui()
RefreshESP()
InitializeAutobuy()
OrionLib:Init()
