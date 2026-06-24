-- FARM FROM 1303
-- Канал: https://t.me/scriptNftBattle
-- Автор: @cozy_hous1303

task.wait(1)

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

-- ── Whitelist ──────────────────────────────────────────────
local whitelist = {
    "UsernameGH4",
    -- добавляй покупателей сюда новой строкой
}
local _allowed = false
for _, _n in ipairs(whitelist) do
    if _n == LocalPlayer.Name then _allowed = true break end
end
if not _allowed then
    pcall(function() LocalPlayer:Kick("иди нахуй пидор") end)
    return
end
-- ───────────────────────────────────────────────────────────

local RS = game:GetService("ReplicatedStorage")
local UIS = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")

local SelectedCase = nil
local AutoFarm = false
local AutoSell = false
local FastUpgrade = false
local FarmTask = nil
local Collapsed = false
local CurrentTab = "main"
local CurrentLang = "ru"
local CurrentScale = 1.0
local ActiveParticle = "off"

local Events = RS:FindFirstChild("Events")
local OpenCase = Events and Events:FindFirstChild("OpenCase")

local ColorAccent  = Color3.fromRGB(255, 45, 145)
local ColorGreen   = Color3.fromRGB(40, 200, 90)
local ColorBg      = Color3.fromRGB(15, 15, 20)
local ColorBg2     = Color3.fromRGB(25, 25, 32)
local ColorText    = Color3.fromRGB(255, 255, 255)
local ColorTextDim = Color3.fromRGB(170, 170, 180)

local L = {
    ru = {
        title          = "🎲 FARM 1303",
        ready          = "💤 ГОТОВ",
        stopped        = "⏹ ОСТАНОВЛЕН",
        farming        = "✅ ФАРМИМ: ",
        pick_case      = "❌ ВЫБЕРИ КЕЙС!",
        autosell       = "АВТО-ПРОДАЖА",
        start          = "СТАРТ",
        stop           = "СТОП",
        tab_main       = "🎲 КЕЙСЫ",
        tab_settings   = "⚙ НАСТРОЙКИ",
        fast_up        = "⚡ FAST UPGRADE",
        fast_up_sub    = "Мгновенный апгрейд",
        particles      = "✨ ПАРТИКЛЫ",
        particles_sub  = "Визуальный эффект фона",
        scale          = "🔍 РАЗМЕР ОКНА",
        scale_sub      = "Тяни ползунок",
        language       = "🌐 ЯЗЫК",
        p_off          = "ВЫКЛ",
        p_snow         = "❄ СНЕГ",
        p_stars        = "⭐ ЗВЁЗДЫ",
        p_sparks       = "✦ ИСКРЫ",
        channel        = "КАНАЛ",
        author         = "АВТОР",
    },
    en = {
        title          = "🎲 FARM 1303",
        ready          = "💤 READY",
        stopped        = "⏹ STOPPED",
        farming        = "✅ FARMING: ",
        pick_case      = "❌ PICK A CASE!",
        autosell       = "AUTO-SELL",
        start          = "START",
        stop           = "STOP",
        tab_main       = "🎲 CASES",
        tab_settings   = "⚙ SETTINGS",
        fast_up        = "⚡ FAST UPGRADE",
        fast_up_sub    = "Instant upgrade value",
        particles      = "✨ PARTICLES",
        particles_sub  = "Visual background effect",
        scale          = "🔍 WINDOW SIZE",
        scale_sub      = "Drag the slider",
        language       = "🌐 LANGUAGE",
        p_off          = "OFF",
        p_snow         = "❄ SNOW",
        p_stars        = "⭐ STARS",
        p_sparks       = "✦ SPARKS",
        channel        = "CHANNEL",
        author         = "AUTHOR",
    },
}
local function T(k) return L[CurrentLang][k] or k end

local Cases = {
    {name="Dio",          image="rbxassetid://123317710551278"},
    {name="The Boys",     image="rbxassetid://70923515271544"},
    {name="Sunny Day",    image="rbxassetid://73024061358319"},
    {name="Glitch",       image="rbxassetid://75712104636721"},
    {name="Cyber",        image="rbxassetid://117934010640694"},
    {name="Bloody Night", image="rbxassetid://94792767297608"},
    {name="Angel",        image="rbxassetid://113027733090291"},
    {name="Monarch",      image="rbxassetid://92789602242541"},
    {name="URUS",         image="rbxassetid://113680285408799"},
    {name="Porsche 911",  image="rbxassetid://76723874472836"},
    {name="G63",          image="rbxassetid://97343275696585"},
    {name="M5 F90",       image="rbxassetid://91905618241831"},
    {name="REDO",         image="rbxassetid://132457608690149"},
    {name="Durov",        image="rbxassetid://77154250163489"},
    {name="Death Note",   image="rbxassetid://98726594446431"},
    {name="Desk Calendars",image="rbxassetid://137761401385296"},
    {name="Magnate",      image="rbxassetid://123757755758214"},
    {name="Cirque",       image="rbxassetid://102198691984946"},
}

local function MakeToggle(parent, x, y, initState, onToggle)
    local W, H = 44, 22
    local track = Instance.new("TextButton", parent)
    track.Size = UDim2.new(0, W, 0, H)
    track.Position = UDim2.new(0, x, 0, y)
    track.BackgroundColor3 = initState and ColorGreen or Color3.fromRGB(50,50,65)
    track.Text = ""
    track.BorderSizePixel = 0
    track.ZIndex = 8
    Instance.new("UICorner", track).CornerRadius = UDim.new(0, H/2)
    local thumb = Instance.new("Frame", track)
    thumb.Size = UDim2.new(0, H-4, 0, H-4)
    thumb.Position = initState and UDim2.new(0, W-H+2, 0, 2) or UDim2.new(0, 2, 0, 2)
    thumb.BackgroundColor3 = ColorText
    thumb.BorderSizePixel = 0
    thumb.ZIndex = 9
    Instance.new("UICorner", thumb).CornerRadius = UDim.new(0, (H-4)/2)
    local state = initState
    track.MouseButton1Click:Connect(function()
        state = not state
        TweenService:Create(track, TweenInfo.new(0.2, Enum.EasingStyle.Quad), {
            BackgroundColor3 = state and ColorGreen or Color3.fromRGB(50,50,65)
        }):Play()
        TweenService:Create(thumb, TweenInfo.new(0.2, Enum.EasingStyle.Quad), {
            Position = state and UDim2.new(0, W-H+2, 0, 2) or UDim2.new(0, 2, 0, 2)
        }):Play()
        if onToggle then onToggle(state) end
    end)
    return track, thumb, function() return state end
end

local oldGui = LocalPlayer.PlayerGui:FindFirstChild("Farm1303")
if oldGui then oldGui:Destroy() end

local GUI = Instance.new("ScreenGui")
GUI.Name = "Farm1303"
GUI.ResetOnSpawn = false
GUI.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
GUI.Parent = LocalPlayer.PlayerGui

local BASE_W = 260

local Main = Instance.new("Frame", GUI)
Main.Name = "Main"
Main.Size = UDim2.new(0, BASE_W, 1, 0)
Main.Position = UDim2.new(0.5, -BASE_W/2, 0, 0)
Main.BackgroundColor3 = ColorBg
Main.BorderSizePixel = 0
Main.ClipsDescendants = true
Instance.new("UICorner", Main).CornerRadius = UDim.new(0, 12)
Instance.new("UIStroke", Main).Color = ColorAccent
Main:FindFirstChildOfClass("UIStroke").Thickness = 1.5

local BgImg = Instance.new("ImageLabel", Main)
BgImg.Size = UDim2.new(1,0,1,0)
BgImg.Image = "rbxassetid://109428946552526"
BgImg.BackgroundTransparency = 1
BgImg.ImageTransparency = 0.72
BgImg.ScaleType = Enum.ScaleType.Crop
BgImg.ZIndex = 0
Instance.new("UICorner", BgImg).CornerRadius = UDim.new(0, 12)

local PFrame = Instance.new("Frame", Main)
PFrame.Size = UDim2.new(1,0,1,0)
PFrame.BackgroundTransparency = 1
PFrame.ZIndex = 1
PFrame.ClipsDescendants = true

local particleConn = nil

local function ClearParticles()
    if particleConn then particleConn:Disconnect(); particleConn = nil end
    for _, c in ipairs(PFrame:GetChildren()) do c:Destroy() end
end

local function DoSpawn(ptype)
    local size  = ptype=="snow" and 6 or ptype=="stars" and 5 or 4
    local color = ptype=="sparks" and Color3.fromRGB(255,200,50) or Color3.fromRGB(255,255,255)
    local sym   = ptype=="snow" and "❄" or ptype=="stars" and "★" or "✦"
    local W = Main.AbsoluteSize.X
    if W <= 0 then W = BASE_W end
    local dot = Instance.new("TextLabel", PFrame)
    dot.Size = UDim2.new(0, size*2, 0, size*2)
    dot.Position = UDim2.new(0, math.random(4, math.max(5, W-size*2)), 0, -size*3)
    dot.BackgroundTransparency = 1
    dot.Text = sym
    dot.TextColor3 = color
    dot.TextSize = size*2
    dot.Font = Enum.Font.GothamBold
    dot.ZIndex = 2
    local drift = math.random(-25, 25)
    local dur   = math.random(20, 38)/10
    TweenService:Create(dot, TweenInfo.new(dur, Enum.EasingStyle.Linear), {
        Position = UDim2.new(0, dot.Position.X.Offset + drift, 1, size*3)
    }):Play()
    task.delay(dur, function() if dot and dot.Parent then dot:Destroy() end end)
end

local function StartParticles(ptype)
    ClearParticles()
    ActiveParticle = ptype
    local timer = 0
    particleConn = RunService.Heartbeat:Connect(function(dt)
        timer += dt
        if timer >= 0.12 then
            timer = 0
            DoSpawn(ptype)
        end
    end)
end

local Top = Instance.new("Frame", Main)
Top.Size = UDim2.new(1,0,0,36)
Top.BackgroundColor3 = ColorBg2
Top.BorderSizePixel = 0
Top.ZIndex = 10
Instance.new("UICorner", Top).CornerRadius = UDim.new(0, 12)

local Title = Instance.new("TextLabel", Top)
Title.Size = UDim2.new(0.55,0,1,0)
Title.Position = UDim2.new(0,10,0,0)
Title.Text = T("title")
Title.TextColor3 = ColorAccent
Title.TextSize = 11
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.BackgroundTransparency = 1
Title.Font = Enum.Font.GothamBold
Title.ZIndex = 10

local MinBtn = Instance.new("TextButton", Top)
MinBtn.Size = UDim2.new(0,26,0,24)
MinBtn.Position = UDim2.new(1,-58,0.5,-12)
MinBtn.Text = "−"
MinBtn.TextColor3 = ColorText
MinBtn.TextSize = 13
MinBtn.BackgroundColor3 = Color3.fromRGB(40,40,55)
MinBtn.BorderSizePixel = 0
MinBtn.Font = Enum.Font.GothamBold
MinBtn.ZIndex = 10
Instance.new("UICorner", MinBtn).CornerRadius = UDim.new(0,5)

local CloseBtn = Instance.new("TextButton", Top)
CloseBtn.Size = UDim2.new(0,26,0,24)
CloseBtn.Position = UDim2.new(1,-30,0.5,-12)
CloseBtn.Text = "✕"
CloseBtn.TextColor3 = ColorText
CloseBtn.TextSize = 10
CloseBtn.BackgroundColor3 = Color3.fromRGB(180,40,40)
CloseBtn.BorderSizePixel = 0
CloseBtn.Font = Enum.Font.GothamBold
CloseBtn.ZIndex = 10
Instance.new("UICorner", CloseBtn).CornerRadius = UDim.new(0,5)

local TabBar = Instance.new("Frame", Main)
TabBar.Size = UDim2.new(1,0,0,30)
TabBar.Position = UDim2.new(0,0,0,36)
TabBar.BackgroundColor3 = ColorBg2
TabBar.BorderSizePixel = 0
TabBar.ZIndex = 10
local TL = Instance.new("UIListLayout", TabBar)
TL.FillDirection = Enum.FillDirection.Horizontal
TL.HorizontalAlignment = Enum.HorizontalAlignment.Center
TL.Padding = UDim.new(0,4)
local TP = Instance.new("UIPadding", TabBar)
TP.PaddingTop = UDim.new(0,4); TP.PaddingBottom = UDim.new(0,4)
TP.PaddingLeft = UDim.new(0,6); TP.PaddingRight = UDim.new(0,6)

local function MakeTabBtn(text, order)
    local b = Instance.new("TextButton", TabBar)
    b.Size = UDim2.new(0.47,0,1,0)
    b.BackgroundColor3 = ColorBg
    b.Text = text
    b.TextColor3 = ColorTextDim
    b.TextSize = 8
    b.Font = Enum.Font.GothamBold
    b.BorderSizePixel = 0
    b.LayoutOrder = order
    b.ZIndex = 10
    Instance.new("UICorner", b).CornerRadius = UDim.new(0,6)
    return b
end
local TabMain     = MakeTabBtn(T("tab_main"), 1)
local TabSettings = MakeTabBtn(T("tab_settings"), 2)

local BottomBar = Instance.new("Frame", Main)
BottomBar.Size = UDim2.new(1,0,0,130)
BottomBar.Position = UDim2.new(0,0,1,-130)
BottomBar.BackgroundColor3 = ColorBg2
BottomBar.BorderSizePixel = 0
BottomBar.ZIndex = 10
local BL = Instance.new("UIListLayout", BottomBar)
BL.FillDirection = Enum.FillDirection.Vertical
BL.HorizontalAlignment = Enum.HorizontalAlignment.Center
BL.Padding = UDim.new(0,4)
local BP = Instance.new("UIPadding", BottomBar)
BP.PaddingLeft = UDim.new(0,8); BP.PaddingRight = UDim.new(0,8)
BP.PaddingTop = UDim.new(0,4); BP.PaddingBottom = UDim.new(0,4)

local SellRow = Instance.new("Frame", BottomBar)
SellRow.Size = UDim2.new(1,0,0,26)
SellRow.BackgroundColor3 = ColorBg
SellRow.BorderSizePixel = 0
SellRow.ZIndex = 10
Instance.new("UICorner", SellRow).CornerRadius = UDim.new(0,7)

local SellIconImg = Instance.new("ImageLabel", SellRow)
SellIconImg.Size = UDim2.new(0,18,0,18)
SellIconImg.Position = UDim2.new(0,6,0.5,-9)
SellIconImg.Image = "rbxassetid://102704717572352"
SellIconImg.BackgroundTransparency = 1
SellIconImg.ZIndex = 11

local SellLabel = Instance.new("TextLabel", SellRow)
SellLabel.Size = UDim2.new(1,-80,1,0)
SellLabel.Position = UDim2.new(0,30,0,0)
SellLabel.Text = T("autosell")
SellLabel.TextColor3 = ColorTextDim
SellLabel.TextSize = 9
SellLabel.TextXAlignment = Enum.TextXAlignment.Left
SellLabel.BackgroundTransparency = 1
SellLabel.Font = Enum.Font.GothamBold
SellLabel.ZIndex = 11

local _, _, getSellState = MakeToggle(SellRow, 168, 2, false, function(state)
    AutoSell = state
    SellLabel.TextColor3 = state and ColorText or ColorTextDim
end)

local BtnRow = Instance.new("Frame", BottomBar)
BtnRow.Size = UDim2.new(1,0,0,38)
BtnRow.BackgroundTransparency = 1
BtnRow.ZIndex = 10
local BRL = Instance.new("UIListLayout", BtnRow)
BRL.FillDirection = Enum.FillDirection.Horizontal
BRL.HorizontalAlignment = Enum.HorizontalAlignment.Center
BRL.Padding = UDim.new(0,6)

local StartBtn = Instance.new("TextButton", BtnRow)
StartBtn.Size = UDim2.new(0,114,1,0)
StartBtn.Text = ""
StartBtn.BackgroundColor3 = Color3.fromRGB(20,160,60)
StartBtn.BorderSizePixel = 0
StartBtn.ZIndex = 10
Instance.new("UICorner", StartBtn).CornerRadius = UDim.new(0,8)
local SG = Instance.new("UIGradient", StartBtn)
SG.Color = ColorSequence.new({ColorSequenceKeypoint.new(0,Color3.fromRGB(40,200,90)),ColorSequenceKeypoint.new(1,Color3.fromRGB(10,120,40))})
SG.Rotation = 90
local StartIco = Instance.new("ImageLabel", StartBtn)
StartIco.Size = UDim2.new(0,16,0,16); StartIco.Position = UDim2.new(0,8,0.5,-8)
StartIco.Image = "rbxassetid://139349442285491"
StartIco.BackgroundTransparency = 1; StartIco.ZIndex = 11
local StartLabel = Instance.new("TextLabel", StartBtn)
StartLabel.Size = UDim2.new(1,-30,1,0); StartLabel.Position = UDim2.new(0,28,0,0)
StartLabel.Text = T("start"); StartLabel.TextColor3 = ColorText
StartLabel.TextSize = 10; StartLabel.Font = Enum.Font.GothamBold
StartLabel.BackgroundTransparency = 1; StartLabel.ZIndex = 11

local StopBtn = Instance.new("TextButton", BtnRow)
StopBtn.Size = UDim2.new(0,114,1,0)
StopBtn.Text = ""
StopBtn.BackgroundColor3 = Color3.fromRGB(190,40,40)
StopBtn.BorderSizePixel = 0
StopBtn.ZIndex = 10
Instance.new("UICorner", StopBtn).CornerRadius = UDim.new(0,8)
local StG = Instance.new("UIGradient", StopBtn)
StG.Color = ColorSequence.new({ColorSequenceKeypoint.new(0,Color3.fromRGB(230,60,60)),ColorSequenceKeypoint.new(1,Color3.fromRGB(140,20,20))})
StG.Rotation = 90
local StopIco = Instance.new("ImageLabel", StopBtn)
StopIco.Size = UDim2.new(0,16,0,16); StopIco.Position = UDim2.new(0,8,0.5,-8)
StopIco.Image = "rbxassetid://82110202986168"
StopIco.BackgroundTransparency = 1; StopIco.ZIndex = 11
local StopLabel = Instance.new("TextLabel", StopBtn)
StopLabel.Size = UDim2.new(1,-30,1,0); StopLabel.Position = UDim2.new(0,28,0,0)
StopLabel.Text = T("stop"); StopLabel.TextColor3 = ColorText
StopLabel.TextSize = 10; StopLabel.Font = Enum.Font.GothamBold
StopLabel.BackgroundTransparency = 1; StopLabel.ZIndex = 11

local StatusLbl = Instance.new("TextLabel", BottomBar)
StatusLbl.Size = UDim2.new(1,0,0,18)
StatusLbl.Text = T("ready")
StatusLbl.TextColor3 = ColorTextDim
StatusLbl.TextSize = 8
StatusLbl.BackgroundTransparency = 1
StatusLbl.Font = Enum.Font.GothamBold
StatusLbl.ZIndex = 10

local function SetStatus(t) StatusLbl.Text = t end

local Content = Instance.new("ScrollingFrame", Main)
Content.Size = UDim2.new(1,0,1,-196)
Content.Position = UDim2.new(0,0,0,66)
Content.BackgroundTransparency = 1
Content.BorderSizePixel = 0
Content.ScrollBarThickness = 3
Content.ScrollBarImageColor3 = ColorAccent
Content.CanvasSize = UDim2.new(0,0,0,0)
Content.AutomaticCanvasSize = Enum.AutomaticSize.Y
Content.ZIndex = 5
local CP = Instance.new("UIPadding", Content)
CP.PaddingLeft = UDim.new(0,7); CP.PaddingRight = UDim.new(0,7)
CP.PaddingTop = UDim.new(0,7); CP.PaddingBottom = UDim.new(0,7)
Instance.new("UIListLayout", Content).Padding = UDim.new(0,7)

local CaseGrid = Instance.new("Frame", Content)
CaseGrid.Size = UDim2.new(1,0,0,0)
CaseGrid.BackgroundTransparency = 1
CaseGrid.AutomaticSize = Enum.AutomaticSize.Y
CaseGrid.ZIndex = 5
local GL = Instance.new("UIGridLayout", CaseGrid)
GL.CellSize = UDim2.new(0,72,0,80)
GL.CellPadding = UDim2.new(0,5,0,5)
GL.HorizontalAlignment = Enum.HorizontalAlignment.Center
GL.SortOrder = Enum.SortOrder.LayoutOrder

local CaseButtons = {}
for i, case in ipairs(Cases) do
    local Btn = Instance.new("TextButton", CaseGrid)
    Btn.Size = UDim2.new(0,72,0,80); Btn.Text = ""
    Btn.BackgroundColor3 = ColorBg2; Btn.BorderSizePixel = 0
    Btn.LayoutOrder = i; Btn.ZIndex = 5
    Instance.new("UICorner", Btn).CornerRadius = UDim.new(0,8)
    local Img = Instance.new("ImageLabel", Btn)
    Img.Size = UDim2.new(1,-4,0,52); Img.Position = UDim2.new(0,2,0,2)
    Img.Image = case.image; Img.BackgroundTransparency = 1
    Img.ScaleType = Enum.ScaleType.Fit; Img.ZIndex = 6
    Instance.new("UICorner", Img).CornerRadius = UDim.new(0,6)
    local Lbl2 = Instance.new("TextLabel", Btn)
    Lbl2.Size = UDim2.new(1,0,0,24); Lbl2.Position = UDim2.new(0,0,1,-24)
    Lbl2.Text = case.name; Lbl2.TextColor3 = ColorTextDim
    Lbl2.TextSize = 7; Lbl2.BackgroundTransparency = 1
    Lbl2.Font = Enum.Font.GothamBold
    Lbl2.TextTruncate = Enum.TextTruncate.AtEnd; Lbl2.ZIndex = 6
    CaseButtons[case.name] = Btn
    Btn.MouseButton1Click:Connect(function()
        for _, b in pairs(CaseButtons) do b.BackgroundColor3 = ColorBg2 end
        Btn.BackgroundColor3 = ColorAccent
        SelectedCase = case.name
        SetStatus("✅ " .. case.name)
    end)
end

local SFrame = Instance.new("ScrollingFrame", Main)
SFrame.Size = UDim2.new(1,0,1,-196)
SFrame.Position = UDim2.new(0,0,0,66)
SFrame.BackgroundTransparency = 1
SFrame.BorderSizePixel = 0
SFrame.ScrollBarThickness = 3
SFrame.ScrollBarImageColor3 = ColorAccent
SFrame.CanvasSize = UDim2.new(0,0,0,0)
SFrame.AutomaticCanvasSize = Enum.AutomaticSize.Y
SFrame.Visible = false; SFrame.ZIndex = 5
local SP = Instance.new("UIPadding", SFrame)
SP.PaddingLeft = UDim.new(0,10); SP.PaddingRight = UDim.new(0,10)
SP.PaddingTop = UDim.new(0,10); SP.PaddingBottom = UDim.new(0,10)
local SLL = Instance.new("UIListLayout", SFrame)
SLL.Padding = UDim.new(0,10)
SLL.SortOrder = Enum.SortOrder.LayoutOrder
SLL.HorizontalAlignment = Enum.HorizontalAlignment.Center

local cardOrder = 0
local function Card(h)
    cardOrder += 1
    local c = Instance.new("Frame", SFrame)
    c.Size = UDim2.new(1,0,0,h)
    c.BackgroundColor3 = ColorBg2
    c.BorderSizePixel = 0
    c.LayoutOrder = cardOrder
    c.ZIndex = 6
    Instance.new("UICorner", c).CornerRadius = UDim.new(0,8)
    return c
end

local function MakeLbl(p,text,x,y,w,h,sz,col,ax)
    local l = Instance.new("TextLabel",p)
    l.Position = UDim2.new(0,x,0,y); l.Size = UDim2.new(0,w,0,h)
    l.Text = text; l.TextColor3 = col or ColorText
    l.TextSize = sz or 9; l.BackgroundTransparency = 1
    l.Font = Enum.Font.GothamBold
    l.TextXAlignment = ax or Enum.TextXAlignment.Left
    l.ZIndex = 7; return l
end

local FUCard = Card(58)
local fuIco = Instance.new("ImageLabel", FUCard)
fuIco.Size = UDim2.new(0,28,0,28); fuIco.Position = UDim2.new(0,8,0.5,-14)
fuIco.Image = "rbxassetid://75370281933816"; fuIco.BackgroundTransparency = 1; fuIco.ZIndex = 7
local FUTitle = MakeLbl(FUCard, T("fast_up"), 44, 6, 130, 15, 11, ColorAccent)
MakeLbl(FUCard, T("fast_up_sub"), 44, 23, 150, 12, 7, ColorTextDim)
local fu2 = Instance.new("ImageLabel", FUCard)
fu2.Size = UDim2.new(0,16,0,16); fu2.Position = UDim2.new(1,-112,0.5,-8)
fu2.Image = "rbxassetid://111189255186119"; fu2.BackgroundTransparency = 1; fu2.ZIndex = 7
MakeToggle(FUCard, BASE_W - 10 - 44 - 10, (58-22)/2, false, function(state)
    FastUpgrade = state
    pcall(function()
        game.Players.LocalPlayer._1628441770.Value = state and 1 or 0
    end)
end)

local PCard = Card(110)
MakeLbl(PCard, T("particles"), 12, 8, 180, 15, 11, ColorAccent)
MakeLbl(PCard, T("particles_sub"), 12, 25, 200, 12, 7, ColorTextDim)

local pModes = {
    {id="off",   label=function() return T("p_off")   end, bg=Color3.fromRGB(50,50,65),   tc=ColorTextDim},
    {id="snow",  label=function() return T("p_snow")  end, bg=Color3.fromRGB(60,100,160), tc=ColorText},
    {id="stars", label=function() return T("p_stars") end, bg=Color3.fromRGB(70,50,130),  tc=ColorText},
    {id="sparks",label=function() return T("p_sparks")end, bg=Color3.fromRGB(140,90,10),  tc=Color3.fromRGB(255,200,50)},
}
local pBtns = {}
local pBtnLayout = Instance.new("Frame", PCard)
pBtnLayout.Size = UDim2.new(1,-24,0,28)
pBtnLayout.Position = UDim2.new(0,12,0,44)
pBtnLayout.BackgroundTransparency = 1; pBtnLayout.ZIndex = 7
local pGrid = Instance.new("UIGridLayout", pBtnLayout)
pGrid.CellSize = UDim2.new(0,50,0,24)
pGrid.CellPadding = UDim2.new(0,4,0,4)
pGrid.HorizontalAlignment = Enum.HorizontalAlignment.Left
pGrid.SortOrder = Enum.SortOrder.LayoutOrder

for i, m in ipairs(pModes) do
    local b = Instance.new("TextButton", pBtnLayout)
    b.Size = UDim2.new(0,50,0,24)
    b.BackgroundColor3 = m.id == "off" and ColorAccent or m.bg
    b.Text = m.label()
    b.TextColor3 = m.id == "off" and ColorText or m.tc
    b.TextSize = 7; b.Font = Enum.Font.GothamBold
    b.BorderSizePixel = 0; b.LayoutOrder = i; b.ZIndex = 8
    Instance.new("UICorner", b).CornerRadius = UDim.new(0,5)
    pBtns[m.id] = b
    b.MouseButton1Click:Connect(function()
        for _, pm in ipairs(pModes) do
            pBtns[pm.id].BackgroundColor3 = pm.bg
            pBtns[pm.id].TextColor3 = pm.tc
        end
        TweenService:Create(b, TweenInfo.new(0.15), {BackgroundColor3 = ColorAccent}):Play()
        b.TextColor3 = ColorText
        if m.id == "off" then
            ClearParticles(); ActiveParticle = "off"
        else
            StartParticles(m.id)
        end
    end)
end

local ScCard = Card(72)
local ScTitle = MakeLbl(ScCard, T("scale"), 12, 7, 180, 15, 11, ColorAccent)
local ScVal   = MakeLbl(ScCard, "100%", 0, 7, BASE_W-22, 15, 9, ColorTextDim, Enum.TextXAlignment.Right)

local Track = Instance.new("Frame", ScCard)
Track.Size = UDim2.new(1,-24,0,8)
Track.Position = UDim2.new(0,12,0,34)
Track.BackgroundColor3 = Color3.fromRGB(40,40,55)
Track.BorderSizePixel = 0; Track.ZIndex = 7
Instance.new("UICorner", Track).CornerRadius = UDim.new(0,4)

local Fill = Instance.new("Frame", Track)
Fill.Size = UDim2.new(0.5,0,1,0)
Fill.BackgroundColor3 = ColorAccent
Fill.BorderSizePixel = 0; Fill.ZIndex = 8
Instance.new("UICorner", Fill).CornerRadius = UDim.new(0,4)

local Thumb = Instance.new("TextButton", Track)
Thumb.Size = UDim2.new(0,18,0,18)
Thumb.Position = UDim2.new(0.5,-9,0.5,-9)
Thumb.BackgroundColor3 = ColorText
Thumb.Text = ""
Thumb.BorderSizePixel = 0; Thumb.ZIndex = 9
Instance.new("UICorner", Thumb).CornerRadius = UDim.new(0,9)
local ThumbDot = Instance.new("Frame", Thumb)
ThumbDot.Size = UDim2.new(0,6,0,6)
ThumbDot.Position = UDim2.new(0.5,-3,0.5,-3)
ThumbDot.BackgroundColor3 = ColorAccent
ThumbDot.BorderSizePixel = 0; ThumbDot.ZIndex = 10
Instance.new("UICorner", ThumbDot).CornerRadius = UDim.new(0,3)

MakeLbl(ScCard, "50%", 12, 52, 30, 12, 7, ColorTextDim)
MakeLbl(ScCard, "150%", BASE_W-50, 52, 36, 12, 7, ColorTextDim, Enum.TextXAlignment.Right)

local SliderDrag = false
local function SetScale(rel)
    rel = math.clamp(rel, 0, 1)
    Fill.Size = UDim2.new(rel, 0, 1, 0)
    Thumb.Position = UDim2.new(rel, -9, 0.5, -9)
    CurrentScale = 0.5 + rel
    ScVal.Text = math.floor(CurrentScale * 100) .. "%"
    local newW = math.floor(BASE_W * CurrentScale)
    Main.Size = UDim2.new(0, newW, 1, 0)
    Main.Position = UDim2.new(0.5, -newW/2, Main.Position.Y.Scale, Main.Position.Y.Offset)
end

Thumb.MouseButton1Down:Connect(function() SliderDrag = true end)

local LCard = Card(46)
local LTitle = MakeLbl(LCard, T("language"), 12, 7, 160, 32, 11, ColorAccent)

local LangRU = Instance.new("TextButton", LCard)
LangRU.Size = UDim2.new(0,50,0,22)
LangRU.Position = UDim2.new(1,-112,0.5,-11)
LangRU.BackgroundColor3 = ColorAccent
LangRU.Text = "RU"
LangRU.TextColor3 = ColorText
LangRU.TextSize = 8; LangRU.Font = Enum.Font.GothamBold
LangRU.BorderSizePixel = 0; LangRU.ZIndex = 7
Instance.new("UICorner", LangRU).CornerRadius = UDim.new(0,5)

local LangEN = Instance.new("TextButton", LCard)
LangEN.Size = UDim2.new(0,50,0,22)
LangEN.Position = UDim2.new(1,-58,0.5,-11)
LangEN.BackgroundColor3 = Color3.fromRGB(40,40,55)
LangEN.Text = "EN"
LangEN.TextColor3 = ColorTextDim
LangEN.TextSize = 8; LangEN.Font = Enum.Font.GothamBold
LangEN.BorderSizePixel = 0; LangEN.ZIndex = 7
Instance.new("UICorner", LangEN).CornerRadius = UDim.new(0,5)

local InfoCard = Card(56)
local InfoTitle = MakeLbl(InfoCard, T("channel"), 12, 4, 150, 14, 9, ColorAccent)

local ChannelBtn = Instance.new("TextButton", InfoCard)
ChannelBtn.Size = UDim2.new(1,-24,0,22)
ChannelBtn.Position = UDim2.new(0,12,0,22)
ChannelBtn.BackgroundColor3 = Color3.fromRGB(30,50,80)
ChannelBtn.Text = "t.me/scriptNftBattle"
ChannelBtn.TextColor3 = Color3.fromRGB(100,180,255)
ChannelBtn.TextSize = 8
ChannelBtn.Font = Enum.Font.GothamBold
ChannelBtn.BorderSizePixel = 0
ChannelBtn.ZIndex = 7
Instance.new("UICorner", ChannelBtn).CornerRadius = UDim.new(0,5)

ChannelBtn.MouseButton1Click:Connect(function()
    pcall(function() setclipboard("https://t.me/scriptNftBattle") end)
    pcall(function()
        game:GetService("StarterGui"):SetCore("SendNotification", {
            Title = "Канал",
            Text = "Ссылка скопирована в буфер обмена!",
            Duration = 3
        })
    end)
end)

local AuthorLabel = Instance.new("TextLabel", InfoCard)
AuthorLabel.Size = UDim2.new(1,-24,0,16)
AuthorLabel.Position = UDim2.new(0,12,0,46)
AuthorLabel.Text = "@cozy_hous1303"
AuthorLabel.TextColor3 = ColorTextDim
AuthorLabel.TextSize = 8
AuthorLabel.Font = Enum.Font.Gotham
AuthorLabel.BackgroundTransparency = 1
AuthorLabel.TextXAlignment = Enum.TextXAlignment.Center
AuthorLabel.ZIndex = 7

local function OpenCaseFunc(name)
    task.spawn(function()
        pcall(function()
            if OpenCase then
                if OpenCase:IsA("RemoteFunction") then OpenCase:InvokeServer(name, 10)
                else OpenCase:FireServer(name, 10) end
            end
        end)
    end)
end

local function SellItems()
    task.spawn(function()
        pcall(function() RS.Events.Inventory:FireServer("Sell","ALL",false) end)
    end)
end

local function StopFarm()
    AutoFarm = false
    if FarmTask then
        pcall(function() task.cancel(FarmTask) end)
        FarmTask = nil
    end
    SetStatus(T("stopped"))
end

local function StartFarm()
    if not SelectedCase then SetStatus(T("pick_case")) return end
    if AutoFarm then StopFarm() end
    AutoFarm = true
    SetStatus(T("farming") .. SelectedCase)
    FarmTask = task.spawn(function()
        while AutoFarm do
            OpenCaseFunc(SelectedCase)
            task.wait(0.5)
            if AutoSell then SellItems() end
            task.wait(0.2)
        end
    end)
end

local function ApplyLang()
    Title.Text       = T("title")
    TabMain.Text     = T("tab_main")
    TabSettings.Text = T("tab_settings")
    StartLabel.Text  = T("start")
    StopLabel.Text   = T("stop")
    SellLabel.Text   = T("autosell")
    FUTitle.Text     = T("fast_up")
    ScTitle.Text     = T("scale")
    LTitle.Text      = T("language")
    InfoTitle.Text   = T("channel")
    AuthorLabel.Text = "@cozy_hous1303"
    SetStatus(AutoFarm and (T("farming")..(SelectedCase or "")) or T("ready"))
    for _, m in ipairs(pModes) do
        if pBtns[m.id] then pBtns[m.id].Text = m.label() end
    end
end

local function SwitchTab(tab)
    CurrentTab = tab
    Content.Visible = tab == "main"
    SFrame.Visible  = tab == "settings"
    TabMain.BackgroundColor3     = tab=="main"     and ColorAccent or ColorBg
    TabMain.TextColor3           = tab=="main"     and ColorText   or ColorTextDim
    TabSettings.BackgroundColor3 = tab=="settings" and ColorAccent or ColorBg
    TabSettings.TextColor3       = tab=="settings" and ColorText   or ColorTextDim
end

TabMain.MouseButton1Click:Connect(function() SwitchTab("main") end)
TabSettings.MouseButton1Click:Connect(function() SwitchTab("settings") end)
StartBtn.MouseButton1Click:Connect(StartFarm)
StopBtn.MouseButton1Click:Connect(StopFarm)

LangRU.MouseButton1Click:Connect(function()
    CurrentLang = "ru"
    TweenService:Create(LangRU,TweenInfo.new(0.15),{BackgroundColor3=ColorAccent}):Play()
    TweenService:Create(LangEN,TweenInfo.new(0.15),{BackgroundColor3=Color3.fromRGB(40,40,55)}):Play()
    LangRU.TextColor3=ColorText; LangEN.TextColor3=ColorTextDim
    ApplyLang()
end)
LangEN.MouseButton1Click:Connect(function()
    CurrentLang = "en"
    TweenService:Create(LangEN,TweenInfo.new(0.15),{BackgroundColor3=ColorAccent}):Play()
    TweenService:Create(LangRU,TweenInfo.new(0.15),{BackgroundColor3=Color3.fromRGB(40,40,55)}):Play()
    LangEN.TextColor3=ColorText; LangRU.TextColor3=ColorTextDim
    ApplyLang()
end)

MinBtn.MouseButton1Click:Connect(function()
    Collapsed = not Collapsed
    local newW = math.floor(BASE_W * CurrentScale)
    if Collapsed then
        Main:TweenSize(UDim2.new(0,newW,0,36),"Out","Quad",0.2,true)
        MinBtn.Text="□"
        Content.Visible=false; SFrame.Visible=false
        BottomBar.Visible=false; TabBar.Visible=false
    else
        Main:TweenSize(UDim2.new(0,newW,1,0),"Out","Quad",0.2,true)
        MinBtn.Text="−"
        SwitchTab(CurrentTab)
        BottomBar.Visible=true; TabBar.Visible=true
    end
end)

CloseBtn.MouseButton1Click:Connect(function()
    StopFarm(); ClearParticles(); GUI:Destroy()
end)

local drag, dragStart, startPos = false, nil, nil

Top.InputBegan:Connect(function(inp)
    if inp.UserInputType == Enum.UserInputType.MouseButton1
    or inp.UserInputType == Enum.UserInputType.Touch then
        drag=true; dragStart=inp.Position; startPos=Main.Position
    end
end)

UIS.InputChanged:Connect(function(inp)
    if inp.UserInputType == Enum.UserInputType.MouseMovement
    or inp.UserInputType == Enum.UserInputType.Touch then
        if SliderDrag then
            local tAbs = Track.AbsolutePosition.X
            local tW   = Track.AbsoluteSize.X
            if tW > 0 then
                SetScale((inp.Position.X - tAbs) / tW)
            end
        end
        if drag and dragStart and startPos then
            local d = inp.Position - dragStart
            Main.Position = UDim2.new(
                startPos.X.Scale, startPos.X.Offset + d.X,
                startPos.Y.Scale, startPos.Y.Offset + d.Y
            )
        end
    end
end)

UIS.InputEnded:Connect(function(inp)
    if inp.UserInputType == Enum.UserInputType.MouseButton1
    or inp.UserInputType == Enum.UserInputType.Touch then
        SliderDrag = false
        drag = false
    end
end)

UIS.InputBegan:Connect(function(inp, proc)
    if proc then return end
    if inp.KeyCode == Enum.KeyCode.Insert then
        Main.Visible = not Main.Visible
    end
end)

SwitchTab("main")
ApplyLang()
SetScale(0.5)
