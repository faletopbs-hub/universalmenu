local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local VirtualInputManager = game:GetService("VirtualInputManager")

local Config = {
    AimBot = { 
        Enabled = false, 
        Bind = Enum.KeyCode.E, 
        Mode = "Hold", 
        TargetPart = "Head", 
        AutoShot = false, 
        AutoShotBind = Enum.KeyCode.Q,
        TargetMode = "Closest"  -- Closest / Cursor
    },
    ESP = { Enabled = false, Outlines = false, Trails = false, Color = Color3.fromRGB(0, 162, 255) },
    Movement = { 
        Fly = false, 
        FlySpeed = 50, 
        FlyBind = Enum.KeyCode.F, 
        Bhop = false, 
        BhopSpeed = 40, 
        InfJump = false, 
        Noclip = false,
        SpeedHack = false,
        SpeedHackMultiplier = 16
    }
}

------------------------------------------------------------------------
-- ФУНКЦИОНАЛ (AIM, ESP, MOVEMENT)
------------------------------------------------------------------------
local function isValidTarget(player, part)
    if not player or not player:IsA("Player") then return false end
    local humanoid = player.Character and player.Character:FindFirstChildOfClass("Humanoid")
    if not humanoid or humanoid.Health <= 0 then return false end
    if part.Transparency > 0.1 then return false end
    return true
end

-- Получить ближайшего игрока
local function getClosestPlayer()
    local closest = nil
    local shortestDistance = math.huge
    local origin = Camera.CFrame.Position
    
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character then
            local part = player.Character:FindFirstChild(Config.AimBot.TargetPart)
            if part and isValidTarget(player, part) then
                local distance = (part.Position - origin).Magnitude
                if distance < shortestDistance then
                    closest = part
                    shortestDistance = distance
                end
            end
        end
    end
    return closest
end

-- Получить игрока под курсором (старый метод)
local function getClosestPlayerToCursor()
    local closest = nil
    local shortestDistance = math.huge
    local mousePos = UserInputService:GetMouseLocation()
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character then
            local part = player.Character:FindFirstChild(Config.AimBot.TargetPart)
            if part and isValidTarget(player, part) then
                local pos, onScreen = Camera:WorldToViewportPoint(part.Position)
                if onScreen then
                    local distance = (Vector2.new(pos.X, pos.Y) - mousePos).Magnitude
                    if distance < shortestDistance then
                        closest = part
                        shortestDistance = distance
                    end
                end
            end
        end
    end
    return closest
end

-- Получить цель в зависимости от режима
local function getTarget()
    if Config.AimBot.TargetMode == "Closest" then
        return getClosestPlayer()
    else
        return getClosestPlayerToCursor()
    end
end

local function applyESP(player)
    if player == LocalPlayer then return end
    local function setupChar(char)
        if not char then return end
        if char:FindFirstChild("MyESP") then char.MyESP:Destroy() end
        if char:FindFirstChild("MyTrail") then char.MyTrail:Destroy() end
        local oldAttachment = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HRP_Attachment_" .. player.Name)
        if oldAttachment then oldAttachment:Destroy() end
        
        if Config.ESP.Enabled then
            local highlight = Instance.new("Highlight")
            highlight.Name = "MyESP"
            highlight.FillTransparency = 0.6
            highlight.FillColor = Config.ESP.Color
            highlight.OutlineColor = Config.ESP.Color
            highlight.OutlineTransparency = Config.ESP.Outlines and 0 or 1
            highlight.Parent = char
            
            if Config.ESP.Trails and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
                local tHrp = char:WaitForChild("HumanoidRootPart", 5)
                if tHrp then
                    local attachment0 = Instance.new("Attachment")
                    attachment0.Name = "HRP_Attachment_" .. player.Name
                    attachment0.Parent = LocalPlayer.Character.HumanoidRootPart
                    local attachment1 = Instance.new("Attachment")
                    attachment1.Name = "Enemy_Attachment"
                    attachment1.Parent = tHrp
                    local beam = Instance.new("Beam")
                    beam.Name = "MyTrail"
                    beam.Attachment0 = attachment0
                    beam.Attachment1 = attachment1
                    beam.Color = ColorSequence.new(Config.ESP.Color)
                    beam.Width0 = 0.05
                    beam.Width1 = 0.05
                    beam.FaceCamera = true
                    beam.Parent = char
                end
            end
        end
    end
    player.CharacterAdded:Connect(setupChar)
    if player.Character then setupChar(player.Character) end
end

local function refreshESP()
    for _, p in pairs(Players:GetPlayers()) do if p.Character then applyESP(p) end end
end
Players.PlayerAdded:Connect(applyESP)

-- Переменная для контроля AutoShot
local isAutoShotActive = false
local autoShotTarget = nil

RunService.RenderStepped:Connect(function()
    if Config.AimBot.Enabled then
        local target = getTarget()
        
        if target then
            -- Наводим прицел
            if Config.AimBot.Mode == "Toggle" or UserInputService:IsKeyDown(Config.AimBot.Bind) then
                Camera.CFrame = CFrame.new(Camera.CFrame.Position, target.Position)
            end
            
            -- AutoShot логика
            if Config.AimBot.AutoShot and UserInputService:IsKeyDown(Config.AimBot.AutoShotBind) then
                -- Если зажат бинд - стреляем в ближайшего
                local closestTarget = getClosestPlayer()
                if closestTarget then
                    -- Наводимся на цель
                    Camera.CFrame = CFrame.new(Camera.CFrame.Position, closestTarget.Position)
                    -- Стреляем (ЛКМ)
                    VirtualInputManager:SendMouseButtonEvent(0, 0, 0, true, game:GetService("UserInputService").Enum.UserInputType.MouseButton1, 0)
                    task.wait(0.05)
                    VirtualInputManager:SendMouseButtonEvent(0, 0, 0, false, game:GetService("UserInputService").Enum.UserInputType.MouseButton1, 0)
                end
            end
        end
    end
end)

UserInputService.JumpRequest:Connect(function()
    if Config.Movement.InfJump and LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid") then
        LocalPlayer.Character:FindFirstChildOfClass("Humanoid"):ChangeState(Enum.HumanoidStateType.Jumping)
    end
end)

local noclipConnection
local function toggleNoclip()
    if Config.Movement.Noclip then
        if noclipConnection then noclipConnection:Disconnect() end
        noclipConnection = RunService.Stepped:Connect(function()
            if LocalPlayer.Character then
                for _, part in pairs(LocalPlayer.Character:GetDescendants()) do
                    if part:IsA("BasePart") then
                        part.CanCollide = false
                    end
                end
            end
        end)
    else
        if noclipConnection then
            noclipConnection:Disconnect()
            noclipConnection = nil
        end
        if LocalPlayer.Character then
            for _, part in pairs(LocalPlayer.Character:GetDescendants()) do
                if part:IsA("BasePart") then
                    part.CanCollide = true
                end
            end
        end
    end
end

local oldNoclip = false
RunService.Heartbeat:Connect(function()
    if Config.Movement.Noclip ~= oldNoclip then
        oldNoclip = Config.Movement.Noclip
        toggleNoclip()
    end
end)

local bodyVelocity, bodyGyro
RunService.Heartbeat:Connect(function()
    local char = LocalPlayer.Character
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    
    -- SPEED HACK
    if Config.Movement.SpeedHack and hrp then
        local humanoid = char:FindFirstChildOfClass("Humanoid")
        if humanoid then
            humanoid.WalkSpeed = Config.Movement.SpeedHackMultiplier
        end
    elseif hrp then
        local humanoid = char:FindFirstChildOfClass("Humanoid")
        if humanoid and humanoid.WalkSpeed ~= 16 then
            humanoid.WalkSpeed = 16
        end
    end
    
    if Config.Movement.Fly and hrp then
        if not bodyVelocity then
            bodyVelocity = Instance.new("BodyVelocity", hrp)
            bodyVelocity.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
            bodyGyro = Instance.new("BodyGyro", hrp)
            bodyGyro.MaxTorque = Vector3.new(math.huge, math.huge, math.huge)
        end
        local moveDir = Vector3.new(0,0,0)
        if UserInputService:IsKeyDown(Enum.KeyCode.W) then moveDir = moveDir + Camera.CFrame.LookVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.S) then moveDir = moveDir - Camera.CFrame.LookVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.A) then moveDir = moveDir - Camera.CFrame.RightVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.D) then moveDir = moveDir + Camera.CFrame.RightVector end
        bodyVelocity.Velocity = moveDir * Config.Movement.FlySpeed
        bodyGyro.CFrame = Camera.CFrame
    else
        if bodyVelocity then bodyVelocity:Destroy() bodyVelocity = nil end
        if bodyGyro then bodyGyro:Destroy() bodyGyro = nil end
    end
    
    if Config.Movement.Bhop and UserInputService:IsKeyDown(Enum.KeyCode.Space) and hrp then
        local direction = Vector3.new(0, 0, 0)
        if UserInputService:IsKeyDown(Enum.KeyCode.W) then direction = direction + Camera.CFrame.LookVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.S) then direction = direction - Camera.CFrame.LookVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.A) then direction = direction - Camera.CFrame.RightVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.D) then direction = direction + Camera.CFrame.RightVector end
        if direction.Magnitude == 0 then direction = Camera.CFrame.LookVector end
        local finalMove = Vector3.new(direction.X, 0, direction.Z).Unit
        hrp.Velocity = Vector3.new(finalMove.X * Config.Movement.BhopSpeed, hrp.Velocity.Y, finalMove.Z * Config.Movement.BhopSpeed)
    end
end)

------------------------------------------------------------------------
-- ИНТЕРФЕЙС ECLIPSE С ТАЙТЛ-БАРОМ И АНИМАЦИЯМИ
------------------------------------------------------------------------
local ScreenGui = Instance.new("ScreenGui", game:GetService("CoreGui") or LocalPlayer:WaitForChild("PlayerGui"))
ScreenGui.Name = "EclipseNeverloseMenu"
ScreenGui.ResetOnSpawn = false

-- Главный контейнер для анимации прозрачности
local MainCanvas = Instance.new("Frame", ScreenGui)
MainCanvas.Size = UDim2.new(0, 740, 0, 520)
MainCanvas.Position = UDim2.new(0.5, -370, 0.5, -260)
MainCanvas.BackgroundTransparency = 1

-- Физическое тело меню
local MainFrame = Instance.new("Frame", MainCanvas)
MainFrame.Size = UDim2.new(1, 0, 1, 0)
MainFrame.BackgroundColor3 = Color3.fromRGB(8, 11, 15)
MainFrame.BorderSizePixel = 0
Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 8)

-- ОБВОДКА МЕНЮ (неоново-голубая)
local MenuStroke = Instance.new("UIStroke", MainFrame)
MenuStroke.Color = Color3.fromRGB(0, 162, 255)
MenuStroke.Thickness = 1.5
MenuStroke.Transparency = 0.3

-- ВЕРХНЯЯ ПАНЕЛЬ С КНОПКАМИ УПРАВЛЕНИЯ (Title Bar)
local TitleBar = Instance.new("Frame", MainFrame)
TitleBar.Size = UDim2.new(1, 0, 0, 30)
TitleBar.BackgroundColor3 = Color3.fromRGB(5, 7, 10)
TitleBar.BorderSizePixel = 0
local TitleCorner = Instance.new("UICorner", TitleBar)
TitleCorner.CornerRadius = UDim.new(0, 8)

-- Скрытие нижних скруглений у тайтл-бара
local TitleFix = Instance.new("Frame", TitleBar)
TitleFix.Size = UDim2.new(1, 0, 0, 8)
TitleFix.Position = UDim2.new(0, 0, 1, -8)
TitleFix.BackgroundColor3 = Color3.fromRGB(5, 7, 10)
TitleFix.BorderSizePixel = 0

-- Перетаскивание всего меню за TitleBar
local menuDragToggle = false
local menuDragStart, menuStartPos
TitleBar.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        menuDragToggle = true
        menuDragStart = input.Position
        menuStartPos = MainCanvas.Position
    end
end)
UserInputService.InputChanged:Connect(function(input)
    if menuDragToggle and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
        local delta = input.Position - menuDragStart
        MainCanvas.Position = UDim2.new(menuStartPos.X.Scale, menuStartPos.X.Offset + delta.X, menuStartPos.Y.Scale, menuStartPos.Y.Offset + delta.Y)
    end
end)
UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        menuDragToggle = false
    end
end)

-- Кнопка закрытия (X)
local CloseBtn = Instance.new("TextButton", TitleBar)
CloseBtn.Size = UDim2.new(0, 30, 1, 0)
CloseBtn.Position = UDim2.new(1, -35, 0, 0)
CloseBtn.Text = "×"
CloseBtn.Font = Enum.Font.SourceSansBold
CloseBtn.TextSize = 20
CloseBtn.TextColor3 = Color3.fromRGB(150, 160, 175)
CloseBtn.BackgroundTransparency = 1

-- Кнопка сворачивания (-)
local MinimizeBtn = Instance.new("TextButton", TitleBar)
MinimizeBtn.Size = UDim2.new(0, 30, 1, 0)
MinimizeBtn.Position = UDim2.new(1, -65, 0, 0)
MinimizeBtn.Text = "—"
MinimizeBtn.Font = Enum.Font.SourceSansBold
MinimizeBtn.TextSize = 12
MinimizeBtn.TextColor3 = Color3.fromRGB(150, 160, 175)
MinimizeBtn.BackgroundTransparency = 1

-- Сайдбар (Опущен ниже тайтл-бара)
local Sidebar = Instance.new("Frame", MainFrame)
Sidebar.Size = UDim2.new(0, 170, 1, -30)
Sidebar.Position = UDim2.new(0, 0, 0, 30)
Sidebar.BackgroundColor3 = Color3.fromRGB(5, 7, 10)
Sidebar.BorderSizePixel = 0

-- Логотип ECLIPSE (растянут вверх/вниз)
local Logo = Instance.new("TextLabel", Sidebar)
Logo.Size = UDim2.new(1, 0, 0, 70)
Logo.Position = UDim2.new(0, 0, 0, 5)
Logo.Text = "ECLIPSE"
Logo.Font = Enum.Font.FredokaOne
Logo.TextSize = 28
Logo.TextColor3 = Color3.fromRGB(0, 162, 255)
Logo.BackgroundTransparency = 1

-- Контейнер вкладок (сдвинут вниз чтобы компенсировать увеличенный логотип)
local TabsContainer = Instance.new("Frame", Sidebar)
TabsContainer.Size = UDim2.new(1, -20, 1, -90)
TabsContainer.Position = UDim2.new(0, 10, 0, 80)
TabsContainer.BackgroundTransparency = 1
local TabsLayout = Instance.new("UIListLayout", TabsContainer)
TabsLayout.Padding = UDim.new(0, 6)

-- Правая рабочая область
local PagesContainer = Instance.new("Frame", MainFrame)
PagesContainer.Size = UDim2.new(1, -190, 1, -50)
PagesContainer.Position = UDim2.new(0, 180, 0, 40)
PagesContainer.BackgroundTransparency = 1

local Pages = {}
local TabButtons = {}
local ActiveTab = nil

-- Конструктор страниц
local function CreatePage(name)
    local page = Instance.new("ScrollingFrame", PagesContainer)
    page.Size = UDim2.new(1, 0, 1, 0)
    page.BackgroundTransparency = 1
    page.BorderSizePixel = 0
    page.ScrollBarThickness = 0
    page.Visible = false
    
    local layout = Instance.new("UIListLayout", page)
    layout.SortOrder = Enum.SortOrder.LayoutOrder
    layout.Padding = UDim.new(0, 15)
    
    Pages[name] = page
    return page
end

-- Конструктор карточек групп (Neverlose-стиль)
local function CreateCard(title, parent)
    local card = Instance.new("Frame", parent)
    card.Size = UDim2.new(1, -5, 0, 45)
    card.BackgroundColor3 = Color3.fromRGB(11, 15, 22)
    card.BorderSizePixel = 0
    Instance.new("UICorner", card).CornerRadius = UDim.new(0, 6)
    
    local cardStroke = Instance.new("UIStroke", card)
    cardStroke.Color = Color3.fromRGB(16, 23, 33)
    
    local header = Instance.new("TextLabel", card)
    header.Size = UDim2.new(1, -20, 0, 30)
    header.Position = UDim2.new(0, 12, 0, 4)
    header.Text = title
    header.Font = Enum.Font.SourceSansBold
    header.TextSize = 14
    header.TextColor3 = Color3.fromRGB(0, 162, 255)
    header.TextXAlignment = Enum.TextXAlignment.Left
    header.BackgroundTransparency = 1

    local content = Instance.new("Frame", card)
    content.Size = UDim2.new(1, -24, 1, -35)
    content.Position = UDim2.new(0, 12, 0, 35)
    content.BackgroundTransparency = 1
    
    local list = Instance.new("UIListLayout", content)
    list.Padding = UDim.new(0, 12)
    
    list:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        card.Size = UDim2.new(1, -5, 0, list.AbsoluteContentSize.Y + 45)
    end)
    
    return content
end

-- Элементы управления: Переключатели (Чекбоксы)
local function CreateToggle(text, default, parent, cb)
    local row = Instance.new("Frame", parent)
    row.Size = UDim2.new(1, 0, 0, 24)
    row.BackgroundTransparency = 1

    local label = Instance.new("TextLabel", row)
    label.Size = UDim2.new(1, -50, 1, 0)
    label.Text = text
    label.Font = Enum.Font.SourceSans
    label.TextSize = 14
    label.TextColor3 = Color3.fromRGB(0, 162, 255)
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.BackgroundTransparency = 1

    local switch = Instance.new("TextButton", row)
    switch.Size = UDim2.new(0, 34, 0, 18)
    switch.Position = UDim2.new(1, -34, 0.5, -9)
    switch.Text = ""
    switch.BackgroundColor3 = default and Color3.fromRGB(0, 162, 255) or Color3.fromRGB(22, 28, 38)
    Instance.new("UICorner", switch).CornerRadius = UDim.new(1, 0)
    
    local thumb = Instance.new("Frame", switch)
    thumb.Size = UDim2.new(0, 12, 0, 12)
    thumb.Position = default and UDim2.new(1, -15, 0.5, -6) or UDim2.new(0, 3, 0.5, -6)
    thumb.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    Instance.new("UICorner", thumb).CornerRadius = UDim.new(1, 0)

    switch.MouseButton1Click:Connect(function()
        default = not default
        TweenService:Create(switch, TweenInfo.new(0.15), {BackgroundColor3 = default and Color3.fromRGB(0, 162, 255) or Color3.fromRGB(22, 28, 38)}):Play()
        TweenService:Create(thumb, TweenInfo.new(0.15), {Position = default and UDim2.new(1, -15, 0.5, -6) or UDim2.new(0, 3, 0.5, -6)}):Play()
        cb(default)
    end)
end

-- Элементы управления: Слайдеры
local function CreateSlider(text, min, max, default, parent, cb)
    local row = Instance.new("Frame", parent)
    row.Size = UDim2.new(1, 0, 0, 30)
    row.BackgroundTransparency = 1

    local label = Instance.new("TextLabel", row)
    label.Size = UDim2.new(0, 120, 1, 0)
    label.Text = text
    label.Font = Enum.Font.SourceSans
    label.TextSize = 14
    label.TextColor3 = Color3.fromRGB(0, 162, 255)
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.BackgroundTransparency = 1

    local track = Instance.new("Frame", row)
    track.Size = UDim2.new(1, -180, 0, 4)
    track.Position = UDim2.new(0, 130, 0.5, -2)
    track.BackgroundColor3 = Color3.fromRGB(22, 28, 38)
    track.BorderSizePixel = 0

    local fill = Instance.new("Frame", track)
    fill.Size = UDim2.new((default - min)/(max - min), 0, 1, 0)
    fill.BackgroundColor3 = Color3.fromRGB(0, 162, 255)
    fill.BorderSizePixel = 0

    local valLabel = Instance.new("TextLabel", row)
    valLabel.Size = UDim2.new(0, 40, 1, 0)
    valLabel.Position = UDim2.new(1, -40, 0, 0)
    valLabel.Text = tostring(default)
    valLabel.Font = Enum.Font.SourceSansBold
    valLabel.TextSize = 13
    valLabel.TextColor3 = Color3.fromRGB(0, 162, 255)
    valLabel.TextXAlignment = Enum.TextXAlignment.Right
    valLabel.BackgroundTransparency = 1

    local dragging = false
    track.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then dragging = true end
    end)
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end
    end)

    RunService.RenderStepped:Connect(function()
        if dragging then
            local mouseX = UserInputService:GetMouseLocation().X
            local relativeX = math.clamp((mouseX - track.AbsolutePosition.X) / track.AbsoluteSize.X, 0, 1)
            fill.Size = UDim2.new(relativeX, 0, 1, 0)
            local val = math.floor(min + (relativeX * (max - min)))
            valLabel.Text = tostring(val)
            cb(val)
        end
    end)
end

-- Элементы управления: Бинды кнопок
local function CreateKeybind(text, defaultKey, parent, cb)
    local row = Instance.new("Frame", parent)
    row.Size = UDim2.new(1, 0, 0, 24)
    row.BackgroundTransparency = 1

    local label = Instance.new("TextLabel", row)
    label.Size = UDim2.new(1, -80, 1, 0)
    label.Text = text
    label.Font = Enum.Font.SourceSans
    label.TextSize = 14
    label.TextColor3 = Color3.fromRGB(0, 162, 255)
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.BackgroundTransparency = 1

    local btn = Instance.new("TextButton", row)
    btn.Size = UDim2.new(0, 70, 0, 20)
    btn.Position = UDim2.new(1, -70, 0.5, -10)
    btn.Text = defaultKey.Name
    btn.Font = Enum.Font.SourceSansBold
    btn.TextSize = 12
    btn.TextColor3 = Color3.fromRGB(0, 162, 255)
    btn.BackgroundColor3 = Color3.fromRGB(16, 23, 33)
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 4)

    btn.MouseButton1Click:Connect(function()
        btn.Text = "..."
        local conn
        conn = UserInputService.InputBegan:Connect(function(input)
            if input.KeyCode ~= Enum.KeyCode.Unknown then
                btn.Text = input.KeyCode.Name
                cb(input.KeyCode)
                conn:Disconnect()
            end
        end)
    end)
end

-- Элемент выбора режима (Dropdown)
local function CreateDropdown(text, options, default, parent, cb)
    local row = Instance.new("Frame", parent)
    row.Size = UDim2.new(1, 0, 0, 30)
    row.BackgroundTransparency = 1

    local label = Instance.new("TextLabel", row)
    label.Size = UDim2.new(0, 120, 1, 0)
    label.Text = text
    label.Font = Enum.Font.SourceSans
    label.TextSize = 14
    label.TextColor3 = Color3.fromRGB(0, 162, 255)
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.BackgroundTransparency = 1

    local dropdown = Instance.new("TextButton", row)
    dropdown.Size = UDim2.new(1, -180, 0, 22)
    dropdown.Position = UDim2.new(0, 130, 0.5, -11)
    dropdown.Text = default
    dropdown.Font = Enum.Font.SourceSansBold
    dropdown.TextSize = 12
    dropdown.TextColor3 = Color3.fromRGB(255, 255, 255)
    dropdown.BackgroundColor3 = Color3.fromRGB(16, 23, 33)
    dropdown.BorderSizePixel = 0
    Instance.new("UICorner", dropdown).CornerRadius = UDim.new(0, 4)

    local isOpen = false
    local listFrame = Instance.new("Frame", row)
    listFrame.Size = UDim2.new(1, -180, 0, 0)
    listFrame.Position = UDim2.new(0, 130, 0, 22)
    listFrame.BackgroundColor3 = Color3.fromRGB(16, 23, 33)
    listFrame.BorderSizePixel = 0
    listFrame.ClipsDescendants = true
    Instance.new("UICorner", listFrame).CornerRadius = UDim.new(0, 4)
    
    local listLayout = Instance.new("UIListLayout", listFrame)
    listLayout.Padding = UDim.new(0, 2)

    for _, option in pairs(options) do
        local btn = Instance.new("TextButton", listFrame)
        btn.Size = UDim2.new(1, 0, 0, 22)
        btn.Text = option
        btn.Font = Enum.Font.SourceSans
        btn.TextSize = 12
        btn.TextColor3 = Color3.fromRGB(200, 200, 200)
        btn.BackgroundColor3 = Color3.fromRGB(20, 28, 40)
        btn.BorderSizePixel = 0
        
        btn.MouseButton1Click:Connect(function()
            dropdown.Text = option
            cb(option)
            listFrame.Size = UDim2.new(1, -180, 0, 0)
            isOpen = false
        end)
    end

    dropdown.MouseButton1Click:Connect(function()
        isOpen = not isOpen
        if isOpen then
            local count = 0
            for _, child in pairs(listFrame:GetChildren()) do
                if child:IsA("TextButton") then count = count + 1 end
            end
            listFrame.Size = UDim2.new(1, -180, 0, count * 24 + 4)
        else
            listFrame.Size = UDim2.new(1, -180, 0, 0)
        end
    end)
end

local function CreateColorPicker(text, defaultColor, parent, cb)
    local row = Instance.new("Frame", parent)
    row.Size = UDim2.new(1, 0, 0, 30)
    row.BackgroundTransparency = 1

    local label = Instance.new("TextLabel", row)
    label.Size = UDim2.new(1, -50, 1, 0)
    label.Text = text
    label.Font = Enum.Font.SourceSans
    label.TextSize = 14
    label.TextColor3 = Color3.fromRGB(0, 162, 255)
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.BackgroundTransparency = 1

    local colorBtn = Instance.new("TextButton", row)
    colorBtn.Size = UDim2.new(0, 40, 0, 22)
    colorBtn.Position = UDim2.new(1, -40, 0.5, -11)
    colorBtn.BackgroundColor3 = defaultColor
    colorBtn.BorderSizePixel = 0
    Instance.new("UICorner", colorBtn).CornerRadius = UDim.new(0, 4)

    local colors = {
        Color3.fromRGB(255, 0, 0),
        Color3.fromRGB(0, 255, 0),
        Color3.fromRGB(0, 0, 255),
        Color3.fromRGB(255, 255, 0),
        Color3.fromRGB(255, 0, 255),
        Color3.fromRGB(0, 255, 255),
        Color3.fromRGB(255, 128, 0),
        Color3.fromRGB(128, 0, 255),
        Color3.fromRGB(0, 255, 128),
        Color3.fromRGB(255, 192, 203),
        Color3.fromRGB(0, 162, 255),
        Color3.fromRGB(255, 255, 255)
    }
    local currentColorIndex = 1
    for i, c in pairs(colors) do
        if c == defaultColor then currentColorIndex = i break end
    end

    colorBtn.MouseButton1Click:Connect(function()
        currentColorIndex = currentColorIndex % #colors + 1
        local newColor = colors[currentColorIndex]
        colorBtn.BackgroundColor3 = newColor
        cb(newColor)
        refreshESP()
    end)
end

-- Переключение вкладок
local function SwitchToTab(name)
    if ActiveTab then
        Pages[ActiveTab].Visible = false
        TweenService:Create(TabButtons[ActiveTab], TweenInfo.new(0.15), {TextColor3 = Color3.fromRGB(120, 130, 145), BackgroundColor3 = Color3.fromRGB(5, 7, 10)}):Play()
    end
    ActiveTab = name
    Pages[name].Visible = true
    TweenService:Create(TabButtons[name], TweenInfo.new(0.15), {TextColor3 = Color3.fromRGB(0, 162, 255), BackgroundColor3 = Color3.fromRGB(14, 19, 29)}):Play()
end

local function CreateTabButton(name)
    local btn = Instance.new("TextButton", TabsContainer)
    btn.Size = UDim2.new(1, 0, 0, 36)
    btn.Text = "  " .. name
    btn.Font = Enum.Font.SourceSansBold
    btn.TextSize = 14
    btn.TextColor3 = Color3.fromRGB(120, 130, 145)
    btn.TextXAlignment = Enum.TextXAlignment.Left
    btn.BackgroundColor3 = Color3.fromRGB(5, 7, 10)
    btn.BorderSizePixel = 0
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 6)

    btn.MouseButton1Click:Connect(function() SwitchToTab(name) end)
    TabButtons[name] = btn
end

------------------------------------------------------------------------
-- ЛОГИКА КРУГЛОЙ КНОПКИ И АНИМАЦИЙ СВЕРТЫВАНИЯ
------------------------------------------------------------------------
local FloatingButton = Instance.new("Frame", ScreenGui)
FloatingButton.Size = UDim2.new(0, 50, 0, 50)
FloatingButton.Position = UDim2.new(0.1, 0, 0.1, 0)
FloatingButton.BackgroundColor3 = Color3.fromRGB(11, 15, 22)
FloatingButton.BorderSizePixel = 0
FloatingButton.Visible = false
FloatingButton.Active = true
Instance.new("UICorner", FloatingButton).CornerRadius = UDim.new(1, 0)

local ButtonStroke = Instance.new("UIStroke", FloatingButton)
ButtonStroke.Color = Color3.fromRGB(0, 162, 255)
ButtonStroke.Thickness = 2

local ButtonText = Instance.new("TextButton", FloatingButton)
ButtonText.Size = UDim2.new(1, 0, 1, 0)
ButtonText.Text = "E"
ButtonText.Font = Enum.Font.FredokaOne
ButtonText.TextSize = 24
ButtonText.TextColor3 = Color3.fromRGB(0, 162, 255)
ButtonText.BackgroundTransparency = 1

-- Drag для круглой кнопки
local dragToggle = false
local dragStart, startPos
ButtonText.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragToggle = true
        dragStart = input.Position
        startPos = FloatingButton.Position
    end
end)
UserInputService.InputChanged:Connect(function(input)
    if dragToggle and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
        local delta = input.Position - dragStart
        FloatingButton.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end)
UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragToggle = false
    end
end)

-- Плавные анимации
local function HideMenuShowButton()
    TweenService:Create(MainFrame, TweenInfo.new(0.2, Enum.EasingStyle.Quad), {BackgroundTransparency = 1}):Play()
    for _, child in pairs(MainFrame:GetChildren()) do
        if child:IsA("GuiObject") then child.Visible = false end
    end
    
    task.wait(0.2)
    MainCanvas.Visible = false
    FloatingButton.Visible = true
    FloatingButton.Size = UDim2.new(0, 0, 0, 0)
    TweenService:Create(FloatingButton, TweenInfo.new(0.3, Enum.EasingStyle.Back), {Size = UDim2.new(0, 50, 0, 50)}):Play()
end

local function HideButtonShowMenu()
    TweenService:Create(FloatingButton, TweenInfo.new(0.2), {Size = UDim2.new(0, 0, 0, 0)}):Play()
    task.wait(0.2)
    FloatingButton.Visible = false
    
    MainCanvas.Visible = true
    MainFrame.BackgroundTransparency = 0
    for _, child in pairs(MainFrame:GetChildren()) do
        if child:IsA("GuiObject") then child.Visible = true end
    end
    
    MainCanvas.Size = UDim2.new(0, 740, 0, 520)
    MainCanvas.Position = UDim2.new(0.5, -370, 0.5, -260)
end

MinimizeBtn.MouseButton1Click:Connect(HideMenuShowButton)
ButtonText.MouseButton1Click:Connect(HideButtonShowMenu)

-- Полное закрытие софта с затуханием
CloseBtn.MouseButton1Click:Connect(function()
    TweenService:Create(MainFrame, TweenInfo.new(0.3, Enum.EasingStyle.Quad), {BackgroundTransparency = 1}):Play()
    task.wait(0.3)
    ScreenGui:Destroy()
end)

------------------------------------------------------------------------
-- НАПОЛНЕНИЕ НАШИХ РАЗДЕЛОВ
------------------------------------------------------------------------

-- 1. РАЗДЕЛ AIMBOT
CreateTabButton("AimBot")
local AimPage = CreatePage("AimBot")
local AimCard = CreateCard("Main Target Parameters", AimPage)
CreateToggle("Enable AimBot", Config.AimBot.Enabled, AimCard, function(v) Config.AimBot.Enabled = v end)
CreateKeybind("Aimbot Trigger Key", Config.AimBot.Bind, AimCard, function(k) Config.AimBot.Bind = k end)
CreateDropdown("Target Mode", {"Closest", "Cursor"}, "Closest", AimCard, function(v) Config.AimBot.TargetMode = v end)
CreateToggle("Automatic Shooting", Config.AimBot.AutoShot, AimCard, function(v) Config.AimBot.AutoShot = v end)
CreateKeybind("Autoshot Trigger Key", Config.AimBot.AutoShotBind, AimCard, function(k) Config.AimBot.AutoShotBind = k end)

-- 2. РАЗДЕЛ VISUALS (ESP)
CreateTabButton("Visuals")
local VisualsPage = CreatePage("Visuals")
local EspCard = CreateCard("Overlay Settings", VisualsPage)
CreateToggle("Enable Overlay ESP", Config.ESP.Enabled, EspCard, function(v) Config.ESP.Enabled = v refreshESP() end)
CreateToggle("Render Outlines", Config.ESP.Outlines, EspCard, function(v) Config.ESP.Outlines = v refreshESP() end)
CreateToggle("Draw Dynamic Snaplines", Config.ESP.Trails, EspCard, function(v) Config.ESP.Trails = v refreshESP() end)
CreateColorPicker("ESP Color", Config.ESP.Color, EspCard, function(v) Config.ESP.Color = v refreshESP() end)

-- 3. РАЗДЕЛ MOVEMENT
CreateTabButton("Movement")
local MovePage = CreatePage("Movement")

local FlyCard = CreateCard("Flight Controls", MovePage)
CreateToggle("Air Flight (Fly Mode)", Config.Movement.Fly, FlyCard, function(v) Config.Movement.Fly = v end)
CreateKeybind("Flight Activation Key", Config.Movement.FlyBind, FlyCard, function(k) Config.Movement.FlyBind = k end)
CreateSlider("Flight Velocity", 10, 200, Config.Movement.FlySpeed, FlyCard, function(v) Config.Movement.FlySpeed = v end)

local BhopCard = CreateCard("Speed & Jump Modifiers", MovePage)
CreateToggle("Strafing BunnyHop", Config.Movement.Bhop, BhopCard, function(v) Config.Movement.Bhop = v end)
CreateSlider("Bhop Speed Multiplier", 10, 150, Config.Movement.BhopSpeed, BhopCard, function(v) Config.Movement.BhopSpeed = v end)
CreateToggle("Infinite Jump Ability", Config.Movement.InfJump, BhopCard, function(v) Config.Movement.InfJump = v end)

local SpeedCard = CreateCard("Speed Hack", MovePage)
CreateToggle("Enable Speed Hack", Config.Movement.SpeedHack, SpeedCard, function(v) 
    Config.Movement.SpeedHack = v 
end)
CreateSlider("Speed Value", 1, 100, Config.Movement.SpeedHackMultiplier, SpeedCard, function(v) 
    Config.Movement.SpeedHackMultiplier = v 
end)

local NoclipCard = CreateCard("Movement Bypass", MovePage)
CreateToggle("Noclip (Phase Through Walls)", Config.Movement.Noclip, NoclipCard, function(v) Config.Movement.Noclip = v end)

-- Открываем AimBot по дефолту
SwitchToTab("AimBot")

print("Eclipse Neverlose Mod V2 Loaded! AutoShot works on closest target!")
