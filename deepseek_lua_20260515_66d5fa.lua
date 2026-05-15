-- Miu Hub v1.0.00
local Lib = loadstring(game:HttpGet("https://raw.githubusercontent.com/Alexchad-source/Alexchad-Hub/refs/heads/main/MaybeAlexchadlib.lua"))()

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TeleportService = game:GetService("TeleportService")
local HttpService = game:GetService("HttpService")
local Lighting = game:GetService("Lighting")
local VirtualInputManager = game:GetService("VirtualInputManager")
local VirtualUser = game:GetService("VirtualUser")
local Workspace = workspace

local LP = Players.LocalPlayer
local Char, Hum, Root, Cam
local function UpdateChar()
    Char = LP.Character
    if Char then 
        Hum = Char:FindFirstChildOfClass("Humanoid") 
        Root = Char:FindFirstChild("HumanoidRootPart") 
    end
    Cam = Workspace.CurrentCamera
end
UpdateChar()
LP.CharacterAdded:Connect(function() task.wait(0.2) UpdateChar() end)

local S = {
    Walk = 16, Jump = 50, FlySpd = 50, SpinSpd = 10, 
    AimSm = 0.1, FlingPow = 5000, KAR = 30, FarmR = 50
}
local Conn = {}
local function AddC(c) table.insert(Conn, c) end
local function CleanC() for _,c in pairs(Conn) do pcall(function() c:Disconnect() end) end Conn = {} end

local BG, BV
local function StopFly()
    if BG then BG:Destroy() BG = nil end
    if BV then BV:Destroy() BV = nil end
    if Hum then Hum.PlatformStand = false end
end

local Highlights = {}

local Window = Lib:CreateWindow({
    Name = "Miu Hub",
    Subtitle = "Universal Script",
    Version = "v1.0.00",
    LoadingTitle = "Miu Hub",
    LoadingSubtitle = "Loading...",
    Theme = "Dark",
    ToggleKey = Enum.KeyCode.RightShift
})

local function Notify(t, c, d, tp) 
    pcall(function()
        Window:Notify({Title = t, Content = c, Duration = d or 3, Type = tp or "Info"})
    end)
end

local Util = {}
function Util:GetNearestPlayer(range)
    local n, s = nil, range or math.huge
    if not Root then return nil, 0 end
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= LP and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
            local d = (Root.Position - p.Character.HumanoidRootPart.Position).Magnitude
            if d < s then s = d n = p end
        end
    end
    return n, s
end

function Util:GetPlayersInRange(range)
    local t = {}
    if not Root then return t end
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= LP and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
            if (Root.Position - p.Character.HumanoidRootPart.Position).Magnitude <= range then
                table.insert(t, p)
            end
        end
    end
    return t
end

function Util:IsAlive() 
    return Char and Hum and Root and Hum.Health > 0 
end

function Util:TPTo(t)
    if not Root then return end
    if typeof(t) == "Vector3" then 
        Root.CFrame = CFrame.new(t)
    elseif typeof(t) == "CFrame" then 
        Root.CFrame = t 
    end
end

-- ==================== TAB 1: MOVEMENT ====================
local T1 = Window:CreateTab({Name = "Movement"})

T1:CreateToggle({
    Name = "BHop",
    Flag = "BH",
    CurrentValue = false,
    Callback = function(v)
        if v then 
            AddC(RunService.Stepped:Connect(function()
                if Util:IsAlive() and UserInputService:IsKeyDown(Enum.KeyCode.Space) then 
                    Hum:Move(Vector3.new(0, Hum.JumpPower, 0)) 
                end
            end)) 
        end
    end
})

T1:CreateToggle({
    Name = "Infinite Jump",
    Flag = "IJ",
    CurrentValue = false,
    Callback = function(v)
        if v then 
            AddC(UserInputService.JumpRequest:Connect(function()
                if Util:IsAlive() then 
                    Hum:ChangeState(Enum.HumanoidStateType.Jumping) 
                end
            end)) 
        end
    end
})

T1:CreateToggle({
    Name = "Fly (WASD + Space/Shift)",
    Flag = "Fly",
    CurrentValue = false,
    Callback = function(v)
        if v then
            if not Root then return end
            BG = Instance.new("BodyGyro")
            BG.P = 9e4
            BG.MaxTorque = Vector3.new(9e9, 9e9, 9e9)
            BG.CFrame = Root.CFrame
            BG.Parent = Root
            
            BV = Instance.new("BodyVelocity")
            BV.MaxForce = Vector3.new(9e9, 9e9, 9e9)
            BV.Velocity = Vector3.zero
            BV.Parent = Root
            
            if Hum then Hum.PlatformStand = true end
            
            AddC(RunService.RenderStepped:Connect(function()
                if not BG or not BV then return end
                BG.CFrame = Cam.CFrame
                local d = Vector3.zero
                if UserInputService:IsKeyDown(Enum.KeyCode.W) then d += Cam.CFrame.LookVector end
                if UserInputService:IsKeyDown(Enum.KeyCode.S) then d -= Cam.CFrame.LookVector end
                if UserInputService:IsKeyDown(Enum.KeyCode.A) then d -= Cam.CFrame.RightVector end
                if UserInputService:IsKeyDown(Enum.KeyCode.D) then d += Cam.CFrame.RightVector end
                if UserInputService:IsKeyDown(Enum.KeyCode.Space) then d += Vector3.new(0, 1, 0) end
                if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then d -= Vector3.new(0, 1, 0) end
                BV.Velocity = d * S.FlySpd
            end))
        else 
            StopFly() 
        end
    end
})

T1:CreateToggle({
    Name = "Noclip",
    Flag = "NC",
    CurrentValue = false,
    Callback = function(v)
        if v then 
            AddC(RunService.Stepped:Connect(function()
                if Char then 
                    for _, p in ipairs(Char:GetDescendants()) do 
                        if p:IsA("BasePart") then p.CanCollide = false end 
                    end 
                end
            end)) 
        else 
            if Char then 
                for _, p in ipairs(Char:GetDescendants()) do 
                    if p:IsA("BasePart") then p.CanCollide = true end 
                end 
            end 
        end
    end
})

T1:CreateButton({
    Name = "Set Speed 100",
    Callback = function()
        S.Walk = 100
        if Hum then Hum.WalkSpeed = 100 end
        Notify("Speed", "Walk speed set to 100!", 2, "Success")
    end
})

T1:CreateButton({
    Name = "Set Speed 200",
    Callback = function()
        S.Walk = 200
        if Hum then Hum.WalkSpeed = 200 end
        Notify("Speed", "Walk speed set to 200!", 2, "Success")
    end
})

T1:CreateButton({
    Name = "Set Jump 100",
    Callback = function()
        S.Jump = 100
        if Hum then Hum.JumpPower = 100 end
        Notify("Jump", "Jump power set to 100!", 2, "Success")
    end
})

T1:CreateButton({
    Name = "Set Jump 200",
    Callback = function()
        S.Jump = 200
        if Hum then Hum.JumpPower = 200 end
        Notify("Jump", "Jump power set to 200!", 2, "Success")
    end
})

T1:CreateButton({
    Name = "Low Gravity",
    Callback = function()
        Workspace.Gravity = 50
        Notify("Gravity", "Low gravity enabled!", 2, "Success")
    end
})

T1:CreateButton({
    Name = "Normal Gravity",
    Callback = function()
        Workspace.Gravity = 196
        Notify("Gravity", "Normal gravity restored!", 2, "Success")
    end
})

-- ==================== TAB 2: COMBAT ====================
local T2 = Window:CreateTab({Name = "Combat"})

T2:CreateToggle({
    Name = "God Mode",
    Flag = "GM",
    CurrentValue = false,
    Callback = function(v)
        if v then 
            AddC(RunService.Heartbeat:Connect(function()
                if Util:IsAlive() then Hum.Health = Hum.MaxHealth end
            end)) 
        end
    end
})

T2:CreateToggle({
    Name = "Kill Aura",
    Flag = "KA",
    CurrentValue = false,
    Callback = function(v)
        if v then 
            AddC(RunService.Heartbeat:Connect(function()
                if not v or not Util:IsAlive() then return end
                local plrs = Util:GetPlayersInRange(S.KAR)
                for _, p in ipairs(plrs) do
                    if p.Character and p.Character:FindFirstChild("Humanoid") then
                        local h = p.Character.Humanoid
                        if h.Health > 0 then h:TakeDamage(999) end
                    end
                end
            end)) 
        end
    end
})

T2:CreateButton({
    Name = "Kill Aura 30 studs",
    Callback = function()
        S.KAR = 30
        Notify("Kill Aura", "Range set to 30!", 2, "Success")
    end
})

T2:CreateButton({
    Name = "Kill Aura 100 studs",
    Callback = function()
        S.KAR = 100
        Notify("Kill Aura", "Range set to 100!", 2, "Success")
    end
})

T2:CreateToggle({
    Name = "Fling Players",
    Flag = "FP",
    CurrentValue = false,
    Callback = function(v)
        if v then 
            AddC(RunService.Heartbeat:Connect(function()
                if not v or not Root then return end
                for _, p in ipairs(Players:GetPlayers()) do
                    if p ~= LP and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
                        local tr = p.Character.HumanoidRootPart
                        tr.Velocity = (tr.Position - Root.Position).Unit * S.FlingPow
                        tr.RotVelocity = Vector3.new(math.random(-100,100), math.random(-100,100), math.random(-100,100))
                    end
                end
            end)) 
        end
    end
})

T2:CreateButton({
    Name = "One Shot All",
    Callback = function()
        for _, p in ipairs(Players:GetPlayers()) do
            if p ~= LP and p.Character and p.Character:FindFirstChild("Humanoid") then 
                p.Character.Humanoid.Health = 0 
            end
        end
        Notify("Combat", "One shot all players!", 2, "Success")
    end
})

-- ==================== TAB 3: AIMBOT ====================
local T3 = Window:CreateTab({Name = "Aimbot"})

T3:CreateToggle({
    Name = "Aimbot",
    Flag = "AB",
    CurrentValue = false,
    Callback = function(v)
        if v then 
            AddC(RunService.RenderStepped:Connect(function()
                if not v or not Cam then return end
                local n, nd = nil, 200
                local mp = UserInputService:GetMouseLocation()
                for _, p in ipairs(Players:GetPlayers()) do
                    if p ~= LP and p.Character and p.Character:FindFirstChild("Head") then
                        local ps, on = Cam:WorldToScreenPoint(p.Character.Head.Position)
                        if on then
                            local d = (Vector2.new(ps.X, ps.Y) - mp).Magnitude
                            if d < nd then nd = d n = p end
                        end
                    end
                end
                if n and n.Character and n.Character:FindFirstChild("Head") then
                    local tp = Cam:WorldToScreenPoint(n.Character.Head.Position)
                    mousemoverel((tp.X - mp.X) * S.AimSm, (tp.Y - mp.Y) * S.AimSm)
                end
            end)) 
        end
    end
})

T3:CreateButton({
    Name = "Smooth Aim (0.1)",
    Callback = function()
        S.AimSm = 0.1
        Notify("Aimbot", "Smoothness: 0.1", 2, "Success")
    end
})

T3:CreateButton({
    Name = "Snap Aim (0.5)",
    Callback = function()
        S.AimSm = 0.5
        Notify("Aimbot", "Smoothness: 0.5", 2, "Success")
    end
})

T3:CreateToggle({
    Name = "Trigger Bot",
    Flag = "TB",
    CurrentValue = false,
    Callback = function(v)
        if v then 
            AddC(RunService.RenderStepped:Connect(function()
                if not v then return end
                local n = Util:GetNearestPlayer(200)
                if n then
                    VirtualInputManager:SendMouseButtonEvent(0, 0, 0, true, game, 0)
                    task.wait(0.05)
                    VirtualInputManager:SendMouseButtonEvent(0, 0, 0, false, game, 0)
                end
            end)) 
        end
    end
})

-- ==================== TAB 4: VISUALS ====================
local T4 = Window:CreateTab({Name = "Visuals"})

T4:CreateToggle({
    Name = "Player ESP",
    Flag = "ESP",
    CurrentValue = false,
    Callback = function(v)
        if v then
            for _, p in ipairs(Players:GetPlayers()) do
                if p ~= LP and not Highlights[p] then
                    task.spawn(function()
                        local chr = p.Character or p.CharacterAdded:Wait()
                        if not chr then return end
                        local hl = Instance.new("Highlight")
                        hl.FillColor = Color3.fromRGB(255, 60, 60)
                        hl.FillTransparency = 0.4
                        hl.OutlineColor = Color3.fromRGB(255, 255, 255)
                        hl.OutlineTransparency = 0
                        hl.Adornee = chr
                        hl.Parent = chr
                        Highlights[p] = hl
                        p.CharacterAdded:Connect(function(nc) 
                            task.wait(0.2)
                            if Highlights[p] then 
                                Highlights[p].Adornee = nc 
                                Highlights[p].Parent = nc 
                            end
                        end)
                    end)
                end
            end
            AddC(Players.PlayerAdded:Connect(function(p)
                task.spawn(function()
                    local chr = p.Character or p.CharacterAdded:Wait()
                    if not chr or Highlights[p] then return end
                    local hl = Instance.new("Highlight")
                    hl.FillColor = Color3.fromRGB(255, 60, 60)
                    hl.FillTransparency = 0.4
                    hl.OutlineColor = Color3.fromRGB(255, 255, 255)
                    hl.OutlineTransparency = 0
                    hl.Adornee = chr
                    hl.Parent = chr
                    Highlights[p] = hl
                    p.CharacterAdded:Connect(function(nc) 
                        task.wait(0.2)
                        if Highlights[p] then 
                            Highlights[p].Adornee = nc 
                            Highlights[p].Parent = nc 
                        end
                    end)
                end)
            end))
            AddC(Players.PlayerRemoving:Connect(function(p)
                if Highlights[p] then 
                    Highlights[p]:Destroy() 
                    Highlights[p] = nil 
                end
            end))
        else 
            for _, hl in pairs(Highlights) do hl:Destroy() end 
            Highlights = {} 
        end
    end
})

T4:CreateToggle({
    Name = "Full Bright",
    Flag = "FB",
    CurrentValue = false,
    Callback = function(v)
        if v then
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

T4:CreateToggle({
    Name = "Invisible",
    Flag = "INV",
    CurrentValue = false,
    Callback = function(v)
        if Char then 
            for _, p in ipairs(Char:GetDescendants()) do 
                if p:IsA("BasePart") and p.Name ~= "HumanoidRootPart" then 
                    p.Transparency = v and 0.95 or 0 
                end 
            end 
        end
    end
})

T4:CreateButton({
    Name = "FOV 90",
    Callback = function()
        if Cam then Cam.FieldOfView = 90 end
        Notify("FOV", "Set to 90!", 2, "Success")
    end
})

T4:CreateButton({
    Name = "FOV 120",
    Callback = function()
        if Cam then Cam.FieldOfView = 120 end
        Notify("FOV", "Set to 120!", 2, "Success")
    end
})

T4:CreateButton({
    Name = "FOV 70 (Default)",
    Callback = function()
        if Cam then Cam.FieldOfView = 70 end
        Notify("FOV", "Reset to default!", 2, "Success")
    end
})

-- ==================== TAB 5: AUTO FARM ====================
local T5 = Window:CreateTab({Name = "Auto Farm"})

T5:CreateToggle({
    Name = "Auto Farm",
    Flag = "AF",
    CurrentValue = false,
    Callback = function(v)
        if v then 
            AddC(RunService.Heartbeat:Connect(function()
                if not v or not Util:IsAlive() then return end
                local n = Util:GetNearestPlayer(S.FarmR)
                if n and n.Character and n.Character:FindFirstChild("HumanoidRootPart") then
                    Root.CFrame = n.Character.HumanoidRootPart.CFrame * CFrame.new(0, 0, 3)
                    VirtualInputManager:SendMouseButtonEvent(0, 0, 0, true, game, 0)
                    task.wait(0.1)
                    VirtualInputManager:SendMouseButtonEvent(0, 0, 0, false, game, 0)
                end
            end)) 
        end
    end
})

T5:CreateButton({
    Name = "Farm Range 50",
    Callback = function()
        S.FarmR = 50
        Notify("Farm", "Range: 50 studs!", 2, "Success")
    end
})

T5:CreateButton({
    Name = "Farm Range 200",
    Callback = function()
        S.FarmR = 200
        Notify("Farm", "Range: 200 studs!", 2, "Success")
    end
})

-- ==================== TAB 6: TELEPORT ====================
local T6 = Window:CreateTab({Name = "Teleport"})

local savedPos

T6:CreateButton({
    Name = "Save Position",
    Callback = function()
        if Root then 
            savedPos = Root.CFrame 
            Notify("Saved", "Position saved!", 2, "Success")
        end
    end
})

T6:CreateButton({
    Name = "Load Position",
    Callback = function()
        if savedPos then 
            Util:TPTo(savedPos) 
            Notify("Loaded", "Position loaded!", 2, "Success")
        else 
            Notify("Error", "No position saved!", 2, "Error")
        end
    end
})

T6:CreateButton({
    Name = "TP to Spawn",
    Callback = function()
        if Workspace:FindFirstChild("SpawnLocation") then 
            Util:TPTo(Workspace.SpawnLocation.CFrame + Vector3.new(0, 5, 0))
            Notify("Success", "Teleported to spawn!", 2, "Success")
        end
    end
})

-- ==================== TAB 7: FUN ====================
local T7 = Window:CreateTab({Name = "Fun"})

T7:CreateToggle({
    Name = "Spinbot",
    Flag = "SB",
    CurrentValue = false,
    Callback = function(v)
        if v then 
            AddC(RunService.RenderStepped:Connect(function()
                if v and Root then 
                    Root.CFrame = Root.CFrame * CFrame.Angles(0, math.rad(S.SpinSpd), 0) 
                end
            end)) 
        end
    end
})

T7:CreateButton({
    Name = "Spin Fast",
    Callback = function()
        S.SpinSpd = 50
        Notify("Spin", "Speed: 50!", 2, "Success")
    end
})

T7:CreateButton({
    Name = "Spin Slow",
    Callback = function()
        S.SpinSpd = 10
        Notify("Spin", "Speed: 10!", 2, "Success")
    end
})

T7:CreateButton({
    Name = "Freeze All",
    Callback = function()
        for _, p in ipairs(Players:GetPlayers()) do
            if p ~= LP and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then 
                p.Character.HumanoidRootPart.Anchored = true 
            end
        end
        Notify("Fun", "Froze all players!", 2, "Success")
    end
})

T7:CreateButton({
    Name = "Unfreeze All",
    Callback = function()
        for _, p in ipairs(Players:GetPlayers()) do
            if p ~= LP and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then 
                p.Character.HumanoidRootPart.Anchored = false 
            end
        end
        Notify("Fun", "Unfroze all players!", 2, "Success")
    end
})

T7:CreateButton({
    Name = "Sit All",
    Callback = function()
        for _, p in ipairs(Players:GetPlayers()) do
            if p.Character and p.Character:FindFirstChild("Humanoid") then 
                p.Character.Humanoid.Sit = true 
            end
        end
        Notify("Fun", "Everyone sitting!", 2, "Success")
    end
})

T7:CreateButton({
    Name = "Explode All",
    Callback = function()
        for _, p in ipairs(Players:GetPlayers()) do
            if p ~= LP and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
                local ex = Instance.new("Explosion")
                ex.Position = p.Character.HumanoidRootPart.Position
                ex.BlastRadius = 50
                ex.BlastPressure = 999999
                ex.Parent = Workspace
            end
        end
        Notify("Fun", "Boom!", 2, "Success")
    end
})

-- ==================== TAB 8: SERVER ====================
local T8 = Window:CreateTab({Name = "Server"})

T8:CreateButton({
    Name = "Rejoin",
    Callback = function()
        TeleportService:Teleport(game.PlaceId, LP)
    end
})

T8:CreateButton({
    Name = "Server Hop",
    Callback = function()
        local ok, data = pcall(function() 
            return HttpService:JSONDecode(game:HttpGet("https://games.roblox.com/v1/games/" .. game.PlaceId .. "/servers/Public?sortOrder=Asc&limit=100")) 
        end)
        if ok then
            local s = {}
            for _, v in ipairs(data.data) do 
                if v.playing < v.maxPlayers and v.id ~= game.JobId then 
                    table.insert(s, v.id) 
                end 
            end
            if #s > 0 then 
                TeleportService:TeleportToPlaceInstance(game.PlaceId, s[math.random(1, #s)], LP)
            else 
                Notify("Error", "No servers!", 3, "Error")
            end
        end
    end
})

T8:CreateToggle({
    Name = "Anti AFK",
    Flag = "AA",
    CurrentValue = true,
    Callback = function(v)
        if v then 
            LP.Idled:Connect(function() 
                VirtualUser:Button2Down(Vector2.new(0, 0), Cam.CFrame) 
                task.wait(1) 
                VirtualUser:Button2Up(Vector2.new(0, 0), Cam.CFrame) 
            end) 
        end
    end
})

T8:CreateButton({
    Name = "Boost FPS",
    Callback = function()
        for _, v in ipairs(Workspace:GetDescendants()) do 
            if v:IsA("Part") and v.Material == Enum.Material.Grass then 
                v.Material = Enum.Material.SmoothPlastic 
            end 
        end
        Lighting.GlobalShadows = false
        Lighting.FogEnd = 100
        Notify("FPS", "Boosted!", 2, "Success")
    end
})

T8:CreateButton({
    Name = "Destroy UI",
    Callback = function()
        Window:Destroy()
    end
})

-- ==================== DONE ====================
Notify("Miu Hub", "Welcome " .. LP.Name .. "!", 5, "Success")
Notify("Miu Hub", "Press RightShift to toggle", 5, "Info")