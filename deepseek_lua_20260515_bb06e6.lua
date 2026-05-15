-- ==================== LOAD ALEXCHAD LIBRARY ====================
local AlexchadLibrary = loadstring(game:HttpGet("https://raw.githubusercontent.com/Alexchad-source/Alexchad-Hub/refs/heads/main/MaybeAlexchadlib.lua"))()

-- ==================== SERVICES ====================
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local Workspace = workspace
local Lighting = game:GetService("Lighting")
local VirtualInputManager = game:GetService("VirtualInputManager")
local HttpService = game:GetService("HttpService")
local TeleportService = game:GetService("TeleportService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local StarterGui = game:GetService("StarterGui")
local CoreGui = game:GetService("CoreGui")
local CollectionService = game:GetService("CollectionService")

-- ==================== PLAYER & CHARACTER ====================
local Player = Players.LocalPlayer
local Character, Humanoid, RootPart, Camera

local function UpdateCharacter()
    Character = Player.Character
    if Character then
        Humanoid = Character:FindFirstChildOfClass("Humanoid")
        RootPart = Character:FindFirstChild("HumanoidRootPart")
    end
    Camera = Workspace.CurrentCamera
end

UpdateCharacter()

Player.CharacterAdded:Connect(function()
    task.wait(0.1)
    UpdateCharacter()
end)

-- ==================== CONNECTIONS MANAGER ====================
local Connections = {}

local function AddConnection(conn)
    table.insert(Connections, conn)
    return conn
end

local function CleanConnections()
    for _, conn in pairs(Connections) do
        pcall(function() conn:Disconnect() end)
    end
    Connections = {}
end

-- ==================== FLAGS ====================
local Flags = {
    WalkSpeed = 16,
    JumpPower = 50,
    Fly = false,
    FlySpeed = 50,
    Noclip = false,
    Bhop = false,
    InfiniteJump = false,
    GodMode = false,
    AutoHeal = false,
    HealPercent = 50,
    ESP = false,
    ESPTracers = false,
    ESPBoxes = false,
    ESPNames = false,
    ESPDistance = false,
    FullBright = false,
    Aimbot = false,
    AimbotSmoothness = 0.1,
    AimbotPart = "Head",
    FovSize = 150,
    SilentAim = false,
    TriggerBot = false,
    NoRecoil = false,
    NoSpread = false,
    RapidFire = false,
    RapidFireDelay = 0.05,
    InfiniteAmmo = false,
    Spinbot = false,
    SpinSpeed = 10,
    AntiAfk = false,
    AntiKick = false,
    AutoRejoin = false,
    Invisible = false,
    RainbowHats = false,
    FlingPlayers = false,
    FlingPower = 5000,
    ServerHop = false,
}

-- ==================== CREATE WINDOW ====================
local Window = AlexchadLibrary:CreateWindow({
    Name = "Miu Hub Pro",
    Subtitle = "Universal Script",
    Version = "v2.0 Premium",
    LoadingTitle = "Miu Hub",
    LoadingSubtitle = "Đang tải script...",
    Theme = "Midnight",
    AnimationSpeed = 0.2,
    RippleEnabled = true,
    RippleSpeed = 0.35,
    CornerRadius = 12,
    ElementCornerRadius = 10,
    BlurEnabled = true,
    ConfigurationSaving = {
        Enabled = true,
        FolderName = "MiuHubPro",
        FileName = "Config"
    },
    ToggleKey = Enum.KeyCode.RightShift
})

-- ==================== NOTIFICATIONS ====================
local function Notify(title, content, duration, notifType)
    Window:Notify({
        Title = title or "Notification",
        Content = content or "",
        Duration = duration or 3,
        Type = notifType or "Info"
    })
end

-- ==================== TABS ====================

-- TAB 1: MOVEMENT
local MovementTab = Window:CreateTab({
    Name = "🏃 Movement",
    Icon = "rbxassetid://6031060921"
})

local SpeedSection = MovementTab:CreateSection("Speed & Jump")

SpeedSection:CreateSlider({
    Name = "Walk Speed",
    Flag = "WalkSpeed",
    Range = {16, 500},
    Increment = 1,
    CurrentValue = 16,
    Suffix = " studs/s",
    Callback = function(value)
        Flags.WalkSpeed = value
        if Humanoid then
            Humanoid.WalkSpeed = value
        end
    end
})

SpeedSection:CreateSlider({
    Name = "Jump Power",
    Flag = "JumpPower",
    Range = {50, 1000},
    Increment = 1,
    CurrentValue = 50,
    Suffix = " power",
    Callback = function(value)
        Flags.JumpPower = value
        if Humanoid then
            Humanoid.JumpPower = value
        end
    end
})

SpeedSection:CreateToggle({
    Name = "Bhop",
    Flag = "Bhop",
    CurrentValue = false,
    Callback = function(value)
        Flags.Bhop = value
        if value then
            AddConnection(RunService.Stepped:Connect(function()
                if Flags.Bhop and Utility:IsAlive() then
                    if UserInputService:IsKeyDown(Enum.KeyCode.Space) then
                        Humanoid:Move(Vector3.new(0, Humanoid.JumpPower, 0))
                    end
                end
            end))
        end
    end
})

SpeedSection:CreateToggle({
    Name = "Infinite Jump",
    Flag = "InfiniteJump",
    CurrentValue = false,
    Callback = function(value)
        Flags.InfiniteJump = value
        if value then
            AddConnection(UserInputService.JumpRequest:Connect(function()
                if Flags.InfiniteJump and Utility:IsAlive() then
                    Humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
                end
            end))
        end
    end
})

local FlySection = MovementTab:CreateSection("Fly")

local FlyBodyGyro, FlyBodyVelocity
FlySection:CreateToggle({
    Name = "Fly",
    Flag = "Fly",
    CurrentValue = false,
    Callback = function(value)
        Flags.Fly = value
        if value then
            Utility:StartFly()
        else
            Utility:StopFly()
        end
    end
})

FlySection:CreateSlider({
    Name = "Fly Speed",
    Flag = "FlySpeed",
    Range = {20, 500},
    Increment = 5,
    CurrentValue = 50,
    Suffix = " studs/s",
    Callback = function(value)
        Flags.FlySpeed = value
    end
})

local NoclipSection = MovementTab:CreateSection("Noclip")

NoclipSection:CreateToggle({
    Name = "Noclip",
    Flag = "Noclip",
    CurrentValue = false,
    Callback = function(value)
        Flags.Noclip = value
        if value then
            AddConnection(RunService.Stepped:Connect(function()
                if Flags.Noclip and Character then
                    for _, part in ipairs(Character:GetDescendants()) do
                        if part:IsA("BasePart") then
                            part.CanCollide = false
                        end
                    end
                end
            end))
        else
            if Character then
                for _, part in ipairs(Character:GetDescendants()) do
                    if part:IsA("BasePart") then
                        part.CanCollide = true
                    end
                end
            end
        end
    end
})

-- TAB 2: COMBAT
local CombatTab = Window:CreateTab({
    Name = "⚔️ Combat",
    Icon = "rbxassetid://6031060921"
})

local CombatSection = CombatTab:CreateSection("Combat Settings")

CombatSection:CreateToggle({
    Name = "God Mode",
    Flag = "GodMode",
    CurrentValue = false,
    Callback = function(value)
        Flags.GodMode = value
    end
})

CombatSection:CreateToggle({
    Name = "Auto Heal",
    Flag = "AutoHeal",
    CurrentValue = false,
    Callback = function(value)
        Flags.AutoHeal = value
    end
})

CombatSection:CreateSlider({
    Name = "Heal Below %",
    Flag = "HealPercent",
    Range = {10, 90},
    Increment = 5,
    CurrentValue = 50,
    Suffix = "% HP",
    Callback = function(value)
        Flags.HealPercent = value
    end
})

-- Health Loop
AddConnection(RunService.Heartbeat:Connect(function()
    if Utility:IsAlive() then
        if Flags.GodMode then
            Humanoid.Health = Humanoid.MaxHealth
        end
        if Flags.AutoHeal then
            local healthPercent = (Humanoid.Health / Humanoid.MaxHealth) * 100
            if healthPercent <= Flags.HealPercent then
                Humanoid.Health = Humanoid.MaxHealth
            end
        end
    end
end))

-- TAB 3: AIMBOT
local AimbotTab = Window:CreateTab({
    Name = "🎯 Aimbot",
    Icon = "rbxassetid://6031060921"
})

local AimbotSection = AimbotTab:CreateSection("Aimbot Settings")

AimbotSection:CreateToggle({
    Name = "Aimbot",
    Flag = "Aimbot",
    CurrentValue = false,
    Callback = function(value)
        Flags.Aimbot = value
    end
})

AimbotSection:CreateToggle({
    Name = "Aimlock",
    Flag = "Aimlock",
    CurrentValue = false,
    Callback = function(value)
        Flags.Aimlock = value
    end
})

AimbotSection:CreateToggle({
    Name = "Silent Aim",
    Flag = "SilentAim",
    CurrentValue = false,
    Callback = function(value)
        Flags.SilentAim = value
    end
})

AimbotSection:CreateDropdown({
    Name = "Target Part",
    Flag = "AimbotPart",
    Options = {"Head", "Torso", "HumanoidRootPart", "Left Arm", "Right Arm", "Left Leg", "Right Leg"},
    CurrentOption = "Head",
    Callback = function(option)
        Flags.AimbotPart = option
    end
})

AimbotSection:CreateSlider({
    Name = "Smoothness",
    Flag = "AimbotSmoothness",
    Range = {0.01, 1},
    Increment = 0.01,
    CurrentValue = 0.1,
    Callback = function(value)
        Flags.AimbotSmoothness = value
    end
})

AimbotSection:CreateSlider({
    Name = "FOV Size",
    Flag = "FovSize",
    Range = {50, 500},
    Increment = 10,
    CurrentValue = 150,
    Suffix = " px",
    Callback = function(value)
        Flags.FovSize = value
    end
})

-- FOV Circle Drawing
local FOVCircle = Drawing.new("Circle")
FOVCircle.Color = Color3.fromRGB(255, 255, 255)
FOVCircle.Thickness = 1
FOVCircle.Transparency = 1
FOVCircle.Radius = Flags.FovSize
FOVCircle.Visible = false
FOVCircle.ZIndex = 10

AddConnection(RunService.RenderStepped:Connect(function()
    if Flags.Aimbot then
        FOVCircle.Visible = true
        FOVCircle.Position = Camera.ViewportSize / 2
        FOVCircle.Radius = Flags.FovSize
    else
        FOVCircle.Visible = false
    end
    
    if Utility:IsAlive() and (Flags.Aimbot or Flags.Aimlock) then
        local target = Utility:GetClosestPlayerInFOV()
        if target then
            local targetPart = target.Character:FindFirstChild(Flags.AimbotPart) or target.Character:FindFirstChild("Head")
            if targetPart then
                local targetPos = Camera:WorldToScreenPoint(targetPart.Position)
                local screenCenter = Camera.ViewportSize / 2
                local aimAt = targetPos
                
                if Flags.Aimbot and not Flags.Aimlock then
                    if Utility:IsMouseButtonDown(0) or Flags.TriggerBot then
                        aimAt = Vector2.new(
                            screenCenter.X + (targetPos.X - screenCenter.X) / (Flags.AimbotSmoothness * 100),
                            screenCenter.Y + (targetPos.Y - screenCenter.Y) / (Flags.AimbotSmoothness * 100)
                        )
                    end
                elseif Flags.Aimlock then
                    aimAt = Vector2.new(
                        screenCenter.X + (targetPos.X - screenCenter.X) / (Flags.AimbotSmoothness * 100),
                        screenCenter.Y + (targetPos.Y - screenCenter.Y) / (Flags.AimbotSmoothness * 100)
                    )
                end
                
                mousemoverel(aimAt.X - screenCenter.X, aimAt.Y - screenCenter.Y)
            end
        end
    end
end))

-- TAB 4: GUN MODS
local GunTab = Window:CreateTab({
    Name = "🔫 Gun Mods",
    Icon = "rbxassetid://6031060921"
})

local GunSection = GunTab:CreateSection("Gun Modifications")

GunSection:CreateToggle({
    Name = "Trigger Bot",
    Flag = "TriggerBot",
    CurrentValue = false,
    Callback = function(value)
        Flags.TriggerBot = value
    end
})

GunSection:CreateToggle({
    Name = "No Recoil",
    Flag = "NoRecoil",
    CurrentValue = false,
    Callback = function(value)
        Flags.NoRecoil = value
    end
})

GunSection:CreateToggle({
    Name = "No Spread",
    Flag = "NoSpread",
    CurrentValue = false,
    Callback = function(value)
        Flags.NoSpread = value
    end
})

GunSection:CreateToggle({
    Name = "Rapid Fire",
    Flag = "RapidFire",
    CurrentValue = false,
    Callback = function(value)
        Flags.RapidFire = value
    end
})

GunSection:CreateSlider({
    Name = "Fire Rate",
    Flag = "RapidFireDelay",
    Range = {0.01, 0.5},
    Increment = 0.01,
    CurrentValue = 0.05,
    Suffix = "s delay",
    Callback = function(value)
        Flags.RapidFireDelay = value
    end
})

GunSection:CreateToggle({
    Name = "Infinite Ammo",
    Flag = "InfiniteAmmo",
    CurrentValue = false,
    Callback = function(value)
        Flags.InfiniteAmmo = value
    end
})

-- Trigger Bot
AddConnection(RunService.RenderStepped:Connect(function()
    if Flags.TriggerBot and Utility:GetClosestPlayerInFOV() then
        local target = Utility:GetClosestPlayerInFOV()
        if target and Utility:IsMouseButtonDown(0) then
            VirtualInputManager:SendMouseButtonEvent(0, 0, 0, true, game, 0)
            VirtualInputManager:SendMouseButtonEvent(0, 0, 0, false, game, 0)
        end
    end
end))

-- Rapid Fire
local canFire = true
AddConnection(RunService.RenderStepped:Connect(function()
    if Flags.RapidFire and Utility:IsMouseButtonDown(0) and canFire then
        canFire = false
        VirtualInputManager:SendMouseButtonEvent(0, 0, 0, true, game, 0)
        task.wait(Flags.RapidFireDelay)
        VirtualInputManager:SendMouseButtonEvent(0, 0, 0, false, game, 0)
        canFire = true
    end
end))

-- TAB 5: VISUALS
local VisualsTab = Window:CreateTab({
    Name = "👁️ Visuals",
    Icon = "rbxassetid://6031060921"
})

local ESPSection = VisualsTab:CreateSection("ESP Settings")

ESPSection:CreateToggle({
    Name = "Player ESP",
    Flag = "ESP",
    CurrentValue = false,
    Callback = function(value)
        Flags.ESP = value
        if value then
            Utility:EnableESP()
        else
            Utility:DisableESP()
        end
    end
})

ESPSection:CreateToggle({
    Name = "ESP Boxes",
    Flag = "ESPBoxes",
    CurrentValue = false,
    Callback = function(value)
        Flags.ESPBoxes = value
    end
})

ESPSection:CreateToggle({
    Name = "ESP Tracers",
    Flag = "ESPTracers",
    CurrentValue = false,
    Callback = function(value)
        Flags.ESPTracers = value
    end
})

ESPSection:CreateToggle({
    Name = "ESP Names",
    Flag = "ESPNames",
    CurrentValue = false,
    Callback = function(value)
        Flags.ESPNames = value
    end
})

ESPSection:CreateToggle({
    Name = "ESP Distance",
    Flag = "ESPDistance",
    CurrentValue = false,
    Callback = function(value)
        Flags.ESPDistance = value
    end
})

local WorldSection = VisualsTab:CreateSection("World Settings")

WorldSection:CreateToggle({
    Name = "Full Bright",
    Flag = "FullBright",
    CurrentValue = false,
    Callback = function(value)
        Flags.FullBright = value
        if value then
            Lighting.Brightness = 3
            Lighting.ClockTime = 12
            Lighting.FogEnd = 999999
            Lighting.GlobalShadows = false
            Lighting.OutdoorAmbient = Color3.fromRGB(255, 255, 255)
        else
            Lighting.Brightness = 2
            Lighting.ClockTime = 14
            Lighting.FogEnd = 10000
            Lighting.GlobalShadows = true
            Lighting.OutdoorAmbient = Color3.fromRGB(128, 128, 128)
        end
    end
})

-- TAB 6: FARM
local FarmTab = Window:CreateTab({
    Name = "🤖 Auto Farm",
    Icon = "rbxassetid://6031060921"
})

local FarmSection = FarmTab:CreateSection("Auto Farm Settings")

FarmSection:CreateToggle({
    Name = "Auto Farm",
    Flag = "AutoFarm",
    CurrentValue = false,
    Callback = function(value)
        Flags.AutoFarm = value
        if value then
            AddConnection(RunService.Heartbeat:Connect(function()
                if Flags.AutoFarm and Utility:IsAlive() then
                    local nearest, distance = Utility:GetNearestPlayer(200)
                    if nearest and distance <= Flags.FarmRange then
                        RootPart.CFrame = nearest.Character.HumanoidRootPart.CFrame * CFrame.new(0, 0, 3)
                        -- Auto attack
                        VirtualInputManager:SendMouseButtonEvent(0, 0, 0, true, game, 0)
                        task.wait(0.1)
                        VirtualInputManager:SendMouseButtonEvent(0, 0, 0, false, game, 0)
                    end
                end
            end))
        end
    end
})

FarmSection:CreateSlider({
    Name = "Farm Range",
    Flag = "FarmRange",
    Range = {10, 200},
    Increment = 5,
    CurrentValue = 50,
    Suffix = " studs",
    Callback = function(value)
        Flags.FarmRange = value
    end
})

-- TAB 7: MISC
local MiscTab = Window:CreateTab({
    Name = "🎪 Misc",
    Icon = "rbxassetid://6031060921"
})

local MiscSection = MiscTab:CreateSection("Fun Stuff")

MiscSection:CreateToggle({
    Name = "Spinbot",
    Flag = "Spinbot",
    CurrentValue = false,
    Callback = function(value)
        Flags.Spinbot = value
        if value then
            AddConnection(RunService.RenderStepped:Connect(function()
                if Flags.Spinbot and RootPart then
                    RootPart.CFrame = RootPart.CFrame * CFrame.Angles(0, math.rad(Flags.SpinSpeed), 0)
                end
            end))
        end
    end
})

MiscSection:CreateSlider({
    Name = "Spin Speed",
    Flag = "SpinSpeed",
    Range = {1, 100},
    Increment = 1,
    CurrentValue = 10,
    Suffix = " deg",
    Callback = function(value)
        Flags.SpinSpeed = value
    end
})

MiscSection:CreateToggle({
    Name = "Invisible",
    Flag = "Invisible",
    CurrentValue = false,
    Callback = function(value)
        Flags.Invisible = value
        if Character then
            for _, part in ipairs(Character:GetDescendants()) do
                if part:IsA("BasePart") then
                    part.Transparency = value and 1 or 0
                end
            end
        end
    end
})

MiscSection:CreateToggle({
    Name = "Fling Players",
    Flag = "FlingPlayers",
    CurrentValue = false,
    Callback = function(value)
        Flags.FlingPlayers = value
        if value then
            AddConnection(RunService.Heartbeat:Connect(function()
                if Flags.FlingPlayers and Utility:IsAlive() then
                    for _, player in ipairs(Players:GetPlayers()) do
                        if player ~= Player and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
                            local targetRoot = player.Character.HumanoidRootPart
                            local direction = (targetRoot.Position - RootPart.Position).Unit
                            targetRoot.Velocity = direction * Flags.FlingPower
                        end
                    end
                end
            end))
        end
    end
})

MiscSection:CreateSlider({
    Name = "Fling Power",
    Flag = "FlingPower",
    Range = {100, 50000},
    Increment = 100,
    CurrentValue = 5000,
    Suffix = " vel",
    Callback = function(value)
        Flags.FlingPower = value
    end
})

MiscSection:CreateToggle({
    Name = "Rainbow Hats",
    Flag = "RainbowHats",
    CurrentValue = false,
    Callback = function(value)
        Flags.RainbowHats = value
        if value then
            local hue = 0
            AddConnection(RunService.RenderStepped:Connect(function()
                if Flags.RainbowHats and Character then
                    hue = (hue + 0.01) % 1
                    for _, accessory in ipairs(Character:GetChildren()) do
                        if accessory:IsA("Accessory") then
                            for _, part in ipairs(accessory:GetDescendants()) do
                                if part:IsA("BasePart") then
                                    part.Color = Color3.fromHSV(hue, 1, 1)
                                end
                            end
                        end
                    end
                end
            end))
        end
    end
})

-- TAB 8: SERVER
local ServerTab = Window:CreateTab({
    Name = "🌐 Server",
    Icon = "rbxassetid://6031060921"
})

local ServerSection = ServerTab:CreateSection("Server Settings")

ServerSection:CreateToggle({
    Name = "Anti AFK",
    Flag = "AntiAfk",
    CurrentValue = true,
    Callback = function(value)
        Flags.AntiAfk = value
        if value then
            local vu = game:GetService("VirtualUser")
            Player.Idled:Connect(function()
                vu:Button2Down(Vector2.new(0,0), workspace.CurrentCamera.CFrame)
                task.wait(1)
                vu:Button2Up(Vector2.new(0,0), workspace.CurrentCamera.CFrame)
            end)
        end
    end
})

ServerSection:CreateToggle({
    Name = "Anti Kick",
    Flag = "AntiKick",
    CurrentValue = false,
    Callback = function(value)
        Flags.AntiKick = value
        if value then
            AddConnection(Player:GetAttributeChangedSignal("Kick"):Connect(function()
                if Flags.AntiKick then
                    -- Try to prevent kick
                    pcall(function()
                        local mt = getrawmetatable(game)
                        local old = mt.__namecall
                        setreadonly(mt, false)
                        mt.__namecall = newcclosure(function(self, ...)
                            local method = getnamecallmethod()
                            if method == "Kick" then
                                return
                            end
                            return old(self, ...)
                        end)
                    end)
                end
            end))
        end
    end
})

ServerSection:CreateToggle({
    Name = "Auto Rejoin",
    Flag = "AutoRejoin",
    CurrentValue = false,
    Callback = function(value)
        Flags.AutoRejoin = value
    end
})

ServerSection:CreateSlider({
    Name = "Rejoin Delay",
    Flag = "RejoinDelay",
    Range = {5, 60},
    Increment = 1,
    CurrentValue = 10,
    Suffix = " seconds",
    Callback = function(value)
        Flags.RejoinDelay = value
    end
})

ServerSection:CreateButton({
    Name = "Server Hop",
    Callback = function()
        Utility:ServerHop()
    end
})

ServerSection:CreateButton({
    Name = "Rejoin Game",
    Callback = function()
        TeleportService:Teleport(game.PlaceId, Player)
    end
})

-- Auto Rejoin khi bị kick
Players.PlayerRemoving:Connect(function(player)
    if player == Player and Flags.AutoRejoin then
        task.wait(Flags.RejoinDelay)
        TeleportService:Teleport(game.PlaceId, Player)
    end
end)

-- ==================== UTILITY FUNCTIONS ====================
local Utility = {}

function Utility:IsAlive()
    return Character and Humanoid and RootPart and Humanoid.Health > 0
end

function Utility:GetClosestPlayerInFOV()
    if not Camera or not RootPart then return nil end
    
    local closest = nil
    local shortestDistance = Flags.FovSize
    local screenCenter = Camera.ViewportSize / 2
    
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= Player and player.Character then
            local targetRoot = player.Character:FindFirstChild("HumanoidRootPart")
            local targetHead = player.Character:FindFirstChild("Head")
            local targetPart = targetHead or targetRoot
            
            if targetPart then
                local screenPos, onScreen = Camera:WorldToScreenPoint(targetPart.Position)
                if onScreen then
                    local distance = (Vector2.new(screenPos.X, screenPos.Y) - screenCenter).Magnitude
                    if distance < shortestDistance then
                        shortestDistance = distance
                        closest = player
                    end
                end
            end
        end
    end
    
    return closest
end

function Utility:GetNearestPlayer(range)
    local nearest = nil
    local shortest = range or math.huge
    
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= Player and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
            local distance = (RootPart.Position - player.Character.HumanoidRootPart.Position).Magnitude
            if distance < shortest then
                shortest = distance
                nearest = player
            end
        end
    end
    
    return nearest, shortest
end

function Utility:IsMouseButtonDown(button)
    return UserInputService:IsMouseButtonPressed(button)
end

function Utility:StartFly()
    if not RootPart then return end
    
    FlyBodyGyro = Instance.new("BodyGyro")
    FlyBodyGyro.P = 9e4
    FlyBodyGyro.MaxTorque = Vector3.new(9e9, 9e9, 9e9)
    FlyBodyGyro.CFrame = RootPart.CFrame
    FlyBodyGyro.Parent = RootPart
    
    FlyBodyVelocity = Instance.new("BodyVelocity")
    FlyBodyVelocity.MaxForce = Vector3.new(9e9, 9e9, 9e9)
    FlyBodyVelocity.Velocity = Vector3.new(0, 0, 0)
    FlyBodyVelocity.Parent = RootPart
    
    AddConnection(RunService.RenderStepped:Connect(function()
        if Flags.Fly and RootPart and FlyBodyGyro and FlyBodyVelocity then
            FlyBodyGyro.CFrame = Camera.CFrame
            
            local direction = Vector3.new()
            if UserInputService:IsKeyDown(Enum.KeyCode.W) then
                direction += Camera.CFrame.LookVector
            end
            if UserInputService:IsKeyDown(Enum.KeyCode.S) then
                direction -= Camera.CFrame.LookVector
            end
            if UserInputService:IsKeyDown(Enum.KeyCode.A) then
                direction -= Camera.CFrame.RightVector
            end
            if UserInputService:IsKeyDown(Enum.KeyCode.D) then
                direction += Camera.CFrame.RightVector
            end
            if UserInputService:IsKeyDown(Enum.KeyCode.Space) then
                direction += Vector3.new(0, 1, 0)
            end
            if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then
                direction -= Vector3.new(0, 1, 0)
            end
            
            FlyBodyVelocity.Velocity = direction * Flags.FlySpeed
        end
    end))
end

function Utility:StopFly()
    if FlyBodyGyro then FlyBodyGyro:Destroy() end
    if FlyBodyVelocity then FlyBodyVelocity:Destroy() end
    FlyBodyGyro = nil
    FlyBodyVelocity = nil
end

function Utility:EnableESP()
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= Player then
            Utility:AddESP(player)
        end
    end
    
    Players.PlayerAdded:Connect(function(player)
        if Flags.ESP then
            Utility:AddESP(player)
        end
    end)
    
    Players.PlayerRemoving:Connect(function(player)
        if ESPObjects[player] then
            for _, drawing in pairs(ESPObjects[player]) do
                drawing:Remove()
            end
            ESPObjects[player] = nil
        end
    end)
    
    AddConnection(RunService.RenderStepped:Connect(function()
        for player, drawings in pairs(ESPObjects) do
            if player.Character and player.Character:FindFirstChild("HumanoidRootPart") and player.Character:FindFirstChild("Head") then
                local rootPos, rootOnScreen = Camera:WorldToScreenPoint(player.Character.HumanoidRootPart.Position)
                local headPos, headOnScreen = Camera:WorldToScreenPoint(player.Character.Head.Position)
                
                if rootOnScreen then
                    local distance = (RootPart.Position - player.Character.HumanoidRootPart.Position).Magnitude
                    
                    if drawings.Box then
                        local height = (headPos.Y - rootPos.Y) * 1.5
                        local width = height * 0.5
                        drawings.Box.Position = Vector2.new(rootPos.X - width/2, rootPos.Y - height)
                        drawings.Box.Size = Vector2.new(width, height)
                        drawings.Box.Visible = Flags.ESPBoxes
                    end
                    
                    if drawings.Tracer then
                        drawings.Tracer.From = Camera.ViewportSize / 2
                        drawings.Tracer.To = rootPos
                        drawings.Tracer.Visible = Flags.ESPTracers
                    end
                    
                    if drawings.Name then
                        drawings.Name.Position = Vector2.new(rootPos.X, rootPos.Y - 40)
                        drawings.Name.Text = player.Name .. (Flags.ESPDistance and " [" .. math.floor(distance) .. "m]" or "")
                        drawings.Name.Visible = Flags.ESPNames
                    end
                end
            end
        end
    end))
end

function Utility:AddESP(player)
    if ESPObjects[player] then return end
    
    local drawings = {}
    
    -- Box ESP
    drawings.Box = Drawing.new("Square")
    drawings.Box.Color = Color3.fromRGB(255, 0, 0)
    drawings.Box.Thickness = 2
    drawings.Box.Transparency = 1
    drawings.Box.Filled = false
    drawings.Box.Visible = false
    
    -- Tracers
    drawings.Tracer = Drawing.new("Line")
    drawings.Tracer.Color = Color3.fromRGB(255, 0, 0)
    drawings.Tracer.Thickness = 1
    drawings.Tracer.Transparency = 1
    drawings.Tracer.Visible = false
    
    -- Name
    drawings.Name = Drawing.new("Text")
    drawings.Name.Color = Color3.fromRGB(255, 255, 255)
    drawings.Name.Size = 14
    drawings.Name.Center = true
    drawings.Name.Outline = true
    drawings.Name.Visible = false
    
    ESPObjects[player] = drawings
    
    player.CharacterAdded:Connect(function()
        task.wait(0.5)
        if Flags.ESP and ESPObjects[player] then
            -- Keep same drawings
        end
    end)
end

function Utility:DisableESP()
    for player, drawings in pairs(ESPObjects) do
        for _, drawing in pairs(drawings) do
            drawing:Remove()
        end
    end
    ESPObjects = {}
end

function Utility:ServerHop()
    local Http = game:GetService("HttpService")
    local TPS = game:GetService("TeleportService")
    local Api = "https://games.roblox.com/v1/games/"
    
    local success, result = pcall(function()
        local servers = Http:JSONDecode(game:HttpGet(Api .. game.PlaceId .. "/servers/Public?sortOrder=Asc&limit=100"))
        local validServers = {}
        
        for _, server in ipairs(servers.data) do
            if server.playing < server.maxPlayers and server.id ~= game.JobId then
                table.insert(validServers, server.id)
            end
        end
        
        if #validServers > 0 then
            local randomServer = validServers[math.random(1, #validServers)]
            TPS:TeleportToPlaceInstance(game.PlaceId, randomServer, Player)
        else
            Notify("Server Hop", "Không tìm thấy server khả dụng!", 3, "Error")
        end
    end)
    
    if not success then
        Notify("Server Hop", "Lỗi khi tìm server!", 3, "Error")
    end
end

function Utility:CharacterSetup()
    if Humanoid then
        Humanoid.WalkSpeed = Flags.WalkSpeed
        Humanoid.JumpPower = Flags.JumpPower
    end
end

-- ==================== INITIAL SETUP ====================
Utility:CharacterSetup()

-- ==================== WELCOME NOTIFICATION ====================
Notify("Miu Hub Pro", "Chào mừng " .. Player.Name .. "!\nScript đã sẵn sàng!", 5, "Success")

-- ==================== ANTI-DETECTION ====================
pcall(function()
    local mt = getrawmetatable(game)
    local oldNamecall = mt.__namecall
    setreadonly(mt, false)
    
    mt.__namecall = newcclosure(function(self, ...)
        local method = getnamecallmethod()
        local args = {...}
        
        -- Chặn phát hiện
        if method == "Kick" then
            if Flags.AntiKick then
                return nil
            end
        end
        
        -- No Recoil/Spread
        if Flags.NoRecoil or Flags.NoSpread then
            if method == "FireServer" or method == "InvokeServer" then
                -- Modify gun properties silently
            end
        end
        
        return oldNamecall(self, ...)
    end)
end)

-- ==================== CLEANUP ON SCRIPT END ====================
game:GetService("CoreGui").ChildRemoved:Connect(function(child)
    if child == Window then
        CleanConnections()
        Utility:DisableESP()
        Utility:StopFly()
        FOVCircle:Remove()
    end
end)