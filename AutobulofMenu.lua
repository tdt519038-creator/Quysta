loadstring(game:HttpGet("https://githubusercontent.com", true))()

--[[
loadstring(game:HttpGet("https://githubusercontent.com", true))()
loadstring(game:HttpGet("https://githubusercontent.com"))()
]]

local plr = game:GetService("Players").LocalPlayer
local cclosure = syn_newcclosure or newcclosure or nil

if not cclosure or not hookmetamethod then
    plr:Kick("\n\nYour exploit doesn't support hookmetamethod\n")
end

local oldNamecall
oldNamecall = hookmetamethod(game, "__namecall", cclosure(function(self, ...)
    local NamecallMethod = getnamecallmethod()
    local args = { ... }
    if (NamecallMethod == "Kick" or NamecallMethod == "kick") and not checkcaller() then
        if self == plr then
            return oldNamecall(self, ...)
        end
        return
    end
    return oldNamecall(self, ...)
end))

for wendigo, iscool in pairs(getgc(true)) do
    if pcall(function() return rawget(iscool, "indexInstance") end)
    and type(rawget(iscool, "indexInstance")) == "table"
    and rawget(iscool, "indexInstance") == "kick" then
        iscool.tvk = {"kick", function()
            return game.Workspace:WaitForChild("")
        end}
    end
end

local getinfo = getinfo or debug.getinfo
local DEBUG = false
local Hooked = {}

local Detected, Kill

setthreadidentity(2)

for i, v in pairs(getgc(true)) do
    if typeof(v) == "table" then
        local DetectFunc = rawget(v, "Detected")
        local KillFunc = rawget(v, "Kill")
        
        if typeof(DetectFunc) == "function" and not Detected then
            Detected = DetectFunc
            
            local Old; Old = hookfunction(Detected, function(Action, Info, NoCrash)
                if Action ~= "_" then
                    if DEBUG then
                        warn("Adonis AntiCheat flagged\nMethod: {Action}\nInfo: {Info}")
                    end
                end
                return true
            end)
            
            table.insert(Hooked, Detected)
        end
        
        if rawget(v, "Variables") and rawget(v, "Process") and typeof(KillFunc) == "function" and not Kill then
            Kill = KillFunc
            local Old; Old = hookfunction(Kill, function(Info)
                if DEBUG then
                    warn("Adonis AntiCheat tried to kill (fallback): {Info}")
                end
            end)
            
            table.insert(Hooked, Kill)
        end
    end
end

local Old; Old = hookfunction(getrenv().debug.info, newcclosure(function(...)
    local LevelOrFunc, Info = ...
    
    if Detected and LevelOrFunc == Detected then
        if DEBUG then
            warn("Adonis AntiCheat sanity check detected and broken")
        end
        return coroutine.yield(coroutine.running())
    end
    
    return Old(...)
end))

Bypass = true

local GameMT = getrawmetatable(game)
-- Backup variables
local OldIndexFunc = GameMT.__index;
local OldNamecallFunc = GameMT.__namecall
setreadonly(GameMT, false)
if (Bypass == true) then
    -- This will be so laggy
    GameMT.__namecall = newcclosure(function(self, ...)
        local NamecallArgs = {...}
        
        local DETECTION_STRINGS =
        {
            'CHECKER_1';
            'CHECKER';
            'OneMoreTime';
            'checkingSPEED';
            'PERMAIDBAN';
            'BANREMOTE';
            'FORCEFIELD';
            'TeleportDetect';
        };
        
        if (table.find(DETECTION_STRINGS, NamecallArgs) and getnamecallmethod() == 'FireServer') then
            return;
        end;
        
        local suc, err = pcall(getfenv, 2)
        if not (err) then
            if getfenv(2).crash then
                hookfunction(getfenv(2).crash, function()
                    
                end)
            end
        end
        return OldNamecallFunc(self, ...)
    end)
end

for _, con in next, getconnections(workspace.CurrentCamera.Changed) do
    task.wait()
    con:Disable()
end

for _, con in next, getconnections(workspace.CurrentCamera:GetPropertyChangedSignal("CFrame")) do
    task.wait()
    con:Disable()
end
--[[
    AUTO DODGE MENU SCRIPT
    Chạy trên Executor (Wave, Solara, Celery, v.v.)
    Phím tắt: RightShift hoặc V
]]

-- ==================== CONFIG ====================
local CONFIG = {
    TOGGLE_KEY = Enum.KeyCode.RightShift, -- Hoặc Enum.KeyCode.V
    MENU_SIZE = UDim2.new(0, 300, 0, 200),
    MENU_POSITION = UDim2.new(0, 20, 0, 20),
}

-- ==================== SERVICES & VARIABLES ====================
local UserInputService = game:GetService("UserInputService")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local Client = Players.LocalPlayer
local Character = Client.Character or Client.CharacterAdded:Wait()
local Humanoid = Character:WaitForChild("Humanoid")
local HumanoidRootPart = Character:WaitForChild("HumanoidRootPart")

local States = workspace:WaitForChild("States")
local Effect = require(game:GetService("ReplicatedStorage").Modules.EffectHelper)

local VIM = game:GetService("VirtualInputManager")

-- ==================== STATE MANAGEMENT ====================
local DodgeEnabled = true
local MenuOpen = false
local Connections = {}
local ScreenGui = nil

local shared_BaseEffectFunction = {}

-- ==================== UTILITIES ====================
local function set_thread_identity(level)
    if setthreadcontext then
        setthreadcontext(level)
    elseif set_thread_identity then
        set_thread_identity(level)
    end
end

local function hold(keyCode, time)
    set_thread_identity(7)
    VIM:SendKeyEvent(true, keyCode, false, game)
    task.wait(time)
    VIM:SendKeyEvent(false, keyCode, false, game)
    set_thread_identity(2)
end

local function get(n, s)
    local found = States[n.Name]:FindFirstChild(s, true)
    return found and found.Value or false
end

local function notif(title, text)
    game:GetService("StarterGui"):SetCore("SendNotification", {
        Title = title,
        Text = text,
        Duration = 3,
    })
end

local function dash()
    hold(32, 0.1)
end

local function random()
    return math.random(1, 100) / 100
end

-- ==================== DODGE SYSTEM ====================
local waiting = {}

local function waitValid(name, func)
    if not waiting[name] then
        waiting[name] = {}
    end
    table.insert(waiting[name], func)
end

local function valid(name, ...)
    if waiting[name] then
        for i = 1, #waiting[name] do
            task.spawn(waiting[name][i], ...)
        end
        waiting[name] = nil
    end
end

-- Hook Effect Functions
for i, v in pairs(Effect) do
    shared_BaseEffectFunction[i] = shared_BaseEffectFunction[i] or v
    Effect[i] = function(d, ...)
        task.spawn(function()
            if not DodgeEnabled then
                return
            end
            
            if type(d) == "table" and typeof(d[2]) == "Instance" then
                local Target = get(Client, "LockedOn")
                local Distance = Client:DistanceFromCharacter(Character:FindFirstChild("HumanoidRootPart") and Character.HumanoidRootPart.Position or Vector3.new(0,0,0))
                
                if get(Client, "Blocking") or
                   not get(Client, "Equipped") or
                   get(Client, "Punching") then
                    return
                end
                
                if Distance > 10.8 then
                    return
                end
                
                if (d[1] == "AttackTrail" or d[1] == "StartupHighlight" or d[1] == "UltimateHighlight") and d[2] ~= Client.Character and type(d[5]) == 'number' then
                    waitValid(d[2].Name, function(LightAttack)
                        local delay = d[5] * Random.new():NextNumber(0.4, 0.6)
                        local formattedResult = string.format("%.2f", delay)
                        task.wait(tonumber(formattedResult))
                        coroutine.wrap(dash)()
                        notif("✓ Dodged!", "Chính xác!")
                    end)
                end
                
                if d[1] == "StartupHighlight" then
                    valid(d[2].Name, not (d[3] or d[4] or d[5]))
                end
            end
        end)
        return shared_BaseEffectFunction[i](d, ...)
    end
end

-- ==================== UI CREATION ====================
local function createMenu()
    -- Kiểm tra menu đã tồn tại chưa
    if ScreenGui then
        return ScreenGui
    end
    
    local PlayerGui = Client:WaitForChild("PlayerGui")
    
    ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "AutoDodgeMenu"
    ScreenGui.ResetOnSpawn = false
    ScreenGui.Parent = PlayerGui
    
    -- Main Frame (Draggable)
    local MainFrame = Instance.new("Frame")
    MainFrame.Name = "MainFrame"
    MainFrame.Size = CONFIG.MENU_SIZE
    MainFrame.Position = CONFIG.MENU_POSITION
    MainFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    MainFrame.BorderSizePixel = 0
    MainFrame.Parent = ScreenGui
    
    -- Title Bar
    local TitleBar = Instance.new("Frame")
    TitleBar.Name = "TitleBar"
    TitleBar.Size = UDim2.new(1, 0, 0, 35)
    TitleBar.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
    TitleBar.BorderSizePixel = 0
    TitleBar.Parent = MainFrame
    
    local TitleLabel = Instance.new("TextLabel")
    TitleLabel.Name = "Title"
    TitleLabel.Size = UDim2.new(0.7, 0, 1, 0)
    TitleLabel.Position = UDim2.new(0, 10, 0, 0)
    TitleLabel.BackgroundTransparency = 1
    TitleLabel.TextColor3 = Color3.fromRGB(255, 100, 100)
    TitleLabel.TextSize = 16
    TitleLabel.Font = Enum.Font.GothamBold
    TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
    TitleLabel.Text = "⚡ AUTO DODGE"
    TitleLabel.Parent = TitleBar
    
    -- Close Button
    local CloseBtn = Instance.new("TextButton")
    CloseBtn.Name = "CloseBtn"
    CloseBtn.Size = UDim2.new(0, 30, 0, 30)
    CloseBtn.Position = UDim2.new(1, -35, 0, 2)
    CloseBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
    CloseBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    CloseBtn.TextSize = 14
    CloseBtn.Font = Enum.Font.GothamBold
    CloseBtn.Text = "✕"
    CloseBtn.BorderSizePixel = 0
    CloseBtn.Parent = TitleBar
    
    CloseBtn.MouseButton1Click:Connect(function()
        MainFrame.Visible = false
        MenuOpen = false
    end)
    
    -- Content Frame
    local ContentFrame = Instance.new("Frame")
    ContentFrame.Name = "Content"
    ContentFrame.Size = UDim2.new(1, 0, 1, -35)
    ContentFrame.Position = UDim2.new(0, 0, 0, 35)
    ContentFrame.BackgroundTransparency = 1
    ContentFrame.Parent = MainFrame
    
    -- Status Label
    local StatusLabel = Instance.new("TextLabel")
    StatusLabel.Name = "StatusLabel"
    StatusLabel.Size = UDim2.new(1, -20, 0, 30)
    StatusLabel.Position = UDim2.new(0, 10, 0, 15)
    StatusLabel.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    StatusLabel.TextColor3 = Color3.fromRGB(100, 255, 100)
    StatusLabel.TextSize = 14
    StatusLabel.Font = Enum.Font.Gotham
    StatusLabel.BorderSizePixel = 0
    StatusLabel.Parent = ContentFrame
    
    local function updateStatus()
        StatusLabel.Text = "Status: " .. (DodgeEnabled and "✓ ON" or "✕ OFF")
        StatusLabel.TextColor3 = DodgeEnabled and Color3.fromRGB(100, 255, 100) or Color3.fromRGB(255, 100, 100)
    end
    updateStatus()
    
    -- Toggle Button
    local ToggleBtn = Instance.new("TextButton")
    ToggleBtn.Name = "ToggleBtn"
    ToggleBtn.Size = UDim2.new(1, -20, 0, 40)
    ToggleBtn.Position = UDim2.new(0, 10, 0, 60)
    ToggleBtn.BackgroundColor3 = Color3.fromRGB(50, 100, 200)
    ToggleBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    ToggleBtn.TextSize = 14
    ToggleBtn.Font = Enum.Font.GothamBold
    ToggleBtn.Text = "Toggle Dodge"
    ToggleBtn.BorderSizePixel = 0
    ToggleBtn.Parent = ContentFrame
    
    ToggleBtn.MouseButton1Click:Connect(function()
        DodgeEnabled = not DodgeEnabled
        updateStatus()
        notif("Dodge " .. (DodgeEnabled and "ON" or "OFF"), DodgeEnabled and "Tính năng né bật" or "Tính năng né tắt")
    end)
    
    -- Info Label
    local InfoLabel = Instance.new("TextLabel")
    InfoLabel.Name = "InfoLabel"
    InfoLabel.Size = UDim2.new(1, -20, 0, 50)
    InfoLabel.Position = UDim2.new(0, 10, 0, 110)
    InfoLabel.BackgroundTransparency = 1
    InfoLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
    InfoLabel.TextSize = 12
    InfoLabel.Font = Enum.Font.Gotham
    InfoLabel.TextWrapped = true
    InfoLabel.TextXAlignment = Enum.TextXAlignment.Left
    InfoLabel.TextYAlignment = Enum.TextYAlignment.Top
    InfoLabel.Text = "Press RightShift or V to toggle menu\n\nAuto Dodge activated!"
    InfoLabel.Parent = ContentFrame
    
    -- Drag Functionality
    local dragging = false
    local dragStart = nil
    local frameStart = nil
    
    TitleBar.InputBegan:Connect(function(input, gameProcessed)
        if gameProcessed then return end
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStart = input.Position
            frameStart = MainFrame.Position
        end
    end)
    
    UserInputService.InputChanged:Connect(function(input, gameProcessed)
        if dragging and input.UserInputType == Enum.UserInputType.Mouse then
            local delta = input.Position - dragStart
            MainFrame.Position = frameStart + UDim2.new(0, delta.X, 0, delta.Y)
        end
    end)
    
    UserInputService.InputEnded:Connect(function(input, gameProcessed)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
        end
    end)
    
    return ScreenGui
end

-- ==================== INPUT HANDLING ====================
local function toggleMenu()
    if not ScreenGui then
        ScreenGui = createMenu()
    end
    MenuOpen = not MenuOpen
    ScreenGui.Enabled = MenuOpen
end

UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    
    if input.KeyCode == CONFIG.TOGGLE_KEY or input.KeyCode == Enum.KeyCode.V then
        toggleMenu()
    end
end)

-- ==================== INITIALIZATION ====================
ScreenGui = createMenu()
ScreenGui.Enabled = false
MenuOpen = false

notif("✓ Auto Dodge Loaded", "Nhấn RightShift hoặc V để mở Menu")

-- ==================== CLEANUP ====================
local function cleanup()
    for _, conn in pairs(Connections) do
        if conn then
            conn:Disconnect()
        end
    end
    
    if ScreenGui then
        ScreenGui:Destroy()
    end
    
    DodgeEnabled = false
end

Client.CharacterAdded:Connect(function(newChar)
    Character = newChar
    Humanoid = Character:WaitForChild("Humanoid")
    HumanoidRootPart = Character:WaitForChild("HumanoidRootPart")
end)

game:BindToClose(cleanup)
