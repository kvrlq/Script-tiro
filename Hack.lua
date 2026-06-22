-- SCRIPT BOT MOBILE - Sistema de Key Corrigido
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

repeat task.wait() until LocalPlayer and LocalPlayer:FindFirstChild("PlayerGui")
local LP = LocalPlayer

print("✅ INICIANDO...")

-- ===== SISTEMA DE KEY =====
local validKeys = {
    "SCRIPTADM",
    "SCRIPT",
    "SCRIPT1",
}

local isAuthenticated = false
local currentKey = ""

local function checkKey(key)
    for _, validKey in pairs(validKeys) do
        if key == validKey then
            return true
        end
    end
    return false
end

-- Variáveis
local AimbotEnabled = false
local ESPEnabled = false
local ESPBox = true
local ESPName = true
local ESPDistance = true
local ESPTracer = true
local WallcheckEnabled = false
local TeamCheck = false
local FOVRadius = 120
local Smoothness = 5
local HitPart = "Head"
local ESPColor = Color3.fromRGB(255, 80, 80)
local FOVColor = Color3.fromRGB(80, 130, 255)
local FOVCircle = nil
local ESPObjects = {}
local FOVHidden = false
local TelekillEnabled = false
local PullEnabled = false
local PullTargetPlayer = nil

-- Criar GUI
local gui = Instance.new("ScreenGui")
gui.Name = "ScriptBot"
gui.ResetOnSpawn = false
gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
gui.IgnoreGuiInset = true
gui.Parent = LP.PlayerGui

-- Funções básicas
local function IsEnemy(p)
    if not p or p == LP then return false end
    if not p.Character then return false end
    if TeamCheck and LP.Team and p.Team then return LP.Team ~= p.Team end
    local h = p.Character:FindFirstChild("Humanoid")
    return h and h.Health > 0
end

local function GetHitPart(char)
    if not char then return nil end
    if HitPart == "Head" then return char:FindFirstChild("Head") end
    if HitPart == "HumanoidRootPart" then return char:FindFirstChild("HumanoidRootPart") end
    return char:FindFirstChild("Torso") or char:FindFirstChild("UpperTorso") or char:FindFirstChild("Head")
end

local function GetClosestEnemy()
    if not LP.Character or not LP.Character:FindFirstChild("HumanoidRootPart") then return nil end
    local best, bestDist = nil, math.huge
    local myPos = LP.Character.HumanoidRootPart.Position
    for _, p in pairs(Players:GetPlayers()) do
        if IsEnemy(p) and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
            local d = (myPos - p.Character.HumanoidRootPart.Position).Magnitude
            if d < bestDist then best = p; bestDist = d end
        end
    end
    return best
end

local function TelekillLoop()
    while TelekillEnabled and isAuthenticated do
        task.wait(0.05)
        if not LP.Character or not LP.Character:FindFirstChild("HumanoidRootPart") then task.wait(0.5); continue end
        local target = GetClosestEnemy()
        if target and target.Character and target.Character:FindFirstChild("HumanoidRootPart") then
            LP.Character.HumanoidRootPart.CFrame = target.Character.HumanoidRootPart.CFrame
        else task.wait(0.5) end
    end
end

local function PullLoop()
    while PullEnabled and PullTargetPlayer and isAuthenticated do
        task.wait(0.05)
        if not LP.Character or not LP.Character:FindFirstChild("HumanoidRootPart") then PullEnabled = false; PullTargetPlayer = nil; break end
        local target = PullTargetPlayer
        if not target or not target.Parent or not target.Character or not target.Character:FindFirstChild("HumanoidRootPart") then PullEnabled = false; PullTargetPlayer = nil; break end
        if not IsEnemy(target) then PullEnabled = false; PullTargetPlayer = nil; break end
        local myPos = LP.Character.HumanoidRootPart.Position
        target.Character.HumanoidRootPart.CFrame = CFrame.new(myPos + Vector3.new(0, 0, -3))
        local humanoid = target.Character:FindFirstChild("Humanoid")
        if humanoid then humanoid.WalkSpeed = 0; humanoid.JumpPower = 0; humanoid.Sit = true end
    end
    if PullTargetPlayer and PullTargetPlayer.Character then
        local humanoid = PullTargetPlayer.Character:FindFirstChild("Humanoid")
        if humanoid then humanoid.WalkSpeed = 16; humanoid.JumpPower = 50; humanoid.Sit = false end
    end
end

local function PullTarget()
    if not isAuthenticated then return end
    local target = GetClosestEnemy()
    if not target then return end
    if PullEnabled then PullEnabled = false; PullTargetPlayer = nil; return end
    PullTargetPlayer = target; PullEnabled = true
    task.spawn(PullLoop)
end

local function TeleportToTarget()
    if not isAuthenticated then return end
    local t = GetClosestEnemy()
    if t and LP.Character and LP.Character:FindFirstChild("HumanoidRootPart") then
        LP.Character.HumanoidRootPart.CFrame = t.Character.HumanoidRootPart.CFrame
    end
end

local function ToggleTelekill(enabled)
    if not isAuthenticated then return end
    TelekillEnabled = enabled
    if enabled then task.spawn(TelekillLoop) end
end

function Notify(msg)
    local n = Instance.new("Frame")
    n.Size = UDim2.new(0, 200, 0, 30)
    n.Position = UDim2.new(0.5, -100, 0.05, 0)
    n.BackgroundColor3 = Color3.fromRGB(20, 20, 35)
    n.BorderSizePixel = 0
    n.ZIndex = 999
    n.Parent = gui
    Instance.new("UICorner", n).CornerRadius = UDim.new(0, 6)
    Instance.new("UIStroke", n).Color = Color3.fromRGB(80, 130, 255)
    local l = Instance.new("TextLabel", n)
    l.Size = UDim2.new(1, 0, 1, 0)
    l.BackgroundTransparency = 1
    l.Text = msg
    l.TextColor3 = Color3.fromRGB(255, 255, 255)
    l.Font = Enum.Font.GothamBold
    l.TextSize = 12
    l.ZIndex = 1000
    task.delay(2, function() if n.Parent then n:Destroy() end end)
end

-- ===== TELA DE LOGIN =====
local LoginFrame = Instance.new("Frame")
LoginFrame.Size = UDim2.new(0, 300, 0, 250)
LoginFrame.Position = UDim2.new(0.5, -150, 0.5, -125)
LoginFrame.BackgroundColor3 = Color3.fromRGB(18, 18, 32)
LoginFrame.BorderSizePixel = 0
LoginFrame.Visible = true
LoginFrame.Active = true
LoginFrame.ZIndex = 200
LoginFrame.Parent = gui
Instance.new("UICorner", LoginFrame).CornerRadius = UDim.new(0, 14)
Instance.new("UIStroke", LoginFrame).Color = Color3.fromRGB(80, 130, 255)

local LoginTitle = Instance.new("TextLabel")
LoginTitle.Size = UDim2.new(1, 0, 0, 50)
LoginTitle.Position = UDim2.new(0, 0, 0, 10)
LoginTitle.BackgroundTransparency = 1
LoginTitle.Text = "🔐 SCRIPT BOT\nDIGITE SUA KEY"
LoginTitle.TextColor3 = Color3.fromRGB(100, 150, 255)
LoginTitle.Font = Enum.Font.GothamBlack
LoginTitle.TextSize = 18
LoginTitle.ZIndex = 201
LoginTitle.Parent = LoginFrame

local KeyInput = Instance.new("TextBox")
KeyInput.Size = UDim2.new(0.85, 0, 0, 40)
KeyInput.Position = UDim2.new(0.075, 0, 0, 80)
KeyInput.BackgroundColor3 = Color3.fromRGB(25, 25, 45)
KeyInput.PlaceholderText = "Digite a Key..."
KeyInput.PlaceholderColor3 = Color3.fromRGB(100, 100, 120)
KeyInput.Text = ""
KeyInput.TextColor3 = Color3.fromRGB(255, 255, 255)
KeyInput.Font = Enum.Font.GothamMedium
KeyInput.TextSize = 14
KeyInput.BorderSizePixel = 0
KeyInput.ZIndex = 201
KeyInput.Parent = LoginFrame
Instance.new("UICorner", KeyInput).CornerRadius = UDim.new(0, 8)
Instance.new("UIStroke", KeyInput).Color = Color3.fromRGB(80, 130, 255)

local LoginBtn = Instance.new("TextButton")
LoginBtn.Size = UDim2.new(0.85, 0, 0, 40)
LoginBtn.Position = UDim2.new(0.075, 0, 0, 135)
LoginBtn.BackgroundColor3 = Color3.fromRGB(60, 130, 60)
LoginBtn.Text = "🔓 ATIVAR SCRIPT"
LoginBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
LoginBtn.Font = Enum.Font.GothamBold
LoginBtn.TextSize = 14
LoginBtn.BorderSizePixel = 0
LoginBtn.ZIndex = 201
LoginBtn.Parent = LoginFrame
Instance.new("UICorner", LoginBtn).CornerRadius = UDim.new(0, 8)

local LoginStatus = Instance.new("TextLabel")
LoginStatus.Size = UDim2.new(1, 0, 0, 30)
LoginStatus.Position = UDim2.new(0, 0, 0, 185)
LoginStatus.BackgroundTransparency = 1
LoginStatus.Text = ""
LoginStatus.TextColor3 = Color3.fromRGB(255, 255, 255)
LoginStatus.Font = Enum.Font.GothamSemibold
LoginStatus.TextSize = 12
LoginStatus.ZIndex = 201
LoginStatus.Parent = LoginFrame

local function showStatus(msg, color)
    LoginStatus.Text = msg
    LoginStatus.TextColor3 = color
    task.delay(3, function()
        if LoginStatus then LoginStatus.Text = "" end
    end)
end

-- ===== BOTÃO FLUTUANTE =====
local Fab = Instance.new("TextButton")
Fab.Size = UDim2.new(0, 50, 0, 50)
Fab.Position = UDim2.new(0.8, 0, 0.7, 0)
Fab.BackgroundColor3 = Color3.fromRGB(30, 30, 50)
Fab.Text = "⚡"
Fab.TextColor3 = Color3.fromRGB(80, 130, 255)
Fab.Font = Enum.Font.GothamBlack
Fab.TextSize = 24
Fab.BorderSizePixel = 0
Fab.Visible = false
Fab.Active = true
Fab.ZIndex = 100
Fab.Parent = gui
Instance.new("UICorner", Fab).CornerRadius = UDim.new(0, 25)
Instance.new("UIStroke", Fab).Color = Color3.fromRGB(80, 130, 255)

print("✅ Botão criado (oculto)")

-- ===== MENU =====
local Main = Instance.new("Frame")
Main.Size = UDim2.new(0, 320, 0, 400)
Main.Position = UDim2.new(0.5, -160, 0.5, -200)
Main.BackgroundColor3 = Color3.fromRGB(18, 18, 32)
Main.BorderSizePixel = 0
Main.Visible = false
Main.Active = true
Main.ClipsDescendants = true
Main.ZIndex = 80
Main.Parent = gui
Instance.new("UICorner", Main).CornerRadius = UDim.new(0, 12)
Instance.new("UIStroke", Main).Color = Color3.fromRGB(60, 100, 220)

local Header = Instance.new("Frame")
Header.Size = UDim2.new(1, 0, 0, 40)
Header.BackgroundColor3 = Color3.fromRGB(22, 22, 40)
Header.BorderSizePixel = 0
Header.ZIndex = 81
Header.Parent = Main
Instance.new("UICorner", Header).CornerRadius = UDim.new(0, 12)

local TitleLabel = Instance.new("TextLabel")
TitleLabel.Size = UDim2.new(0.6, 0, 1, 0)
TitleLabel.Position = UDim2.new(0.05, 0, 0, 0)
TitleLabel.BackgroundTransparency = 1
TitleLabel.Text = "⚡ SCRIPT BOT"
TitleLabel.TextColor3 = Color3.fromRGB(100, 150, 255)
TitleLabel.Font = Enum.Font.GothamBlack
TitleLabel.TextSize = 16
TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
TitleLabel.ZIndex = 82
TitleLabel.Parent = Header

local Close = Instance.new("TextButton")
Close.Size = UDim2.new(0, 30, 0, 30)
Close.Position = UDim2.new(1, -35, 0, 5)
Close.BackgroundColor3 = Color3.fromRGB(220, 50, 50)
Close.Text = "✕"
Close.TextColor3 = Color3.fromRGB(255, 255, 255)
Close.Font = Enum.Font.GothamBold
Close.TextSize = 16
Close.BorderSizePixel = 0
Close.ZIndex = 82
Close.Parent = Header
Instance.new("UICorner", Close).CornerRadius = UDim.new(0, 15)
Close.MouseButton1Click:Connect(function() Main.Visible = false end)

local Scroll = Instance.new("ScrollingFrame")
Scroll.Size = UDim2.new(1, -4, 1, -44)
Scroll.Position = UDim2.new(0, 2, 0, 42)
Scroll.BackgroundTransparency = 1
Scroll.ScrollBarThickness = 3
Scroll.ScrollBarImageColor3 = Color3.fromRGB(80, 130, 255)
Scroll.CanvasSize = UDim2.new(0, 0, 0, 0)
Scroll.ZIndex = 80
Scroll.Parent = Main

local List = Instance.new("UIListLayout")
List.Padding = UDim.new(0, 4)
List.HorizontalAlignment = Enum.HorizontalAlignment.Center
List.Parent = Scroll

-- Componentes UI
local function Sec(t)
    local f = Instance.new("Frame", Scroll)
    f.Size = UDim2.new(0.94, 0, 0, 20); f.BackgroundTransparency = 1; f.ZIndex = 81
    local l = Instance.new("TextLabel", f)
    l.Size = UDim2.new(1, 0, 1, 0); l.BackgroundTransparency = 1
    l.Text = t; l.TextColor3 = Color3.fromRGB(140, 140, 170)
    l.Font = Enum.Font.GothamBold; l.TextSize = 11; l.TextXAlignment = Enum.TextXAlignment.Left; l.ZIndex = 82
end

local function Tgl(text, default, callback)
    local f = Instance.new("Frame", Scroll)
    f.Size = UDim2.new(0.94, 0, 0, 34); f.BackgroundColor3 = Color3.fromRGB(28, 28, 48)
    f.BorderSizePixel = 0; f.ZIndex = 81
    Instance.new("UICorner", f).CornerRadius = UDim.new(0, 7)
    
    local lbl = Instance.new("TextLabel", f)
    lbl.Size = UDim2.new(0.62, 0, 1, 0); lbl.Position = UDim2.new(0.05, 0, 0, 0)
    lbl.BackgroundTransparency = 1; lbl.Text = text
    lbl.TextColor3 = Color3.fromRGB(200, 200, 220); lbl.Font = Enum.Font.GothamSemibold
    lbl.TextSize = 12; lbl.TextXAlignment = Enum.TextXAlignment.Left; lbl.ZIndex = 82
    
    local sw = Instance.new("TextButton", f)
    sw.Size = UDim2.new(0, 40, 0, 20); sw.Position = UDim2.new(1, -48, 0.5, -10)
    sw.BackgroundColor3 = default and Color3.fromRGB(80, 130, 255) or Color3.fromRGB(55, 55, 80)
    sw.Text = ""; sw.BorderSizePixel = 0; sw.Active = true; sw.ZIndex = 82
    Instance.new("UICorner", sw).CornerRadius = UDim.new(0, 10)
    
    local knob = Instance.new("Frame", sw)
    knob.Size = UDim2.new(0, 16, 0, 16)
    knob.Position = default and UDim2.new(1, -18, 0.5, -8) or UDim2.new(0, 2, 0.5, -8)
    knob.BackgroundColor3 = Color3.fromRGB(255, 255, 255); knob.BorderSizePixel = 0; knob.ZIndex = 83
    Instance.new("UICorner", knob).CornerRadius = UDim.new(0, 8)
    
    local enabled = default
    
    sw.MouseButton1Click:Connect(function()
        if not isAuthenticated then return end
        enabled = not enabled
        TweenService:Create(sw, TweenInfo.new(0.2), {BackgroundColor3 = enabled and Color3.fromRGB(80, 130, 255) or Color3.fromRGB(55, 55, 80)}):Play()
        TweenService:Create(knob, TweenInfo.new(0.2), {Position = enabled and UDim2.new(1, -18, 0.5, -8) or UDim2.new(0, 2, 0.5, -8)}):Play()
        callback(enabled)
    end)
end

local function Btn(text, color, callback)
    local f = Instance.new("Frame", Scroll)
    f.Size = UDim2.new(0.94, 0, 0, 34); f.BackgroundColor3 = Color3.fromRGB(28, 28, 48)
    f.BorderSizePixel = 0; f.ZIndex = 81
    Instance.new("UICorner", f).CornerRadius = UDim.new(0, 7)
    local b = Instance.new("TextButton", f)
    b.Size = UDim2.new(0.9, 0, 0, 24); b.Position = UDim2.new(0.5, 0, 0.5, 0)
    b.AnchorPoint = Vector2.new(0.5, 0.5); b.BackgroundColor3 = color
    b.Text = text; b.TextColor3 = Color3.fromRGB(255, 255, 255)
    b.Font = Enum.Font.GothamBold; b.TextSize = 12; b.BorderSizePixel = 0; b.ZIndex = 82
    Instance.new("UICorner", b).CornerRadius = UDim.new(0, 6)
    b.MouseButton1Click:Connect(function()
        if isAuthenticated then callback() end
    end)
end

local function Sld(text, min, max, default, callback)
    local f = Instance.new("Frame", Scroll)
    f.Size = UDim2.new(0.94, 0, 0, 48); f.BackgroundColor3 = Color3.fromRGB(28, 28, 48)
    f.BorderSizePixel = 0; f.ZIndex = 81
    Instance.new("UICorner", f).CornerRadius = UDim.new(0, 7)
    
    local lbl = Instance.new("TextLabel", f)
    lbl.Size = UDim2.new(0.5, 0, 0, 16); lbl.Position = UDim2.new(0.05, 0, 0, 4)
    lbl.BackgroundTransparency = 1; lbl.Text = text
    lbl.TextColor3 = Color3.fromRGB(200, 200, 220); lbl.Font = Enum.Font.GothamSemibold
    lbl.TextSize = 11; lbl.TextXAlignment = Enum.TextXAlignment.Left; lbl.ZIndex = 82
    
    local val = Instance.new("TextLabel", f)
    val.Size = UDim2.new(0.25, 0, 0, 16); val.Position = UDim2.new(0.7, 0, 0, 4)
    val.BackgroundTransparency = 1; val.Text = tostring(default)
    val.TextColor3 = Color3.fromRGB(100, 150, 255); val.Font = Enum.Font.GothamBold
    val.TextSize = 11; val.TextXAlignment = Enum.TextXAlignment.Right; val.ZIndex = 82
    
    local bg = Instance.new("Frame", f)
    bg.Size = UDim2.new(0.9, 0, 0, 4); bg.Position = UDim2.new(0.05, 0, 0, 28)
    bg.BackgroundColor3 = Color3.fromRGB(50, 50, 75); bg.BorderSizePixel = 0; bg.Active = true; bg.ZIndex = 82
    Instance.new("UICorner", bg).CornerRadius = UDim.new(0, 2)
    
    local pct = (default - min) / (max - min)
    local fill = Instance.new("Frame", bg)
    fill.Size = UDim2.new(pct, 0, 1, 0); fill.BackgroundColor3 = Color3.fromRGB(80, 130, 255)
    fill.BorderSizePixel = 0; fill.ZIndex = 83
    
    local thumb = Instance.new("TextButton", bg)
    thumb.Size = UDim2.new(0, 16, 0, 16); thumb.Position = UDim2.new(pct, -8, 0.5, -8)
    thumb.BackgroundColor3 = Color3.fromRGB(255, 255, 255); thumb.Text = ""
    thumb.BorderSizePixel = 0; thumb.ZIndex = 84
    Instance.new("UICorner", thumb).CornerRadius = UDim.new(0, 8)
    
    local drag = false
    local function upd(input)
        local pos = math.clamp((input.Position.X - bg.AbsolutePosition.X) / bg.AbsoluteSize.X, 0, 1)
        local v = math.floor(min + (max - min) * pos)
        val.Text = tostring(v); fill.Size = UDim2.new(pos, 0, 1, 0)
        thumb.Position = UDim2.new(pos, -8, 0.5, -8); callback(v)
    end
    thumb.InputBegan:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then drag = true end end)
    bg.InputBegan:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then drag = true; upd(i) end end)
    UserInputService.InputChanged:Connect(function(i) if drag then upd(i) end end)
    UserInputService.InputEnded:Connect(function() drag = false end)
end

local function ColorPick(text, default, callback)
    local f = Instance.new("Frame", Scroll)
    f.Size = UDim2.new(0.94, 0, 0, 50); f.BackgroundColor3 = Color3.fromRGB(28, 28, 48)
    f.BorderSizePixel = 0; f.ZIndex = 81
    Instance.new("UICorner", f).CornerRadius = UDim.new(0, 7)
    local lbl = Instance.new("TextLabel", f)
    lbl.Size = UDim2.new(1, -10, 0, 16); lbl.Position = UDim2.new(0, 5, 0, 4)
    lbl.BackgroundTransparency = 1; lbl.Text = text
    lbl.TextColor3 = Color3.fromRGB(200, 200, 220); lbl.Font = Enum.Font.GothamSemibold
    lbl.TextSize = 11; lbl.TextXAlignment = Enum.TextXAlignment.Left; lbl.ZIndex = 82
    local colors = {Color3.fromRGB(255, 80, 80), Color3.fromRGB(80, 130, 255), Color3.fromRGB(80, 255, 100), Color3.fromRGB(255, 255, 80), Color3.fromRGB(180, 80, 255), Color3.fromRGB(255, 255, 255)}
    for i, color in pairs(colors) do
        local b = Instance.new("TextButton", f)
        b.Size = UDim2.new(0, 20, 0, 20); b.Position = UDim2.new(0.05 + ((i-1) * 0.15), 0, 0, 26)
        b.BackgroundColor3 = color; b.Text = ""; b.BorderSizePixel = 0; b.ZIndex = 82
        Instance.new("UICorner", b).CornerRadius = UDim.new(0, 10)
        local st = Instance.new("UIStroke", b)
        st.Color = color == default and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(40, 40, 60)
        b.MouseButton1Click:Connect(function()
            callback(color)
            for _, c in pairs(f:GetChildren()) do if c:IsA("TextButton") and c:FindFirstChild("UIStroke") then c.UIStroke.Color = c.BackgroundColor3 == color and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(40, 40, 60) end end
        end)
    end
end

local function Pad()
    local p = Instance.new("Frame", Scroll)
    p.Size = UDim2.new(1, 0, 0, 6); p.BackgroundTransparency = 1
end

-- CONTEÚDO
Sec("🎯 AIMBOT")
Tgl("Aimbot (Inimigos)", false, function(v)
    AimbotEnabled = v
    if v then
        if not FOVCircle then
            FOVCircle = Instance.new("Frame")
            FOVCircle.Size = UDim2.new(0, FOVRadius * 2, 0, FOVRadius * 2)
            FOVCircle.AnchorPoint = Vector2.new(0.5, 0.5)
            FOVCircle.Position = UDim2.new(0.5, 0, 0.5, 0)
            FOVCircle.BackgroundTransparency = 1; FOVCircle.BorderSizePixel = 0
            FOVCircle.ZIndex = 200; FOVCircle.Parent = gui
            Instance.new("UIStroke", FOVCircle).Color = FOVColor
            Instance.new("UICorner", FOVCircle).CornerRadius = UDim.new(1, 0)
        end
        FOVCircle.Visible = not FOVHidden
        if FOVCircle:FindFirstChild("UIStroke") then FOVCircle.UIStroke.Transparency = FOVHidden and 1 or 0 end
    else
        if FOVCircle then FOVCircle.Visible = false end
    end
end)
Tgl("Esconder FOV", false, function(v)
    FOVHidden = v
    if FOVCircle and FOVCircle:FindFirstChild("UIStroke") then FOVCircle.UIStroke.Transparency = v and 1 or 0 end
end)

Sec("⚡ TELEKILL")
Tgl("Ativar Telekill", false, ToggleTelekill)

Sec("⚡ MOVIMENTO")
Btn("IR ATÉ O INIMIGO", Color3.fromRGB(60, 140, 60), TeleportToTarget)
Btn("PUXAR INIMIGO", Color3.fromRGB(140, 60, 140), PullTarget)

Sec("👁 ESP")
Tgl("ESP", false, function(v)
    ESPEnabled = v
    if not v then for _, o in pairs(ESPObjects) do if o and o.Frame then o.Frame:Destroy() end end; ESPObjects = {} end
end)
Tgl("Caixa", true, function(v) ESPBox = v; for _, d in pairs(ESPObjects) do if d.Box then d.Box.Visible = v end end end)
Tgl("Nome", true, function(v) ESPName = v; for _, d in pairs(ESPObjects) do if d.NameTag then d.NameTag.Visible = v end end end)
Tgl("Distância", true, function(v) ESPDistance = v; for _, d in pairs(ESPObjects) do if d.DistTag then d.DistTag.Visible = v end end end)
Tgl("Tracer", true, function(v) ESPTracer = v; for _, d in pairs(ESPObjects) do if d.Tracer then d.Tracer.Visible = v end end end)

Sec("🎨 COR ESP")
ColorPick("Cor ESP", ESPColor, function(c)
    ESPColor = c
    for _, d in pairs(ESPObjects) do
        if d.Box and d.Box:FindFirstChild("UIStroke") then d.Box.UIStroke.Color = c end
        if d.NameTag then d.NameTag.TextColor3 = c end
        if d.DistTag then d.DistTag.TextColor3 = c end
        if d.Tracer then d.Tracer.BackgroundColor3 = c end
    end
end)

Sec("⚙️ AIMBOT")
Sld("FOV", 50, 300, FOVRadius, function(v) FOVRadius = v; if FOVCircle then FOVCircle.Size = UDim2.new(0, v*2, 0, v*2) end end)
Sld("Suavidade", 1, 15, Smoothness, function(v) Smoothness = v end)

Sec("🛡️ SEGURANÇA")
Tgl("Team Check", false, function(v) TeamCheck = v end)
Tgl("Wall Check", false, function(v) WallcheckEnabled = v end)

Sec("🎨 COR FOV")
ColorPick("Cor FOV", FOVColor, function(c) FOVColor = c; if FOVCircle and FOVCircle:FindFirstChild("UIStroke") then FOVCircle.UIStroke.Color = c end end)

Pad()

List:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
    Scroll.CanvasSize = UDim2.new(0, 0, 0, List.AbsoluteContentSize.Y + 6)
end)

-- ===== AÇÃO DO BOTÃO LOGIN =====
LoginBtn.MouseButton1Click:Connect(function()
    local key = KeyInput.Text
    
    if key == "" then
        showStatus("❌ Digite uma Key!", Color3.fromRGB(255, 80, 80))
        return
    end
    
    if checkKey(key) then
        isAuthenticated = true
        currentKey = key
        showStatus("✅ KEY VÁLIDA!", Color3.fromRGB(80, 255, 100))
        
        print("✅ Key válida: " .. key)
        
        -- Destruir tela de login
        task.wait(1)
        LoginFrame:Destroy()
        
        -- ✅ MOSTRAR BOTÃO ⚡
        Fab.Visible = true
        print("✅ Botão ⚡ agora visível!")
        
        Notify("✅ SCRIPT ATIVADO!")
        
        -- Iniciar sistemas
        -- Aimbot
        RunService.RenderStepped:Connect(function()
            if not isAuthenticated then return end
            if not AimbotEnabled or not LP.Character or not LP.Character:FindFirstChild("HumanoidRootPart") then return end
            local closest, dist = nil, math.huge
            for _, p in pairs(Players:GetPlayers()) do
                if IsEnemy(p) and p.Character then
                    local t = GetHitPart(p.Character)
                    if t then
                        local pos, vis = Camera:WorldToViewportPoint(t.Position)
                        if vis then
                            if WallcheckEnabled then
                                local ray = Ray.new(Camera.CFrame.Position, (t.Position - Camera.CFrame.Position).Unit * 500)
                                local hit = workspace:FindPartOnRay(ray, LP.Character)
                                if not hit or not hit:IsDescendantOf(p.Character) then vis = false end
                            end
                            if vis then
                                local d = (Vector2.new(pos.X, pos.Y) - Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y/2)).Magnitude
                                if d < FOVRadius and d < dist then closest = t; dist = d end
                            end
                        end
                    end
                end
            end
            if closest then Camera.CFrame = Camera.CFrame:Lerp(CFrame.new(Camera.CFrame.Position, closest.Position), 1 / Smoothness) end
        end)
        
        -- ESP
        local function CreateESP(player)
            if ESPObjects[player] then return end
            local f = Instance.new("Frame", gui); f.BackgroundTransparency = 1; f.BorderSizePixel = 0; f.ZIndex = 30
            local box = Instance.new("Frame", f); box.Size = UDim2.new(1, 0, 1, 0); box.BackgroundTransparency = 1; box.Visible = ESPBox; box.ZIndex = 30; Instance.new("UIStroke", box).Color = ESPColor
            local nm = Instance.new("TextLabel", f); nm.Size = UDim2.new(1, 0, 0, 14); nm.Position = UDim2.new(0, 0, 0, -18); nm.BackgroundTransparency = 1; nm.Text = player.Name; nm.TextColor3 = ESPColor; nm.Font = Enum.Font.GothamBold; nm.TextSize = 9; nm.Visible = ESPName; nm.ZIndex = 31
            local dst = Instance.new("TextLabel", f); dst.Size = UDim2.new(1, 0, 0, 14); dst.Position = UDim2.new(0, 0, 1, 2); dst.BackgroundTransparency = 1; dst.Text = "0m"; dst.TextColor3 = ESPColor; dst.Font = Enum.Font.GothamSemibold; dst.TextSize = 8; dst.Visible = ESPDistance; dst.ZIndex = 31
            local tr = Instance.new("Frame", f); tr.BackgroundColor3 = ESPColor; tr.BorderSizePixel = 0; tr.Visible = ESPTracer; tr.ZIndex = 29; tr.AnchorPoint = Vector2.new(0.5, 0)
            ESPObjects[player] = {Frame = f, Box = box, NameTag = nm, DistTag = dst, Tracer = tr}
        end
        
        local function UpdateESP()
            if not ESPEnabled or not isAuthenticated then return end
            local center = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y)
            for player, data in pairs(ESPObjects) do
                if player and player.Parent and player.Character and IsEnemy(player) then
                    local root = player.Character:FindFirstChild("HumanoidRootPart"); local head = player.Character:FindFirstChild("Head")
                    if root and head then
                        local rp, ro = Camera:WorldToViewportPoint(root.Position); local hp, ho = Camera:WorldToViewportPoint(head.Position + Vector3.new(0, 0.5, 0))
                        if ro and ho then
                            local h = math.abs(rp.Y - hp.Y) * 1.7; local w = h * 0.6
                            data.Frame.Visible = true; data.Frame.Position = UDim2.new(0, hp.X - w/2, 0, hp.Y); data.Frame.Size = UDim2.new(0, w, 0, h)
                            if ESPTracer then local bx, by = hp.X, hp.Y + h; local th = center.Y - by; data.Tracer.Size = UDim2.new(0, 1, 0, math.abs(th)); data.Tracer.Position = UDim2.new(0.5, 0, 0, -th); data.Tracer.Rotation = math.deg(math.atan2(center.X - bx, th)) end
                            if LP.Character and LP.Character:FindFirstChild("HumanoidRootPart") then data.DistTag.Text = string.format("%.0fm", (LP.Character.HumanoidRootPart.Position - root.Position).Magnitude) end
                        else data.Frame.Visible = false end
                    end
                elseif data.Frame then data.Frame.Visible = false end
            end
        end
        
        RunService.RenderStepped:Connect(function()
            if not isAuthenticated then return end
            if ESPEnabled then
                UpdateESP()
                for _, p in pairs(Players:GetPlayers()) do if p ~= LP and p.Character and IsEnemy(p) and not ESPObjects[p] then CreateESP(p) end end
                for p, _ in pairs(ESPObjects) do if not p.Parent then ESPObjects[p].Frame:Destroy(); ESPObjects[p] = nil end end
            end
        end)
        
        Players.PlayerAdded:Connect(function(p) p.CharacterAdded:Connect(function() if ESPEnabled and isAuthenticated and IsEnemy(p) then task.wait(0.3); CreateESP(p) end end) end)
        Players.PlayerRemoving:Connect(function(p) if ESPObjects[p] then ESPObjects[p].Frame:Destroy(); ESPObjects[p] = nil end end)
        
    else
        showStatus("❌ KEY INVÁLIDA!", Color3.fromRGB(255, 80, 80))
        print("❌ Key inválida: " .. key)
    end
end)

-- Clique/Arraste do botão
local fabDrag, fabStart, fabPos, fabMoved = false, nil, nil, false
Fab.InputBegan:Connect(function(i)
    if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
        fabDrag = true; fabMoved = false; fabStart = i.Position; fabPos = Fab.Position
    end
end)
Fab.InputEnded:Connect(function()
    if not fabMoved then Main.Visible = true end
    fabDrag = false
end)
UserInputService.InputChanged:Connect(function(i)
    if fabDrag then
        local d = i.Position - fabStart
        if d.Magnitude > 3 then fabMoved = true; Fab.Position = UDim2.new(fabPos.X.Scale, fabPos.X.Offset + d.X, fabPos.Y.Scale, fabPos.Y.Offset + d.Y) end
    end
end)

-- Drag menu
local menuDrag, menuStart, menuPos = false, nil, nil
Header.InputBegan:Connect(function(i)
    if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
        menuDrag = true; menuStart = i.Position; menuPos = Main.Position
    end
end)
UserInputService.InputChanged:Connect(function(i)
    if menuDrag then local d = i.Position - menuStart; Main.Position = UDim2.new(menuPos.X.Scale, menuPos.X.Offset + d.X, menuPos.Y.Scale, menuPos.Y.Offset + d.Y) end
end)
UserInputService.InputEnded:Connect(function() menuDrag = false end)

print("✅✅✅ SCRIPT CARREGADO! ✅✅✅")
print("🔐 Tela de login visível")
print("Keys válidas: SCRIPTBOT-12345, SCRIPTBOT-ADMIN, SCRIPTBOT-FREE")
