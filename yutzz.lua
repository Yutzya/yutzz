-- This WILL NOT WORK ON LOW UNC EXECUTORS LIKE XENO
local function SafeDrawing(type)
    local success, result = pcall(function()
        return Drawing.new(type)
    end)
    if success then return result end
    return nil
end

local function SafeRemove(obj)
    if obj and obj.Remove then
        pcall(function() obj:Remove() end)
    end
end

if not Drawing or not Drawing.new then
    local waited = 0
    while not Drawing and waited < 5 do
        task.wait(0.1)
        waited = waited + 0.1
    end
    
    if not Drawing then
        warn("[Violence] Drawing library not available.")
        return
    end
end

local ExecutorName = "Unknown"
pcall(function()
    if identifyexecutor then
        ExecutorName = identifyexecutor()
    elseif getexecutorname then
        ExecutorName = getexecutorname()
    end
end)

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
local LocalPlayer = Players.LocalPlayer

local Config = {
    ESP_Enabled = true,
    ESP_Killer = true,
    ESP_Survivor = true,
    ESP_Generator = true,
    ESP_Gate = true,
    ESP_Hook = true,
    ESP_Pallet = true,
    ESP_Window = false,
    ESP_Distance = true,
    ESP_Names = true,
    ESP_Health = true,
    ESP_Skeleton = false,
    ESP_Offscreen = true,
    ESP_Velocity = false,
    ESP_ClosestHook = true,
    ESP_MaxDist = 500,
    
    ESP_PlayerChams = false,
    ESP_ObjectChams = true,
    
    RADAR_Enabled = false,
    RADAR_Size = 120,
    RADAR_Circle = false,
    RADAR_Killer = true,
    RADAR_Survivor = true,
    RADAR_Generator = true,
    RADAR_Pallet = true,
    
    AUTO_Generator = false,
    AUTO_GenMode = "Fast",
    AUTO_LeaveGen = false,
    AUTO_LeaveDist = 18,
    AUTO_Attack = false,
    AUTO_AttackRange = 12,
    HITBOX_Enabled = false,
    HITBOX_Size = 15,
    AUTO_TeleAway = false,
    AUTO_TeleAwayDist = 40,
    
    AUTO_Parry = false,
    AUTO_SkillCheck = false,
    SURV_NoFall = false,
    SURV_AutoWiggle = false,
    KILLER_DestroyPallets = false,
    KILLER_FullGenBreak = false,
    KILLER_NoPalletStun = false,
    KILLER_AutoHook = false,
    KILLER_AntiBlind = false,
    KILLER_NoSlowdown = false,
    KILLER_DoubleTap = false,
    KILLER_InfiniteLunge = false,
    SPEED_Enabled = false,
    SPEED_Value = 32,
    SPEED_Method = "Attribute",
    KEY_Speed = Enum.KeyCode.C,
    NOCLIP_Enabled = false,
    KEY_Noclip = Enum.KeyCode.V,
    FLY_Enabled = false,
    FLY_Speed = 50,
    FLY_Method = "CFrame",
    KEY_Fly = Enum.KeyCode.F,
    JUMP_Power = 50,
    JUMP_Infinite = false,
    
    NO_Fog = false,
    CAM_FOVEnabled = false,
    CAM_FOV = 90,
    CAM_ThirdPerson = false,
    CAM_ShiftLock = false,
    FLING_Enabled = false,
    FLING_Strength = 10000,
    
    BEAT_Survivor = false,
    BEAT_Killer = false,
    
    TP_Offset = 3,
    
    MENU_Open = true,
    MENU_Tab = 1,
    
    KEY_Menu = Enum.KeyCode.Insert,
    KEY_Panic = Enum.KeyCode.Home,
    KEY_LeaveGen = Enum.KeyCode.Q,
    KEY_StopGen = Enum.KeyCode.X,
    KEY_TP_Gen = Enum.KeyCode.G,
    KEY_TP_Gate = Enum.KeyCode.T,
    KEY_TP_Hook = Enum.KeyCode.H,
    
    AIM_Enabled = false,
    AIM_UseRMB = true,
    AIM_FOV = 120,
    AIM_Smooth = 0.3,
    AIM_TargetPart = "Head",
    AIM_VisCheck = true,
    AIM_ShowFOV = true,
    AIM_Predict = true,
    
    
    SPEAR_Aimbot = false,
    SPEAR_Gravity = 50,
    SPEAR_Speed = 100
}

local Tuning = {
    ESP_RefreshRate = 0.08,
    ESP_VisCheckRate = 0.15,
    Gen_RefreshRate = 0.2,
    CacheRefreshRate = 1.0,
    
    Box_WidthRatio = 0.55,
    Name_Offset = 18,
    Dist_Offset = 5,
    Health_Width = 4,
    Health_Offset = 6,
    
    Offscreen_Edge = 50,
    Offscreen_Size = 12,
    
    Skel_Thickness = 1,
    Box_Thickness = 1,
    
    RadarRange = 150,
    RadarDotSize = 5,
    RadarArrowSize = 8
}


local Colors = {
    Killer = Color3.fromRGB(255, 65, 65),
    KillerVis = Color3.fromRGB(255, 120, 120),
    Survivor = Color3.fromRGB(65, 220, 130),
    SurvivorVis = Color3.fromRGB(120, 255, 170),
    Generator = Color3.fromRGB(255, 180, 50),
    GeneratorDone = Color3.fromRGB(100, 255, 130),
    Gate = Color3.fromRGB(200, 200, 220),
    Hook = Color3.fromRGB(255, 100, 100),
    HookClose = Color3.fromRGB(255, 230, 80),
    Pallet = Color3.fromRGB(220, 180, 100),
    Window = Color3.fromRGB(100, 180, 255),
    Skeleton = Color3.fromRGB(255, 255, 255),
    SkeletonVis = Color3.fromRGB(150, 255, 150),
    Offscreen = Color3.fromRGB(255, 255, 255),
    HealthHigh = Color3.fromRGB(100, 255, 100),
    HealthMid = Color3.fromRGB(255, 220, 60),
    HealthLow = Color3.fromRGB(255, 70, 70),
    HealthBg = Color3.fromRGB(25, 25, 25),
    
    UI_Bg = Color3.fromRGB(12, 12, 16),
    UI_Card = Color3.fromRGB(20, 20, 26),
    UI_CardHover = Color3.fromRGB(30, 30, 40),
    UI_Border = Color3.fromRGB(45, 45, 55),
    UI_Accent = Color3.fromRGB(220, 70, 70),
    UI_AccentDim = Color3.fromRGB(160, 55, 55),
    UI_Text = Color3.fromRGB(235, 235, 240),
    UI_TextDim = Color3.fromRGB(130, 130, 145),
    UI_On = Color3.fromRGB(90, 220, 120),
    UI_Off = Color3.fromRGB(60, 60, 75),
    UI_Sidebar = Color3.fromRGB(16, 16, 20),
    UI_TabActive = Color3.fromRGB(220, 70, 70),
    UI_TabInactive = Color3.fromRGB(85, 85, 100),
    
    RadarBg = Color3.fromRGB(20, 20, 20),
    RadarBorder = Color3.fromRGB(255, 65, 65),
    RadarYou = Color3.fromRGB(0, 255, 0)
}


local ChamsColors = {
    Killer = {fill = Color3.fromRGB(180, 40, 40), outline = Color3.fromRGB(255, 80, 80), fillTrans = 0.6},
    Survivor = {fill = Color3.fromRGB(40, 160, 80), outline = Color3.fromRGB(80, 255, 130), fillTrans = 0.6},
    Generator = {fill = Color3.fromRGB(200, 140, 30), outline = Color3.fromRGB(255, 200, 80), fillTrans = 0.5},
    Gate = {fill = Color3.fromRGB(150, 150, 170), outline = Color3.fromRGB(220, 220, 255), fillTrans = 0.5},
    Hook = {fill = Color3.fromRGB(180, 60, 60), outline = Color3.fromRGB(255, 100, 100), fillTrans = 0.5},
    HookClose = {fill = Color3.fromRGB(200, 180, 40), outline = Color3.fromRGB(255, 240, 100), fillTrans = 0.4},
    Pallet = {fill = Color3.fromRGB(180, 140, 70), outline = Color3.fromRGB(255, 210, 130), fillTrans = 0.5},
    Window = {fill = Color3.fromRGB(60, 140, 200), outline = Color3.fromRGB(120, 200, 255), fillTrans = 0.5}
}


local Bones_R15 = {
    {"Head", "UpperTorso"}, {"UpperTorso", "LowerTorso"},
    {"UpperTorso", "LeftUpperArm"}, {"LeftUpperArm", "LeftLowerArm"}, {"LeftLowerArm", "LeftHand"},
    {"UpperTorso", "RightUpperArm"}, {"RightUpperArm", "RightLowerArm"}, {"RightLowerArm", "RightHand"},
    {"LowerTorso", "LeftUpperLeg"}, {"LeftUpperLeg", "LeftLowerLeg"}, {"LeftLowerLeg", "LeftFoot"},
    {"LowerTorso", "RightUpperLeg"}, {"RightUpperLeg", "RightLowerLeg"}, {"RightLowerLeg", "RightFoot"}
}

local Bones_R6 = {
    {"Head", "Torso"}, {"Torso", "Left Arm"}, {"Torso", "Right Arm"}, {"Torso", "Left Leg"}, {"Torso", "Right Leg"}
}


local State = {
    Unloaded = false,
    LastESPUpdate = 0,
    LastVisCheck = 0,
    LastGenUpdate = 0,
    LastCacheUpdate = 0,
    LastTeleAway = 0,
    AimTarget = nil,
    AimHolding = false,
    OriginalSpeed = 16,
    LastFogState = false,
    KillerTarget = nil,
    LastBeatTP = 0,
    LastFinishPos = nil,
    BeatSurvivorDone = false
}

local Cache = {
    Players = {},
    Generators = {},
    Gates = {},
    Hooks = {},
    Pallets = {},
    Windows = {},
    Visibility = {},
    ClosestHook = nil
}

local Connections = {}


local Unload

local function GetRole()
    if not LocalPlayer.Team then return "Unknown" end
    local name = LocalPlayer.Team.Name
    if name == "Killer" then return "Killer" end
    if name == "Survivors" then return "Survivor" end
    return "Lobby"
end

local function IsKiller(player)
    return player and player.Team and player.Team.Name == "Killer"
end

local function IsSurvivor(player)
    return player and player.Team and player.Team.Name == "Survivors"
end

local function GetCharacterRoot()
    local char = LocalPlayer.Character
    return char and char:FindFirstChild("HumanoidRootPart")
end

local function IsR6(char)
    return char:FindFirstChild("Torso") ~= nil
end

local function GetDistance(pos)
    local root = GetCharacterRoot()
    if not root then return math.huge end
    return (pos - root.Position).Magnitude
end

local function IsVisible(char)
    if not char then return false end
    local cam = workspace.CurrentCamera
    if not cam then return false end
    
    local origin = cam.CFrame.Position
    local parts = {"Head", "UpperTorso", "Torso", "HumanoidRootPart"}
    
    local params = RaycastParams.new()
    params.FilterType = Enum.RaycastFilterType.Blacklist
    params.FilterDescendantsInstances = {cam, LocalPlayer.Character, char}
    
    for _, partName in ipairs(parts) do
        local part = char:FindFirstChild(partName)
        if part then
            local dir = part.Position - origin
            local ray = workspace:Raycast(origin, dir, params)
            if not ray then return true end
        end
    end
    return false
end

local function WorldToScreen(pos)
    local cam = workspace.CurrentCamera
    if not cam then return Vector2.new(), false, 0 end
    local screen, onScreen = cam:WorldToViewportPoint(pos)
    return Vector2.new(screen.X, screen.Y), onScreen, screen.Z
end

local function Lerp(a, b, t)
    return a + (b - a) * t
end

local function LerpColor(c1, c2, t)
    return Color3.new(
        c1.R + (c2.R - c1.R) * t,
        c1.G + (c2.G - c1.G) * t,
        c1.B + (c2.B - c1.B) * t
    )
end



local Chams = {
    Objects = {},
    Labels = {}
}

function Chams.Create(target, colorData, label)
    if not target or not target:IsA("Instance") then return nil end
    
    local existing = target:FindFirstChild("_ViolenceChams")
    if existing then existing:Destroy() end
    
    local highlight = Instance.new("Highlight")
    highlight.Name = "_ViolenceChams"
    highlight.Adornee = target
    highlight.FillColor = colorData.fill
    highlight.OutlineColor = colorData.outline
    highlight.FillTransparency = colorData.fillTrans
    highlight.OutlineTransparency = 0
    highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
    highlight.Parent = target
    
    local data = {highlight = highlight, target = target}
    
    if label then
        local rootPart = target:IsA("Model") and (target:FindFirstChild("HumanoidRootPart") or target:FindFirstChildWhichIsA("BasePart")) or target
        if rootPart then
            local billboard = Instance.new("BillboardGui")
            billboard.Name = "_ViolenceLabel"
            billboard.Size = UDim2.new(0, 80, 0, 18)
            billboard.AlwaysOnTop = true
            billboard.StudsOffset = Vector3.new(0, 3, 0)
            billboard.Adornee = rootPart
            billboard.Parent = target
            
            local textLabel = Instance.new("TextLabel")
            textLabel.Size = UDim2.new(1, 0, 1, 0)
            textLabel.BackgroundTransparency = 1
            textLabel.TextColor3 = colorData.outline
            textLabel.TextStrokeColor3 = Color3.new(0, 0, 0)
            textLabel.TextStrokeTransparency = 0.2
            textLabel.Font = Enum.Font.Gotham
            textLabel.TextSize = 10
            textLabel.TextScaled = false
            textLabel.Text = label
            textLabel.Parent = billboard
            
            data.billboard = billboard
            data.textLabel = textLabel
            data.rootPart = rootPart
        end
    end
    
    Chams.Objects[target] = data
    return data
end

function Chams.Update(target, newLabel, newDist)
    local data = Chams.Objects[target]
    if not data then return end
    
    if data.textLabel and newLabel then
        local text = newLabel
        if newDist and Config.ESP_Distance then
            text = text .. "\n" .. math.floor(newDist) .. "m"
        end
        data.textLabel.Text = text
    end
end

function Chams.SetColor(target, colorData)
    local data = Chams.Objects[target]
    if not data or not data.highlight then return end
    
    data.highlight.FillColor = colorData.fill
    data.highlight.OutlineColor = colorData.outline
    data.highlight.FillTransparency = colorData.fillTrans
    
    if data.textLabel then
        data.textLabel.TextColor3 = colorData.outline
    end
end

function Chams.Remove(target)
    local data = Chams.Objects[target]
    if data then
        if data.highlight and data.highlight.Parent then
            data.highlight:Destroy()
        end
        if data.billboard and data.billboard.Parent then
            data.billboard:Destroy()
        end
        Chams.Objects[target] = nil
    end
    
    if target then
        local existing = target:FindFirstChild("_ViolenceChams")
        if existing then existing:Destroy() end
        local existingLabel = target:FindFirstChild("_ViolenceLabel")
        if existingLabel then existingLabel:Destroy() end
    end
end

function Chams.ClearAll()
    for target, _ in pairs(Chams.Objects) do
        Chams.Remove(target)
    end
    Chams.Objects = {}
end



local ESP = {
    cache = {},
    objectCache = {},
    velocityData = {}
}

function ESP.create()
    local skel = {}
    for i = 1, 14 do
        skel[i] = Drawing.new("Line")
        skel[i].Thickness = 1
        skel[i].Visible = false
    end
    
    local box = {}
    for i = 1, 4 do
        box[i] = Drawing.new("Line")
        box[i].Thickness = 1
        box[i].Visible = false
    end
    
    return {
        Box = box,
        Name = Drawing.new("Text"),
        Dist = Drawing.new("Text"),
        Skel = skel,
        HealthBg = Drawing.new("Square"),
        HealthBar = Drawing.new("Square"),
        Offscreen = Drawing.new("Triangle"),
        VelLine = Drawing.new("Line"),
        VelArrow = Drawing.new("Triangle")
    }
end

function ESP.setup(esp)
    for _, l in ipairs(esp.Box) do
        l.Thickness = 1
        l.Visible = false
    end
    
    esp.Name.Size = 14
    esp.Name.Font = Drawing.Fonts.Monospace
    esp.Name.Center = true
    esp.Name.Outline = true
    esp.Name.Visible = false
    
    esp.Dist.Size = 12
    esp.Dist.Font = Drawing.Fonts.Monospace
    esp.Dist.Center = true
    esp.Dist.Outline = true
    esp.Dist.Color = Color3.fromRGB(180, 180, 180)
    esp.Dist.Visible = false
    
    for _, l in ipairs(esp.Skel) do
        l.Thickness = 1
        l.Visible = false
    end
    
    esp.HealthBg.Filled = true
    esp.HealthBg.Color = Colors.HealthBg
    esp.HealthBg.Visible = false
    
    esp.HealthBar.Filled = true
    esp.HealthBar.Visible = false
    
    esp.Offscreen.Filled = true
    esp.Offscreen.Visible = false
    
    esp.VelLine.Thickness = 2
    esp.VelLine.Color = Color3.fromRGB(0, 255, 255)
    esp.VelLine.Visible = false
    
    esp.VelArrow.Filled = true
    esp.VelArrow.Color = Color3.fromRGB(0, 255, 255)
    esp.VelArrow.Visible = false
end

function ESP.hide(esp)
    if not esp then return end
    for _, l in ipairs(esp.Box) do l.Visible = false end
    esp.Name.Visible = false
    esp.Dist.Visible = false
    for _, l in ipairs(esp.Skel) do l.Visible = false end
    esp.HealthBg.Visible = false
    esp.HealthBar.Visible = false
    esp.Offscreen.Visible = false
    esp.VelLine.Visible = false
    esp.VelArrow.Visible = false
end

function ESP.destroy(esp)
    if not esp then return end
    pcall(function()
        for _, l in ipairs(esp.Box) do l:Remove() end
        esp.Name:Remove()
        esp.Dist:Remove()
        for _, l in ipairs(esp.Skel) do l:Remove() end
        esp.HealthBg:Remove()
        esp.HealthBar:Remove()
        esp.Offscreen:Remove()
        esp.VelLine:Remove()
        esp.VelArrow:Remove()
    end)
end

function ESP.hideAll()
    for _, esp in pairs(ESP.cache) do
        ESP.hide(esp)
    end
end

function ESP.cleanup()
    local validPlayers = {}
    for _, p in ipairs(Players:GetPlayers()) do
        validPlayers[p] = true
    end
    for player, esp in pairs(ESP.cache) do
        if not validPlayers[player] then
            ESP.hide(esp)
            ESP.destroy(esp)
            ESP.cache[player] = nil
            ESP.velocityData[player] = nil
        end
    end
end

function ESP.createObject()
    local box = {}
    for i = 1, 4 do
        box[i] = Drawing.new("Line")
        box[i].Thickness = 1
        box[i].Visible = false
    end
    
    return {
        Box = box,
        Label = Drawing.new("Text"),
        Dist = Drawing.new("Text")
    }
end

function ESP.setupObject(esp)
    for _, l in ipairs(esp.Box) do
        l.Thickness = 1
        l.Visible = false
    end
    
    esp.Label.Size = 13
    esp.Label.Font = Drawing.Fonts.Monospace
    esp.Label.Center = true
    esp.Label.Outline = true
    esp.Label.Visible = false
    
    esp.Dist.Size = 11
    esp.Dist.Font = Drawing.Fonts.Monospace
    esp.Dist.Center = true
    esp.Dist.Outline = true
    esp.Dist.Color = Color3.fromRGB(160, 160, 160)
    esp.Dist.Visible = false
end

function ESP.hideObject(esp)
    if not esp then return end
    for _, l in ipairs(esp.Box) do l.Visible = false end
    esp.Label.Visible = false
    esp.Dist.Visible = false
end

function ESP.destroyObject(esp)
    if not esp then return end
    pcall(function()
        for _, l in ipairs(esp.Box) do l:Remove() end
        esp.Label:Remove()
        esp.Dist:Remove()
    end)
end

function ESP.render(esp, player, char, cam, screenSize, screenCenter)
    local root = char:FindFirstChild("HumanoidRootPart")
    local head = char:FindFirstChild("Head")
    local hum = char:FindFirstChildOfClass("Humanoid")
    
    if not root or not head then
        ESP.hide(esp)
        return
    end
    
    local myRoot = GetCharacterRoot()
    local dist = myRoot and (root.Position - myRoot.Position).Magnitude or 0
    
    if dist > Config.ESP_MaxDist then
        ESP.hide(esp)
        return
    end
    
    local isKillerPlayer = IsKiller(player)
    local visible = Cache.Visibility[player]
    local col = isKillerPlayer and (visible and Colors.KillerVis or Colors.Killer) or (visible and Colors.SurvivorVis or Colors.Survivor)
    local skelCol = visible and Colors.SkeletonVis or Colors.Skeleton
    
    local headPos = head.Position + Vector3.new(0, 0.5, 0)
    local feetPos = root.Position - Vector3.new(0, 3, 0)
    
    local rs = cam:WorldToViewportPoint(root.Position)
    local hs = cam:WorldToViewportPoint(headPos)
    local fs = cam:WorldToViewportPoint(feetPos)
    
    local onScreen = rs.Z > 0 and rs.X > 0 and rs.X < screenSize.X and rs.Y > 0 and rs.Y < screenSize.Y
    
    if not onScreen then
        for _, l in ipairs(esp.Box) do l.Visible = false end
        esp.Name.Visible = false
        esp.Dist.Visible = false
        for _, l in ipairs(esp.Skel) do l.Visible = false end
        esp.HealthBg.Visible = false
        esp.HealthBar.Visible = false
        esp.VelLine.Visible = false
        esp.VelArrow.Visible = false
        
        if Config.ESP_Offscreen and visible then
            local dx = rs.X - screenCenter.X
            local dy = rs.Y - screenCenter.Y
            local angle = math.atan2(dy, dx)
            local edge = 50
            local arrowX = math.clamp(screenCenter.X + math.cos(angle) * (screenSize.X/2 - edge), edge, screenSize.X - edge)
            local arrowY = math.clamp(screenCenter.Y + math.sin(angle) * (screenSize.Y/2 - edge), edge, screenSize.Y - edge)
            local fwd = Vector2.new(math.cos(angle), math.sin(angle))
            local right = Vector2.new(-fwd.Y, fwd.X)
            local pos = Vector2.new(arrowX, arrowY)
            local arrowSize = 12
            esp.Offscreen.PointA = pos + fwd * arrowSize
            esp.Offscreen.PointB = pos - fwd * arrowSize/2 - right * arrowSize/2
            esp.Offscreen.PointC = pos - fwd * arrowSize/2 + right * arrowSize/2
            esp.Offscreen.Color = col
            esp.Offscreen.Visible = true
        else
            esp.Offscreen.Visible = false
        end
        return
    end
    
    esp.Offscreen.Visible = false
    
    local boxTop = hs.Y
    local boxBottom = fs.Y
    local boxHeight = math.abs(boxBottom - boxTop)
    local boxWidth = boxHeight * 0.6
    local cx = rs.X
    
    esp.Box[1].From = Vector2.new(cx - boxWidth/2, boxTop)
    esp.Box[1].To = Vector2.new(cx + boxWidth/2, boxTop)
    esp.Box[2].From = Vector2.new(cx + boxWidth/2, boxTop)
    esp.Box[2].To = Vector2.new(cx + boxWidth/2, boxBottom)
    esp.Box[3].From = Vector2.new(cx + boxWidth/2, boxBottom)
    esp.Box[3].To = Vector2.new(cx - boxWidth/2, boxBottom)
    esp.Box[4].From = Vector2.new(cx - boxWidth/2, boxBottom)
    esp.Box[4].To = Vector2.new(cx - boxWidth/2, boxTop)
    for _, l in ipairs(esp.Box) do
        l.Color = col
        l.Visible = true
    end
    
    if Config.ESP_Names then
        esp.Name.Text = player.Name
        esp.Name.Position = Vector2.new(cx, boxTop - 18)
        esp.Name.Color = col
        esp.Name.Visible = true
    else
        esp.Name.Visible = false
    end
    
    if Config.ESP_Distance then
        esp.Dist.Text = math.floor(dist) .. "m"
        esp.Dist.Position = Vector2.new(cx, boxBottom + 4)
        esp.Dist.Visible = true
    else
        esp.Dist.Visible = false
    end
    
    if Config.ESP_Health and hum then
        local pct = math.clamp(hum.Health / hum.MaxHealth, 0, 1)
        local barX = cx - boxWidth/2 - 6
        local barH = boxHeight * pct
        
        esp.HealthBg.Position = Vector2.new(barX - 1, boxTop - 1)
        esp.HealthBg.Size = Vector2.new(5, boxHeight + 2)
        esp.HealthBg.Visible = true
        
        esp.HealthBar.Position = Vector2.new(barX, boxBottom - barH)
        esp.HealthBar.Size = Vector2.new(3, barH)
        esp.HealthBar.Color = pct > 0.6 and Colors.HealthHigh or pct > 0.3 and Colors.HealthMid or Colors.HealthLow
        esp.HealthBar.Visible = true
    else
        esp.HealthBg.Visible = false
        esp.HealthBar.Visible = false
    end
    
    if Config.ESP_Skeleton then
        local bones = IsR6(char) and Bones_R6 or Bones_R15
        for i, b in ipairs(bones) do
            if esp.Skel[i] then
                local p1 = char:FindFirstChild(b[1])
                local p2 = char:FindFirstChild(b[2])
                if p1 and p2 then
                    local s1 = cam:WorldToViewportPoint(p1.Position)
                    local s2 = cam:WorldToViewportPoint(p2.Position)
                    if s1.Z > 0 and s2.Z > 0 then
                        esp.Skel[i].From = Vector2.new(s1.X, s1.Y)
                        esp.Skel[i].To = Vector2.new(s2.X, s2.Y)
                        esp.Skel[i].Color = skelCol
                        esp.Skel[i].Visible = true
                    else
                        esp.Skel[i].Visible = false
                    end
                else
                    esp.Skel[i].Visible = false
                end
            end
        end
        for i = #bones + 1, #esp.Skel do
            if esp.Skel[i] then esp.Skel[i].Visible = false end
        end
    else
        for _, l in ipairs(esp.Skel) do l.Visible = false end
    end
    
    local vd = ESP.velocityData[player]
    if not vd then
        vd = {pos = root.Position, vel = Vector3.zero, time = tick()}
        ESP.velocityData[player] = vd
    end
    local now = tick()
    local dt = now - vd.time
    if dt > 0.03 then
        local rawVel = (root.Position - vd.pos) / dt
        vd.vel = vd.vel * 0.7 + rawVel * 0.3
        vd.pos = root.Position
        vd.time = now
    end
    
    if Config.ESP_Velocity then
        local velFlat = Vector3.new(vd.vel.X, 0, vd.vel.Z)
        local velMag = velFlat.Magnitude
        if velMag > 2 then
            local futurePos = root.Position + velFlat.Unit * math.clamp(velMag * 0.4, 5, 20)
            local futureScreen, futureOn = cam:WorldToViewportPoint(futurePos)
            if futureOn and futureScreen.Z > 0 then
                esp.VelLine.From = Vector2.new(rs.X, rs.Y)
                esp.VelLine.To = Vector2.new(futureScreen.X, futureScreen.Y)
                esp.VelLine.Visible = true
                local dx, dy = futureScreen.X - rs.X, futureScreen.Y - rs.Y
                local len = math.sqrt(dx*dx + dy*dy)
                if len > 5 then
                    local fx, fy = dx/len, dy/len
                    esp.VelArrow.PointA = Vector2.new(futureScreen.X, futureScreen.Y)
                    esp.VelArrow.PointB = Vector2.new(futureScreen.X - fx*10 + fy*5, futureScreen.Y - fy*10 - fx*5)
                    esp.VelArrow.PointC = Vector2.new(futureScreen.X - fx*10 - fy*5, futureScreen.Y - fy*10 + fx*5)
                    esp.VelArrow.Visible = true
                else
                    esp.VelArrow.Visible = false
                end
            else
                esp.VelLine.Visible = false
                esp.VelArrow.Visible = false
            end
        else
            esp.VelLine.Visible = false
            esp.VelArrow.Visible = false
        end
    else
        esp.VelLine.Visible = false
        esp.VelArrow.Visible = false
    end
end

function ESP.renderObject(esp, pos, label, color, cam)
    local myRoot = GetCharacterRoot()
    local dist = myRoot and (pos - myRoot.Position).Magnitude or 0
    
    if dist > Config.ESP_MaxDist then
        ESP.hideObject(esp)
        return
    end
    
    local screen = cam:WorldToViewportPoint(pos)
    if screen.Z <= 0 then
        ESP.hideObject(esp)
        return
    end
    
    local size = math.clamp(800 / screen.Z, 16, 60)
    
    esp.Box[1].From = Vector2.new(screen.X - size/2, screen.Y - size/2)
    esp.Box[1].To = Vector2.new(screen.X + size/2, screen.Y - size/2)
    esp.Box[2].From = Vector2.new(screen.X + size/2, screen.Y - size/2)
    esp.Box[2].To = Vector2.new(screen.X + size/2, screen.Y + size/2)
    esp.Box[3].From = Vector2.new(screen.X + size/2, screen.Y + size/2)
    esp.Box[3].To = Vector2.new(screen.X - size/2, screen.Y + size/2)
    esp.Box[4].From = Vector2.new(screen.X - size/2, screen.Y + size/2)
    esp.Box[4].To = Vector2.new(screen.X - size/2, screen.Y - size/2)
    for _, l in ipairs(esp.Box) do
        l.Color = color
        l.Visible = true
    end
    
    esp.Label.Text = label
    esp.Label.Position = Vector2.new(screen.X, screen.Y - size/2 - 14)
    esp.Label.Color = color
    esp.Label.Visible = true
    
    if Config.ESP_Distance then
        esp.Dist.Text = math.floor(dist) .. "m"
        esp.Dist.Position = Vector2.new(screen.X, screen.Y + size/2 + 2)
        esp.Dist.Visible = true
    else
        esp.Dist.Visible = false
    end
end

function ESP.step(cam, screenSize, screenCenter)
    if not Config.ESP_Enabled then
        ESP.hideAll()
        return
    end
    
    ESP.cleanup()
    
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer then
            local char = player.Character
            if not char or not char:FindFirstChild("HumanoidRootPart") then
                if ESP.cache[player] then ESP.hide(ESP.cache[player]) end
            else
                local isKillerPlayer = IsKiller(player)
                local shouldShow = (isKillerPlayer and Config.ESP_Killer) or (not isKillerPlayer and Config.ESP_Survivor)
                
                if not shouldShow then
                    if ESP.cache[player] then ESP.hide(ESP.cache[player]) end
                    Chams.Remove(char)
                else
                    if not Config.ESP_PlayerChams then
                        if not ESP.cache[player] then
                            ESP.cache[player] = ESP.create()
                            ESP.setup(ESP.cache[player])
                        end
                        ESP.render(ESP.cache[player], player, char, cam, screenSize, screenCenter)
                        Chams.Remove(char)
                    else
                        if ESP.cache[player] then ESP.hide(ESP.cache[player]) end
                        local colorData = isKillerPlayer and ChamsColors.Killer or ChamsColors.Survivor
                        local root = char:FindFirstChild("HumanoidRootPart")
                        local dist = root and GetDistance(root.Position) or 0
                        if not Chams.Objects[char] then
                            Chams.Create(char, colorData, player.Name)
                        else
                            Chams.SetColor(char, colorData)
                        end
                        Chams.Update(char, player.Name, dist)
                    end
                end
            end
        end
    end
end


local Radar = {
    bg = Drawing.new("Square"),
    circleBg = Drawing.new("Circle"),
    border = Drawing.new("Square"),
    circleBorder = Drawing.new("Circle"),
    cross1 = Drawing.new("Line"),
    cross2 = Drawing.new("Line"),
    center = Drawing.new("Triangle"),
    dots = {},
    objectDots = {},
    palletSquares = {}
}

do
    Radar.bg.Filled = true
    Radar.bg.Color = Colors.RadarBg
    Radar.bg.Transparency = 0.8
    Radar.circleBg.Filled = true
    Radar.circleBg.Color = Colors.RadarBg
    Radar.circleBg.Transparency = 0.8
    Radar.circleBg.NumSides = 64
    Radar.border.Filled = false
    Radar.border.Color = Colors.RadarBorder
    Radar.border.Thickness = 2
    Radar.circleBorder.Filled = false
    Radar.circleBorder.Color = Colors.RadarBorder
    Radar.circleBorder.Thickness = 2
    Radar.circleBorder.NumSides = 64
    Radar.cross1.Color = Color3.fromRGB(40, 40, 40)
    Radar.cross1.Thickness = 1
    Radar.cross2.Color = Color3.fromRGB(40, 40, 40)
    Radar.cross2.Thickness = 1
    Radar.center.Filled = true
    Radar.center.Color = Colors.RadarYou
    for i = 1, 100 do
        local d = Drawing.new("Triangle")
        d.Filled = true
        d.Visible = false
        Radar.dots[i] = d
    end
    for i = 1, 100 do
        local d = Drawing.new("Circle")
        d.Filled = true
        d.Visible = false
        d.NumSides = 16
        Radar.objectDots[i] = d
    end
    for i = 1, 100 do
        local d = Drawing.new("Square")
        d.Filled = true
        d.Visible = false
        Radar.palletSquares[i] = d
    end
end

function Radar.hideAll()
    Radar.bg.Visible = false
    Radar.circleBg.Visible = false
    Radar.border.Visible = false
    Radar.circleBorder.Visible = false
    Radar.center.Visible = false
    Radar.cross1.Visible = false
    Radar.cross2.Visible = false
    for _, d in pairs(Radar.dots) do d.Visible = false end
    for _, d in pairs(Radar.objectDots) do d.Visible = false end
    for _, d in pairs(Radar.palletSquares) do d.Visible = false end
end

function Radar.step(cam)
    if not Config.RADAR_Enabled then
        Radar.hideAll()
        return
    end
    
    local size = Config.RADAR_Size
    local pos = Vector2.new(cam.ViewportSize.X - size - 20, 20)
    local center = pos + Vector2.new(size/2, size/2)
    
    if Config.RADAR_Circle then
        Radar.bg.Visible = false
        Radar.border.Visible = false
        Radar.circleBg.Position = center
        Radar.circleBg.Radius = size/2
        Radar.circleBg.Visible = true
        Radar.circleBorder.Position = center
        Radar.circleBorder.Radius = size/2
        Radar.circleBorder.Visible = true
    else
        Radar.circleBg.Visible = false
        Radar.circleBorder.Visible = false
        Radar.bg.Position = pos
        Radar.bg.Size = Vector2.new(size, size)
        Radar.bg.Visible = true
        Radar.border.Position = pos
        Radar.border.Size = Vector2.new(size, size)
        Radar.border.Visible = true
    end
    
    Radar.cross1.From = Vector2.new(center.X, pos.Y + 10)
    Radar.cross1.To = Vector2.new(center.X, pos.Y + size - 10)
    Radar.cross1.Visible = true
    Radar.cross2.From = Vector2.new(pos.X + 10, center.Y)
    Radar.cross2.To = Vector2.new(pos.X + size - 10, center.Y)
    Radar.cross2.Visible = true
    
    local myChar = LocalPlayer.Character
    local myRoot = myChar and myChar:FindFirstChild("HumanoidRootPart")
    local myLook = cam.CFrame.LookVector
    if not myRoot then
        Radar.center.Visible = false
        for _, d in pairs(Radar.dots) do d.Visible = false end
        for _, d in pairs(Radar.objectDots) do d.Visible = false end
        for _, d in pairs(Radar.palletSquares) do d.Visible = false end
        return
    end
    
    local myAngle = math.atan2(-myLook.X, -myLook.Z)
    local cosA, sinA = math.cos(myAngle), math.sin(myAngle)
    local scale = (size/2 - 10) / Tuning.RadarRange
    local idx = 1
    local objIdx = 1
    local palletIdx = 1
    
    if Config.RADAR_Killer then
        for _, player in ipairs(Players:GetPlayers()) do
            if player == LocalPlayer then continue end
            if idx > #Radar.dots then break end
            if not IsKiller(player) then continue end
            local char = player.Character
            if char then
                local root = char:FindFirstChild("HumanoidRootPart")
                if root then
                    local rx, rz = root.Position.X - myRoot.Position.X, root.Position.Z - myRoot.Position.Z
                    local dist2D = math.sqrt(rx^2 + rz^2)
                    if dist2D < Tuning.RadarRange then
                        local rotX = rx * cosA - rz * sinA
                        local rotZ = rx * sinA + rz * cosA
                        local radarX, radarY = rotX * scale, rotZ * scale
                        local maxD = size/2 - 8
                        local rDist = math.sqrt(radarX^2 + radarY^2)
                        if rDist > maxD then
                            radarX, radarY = radarX/rDist*maxD, radarY/rDist*maxD
                        end
                        local dotPos = center + Vector2.new(radarX, radarY)
                        local dot = Radar.dots[idx]
                        local head = char:FindFirstChild("Head")
                        local eAngle = head and math.atan2(-head.CFrame.LookVector.X, -head.CFrame.LookVector.Z) - myAngle or 0
                        local eFwd = Vector2.new(-math.sin(eAngle), -math.cos(eAngle))
                        local eRight = Vector2.new(-eFwd.Y, eFwd.X)
                        dot.PointA = dotPos + eFwd * Tuning.RadarDotSize
                        dot.PointB = dotPos - eFwd * Tuning.RadarDotSize/2 + eRight * Tuning.RadarDotSize/2
                        dot.PointC = dotPos - eFwd * Tuning.RadarDotSize/2 - eRight * Tuning.RadarDotSize/2
                        dot.Color = Colors.Killer
                        dot.Visible = true
                        idx = idx + 1
                    end
                end
            end
        end
    end
    
    if Config.RADAR_Survivor then
        for _, player in ipairs(Players:GetPlayers()) do
            if player == LocalPlayer then continue end
            if idx > #Radar.dots then break end
            if not IsSurvivor(player) then continue end
            local char = player.Character
            if char then
                local root = char:FindFirstChild("HumanoidRootPart")
                if root then
                    local rx, rz = root.Position.X - myRoot.Position.X, root.Position.Z - myRoot.Position.Z
                    local dist2D = math.sqrt(rx^2 + rz^2)
                    if dist2D < Tuning.RadarRange then
                        local rotX = rx * cosA - rz * sinA
                        local rotZ = rx * sinA + rz * cosA
                        local radarX, radarY = rotX * scale, rotZ * scale
                        local maxD = size/2 - 8
                        local rDist = math.sqrt(radarX^2 + radarY^2)
                        if rDist > maxD then
                            radarX, radarY = radarX/rDist*maxD, radarY/rDist*maxD
                        end
                        local dotPos = center + Vector2.new(radarX, radarY)
                        local dot = Radar.dots[idx]
                        local head = char:FindFirstChild("Head")
                        local eAngle = head and math.atan2(-head.CFrame.LookVector.X, -head.CFrame.LookVector.Z) - myAngle or 0
                        local eFwd = Vector2.new(-math.sin(eAngle), -math.cos(eAngle))
                        local eRight = Vector2.new(-eFwd.Y, eFwd.X)
                        dot.PointA = dotPos + eFwd * Tuning.RadarDotSize
                        dot.PointB = dotPos - eFwd * Tuning.RadarDotSize/2 + eRight * Tuning.RadarDotSize/2
                        dot.PointC = dotPos - eFwd * Tuning.RadarDotSize/2 - eRight * Tuning.RadarDotSize/2
                        dot.Color = Colors.Survivor
                        dot.Visible = true
                        idx = idx + 1
                    end
                end
            end
        end
    end
    
    if Config.RADAR_Generator then
        for _, gen in ipairs(Cache.Generators) do
            if objIdx > #Radar.objectDots then break end
            if gen.part and gen.part.Parent then
                local rx, rz = gen.part.Position.X - myRoot.Position.X, gen.part.Position.Z - myRoot.Position.Z
                local dist2D = math.sqrt(rx^2 + rz^2)
                if dist2D < Tuning.RadarRange then
                    local rotX = rx * cosA - rz * sinA
                    local rotZ = rx * sinA + rz * cosA
                    local radarX, radarY = rotX * scale, rotZ * scale
                    local maxD = size/2 - 8
                    local rDist = math.sqrt(radarX^2 + radarY^2)
                    if rDist > maxD then
                        radarX, radarY = radarX/rDist*maxD, radarY/rDist*maxD
                    end
                    local dotPos = center + Vector2.new(radarX, radarY)
                    local dot = Radar.objectDots[objIdx]
                    dot.Position = dotPos
                    dot.Radius = 3
                    dot.Color = Colors.Generator
                    dot.Visible = true
                    objIdx = objIdx + 1
                end
            end
        end
    end
    
    if Config.RADAR_Pallet then
        for _, pallet in ipairs(Cache.Pallets) do
            if palletIdx > #Radar.palletSquares then break end
            if pallet.part and pallet.part.Parent then
                local rx, rz = pallet.part.Position.X - myRoot.Position.X, pallet.part.Position.Z - myRoot.Position.Z
                local dist2D = math.sqrt(rx^2 + rz^2)
                if dist2D < Tuning.RadarRange then
                    local rotX = rx * cosA - rz * sinA
                    local rotZ = rx * sinA + rz * cosA
                    local radarX, radarY = rotX * scale, rotZ * scale
                    local maxD = size/2 - 8
                    local rDist = math.sqrt(radarX^2 + radarY^2)
                    if rDist > maxD then
                        radarX, radarY = radarX/rDist*maxD, radarY/rDist*maxD
                    end
                    local dotPos = center + Vector2.new(radarX, radarY)
                    local square = Radar.palletSquares[palletIdx]
                    local squareSize = 5
                    square.Position = dotPos - Vector2.new(squareSize/2, squareSize/2)
                    square.Size = Vector2.new(squareSize, squareSize)
                    square.Color = Colors.Pallet
                    square.Visible = true
                    palletIdx = palletIdx + 1
                end
            end
        end
    end
    
    for i = idx, #Radar.dots do Radar.dots[i].Visible = false end
    for i = objIdx, #Radar.objectDots do Radar.objectDots[i].Visible = false end
    for i = palletIdx, #Radar.palletSquares do Radar.palletSquares[i].Visible = false end
    
    Radar.center.PointA = center + Vector2.new(0, -Tuning.RadarArrowSize)
    Radar.center.PointB = center + Vector2.new(-Tuning.RadarArrowSize/2, Tuning.RadarArrowSize/2)
    Radar.center.PointC = center + Vector2.new(Tuning.RadarArrowSize/2, Tuning.RadarArrowSize/2)
    Radar.center.Visible = true
end


local Aimbot = {}

function Aimbot.GetTargetPart(char)
    if not char then return nil end
    local partName = Config.AIM_TargetPart
    if partName == "Head" then
        return char:FindFirstChild("Head")
    elseif partName == "Torso" then
        return char:FindFirstChild("UpperTorso") or char:FindFirstChild("Torso")
    else
        return char:FindFirstChild("HumanoidRootPart")
    end
end

function Aimbot.GetClosestTarget(cam, screenCenter)
    if not cam then return nil end
    
    local myRole = GetRole()
    local closestPlayer = nil
    local closestDist = Config.AIM_FOV
    
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character and player.Team then
           
            local shouldTarget = false
            if myRole == "Survivor" and IsKiller(player) then
                shouldTarget = true
            elseif myRole == "Killer" and IsSurvivor(player) then
                shouldTarget = true
            end
            
            if shouldTarget then
                local targetPart = Aimbot.GetTargetPart(player.Character)
                if targetPart then
               
                    local passVisCheck = true
                    if Config.AIM_VisCheck and not Cache.Visibility[player] then
                        passVisCheck = false
                    end
                    
                    if passVisCheck then
                        local screenPos, onScreen, depth = WorldToScreen(targetPart.Position)
                        if onScreen and depth > 0 then
                            local dist = (screenPos - screenCenter).Magnitude
                            if dist < closestDist then
                                closestDist = dist
                                closestPlayer = player
                            end
                        end
                    end
                end
            end
        end
    end
    
    return closestPlayer
end

function Aimbot.GetPredictedPosition(target, targetPart)
    if not target or not targetPart then return nil end
    
    local pos = targetPart.Position
    
    if Config.AIM_Predict then
        local root = target.Character and target.Character:FindFirstChild("HumanoidRootPart")
        if root then
            local velocity = root.Velocity
            
            pos = pos + velocity * 0.1
        end
    end
    
    return pos
end

function Aimbot.AimAt(cam, targetPos)
    if not cam or not targetPos then return end
    
    local currentCF = cam.CFrame
    local targetCF = CFrame.new(currentCF.Position, targetPos)
    
    local smooth = Config.AIM_Smooth
    cam.CFrame = currentCF:Lerp(targetCF, smooth)
end

function Aimbot.Update(cam, screenSize, screenCenter)
    if not Config.AIM_Enabled then
        State.AimTarget = nil
        return
    end
    
    
    if not State.AimHolding then
        State.AimTarget = nil
        return
    end
    
   
    local target = Aimbot.GetClosestTarget(cam, screenCenter)
    State.AimTarget = target
    
    if target and target.Character then
        local targetPart = Aimbot.GetTargetPart(target.Character)
        if targetPart then
            local predictedPos = Aimbot.GetPredictedPosition(target, targetPart)
            if predictedPos then
                Aimbot.AimAt(cam, predictedPos)
            end
        end
    end
end


local function ScanMap()
    local map = Workspace:FindFirstChild("Map")
    if not map then 
        Cache.Generators = {}
        Cache.Gates = {}
        Cache.Hooks = {}
        Cache.Pallets = {}
        Cache.Windows = {}
        return 
    end
    
    local newGenerators = {}
    local newGates = {}
    local newHooks = {}
    local newPallets = {}
    local newWindows = {}
    
    for _, obj in ipairs(map:GetDescendants()) do
        if obj:IsA("Model") then
            local part = obj:FindFirstChildWhichIsA("BasePart")
            if part then
                if obj.Name == "Generator" then
                    table.insert(newGenerators, {model = obj, part = part})
                elseif obj.Name == "Gate" then
                    table.insert(newGates, {model = obj, part = part})
                elseif obj.Name == "Hook" then
                    table.insert(newHooks, {model = obj, part = part})
                elseif obj.Name == "Palletwrong" or obj.Name:lower():find("pallet") then
                    table.insert(newPallets, {model = obj, part = part})
                elseif obj.Name == "Window" then
                    table.insert(newWindows, {model = obj, part = part})
                end
            end
        end
    end
    
    Cache.Generators = newGenerators
    Cache.Gates = newGates
    Cache.Hooks = newHooks
    Cache.Pallets = newPallets
    Cache.Windows = newWindows
    
    local root = GetCharacterRoot()
    if root and #Cache.Hooks > 0 then
        local closest, closestDist = nil, math.huge
        for _, hook in ipairs(Cache.Hooks) do
            if hook.part then
                local d = (hook.part.Position - root.Position).Magnitude
                if d < closestDist then
                    closestDist = d
                    closest = hook
                end
            end
        end
        Cache.ClosestHook = closest
    end
end

local function UpdateVisibility()
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character then
            Cache.Visibility[player] = IsVisible(player.Character)
        end
    end
end


local function UpdateObjectESP(cam)
    
    for _, esp in pairs(ESP.objectCache) do
        ESP.hideObject(esp)
    end
    
 
    for _, obj in ipairs(Cache.Generators) do
        local target = obj.model or obj.part
        if Config.ESP_Generator and obj.part and obj.part.Parent then
            if Config.ESP_ObjectChams then
                if not Chams.Objects[target] then
                    Chams.Create(target, ChamsColors.Generator, "GEN")
                end
                Chams.Update(target, "GEN", GetDistance(obj.part.Position))
            else
                local key = tostring(target)
                if not ESP.objectCache[key] then
                    ESP.objectCache[key] = ESP.createObject()
                    ESP.setupObject(ESP.objectCache[key])
                end
                ESP.renderObject(ESP.objectCache[key], obj.part.Position, "GEN", Colors.Generator, cam)
                Chams.Remove(target)
            end
        else
            Chams.Remove(target)
        end
    end
    
   
    for _, obj in ipairs(Cache.Gates) do
        local target = obj.model or obj.part
        if Config.ESP_Gate and obj.part and obj.part.Parent then
            if Config.ESP_ObjectChams then
                if not Chams.Objects[target] then
                    Chams.Create(target, ChamsColors.Gate, "GATE")
                end
                Chams.Update(target, "GATE", GetDistance(obj.part.Position))
            else
                local key = tostring(target)
                if not ESP.objectCache[key] then
                    ESP.objectCache[key] = ESP.createObject()
                    ESP.setupObject(ESP.objectCache[key])
                end
                ESP.renderObject(ESP.objectCache[key], obj.part.Position, "GATE", Colors.Gate, cam)
                Chams.Remove(target)
            end
        else
            Chams.Remove(target)
        end
    end
    
   
    for _, obj in ipairs(Cache.Hooks) do
        local target = obj.model or obj.part
        local isClosest = Config.ESP_ClosestHook and obj == Cache.ClosestHook
        if Config.ESP_Hook and obj.part and obj.part.Parent then
            local useColor = isClosest and Colors.HookClose or Colors.Hook
            local useChams = isClosest and ChamsColors.HookClose or ChamsColors.Hook
            local useLabel = isClosest and "HOOK!" or "HOOK"
            if Config.ESP_ObjectChams then
                if not Chams.Objects[target] then
                    Chams.Create(target, useChams, useLabel)
                else
                    Chams.SetColor(target, useChams)
                end
                Chams.Update(target, useLabel, GetDistance(obj.part.Position))
            else
                local key = tostring(target)
                if not ESP.objectCache[key] then
                    ESP.objectCache[key] = ESP.createObject()
                    ESP.setupObject(ESP.objectCache[key])
                end
                ESP.renderObject(ESP.objectCache[key], obj.part.Position, useLabel, useColor, cam)
                Chams.Remove(target)
            end
        else
            Chams.Remove(target)
        end
    end
    
  
    for _, obj in ipairs(Cache.Pallets) do
        local target = obj.model or obj.part
        if Config.ESP_Pallet and obj.part and obj.part.Parent then
            if Config.ESP_ObjectChams then
                if not Chams.Objects[target] then
                    Chams.Create(target, ChamsColors.Pallet, "PALLET")
                end
                Chams.Update(target, "PALLET", GetDistance(obj.part.Position))
            else
                local key = tostring(target)
                if not ESP.objectCache[key] then
                    ESP.objectCache[key] = ESP.createObject()
                    ESP.setupObject(ESP.objectCache[key])
                end
                ESP.renderObject(ESP.objectCache[key], obj.part.Position, "PALLET", Colors.Pallet, cam)
                Chams.Remove(target)
            end
        else
            Chams.Remove(target)
        end
    end
    
  
    for _, obj in ipairs(Cache.Windows) do
        local target = obj.model or obj.part
        if Config.ESP_Window and obj.part and obj.part.Parent then
            if Config.ESP_ObjectChams then
                if not Chams.Objects[target] then
                    Chams.Create(target, ChamsColors.Window, "WINDOW")
                end
                Chams.Update(target, "WINDOW", GetDistance(obj.part.Position))
            else
                local key = tostring(target)
                if not ESP.objectCache[key] then
                    ESP.objectCache[key] = ESP.createObject()
                    ESP.setupObject(ESP.objectCache[key])
                end
                ESP.renderObject(ESP.objectCache[key], obj.part.Position, "WINDOW", Colors.Window, cam)
                Chams.Remove(target)
            end
        else
            Chams.Remove(target)
        end
    end
end


local function StopAutoGen()
    Config.AUTO_Generator = false
    
    pcall(function()
        local char = LocalPlayer.Character
        if not char then return end
        local root = char:FindFirstChild("HumanoidRootPart")
        local humanoid = char:FindFirstChildOfClass("Humanoid")
        
        
        if root then
            local map = Workspace:FindFirstChild("Map")
            if map then
                for _, obj in ipairs(map:GetDescendants()) do
                    if obj:IsA("Model") and obj.Name == "Generator" then
                        local genPart = obj:FindFirstChildWhichIsA("BasePart")
                        if genPart then
                            local dist = (genPart.Position - root.Position).Magnitude
                            if dist < 25 then
                                local dir = (root.Position - genPart.Position).Unit
                                if dir.Magnitude ~= dir.Magnitude then dir = Vector3.new(1, 0, 0) end
                                root.CFrame = CFrame.new(root.Position + dir * 20 + Vector3.new(0, 3, 0))
                                break
                            end
                        end
                    end
                end
            end
        end
        
        
        if humanoid then
            humanoid:ChangeState(Enum.HumanoidStateType.GettingUp)
            humanoid.PlatformStand = false
            humanoid.Sit = false
            humanoid.WalkSpeed = State.OriginalSpeed or 16
            humanoid.JumpPower = 50
        end
        
       
        local animator = humanoid and humanoid:FindFirstChildOfClass("Animator")
        if animator then
            for _, track in pairs(animator:GetPlayingAnimationTracks()) do
                track:Stop(0)
            end
        end
        
       
        for _, part in ipairs(char:GetDescendants()) do
            if part:IsA("BasePart") then
                part.CanCollide = true
            end
        end
        
        
        if root then
            root.Velocity = Vector3.new(0, 30, 0)
            root.RotVelocity = Vector3.new(0, 0, 0)
        end
    end)
end

local function LeaveGenerator()
    local root = GetCharacterRoot()
    if not root then return false end
    
    local nearestGen, nearestDist = nil, math.huge
    for _, gen in ipairs(Cache.Generators) do
        local dist = GetDistance(gen.part.Position)
        if dist < nearestDist then
            nearestDist = dist
            nearestGen = gen
        end
    end
    
    if not nearestGen or nearestDist > Config.AUTO_LeaveDist then return false end
    
    local direction = (root.Position - nearestGen.part.Position).Unit
    local escapePos = root.Position + direction * (Config.AUTO_LeaveDist + 10)
    
    if true then
        for _, part in ipairs(LocalPlayer.Character:GetDescendants()) do
            if part:IsA("BasePart") then part.CanCollide = false end
        end
    end
    
    root.CFrame = CFrame.new(escapePos + Vector3.new(0, Config.TP_Offset, 0))
    
    if true then
        task.delay(0.3, function()
            if LocalPlayer.Character then
                for _, part in ipairs(LocalPlayer.Character:GetDescendants()) do
                    if part:IsA("BasePart") and part.Name ~= "HumanoidRootPart" then
                        part.CanCollide = true
                    end
                end
            end
        end)
    end
    
    return true
end

local function TeleportToGenerator(index)
    if #Cache.Generators == 0 then return false end
    
    local sorted = {}
    for _, gen in ipairs(Cache.Generators) do
        table.insert(sorted, {gen = gen, dist = GetDistance(gen.part.Position)})
    end
    table.sort(sorted, function(a, b) return a.dist < b.dist end)
    
    local target = sorted[index or 1]
    if not target then return false end
    
    local root = GetCharacterRoot()
    if not root then return false end
    
    if true then
        for _, part in ipairs(LocalPlayer.Character:GetDescendants()) do
            if part:IsA("BasePart") then part.CanCollide = false end
        end
    end
    
    root.CFrame = target.gen.part.CFrame + Vector3.new(0, Config.TP_Offset, 0)
    
    if true then
        task.delay(0.3, function()
            if LocalPlayer.Character then
                for _, part in ipairs(LocalPlayer.Character:GetDescendants()) do
                    if part:IsA("BasePart") and part.Name ~= "HumanoidRootPart" then
                        part.CanCollide = true
                    end
                end
            end
        end)
    end
    
    return true
end

local function TeleportToGate()
    if #Cache.Gates == 0 then return false end
    
    local closest, closestDist = nil, math.huge
    for _, gate in ipairs(Cache.Gates) do
        local dist = GetDistance(gate.part.Position)
        if dist < closestDist then
            closestDist = dist
            closest = gate
        end
    end
    
    if not closest then return false end
    
    local root = GetCharacterRoot()
    if not root then return false end
    
    if true then
        for _, part in ipairs(LocalPlayer.Character:GetDescendants()) do
            if part:IsA("BasePart") then part.CanCollide = false end
        end
    end
    
    root.CFrame = closest.part.CFrame + Vector3.new(0, Config.TP_Offset, 0)
    
    if true then
        task.delay(0.3, function()
            if LocalPlayer.Character then
                for _, part in ipairs(LocalPlayer.Character:GetDescendants()) do
                    if part:IsA("BasePart") and part.Name ~= "HumanoidRootPart" then
                        part.CanCollide = true
                    end
                end
            end
        end)
    end
    
    return true
end

local function TeleportToHook()
    if not Cache.ClosestHook then return false end
    
    local root = GetCharacterRoot()
    if not root then return false end
    
    if true then
        for _, part in ipairs(LocalPlayer.Character:GetDescendants()) do
            if part:IsA("BasePart") then part.CanCollide = false end
        end
    end
    
    root.CFrame = Cache.ClosestHook.part.CFrame + Vector3.new(0, Config.TP_Offset, 0)
    
    if true then
        task.delay(0.3, function()
            if LocalPlayer.Character then
                for _, part in ipairs(LocalPlayer.Character:GetDescendants()) do
                    if part:IsA("BasePart") and part.Name ~= "HumanoidRootPart" then
                        part.CanCollide = true
                    end
                end
            end
        end)
    end
    
    return true
end

local function GetKillerDistance()
    local root = GetCharacterRoot()
    if not root then return math.huge end
    
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and IsKiller(player) then
            local killerRoot = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
            if killerRoot then
                return (killerRoot.Position - root.Position).Magnitude, killerRoot.Position
            end
        end
    end
    return math.huge, nil
end

local function TeleportAway()
    if not Config.AUTO_TeleAway then return end
    if GetRole() == "Killer" then return end 
    
   
    local now = tick()
    if now - State.LastTeleAway < 3 then return end
    
    local root = GetCharacterRoot()
    if not root then return end
    
    local killerDist, killerPos = GetKillerDistance()
    if killerDist > Config.AUTO_TeleAwayDist then return end 
    
    State.LastTeleAway = now
    
   
    local bestSpot = nil
    local bestDist = 0
    
   
    for _, gate in ipairs(Cache.Gates) do
        if gate.part and killerPos then
            local gatePos = gate.part.Position
            local distFromKiller = (gatePos - killerPos).Magnitude
            if distFromKiller > bestDist then
                bestDist = distFromKiller
                bestSpot = gatePos
            end
        end
    end
    
    
    if not bestSpot or bestDist < 50 then
        for _, gen in ipairs(Cache.Generators) do
            if gen.part and killerPos then
                local genPos = gen.part.Position
                local distFromKiller = (genPos - killerPos).Magnitude
                if distFromKiller > bestDist then
                    bestDist = distFromKiller
                    bestSpot = genPos
                end
            end
        end
    end
    
  
    if not bestSpot and killerPos then
        local direction = (root.Position - killerPos).Unit
        bestSpot = root.Position + direction * 80
    end
    
    if bestSpot then
        if true then
            for _, part in ipairs(LocalPlayer.Character:GetDescendants()) do
                if part:IsA("BasePart") then part.CanCollide = false end
            end
        end
        
        root.CFrame = CFrame.new(bestSpot + Vector3.new(0, Config.TP_Offset, 0))
        
        if true then
            task.delay(0.3, function()
                if LocalPlayer.Character then
                    for _, part in ipairs(LocalPlayer.Character:GetDescendants()) do
                        if part:IsA("BasePart") and part.Name ~= "HumanoidRootPart" then
                            part.CanCollide = true
                        end
                    end
                end
            end)
        end
    end
end



local OriginalHitboxSizes = {}

local function UpdateHitboxes()
    if GetRole() ~= "Killer" then
       
        for player, originalSize in pairs(OriginalHitboxSizes) do
            if player and player.Character then
                local root = player.Character:FindFirstChild("HumanoidRootPart")
                if root then
                    root.Size = originalSize
                    root.Transparency = 1
                    root.CanCollide = true
                end
            end
        end
        OriginalHitboxSizes = {}
        return
    end
    
    if not Config.HITBOX_Enabled then
     
        for player, originalSize in pairs(OriginalHitboxSizes) do
            if player and player.Character then
                local root = player.Character:FindFirstChild("HumanoidRootPart")
                if root then
                    root.Size = originalSize
                    root.Transparency = 1
                    root.CanCollide = true
                end
            end
        end
        OriginalHitboxSizes = {}
        return
    end
    
    
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and IsSurvivor(player) then
            local char = player.Character
            if char then
                local root = char:FindFirstChild("HumanoidRootPart")
                local hum = char:FindFirstChildOfClass("Humanoid")
                
                if root and hum and hum.Health > 0 then
                  
                    if not OriginalHitboxSizes[player] then
                        OriginalHitboxSizes[player] = root.Size
                    end
                    
                  
                    local size = Config.HITBOX_Size
                    root.Size = Vector3.new(size, size, size)
                    root.CanCollide = false
                    root.Transparency = 0.7
                elseif root then
                    
                    if OriginalHitboxSizes[player] then
                        root.Size = OriginalHitboxSizes[player]
                        root.Transparency = 1
                        root.CanCollide = true
                        OriginalHitboxSizes[player] = nil
                    end
                end
            end
        end
    end
end


Players.PlayerRemoving:Connect(function(player)
    OriginalHitboxSizes[player] = nil
end)

local function AutoAttack()
    if not Config.AUTO_Attack then return end
    if GetRole() ~= "Killer" then return end
    
    local root = GetCharacterRoot()
    if not root then return end
    
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character then
            local targetRoot = player.Character:FindFirstChild("HumanoidRootPart")
            if targetRoot then
                local dist = (targetRoot.Position - root.Position).Magnitude
                if dist <= Config.AUTO_AttackRange then
                    pcall(function()
                        local remotes = ReplicatedStorage:FindFirstChild("Remotes")
                        if remotes then
                            local attacks = remotes:FindFirstChild("Attacks")
                            if attacks then
                                local basicAttack = attacks:FindFirstChild("BasicAttack")
                                if basicAttack then
                                    basicAttack:FireServer(false)
                                end
                            end
                        end
                    end)
                    break
                end
            end
        end
    end
end


local LastParryTime = 0
local function AutoParry()
    if not Config.AUTO_Parry then return end
    if GetRole() ~= "Survivor" then return end
    if tick() - LastParryTime < 0.5 then return end
    
    local root = GetCharacterRoot()
    if not root then return end
    
   
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and IsKiller(player) and player.Character then
            local killerRoot = player.Character:FindFirstChild("HumanoidRootPart")
            if killerRoot then
                local dist = (killerRoot.Position - root.Position).Magnitude
                if dist <= 15 then
                    pcall(function()
                        local remotes = ReplicatedStorage:FindFirstChild("Remotes")
                        if remotes then
                            local items = remotes:FindFirstChild("Items")
                            if items then
                                local dagger = items:FindFirstChild("Parrying Dagger")
                                if dagger then
                                    local parry = dagger:FindFirstChild("parry")
                                    if parry then
                                        parry:FireServer()
                                        LastParryTime = tick()
                                    end
                                end
                            end
                        end
                    end)
                    break
                end
            end
        end
    end
end

local LastWiggleTime = 0
local function AutoWiggle()
    if not Config.SURV_AutoWiggle then return end
    if GetRole() ~= "Survivor" then return end
    if tick() - LastWiggleTime < 0.3 then return end
    
        pcall(function()
            local remotes = ReplicatedStorage:FindFirstChild("Remotes")
            if remotes then
                local carry = remotes:FindFirstChild("Carry")
                if carry then
                    local selfUnhook = carry:FindFirstChild("SelfUnHookEvent")
                    if selfUnhook then
                        selfUnhook:FireServer()
                    LastWiggleTime = tick()
                    end
                end
            end
        end)
end

local QTEHandler = {
    Monitoring = false,
    FrameConn = nil,
    UIConn = nil,
    Elements = nil
}

local function QTE_SimulateInput()
    local inputMgr = game:GetService("VirtualInputManager")
    inputMgr:SendKeyEvent(true, Enum.KeyCode.Space, false, game)
    task.defer(function()
        inputMgr:SendKeyEvent(false, Enum.KeyCode.Space, false, game)
    end)
end

local function QTE_GetUIElements()
    local pg = LocalPlayer:FindFirstChild("PlayerGui")
    if not pg then return nil end
    local prompt = pg:FindFirstChild("SkillCheckPromptGui")
    if not prompt then return nil end
    local frame = prompt:FindFirstChild("Check")
    if not frame then return nil end
    return {
        frame = frame,
        needle = frame:FindFirstChild("Line"),
        target = frame:FindFirstChild("Goal")
    }
end

local function QTE_IsNeedleInZone(needleAngle, targetAngle)
    local needle = needleAngle % 360
    local target = targetAngle % 360
    local sweetSpotStart = (target + 104) % 360
    local sweetSpotEnd = (target + 114) % 360
    if sweetSpotStart > sweetSpotEnd then
        return needle >= sweetSpotStart or needle <= sweetSpotEnd
    end
    return needle >= sweetSpotStart and needle <= sweetSpotEnd
end

local function QTE_StopMonitoring()
    if QTEHandler.FrameConn then
        QTEHandler.FrameConn:Disconnect()
        QTEHandler.FrameConn = nil
    end
    QTEHandler.Monitoring = false
end

local function QTE_FrameUpdate()
    if not Config.AUTO_SkillCheck or GetRole() ~= "Survivor" then
        QTE_StopMonitoring()
        return
    end
    
    local ui = QTEHandler.Elements
    if not ui or not ui.needle or not ui.target then
        QTE_StopMonitoring()
        return
    end
    
    if QTE_IsNeedleInZone(ui.needle.Rotation, ui.target.Rotation) then
        QTE_SimulateInput()
        QTE_StopMonitoring()
    end
end

local function QTE_StartMonitoring()
    if QTEHandler.Monitoring then return end
    QTEHandler.Monitoring = true
    QTEHandler.FrameConn = RunService.Heartbeat:Connect(QTE_FrameUpdate)
end

local function QTE_OnVisibilityChange()
    if not Config.AUTO_SkillCheck or GetRole() ~= "Survivor" then
        QTE_StopMonitoring()
        return
    end
    
    local ui = QTEHandler.Elements
    if ui and ui.frame and ui.frame.Visible then
        QTE_StartMonitoring()
    else
        QTE_StopMonitoring()
    end
end

local function SetupSkillCheckMonitor()
    pcall(function()
        QTE_StopMonitoring()
        if QTEHandler.UIConn then
            QTEHandler.UIConn:Disconnect()
            QTEHandler.UIConn = nil
        end
        
        local ui = QTE_GetUIElements()
        if not ui or not ui.frame or not ui.needle or not ui.target then return end
        
        QTEHandler.Elements = ui
        QTEHandler.UIConn = ui.frame:GetPropertyChangedSignal("Visible"):Connect(QTE_OnVisibilityChange)
    end)
end

local function DestroyAllPallets()
    if not Config.KILLER_DestroyPallets then return end
    if GetRole() ~= "Killer" then return end
    
    pcall(function()
        local remotes = ReplicatedStorage:FindFirstChild("Remotes")
        if remotes then
            local pallet = remotes:FindFirstChild("Pallet")
            if pallet then
                local jason = pallet:FindFirstChild("Jason")
                if jason then
                   
                    local destroyGlobal = jason:FindFirstChild("Destroy-Global")
                    if destroyGlobal then
                        destroyGlobal:FireServer()
                    end
                    
                    local destroy = jason:FindFirstChild("Destroy")
                    if destroy then
                        local map = workspace:FindFirstChild("Map")
                        if map then
                            for _, obj in ipairs(map:GetDescendants()) do
                                if obj.Name:lower():find("pallet") and obj:IsA("Model") then
                                    destroy:FireServer(obj)
                                end
                            end
                        end
                    end
                end
            end
        end
    end)
end


local LastGenBreakTime = 0
local function FullGenBreak()
    if not Config.KILLER_FullGenBreak then return end
    if GetRole() ~= "Killer" then return end
    if tick() - LastGenBreakTime < 0.3 then return end
    
    local root = GetCharacterRoot()
    if not root then return end
    
    pcall(function()
        local remotes = ReplicatedStorage:FindFirstChild("Remotes")
        if remotes then
            local generator = remotes:FindFirstChild("Generator")
            if generator then
                local breakEvent = generator:FindFirstChild("BreakGenEvent")
                if breakEvent then
                  
                    local map = workspace:FindFirstChild("Map")
                    if map then
                        for _, obj in ipairs(map:GetDescendants()) do
                            if obj.Name:lower():find("generator") or obj.Name:lower():find("gen") then
                                local genPart = obj:IsA("BasePart") and obj or obj:FindFirstChildWhichIsA("BasePart")
                                if genPart then
                                    local dist = (genPart.Position - root.Position).Magnitude
                                    if dist <= 15 then
                                        breakEvent:FireServer(obj)
                                        LastGenBreakTime = tick()
                                    end
                                end
                            end
                        end
                    end
                end
            end
        end
    end)
end

local function UpdateSpeed()
    local char = LocalPlayer.Character
    if not char then return end
    
    local hum = char:FindFirstChildOfClass("Humanoid")
    if not hum then return end
    
    
    if State.OriginalSpeed == 16 and hum.WalkSpeed ~= Config.SPEED_Value then
        State.OriginalSpeed = hum.WalkSpeed
    end
    
    if Config.SPEED_Enabled then
        hum.WalkSpeed = Config.SPEED_Value
    else
        hum.WalkSpeed = State.OriginalSpeed
    end
end

local NoclipWasOn = false

local function UpdateNoclip()
    local char = LocalPlayer.Character
    if not char then return end
    
    if Config.NOCLIP_Enabled then
       
        for _, part in ipairs(char:GetDescendants()) do
            if part:IsA("BasePart") then
                part.CanCollide = false
            end
        end
        NoclipWasOn = true
    elseif NoclipWasOn then
        
        for _, part in ipairs(char:GetDescendants()) do
            if part:IsA("BasePart") and part.Name ~= "HumanoidRootPart" then
                part.CanCollide = true
            end
        end
        NoclipWasOn = false
    end
    
end

local FogCache = {}

local function RemoveFog()
    
    pcall(function()
        local map = Workspace:FindFirstChild("Map")
        if map then
            for _, obj in ipairs(map:GetDescendants()) do
                if obj.Name:lower():find("fog") or obj:IsA("Atmosphere") or obj:IsA("BloomEffect") or obj:IsA("BlurEffect") or obj:IsA("ColorCorrectionEffect") then
                    if not FogCache[obj] then
                        FogCache[obj] = {enabled = obj:IsA("PostEffect") and obj.Enabled or true, parent = obj.Parent}
                    end
                    if obj:IsA("PostEffect") then
                        obj.Enabled = false
                    else
                        obj.Parent = nil
                    end
                end
            end
        end
    end)
    
    
    pcall(function()
        local lighting = game:GetService("Lighting")
        for _, obj in ipairs(lighting:GetChildren()) do
            if obj:IsA("Atmosphere") or obj.Name:lower():find("fog") then
                if not FogCache[obj] then
                    FogCache[obj] = {enabled = obj:IsA("Atmosphere") or true, parent = obj.Parent}
                end
                if obj:IsA("Atmosphere") then
                    obj.Density = 0
                else
                    obj.Parent = nil
                end
            end
        end
        
        lighting.FogEnd = 100000
        lighting.FogStart = 0
    end)
end

local function RestoreFog()
    pcall(function()
        for obj, data in pairs(FogCache) do
            if obj and data.parent then
                if obj:IsA("PostEffect") then
                    obj.Enabled = data.enabled
                else
                    obj.Parent = data.parent
                end
            end
        end
        FogCache = {}
        
        
        local lighting = game:GetService("Lighting")
        lighting.FogEnd = 1000
    end)
end

local function UpdateNoFall()
    if not Config.SURV_NoFall then return end
    
    local char = LocalPlayer.Character
    if not char then return end
    local hum = char:FindFirstChildOfClass("Humanoid")
    if hum then
        hum:SetStateEnabled(Enum.HumanoidStateType.FallingDown, false)
        hum:SetStateEnabled(Enum.HumanoidStateType.Ragdoll, false)
    end
end

local function SetupAntiBlind()
    pcall(function()
        local remotes = ReplicatedStorage:FindFirstChild("Remotes")
        if not remotes then return end
        local items = remotes:FindFirstChild("Items")
        if not items then return end
        local flashlight = items:FindFirstChild("Flashlight")
        if not flashlight then return end
        local gotBlinded = flashlight:FindFirstChild("GotBlinded")
        
        if gotBlinded and gotBlinded:IsA("RemoteEvent") then
            local oldFire = gotBlinded.FireServer
            gotBlinded.FireServer = function(self, ...)
                if Config.KILLER_AntiBlind and GetRole() == "Killer" then
                    return nil 
                end
                return oldFire(self, ...)
            end
        end
    end)
end


local function UpdateNoSlowdown()
    if not Config.KILLER_NoSlowdown then return end
    if GetRole() ~= "Killer" then return end
    
    local char = LocalPlayer.Character
    if not char then return end
    local hum = char:FindFirstChildOfClass("Humanoid")
    if not hum then return end
    
    
    if hum.WalkSpeed < 16 then
        hum.WalkSpeed = State.OriginalSpeed or 16
    end
end


local LastDoubleTapTime = 0
local function DoubleTap()
    if not Config.KILLER_DoubleTap then return end
    if GetRole() ~= "Killer" then return end
    if tick() - LastDoubleTapTime < 0.5 then return end
    
    pcall(function()
        local remotes = ReplicatedStorage:FindFirstChild("Remotes")
        if not remotes then return end
        local attacks = remotes:FindFirstChild("Attacks")
        if not attacks then return end
        local basicAttack = attacks:FindFirstChild("BasicAttack")
        if basicAttack then
            basicAttack:FireServer(false)
            task.wait(0.05)
            basicAttack:FireServer(false)
            LastDoubleTapTime = tick()
        end
    end)
end


local function InfiniteLunge()
    if not Config.KILLER_InfiniteLunge then return end
    if GetRole() ~= "Killer" then return end
    
    local char = LocalPlayer.Character
    if not char then return end
    local hum = char:FindFirstChildOfClass("Humanoid")
    if not hum then return end
    
    
    local root = char:FindFirstChild("HumanoidRootPart")
    if root then
        local lookVector = root.CFrame.LookVector
        root.Velocity = lookVector * 100 + Vector3.new(0, 10, 0)
    end
end


local function SetupNoPalletStun()
    pcall(function()
        local remotes = ReplicatedStorage:FindFirstChild("Remotes")
        if not remotes then return end
        
        
        local pallet = remotes:FindFirstChild("Pallet")
        if pallet then
            local jason = pallet:FindFirstChild("Jason")
            if jason then
                local stun = jason:FindFirstChild("Stun")
                local stunDrop = jason:FindFirstChild("StunDrop")
                
                if stun and stun:IsA("RemoteEvent") then
                    local mt = getrawmetatable(game)
                    if mt and setreadonly then
                        setreadonly(mt, false)
                        local oldIndex = mt.__namecall
                        mt.__namecall = newcclosure(function(self, ...)
                            if Config.KILLER_NoPalletStun and GetRole() == "Killer" then
                                if self == stun or self == stunDrop then
                                    return nil
                                end
                            end
                            return oldIndex(self, ...)
                        end)
                        setreadonly(mt, true)
                    end
                end
            end
        end
        
        
        local mechanics = remotes:FindFirstChild("Mechanics")
        if mechanics then
            local palletStun = mechanics:FindFirstChild("PalletStun")
            if palletStun and palletStun:IsA("RemoteEvent") then
                
            end
        end
    end)
end

local OriginalCameraType = nil
local ThirdPersonWasActive = false
local function UpdateThirdPerson()
    local cam = workspace.CurrentCamera
    if not cam then return end
    local isKiller = GetRole() == "Killer"
    local shouldBeActive = Config.CAM_ThirdPerson and isKiller
    
    if shouldBeActive then
        if not ThirdPersonWasActive then
            OriginalCameraType = cam.CameraType
        end
        cam.CameraType = Enum.CameraType.Custom
        local char = LocalPlayer.Character
        if char then
            local hum = char:FindFirstChildOfClass("Humanoid")
            if hum then hum.CameraOffset = Vector3.new(2, 1, 8) end
        end
        ThirdPersonWasActive = true
    elseif ThirdPersonWasActive then
        if OriginalCameraType then
            cam.CameraType = OriginalCameraType
            OriginalCameraType = nil
        end
        local char = LocalPlayer.Character
        if char then
            local hum = char:FindFirstChildOfClass("Humanoid")
            if hum then hum.CameraOffset = Vector3.new(0, 0, 0) end
        end
        ThirdPersonWasActive = false
    end
end


local function UpdateShiftLock()
    if not Config.CAM_ShiftLock then return end
    
    local char = LocalPlayer.Character
    if not char then return end
    local root = char:FindFirstChild("HumanoidRootPart")
    local cam = workspace.CurrentCamera
    if not root or not cam then return end
    
    
    local camLook = cam.CFrame.LookVector
    local flatLook = Vector3.new(camLook.X, 0, camLook.Z).Unit
    root.CFrame = CFrame.new(root.Position, root.Position + flatLook)
end


local OriginalFOV = nil
local function UpdateCameraFOV()
    local cam = workspace.CurrentCamera
    if not cam then return end
    
    if not OriginalFOV then
        OriginalFOV = cam.FieldOfView
    end
    
    if Config.CAM_FOVEnabled then
        cam.FieldOfView = Config.CAM_FOV
    elseif OriginalFOV then
        cam.FieldOfView = OriginalFOV
    end
end


local FlyConnection = nil
local FlyBodyVelocity = nil
local FlyBodyGyro = nil

local function UpdateFly()
    local char = LocalPlayer.Character
    if not char then return end
    local root = char:FindFirstChild("HumanoidRootPart")
    local hum = char:FindFirstChildOfClass("Humanoid")
    if not root or not hum then return end
    
    if Config.FLY_Enabled then
        hum.PlatformStand = true
        
        
        if not FlyBodyVelocity then
            FlyBodyVelocity = Instance.new("BodyVelocity")
            FlyBodyVelocity.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
            FlyBodyVelocity.Velocity = Vector3.zero
            FlyBodyVelocity.Parent = root
        end
        
        if not FlyBodyGyro then
            FlyBodyGyro = Instance.new("BodyGyro")
            FlyBodyGyro.MaxTorque = Vector3.new(math.huge, math.huge, math.huge)
            FlyBodyGyro.P = 9e4
            FlyBodyGyro.Parent = root
        end
        
        
        local cam = workspace.CurrentCamera
        local moveDir = Vector3.zero
        
        if UserInputService:IsKeyDown(Enum.KeyCode.W) then
            moveDir = moveDir + cam.CFrame.LookVector
        end
        if UserInputService:IsKeyDown(Enum.KeyCode.S) then
            moveDir = moveDir - cam.CFrame.LookVector
        end
        if UserInputService:IsKeyDown(Enum.KeyCode.A) then
            moveDir = moveDir - cam.CFrame.RightVector
        end
        if UserInputService:IsKeyDown(Enum.KeyCode.D) then
            moveDir = moveDir + cam.CFrame.RightVector
        end
        if UserInputService:IsKeyDown(Enum.KeyCode.Space) then
            moveDir = moveDir + Vector3.new(0, 1, 0)
        end
        if UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) or UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then
            moveDir = moveDir - Vector3.new(0, 1, 0)
        end
        
        if moveDir.Magnitude > 0 then
            moveDir = moveDir.Unit * Config.FLY_Speed
        end
        
        if Config.FLY_Method == "Velocity" then
            FlyBodyVelocity.Velocity = moveDir
        else 
            FlyBodyVelocity.Velocity = Vector3.zero
            if moveDir.Magnitude > 0 then
                root.CFrame = root.CFrame + moveDir * 0.05
            end
        end
        
        FlyBodyGyro.CFrame = cam.CFrame
    else
        
        if FlyBodyVelocity then
            FlyBodyVelocity:Destroy()
            FlyBodyVelocity = nil
        end
        if FlyBodyGyro then
            FlyBodyGyro:Destroy()
            FlyBodyGyro = nil
        end
        if hum then
            hum.PlatformStand = false
        end
    end
end


local InfiniteJumpConnection = nil
local function SetupInfiniteJump()
    if InfiniteJumpConnection then
        InfiniteJumpConnection:Disconnect()
        InfiniteJumpConnection = nil
    end
    
    InfiniteJumpConnection = UserInputService.JumpRequest:Connect(function()
        if not Config.JUMP_Infinite then return end
        local char = LocalPlayer.Character
        if not char then return end
        local hum = char:FindFirstChildOfClass("Humanoid")
        if hum then
            hum:ChangeState(Enum.HumanoidStateType.Jumping)
        end
    end)
end


local OriginalJumpPower = nil
local function UpdateJumpPower()
    local char = LocalPlayer.Character
    if not char then return end
    local hum = char:FindFirstChildOfClass("Humanoid")
    if not hum then return end
    
    if not OriginalJumpPower then
        OriginalJumpPower = hum.JumpPower
    end
    
    if Config.JUMP_Power ~= 50 then
        hum.JumpPower = Config.JUMP_Power
        hum.UseJumpPower = true
    end
end


local function FlingNearest()
    if not Config.FLING_Enabled then return end
    
    local root = GetCharacterRoot()
    if not root then return end
    
    local closest, closestDist = nil, math.huge
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character then
            local targetRoot = player.Character:FindFirstChild("HumanoidRootPart")
            if targetRoot then
                local dist = (targetRoot.Position - root.Position).Magnitude
                if dist < closestDist then
                    closestDist = dist
                    closest = player
                end
            end
        end
    end
    
    if closest and closest.Character then
        local targetRoot = closest.Character:FindFirstChild("HumanoidRootPart")
        if targetRoot then
           
            local originalPos = root.CFrame
            for i = 1, 10 do
                root.CFrame = targetRoot.CFrame
                root.Velocity = Vector3.new(Config.FLING_Strength, Config.FLING_Strength/2, Config.FLING_Strength)
                root.RotVelocity = Vector3.new(9999, 9999, 9999)
                task.wait()
            end
            root.CFrame = originalPos
            root.Velocity = Vector3.zero
            root.RotVelocity = Vector3.zero
        end
    end
end

local function FlingAll()
    if not Config.FLING_Enabled then return end
    
    local root = GetCharacterRoot()
    if not root then return end
    local originalPos = root.CFrame
    
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character then
            local targetRoot = player.Character:FindFirstChild("HumanoidRootPart")
            if targetRoot then
                for i = 1, 5 do
                    root.CFrame = targetRoot.CFrame
                    root.Velocity = Vector3.new(Config.FLING_Strength, Config.FLING_Strength/2, Config.FLING_Strength)
                    root.RotVelocity = Vector3.new(9999, 9999, 9999)
                    task.wait()
                end
            end
        end
    end
    
    root.CFrame = originalPos
    root.Velocity = Vector3.zero
    root.RotVelocity = Vector3.zero
end

local function SpearAimbot(targetPos)
    if not Config.SPEAR_Aimbot then return nil end
    if GetRole() ~= "Killer" then return nil end
    
    local root = GetCharacterRoot()
    if not root then return nil end
    
    
    local startPos = root.Position + Vector3.new(0, 2, 0) 
    local distance = (targetPos - startPos).Magnitude
    local gravity = Config.SPEAR_Gravity
    local speed = Config.SPEAR_Speed
    
  
    local time = distance / speed
    
  
    local gravityDrop = 0.5 * gravity * time * time
    local aimPos = targetPos + Vector3.new(0, gravityDrop, 0)
    
    return aimPos
end

local function UpdateSpearAim()
    if not Config.SPEAR_Aimbot then return end
    if GetRole() ~= "Killer" then return end
    
    
    local root = GetCharacterRoot()
    if not root then return end
    
    local closest, closestDist = nil, math.huge
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and IsSurvivor(player) and player.Character then
            local targetRoot = player.Character:FindFirstChild("HumanoidRootPart")
            if targetRoot then
                local dist = (targetRoot.Position - root.Position).Magnitude
                if dist < closestDist and Cache.Visibility[player] then
                    closestDist = dist
                    closest = player
                end
            end
        end
    end
    
    if closest and closest.Character then
        local targetRoot = closest.Character:FindFirstChild("HumanoidRootPart")
        if targetRoot then
            local aimPos = SpearAimbot(targetRoot.Position)
            if aimPos then
                
                local cam = workspace.CurrentCamera
                if cam then
                    cam.CFrame = CFrame.new(cam.CFrame.Position, aimPos)
                end
            end
        end
    end
end

local Tabs = {
    {name = "ESP"},
    {name = "AIM"},
    {name = "SURV"},
    {name = "KILL"},
    {name = "MOVE"},
    {name = "MISC"}
}

local MenuItems = {
    
    {tab = 1, name = "GENERAL", type = "label"},
    {tab = 1, name = "Enable ESP", key = "ESP_Enabled", type = "toggle"},
    {tab = 1, name = "Max Distance", key = "ESP_MaxDist", type = "slider", min = 100, max = 1000, step = 50},
    {tab = 1, name = "PLAYERS", type = "label"},
    {tab = 1, name = "Killer", key = "ESP_Killer", type = "toggle"},
    {tab = 1, name = "Survivor", key = "ESP_Survivor", type = "toggle"},
    {tab = 1, name = "Player Mode", key = "ESP_PlayerChams", type = "mode"},
    {tab = 1, name = "OBJECTS", type = "label"},
    {tab = 1, name = "Generator", key = "ESP_Generator", type = "toggle"},
    {tab = 1, name = "Gate", key = "ESP_Gate", type = "toggle"},
    {tab = 1, name = "Hook", key = "ESP_Hook", type = "toggle"},
    {tab = 1, name = "Pallet", key = "ESP_Pallet", type = "toggle"},
    {tab = 1, name = "Window", key = "ESP_Window", type = "toggle"},
    {tab = 1, name = "Closest Hook", key = "ESP_ClosestHook", type = "toggle"},
    {tab = 1, name = "Object Mode", key = "ESP_ObjectChams", type = "mode"},
    {tab = 1, name = "DETAILS", type = "label"},
    {tab = 1, name = "Names", key = "ESP_Names", type = "toggle"},
    {tab = 1, name = "Distance", key = "ESP_Distance", type = "toggle"},
    {tab = 1, name = "Health", key = "ESP_Health", type = "toggle"},
    {tab = 1, name = "Skeleton", key = "ESP_Skeleton", type = "toggle"},
    {tab = 1, name = "Offscreen", key = "ESP_Offscreen", type = "toggle"},
    {tab = 1, name = "Velocity", key = "ESP_Velocity", type = "toggle"},
    {tab = 1, name = "RADAR", type = "label"},
    {tab = 1, name = "Radar Enable", key = "RADAR_Enabled", type = "toggle"},
    {tab = 1, name = "Radar Size", key = "RADAR_Size", type = "slider", min = 80, max = 200, step = 10},
    {tab = 1, name = "Radar Circle", key = "RADAR_Circle", type = "toggle"},
    {tab = 1, name = "Show Killer", key = "RADAR_Killer", type = "toggle"},
    {tab = 1, name = "Show Survivor", key = "RADAR_Survivor", type = "toggle"},
    {tab = 1, name = "Show Generator", key = "RADAR_Generator", type = "toggle"},
    {tab = 1, name = "Show Pallet", key = "RADAR_Pallet", type = "toggle"},
    
    {tab = 2, name = "CAMERA AIMBOT", type = "label"},
    {tab = 2, name = "Enable", key = "AIM_Enabled", type = "toggle"},
    {tab = 2, name = "Use RMB", key = "AIM_UseRMB", type = "toggle"},
    {tab = 2, name = "Show FOV", key = "AIM_ShowFOV", type = "toggle"},
    {tab = 2, name = "FOV Size", key = "AIM_FOV", type = "slider", min = 50, max = 400, step = 10},
    {tab = 2, name = "Smoothness", key = "AIM_Smooth", type = "slider", min = 0.1, max = 1, step = 0.05},
    {tab = 2, name = "Target Part", key = "AIM_TargetPart", type = "dropdown", options = {"Head", "Torso", "Root"}},
    {tab = 2, name = "Visibility", key = "AIM_VisCheck", type = "toggle"},
    {tab = 2, name = "Prediction", key = "AIM_Predict", type = "toggle"},
    {tab = 2, name = "SPEAR AIMBOT (VEIL)", type = "label"},
    {tab = 2, name = "Spear Aimbot", key = "SPEAR_Aimbot", type = "toggle"},
    {tab = 2, name = "Spear Gravity", key = "SPEAR_Gravity", type = "slider", min = 10, max = 200, step = 5},
    {tab = 2, name = "Spear Speed", key = "SPEAR_Speed", type = "slider", min = 50, max = 300, step = 10},
    
   
    {tab = 3, name = "GENERATORS", type = "label"},
    {tab = 3, name = "Auto Generator", key = "AUTO_Generator", type = "toggle"},
    {tab = 3, name = "Gen Speed", key = "AUTO_GenMode", type = "dropdown", options = {"Fast", "Slow"}},
    {tab = 3, name = "Leave Gen Key", key = "KEY_LeaveGen", type = "keybind"},
    {tab = 3, name = "Stop Gen Key", key = "KEY_StopGen", type = "keybind"},
    {tab = 3, name = "Leave Dist", key = "AUTO_LeaveDist", type = "slider", min = 10, max = 30, step = 2},
    {tab = 3, name = "SURVIVAL", type = "label"},
    {tab = 3, name = "No Fall Dmg", key = "SURV_NoFall", type = "toggle"},
    {tab = 3, name = "Flee Killer", key = "AUTO_TeleAway", type = "toggle"},
    {tab = 3, name = "Flee Distance", key = "AUTO_TeleAwayDist", type = "slider", min = 20, max = 80, step = 5},
    {tab = 3, name = "Auto Parry", key = "AUTO_Parry", type = "toggle"},
    {tab = 3, name = "Auto Wiggle", key = "SURV_AutoWiggle", type = "toggle"},
    {tab = 3, name = "Perfect Skill Check", key = "AUTO_SkillCheck", type = "toggle"},
    {tab = 3, name = "BEAT GAME", type = "label"},
    {tab = 3, name = "Beat Survivor", key = "BEAT_Survivor", type = "toggle"},
    
 
    {tab = 4, name = "COMBAT", type = "label"},
    {tab = 4, name = "Auto Attack", key = "AUTO_Attack", type = "toggle"},
    {tab = 4, name = "Attack Range", key = "AUTO_AttackRange", type = "slider", min = 5, max = 20, step = 1},
    {tab = 4, name = "Double Tap (instant kill)", key = "KILLER_DoubleTap", type = "toggle"},
    {tab = 4, name = "Infinite Lunge", key = "KILLER_InfiniteLunge", type = "toggle"},
    {tab = 4, name = "Auto Hook", key = "KILLER_AutoHook", type = "toggle"},
    {tab = 4, name = "HITBOX", type = "label"},
    {tab = 4, name = "Hitbox Expand", key = "HITBOX_Enabled", type = "toggle"},
    {tab = 4, name = "Hitbox Size", key = "HITBOX_Size", type = "slider", min = 5, max = 30, step = 1},
    {tab = 4, name = "PROTECTION", type = "label"},
    {tab = 4, name = "No Pallet Stun", key = "KILLER_NoPalletStun", type = "toggle"},
    {tab = 4, name = "Anti Blind", key = "KILLER_AntiBlind", type = "toggle"},
    {tab = 4, name = "No Slowdown", key = "KILLER_NoSlowdown", type = "toggle"},
    {tab = 4, name = "DESTRUCTION", type = "label"},
    {tab = 4, name = "Full Gen Break", key = "KILLER_FullGenBreak", type = "toggle"},
    {tab = 4, name = "Destroy Pallets", key = "KILLER_DestroyPallets", type = "toggle"},
    {tab = 4, name = "CAMERA", type = "label"},
    {tab = 4, name = "Third Person", key = "CAM_ThirdPerson", type = "toggle"},
    {tab = 4, name = "Shift Lock", key = "CAM_ShiftLock", type = "toggle"},
    {tab = 4, name = "BEAT GAME", type = "label"},
    {tab = 4, name = "Beat Killer", key = "BEAT_Killer", type = "toggle"},
    
   
    {tab = 5, name = "SPEED", type = "label"},
    {tab = 5, name = "Speed Hack", key = "SPEED_Enabled", type = "toggle"},
    {tab = 5, name = "Speed Value", key = "SPEED_Value", type = "slider", min = 16, max = 150, step = 2},
    {tab = 5, name = "Speed Method", key = "SPEED_Method", type = "dropdown", options = {"Attribute", "TP"}},
    {tab = 5, name = "Speed Key", key = "KEY_Speed", type = "keybind"},
    {tab = 5, name = "FLIGHT", type = "label"},
    {tab = 5, name = "Fly", key = "FLY_Enabled", type = "toggle"},
    {tab = 5, name = "Fly Speed", key = "FLY_Speed", type = "slider", min = 10, max = 200, step = 5},
    {tab = 5, name = "Fly Method", key = "FLY_Method", type = "dropdown", options = {"CFrame", "Velocity"}},
    {tab = 5, name = "Fly Key", key = "KEY_Fly", type = "keybind"},
    {tab = 5, name = "JUMP", type = "label"},
    {tab = 5, name = "Jump Power", key = "JUMP_Power", type = "slider", min = 50, max = 200, step = 5},
    {tab = 5, name = "Infinite Jump", key = "JUMP_Infinite", type = "toggle"},
    {tab = 5, name = "COLLISION", type = "label"},
    {tab = 5, name = "Noclip", key = "NOCLIP_Enabled", type = "toggle"},
    {tab = 5, name = "Noclip Key", key = "KEY_Noclip", type = "keybind"},
    {tab = 5, name = "TELEPORT", type = "label"},
    {tab = 5, name = "TP Height", key = "TP_Offset", type = "slider", min = 0, max = 10, step = 1},
    {tab = 5, name = "TP to Gen", type = "button", action = function() TeleportToGenerator(1) end},
    {tab = 5, name = "TP to Gate", type = "button", action = function() TeleportToGate() end},
    {tab = 5, name = "TP to Hook", type = "button", action = function() TeleportToHook() end},
    {tab = 5, name = "Gen Key", key = "KEY_TP_Gen", type = "keybind"},
    {tab = 5, name = "Gate Key", key = "KEY_TP_Gate", type = "keybind"},
    {tab = 5, name = "Hook Key", key = "KEY_TP_Hook", type = "keybind"},
    
    
    {tab = 6, name = "VISUAL", type = "label"},
    {tab = 6, name = "No Fog", key = "NO_Fog", type = "toggle"},
    {tab = 6, name = "FOV Enabled", key = "CAM_FOVEnabled", type = "toggle"},
    {tab = 6, name = "FOV Value", key = "CAM_FOV", type = "slider", min = 30, max = 120, step = 5},
    {tab = 6, name = "FLING", type = "label"},
    {tab = 6, name = "Fling Enable", key = "FLING_Enabled", type = "toggle"},
    {tab = 6, name = "Fling Strength", key = "FLING_Strength", type = "slider", min = 1000, max = 50000, step = 1000},
    {tab = 6, name = "Fling Nearest", type = "button", action = function() FlingNearest() end},
    {tab = 6, name = "Fling All", type = "button", action = function() FlingAll() end},
    {tab = 6, name = "MENU", type = "label"},
    {tab = 6, name = "Menu Key", key = "KEY_Menu", type = "keybind"},
    {tab = 6, name = "Panic Key", key = "KEY_Panic", type = "keybind"}
}

local GUI = {
    Drawings = {},
    Visible = true,
    AnimProgress = 1,
    TargetAnim = 1,
    HoverStates = {},
    ItemHover = {},
    TabHover = {},
    ScrollOffset = 0,
    MaxScroll = 0,
    Dragging = false,
    ScrollbarDragging = false,
    Position = nil,
    PositionOffset = Vector2.new(0, 0),
    ItemPositions = {},
    TabPositions = {},
    ContentBounds = {},
    ScrollbarBounds = {},
    EditingKeybind = nil
}

local KeyNames = {
    [Enum.KeyCode.Q] = "Q", [Enum.KeyCode.W] = "W", [Enum.KeyCode.E] = "E", [Enum.KeyCode.R] = "R",
    [Enum.KeyCode.T] = "T", [Enum.KeyCode.Y] = "Y", [Enum.KeyCode.U] = "U", [Enum.KeyCode.I] = "I",
    [Enum.KeyCode.O] = "O", [Enum.KeyCode.P] = "P", [Enum.KeyCode.A] = "A", [Enum.KeyCode.S] = "S",
    [Enum.KeyCode.D] = "D", [Enum.KeyCode.F] = "F", [Enum.KeyCode.G] = "G", [Enum.KeyCode.H] = "H",
    [Enum.KeyCode.J] = "J", [Enum.KeyCode.K] = "K", [Enum.KeyCode.L] = "L", [Enum.KeyCode.Z] = "Z",
    [Enum.KeyCode.X] = "X", [Enum.KeyCode.C] = "C", [Enum.KeyCode.V] = "V", [Enum.KeyCode.B] = "B",
    [Enum.KeyCode.N] = "N", [Enum.KeyCode.M] = "M",
    [Enum.KeyCode.One] = "1", [Enum.KeyCode.Two] = "2", [Enum.KeyCode.Three] = "3",
    [Enum.KeyCode.Four] = "4", [Enum.KeyCode.Five] = "5", [Enum.KeyCode.Six] = "6",
    [Enum.KeyCode.Seven] = "7", [Enum.KeyCode.Eight] = "8", [Enum.KeyCode.Nine] = "9",
    [Enum.KeyCode.Zero] = "0",
    [Enum.KeyCode.Insert] = "INS", [Enum.KeyCode.Home] = "HOME", [Enum.KeyCode.End] = "END",
    [Enum.KeyCode.Delete] = "DEL", [Enum.KeyCode.PageUp] = "PGUP", [Enum.KeyCode.PageDown] = "PGDN",
    [Enum.KeyCode.F1] = "F1", [Enum.KeyCode.F2] = "F2", [Enum.KeyCode.F3] = "F3", [Enum.KeyCode.F4] = "F4",
    [Enum.KeyCode.F5] = "F5", [Enum.KeyCode.F6] = "F6", [Enum.KeyCode.F7] = "F7", [Enum.KeyCode.F8] = "F8",
    [Enum.KeyCode.LeftShift] = "LSHIFT", [Enum.KeyCode.RightShift] = "RSHIFT",
    [Enum.KeyCode.LeftControl] = "LCTRL", [Enum.KeyCode.RightControl] = "RCTRL",
    [Enum.KeyCode.LeftAlt] = "LALT", [Enum.KeyCode.RightAlt] = "RALT",
    [Enum.KeyCode.Backquote] = "`", [Enum.KeyCode.Tab] = "TAB"
}

local function GetKeyName(keyCode)
    return KeyNames[keyCode] or tostring(keyCode):gsub("Enum.KeyCode.", "")
end

function GUI.Create()
    GUI.Drawings.Bg = Drawing.new("Square")
    GUI.Drawings.Bg.Filled = true
    GUI.Drawings.Bg.Color = Colors.UI_Bg
    GUI.Drawings.Bg.Visible = false
    
    GUI.Drawings.Border = Drawing.new("Square")
    GUI.Drawings.Border.Filled = false
    GUI.Drawings.Border.Color = Colors.UI_Border
    GUI.Drawings.Border.Thickness = 1
    GUI.Drawings.Border.Visible = false
    
    GUI.Drawings.DragBar = Drawing.new("Square")
    GUI.Drawings.DragBar.Filled = true
    GUI.Drawings.DragBar.Color = Colors.UI_Sidebar
    GUI.Drawings.DragBar.Visible = false
    
    GUI.Drawings.Sidebar = Drawing.new("Square")
    GUI.Drawings.Sidebar.Filled = true
    GUI.Drawings.Sidebar.Color = Colors.UI_Sidebar
    GUI.Drawings.Sidebar.Visible = false
    
    GUI.Drawings.ScrollbarBg = Drawing.new("Square")
    GUI.Drawings.ScrollbarBg.Filled = true
    GUI.Drawings.ScrollbarBg.Color = Color3.fromRGB(25, 25, 30)
    GUI.Drawings.ScrollbarBg.Visible = false
    
    GUI.Drawings.ScrollbarThumb = Drawing.new("Square")
    GUI.Drawings.ScrollbarThumb.Filled = true
    GUI.Drawings.ScrollbarThumb.Color = Colors.UI_Accent
    GUI.Drawings.ScrollbarThumb.Visible = false
    
    GUI.Drawings.Tabs = {}
    for i = 1, #Tabs do
        GUI.Drawings.Tabs[i] = {
            Bg = Drawing.new("Square"),
            Label = Drawing.new("Text"),
            Indicator = Drawing.new("Square")
        }
        GUI.Drawings.Tabs[i].Bg.Filled = true
        GUI.Drawings.Tabs[i].Bg.Visible = false
        GUI.Drawings.Tabs[i].Label.Size = 15
        GUI.Drawings.Tabs[i].Label.Font = Drawing.Fonts.UI
        GUI.Drawings.Tabs[i].Label.Center = true
        GUI.Drawings.Tabs[i].Label.Outline = true
        GUI.Drawings.Tabs[i].Label.Visible = false
        GUI.Drawings.Tabs[i].Indicator.Filled = true
        GUI.Drawings.Tabs[i].Indicator.Color = Colors.UI_Accent
        GUI.Drawings.Tabs[i].Indicator.Visible = false
    end
    
    GUI.Drawings.Items = {}
    for i = 1, 25 do
        GUI.Drawings.Items[i] = {
            Bg = Drawing.new("Square"),
            SelectBar = Drawing.new("Square"),
            Label = Drawing.new("Text"),
            Value = Drawing.new("Text"),
            Toggle = Drawing.new("Square"),
            ToggleKnob = Drawing.new("Square"),
            SliderBg = Drawing.new("Square"),
            SliderFill = Drawing.new("Square")
        }
        local item = GUI.Drawings.Items[i]
        item.Bg.Filled = true
        item.Bg.Visible = false
        item.SelectBar.Filled = true
        item.SelectBar.Color = Colors.UI_Accent
        item.SelectBar.Visible = false
        item.Label.Size = 15
        item.Label.Font = Drawing.Fonts.UI
        item.Label.Outline = true
        item.Label.Visible = false
        item.Value.Size = 14
        item.Value.Font = Drawing.Fonts.UI
        item.Value.Outline = true
        item.Value.Visible = false
        item.Toggle.Filled = true
        item.Toggle.Visible = false
        item.ToggleKnob.Filled = true
        item.ToggleKnob.Color = Color3.new(1, 1, 1)
        item.ToggleKnob.Visible = false
        item.SliderBg.Filled = true
        item.SliderBg.Color = Colors.UI_Off
        item.SliderBg.Visible = false
        item.SliderFill.Filled = true
        item.SliderFill.Color = Colors.UI_Accent
        item.SliderFill.Visible = false
    end
    
    GUI.Drawings.Footer = Drawing.new("Square")
    GUI.Drawings.Footer.Filled = true
    GUI.Drawings.Footer.Color = Colors.UI_Sidebar
    GUI.Drawings.Footer.Visible = false
    
    GUI.Drawings.Hint = Drawing.new("Text")
    GUI.Drawings.Hint.Size = 13
    GUI.Drawings.Hint.Font = Drawing.Fonts.UI
    GUI.Drawings.Hint.Color = Colors.UI_TextDim
    GUI.Drawings.Hint.Outline = true
    GUI.Drawings.Hint.Text = "INS HOME TAB"
    GUI.Drawings.Hint.Visible = false
    
    GUI.Drawings.Role = Drawing.new("Text")
    GUI.Drawings.Role.Size = 13
    GUI.Drawings.Role.Font = Drawing.Fonts.UI
    GUI.Drawings.Role.Outline = true
    GUI.Drawings.Role.Visible = false
    
   
    GUI.Drawings.AutoGenHint = Drawing.new("Text")
    GUI.Drawings.AutoGenHint.Size = 16
    GUI.Drawings.AutoGenHint.Font = Drawing.Fonts.UI
    GUI.Drawings.AutoGenHint.Center = true
    GUI.Drawings.AutoGenHint.Outline = true
    GUI.Drawings.AutoGenHint.Color = Colors.UI_Accent
    GUI.Drawings.AutoGenHint.Visible = false
    
    
    GUI.Drawings.FOVCircle = Drawing.new("Circle")
    GUI.Drawings.FOVCircle.Thickness = 1
    GUI.Drawings.FOVCircle.Color = Colors.UI_Accent
    GUI.Drawings.FOVCircle.Filled = false
    GUI.Drawings.FOVCircle.NumSides = 60
    GUI.Drawings.FOVCircle.Transparency = 0.8
    GUI.Drawings.FOVCircle.Visible = false
end

function GUI.Hide()
    local keepVisible = {FOVCircle = true, AutoGenHint = true}
    for name, drawing in pairs(GUI.Drawings) do
        if keepVisible[name] then
           
        elseif type(drawing) == "table" then
            for _, subDrawing in pairs(drawing) do
                if type(subDrawing) == "table" then
                    for _, d in pairs(subDrawing) do
                        if d.Visible ~= nil then d.Visible = false end
                    end
                elseif subDrawing.Visible ~= nil then
                    subDrawing.Visible = false
                end
            end
        elseif drawing.Visible ~= nil then
            drawing.Visible = false
        end
    end
end

function GUI.Render()
    GUI.TargetAnim = Config.MENU_Open and 1 or 0
    GUI.AnimProgress = Lerp(GUI.AnimProgress, GUI.TargetAnim, 0.15)
    
    if GUI.AnimProgress < 0.01 then
        GUI.Hide()
        return
    end
    
    local cam = workspace.CurrentCamera
    if not cam then return end
    
    local screenSize = cam.ViewportSize
    local menuW, menuH = 300, 420
    local sidebarW = 60
    local dragBarH = 22
    local footerH = 30
    local scrollbarW = 6
    
    if not GUI.Position then
        GUI.Position = Vector2.new(screenSize.X / 2 - menuW / 2, screenSize.Y / 2 - menuH / 2)
    end
    
    if GUI.Dragging then
        local mouse = UserInputService:GetMouseLocation()
        GUI.Position = mouse - GUI.PositionOffset
        GUI.Position = Vector2.new(
            math.clamp(GUI.Position.X, 0, screenSize.X - menuW),
            math.clamp(GUI.Position.Y, 0, screenSize.Y - menuH)
        )
    end
    
    local animAlpha = GUI.AnimProgress
    local x = GUI.Position.X
    local y = GUI.Position.Y
    
    GUI.Drawings.Bg.Position = Vector2.new(x, y)
    GUI.Drawings.Bg.Size = Vector2.new(menuW, menuH)
    GUI.Drawings.Bg.Transparency = animAlpha * 0.95
    GUI.Drawings.Bg.Visible = true
    
    GUI.Drawings.Border.Position = Vector2.new(x, y)
    GUI.Drawings.Border.Size = Vector2.new(menuW, menuH)
    GUI.Drawings.Border.Transparency = animAlpha
    GUI.Drawings.Border.Visible = true
    
    GUI.Drawings.DragBar.Position = Vector2.new(x + sidebarW, y)
    GUI.Drawings.DragBar.Size = Vector2.new(menuW - sidebarW, dragBarH)
    GUI.Drawings.DragBar.Transparency = animAlpha * 0.95
    GUI.Drawings.DragBar.Visible = true
    
    GUI.Drawings.Sidebar.Position = Vector2.new(x, y)
    GUI.Drawings.Sidebar.Size = Vector2.new(sidebarW, menuH)
    GUI.Drawings.Sidebar.Transparency = animAlpha * 0.95
    GUI.Drawings.Sidebar.Visible = true
    
    GUI.TabPositions = {}
    local tabY = y + 15
    local tabH = 36
    for i, tab in ipairs(Tabs) do
        local tabDrawing = GUI.Drawings.Tabs[i]
        local isSelected = (i == Config.MENU_Tab)
        
        GUI.TabHover[i] = GUI.TabHover[i] or 0
        GUI.TabHover[i] = Lerp(GUI.TabHover[i], isSelected and 1 or 0, 0.2)
        
        local bgColor = LerpColor(Colors.UI_Sidebar, Colors.UI_Card, GUI.TabHover[i])
        
        tabDrawing.Bg.Position = Vector2.new(x + 5, tabY)
        tabDrawing.Bg.Size = Vector2.new(sidebarW - 10, tabH)
        tabDrawing.Bg.Color = bgColor
        tabDrawing.Bg.Transparency = animAlpha * 0.9
        tabDrawing.Bg.Visible = true
        
        GUI.TabPositions[i] = {x = x + 5, y = tabY, w = sidebarW - 10, h = tabH}
        
        tabDrawing.Label.Position = Vector2.new(x + sidebarW / 2, tabY + tabH / 2 - 7)
        tabDrawing.Label.Text = tab.name
        tabDrawing.Label.Color = LerpColor(Colors.UI_TextDim, Colors.UI_Text, GUI.TabHover[i])
        tabDrawing.Label.Transparency = animAlpha
        tabDrawing.Label.Visible = true
        
        local indicatorH = (tabH - 10) * GUI.TabHover[i]
        if indicatorH > 1 then
            tabDrawing.Indicator.Position = Vector2.new(x + sidebarW - 3, tabY + tabH/2 - indicatorH/2)
            tabDrawing.Indicator.Size = Vector2.new(3, indicatorH)
            tabDrawing.Indicator.Transparency = animAlpha
            tabDrawing.Indicator.Visible = true
        else
            tabDrawing.Indicator.Visible = false
        end
        
        tabY = tabY + tabH + 6
    end
    
    local contentX = x + sidebarW + 10
    local contentY = y + dragBarH + 8
    local contentW = menuW - sidebarW - 20 - scrollbarW
    local contentH = menuH - dragBarH - footerH - 16
    local itemH = 30
    local itemSpacing = 4
    local itemIdx = 0
    local currentTabItemIdx = 0
    
    GUI.ContentBounds = {x = contentX, y = contentY, w = contentW, h = contentH}
    
    local tabItemCount = 0
    for _, item in ipairs(MenuItems) do
        if item.tab == Config.MENU_Tab then tabItemCount = tabItemCount + 1 end
    end
    local totalContentH = tabItemCount * (itemH + itemSpacing)
    GUI.MaxScroll = math.max(0, totalContentH - contentH)
    GUI.ScrollOffset = math.clamp(GUI.ScrollOffset, 0, GUI.MaxScroll)
    
    local scrollbarX = x + menuW - scrollbarW - 6
    local scrollbarY = contentY
    local scrollbarH = contentH
    
    GUI.Drawings.ScrollbarBg.Position = Vector2.new(scrollbarX, scrollbarY)
    GUI.Drawings.ScrollbarBg.Size = Vector2.new(scrollbarW, scrollbarH)
    GUI.Drawings.ScrollbarBg.Transparency = animAlpha * 0.6
    GUI.Drawings.ScrollbarBg.Visible = true
    
    GUI.ScrollbarBounds = {x = scrollbarX, y = scrollbarY, w = scrollbarW, h = scrollbarH}
    
    if GUI.MaxScroll > 0 then
        local thumbH = math.max(30, scrollbarH * (contentH / totalContentH))
        local thumbY = scrollbarY + (GUI.ScrollOffset / GUI.MaxScroll) * (scrollbarH - thumbH)
        GUI.Drawings.ScrollbarThumb.Position = Vector2.new(scrollbarX, thumbY)
        GUI.Drawings.ScrollbarThumb.Size = Vector2.new(scrollbarW, thumbH)
        GUI.Drawings.ScrollbarThumb.Transparency = animAlpha
        GUI.Drawings.ScrollbarThumb.Visible = true
        GUI.ScrollbarBounds.thumbH = thumbH
    else
        GUI.Drawings.ScrollbarThumb.Visible = false
        GUI.ScrollbarBounds.thumbH = 0
    end
    
    GUI.ItemPositions = {}
    
    for _, menuItem in ipairs(MenuItems) do
        if menuItem.tab == Config.MENU_Tab then
            currentTabItemIdx = currentTabItemIdx + 1
            
            local rawY = contentY + (currentTabItemIdx - 1) * (itemH + itemSpacing) - GUI.ScrollOffset
            
            local isVisible = rawY >= contentY - 2 and rawY <= contentY + contentH - itemH + 5
            
            if isVisible then
                itemIdx = itemIdx + 1
                if itemIdx > 25 then break end
                
                local item = GUI.Drawings.Items[itemIdx]
                local itemY = rawY
                local isSelected = (currentTabItemIdx == SelectedItem)
                
                GUI.ItemPositions[itemIdx] = {x = contentX, y = itemY, w = contentW, h = itemH, idx = currentTabItemIdx}
                
                local itemKey = Config.MENU_Tab .. "_" .. itemIdx
                GUI.ItemHover[itemKey] = GUI.ItemHover[itemKey] or 0
                local targetHover = isSelected and 1 or 0
                GUI.ItemHover[itemKey] = Lerp(GUI.ItemHover[itemKey], targetHover, 0.2)
                
                local bgColor = LerpColor(Colors.UI_Card, Colors.UI_CardHover, GUI.ItemHover[itemKey])
                
                item.Bg.Position = Vector2.new(contentX, itemY)
                item.Bg.Size = Vector2.new(contentW, itemH)
                item.Bg.Color = bgColor
                item.Bg.Transparency = animAlpha * 0.9
                item.Bg.Visible = true
                
                local selectBarWidth = 4 * GUI.ItemHover[itemKey]
                if selectBarWidth > 0.5 then
                    item.SelectBar.Position = Vector2.new(contentX, itemY)
                    item.SelectBar.Size = Vector2.new(selectBarWidth, itemH)
                    item.SelectBar.Transparency = animAlpha
                    item.SelectBar.Visible = true
                else
                    item.SelectBar.Visible = false
                end
                
                local labelColor = LerpColor(Colors.UI_Text, Colors.UI_Accent, GUI.ItemHover[itemKey] * 0.5)
                item.Label.Position = Vector2.new(contentX + 10, itemY + 7)
                item.Label.Text = menuItem.name
                item.Label.Color = labelColor
                item.Label.Transparency = animAlpha
                item.Label.Visible = true
                
                if menuItem.type == "toggle" then
                    local isOn = Config[menuItem.key]
                    local toggleColor = LerpColor(Colors.UI_Off, Colors.UI_On, isOn and 1 or 0)
                    
                    local toggleX = contentX + contentW - 42
                    local toggleY = itemY + 7
                    local toggleW = 32
                    local toggleH = 16
                    local knobSize = 12
                    
                    item.Toggle.Position = Vector2.new(toggleX, toggleY)
                    item.Toggle.Size = Vector2.new(toggleW, toggleH)
                    item.Toggle.Color = toggleColor
                    item.Toggle.Transparency = animAlpha
                    item.Toggle.Visible = true
                    
                    local knobX = isOn and (toggleX + toggleW - knobSize - 2) or (toggleX + 2)
                    item.ToggleKnob.Position = Vector2.new(knobX, toggleY + 2)
                    item.ToggleKnob.Size = Vector2.new(knobSize, knobSize)
                    item.ToggleKnob.Transparency = animAlpha
                    item.ToggleKnob.Visible = true
                    
                    item.Value.Visible = false
                    item.SliderBg.Visible = false
                    item.SliderFill.Visible = false
                elseif menuItem.type == "slider" then
                    local val = Config[menuItem.key]
                    local pct = (val - menuItem.min) / (menuItem.max - menuItem.min)
                    local valText = menuItem.step < 1 and string.format("%.2f", val) or tostring(math.floor(val))
                    
                    item.Value.Position = Vector2.new(contentX + contentW - 45, itemY + 7)
                    item.Value.Text = valText
                    item.Value.Color = Colors.UI_TextDim
                    item.Value.Transparency = animAlpha
                    item.Value.Visible = true
                    
                    item.SliderBg.Position = Vector2.new(contentX + 10, itemY + itemH - 7)
                    item.SliderBg.Size = Vector2.new(contentW - 60, 4)
                    item.SliderBg.Transparency = animAlpha * 0.8
                    item.SliderBg.Visible = true
                    
                    item.SliderFill.Position = Vector2.new(contentX + 10, itemY + itemH - 7)
                    item.SliderFill.Size = Vector2.new((contentW - 60) * pct, 4)
                    item.SliderFill.Transparency = animAlpha
                    item.SliderFill.Visible = true
                    
                    item.Toggle.Visible = false
                    item.ToggleKnob.Visible = false
                elseif menuItem.type == "button" then
                    item.Value.Position = Vector2.new(contentX + contentW - 40, itemY + 7)
                    item.Value.Text = "[GO]"
                    item.Value.Color = LerpColor(Colors.UI_Accent, Colors.UI_Text, GUI.ItemHover[itemKey])
                    item.Value.Transparency = animAlpha
                    item.Value.Visible = true
                    item.Toggle.Visible = false
                    item.ToggleKnob.Visible = false
                    item.SliderBg.Visible = false
                    item.SliderFill.Visible = false
                elseif menuItem.type == "label" then
                    item.Label.Color = Colors.UI_Accent
                    item.Label.Position = Vector2.new(contentX + 10, itemY + 7)
                    item.Value.Visible = false
                    item.Toggle.Visible = false
                    item.ToggleKnob.Visible = false
                    item.SliderBg.Visible = false
                    item.SliderFill.Visible = false
                    item.Bg.Color = Colors.UI_Sidebar
                    item.SelectBar.Visible = false
                elseif menuItem.type == "info" then
                    item.Label.Color = Colors.UI_TextDim
                    item.Label.Position = Vector2.new(contentX + 10, itemY + 7)
                    item.Value.Visible = false
                    item.Toggle.Visible = false
                    item.ToggleKnob.Visible = false
                    item.SliderBg.Visible = false
                    item.SliderFill.Visible = false
                    item.Bg.Color = Colors.UI_Bg
                    item.SelectBar.Visible = false
                elseif menuItem.type == "keybind" then
                    local keyCode = Config[menuItem.key]
                    local keyText = GUI.EditingKeybind == menuItem.key and "[...]" or ("[" .. GetKeyName(keyCode) .. "]")
                    
                    item.Value.Position = Vector2.new(contentX + contentW - 50, itemY + 7)
                    item.Value.Text = keyText
                    item.Value.Color = GUI.EditingKeybind == menuItem.key and Colors.UI_Accent or Colors.UI_Text
                    item.Value.Transparency = animAlpha
                    item.Value.Visible = true
                    item.Toggle.Visible = false
                    item.ToggleKnob.Visible = false
                    item.SliderBg.Visible = false
                    item.SliderFill.Visible = false
                elseif menuItem.type == "mode" then
                    local isChams = Config[menuItem.key]
                    
                    item.Value.Position = Vector2.new(contentX + contentW - 85, itemY + 7)
                    item.Value.Text = isChams and "DRAW | [CHAMS]" or "[DRAW] | CHAMS"
                    item.Value.Color = Colors.UI_Text
                    item.Value.Transparency = animAlpha
                    item.Value.Visible = true
                    
                    item.Toggle.Visible = false
                    item.ToggleKnob.Visible = false
                    item.SliderBg.Visible = false
                    item.SliderFill.Visible = false
                elseif menuItem.type == "dropdown" then
                    local currentVal = Config[menuItem.key]
                    local displayText = "[" .. tostring(currentVal):upper() .. "]"
                    
                    item.Value.Position = Vector2.new(contentX + contentW - 60, itemY + 7)
                    item.Value.Text = displayText
                    item.Value.Color = Colors.UI_Accent
                    item.Value.Transparency = animAlpha
                    item.Value.Visible = true
                    
                    item.Toggle.Visible = false
                    item.ToggleKnob.Visible = false
                    item.SliderBg.Visible = false
                    item.SliderFill.Visible = false
                end
            end
        end
    end
    
    for i = itemIdx + 1, 25 do
        local item = GUI.Drawings.Items[i]
        item.Bg.Visible = false
        item.SelectBar.Visible = false
        item.Label.Visible = false
        item.Value.Visible = false
        item.Toggle.Visible = false
        item.ToggleKnob.Visible = false
        item.SliderBg.Visible = false
        item.SliderFill.Visible = false
    end
    
    GUI.Drawings.Footer.Position = Vector2.new(x + sidebarW, y + menuH - footerH)
    GUI.Drawings.Footer.Size = Vector2.new(menuW - sidebarW, footerH)
    GUI.Drawings.Footer.Transparency = animAlpha * 0.95
    GUI.Drawings.Footer.Visible = true
    
    GUI.Drawings.Hint.Position = Vector2.new(x + sidebarW + 10, y + menuH - footerH + 8)
    GUI.Drawings.Hint.Transparency = animAlpha * 0.7
    GUI.Drawings.Hint.Visible = true
    
    local role = GetRole()
    GUI.Drawings.Role.Position = Vector2.new(x + menuW - 55, y + menuH - footerH + 8)
    GUI.Drawings.Role.Text = role
    GUI.Drawings.Role.Color = role == "Killer" and Colors.Killer or role == "Survivor" and Colors.Survivor or Colors.UI_TextDim
    GUI.Drawings.Role.Transparency = animAlpha
    GUI.Drawings.Role.Visible = true
end


local SelectedItem = 1

local function HandleInput(input, gameProcessed)
    if State.Unloaded then return end
    
    local menuW, menuH = 300, 420
    local sidebarW = 60
    local dragBarH = 22
    local footerH = 30
    
    
    if GUI.EditingKeybind and input.UserInputType == Enum.UserInputType.Keyboard then
        if input.KeyCode ~= Enum.KeyCode.Escape then
            Config[GUI.EditingKeybind] = input.KeyCode
        end
        GUI.EditingKeybind = nil
        return
    end
    
    if input.UserInputType == Enum.UserInputType.Keyboard then
        
        if input.KeyCode == Config.KEY_Panic then
            Unload()
            return
        end
        
        
        if input.KeyCode == Config.KEY_Menu and not gameProcessed then
            Config.MENU_Open = not Config.MENU_Open
            return
        end
        
       
        if (Config.AUTO_LeaveGen or Config.AUTO_Generator) and input.KeyCode == Config.KEY_LeaveGen and not gameProcessed then
            LeaveGenerator()
            return
        end
        
        
        if input.KeyCode == Config.KEY_StopGen and not gameProcessed then
            StopAutoGen()
            return
        end
        
        
      
        if input.KeyCode == Config.KEY_TP_Gen and not gameProcessed then
            TeleportToGenerator(1)
            return
        end
        if input.KeyCode == Config.KEY_TP_Gate and not gameProcessed then
            TeleportToGate()
            return
        end
        if input.KeyCode == Config.KEY_TP_Hook and not gameProcessed then
            TeleportToHook()
            return
        end
        
        
        if input.KeyCode == Config.KEY_Speed and not gameProcessed then
            Config.SPEED_Enabled = not Config.SPEED_Enabled
            return
        end
        
        
        if input.KeyCode == Config.KEY_Noclip and not gameProcessed then
            Config.NOCLIP_Enabled = not Config.NOCLIP_Enabled
            return
        end
        
        
        if input.KeyCode == Config.KEY_Fly and not gameProcessed then
            Config.FLY_Enabled = not Config.FLY_Enabled
            return
        end
    end
    
    
    if input.UserInputType == Enum.UserInputType.MouseButton2 then
        if Config.AIM_Enabled and Config.AIM_UseRMB then
            State.AimHolding = true
        end
    end
    
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        if Config.MENU_Open and GUI.Position then
            local mouse = UserInputService:GetMouseLocation()
            local x, y = GUI.Position.X, GUI.Position.Y
            
           
            if mouse.X >= x + sidebarW and mouse.X <= x + menuW and
               mouse.Y >= y and mouse.Y <= y + dragBarH then
                GUI.Dragging = true
                GUI.PositionOffset = mouse - GUI.Position
                return
            end
            
            
            if GUI.ScrollbarBounds and GUI.MaxScroll > 0 then
                local sb = GUI.ScrollbarBounds
                if mouse.X >= sb.x and mouse.X <= sb.x + sb.w + 10 and
                   mouse.Y >= sb.y and mouse.Y <= sb.y + sb.h then
                    GUI.ScrollbarDragging = true
                    local pct = math.clamp((mouse.Y - sb.y) / sb.h, 0, 1)
                    GUI.ScrollOffset = pct * GUI.MaxScroll
                    return
                end
            end
            
            
            for i, pos in pairs(GUI.TabPositions) do
                if mouse.X >= pos.x and mouse.X <= pos.x + pos.w and
                   mouse.Y >= pos.y and mouse.Y <= pos.y + pos.h then
                    Config.MENU_Tab = i
                    SelectedItem = 1
                    GUI.ScrollOffset = 0
                    GUI.EditingKeybind = nil
                    return
                end
            end
            
            
            for i, pos in pairs(GUI.ItemPositions) do
                if mouse.X >= pos.x and mouse.X <= pos.x + pos.w and
                   mouse.Y >= pos.y and mouse.Y <= pos.y + pos.h then
                    local tabItems = {}
                    for _, item in ipairs(MenuItems) do
                        if item.tab == Config.MENU_Tab then
                            table.insert(tabItems, item)
                        end
                    end
                    
                    local menuItem = tabItems[pos.idx]
                    if menuItem then
                        SelectedItem = pos.idx
                        
                        if menuItem.type == "toggle" then
                            Config[menuItem.key] = not Config[menuItem.key]
                        elseif menuItem.type == "mode" then
                            Config[menuItem.key] = not Config[menuItem.key]
                        elseif menuItem.type == "dropdown" then
                            local opts = menuItem.options
                            local current = Config[menuItem.key]
                            local idx = 1
                            for i, opt in ipairs(opts) do
                                if opt == current then idx = i break end
                            end
                            idx = idx + 1
                            if idx > #opts then idx = 1 end
                            Config[menuItem.key] = opts[idx]
                        elseif menuItem.type == "button" and menuItem.action then
                            menuItem.action()
                        elseif menuItem.type == "slider" then
                            local sliderX = pos.x + 10
                            local sliderW = pos.w - 60
                            local pct = math.clamp((mouse.X - sliderX) / sliderW, 0, 1)
                            local val = menuItem.min + pct * (menuItem.max - menuItem.min)
                            val = math.floor(val / menuItem.step + 0.5) * menuItem.step
                            Config[menuItem.key] = math.clamp(val, menuItem.min, menuItem.max)
                        elseif menuItem.type == "keybind" then
                            GUI.EditingKeybind = menuItem.key
                        end
                    end
                    return
                end
            end
        end
    end
    
    
    if not Config.MENU_Open then return end
    if input.UserInputType ~= Enum.UserInputType.Keyboard then return end
    
    local tabItems = {}
    for _, item in ipairs(MenuItems) do
        if item.tab == Config.MENU_Tab then
            table.insert(tabItems, item)
        end
    end
    
    local function isSelectable(item)
        return item.type ~= "label" and item.type ~= "info"
    end
    
    if input.KeyCode == Enum.KeyCode.Up then
        local startIdx = SelectedItem
        repeat
            SelectedItem = SelectedItem - 1
            if SelectedItem < 1 then SelectedItem = #tabItems end
        until isSelectable(tabItems[SelectedItem]) or SelectedItem == startIdx
    elseif input.KeyCode == Enum.KeyCode.Down then
        local startIdx = SelectedItem
        repeat
            SelectedItem = SelectedItem + 1
            if SelectedItem > #tabItems then SelectedItem = 1 end
        until isSelectable(tabItems[SelectedItem]) or SelectedItem == startIdx
    elseif input.KeyCode == Enum.KeyCode.Tab then
        Config.MENU_Tab = Config.MENU_Tab + 1
        if Config.MENU_Tab > #Tabs then Config.MENU_Tab = 1 end
        SelectedItem = 1
        GUI.ScrollOffset = 0
        local newTabItems = {}
        for _, item in ipairs(MenuItems) do
            if item.tab == Config.MENU_Tab then
                table.insert(newTabItems, item)
            end
        end
        for i, item in ipairs(newTabItems) do
            if isSelectable(item) then
                SelectedItem = i
                break
            end
        end
    elseif input.KeyCode == Enum.KeyCode.Return or input.KeyCode == Enum.KeyCode.Space then
        local selectedMenuItem = tabItems[SelectedItem]
        if selectedMenuItem then
            if selectedMenuItem.type == "toggle" then
                Config[selectedMenuItem.key] = not Config[selectedMenuItem.key]
            elseif selectedMenuItem.type == "mode" then
                Config[selectedMenuItem.key] = not Config[selectedMenuItem.key]
            elseif selectedMenuItem.type == "dropdown" then
                local opts = selectedMenuItem.options
                local current = Config[selectedMenuItem.key]
                local idx = 1
                for i, opt in ipairs(opts) do
                    if opt == current then idx = i break end
                end
                idx = idx + 1
                if idx > #opts then idx = 1 end
                Config[selectedMenuItem.key] = opts[idx]
            elseif selectedMenuItem.type == "button" and selectedMenuItem.action then
                selectedMenuItem.action()
            elseif selectedMenuItem.type == "keybind" then
                GUI.EditingKeybind = selectedMenuItem.key
            end
        end
    elseif input.KeyCode == Enum.KeyCode.Left then
        local selectedMenuItem = tabItems[SelectedItem]
        if selectedMenuItem and selectedMenuItem.type == "slider" then
            local newVal = Config[selectedMenuItem.key] - selectedMenuItem.step
            Config[selectedMenuItem.key] = math.clamp(newVal, selectedMenuItem.min, selectedMenuItem.max)
        end
    elseif input.KeyCode == Enum.KeyCode.Right then
        local selectedMenuItem = tabItems[SelectedItem]
        if selectedMenuItem and selectedMenuItem.type == "slider" then
            local newVal = Config[selectedMenuItem.key] + selectedMenuItem.step
            Config[selectedMenuItem.key] = math.clamp(newVal, selectedMenuItem.min, selectedMenuItem.max)
        end
    end
end

local function HandleScroll(input)
    if State.Unloaded then return end
    if not Config.MENU_Open or not GUI.Position then return end
    
    local menuW, menuH = 300, 420
    local sidebarW = 60
    local dragBarH = 22
    local footerH = 30
    
    local mouse = UserInputService:GetMouseLocation()
    local x, y = GUI.Position.X, GUI.Position.Y
    
    if mouse.X >= x + sidebarW and mouse.X <= x + menuW and
       mouse.Y >= y + dragBarH and mouse.Y <= y + menuH - footerH then
        local scrollAmount = input.Position.Z * 40
        GUI.ScrollOffset = math.clamp(GUI.ScrollOffset - scrollAmount, 0, GUI.MaxScroll)
    end
end



local function MainLoop()
    if State.Unloaded then return end
    
    local cam = workspace.CurrentCamera
    if not cam then return end
    
    local screenSize = cam.ViewportSize
    local screenCenter = Vector2.new(screenSize.X / 2, screenSize.Y / 2)
    local now = tick()
    
    if now - State.LastCacheUpdate >= Tuning.CacheRefreshRate then
        State.LastCacheUpdate = now
        ScanMap()
    end
    
    if now - State.LastVisCheck >= Tuning.ESP_VisCheckRate then
        State.LastVisCheck = now
        UpdateVisibility()
    end
    
    ESP.step(cam, screenSize, screenCenter)
    UpdateObjectESP(cam)
    Radar.step(cam)
    
    if Config.AUTO_Generator and GUI.Drawings.AutoGenHint then
        local leaveKey = GetKeyName(Config.KEY_LeaveGen)
        local stopKey = GetKeyName(Config.KEY_StopGen)
        GUI.Drawings.AutoGenHint.Text = "AUTO GEN  |  [" .. leaveKey .. "] Leave  [" .. stopKey .. "] Stop"
        GUI.Drawings.AutoGenHint.Position = Vector2.new(screenSize.X / 2, 30)
        GUI.Drawings.AutoGenHint.Visible = true
    elseif GUI.Drawings.AutoGenHint then
        GUI.Drawings.AutoGenHint.Visible = false
    end
    
   
    Aimbot.Update(cam, screenSize, screenCenter)
    
    
    if GUI.Drawings.FOVCircle then
        if Config.AIM_Enabled and Config.AIM_ShowFOV then
            GUI.Drawings.FOVCircle.Position = screenCenter
            GUI.Drawings.FOVCircle.Radius = Config.AIM_FOV
            GUI.Drawings.FOVCircle.Color = State.AimTarget and Colors.UI_On or Colors.UI_Accent
            GUI.Drawings.FOVCircle.Visible = true
        else
            GUI.Drawings.FOVCircle.Visible = false
        end
    end
    
    GUI.Render()
end

local function UpdateFog()
    if Config.NO_Fog ~= State.LastFogState then
        State.LastFogState = Config.NO_Fog
        if Config.NO_Fog then
            RemoveFog()
        else
            RestoreFog()
        end
    end
end

local function BeatGameSurvivor()
    if not Config.BEAT_Survivor then 
        State.BeatSurvivorDone = false
        State.LastFinishPos = nil
        return 
    end
    if GetRole() ~= "Survivor" then return end
    
    local root = GetCharacterRoot()
    if not root then return end
    
    local map = Workspace:FindFirstChild("Map")
    if not map then return end
    
    
    local exitPos = nil
    
    pcall(function()
        
        if map:FindFirstChild("RooftopHitbox") or map:FindFirstChild("Rooftop") then
            exitPos = Vector3.new(3098.16, 454.04, -4918.74)
            return
        end
        
        
        if map:FindFirstChild("HooksMeat") then
            exitPos = Vector3.new(1546.12, 152.21, -796.72)
            return
        end
        
      
        if map:FindFirstChild("churchbell") then
            exitPos = Vector3.new(760.98, -20.14, -78.48)
            return
        end
        
       
        local finish = map:FindFirstChild("Finishline") or map:FindFirstChild("FinishLine") or map:FindFirstChild("Fininshline")
        if finish then
            if finish:IsA("BasePart") then
                exitPos = finish.Position
            elseif finish:IsA("Model") then
                local part = finish:FindFirstChildWhichIsA("BasePart")
                if part then exitPos = part.Position end
            end
            return
        end
        
        
        for _, obj in ipairs(map:GetDescendants()) do
            if obj.Name:lower():find("finish") then
                if obj:IsA("BasePart") then
                    exitPos = obj.Position
                    break
                elseif obj:IsA("Model") then
                    local part = obj:FindFirstChildWhichIsA("BasePart")
                    if part then 
                        exitPos = part.Position
                        break
                    end
                end
            end
        end
        
        
        if not exitPos then
            for _, obj in ipairs(map:GetDescendants()) do
                if obj:IsA("MeshPart") and obj.Material == Enum.Material.Limestone then
                    exitPos = Vector3.new(-947.90, 152.12, -7579.52)
                    break
                end
            end
        end
        
       
        if not exitPos then
            for _, obj in ipairs(map:GetDescendants()) do
                if obj:IsA("MeshPart") and obj.Material == Enum.Material.Leather then
                    exitPos = Vector3.new(1546.12, 152.21, -796.72)
                    break
                end
            end
        end
    end)
    
    if not exitPos then return end
    
    
    if State.LastFinishPos then
        local dist = (exitPos - State.LastFinishPos).Magnitude
        if dist > 50 then
            State.BeatSurvivorDone = false
        end
    end
    
    
    if State.BeatSurvivorDone then return end
    
    
    root.CFrame = CFrame.new(exitPos + Vector3.new(0, 3, 0))
    
   
    State.BeatSurvivorDone = true
    State.LastFinishPos = exitPos
end

local function GetHealthPercent(hum)
    if not hum or hum.MaxHealth <= 0 then return 0 end
    return hum.Health / hum.MaxHealth
end

local function IsPlayerDowned(hum)
    local pct = GetHealthPercent(hum)
    return pct <= 0.25 and pct > 0
end

local function IsPlayerAlive(hum)
    local pct = GetHealthPercent(hum)
    return pct > 0.25
end

local function BeatGameKiller()
    if not Config.BEAT_Killer then 
        State.KillerTarget = nil
        return 
    end
    if GetRole() ~= "Killer" then 
        State.KillerTarget = nil
        return 
    end
    
    local root = GetCharacterRoot()
    if not root then return end
    
    local target = State.KillerTarget
    local needNewTarget = true
    
    if target and target.Character then
        local targetRoot = target.Character:FindFirstChild("HumanoidRootPart")
        local targetHum = target.Character:FindFirstChildOfClass("Humanoid")
        if targetRoot and targetHum and IsPlayerAlive(targetHum) then
            needNewTarget = false
        else
            State.KillerTarget = nil
        end
    end
    
    if needNewTarget then
        local survivors = {}
        
        for _, player in ipairs(Players:GetPlayers()) do
            if player ~= LocalPlayer and IsSurvivor(player) and player.Character then
                local pRoot = player.Character:FindFirstChild("HumanoidRootPart")
                local pHum = player.Character:FindFirstChildOfClass("Humanoid")
                if pRoot and pHum and IsPlayerAlive(pHum) then
                    table.insert(survivors, player)
                end
            end
        end
        
        if #survivors > 0 then
            local closestDist = math.huge
            local closest = nil
            
            for _, player in ipairs(survivors) do
                local pRoot = player.Character:FindFirstChild("HumanoidRootPart")
                    local dist = (pRoot.Position - root.Position).Magnitude
                    if dist < closestDist then
                        closestDist = dist
                    closest = player
                    end
                end
            
            State.KillerTarget = closest
            target = closest
        else
            State.KillerTarget = nil
            return
        end
    end
    
    if not target or not target.Character then return end
    
    local targetRoot = target.Character:FindFirstChild("HumanoidRootPart")
    local targetHum = target.Character:FindFirstChildOfClass("Humanoid")
    if not targetRoot or not targetHum then 
        State.KillerTarget = nil
        return 
    end
    
    if not IsPlayerAlive(targetHum) then
        State.KillerTarget = nil
        return
    end
    
    for _, part in ipairs(LocalPlayer.Character:GetDescendants()) do
        if part:IsA("BasePart") then part.CanCollide = false end
    end
    
    local targetPos = targetRoot.Position
    local direction = (root.Position - targetPos).Unit
    if direction.Magnitude ~= direction.Magnitude then 
        direction = Vector3.new(1, 0, 0)
    end
    local offsetPos = targetPos + direction * 3 + Vector3.new(0, 1, 0)
    
    root.CFrame = CFrame.new(offsetPos, targetPos)
    
    pcall(function()
        local remotes = ReplicatedStorage:FindFirstChild("Remotes")
        if remotes then
            local attacks = remotes:FindFirstChild("Attacks")
            if attacks then
                local basicAttack = attacks:FindFirstChild("BasicAttack")
                if basicAttack then
                    basicAttack:FireServer(false)
                end
            end
        end
    end)
end

local LastAutoHookTime = 0
local AutoHookState = {
    phase = 0,
    target = nil,
    startTime = 0,
    spamCount = 0
}

local function AutoHook_SpamSpace(duration)
    task.spawn(function()
        local vim = game:GetService("VirtualInputManager")
        local endTime = tick() + duration
        while tick() < endTime do
            pcall(function()
                vim:SendKeyEvent(true, Enum.KeyCode.Space, false, game)
                task.wait(0.05)
                vim:SendKeyEvent(false, Enum.KeyCode.Space, false, game)
            end)
            task.wait(0.08)
        end
    end)
end

local function AutoHook_LookAt(targetPos)
    local cam = workspace.CurrentCamera
    if not cam then return end
    local root = GetCharacterRoot()
    if not root then return end
    cam.CFrame = CFrame.new(cam.CFrame.Position, targetPos)
end

local function AutoHook_IsHookOccupied(hook)
    if not hook or not hook.part then return true end
    
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and IsSurvivor(player) and player.Character then
            local pRoot = player.Character:FindFirstChild("HumanoidRootPart")
            if pRoot then
                local dist = (pRoot.Position - hook.part.Position).Magnitude
                if dist < 8 then
                    return true
                end
            end
        end
    end
    return false
end

local function AutoHook_FindBestHook()
    local root = GetCharacterRoot()
    if not root then return nil end
    
    local bestHook = nil
    local bestDist = math.huge
    
    for _, hook in ipairs(Cache.Hooks) do
        if hook.part and hook.part.Parent then
            if not AutoHook_IsHookOccupied(hook) then
                local dist = (hook.part.Position - root.Position).Magnitude
                if dist < bestDist then
                    bestDist = dist
                    bestHook = hook
                end
            end
        end
    end
    
    return bestHook
end

local function AutoHook()
    if not Config.KILLER_AutoHook then 
        AutoHookState.phase = 0
        AutoHookState.target = nil
        return 
    end
    if GetRole() ~= "Killer" then 
        AutoHookState.phase = 0
        AutoHookState.target = nil
        return 
    end
    
    local root = GetCharacterRoot()
    if not root then return end
    
    local char = LocalPlayer.Character
    if not char then return end
    
    if AutoHookState.phase == 3 then
        if tick() - AutoHookState.startTime > 2 then
            AutoHookState.phase = 0
            AutoHookState.target = nil
            LastAutoHookTime = tick()
        end
        return
    end
    
    if AutoHookState.phase == 2 then
        local hook = AutoHook_FindBestHook()
        if hook and hook.part then
            for _, part in ipairs(char:GetDescendants()) do
                if part:IsA("BasePart") then part.CanCollide = false end
            end
            
            local hookPos = hook.part.Position
            root.CFrame = CFrame.new(hookPos + Vector3.new(0, 2, 0), hookPos)
            AutoHook_LookAt(hookPos)
            AutoHook_SpamSpace(1.5)
            
            task.delay(0.3, function()
                if LocalPlayer.Character then
                    for _, part in ipairs(LocalPlayer.Character:GetDescendants()) do
                        if part:IsA("BasePart") and part.Name ~= "HumanoidRootPart" then
                            part.CanCollide = true
                        end
                    end
                end
            end)
            
            AutoHookState.phase = 3
            AutoHookState.startTime = tick()
        else
            AutoHookState.phase = 0
            AutoHookState.target = nil
        end
        return
    end
    
    if AutoHookState.phase == 1 then
        if tick() - AutoHookState.startTime > 1.5 then
            AutoHookState.phase = 2
        end
        return
    end
    
    if tick() - LastAutoHookTime < 0.5 then return end
    
    local closestDowned = nil
    local closestDist = math.huge
    
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and IsSurvivor(player) and player.Character then
            local targetRoot = player.Character:FindFirstChild("HumanoidRootPart")
            local targetHum = player.Character:FindFirstChildOfClass("Humanoid")
            if targetRoot and targetHum and IsPlayerDowned(targetHum) then
                local dist = (targetRoot.Position - root.Position).Magnitude
                if dist < closestDist then
                    closestDist = dist
                    closestDowned = {player = player, root = targetRoot}
                end
            end
        end
    end
    
    if closestDowned then
        for _, part in ipairs(char:GetDescendants()) do
            if part:IsA("BasePart") then part.CanCollide = false end
        end
        
        local targetPos = closestDowned.root.Position
        root.CFrame = CFrame.new(targetPos + Vector3.new(0, 3, 0), targetPos + Vector3.new(0, -5, 0))
        
        AutoHook_LookAt(targetPos)
        AutoHook_SpamSpace(1.5)
        
        AutoHookState.phase = 1
        AutoHookState.target = closestDowned.player
        AutoHookState.startTime = tick()
        
        task.delay(0.5, function()
            if LocalPlayer.Character then
                for _, part in ipairs(LocalPlayer.Character:GetDescendants()) do
                    if part:IsA("BasePart") and part.Name ~= "HumanoidRootPart" then
                        part.CanCollide = true
                    end
                end
            end
        end)
    end
end

local function AutoLoop()
    while not State.Unloaded do
        AutoAttack()
        TeleportAway()
        UpdateNoFall()
        AutoWiggle()
        DoubleTap()
        UpdateNoSlowdown()
        AutoHook()
        
        UpdateSpeed()
        UpdateNoclip()
        UpdateFly()
        UpdateJumpPower()
        
       
        UpdateFog()
        UpdateCameraFOV()
        UpdateThirdPerson()
        UpdateShiftLock()
        
       
        UpdateHitboxes()
        UpdateSpearAim()
        
        
        BeatGameSurvivor()
        BeatGameKiller()
        
        task.wait(0.1)
    end
end


Unload = function()
    State.Unloaded = true
    Config.AUTO_Generator = false
    Config.AUTO_Attack = false
    Config.AUTO_TeleAway = false
    Config.SPEED_Enabled = false
    Config.NOCLIP_Enabled = false
    Config.BEAT_Survivor = false
    Config.BEAT_Killer = false
    Config.HITBOX_Enabled = false
    Config.FLY_Enabled = false
    Config.FLING_Enabled = false
    Config.KILLER_DoubleTap = false
    Config.KILLER_InfiniteLunge = false
    Config.KILLER_AutoHook = false
    Config.AUTO_SkillCheck = false
    State.KillerTarget = nil
    AutoHookState.phase = 0
    AutoHookState.target = nil
    
    pcall(QTE_StopMonitoring)
    if QTEHandler.UIConn then
        pcall(function() QTEHandler.UIConn:Disconnect() end)
        QTEHandler.UIConn = nil
    end
    
    
    for player, originalSize in pairs(OriginalHitboxSizes) do
        pcall(function()
            if player and player.Character then
                local root = player.Character:FindFirstChild("HumanoidRootPart")
                if root then
                    root.Size = originalSize
                    root.Transparency = 1
                    root.CanCollide = true
                end
            end
        end)
    end
    OriginalHitboxSizes = {}
    
    
    pcall(function()
        local hum = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
        if hum then hum.WalkSpeed = State.OriginalSpeed end
    end)
    
  
    pcall(function()
        local hum = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
        if hum and OriginalJumpPower then hum.JumpPower = OriginalJumpPower end
    end)
    
    
    pcall(function()
        local cam = workspace.CurrentCamera
        if cam and OriginalFOV then cam.FieldOfView = OriginalFOV end
    end)
    
    
    pcall(function()
        local hum = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
        if hum then hum.CameraOffset = Vector3.new(0, 0, 0) end
        local cam = workspace.CurrentCamera
        if cam and OriginalCameraType then cam.CameraType = OriginalCameraType end
    end)
    
    
    pcall(function()
        if FlyBodyVelocity then FlyBodyVelocity:Destroy() end
        if FlyBodyGyro then FlyBodyGyro:Destroy() end
        local hum = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
        if hum then hum.PlatformStand = false end
    end)
    
    
    pcall(function()
        if InfiniteJumpConnection then InfiniteJumpConnection:Disconnect() end
    end)
    
    
    pcall(function()
        local char = LocalPlayer.Character
        if char then
            for _, part in ipairs(char:GetDescendants()) do
                if part:IsA("BasePart") and part.Name ~= "HumanoidRootPart" then
                    part.CanCollide = true
                end
            end
        end
    end)
    
   
    if Config.NO_Fog then
        RestoreFog()
    end
    
    
    for name, conn in pairs(Connections) do
        if conn then 
            pcall(function() conn:Disconnect() end)
            Connections[name] = nil
        end
    end
    
    
    for _, esp in pairs(ESP.cache) do
        ESP.destroy(esp)
    end
    ESP.cache = {}
    
    
    for _, esp in pairs(ESP.objectCache) do
        ESP.destroyObject(esp)
    end
    ESP.objectCache = {}
    
    
    Chams.ClearAll()
    
   
    pcall(function()
        for _, obj in pairs(workspace:GetDescendants()) do
            if obj.Name == "_ViolenceChams" or obj.Name == "_ViolenceLabel" then
                pcall(function() obj:Destroy() end)
            end
        end
        for _, player in pairs(Players:GetPlayers()) do
            if player.Character then
                local c = player.Character:FindFirstChild("_ViolenceChams")
                if c then c:Destroy() end
                local l = player.Character:FindFirstChild("_ViolenceLabel")
                if l then l:Destroy() end
            end
        end
    end)
    
    pcall(function()
        Radar.bg:Remove()
        Radar.circleBg:Remove()
        Radar.border:Remove()
        Radar.circleBorder:Remove()
        Radar.cross1:Remove()
        Radar.cross2:Remove()
        Radar.center:Remove()
        for _, d in pairs(Radar.dots) do
            if d then d:Remove() end
        end
        for _, d in pairs(Radar.objectDots) do
            if d then d:Remove() end
        end
        for _, d in pairs(Radar.palletSquares) do
            if d then d:Remove() end
        end
    end)
    
    for _, drawing in pairs(GUI.Drawings) do
        if type(drawing) == "table" then
            for _, subDrawing in pairs(drawing) do
                if type(subDrawing) == "table" then
                    for _, d in pairs(subDrawing) do
                        SafeRemove(d)
                    end
                else
                    SafeRemove(subDrawing)
                end
            end
        else
            SafeRemove(drawing)
        end
    end
    GUI.Drawings = {}
end


local function Init()
    GUI.Create()
    ScanMap()
    pcall(SetupAntiBlind)
    pcall(SetupNoPalletStun)
    pcall(SetupInfiniteJump)
    pcall(SetupSkillCheckMonitor)
    
    Connections.Input = UserInputService.InputBegan:Connect(HandleInput)
    
    Connections.InputEnd = UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            GUI.Dragging = false
            GUI.ScrollbarDragging = false
        end
        
        
        if input.UserInputType == Enum.UserInputType.MouseButton2 then
            if Config.AIM_UseRMB then
                State.AimHolding = false
                State.AimTarget = nil
            end
        end
    end)
    
    Connections.InputChanged = UserInputService.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseWheel then
            HandleScroll(input)
        elseif input.UserInputType == Enum.UserInputType.MouseMovement then
            if GUI.ScrollbarDragging and GUI.ScrollbarBounds and GUI.MaxScroll > 0 then
                local mouse = UserInputService:GetMouseLocation()
                local sb = GUI.ScrollbarBounds
                local pct = math.clamp((mouse.Y - sb.y) / sb.h, 0, 1)
                GUI.ScrollOffset = pct * GUI.MaxScroll
            end
        end
    end)
    
    Connections.Render = RunService.RenderStepped:Connect(MainLoop)
    
    task.spawn(AutoLoop)
    
    task.spawn(function()
        local repairRemote, skillRemote
        local lastScan = 0
        local genPoints = {}
        
        while not State.Unloaded do
            if Config.AUTO_Generator then
              
                if not repairRemote then
                    local r = ReplicatedStorage:FindFirstChild("Remotes")
                    local g = r and r:FindFirstChild("Generator")
                    repairRemote = g and g:FindFirstChild("RepairEvent")
                    skillRemote = g and g:FindFirstChild("SkillCheckResultEvent")
                end
                
               
                if tick() - lastScan > 2 then
                    genPoints = {}
                    local m = Workspace:FindFirstChild("Map")
                    if m then
                        for _, v in ipairs(m:GetDescendants()) do
                            if v:IsA("Model") and v.Name == "Generator" then
                                for _, c in ipairs(v:GetChildren()) do
                                    if c.Name:match("GeneratorPoint") then
                                        table.insert(genPoints, {gen = v, pt = c})
                                    end
                                end
                            end
                        end
                    end
                    lastScan = tick()
                end
                
              
                if repairRemote and skillRemote then
                    local mode = Config.AUTO_GenMode == "Fast"
                    for _, data in ipairs(genPoints) do
                        pcall(repairRemote.FireServer, repairRemote, data.pt, true)
                        pcall(skillRemote.FireServer, skillRemote, mode and "success" or "neutral", mode and 1 or 0, data.gen, data.pt)
                    end
                end
            end
            task.wait(0.15)
        end
    end)
    
    Connections.PlayerLeft = Players.PlayerRemoving:Connect(function(player)
        if ESP.cache[player] then
            ESP.hide(ESP.cache[player])
            ESP.destroy(ESP.cache[player])
            ESP.cache[player] = nil
        end
        if player.Character then
            Chams.Remove(player.Character)
        end
        Cache.Visibility[player] = nil
    end)
    
    Connections.PlayerAdded = Players.PlayerAdded:Connect(function(player)
        player.CharacterAdded:Connect(function()
            task.wait(1)
            ScanMap()
        end)
    end)
end

Init()
