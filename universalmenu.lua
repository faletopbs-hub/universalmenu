-- Загружаем библиотеку интерфейса (Orion — отличный выбор для темных закругленных меню)
local OrionLib = loadstring(game:HttpGet(('https://raw.githubusercontent.com/shlexware/Orion/main/source')))()

local Window = OrionLib:MakeWindow({
    Name = "MVS Duels | Script", 
    HidePremium = false, 
    SaveConfig = true, 
    ConfigFolder = "MVSDuelsConfig",
    IntroText = "Loading..."
})

-- Переменные для настроек
local Settings = {
    SilentAim = false,
    SilentRadius = 100,
    
    Aimbot = false,
    AimRadius = 100,
    AimPart = "Head",
    
    ESP = false,
    ESPColor = Color3.fromRGB(255, 0, 0)
}

-- Инициализация FOV кругов для визуализации радиуса
local SilentCircle = Drawing.new("Circle")
SilentCircle.Visible = false
SilentCircle.Color = Color3.fromRGB(255, 255, 255)
SilentCircle.Thickness = 1
SilentCircle.NumSides = 64
SilentCircle.Radius = Settings.SilentRadius
SilentCircle.Filled = false

local AimCircle = Drawing.new("Circle")
AimCircle.Visible = false
AimCircle.Color = Color3.fromRGB(0, 255, 255)
AimCircle.Thickness = 1
AimCircle.NumSides = 64
AimCircle.Radius = Settings.AimRadius
AimCircle.Filled = false

-- Обновление позиции кругов за мышкой
game:GetService("RunService").RenderStepped:Connect(function()
    local MousePos = game:GetService("Players").LocalPlayer:GetMouse()
    
    if Settings.SilentAim then
        SilentCircle.Position = Vector2.new(MousePos.X, MousePos.Y + 36) -- +36 учитывает топбар роблокса
        SilentCircle.Radius = Settings.SilentRadius
        SilentCircle.Visible = true
    else
        SilentCircle.Visible = false
    end
    
    if Settings.Aimbot then
        AimCircle.Position = Vector2.new(MousePos.X, MousePos.Y + 36)
        AimCircle.Radius = Settings.AimRadius
        AimCircle.Visible = true
    else
        AimCircle.Visible = false
    end
end)

-- Вкладка функций
local MainTab = Window:MakeTab({
    Name = "Main",
    Icon = "rbxassetid://4483345998"
})

-- SECTION: SILENT AIM
MainTab:AddSection({ Name = "Silent Aim" })

MainTab:AddToggle({
    Name = "Enable Silent Aim",
    Default = false,
    Callback = function(Value)
        Settings.SilentAim = Value
    end    
})

MainTab:AddSlider({
    Name = "Silent Aim Radius",
    Min = 10,
    Max = 500,
    Default = 100,
    Color = Color3.fromRGB(255,255,255),
    Increment = 5,
    ValueName = "px",
    Callback = function(Value)
        Settings.SilentRadius = Value
    end    
})

-- SECTION: AIMBOT
MainTab:AddSection({ Name = "Aimbot" })

MainTab:AddToggle({
    Name = "Enable Aimbot",
    Default = false,
    Callback = function(Value)
        Settings.Aimbot = Value
    end    
})

MainTab:AddSlider({
    Name = "Aimbot Radius",
    Min = 10,
    Max = 500,
    Default = 100,
    Color = Color3.fromRGB(0,255,255),
    Increment = 5,
    ValueName = "px",
    Callback = function(Value)
        Settings.AimRadius = Value
    end    
})

MainTab:AddDropdown({
    Name = "Target Hitbox",
    Default = "Head",
    Options = {"Head", "HumanoidRootPart"},
    Callback = function(Value)
        Settings.AimPart = Value
    end
})

-- SECTION: ESP
MainTab:AddSection({ Name = "Visuals (ESP)" })

MainTab:AddToggle({
    Name = "Enable ESP (Boxes)",
    Default = false,
    Callback = function(Value)
        Settings.ESP = Value
    end    
})

MainTab:AddColorpicker({
    Name = "ESP Color",
    Default = Color3.fromRGB(255, 0, 0),
    Callback = function(Value)
        Settings.ESPColor = Value
    end	  
})

-- Логика поиска ближайшей цели в FOV круге
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

local function GetClosestPlayer(Radius, Part)
    local Target = nil
    local MaxDistance = Radius
    
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild(Part) and player.Character:FindFirstChild("Humanoid") and player.Character.Humanoid.Health > 0 then
            local ScreenPos, OnScreen = Camera:WorldToViewportPoint(player.Character[Part].Position)
            if OnScreen then
                local MousePos = LocalPlayer:GetMouse()
                local Distance = (Vector2.new(ScreenPos.X, ScreenPos.Y) - Vector2.new(MousePos.X, MousePos.Y)).Magnitude
                if Distance < MaxDistance then
                    MaxDistance = Distance
                    Target = player
                end
            end
        end
    end
    return Target
end

-- Логика работы Аимбота (доводка курсора)
game:GetService("RunService").RenderStepped:Connect(function()
    if Settings.Aimbot then
        local Target = GetClosestPlayer(Settings.AimRadius, Settings.AimPart)
        if Target and Target.Character then
            -- Плавная доводка (Tween или Lerp камеры для беспалевности)
            local TargetPos = Camera:WorldToViewportPoint(Target.Character[Settings.AimPart].Position)
            mousemoverel((TargetPos.X - LocalPlayer:GetMouse().X) * 0.2, (TargetPos.Y - LocalPlayer:GetMouse().Y) * 0.2)
        end
    end
end)

-- Логика Silent Aim (Подмена __index или __namecall метатаблицы)
-- Примечание: работает, если пули в игре используют Raycast или мышь для направления
local MT = getrawmetatable(game)
local OldNamecall = MT.__namecall
local OldIndex = MT.__index
setreadonly(MT, false)

MT.__namecall = newcclosure(function(Self, ...)
    local Args = {...}
    local Method = getnamecallmethod()
    
    if Settings.SilentAim and (Method == "FindPartOnRay" or Method == "Raycast") then
        local Target = GetClosestPlayer(Settings.SilentRadius, "HumanoidRootPart")
        if Target and Target.Character then
            -- Перенаправляем луч прямо в цель
            -- Здесь может потребоваться точечная настройка под конкретный скрипт оружия игры MVS
        end
    end
    return OldNamecall(Self, ...)
end)

MT.__index = newcclosure(function(Self, Key)
    if Settings.SilentAim and Key == "Hit" and Self == LocalPlayer:GetMouse() then
        local Target = GetClosestPlayer(Settings.SilentRadius, "HumanoidRootPart")
        if Target and Target.Character then
            return Target.Character.HumanoidRootPart.CFrame
        end
    end
    return OldIndex(Self, Key)
end)

setreadonly(MT, true)

-- Базовый ESP (Highlight)
Players.PlayerAdded:Connect(function(player)
    player.CharacterAdded:Connect(function(char)
        if Settings.ESP then
            local Highlight = Instance.new("Highlight")
            Highlight.Name = "EspHighlight"
            Highlight.FillTransparency = 1
            Highlight.OutlineColor = Settings.ESPColor
            Highlight.Parent = char
        end
    end)
end)

-- Цикл для обновления ESP на уже существующих игроках
spawn(function()
    while wait(1) do
        for _, player in pairs(Players:GetPlayers()) do
            if player ~= LocalPlayer and player.Character then
                local hl = player.Character:FindFirstChild("EspHighlight")
                if Settings.ESP then
                    if not hl then
                        hl = Instance.new("Highlight", player.Character)
                        hl.Name = "EspHighlight"
                    end
                    hl.FillTransparency = 1
                    hl.OutlineColor = Settings.ESPColor
                else
                    if hl then hl:Destroy() end
                end
            end
        end
    end
end)

OrionLib:Init()
