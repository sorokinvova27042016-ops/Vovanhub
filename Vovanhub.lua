-- MM2 WALLBANG AIMBOT + PULSEHUB UI
-- Красивое меню в стиле PulseHub

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()
local Camera = Workspace.CurrentCamera

-- =============================================
-- НАСТРОЙКИ
-- =============================================
local SETTINGS = {
    Enabled = true,
    Wallbang = true,
    AutoShoot = true,
    TargetMurderer = true,
    TargetSheriff = false,
    FOV = 360,
    Smoothness = 0.15,
    ShootDelay = 0.1
}

-- =============================================
-- ЦВЕТА PULSEHUB
-- =============================================
local COLORS = {
    Background = Color3.fromRGB(15, 15, 20),
    Panel = Color3.fromRGB(22, 22, 30),
    PanelLight = Color3.fromRGB(30, 30, 42),
    Accent = Color3.fromRGB(138, 43, 226),      -- фиолетовый
    AccentLight = Color3.fromRGB(180, 100, 255),
    Text = Color3.fromRGB(240, 240, 250),
    TextDim = Color3.fromRGB(140, 140, 160),
    ToggleOn = Color3.fromRGB(138, 43, 226),
    ToggleOff = Color3.fromRGB(50, 50, 65),
    Success = Color3.fromRGB(80, 220, 120),
    Danger = Color3.fromRGB(255, 80, 80)
}

-- =============================================
-- ЛОГИКА РОЛЕЙ
-- =============================================
local function getRole(player)
    if not player or not player.Character then return "Innocent" end
    local bp = player:FindFirstChild("Backpack")
    if bp then
        if bp:FindFirstChild("Knife") then return "Murderer" end
        if bp:FindFirstChild("Gun") then return "Sheriff" end
    end
    local char = player.Character
    if char:FindFirstChild("Knife") then return "Murderer" end
    if char:FindFirstChild("Gun") then return "Sheriff" end
    return "Innocent"
end

-- =============================================
-- UI LIBRARY (PulseHub Style)
-- =============================================
local UI = {}

local screenGui = Instance.new("ScreenGui")
screenGui.Name = "PulseHubUI"
screenGui.ResetOnSpawn = false
screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
screenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")

-- Главное окно
local main = Instance.new("Frame")
main.Name = "Main"
main.Size = UDim2.new(0, 560, 0, 380)
main.Position = UDim2.new(0.5, -280, 0.5, -190)
main.BackgroundColor3 = COLORS.Background
main.BorderSizePixel = 0
main.Parent = screenGui

local mainCorner = Instance.new("UICorner")
mainCorner.CornerRadius = UDim.new(0, 10)
mainCorner.Parent = main

local mainStroke = Instance.new("UIStroke")
mainStroke.Color = COLORS.Accent
mainStroke.Thickness = 1.5
mainStroke.Transparency = 0.3
mainStroke.Parent = main

-- Заголовок
local header = Instance.new("Frame")
header.Size = UDim2.new(1, 0, 0, 44)
header.BackgroundColor3 = COLORS.Panel
header.BorderSizePixel = 0
header.Parent = main

local headerCorner = Instance.new("UICorner")
headerCorner.CornerRadius = UDim.new(0, 10)
headerCorner.Parent = header

local headerFix = Instance.new("Frame")
headerFix.Size = UDim2.new(1, 0, 0, 15)
headerFix.Position = UDim2.new(0, 0, 1, -15)
headerFix.BackgroundColor3 = COLORS.Panel
headerFix.BorderSizePixel = 0
headerFix.Parent = header

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, -20, 1, 0)
title.Position = UDim2.new(0, 20, 0, 0)
title.BackgroundTransparency = 1
title.Text = "PULSEHUB  •  MM2"
title.TextColor3 = COLORS.AccentLight
title.Font = Enum.Font.GothamBold
title.TextSize = 16
title.TextXAlignment = Enum.TextXAlignment.Left
title.Parent = header

-- Кнопка закрытия
local closeBtn = Instance.new("TextButton")
closeBtn.Size = UDim2.new(0, 28, 0, 28)
closeBtn.Position = UDim2.new(1, -36, 0, 8)
closeBtn.BackgroundColor3 = COLORS.PanelLight
closeBtn.Text = "✕"
closeBtn.TextColor3 = COLORS.Text
closeBtn.Font = Enum.Font.GothamBold
closeBtn.TextSize = 14
closeBtn.Parent = header

local closeCorner = Instance.new("UICorner")
closeCorner.CornerRadius = UDim.new(0, 6)
closeCorner.Parent = closeBtn

-- Боковая панель (категории)
local sidebar = Instance.new("Frame")
sidebar.Size = UDim2.new(0, 140, 1, -44)
sidebar.Position = UDim2.new(0, 0, 0, 44)
sidebar.BackgroundColor3 = COLORS.Panel
sidebar.BorderSizePixel = 0
sidebar.Parent = main

local sidebarFix = Instance.new("Frame")
sidebarFix.Size = UDim2.new(0, 15, 1, 0)
sidebarFix.Position = UDim2.new(1, -15, 0, 0)
sidebarFix.BackgroundColor3 = COLORS.Panel
sidebarFix.BorderSizePixel = 0
sidebarFix.Parent = sidebar

-- Контент
local content = Instance.new("Frame")
content.Size = UDim2.new(1, -140, 1, -44)
content.Position = UDim2.new(0, 140, 0, 44)
content.BackgroundColor3 = COLORS.Background
content.BorderSizePixel = 0
content.Parent = main

-- =============================================
-- ФУНКЦИЯ СОЗДАНИЯ КАТЕГОРИИ
-- =============================================
local categories = {}
local currentCategory = nil
local categoryButtons = {}

function UI.createCategory(name)
    local page = Instance.new("ScrollingFrame")
    page.Size = UDim2.new(1, -20, 1, -20)
    page.Position = UDim2.new(0, 10, 0, 10)
    page.BackgroundTransparency = 1
    page.BorderSizePixel = 0
    page.ScrollBarThickness = 4
    page.ScrollBarImageColor3 = COLORS.Accent
    page.CanvasSize = UDim2.new(0, 0, 0, 0)
    page.AutomaticCanvasSize = Enum.AutomaticSize.Y
    page.Visible = false
    page.Parent = content
    
    local layout = Instance.new("UIListLayout")
    layout.Padding = UDim.new(0, 8)
    layout.SortOrder = Enum.SortOrder.LayoutOrder
    layout.Parent = page
    
    categories[name] = page
    
    -- Кнопка в сайдбаре
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, -10, 0, 36)
    btn.Position = UDim2.new(0, 5, 0, 5 + (#categoryButtons * 40))
    btn.BackgroundColor3 = COLORS.Panel
    btn.Text = "  " .. name
    btn.TextColor3 = COLORS.TextDim
    btn.Font = Enum.Font.Gotham
    btn.TextSize = 13
    btn.TextXAlignment = Enum.TextXAlignment.Left
    btn.Parent = sidebar
    
    local btnCorner = Instance.new("UICorner")
    btnCorner.CornerRadius = UDim.new(0, 6)
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
        if btn.Text == "  " .. name then
            TweenService:Create(btn, TweenInfo.new(0.2), {BackgroundColor3 = COLORS.Accent}):Play()
            TweenService:Create(btn, TweenInfo.new(0.2), {TextColor3 = COLORS.Text}):Play()
        else
            TweenService:Create(btn, TweenInfo.new(0.2), {BackgroundColor3 = COLORS.Panel}):Play()
            TweenService:Create(btn, TweenInfo.new(0.2), {TextColor3 = COLORS.TextDim}):Play()
        end
    end
    currentCategory = name
end

-- =============================================
-- ЭЛЕМЕНТЫ UI
-- =============================================
function UI.createToggle(parent, name, default, callback)
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1, 0, 0, 36)
    frame.BackgroundColor3 = COLORS.Panel
    frame.BorderSizePixel = 0
    frame.Parent = parent
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 6)
    corner.Parent = frame
    
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, -60, 1, 0)
    label.Position = UDim2.new(0, 12, 0, 0)
    label.BackgroundTransparency = 1
    label.Text = name
    label.TextColor3 = COLORS.Text
    label.Font = Enum.Font.Gotham
    label.TextSize = 13
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = frame
    
    local toggle = Instance.new("Frame")
    toggle.Size = UDim2.new(0, 40, 0, 20)
    toggle.Position = UDim2.new(1, -52, 0.5, -10)
    toggle.BackgroundColor3 = default and COLORS.ToggleOn or COLORS.ToggleOff
    toggle.Parent = frame
    
    local toggleCorner = Instance.new("UICorner")
    toggleCorner.CornerRadius = UDim.new(1, 0)
    toggleCorner.Parent = toggle
    
    local knob = Instance.new("Frame")
    knob.Size = UDim2.new(0, 16, 0, 16)
    knob.Position = default and UDim2.new(1, -18, 0.5, -8) or UDim2.new(0, 2, 0.5, -8)
    knob.BackgroundColor3 = COLORS.Text
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
        TweenService:Create(toggle, TweenInfo.new(0.2), {BackgroundColor3 = state and COLORS.ToggleOn or COLORS.ToggleOff}):Play()
        TweenService:Create(knob, TweenInfo.new(0.2), {Position = state and UDim2.new(1, -18, 0.5, -8) or UDim2.new(0, 2, 0.5, -8)}):Play()
        callback(state)
    end)
end

function UI.createSlider(parent, name, min, max, default, callback)
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1, 0, 0, 50)
    frame.BackgroundColor3 = COLORS.Panel
    frame.BorderSizePixel = 0
    frame.Parent = parent
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 6)
    corner.Parent = frame
    
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, -20, 0, 22)
    label.Position = UDim2.new(0, 12, 0, 4)
    label.BackgroundTransparency = 1
    label.Text = name .. ": " .. default
    label.TextColor3 = COLORS.Text
    label.Font = Enum.Font.Gotham
    label.TextSize = 13
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = frame
    
    local barBg = Instance.new("Frame")
    barBg.Size = UDim2.new(1, -24, 0, 6)
    barBg.Position = UDim2.new(0, 12, 0, 34)
    barBg.BackgroundColor3 = COLORS.ToggleOff
    barBg.BorderSizePixel = 0
    barBg.Parent = frame
    
    local barBgCorner = Instance.new("UICorner")
    barBgCorner.CornerRadius = UDim.new(1, 0)
    barBgCorner.Parent = barBg
    
    local fill = Instance.new("Frame")
    fill.Size = UDim2.new((default - min) / (max - min), 0, 1, 0)
    fill.BackgroundColor3 = COLORS.Accent
    fill.BorderSizePixel = 0
    fill.Parent = barBg
    
    local fillCorner = Instance.new("UICorner")
    fillCorner.CornerRadius = UDim.new(1, 0)
    fillCorner.Parent = fill
    
    local dragging = false
    
    local clickArea = Instance.new("TextButton")
    clickArea.Size = UDim2.new(1, -24, 0, 20)
    clickArea.Position = UDim2.new(0, 12, 0, 27)
    clickArea.BackgroundTransparency = 1
    clickArea.Text = ""
    clickArea.Parent = frame
    
    local function updateFromX(x)
        local rel = math.clamp((x - barBg.AbsolutePosition.X) / barBg.AbsoluteSize.X, 0, 1)
        local val = min + (max - min) * rel
        val = math.floor(val * 100) / 100
        fill.Size = UDim2.new(rel, 0, 1, 0)
        label.Text = name .. ": " .. val
        callback(val)
    end
    
    clickArea.MouseButton1Down:Connect(function()
        dragging = true
        updateFromX(Mouse.X)
    end)
    
    UserInputService.InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            updateFromX(Mouse.X)
        end
    end)
    
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
        end
    end)
end

function UI.createLabel(parent, text, color)
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, 0, 0, 28)
    label.BackgroundColor3 = COLORS.Panel
    label.Text = text
    label.TextColor3 = color or COLORS.TextDim
    label.Font = Enum.Font.GothamBold
    label.TextSize = 12
    label.Parent = parent
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 6)
    corner.Parent = label
end

-- =============================================
-- СОЗДАНИЕ СТРАНИЦ
-- =============================================

-- Combat
local combatPage = UI.createCategory("Combat")
UI.createLabel(combatPage, "  ⚔  AIMBOT SETTINGS", COLORS.AccentLight)
UI.createToggle(combatPage, "Enabled", SETTINGS.Enabled, function(v) SETTINGS.Enabled = v end)
UI.createToggle(combatPage, "Wallbang (сквозь стены)", SETTINGS.Wallbang, function(v) SETTINGS.Wallbang = v end)
UI.createToggle(combatPage, "Auto Shoot", SETTINGS.AutoShoot, function(v) SETTINGS.AutoShoot = v end)
UI.createToggle(combatPage, "Target Murderer", SETTINGS.TargetMurderer, function(v) SETTINGS.TargetMurderer = v end)
UI.createToggle(combatPage, "Target Sheriff", SETTINGS.TargetSheriff, function(v) SETTINGS.TargetSheriff = v end)
UI.createSlider(combatPage, "FOV", 0, 360, SETTINGS.FOV, function(v) SETTINGS.FOV = v end)
UI.createSlider(combatPage, "Smoothness", 0, 1, SETTINGS.Smoothness, function(v) SETTINGS.Smoothness = v end)
UI.createSlider(combatPage, "Shoot Delay", 0.01, 0.5, SETTINGS.ShootDelay, function(v) SETTINGS.ShootDelay = v end)

-- Visuals
local visualPage = UI.createCategory("Visuals")
UI.createLabel(visualPage, "  👁  VISUAL SETTINGS", COLORS.AccentLight)
local espEnabled = false
local espBoxes = {}

UI.createToggle(visualPage, "ESP (видеть роли)", false, function(v)
    espEnabled = v
    if not v then
        for _, box in pairs(espBoxes) do
            if box then box:Destroy() end
        end
        espBoxes = {}
    end
end)

UI.createToggle(visualPage, "Show Murderer Only", false, function(v)
    -- логика фильтра ESP
end)

-- Misc
local miscPage = UI.createCategory("Misc")
UI.createLabel(miscPage, "  ⚙  MISC SETTINGS", COLORS.AccentLight)
UI.createToggle(miscPage, "Auto Win (Murderer)", false, function(v)
    -- логика авто-победы
end)
UI.createToggle(miscPage, "Anti AFK", true, function(v)
    -- логика анти-афк
end)

-- Info
local infoPage = UI.createCategory("Info")
UI.createLabel(infoPage, "  ℹ  PULSEHUB MM2", COLORS.AccentLight)
UI.createLabel(infoPage, "  Version: 1.0.0", COLORS.TextDim)
UI.createLabel(infoPage, "  Status: Undetected", COLORS.Success)
UI.createLabel(infoPage, "  Insert - toggle menu", COLORS.TextDim)
UI.createLabel(infoPage, "  Made for alt accounts only", COLORS.Danger)

-- Открываем Combat по умолчанию
UI.switchCategory("Combat")

-- =============================================
-- ПЕРЕТАСКИВАНИЕ ОКНА
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
-- ОТКРЫТИЕ/ЗАКРЫТИЕ МЕНЮ
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
                Size = UDim2.new(0, 560, 0, 380)
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
-- AIMBOT ЛОГИКА
-- =============================================
local lastShot = 0
local currentTarget = nil

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
            -- ok
        elseif SETTINGS.TargetSheriff and role == "Sheriff" then
            -- ok
        else
            continue
        end
        
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
        local currentCF = Camera.CFrame
        local targetCF = CFrame.new(currentCF.Position, head.Position)
        Camera.CFrame = currentCF:Lerp(targetCF, 1 - SETTINGS.Smoothness)
    end
end

local function shoot()
    local now = tick()
    if now - lastShot < SETTINGS.ShootDelay then return end
    lastShot = now
    
    local tool = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Tool")
    if tool then tool:Activate() end
end

-- =============================================
-- ESP ЛОГИКА
-- =============================================
RunService.RenderStepped:Connect(function()
    if not espEnabled then return end
    
    for _, player in pairs(Players:GetPlayers()) do
        if player == LocalPlayer then continue end
        if not player.Character then continue end
        
        local head = player.Character:FindFirstChild("Head")
        if not head then continue end
        
        local role = getRole(player)
        local color = role == "Murderer" and COLORS.Danger or (role == "Sheriff" and Color3.fromRGB(80, 150, 255) or COLORS.Success)
        
        if not espBoxes[player] then
            local billboard = Instance.new("BillboardGui")
            billboard.Size = UDim2.new(0, 100, 0, 30)
            billboard.AlwaysOnTop = true
            billboard.Parent = screenGui
            
            local label = Instance.new("TextLabel")
            label.Size = UDim2.new(1, 0, 1, 0)
            label.BackgroundTransparency = 0.3
            label.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
            label.TextColor3 = color
            label.Font = Enum.Font.GothamBold
            label.TextSize = 12
            label.Text = role
            label.Parent = billboard
            
            espBoxes[player] = billboard
        end
        
        espBoxes[player].Adornee = head
        espBoxes[player].TextLabel.Text = role
        espBoxes[player].TextLabel.TextColor3 = color
    end
end)

-- =============================================
-- ОСНОВНОЙ ЦИКЛ AIMBOT
-- =============================================
RunService.RenderStepped:Connect(function()
    if not SETTINGS.Enabled then return end
    
    currentTarget = findTarget()
    
    if currentTarget then
        aimAt(currentTarget)
        
        if SETTINGS.AutoShoot then
            local myRole = getRole(LocalPlayer)
            if myRole == "Murderer" or myRole == "Sheriff" then
                shoot()
            end
        end
    end
end)

print("⚡ PulseHub MM2 Loaded. Press INSERT to toggle.")
