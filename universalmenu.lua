-- ==================================================
-- ECLIPE - RAYFIELD UI (ПОЛНАЯ ВЕРСИЯ)
-- ==================================================
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local CoreGui = game:GetService("CoreGui")
local Lighting = game:GetService("Lighting")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- ==================================================
-- НАСТРОЙКИ
-- ==================================================
local ESP = {
    Enabled = false,
    Snaplines = false,
    Names = false,
    Box = false,
    Health = false,
    Color = Color3.fromRGB(255, 255, 255)
}

local Settings = {
    Skybox = "Default",
    RainbowSky = false,
    ShowFPS = false,
    FOV = 70,
    WindowWidth = 520,
    WindowHeight = 450
}

local Movement = {
    Fly = false,
    FlySpeed = 50,
    NoClip = false,
    InfiniteJump = false,
    SpeedHack = false,
    SpeedHackValue = 16,
    JumpPower = false,
    JumpPowerValue = 50,
    Bhop = false,
    BhopSpeed = 40
}

-- Keybinds для Movement
local MovementKeybinds = {
    Fly = nil,
    NoClip = nil,
    InfiniteJump = nil,
    SpeedHack = nil,
    JumpPower = nil,
    Bhop = nil
}

local Misc = {
    AntiFling = false,
    ClickTP = false,
    Invisible = false,
    ImAPart = false,
}

-- ==================================================
-- НАСТРОЙКИ AIMBOT
-- ==================================================
local Aimbot = {
    Enabled = false,
    FOV = 120,
    Smoothness = 0.3,
    AimPart = "Head",
    VisibleCheck = false,
    InvisibleCheck = false,
    TeamCheck = false,
    KeyBind = Enum.KeyCode.LeftControl,
    Target = nil
}

-- ==================================================
-- ЗАГРУЗКА RAYFIELD UI
-- ==================================================
local success, Rayfield = pcall(function()
    return loadstring(game:HttpGet('https://sirius.menu/rayfield'))()
end)

if not success or not Rayfield then
    warn("Failed to load Rayfield. Aborting UI creation.")
    return
end

-- ==================================================
-- ФУНКЦИИ MOVEMENT
-- ==================================================
local flyBodyVelocity = nil
local flyBodyGyro = nil
local speedHackConnection = nil
local noclipConnection = nil
local jumpPowerConnection = nil

-- Функция для обработки Keybinds Movement
local function HandleMovementKeybind(keyCode)
    if keyCode == MovementKeybinds.Fly then
        Movement.Fly = not Movement.Fly
        print("Fly: " .. tostring(Movement.Fly))
    elseif keyCode == MovementKeybinds.NoClip then
        Movement.NoClip = not Movement.NoClip
        ToggleNoClip(Movement.NoClip)
        print("NoClip: " .. tostring(Movement.NoClip))
    elseif keyCode == MovementKeybinds.InfiniteJump then
        Movement.InfiniteJump = not Movement.InfiniteJump
        print("Infinite Jump: " .. tostring(Movement.InfiniteJump))
    elseif keyCode == MovementKeybinds.SpeedHack then
        Movement.SpeedHack = not Movement.SpeedHack
        ApplySpeedHack()
        print("Speed Hack: " .. tostring(Movement.SpeedHack))
    elseif keyCode == MovementKeybinds.JumpPower then
        Movement.JumpPower = not Movement.JumpPower
        ApplyJumpPower()
        print("Jump Power: " .. tostring(Movement.JumpPower))
    elseif keyCode == MovementKeybinds.Bhop then
        Movement.Bhop = not Movement.Bhop
        print("Bunny Hop: " .. tostring(Movement.Bhop))
    end
end

local function ApplySpeedHack()
    if speedHackConnection then
        speedHackConnection:Disconnect()
        speedHackConnection = nil
    end
    if Movement.SpeedHack then
        speedHackConnection = RunService.Heartbeat:Connect(function()
            local char = LocalPlayer.Character
            local humanoid = char and char:FindFirstChildOfClass("Humanoid")
            if humanoid then
                humanoid.WalkSpeed = Movement.SpeedHackValue
            end
        end)
    else
        local char = LocalPlayer.Character
        local humanoid = char and char:FindFirstChildOfClass("Humanoid")
        if humanoid then
            humanoid.WalkSpeed = 16
        end
    end
end

local function ApplyJumpPower()
    if jumpPowerConnection then
        jumpPowerConnection:Disconnect()
        jumpPowerConnection = nil
    end
    if Movement.JumpPower then
        jumpPowerConnection = RunService.Heartbeat:Connect(function()
            local char = LocalPlayer.Character
            local humanoid = char and char:FindFirstChildOfClass("Humanoid")
            if humanoid then
                humanoid.JumpPower = Movement.JumpPowerValue
            end
        end)
    else
        local char = LocalPlayer.Character
        local humanoid = char and char:FindFirstChildOfClass("Humanoid")
        if humanoid and humanoid.JumpPower ~= 50 then
            humanoid.JumpPower = 50
        end
    end
end

local function ToggleNoClip(state)
    if noclipConnection then
        noclipConnection:Disconnect()
        noclipConnection = nil
    end
    if state then
        noclipConnection = RunService.Stepped:Connect(function()
            local char = LocalPlayer.Character
            if char then
                for _, part in pairs(char:GetDescendants()) do
                    if part:IsA("BasePart") then
                        part.CanCollide = false
                    end
                end
            end
        end)
    else
        local char = LocalPlayer.Character
        if char then
            for _, part in pairs(char:GetDescendants()) do
                if part:IsA("BasePart") then
                    part.CanCollide = true
                end
            end
        end
    end
end

local antiFlingConnection = nil
local function ToggleAntiFling(state)
    Misc.AntiFling = state
    if antiFlingConnection then
        antiFlingConnection:Disconnect()
        antiFlingConnection = nil
    end
    if state then
        antiFlingConnection = RunService.Heartbeat:Connect(function()
            local char = LocalPlayer.Character
            if not char then return end
            for _, player in pairs(Players:GetPlayers()) do
                if player ~= LocalPlayer and player.Character then
                    for _, part in pairs(player.Character:GetDescendants()) do
                        if part:IsA("BasePart") then
                            part.CanCollide = false
                        end
                    end
                end
            end
            for _, part in pairs(char:GetDescendants()) do
                if part:IsA("BasePart") then
                    part.CanCollide = false
                end
            end
        end)
    else
        for _, player in pairs(Players:GetPlayers()) do
            if player.Character then
                for _, part in pairs(player.Character:GetDescendants()) do
                    if part:IsA("BasePart") then
                        part.CanCollide = true
                    end
                end
            end
        end
        local char = LocalPlayer.Character
        if char then
            for _, part in pairs(char:GetDescendants()) do
                if part:IsA("BasePart") then
                    part.CanCollide = true
                end
            end
        end
    end
end

-- ==================================================
-- INVISIBLE
-- ==================================================
local invisibleConnection = nil
local originalTransparencies = {}
local originalHealthDisplayDistance = nil

local function ToggleInvisible(state)
    Misc.Invisible = state
    
    if invisibleConnection then
        invisibleConnection:Disconnect()
        invisibleConnection = nil
    end
    
    local char = LocalPlayer.Character
    if not char then return end
    
    if state then
        originalTransparencies = {}
        for _, part in pairs(char:GetDescendants()) do
            if part:IsA("BasePart") then
                originalTransparencies[part] = part.Transparency
                part.Transparency = 1
            end
        end
        
        local humanoid = char:FindFirstChildOfClass("Humanoid")
        if humanoid then
            originalHealthDisplayDistance = humanoid.HealthDisplayDistance
            humanoid.HealthDisplayDistance = 0
        end
        
        if char:FindFirstChild("HumanoidRootPart") then
            char.HumanoidRootPart:SetAttribute("Invisible", true)
        end
        
        for _, part in pairs(char:GetDescendants()) do
            if part:IsA("BasePart") then
                part.CastShadow = false
            end
        end
        
        print("Invisible включен!")
    else
        for part, transparency in pairs(originalTransparencies) do
            if part and part.Parent then
                part.Transparency = transparency
                part.CastShadow = true
            end
        end
        originalTransparencies = {}
        
        local humanoid = char:FindFirstChildOfClass("Humanoid")
        if humanoid and originalHealthDisplayDistance then
            humanoid.HealthDisplayDistance = originalHealthDisplayDistance
            originalHealthDisplayDistance = nil
        end
        
        if char:FindFirstChild("HumanoidRootPart") then
            char.HumanoidRootPart:SetAttribute("Invisible", nil)
        end
        
        print("Invisible выключен!")
    end
end

-- ==================================================
-- ФУНКЦИЯ I'M A PART
-- ==================================================
local imAPartConnection = nil
local originalParts = {}
local partBlock = nil
local partWeld = nil
local characterHidden = false

local function ToggleImAPart(state)
    Misc.ImAPart = state
    
    if imAPartConnection then
        imAPartConnection:Disconnect()
        imAPartConnection = nil
    end
    
    local char = LocalPlayer.Character
    if not char then return end
    
    if state then
        -- Создаём Tool с Handle (видно всем)
        local tool = Instance.new("Tool")
        tool.Name = "ImAPartTool"
        tool.RequiresHandle = false
        tool.CanBeDropped = false
        tool.Parent = LocalPlayer.Backpack
        
        local handle = Instance.new("Part")
        handle.Name = "Handle"
        handle.Size = Vector3.new(2, 4, 2)
        handle.Shape = Enum.PartType.Block
        handle.Material = Enum.Material.SmoothPlastic
        handle.BrickColor = BrickColor.new("Bright blue")
        handle.Anchored = false
        handle.CanCollide = true
        handle.Parent = tool
        
        local selection = Instance.new("SelectionBox")
        selection.Adornee = handle
        selection.Color3 = Color3.fromRGB(0, 200, 255)
        selection.LineThickness = 0.1
        selection.Parent = handle
        
        -- Скрываем персонажа
        for _, part in pairs(char:GetDescendants()) do
            if part:IsA("BasePart") then
                originalParts[part] = {
                    Transparency = part.Transparency,
                    CanCollide = part.CanCollide,
                    Material = part.Material
                }
                part.Transparency = 1
                part.CanCollide = false
                part.Material = Enum.Material.ForceField
            end
        end
        
        characterHidden = true
        
        wait(0.1)
        local humanoid = char:FindFirstChildOfClass("Humanoid")
        if humanoid then
            humanoid:EquipTool(tool)
            humanoid.HealthDisplayDistance = 0
        end
        
        local hrp = char:FindFirstChild("HumanoidRootPart")
        if hrp then
            partWeld = Instance.new("Weld")
            partWeld.Part0 = hrp
            partWeld.Part1 = handle
            partWeld.C0 = CFrame.new(0, 0, 0)
            partWeld.Parent = handle
        end
        
        partBlock = handle
        print("I'm a Part включен!")
        
    else
        local tool = LocalPlayer.Backpack:FindFirstChild("ImAPartTool")
        if tool then
            tool:Destroy()
        end
        
        local char = LocalPlayer.Character
        if char then
            local toolInHand = char:FindFirstChild("ImAPartTool")
            if toolInHand then
                toolInHand:Destroy()
            end
        end
        
        for part, data in pairs(originalParts) do
            if part and part.Parent then
                part.Transparency = data.Transparency or 0
                part.CanCollide = data.CanCollide or true
                part.Material = data.Material or Enum.Material.Plastic
            end
        end
        originalParts = {}
        characterHidden = false
        partBlock = nil
        partWeld = nil
        
        local humanoid = char and char:FindFirstChildOfClass("Humanoid")
        if humanoid then
            humanoid.HealthDisplayDistance = 100
        end
        
        print("I'm a Part выключен!")
    end
end

-- ==================================================
-- ОБНОВЛЕНИЕ MOVEMENT
-- ==================================================
local function UpdateMovement()
    local char = LocalPlayer.Character
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    local humanoid = char and char:FindFirstChildOfClass("Humanoid")
    
    if not char or not hrp then return end
    
    if Movement.Fly and hrp then
        if not flyBodyVelocity then
            flyBodyVelocity = Instance.new("BodyVelocity")
            flyBodyVelocity.MaxForce = Vector3.new(100000, 100000, 100000)
            flyBodyVelocity.Parent = hrp
            flyBodyGyro = Instance.new("BodyGyro")
            flyBodyGyro.MaxTorque = Vector3.new(100000, 100000, 100000)
            flyBodyGyro.Parent = hrp
        end
        local moveDir = Vector3.new(0,0,0)
        if UserInputService:IsKeyDown(Enum.KeyCode.W) then moveDir = moveDir + Camera.CFrame.LookVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.S) then moveDir = moveDir - Camera.CFrame.LookVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.A) then moveDir = moveDir - Camera.CFrame.RightVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.D) then moveDir = moveDir + Camera.CFrame.RightVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.Space) then moveDir = moveDir + Vector3.new(0, 1, 0) end
        if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then moveDir = moveDir - Vector3.new(0, 1, 0) end
        if moveDir.Magnitude > 0 then
            flyBodyVelocity.Velocity = moveDir.Unit * Movement.FlySpeed
        else
            flyBodyVelocity.Velocity = Vector3.new(0, 0, 0)
        end
        flyBodyGyro.CFrame = Camera.CFrame
        humanoid.PlatformStand = true
    else
        if flyBodyVelocity then flyBodyVelocity:Destroy(); flyBodyVelocity = nil end
        if flyBodyGyro then flyBodyGyro:Destroy(); flyBodyGyro = nil end
        if humanoid then humanoid.PlatformStand = false end
    end
    
    if Movement.Bhop and UserInputService:IsKeyDown(Enum.KeyCode.Space) and hrp then
        local direction = Vector3.new(0, 0, 0)
        if UserInputService:IsKeyDown(Enum.KeyCode.W) then direction = direction + Camera.CFrame.LookVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.S) then direction = direction - Camera.CFrame.LookVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.A) then direction = direction - Camera.CFrame.RightVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.D) then direction = direction + Camera.CFrame.RightVector end
        if direction.Magnitude == 0 then direction = Camera.CFrame.LookVector end
        local finalMove = Vector3.new(direction.X, 0, direction.Z).Unit
        hrp.Velocity = Vector3.new(finalMove.X * Movement.BhopSpeed, hrp.Velocity.Y, finalMove.Z * Movement.BhopSpeed)
    end
end

ApplySpeedHack()
ApplyJumpPower()
RunService.Heartbeat:Connect(UpdateMovement)

LocalPlayer.CharacterAdded:Connect(function()
    ApplySpeedHack()
    ApplyJumpPower()
    ToggleNoClip(Movement.NoClip)
    ToggleAntiFling(Misc.AntiFling)
    if Misc.Invisible then
        ToggleInvisible(true)
    end
    if Misc.ImAPart then
        ToggleImAPart(true)
    end
end)

UserInputService.JumpRequest:Connect(function()
    if Movement.InfiniteJump and LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid") then
        LocalPlayer.Character:FindFirstChildOfClass("Humanoid"):ChangeState(Enum.HumanoidStateType.Jumping)
    end
end)

-- ==================================================
-- SKYBOX
-- ==================================================
local function ApplySkybox(skyName)
    Settings.Skybox = skyName
    if Settings.RainbowSky then return end
    local color
    if skyName == "Default" then
        color = Color3.fromRGB(255, 255, 255)
        Lighting.Ambient = Color3.fromRGB(127, 127, 127)
        Lighting.Brightness = 1
    elseif skyName == "Night" then
        color = Color3.fromRGB(10, 10, 40)
        Lighting.Ambient = Color3.fromRGB(20, 20, 40)
        Lighting.Brightness = 0.3
    elseif skyName == "Sunset" then
        color = Color3.fromRGB(255, 150, 50)
        Lighting.Ambient = Color3.fromRGB(200, 120, 50)
        Lighting.Brightness = 0.8
    elseif skyName == "Neon" then
        color = Color3.fromRGB(200, 50, 255)
        Lighting.Ambient = Color3.fromRGB(150, 0, 200)
        Lighting.Brightness = 1.2
    elseif skyName == "Space" then
        color = Color3.fromRGB(0, 20, 80)
        Lighting.Ambient = Color3.fromRGB(5, 5, 20)
        Lighting.Brightness = 0.2
    end
    Lighting.ColorShift_Top = color
end

local rainbowConnection
local function ToggleRainbowSky(state)
    Settings.RainbowSky = state
    if rainbowConnection then rainbowConnection:Disconnect() rainbowConnection = nil end
    if state then
        rainbowConnection = RunService.RenderStepped:Connect(function()
            local hue = tick() % 10 / 10
            Lighting.ColorShift_Top = Color3.fromHSV(hue, 0.8, 1)
        end)
    else
        ApplySkybox(Settings.Skybox)
    end
end

-- ==================================================
-- FPS
-- ==================================================
local fpsLabel = nil
local function CreateFPSLabel()
    if fpsLabel then fpsLabel.Parent:Destroy(); fpsLabel = nil end
    if not Settings.ShowFPS then return end
    local screenGui = Instance.new("ScreenGui", CoreGui)
    screenGui.Name = "FPS_Counter"
    fpsLabel = Instance.new("TextLabel", screenGui)
    fpsLabel.Size = UDim2.new(0, 80, 0, 30)
    fpsLabel.Position = UDim2.new(1, -90, 0, 10)
    fpsLabel.BackgroundColor3 = Color3.fromRGB(0,0,0)
    fpsLabel.BackgroundTransparency = 0.5
    fpsLabel.TextColor3 = Color3.fromRGB(255,255,255)
    fpsLabel.TextSize = 16
    fpsLabel.Font = Enum.Font.GothamBold
    fpsLabel.Text = "FPS: 0"
    Instance.new("UICorner", fpsLabel).CornerRadius = UDim.new(0, 4)
    local frames = 0
    local lastTime = tick()
    RunService.RenderStepped:Connect(function()
        frames = frames + 1
        local now = tick()
        if now - lastTime >= 1 then
            fpsLabel.Text = "FPS: " .. frames
            frames = 0
            lastTime = now
        end
    end)
end

-- ==================================================
-- ESP
-- ==================================================
local espObjects = {}
local function HardClearESP()
    for _, player in pairs(Players:GetPlayers()) do
        if player.Character then
            for _, obj in pairs(player.Character:GetDescendants()) do
                if obj.Name == "ESP_Object" then obj:Destroy() end
            end
        end
    end
    for _, objs in pairs(espObjects) do
        for _, obj in pairs(objs) do if obj and obj.Parent then obj:Destroy() end end
    end
    espObjects = {}
end

local function UpdateESPForPlayer(player)
    if player == LocalPlayer then return end
    local character = player.Character
    if not character then return end
    local rootPart = character:FindFirstChild("HumanoidRootPart")
    if not rootPart then return end
    for _, obj in pairs(character:GetDescendants()) do
        if obj.Name == "ESP_Object" then obj:Destroy() end
    end
    if espObjects[player] then
        for _, obj in pairs(espObjects[player]) do if obj and obj.Parent then obj:Destroy() end end
        espObjects[player] = nil
    end
    if not ESP.Enabled then return end
    local objects = {}
    local highlight = Instance.new("Highlight")
    highlight.Name = "ESP_Object"
    highlight.FillTransparency = 0.6
    highlight.FillColor = ESP.Color
    highlight.OutlineTransparency = 0.4
    highlight.OutlineColor = ESP.Color
    highlight.Parent = character
    table.insert(objects, highlight)
    if ESP.Box then
        local box = Instance.new("BoxHandleAdornment")
        box.Name = "ESP_Object"
        box.Size = Vector3.new(3, 5, 1.5)
        box.Adornee = rootPart
        box.ZIndex = 0
        box.AlwaysOnTop = true
        box.Color3 = ESP.Color
        box.Transparency = 0.3
        box.Parent = rootPart
        table.insert(objects, box)
    end
    if ESP.Names then
        local billboard = Instance.new("BillboardGui")
        billboard.Name = "ESP_Object"
        billboard.Adornee = rootPart
        billboard.Size = UDim2.new(0, 100, 0, 24)
        billboard.StudsOffset = Vector3.new(0, 3.5, 0)
        billboard.AlwaysOnTop = true
        local label = Instance.new("TextLabel")
        label.Name = "ESP_Object"
        label.Size = UDim2.new(1,0,1,0)
        label.BackgroundTransparency = 1
        label.Text = player.Name
        label.TextColor3 = Color3.fromRGB(255,255,255)
        label.TextSize = 12
        label.Font = Enum.Font.GothamBold
        label.Parent = billboard
        billboard.Parent = rootPart
        table.insert(objects, billboard)
    end
    if ESP.Health then
        local billboard = Instance.new("BillboardGui")
        billboard.Name = "ESP_Object"
        billboard.Adornee = rootPart
        billboard.Size = UDim2.new(0, 40, 0, 6)
        billboard.StudsOffset = Vector3.new(0, 2.2, 0)
        billboard.AlwaysOnTop = true
        local bg = Instance.new("Frame")
        bg.Name = "ESP_Object"
        bg.Size = UDim2.new(1,0,1,0)
        bg.BackgroundColor3 = Color3.fromRGB(40,40,50)
        bg.Parent = billboard
        local fill = Instance.new("Frame")
        fill.Name = "ESP_Object"
        fill.Size = UDim2.new(1,0,1,0)
        fill.BackgroundColor3 = Color3.fromRGB(0,255,0)
        fill.Parent = bg
        billboard.Parent = rootPart
        table.insert(objects, billboard)
        local humanoid = character:FindFirstChildOfClass("Humanoid")
        if humanoid then
            local function updateHealth()
                local health = humanoid.Health
                local maxHealth = humanoid.MaxHealth
                if maxHealth > 0 then
                    fill.Size = UDim2.new(math.clamp(health/maxHealth,0,1),0,1,0)
                    fill.BackgroundColor3 = Color3.fromRGB(255*(1-health/maxHealth), 255*(health/maxHealth), 0)
                end
            end
            updateHealth()
            humanoid:GetPropertyChangedSignal("Health"):Connect(updateHealth)
        end
    end
    if ESP.Snaplines and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
        local myRoot = LocalPlayer.Character.HumanoidRootPart
        local attachment0 = Instance.new("Attachment")
        attachment0.Name = "ESP_Object"
        attachment0.Parent = myRoot
        local attachment1 = Instance.new("Attachment")
        attachment1.Name = "ESP_Object"
        attachment1.Parent = rootPart
        local beam = Instance.new("Beam")
        beam.Name = "ESP_Object"
        beam.Attachment0 = attachment0
        beam.Attachment1 = attachment1
        beam.Color = ColorSequence.new(ESP.Color)
        beam.Width0 = 0.1
        beam.Width1 = 0.1
        beam.FaceCamera = true
        beam.Parent = character
        table.insert(objects, attachment0)
        table.insert(objects, attachment1)
        table.insert(objects, beam)
    end
    espObjects[player] = objects
end

local function RefreshESP()
    HardClearESP()
    if not ESP.Enabled then return end
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer then UpdateESPForPlayer(player) end
    end
end

Players.PlayerAdded:Connect(function(player)
    player.CharacterAdded:Connect(function()
        wait(0.5)
        if ESP.Enabled then UpdateESPForPlayer(player) end
    end)
end)

-- ==================================================
-- ФУНКЦИИ MISC
-- ==================================================

-- Click TP
local clickTPConnection = nil
local function ToggleClickTP(state)
    Misc.ClickTP = state
    if clickTPConnection then
        clickTPConnection:Disconnect()
        clickTPConnection = nil
    end
    if state then
        clickTPConnection = UserInputService.InputBegan:Connect(function(input, gp)
            if gp then return end
            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                local mouse = LocalPlayer:GetMouse()
                if mouse.Target then
                    local targetPos = mouse.Hit.Position
                    local char = LocalPlayer.Character
                    local hrp = char and char:FindFirstChild("HumanoidRootPart")
                    if hrp then
                        hrp.CFrame = CFrame.new(targetPos)
                    end
                end
            end
        end)
    end
end

-- Отдельный ScreenGui для окон
local PopupGui = Instance.new("ScreenGui")
PopupGui.Name = "PopupGui"
PopupGui.Parent = CoreGui
PopupGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

-- Окно выбора игрока
local function CreatePlayerSelectWindow(title, callback, showAll, showMe)
    for _, child in pairs(PopupGui:GetChildren()) do
        child:Destroy()
    end
    
    local window = Instance.new("Frame", PopupGui)
    window.Size = UDim2.new(0, 350, 0, 450)
    window.Position = UDim2.new(0.5, -175, 0.5, -225)
    window.BackgroundColor3 = Color3.fromRGB(12, 12, 18)
    window.BorderSizePixel = 0
    window.ZIndex = 10
    Instance.new("UICorner", window).CornerRadius = UDim.new(0, 10)
    
    local backdrop = Instance.new("Frame", PopupGui)
    backdrop.Size = UDim2.new(1, 0, 1, 0)
    backdrop.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    backdrop.BackgroundTransparency = 0.5
    backdrop.ZIndex = 5
    backdrop.Name = "Backdrop"
    
    local shadow = Instance.new("Frame", window)
    shadow.Size = UDim2.new(1, 4, 1, 4)
    shadow.Position = UDim2.new(0, -2, 0, -2)
    shadow.BackgroundColor3 = Color3.fromRGB(0,0,0)
    shadow.BackgroundTransparency = 0.6
    shadow.ZIndex = -1
    Instance.new("UICorner", shadow).CornerRadius = UDim.new(0, 14)
    
    local titleFrame = Instance.new("Frame", window)
    titleFrame.Size = UDim2.new(1, 0, 0, 42)
    titleFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 30)
    titleFrame.BorderSizePixel = 0
    Instance.new("UICorner", titleFrame).CornerRadius = UDim.new(0, 10)
    local titleFix = Instance.new("Frame", titleFrame)
    titleFix.Size = UDim2.new(1, 0, 0, 10)
    titleFix.Position = UDim2.new(0, 0, 1, -10)
    titleFix.BackgroundColor3 = Color3.fromRGB(20, 20, 30)
    titleFix.BorderSizePixel = 0
    
    local titleLabel = Instance.new("TextLabel", titleFrame)
    titleLabel.Size = UDim2.new(1, -50, 1, 0)
    titleLabel.Position = UDim2.new(0, 15, 0, 0)
    titleLabel.BackgroundTransparency = 1
    titleLabel.Text = "👤 " .. title
    titleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    titleLabel.TextSize = 16
    titleLabel.Font = Enum.Font.GothamBold
    titleLabel.TextXAlignment = Enum.TextXAlignment.Left
    
    local closeBtn = Instance.new("TextButton", titleFrame)
    closeBtn.Size = UDim2.new(0, 32, 0, 32)
    closeBtn.Position = UDim2.new(1, -42, 0.5, -16)
    closeBtn.BackgroundColor3 = Color3.fromRGB(50, 50, 70)
    closeBtn.Text = "✕"
    closeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    closeBtn.TextSize = 18
    closeBtn.Font = Enum.Font.GothamBold
    Instance.new("UICorner", closeBtn).CornerRadius = UDim.new(0, 6)
    closeBtn.MouseButton1Click:Connect(function()
        PopupGui:ClearAllChildren()
    end)
    closeBtn.MouseEnter:Connect(function()
        closeBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
    end)
    closeBtn.MouseLeave:Connect(function()
        closeBtn.BackgroundColor3 = Color3.fromRGB(50, 50, 70)
    end)
    
    local listFrame = Instance.new("ScrollingFrame", window)
    listFrame.Size = UDim2.new(1, -20, 1, -85)
    listFrame.Position = UDim2.new(0, 10, 0, 50)
    listFrame.BackgroundTransparency = 1
    listFrame.ScrollBarThickness = 4
    listFrame.ScrollBarImageColor3 = Color3.fromRGB(80, 80, 100)
    listFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
    listFrame.AutomaticCanvasSize = Enum.AutomaticSize.Y
    
    local listLayout = Instance.new("UIListLayout", listFrame)
    listLayout.Padding = UDim.new(0, 6)
    
    if showAll then
        local allBtn = Instance.new("TextButton", listFrame)
        allBtn.Size = UDim2.new(1, 0, 0, 38)
        allBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 60)
        allBtn.Text = "🔴 ALL PLAYERS"
        allBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
        allBtn.TextSize = 15
        allBtn.Font = Enum.Font.GothamBold
        Instance.new("UICorner", allBtn).CornerRadius = UDim.new(0, 6)
        allBtn.MouseButton1Click:Connect(function()
            callback("All")
            PopupGui:ClearAllChildren()
        end)
        allBtn.MouseEnter:Connect(function()
            allBtn.BackgroundColor3 = Color3.fromRGB(80, 80, 120)
        end)
        allBtn.MouseLeave:Connect(function()
            allBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 60)
        end)
    end
    
    if showMe then
        local meBtn = Instance.new("TextButton", listFrame)
        meBtn.Size = UDim2.new(1, 0, 0, 38)
        meBtn.BackgroundColor3 = Color3.fromRGB(50, 150, 50)
        meBtn.Text = "🟢 " .. LocalPlayer.Name .. " (ME)"
        meBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
        meBtn.TextSize = 14
        meBtn.Font = Enum.Font.GothamBold
        Instance.new("UICorner", meBtn).CornerRadius = UDim.new(0, 6)
        meBtn.MouseButton1Click:Connect(function()
            callback(LocalPlayer)
            PopupGui:ClearAllChildren()
        end)
        meBtn.MouseEnter:Connect(function()
            meBtn.BackgroundColor3 = Color3.fromRGB(80, 200, 80)
        end)
        meBtn.MouseLeave:Connect(function()
            meBtn.BackgroundColor3 = Color3.fromRGB(50, 150, 50)
        end)
    end
    
    local playerCount = 0
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer then
            playerCount = playerCount + 1
            local btn = Instance.new("TextButton", listFrame)
            btn.Size = UDim2.new(1, 0, 0, 38)
            btn.BackgroundColor3 = Color3.fromRGB(35, 35, 55)
            btn.Text = "  " .. player.Name
            btn.TextColor3 = Color3.fromRGB(255, 255, 255)
            btn.TextSize = 14
            btn.Font = Enum.Font.Gotham
            btn.TextXAlignment = Enum.TextXAlignment.Left
            Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 6)
            btn.MouseEnter:Connect(function()
                btn.BackgroundColor3 = Color3.fromRGB(80, 80, 120)
            end)
            btn.MouseLeave:Connect(function()
                btn.BackgroundColor3 = Color3.fromRGB(35, 35, 55)
            end)
            btn.MouseButton1Click:Connect(function()
                callback(player)
                PopupGui:ClearAllChildren()
            end)
        end
    end
    
    if playerCount == 0 and not showMe then
        local noPlayers = Instance.new("TextLabel", listFrame)
        noPlayers.Size = UDim2.new(1, 0, 0, 40)
        noPlayers.BackgroundTransparency = 1
        noPlayers.Text = "❌ No players found"
        noPlayers.TextColor3 = Color3.fromRGB(150, 150, 180)
        noPlayers.TextSize = 14
        noPlayers.Font = Enum.Font.Gotham
        noPlayers.TextXAlignment = Enum.TextXAlignment.Center
    end
end

-- ==================================================
-- ФУНКЦИИ ДЛЯ MISC
-- ==================================================

-- Bring Player
local function BringPlayer(target)
    if target == "All" then
        for _, player in pairs(Players:GetPlayers()) do
            if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
                local targetHrp = player.Character.HumanoidRootPart
                local char = LocalPlayer.Character
                local myHrp = char and char:FindFirstChild("HumanoidRootPart")
                if myHrp then
                    targetHrp.CFrame = myHrp.CFrame + Vector3.new(math.random(-3,3), 0, math.random(-3,3))
                end
            end
        end
    elseif target and target.Character and target.Character:FindFirstChild("HumanoidRootPart") then
        local targetHrp = target.Character.HumanoidRootPart
        local char = LocalPlayer.Character
        local myHrp = char and char:FindFirstChild("HumanoidRootPart")
        if myHrp then
            targetHrp.CFrame = myHrp.CFrame + Vector3.new(0, 2, 0)
        end
    end
end

-- Freeze
local frozenPlayers = {}
local function FreezePlayer(target)
    if target == "All" then
        for _, player in pairs(Players:GetPlayers()) do
            if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("Humanoid") then
                local humanoid = player.Character.Humanoid
                frozenPlayers[player] = humanoid.WalkSpeed
                humanoid.WalkSpeed = 0
                humanoid.JumpPower = 0
                humanoid.PlatformStand = true
            end
        end
    elseif target and target.Character and target.Character:FindFirstChild("Humanoid") then
        local humanoid = target.Character.Humanoid
        frozenPlayers[target] = humanoid.WalkSpeed
        humanoid.WalkSpeed = 0
        humanoid.JumpPower = 0
        humanoid.PlatformStand = true
    end
end

-- Unfreeze
local function UnfreezePlayer(target)
    if target == "All" then
        for _, player in pairs(Players:GetPlayers()) do
            if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("Humanoid") then
                local humanoid = player.Character.Humanoid
                local oldSpeed = frozenPlayers[player] or 16
                humanoid.WalkSpeed = oldSpeed
                humanoid.JumpPower = 50
                humanoid.PlatformStand = false
                frozenPlayers[player] = nil
            end
        end
    elseif target and target.Character and target.Character:FindFirstChild("Humanoid") then
        local humanoid = target.Character.Humanoid
        local oldSpeed = frozenPlayers[target] or 16
        humanoid.WalkSpeed = oldSpeed
        humanoid.JumpPower = 50
        humanoid.PlatformStand = false
        frozenPlayers[target] = nil
    end
end

-- Kill
local function KillPlayer(target)
    if target == "All" then
        for _, player in pairs(Players:GetPlayers()) do
            if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("Humanoid") then
                player.Character.Humanoid.Health = 0
            end
        end
    elseif target and target.Character and target.Character:FindFirstChild("Humanoid") then
        target.Character.Humanoid.Health = 0
    end
end

-- Loop Kill
local loopKillConnection = nil
local loopKillTarget = nil
local function StartLoopKill(target)
    if loopKillConnection then
        loopKillConnection:Disconnect()
        loopKillConnection = nil
    end
    loopKillTarget = target
    loopKillConnection = RunService.Heartbeat:Connect(function()
        if loopKillTarget == "All" then
            for _, player in pairs(Players:GetPlayers()) do
                if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("Humanoid") then
                    player.Character.Humanoid.Health = 0
                end
            end
        elseif loopKillTarget and loopKillTarget.Character and loopKillTarget.Character:FindFirstChild("Humanoid") then
            loopKillTarget.Character.Humanoid.Health = 0
        end
    end)
end

local function StopLoopKill()
    if loopKillConnection then
        loopKillConnection:Disconnect()
        loopKillConnection = nil
    end
    loopKillTarget = nil
end

-- ==================================================
-- FLING
-- ==================================================
local flingConnection = nil
local flingTarget = nil
local flinging = false
local flingGyro = nil
local startPosition = nil

local function GetGroundPosition()
    local char = LocalPlayer.Character
    if not char then return nil end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not hrp then return nil end
    
    local rayOrigin = hrp.Position
    local rayDirection = Vector3.new(0, -1000, 0)
    local raycastParams = RaycastParams.new()
    raycastParams.FilterType = Enum.RaycastFilterType.Exclude
    raycastParams.FilterDescendantsInstances = {char, workspace.Terrain}
    
    local result = workspace:Raycast(rayOrigin, rayDirection, raycastParams)
    if result then
        return result.Position + Vector3.new(0, 3, 0)
    end
    return nil
end

local function StartFling(target)
    if flingConnection then
        flingConnection:Disconnect()
        flingConnection = nil
    end
    if flingGyro then
        flingGyro:Destroy()
        flingGyro = nil
    end
    
    local char = LocalPlayer.Character
    if char and char:FindFirstChild("HumanoidRootPart") then
        startPosition = char.HumanoidRootPart.Position
    end
    
    flingTarget = target
    flinging = true
    
    spawn(function()
        while flinging do
            local char = LocalPlayer.Character
            if not char then wait(0.1) continue end
            
            local hrp = char:FindFirstChild("HumanoidRootPart")
            if not hrp then wait(0.1) continue end
            
            local targetPlayer = flingTarget
            if targetPlayer == "All" then
                for _, p in pairs(Players:GetPlayers()) do
                    if p ~= LocalPlayer and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
                        targetPlayer = p
                        break
                    end
                end
            end
            
            if not targetPlayer or not targetPlayer.Character or not targetPlayer.Character:FindFirstChild("HumanoidRootPart") then
                wait(0.1)
                continue
            end
            
            local targetHrp = targetPlayer.Character.HumanoidRootPart
            
            for _, part in pairs(char:GetDescendants()) do
                if part:IsA("BasePart") then
                    part.CustomPhysicalProperties = PhysicalProperties.new(math.huge, 0.3, 0.5)
                end
            end
            
            for _, part in pairs(char:GetDescendants()) do
                if part:IsA("BasePart") then
                    part.CanCollide = false
                    part.Massless = true
                    part.Velocity = Vector3.new(0, 0, 0)
                end
            end
            
            hrp.CFrame = CFrame.new(targetHrp.Position)
            
            if not flingGyro then
                flingGyro = Instance.new("BodyAngularVelocity")
                flingGyro.Parent = hrp
                flingGyro.MaxTorque = Vector3.new(0, math.huge, 0)
                flingGyro.P = math.huge
            end
            
            if flingGyro then
                flingGyro.AngularVelocity = Vector3.new(0, 99999, 0)
                wait(0.2)
                if flingGyro then
                    flingGyro.AngularVelocity = Vector3.new(0, 0, 0)
                end
                wait(0.1)
            end
        end
    end)
end

local function StopFling()
    flinging = false
    if flingConnection then
        flingConnection:Disconnect()
        flingConnection = nil
    end
    if flingGyro then
        flingGyro:Destroy()
        flingGyro = nil
    end
    flingTarget = nil
    
    local char = LocalPlayer.Character
    if char then
        local hrp = char:FindFirstChild("HumanoidRootPart")
        if hrp then
            hrp.Velocity = Vector3.new(0, 0, 0)
            hrp.RotVelocity = Vector3.new(0, 0, 0)
            
            if startPosition then
                local ground = GetGroundPosition()
                if ground then
                    hrp.CFrame = CFrame.new(ground)
                else
                    hrp.CFrame = CFrame.new(startPosition)
                end
                startPosition = nil
            end
        end
        local humanoid = char:FindFirstChildOfClass("Humanoid")
        if humanoid then
            humanoid.PlatformStand = false
        end
        for _, part in pairs(char:GetDescendants()) do
            if part:IsA("BasePart") then
                part.CanCollide = true
                part.Massless = false
                part.CustomPhysicalProperties = PhysicalProperties.new(1, 0.3, 0.5)
            end
        end
    end
    print("Fling stopped!")
end

-- ==================================================
-- AIMBOT
-- ==================================================
local aimbotConnection = nil
local aimbotCircle = nil

-- Функция для создания круга FOV
local function CreateFOVCircle()
    if aimbotCircle then
        aimbotCircle:Destroy()
        aimbotCircle = nil
    end
    
    if not Aimbot.Enabled then return end
    
    local circleGui = Instance.new("ScreenGui")
    circleGui.Name = "AimbotFOV"
    circleGui.Parent = CoreGui
    circleGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    
    local circle = Instance.new("Frame")
    circle.Size = UDim2.new(0, Aimbot.FOV * 2, 0, Aimbot.FOV * 2)
    circle.Position = UDim2.new(0.5, -Aimbot.FOV, 0.5, -Aimbot.FOV)
    circle.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    circle.BackgroundTransparency = 0.85
    circle.BorderSizePixel = 2
    circle.BorderColor3 = Color3.fromRGB(255, 255, 255)
    circle.Parent = circleGui
    Instance.new("UICorner", circle).CornerRadius = UDim.new(1, 0)
    
    aimbotCircle = circleGui
end

-- Функция для проверки видимости
local function IsVisible(targetPart)
    if not targetPart then return false end
    
    local char = LocalPlayer.Character
    if not char then return false end
    
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not hrp then return false end
    
    local raycastParams = RaycastParams.new()
    raycastParams.FilterType = Enum.RaycastFilterType.Exclude
    raycastParams.FilterDescendantsInstances = {char}
    
    local origin = hrp.Position
    local destination = targetPart.Position
    
    local result = workspace:Raycast(origin, destination - origin, raycastParams)
    
    if result then
        if result.Instance:IsDescendantOf(targetPart.Parent) then
            return true
        end
        return false
    end
    
    return true
end

-- Функция для проверки невидимости
local function IsPlayerInvisible(player)
    if not player or not player.Character then return false end
    
    local char = player.Character
    
    for _, part in pairs(char:GetDescendants()) do
        if part:IsA("BasePart") and part.Transparency >= 0.9 then
            return true
        end
    end
    
    local humanoid = char:FindFirstChildOfClass("Humanoid")
    if humanoid and humanoid.HealthDisplayDistance == 0 then
        return true
    end
    
    if char:FindFirstChild("HumanoidRootPart") then
        local hrp = char.HumanoidRootPart
        if hrp:GetAttribute("Invisible") == true then
            return true
        end
    end
    
    if char:FindFirstChild("InvisibleEffect") or char:FindFirstChild("StealthEffect") then
        return true
    end
    
    if char:FindFirstChild("Invisible") then
        return true
    end
    
    return false
end

-- Функция для получения цели
local function GetAimbotTarget()
    local char = LocalPlayer.Character
    if not char then return nil end
    
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not hrp then return nil end
    
    local camera = Camera
    local closestPlayer = nil
    local closestDistance = Aimbot.FOV
    
    for _, player in pairs(Players:GetPlayers()) do
        if player == LocalPlayer then continue end
        if not player.Character then continue end
        
        if Aimbot.InvisibleCheck and IsPlayerInvisible(player) then
            continue
        end
        
        local targetChar = player.Character
        local targetPart = targetChar:FindFirstChild(Aimbot.AimPart)
        
        if not targetPart then
            targetPart = targetChar:FindFirstChild("HumanoidRootPart")
        end
        
        if not targetPart then continue end
        
        if Aimbot.VisibleCheck and not IsVisible(targetPart) then
            continue
        end
        
        if Aimbot.TeamCheck then
            local playerTeam = player.Team
            local myTeam = LocalPlayer.Team
            if playerTeam and myTeam and playerTeam == myTeam then
                continue
            end
        end
        
        local targetPos = targetPart.Position
        local screenPos, onScreen = camera:WorldToScreenPoint(targetPos)
        
        if not onScreen then continue end
        
        local screenCenter = Vector2.new(camera.ViewportSize.X / 2, camera.ViewportSize.Y / 2)
        local distance = (Vector2.new(screenPos.X, screenPos.Y) - screenCenter).Magnitude
        
        if distance < closestDistance then
            closestDistance = distance
            closestPlayer = {
                Player = player,
                Part = targetPart,
                Position = targetPos
            }
        end
    end
    
    return closestPlayer
end

-- Функция для плавного наведения
local function SmoothAim(targetPosition)
    local camera = Camera
    local char = LocalPlayer.Character
    if not char then return end
    
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not hrp then return end
    
    local currentCFrame = camera.CFrame
    local targetCFrame = CFrame.lookAt(currentCFrame.Position, targetPosition)
    
    local lerpFactor = math.clamp(Aimbot.Smoothness, 0.01, 1)
    local newCFrame = currentCFrame:Lerp(targetCFrame, lerpFactor)
    
    camera.CFrame = newCFrame
end

-- Основная функция Aimbot
local function UpdateAimbot()
    if not Aimbot.Enabled then return end
    
    local isKeyPressed = UserInputService:IsKeyDown(Aimbot.KeyBind)
    if not isKeyPressed then return end
    
    local target = GetAimbotTarget()
    if not target then return end
    
    SmoothAim(target.Position)
end

-- Включение/выключение Aimbot
local function ToggleAimbot(state)
    Aimbot.Enabled = state
    
    if aimbotConnection then
        aimbotConnection:Disconnect()
        aimbotConnection = nil
    end
    
    if aimbotCircle then
        aimbotCircle:Destroy()
        aimbotCircle = nil
    end
    
    if state then
        aimbotConnection = RunService.RenderStepped:Connect(UpdateAimbot)
        CreateFOVCircle()
    end
end

-- Обновление круга FOV
local function UpdateFOVCircle()
    if aimbotCircle then
        aimbotCircle:Destroy()
        aimbotCircle = nil
    end
    if Aimbot.Enabled then
        CreateFOVCircle()
    end
end

-- ==================================================
-- ДИЗАЙН МЕНЮ (RAYFIELD UI)
-- ==================================================
local Window = Rayfield:CreateWindow({
    Name = "Eclipse Menu",
    LoadingTitle = "Eclipse Loader",
    LoadingSubtitle = "by Eclipse Team",
    ConfigurationSaving = {
        Enabled = true,
        FolderName = "EclipseConfigs",
        FileName = "Eclipse"
    },
    Discord = {
        Enabled = false,
    },
    KeySystem = false,
})

-- ==================================================
-- ВКЛАДКА COMBAT
-- ==================================================
local CombatTab = Window:CreateTab("Combat")
CombatTab:CreateSection("Aimbot")

CombatTab:CreateToggle({
    Name = "Enable Aimbot",
    CurrentValue = false,
    Flag = "AimbotEnabled",
    Callback = function(v)
        ToggleAimbot(v)
    end,
})

CombatTab:CreateSlider({
    Name = "Aimbot FOV",
    Range = {30, 500},
    Increment = 5,
    CurrentValue = 120,
    Flag = "AimbotFOV",
    Callback = function(v)
        Aimbot.FOV = v
        UpdateFOVCircle()
    end,
})

CombatTab:CreateSlider({
    Name = "Smoothness",
    Range = {1, 100},
    Increment = 1,
    CurrentValue = 30,
    Flag = "Smoothness",
    Callback = function(v)
        Aimbot.Smoothness = v / 100
    end,
})

CombatTab:CreateDropdown({
    Name = "Aim Part",
    Options = {"Head", "Torso", "HumanoidRootPart"},
    CurrentOption = "Head",
    Flag = "AimPart",
    Callback = function(v)
        Aimbot.AimPart = v
    end,
})

CombatTab:CreateToggle({
    Name = "Visible Check",
    CurrentValue = false,
    Flag = "VisibleCheck",
    Callback = function(v)
        Aimbot.VisibleCheck = v
    end,
})

CombatTab:CreateToggle({
    Name = "Invisible Check",
    CurrentValue = false,
    Flag = "InvisibleCheck",
    Callback = function(v)
        Aimbot.InvisibleCheck = v
    end,
})

CombatTab:CreateToggle({
    Name = "Team Check",
    CurrentValue = false,
    Flag = "TeamCheck",
    Callback = function(v)
        Aimbot.TeamCheck = v
    end,
})

CombatTab:CreateKeybind({
    Name = "Key Bind",
    CurrentKeybind = "LeftControl",
    HoldToInteract = false,
    Flag = "AimbotKey",
    Callback = function(v)
        Aimbot.KeyBind = v
    end,
})

-- ==================================================
-- ВКЛАДКА MOVEMENT
-- ==================================================
local MovementTab = Window:CreateTab("Movement")
MovementTab:CreateSection("Movement Modifiers")

MovementTab:CreateToggle({
    Name = "Fly",
    CurrentValue = false,
    Flag = "FlyEnabled",
    Callback = function(v)
        Movement.Fly = v
    end,
})

MovementTab:CreateSlider({
    Name = "Fly Speed",
    Range = {10, 200},
    Increment = 5,
    CurrentValue = 50,
    Flag = "FlySpeed",
    Callback = function(v)
        Movement.FlySpeed = v
    end,
})

MovementTab:CreateKeybind({
    Name = "Fly Keybind",
    CurrentKeybind = "None",
    HoldToInteract = false,
    Flag = "FlyKey",
    Callback = function(v)
        MovementKeybinds.Fly = v
    end,
})

MovementTab:CreateToggle({
    Name = "Speed Hack",
    CurrentValue = false,
    Flag = "SpeedHack",
    Callback = function(v)
        Movement.SpeedHack = v
        ApplySpeedHack()
    end,
})

MovementTab:CreateSlider({
    Name = "Speed Value",
    Range = {1, 100},
    Increment = 1,
    CurrentValue = 16,
    Flag = "SpeedValue",
    Callback = function(v)
        Movement.SpeedHackValue = v
        if Movement.SpeedHack then ApplySpeedHack() end
    end,
})

MovementTab:CreateKeybind({
    Name = "Speed Hack Keybind",
    CurrentKeybind = "None",
    HoldToInteract = false,
    Flag = "SpeedKey",
    Callback = function(v)
        MovementKeybinds.SpeedHack = v
    end,
})

MovementTab:CreateToggle({
    Name = "Jump Power",
    CurrentValue = false,
    Flag = "JumpPower",
    Callback = function(v)
        Movement.JumpPower = v
        ApplyJumpPower()
    end,
})

MovementTab:CreateSlider({
    Name = "Jump Value",
    Range = {1, 200},
    Increment = 1,
    CurrentValue = 50,
    Flag = "JumpValue",
    Callback = function(v)
        Movement.JumpPowerValue = v
        if Movement.JumpPower then ApplyJumpPower() end
    end,
})

MovementTab:CreateKeybind({
    Name = "Jump Power Keybind",
    CurrentKeybind = "None",
    HoldToInteract = false,
    Flag = "JumpKey",
    Callback = function(v)
        MovementKeybinds.JumpPower = v
    end,
})

MovementTab:CreateToggle({
    Name = "NoClip",
    CurrentValue = false,
    Flag = "NoClip",
    Callback = function(v)
        Movement.NoClip = v
        ToggleNoClip(v)
    end,
})

MovementTab:CreateKeybind({
    Name = "NoClip Keybind",
    CurrentKeybind = "None",
    HoldToInteract = false,
    Flag = "NoClipKey",
    Callback = function(v)
        MovementKeybinds.NoClip = v
    end,
})

MovementTab:CreateToggle({
    Name = "Infinite Jump",
    CurrentValue = false,
    Flag = "InfiniteJump",
    Callback = function(v)
        Movement.InfiniteJump = v
    end,
})

MovementTab:CreateKeybind({
    Name = "Infinite Jump Keybind",
    CurrentKeybind = "None",
    HoldToInteract = false,
    Flag = "InfJumpKey",
    Callback = function(v)
        MovementKeybinds.InfiniteJump = v
    end,
})

MovementTab:CreateToggle({
    Name = "Bunny Hop",
    CurrentValue = false,
    Flag = "Bhop",
    Callback = function(v)
        Movement.Bhop = v
    end,
})

MovementTab:CreateSlider({
    Name = "Bhop Speed",
    Range = {10, 150},
    Increment = 5,
    CurrentValue = 40,
    Flag = "BhopSpeed",
    Callback = function(v)
        Movement.BhopSpeed = v
    end,
})

MovementTab:CreateKeybind({
    Name = "Bhop Keybind",
    CurrentKeybind = "None",
    HoldToInteract = false,
    Flag = "BhopKey",
    Callback = function(v)
        MovementKeybinds.Bhop = v
    end,
})

-- ==================================================
-- ВКЛАДКА VISUAL
-- ==================================================
local VisualTab = Window:CreateTab("Visual")

VisualTab:CreateSection("ESP Settings")

VisualTab:CreateToggle({
    Name = "Enable ESP",
    CurrentValue = false,
    Flag = "ESPEnabled",
    Callback = function(v)
        ESP.Enabled = v
        RefreshESP()
    end,
})

VisualTab:CreateToggle({
    Name = "Snaplines",
    CurrentValue = false,
    Flag = "Snaplines",
    Callback = function(v)
        ESP.Snaplines = v
        RefreshESP()
    end,
})

VisualTab:CreateToggle({
    Name = "Names",
    CurrentValue = false,
    Flag = "Names",
    Callback = function(v)
        ESP.Names = v
        RefreshESP()
    end,
})

VisualTab:CreateToggle({
    Name = "Box ESP",
    CurrentValue = false,
    Flag = "BoxESP",
    Callback = function(v)
        ESP.Box = v
        RefreshESP()
    end,
})

VisualTab:CreateToggle({
    Name = "Health Bar",
    CurrentValue = false,
    Flag = "HealthBar",
    Callback = function(v)
        ESP.Health = v
        RefreshESP()
    end,
})

VisualTab:CreateColorPicker({
    Name = "ESP Color",
    Color = Color3.fromRGB(255, 255, 255),
    Flag = "ESPColor",
    Callback = function(v)
        ESP.Color = v
        RefreshESP()
    end,
})

VisualTab:CreateSection("Skybox")

VisualTab:CreateDropdown({
    Name = "Skybox",
    Options = {"Default", "Night", "Sunset", "Neon", "Space"},
    CurrentOption = "Default",
    Flag = "Skybox",
    Callback = function(v)
        ApplySkybox(v)
    end,
})

VisualTab:CreateToggle({
    Name = "Rainbow Sky",
    CurrentValue = false,
    Flag = "RainbowSky",
    Callback = function(v)
        ToggleRainbowSky(v)
    end,
})

VisualTab:CreateSection("Performance")

VisualTab:CreateToggle({
    Name = "Show FPS",
    CurrentValue = false,
    Flag = "ShowFPS",
    Callback = function(v)
        Settings.ShowFPS = v
        if v then CreateFPSLabel() else if fpsLabel then fpsLabel.Parent:Destroy(); fpsLabel = nil end end
    end,
})

VisualTab:CreateSlider({
    Name = "Field of View",
    Range = {1, 120},
    Increment = 1,
    CurrentValue = 70,
    Flag = "FOV",
    Callback = function(v)
        Settings.FOV = v
        Camera.FieldOfView = v
    end,
})

-- ==================================================
-- ВКЛАДКА MISC
-- ==================================================
local MiscTab = Window:CreateTab("Misc")

MiscTab:CreateSection("Misc Settings")

MiscTab:CreateToggle({
    Name = "Anti-Fling",
    CurrentValue = false,
    Flag = "AntiFling",
    Callback = function(v)
        ToggleAntiFling(v)
    end,
})

MiscTab:CreateToggle({
    Name = "Click TP",
    CurrentValue = false,
    Flag = "ClickTP",
    Callback = function(v)
        ToggleClickTP(v)
    end,
})

MiscTab:CreateToggle({
    Name = "Invisible",
    CurrentValue = false,
    Flag = "Invisible",
    Callback = function(v)
        ToggleInvisible(v)
    end,
})

MiscTab:CreateToggle({
    Name = "I'm a Part",
    CurrentValue = false,
    Flag = "ImAPart",
    Callback = function(v)
        ToggleImAPart(v)
    end,
})

MiscTab:CreateSection("Player Actions")

MiscTab:CreateButton({
    Name = "TP to Player",
    Callback = function()
        CreatePlayerSelectWindow("Select Player to TP", function(player)
            if player and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
                local hrp = player.Character.HumanoidRootPart
                local char = LocalPlayer.Character
                local myHrp = char and char:FindFirstChild("HumanoidRootPart")
                if myHrp then
                    myHrp.CFrame = hrp.CFrame + Vector3.new(0, 2, 0)
                end
            end
        end, false, false)
    end,
})

MiscTab:CreateButton({
    Name = "Bring Player",
    Callback = function()
        CreatePlayerSelectWindow("Select Player to Bring", function(player)
            if player == "All" then
                BringPlayer("All")
            elseif player then
                BringPlayer(player)
            end
        end, true, false)
    end,
})

MiscTab:CreateButton({
    Name = "Freeze Player",
    Callback = function()
        CreatePlayerSelectWindow("Select Player to Freeze", function(player)
            if player == "All" then
                FreezePlayer("All")
            elseif player then
                FreezePlayer(player)
            end
        end, true, false)
    end,
})

MiscTab:CreateButton({
    Name = "Unfreeze Player",
    Callback = function()
        CreatePlayerSelectWindow("Select Player to Unfreeze", function(player)
            if player == "All" then
                UnfreezePlayer("All")
            elseif player then
                UnfreezePlayer(player)
            end
        end, true, false)
    end,
})

MiscTab:CreateButton({
    Name = "Kill Player",
    Callback = function()
        CreatePlayerSelectWindow("Select Player to Kill", function(player)
            if player == "All" then
                KillPlayer("All")
            elseif player then
                KillPlayer(player)
            end
        end, true, false)
    end,
})

MiscTab:CreateButton({
    Name = "Start Loop Kill",
    Callback = function()
        CreatePlayerSelectWindow("Select Player for Loop Kill", function(player)
            if player == "All" then
                StartLoopKill("All")
            elseif player then
                StartLoopKill(player)
            end
        end, true, false)
    end,
})

MiscTab:CreateButton({
    Name = "Stop Loop Kill",
    Callback = function()
        StopLoopKill()
    end,
})

MiscTab:CreateButton({
    Name = "Fling Player",
    Callback = function()
        CreatePlayerSelectWindow("Select Player to Fling", function(player)
            if player == "All" then
                StartFling("All")
            elseif player then
                StartFling(player)
            end
        end, true, false)
    end,
})

MiscTab:CreateButton({
    Name = "Stop Fling",
    Callback = function()
        StopFling()
    end,
})

-- ==================================================
-- ОБРАБОТКА KEYBINDS
-- ==================================================
UserInputService.InputBegan:Connect(function(input, gp)
    if gp then return end
    if input.UserInputType == Enum.UserInputType.Keyboard then
        HandleMovementKeybind(input.KeyCode)
    end
end)

-- ==================================================
-- ЗАПУСК
-- ==================================================
RefreshESP()
ApplySkybox(Settings.Skybox)
ApplyJumpPower()

print("ECLIPE MENU LOADED WITH RAYFIELD UI!")
print("All functions are working!")
print("Press RightShift or your keybind to open menu")
