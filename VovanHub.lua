-- VovanHub v2.0 — MM2
-- Aimbot, Wallbang, ESP, Spinner, Bhop, Auto-Shoot

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local Lighting = game:GetService("Lighting")
local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()
local Camera = Workspace.CurrentCamera

-- =============================================
-- НАСТРОЙКИ
-- =============================================
local SETTINGS = {
    -- Aimbot
    Enabled = true,
    Wallbang = true,
    AutoShoot = true,
    TargetMurderer = true,
    TargetSheriff = false,
    FOV = 360,
    Smoothness = 0.15,
    ShootDelay = 0.08,
    -- ESP
    ESPEnabled = true,
    ESPMurderer = true,
    ESPSheriff = true,
    ESPInnocent = true,
    ESPShowDistance = true,
    ESPShowName = true,
    -- Spinner
    SpinnerEnabled = false,
    SpinnerSpeed = 50,
    -- Bhop
    BhopEnabled = false,
    BhopSpeed = 100,
    -- Misc
    EarlyRoleDetect = true,
}

-- =============================================
-- ЦВЕТА VOVANHUB
-- =============================================
local C = {
    Bg = Color3.fromRGB(10, 10, 14),
    Panel = Color3.fromRGB(18, 18, 26),
    PanelLight = Color3.fromRGB(26, 26, 38),
    Card = Color3.fromRGB(22, 22, 32),
    Accent = Color3.fromRGB(255, 45, 85),
    Accent2 = Color3.fromRGB(120, 60, 255),
    Accent3 = Color3.fromRGB(0, 220, 255),
    Text = Color3.fromRGB(245, 245, 255),
    TextDim = Color3.fromRGB(130, 130, 155),
    ToggleOn = Color3.fromRGB(255, 45, 85),
    ToggleOff = Color3.fromRGB(45, 45, 60),
    Success = Color3.fromRGB(80, 240, 120),
    Danger = Color3.fromRGB(255, 60, 60),
    Innocent = Color3.fromRGB(80, 240, 120),   -- зелёный
    Murderer = Color3.fromRGB(255, 60, 60),    -- красный
    Sheriff = Color3.fromRGB(60, 140, 255),    -- синий
}

-- =============================================
-- РАННЕЕ ОПРЕДЕЛЕНИЕ РОЛЕЙ
-- =============================================
local roleCache = {}

local function getRole(player)
    if not player or not player.Character then return "Innocent" end
    if roleCache[player] then return roleCache[player] end
    
    local bp = player:FindFirstChild("Backpack")
    if bp then
        if bp:FindFirstChild("Knife") then
            roleCache[player] = "Murderer"
            return "Murderer"
        end
        if bp:FindFirstChild("Gun") then
            roleCache[player] = "Sheriff"
            return "Sheriff"
        end
    end
    local char = player.Character
    if char:FindFirstChild("Knife") then
        roleCache[player] = "Murderer"
        return "Murderer"
    end
    if char:FindFirstChild("Gun") then
        roleCache[player] = "Sheriff"
        return "Sheriff"
    end
    
    return "Innocent"
end

-- Следим за новыми инструментами (раннее определение)
for _, player in pairs(Players:GetPlayers()) do
    if player ~= LocalPlayer then
        player.CharacterAdded:Connect(function(char)
            roleCache[player] = nil
            char.ChildAdded:Connect(function(child)
                if child.Name == "Knife" then
                    roleCache[player] = "Murderer"
                elseif child.Name == "Gun" then
                    roleCache[player] = "Sheriff"
                end
            end)
        end)
    end
end
Players.PlayerAdded:Connect(function(player)
    if player ~= LocalPlayer then
        player.CharacterAdded:Connect(function(char)
            roleCache[player] = nil
            char.ChildAdded:Connect(function(child)
                if child.Name == "Knife" then
                    roleCache[player] = "Murderer"
                elseif child.Name == "Gun" then
                    roleCache[player] = "Sheriff"
                end
            end)
        end)
    end
end)

-- =============================================
-- UI LIBRARY — VOVANHUB
-- =============================================
local UI = {}
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "VovanHub"
screenGui.ResetOnSpawn = false
screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
screenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")

-- Главное окно
local main = Instance.new("Frame")
main.Name = "Main"
main.Size = UDim2.new(0, 620, 0, 420)
main.Position = UDim2.new(0.5, -310, 0.5, -210)
main.BackgroundColor3 = C.Bg
main.BorderSizePixel = 0
main.Parent = screenGui

local mainCorner = Instance.new("UICorner")
mainCorner.CornerRadius = UDim.new(0, 12)
mainCorner.Parent = main

local mainStroke = Instance.new("UIStroke")
mainStroke.Color = C.Accent
mainStroke.Thickness = 1.5
mainStroke.Transparency = 0.4
mainStroke.Parent = main

-- Градиент фона
local bgGradient = Instance.new("UIGradient")
bgGradient.Color = ColorSequence.new{
    ColorSequenceKeypoint.new(0, C.Bg),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(20, 15, 30))
}
bgGradient.Rotation = 45
bgGradient.Parent = main

-- Заголовок
local header = Instance.new("Frame")
header.Size = UDim2.new(1, 0, 0, 52)
header.BackgroundColor3 = C.Panel
header.BorderSizePixel = 0
header.Parent = main

local headerCorner = Instance.new("UICorner")
headerCorner.CornerRadius = UDim.new(0, 12)
headerCorner.Parent = header

local headerFix = Instance.new("Frame")
headerFix.Size = UDim2.new(1, 0, 0, 15)
headerFix.Position = UDim2.new(0, 0, 1, -15)
headerFix.BackgroundColor3 = C.Panel
headerFix.BorderSizePixel = 0
headerFix.Parent = header

-- Логотип
local logo = Instance.new("TextLabel")
logo.Size = UDim2.new(0, 40, 0, 40)
logo.Position = UDim2.new(0, 14, 0, 6)
logo.BackgroundColor3 = C.Accent
logo.Text = "V"
logo.TextColor3 = C.Text
logo.Font = Enum.Font.GothamBlack
logo.TextSize = 22
logo.Parent = header

local logoCorner = Instance.new("UICorner")
logoCorner.CornerRadius = UDim.new(0, 8)
logoCorner.Parent = logo

-- Название
local title = Instance.new("TextLabel")
title.Size = UDim2.new(0, 300, 0, 24)
title.Position = UDim2.new(0, 64, 0, 8)
title.BackgroundTransparency = 1
title.Text = "VOVANHUB"
title.TextColor3 = C.Text
title.Font = Enum.Font.GothamBlack
title.TextSize = 20
title.TextXAlignment = Enum.TextXAlignment.Left
title.Parent = header

local subtitle = Instance.new("TextLabel")
subtitle.Size = UDim2.new(0, 300, 0, 16)
subtitle.Position = UDim2.new(0, 64, 0, 30)
subtitle.BackgroundTransparency = 1
subtitle.Text = "MM2  •  v2.0  •  Undetected"
subtitle.TextColor3 = C.TextDim
subtitle.Font = Enum.Font.Gotham
subtitle.TextSize = 11
subtitle.TextXAlignment = Enum.TextXAlignment.Left
subtitle.Parent = header

-- Статус
local status = Instance.new("TextLabel")
status.Size = UDim2.new(0, 100, 0, 20)
status.Position = UDim2.new(1, -150, 0, 16)
status.BackgroundColor3 = C.Success
status.Text = "● ONLINE"
status.TextColor3 = C.Text
status.Font = Enum.Font.GothamBold
status.TextSize = 11
status.Parent = header

local statusCorner = Instance.new("UICorner")
statusCorner.CornerRadius = UDim.new(1, 0)
statusCorner.Parent = status

-- Кнопка закрытия
local closeBtn = Instance.new("TextButton")
closeBtn.Size = UDim2.new(0, 30, 0, 30)
closeBtn.Position = UDim2.new(1, -40, 0, 11)
closeBtn.BackgroundColor3 = C.PanelLight
closeBtn.Text = "✕"
closeBtn.TextColor3 = C.Text
closeBtn.Font = Enum.Font.GothamBold
closeBtn.TextSize = 14
closeBtn.Parent = header

local closeCorner = Instance.new("UICorner")
closeCorner.CornerRadius = UDim.new(0, 8)
closeCorner.Parent = closeBtn

-- Боковая панель
local sidebar = Instance.new("Frame")
sidebar.Size = UDim2.new(0, 160, 1, -52)
sidebar.Position = UDim2.new(0, 0, 0, 52)
sidebar.BackgroundColor3 = C.Panel
sidebar.BorderSizePixel = 0
sidebar.Parent = main

local sidebarFix = Instance.new("Frame")
sidebarFix.Size = UDim2.new(0, 15, 1, 0)
sidebarFix.Position = UDim2.new(1, -15, 0, 0)
sidebarFix.BackgroundColor3 = C.Panel
sidebarFix.BorderSizePixel = 0
sidebarFix.Parent = sidebar

-- Контент
local content = Instance.new("Frame")
content.Size = UDim2.new(1, -160, 1, -52)
content.Position = UDim2.new(0, 160, 0, 52)
content.BackgroundTransparency = 1
content.Parent = main

-- =============================================
-- КАТЕГОРИИ
-- =============================================
local categories = {}
local categoryButtons = {}

function UI.createCategory(name, icon)
    local page = Instance.new("ScrollingFrame")
    page.Size = UDim2.new(1, -24, 1, -24)
    page.Position = UDim2.new(0, 12, 0, 12)
    page.BackgroundTransparency = 1
    page.BorderSizePixel = 0
    page.ScrollBarThickness = 4
    page.ScrollBarImageColor3 = C.Accent
    page.CanvasSize = UDim2.new(0, 0, 0, 0)
    page.AutomaticCanvasSize = Enum.AutomaticSize.Y
    page.Visible = false
    page.Parent = content
    
    local layout = Instance.new("UIListLayout")
    layout.Padding = UDim.new(0, 8)
    layout.SortOrder = Enum.SortOrder.LayoutOrder
    layout.Parent = page
    
    categories[name] = page
    
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, -12, 0, 40)
    btn.Position = UDim2.new(0, 6, 0, 6 + (#categoryButtons * 46))
    btn.BackgroundColor3 = C.Panel
    btn.Text = "  " .. icon .. "  " .. name
    btn.TextColor3 = C.TextDim
    btn.Font = Enum.Font.GothamBold
    btn.TextSize = 13
    btn.TextXAlignment = Enum.TextXAlignment.Left
    btn.Parent = sidebar
    
    local btnCorner = Instance.new("UICorner")
    btnCorner.CornerRadius = UDim.new(0, 8)
    btnCorner.Parent = btn
    
    table.insert(categoryButtons, btn)
    
    btn.MouseButton1Click:Connect(function()
        UI.switchCategory(name)
    end)
    
    return page
end

function UI.switchCategory(name)
    for catName, page in pairs(categories) do
        page.Visible = (catName == name)
    end
    for _, btn in pairs(categoryButtons) do
        if btn.Text:find(name) then
            TweenService:Create(btn, TweenInfo.new(0.2), {BackgroundColor3 = C.Accent}):Play()
            TweenService:Create(btn, TweenInfo.new(0.2), {TextColor3 = C.Text}):Play()
        else
            TweenService:Create(btn, TweenInfo.new(0.2), {BackgroundColor3 = C.Panel}):Play()
            TweenService:Create(btn, TweenInfo.new(0.2), {TextColor3 = C.TextDim}):Play()
        end
    end
end

-- =============================================
-- ЭЛЕМЕНТЫ UI
-- =============================================
function UI.createToggle(parent, name, default, callback)
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1, 0, 0, 40)
    frame.BackgroundColor3 = C.Card
    frame.BorderSizePixel = 0
    frame.Parent = parent
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 8)
    corner.Parent = frame
    
    local stroke = Instance.new("UIStroke")
    stroke.Color = C.PanelLight
    stroke.Thickness = 1
    stroke.Transparency = 0.5
    stroke.Parent = frame
    
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, -70, 1, 0)
    label.Position = UDim2.new(0, 14, 0, 0)
    label.BackgroundTransparency = 1
    label.Text = name
    label.TextColor3 = C.Text
    label.Font = Enum.Font.Gotham
    label.TextSize = 13
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = frame
    
    local toggle = Instance.new("Frame")
    toggle.Size = UDim2.new(0, 44, 0, 22)
    toggle.Position = UDim2.new(1, -58, 0.5, -11)
    toggle.BackgroundColor3 = default and C.ToggleOn or C.ToggleOff
    toggle.Parent = frame
    
    local toggleCorner = Instance.new("UICorner")
    toggleCorner.CornerRadius = UDim.new(1, 0)
    toggleCorner.Parent = toggle
    
    local knob = Instance.new("Frame")
    knob.Size = UDim2.new(0, 18, 0, 18)
    knob.Position = default and UDim2.new(1, -20, 0.5, -9) or UDim2.new(0, 2, 0.5, -9)
    knob.BackgroundColor3 = C.Text
    knob.Parent = toggle
    
    local knobCorner = Instance.new("UICorner")
    knobCorner.CornerRadius = UDim.new(1, 0)
    knobCorner.Parent = knob
    
    local state = default
    
    local clickBtn = Instance.new("TextButton")
    clickBtn.Size = UDim2.new(1, 0, 1, 0)
    clickBtn.BackgroundTransparency = 1
    clickBtn.Text = ""
    clickBtn.Parent = frame
    
    clickBtn.MouseButton1Click:Connect(function()
        state = not state
        TweenService:Create(toggle, TweenInfo.new(0.2), {BackgroundColor3 = state and C.ToggleOn or C.ToggleOff}):Play()
        TweenService:Create(knob, TweenInfo.new(0.2), {Position = state and UDim2.new(1, -20, 0.5, -9) or UDim2.new(0, 2, 0.5, -9)}):Play()
        callback(state)
    end)
end

function UI.createSlider(parent, name, min, max, default, callback)
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1, 0, 0, 54)
    frame.BackgroundColor3 = C.Card
    frame.BorderSizePixel = 0
    frame.Parent = parent
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 8)
    corner.Parent = frame
    
    local stroke = Instance.new("UIStroke")
    stroke.Color = C.PanelLight
    stroke.Thickness = 1
    stroke.Transparency = 0.5
    stroke.Parent = frame
    
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, -24, 0, 24)
    label.Position = UDim2.new(0, 14, 0, 4)
    label.BackgroundTransparency = 1
    label.Text = name .. ": " .. default
    label.TextColor3 = C.Text
    label.Font = Enum.Font.Gotham
    label.TextSize = 13
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = frame
    
    local barBg = Instance.new("Frame")
    barBg.Size = UDim2.new(1, -28, 0, 8)
    barBg.Position = UDim2.new(0, 14, 0, 36)
    barBg.BackgroundColor3 = C.ToggleOff
    barBg.BorderSizePixel = 0
    barBg.Parent = frame
    
    local barCorner = Instance.new("UICorner")
    barCorner.CornerRadius = UDim.new(1, 0)
    barCorner.Parent = barBg
    
    local fill = Instance.new("Frame")
    fill.Size = UDim2.new((default - min) / (max - min), 0, 1, 0)
    fill.BackgroundColor3 = C.Accent
    fill.BorderSizePixel = 0
    fill.Parent = barBg
    
    local fillCorner = Instance.new("UICorner")
    fillCorner.CornerRadius = UDim.new(1, 0)
    fillCorner.Parent = fill
    
    local drag = false
    
    local clickArea = Instance.new("TextButton")
    clickArea.Size = UDim2.new(1, -28, 0, 24)
    clickArea.Position = UDim2.new(0, 14, 0, 28)
    clickArea.BackgroundTransparency = 1
    clickArea.Text = ""
    clickArea.Parent = frame
    
    local function update(x)
        local rel = math.clamp((x - barBg.AbsolutePosition.X) / barBg.AbsoluteSize.X, 0, 1)
        local val = min + (max - min) * rel
        val = math.floor(val * 100) / 100
        fill.Size = UDim2.new(rel, 0, 1, 0)
        label.Text = name .. ": " .. val
        callback(val)
    end
    
    clickArea.MouseButton1Down:Connect(function()
        drag = true
        update(Mouse.X)
    end)
    
    UserInputService.InputChanged:Connect(function(input)
        if drag and input.UserInputType == Enum.UserInputType.MouseMovement then
            update(Mouse.X)
        end
    end)
    
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            drag = false
        end
    end)
end

function UI.createLabel(parent, text, color, size)
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, 0, 0, size or 30)
    label.BackgroundColor3 = C.Card
    label.Text = text
    label.TextColor3 = color or C.TextDim
    label.Font = Enum.Font.GothamBold
    label.TextSize = 12
    label.Parent = parent
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 8)
    corner.Parent = label
    
    return label
end

-- =============================================
-- СТРАНИЦЫ
-- =============================================

-- Combat
local combat = UI.createCategory("Combat", "⚔")
UI.createLabel(combat, "  AIMBOT", C.Accent, 32)
UI.createToggle(combat, "Enabled", SETTINGS.Enabled, function(v) SETTINGS.Enabled = v end)
UI.createToggle(combat, "Wallbang (сквозь стены)", SETTINGS.Wallbang, function(v) SETTINGS.Wallbang = v end)
UI.createToggle(combat, "Auto Shoot", SETTINGS.AutoShoot, function(v) SETTINGS.AutoShoot = v end)
UI.createToggle(combat, "Target Murderer", SETTINGS.TargetMurderer, function(v) SETTINGS.TargetMurderer = v end)
UI.createToggle(combat, "Target Sheriff", SETTINGS.TargetSheriff, function(v) SETTINGS.TargetSheriff = v end)
UI.createSlider(combat, "FOV", 0, 360, SETTINGS.FOV, function(v) SETTINGS.FOV = v end)
UI.createSlider(combat, "Smoothness", 0, 1, SETTINGS.Smoothness, function(v) SETTINGS.Smoothness = v end)
UI.createSlider(combat, "Shoot Delay", 0.01, 0.5, SETTINGS.ShootDelay, function(v) SETTINGS.ShootDelay = v end)

-- Visuals
local visuals = UI.createCategory("Visuals", "👁")
UI.createLabel(visuals, "  ESP (WALLHACK)", C.Accent, 32)
UI.createToggle(visuals, "ESP Enabled", SETTINGS.ESPEnabled, function(v) SETTINGS.ESPEnabled = v end)
UI.createToggle(visuals, "Показывать Murderer", SETTINGS.ESPMurderer, function(v) SETTINGS.ESPMurderer = v end)
UI.createToggle(visuals, "Показывать Sheriff", SETTINGS.ESPSheriff, function(v) SETTINGS.ESPSheriff = v end)
UI.createToggle(visuals, "Показывать Innocent", SETTINGS.ESPInnocent, function(v) SETTINGS.ESPInnocent = v end)
UI.createToggle(visuals, "Показывать дистанцию", SETTINGS.ESPShowDistance, function(v) SETTINGS.ESPShowDistance = v end)
UI.createToggle(visuals, "Показывать имя", SETTINGS.ESPShowName, function(v) SETTINGS.ESPShowName = v end)

-- Movement
local movement = UI.createCategory("Movement", "🏃")
UI.createLabel(movement, "  SPINNER", C.Accent, 32)
UI.createToggle(movement, "Spinner Enabled", SETTINGS.SpinnerEnabled, function(v) SETTINGS.SpinnerEnabled = v end)
UI.createSlider(movement, "Spinner Speed", 1, 200, SETTINGS.SpinnerSpeed, function(v) SETTINGS.SpinnerSpeed = v end)
UI.createLabel(movement, "  BHOP", C.Accent, 32)
UI.createToggle(movement, "Bhop Enabled", SETTINGS.BhopEnabled, function(v) SETTINGS.BhopEnabled = v end)
UI.createSlider(movement, "Bhop Speed", 16, 1000, SETTINGS.BhopSpeed, function(v) SETTINGS.BhopSpeed = v end)

-- Misc
local misc = UI.createCategory("Misc", "⚙")
UI.createLabel(misc, "  SETTINGS", C.Accent, 32)
UI.createToggle(misc, "Early Role Detect", SETTINGS.EarlyRoleDetect, function(v) SETTINGS.EarlyRoleDetect = v end)

-- Info
local info = UI.createCategory("Info", "ℹ")
UI.createLabel(info, "  VOVANHUB v2.0", C.Accent, 32)
UI.createLabel(info, "  Status: Undetected", C.Success)
UI.createLabel(info, "  Insert — toggle menu", C.TextDim)
UI.createLabel(info, "  Made by Vovan", C.Accent2)
UI.createLabel(info, "  Only for alt accounts", C.Danger)

UI.switchCategory("Combat")

-- =============================================
-- ПЕРЕТАСКИВАНИЕ
-- =============================================
local dragging = false
local dragStart, startPos

header.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = true
        dragStart = input.Position
        startPos = main.Position
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
        local delta = input.Position - dragStart
        main.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end)

UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = false
    end
end)

-- =============================================
-- ОТКРЫТИЕ/ЗАКРЫТИЕ
-- =============================================
local menuOpen = true

UserInputService.InputBegan:Connect(function(input, gp)
    if gp then return end
    if input.KeyCode == Enum.KeyCode.Insert then
        menuOpen = not menuOpen
        if menuOpen then
            main.Visible = true
            main.Size = UDim2.new(0, 0, 0, 0)
            TweenService:Create(main, TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
                Size = UDim2.new(0, 620, 0, 420)
            }):Play()
        else
            TweenService:Create(main, TweenInfo.new(0.2), {
                Size = UDim2.new(0, 0, 0, 0)
            }):Play()
            task.wait(0.2)
            main.Visible = false
        end
    end
end)

closeBtn.MouseButton1Click:Connect(function()
    menuOpen = false
    TweenService:Create(main, TweenInfo.new(0.2), {Size = UDim2.new(0, 0, 0, 0)}):Play()
    task.wait(0.2)
    main.Visible = false
end)

-- =============================================
-- AIMBOT
-- =============================================
local lastShot = 0

local function findTarget()
    local closest = nil
    local shortestDist = math.huge
    local mousePos = Vector2.new(Mouse.X, Mouse.Y)
    
    for _, player in pairs(Players:GetPlayers()) do
        if player == LocalPlayer then continue end
        if not player.Character then continue end
        
        local humanoid = player.Character:FindFirstChild("Humanoid")
        local head = player.Character:FindFirstChild("Head")
        
        if not humanoid or not head or humanoid.Health <= 0 then continue end
        
        local role = getRole(player)
        if SETTINGS.TargetMurderer and role == "Murderer" then
        elseif SETTINGS.TargetSheriff and role == "Sheriff" then
        else continue end
        
        local screenPos, onScreen = Camera:WorldToViewportPoint(head.Position)
        if not onScreen and not SETTINGS.Wallbang then continue end
        
        local dist = (mousePos - Vector2.new(screenPos.X, screenPos.Y)).Magnitude
        if dist < SETTINGS.FOV and dist < shortestDist then
            shortestDist = dist
            closest = player
        end
    end
    return closest
end

local function aimAt(target)
    if not target or not target.Character then return end
    local head = target.Character:FindFirstChild("Head")
    if not head then return end
    
    if SETTINGS.Wallbang then
        Camera.CFrame = CFrame.new(Camera.CFrame.Position, head.Position)
    else
        local cur = Camera.CFrame
        local tgt = CFrame.new(cur.Position, head.Position)
        Camera.CFrame = cur:Lerp(tgt, 1 - SETTINGS.Smoothness)
    end
end

local function shoot()
    local now = tick()
    if now - lastShot < SETTINGS.ShootDelay then return end
    lastShot = now
    local tool = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Tool")
    if tool then tool:Activate() end
end

RunService.RenderStepped:Connect(function()
    if not SETTINGS.Enabled then return end
    local target = findTarget()
    if target then
        aimAt(target)
        if SETTINGS.AutoShoot then
            local myRole = getRole(LocalPlayer)
            if myRole == "Murderer" or myRole == "Sheriff" then
                shoot()
            end
        end
    end
end)

-- =============================================
-- ESP (WALLHACK)
-- =============================================
local espBoxes = {}

local function clearESP()
    for _, box in pairs(espBoxes) do
        if box then box:Destroy() end
    end
    espBoxes = {}
end

RunService.RenderStepped:Connect(function()
    if not SETTINGS.ESPEnabled then
        clearESP()
        return
    end
    
    for _, player in pairs(Players:GetPlayers()) do
        if player == LocalPlayer then continue end
        if not player.Character then continue end
        
        local head = player.Character:FindFirstChild("Head")
        local hrp = player.Character:FindFirstChild("HumanoidRootPart")
        if not head or not hrp then continue end
        
        local role = getRole(player)
        local color
        local show = false
        
        if role == "Murderer" and SETTINGS.ESPMurderer then
            color = C.Murderer
            show = true
        elseif role == "Sheriff" and SETTINGS.ESPSheriff then
            color = C.Sheriff
            show = true
        elseif role == "Innocent" and SETTINGS.ESPInnocent then
            color = C.Innocent
            show = true
        end
        
        if not show then
            if espBoxes[player] then
                espBoxes[player]:Destroy()
                espBoxes[player] = nil
            end
            continue
        end
        
        if not espBoxes[player] then
            local billboard = Instance.new("BillboardGui")
            billboard.Size = UDim2.new(0, 140, 0, 50)
            billboard.AlwaysOnTop = true
            billboard.StudsOffset = Vector3.new(0, 2.5, 0)
            billboard.Parent = screenGui
            
            local box = Instance.new("Frame")
            box.Size = UDim2.new(1, 0, 1, 0)
            box.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
            box.BackgroundTransparency = 0.4
            box.BorderSizePixel = 0
            box.Parent = billboard
            
            local boxCorner = Instance.new("UICorner")
            boxCorner.CornerRadius = UDim.new(0, 6)
            boxCorner.Parent = box
            
            local boxStroke = Instance.new("UIStroke")
            boxStroke.Color = color
            boxStroke.Thickness = 1.5
            boxStroke.Parent = box
            
            local roleLabel = Instance.new("TextLabel")
            roleLabel.Size = UDim2.new(1, 0, 0, 22)
            roleLabel.BackgroundTransparency = 1
            roleLabel.Text = role
            roleLabel.TextColor3 = color
            roleLabel.Font = Enum.Font.GothamBold
            roleLabel.TextSize = 13
            roleLabel.Parent = box
            
            local infoLabel = Instance.new("TextLabel")
            infoLabel.Size = UDim2.new(1, 0, 0, 22)
            infoLabel.Position = UDim2.new(0, 0, 0, 22)
            infoLabel.BackgroundTransparency = 1
            infoLabel.Text = ""
            infoLabel.TextColor3 = C.Text
            infoLabel.Font = Enum.Font.Gotham
            infoLabel.TextSize = 11
            infoLabel.Parent = box
            
            espBoxes[player] = billboard
            billboard.Adornee = head
        end
        
        local dist = math.floor((hrp.Position - Camera.CFrame.Position).Magnitude)
        local text = ""
        if SETTINGS.ESPShowName then text = player.Name end
        if SETTINGS.ESPShowDistance then
            text = text .. (text ~= "" and " | " or "") .. dist .. "m"
        end
        espBoxes[player].Frame.TextLabel.Text = role
        espBoxes[player].Frame.TextLabel.TextColor3 = color
        espBoxes[player].Frame.UIStroke.Color = color
        espBoxes[player].Frame:FindFirstChildOfClass("TextLabel").Text = role
    end
    
    -- Убираем ESP у вышедших
    for player, box in pairs(espBoxes) do
        if not player.Parent or not player.Character then
            box:Destroy()
            espBoxes[player] = nil
        end
    end
end)

-- =============================================
-- SPINNER
-- =============================================
RunService.RenderStepped:Connect(function(dt)
    if not SETTINGS.SpinnerEnabled then return end
    local char = LocalPlayer.Character
    if not char then return end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not hrp then return end
    
    local speed = SETTINGS.SpinnerSpeed
    hrp.CFrame = hrp.CFrame * CFrame.Angles(0, math.rad(speed * dt * 60), 0)
end)

-- =============================================
-- BHOP
-- =============================================
RunService.RenderStepped:Connect(function()
    if not SETTINGS.BhopEnabled then return end
