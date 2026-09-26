
-- ========================================================
-- PHẦN 1: MÃ BYPASS ANTI-CHEAT (ĐẶT TRÊN ĐẦU)
-- ========================================================
local plr = game:GetService("Players").LocalPlayer
local cclosure = syn_newcclosure or newcclosure or nil

if cclosure and hookmetamethod then
    local oldNamecall
    oldNamecall = hookmetamethod(game, "__namecall", cclosure(function(self, ...)
        local NamecallMethod = getnamecallmethod()
        if (NamecallMethod == "Kick" or NamecallMethod == "kick") and not checkcaller() then
            if self == plr then return oldNamecall(self, ...) end
            return
        end
        return oldNamecall(self, ...)
    end))
end

Bypass = true
local GameMT = getrawmetatable(game)
if GameMT and Bypass then
    setreadonly(GameMT, false)
    local OldNamecallFunc = GameMT.__namecall
    GameMT.__namecall = newcclosure(function(self, ...)
        local NamecallArgs = {...}
        local DETECTION_STRINGS = {'CHECKER_1','CHECKER','OneMoreTime','checkingSPEED','PERMAIDBAN','BANREMOTE','FORCEFIELD','TeleportDetect'}
        
        if (table.find(DETECTION_STRINGS, NamecallArgs[1]) and getnamecallmethod() == 'FireServer') then
            return;
        end;
        return OldNamecallFunc(self, ...)
    end)
end

-- ========================================================
-- PHẦN 2: SCRIPT AUTO DODGE CỦA BẠN (ĐẶT PHÍA DƯỚI)
-- ========================================================
local CONFIG = {
    TOGGLE_KEY = Enum.KeyCode.RightShift,
    MENU_SIZE = UDim2.new(0, 300, 0, 200),
    MENU_POSITION = UDim2.new(0, 20, 0, 20),
}

local UserInputService = game:GetService("UserInputService")
local Players = game:GetService("Players")
local Client = Players.LocalPlayer
local Character = Client.Character or Client.CharacterAdded:Wait()
local States = workspace:WaitForChild("States")
local Effect = require(game:GetService("ReplicatedStorage").Modules.EffectHelper)
local VIM = game:GetService("VirtualInputManager")

local DodgeEnabled = true
local MenuOpen = false
local ScreenGui = nil
local shared_BaseEffectFunction = {}

local function set_thread_identity(level)
    if setthreadcontext then setthreadcontext(level)
    elseif set_thread_identity then set_thread_identity(level) end
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
    game:GetService("StarterGui"):SetCore("SendNotification", {Title = title, Text = text, Duration = 3})
end

local function dash() hold(32, 0.1) end

local waiting = {}
local function waitValid(name, func)
    if not waiting[name] then waiting[name] = {} end
    table.insert(waiting[name], func)
end

local function valid(name, ...)
    if waiting[name] then
        for i = 1, #waiting[name] do task.spawn(waiting[name][i], ...) end
        waiting[name] = nil
    end
end

for i, v in pairs(Effect) do
    shared_BaseEffectFunction[i] = shared_BaseEffectFunction[i] or v
    Effect[i] = function(d, ...)
        task.spawn(function()
            if not DodgeEnabled then return end
            if type(d) == "table" and typeof(d[2]) == "Instance" then
                local Distance = Client:DistanceFromCharacter(Character:FindFirstChild("HumanoidRootPart") and Character.HumanoidRootPart.Position or Vector3.new(0,0,0))
                if get(Client, "Blocking") or not get(Client, "Equipped") or get(Client, "Punching") then return end
                if Distance > 10.8 then return end
                
                if (d[1] == "AttackTrail" or d[1] == "StartupHighlight" or d[1] == "UltimateHighlight") and d[2] ~= Client.Character and type(d[5]) == 'number' then
                    waitValid(d[2].Name, function(LightAttack)
                        local delay = d[5] * Random.new():NextNumber(0.4, 0.6)
                        task.wait(delay)
                        coroutine.wrap(dash)()
                        notif("✓ Dodged!", "Chính xác!")
                    end)
                end
                if d[1] == "StartupHighlight" then valid(d[2].Name, not (d[3] or d[4] or d[5])) end
            end
        end)
        return shared_BaseEffectFunction[i](d, ...)
    end
end

local function createMenu()
    if ScreenGui then return ScreenGui end
    local PlayerGui = Client:WaitForChild("PlayerGui")
    ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "AutoDodgeMenu"
    ScreenGui.ResetOnSpawn = false
    ScreenGui.Parent = PlayerGui
    
    local MainFrame = Instance.new("Frame")
    MainFrame.Size = CONFIG.MENU_SIZE
    MainFrame.Position = CONFIG.MENU_POSITION
    MainFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    MainFrame.BorderSizePixel = 0
    MainFrame.Parent = ScreenGui
    
    local TitleBar = Instance.new("Frame")
    TitleBar.Size = UDim2.new(1, 0, 0, 35)
    TitleBar.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
    TitleBar.Parent = MainFrame
    
    local TitleLabel = Instance.new("TextLabel")
    TitleLabel.Size = UDim2.new(0.7, 0, 1, 0)
    TitleLabel.Position = UDim2.new(0, 10, 0, 0)
    TitleLabel.BackgroundTransparency = 1
    TitleLabel.TextColor3 = Color3.fromRGB(255, 100, 100)
    TitleLabel.Text = "⚡ AUTO DODGE"
    TitleLabel.Parent = TitleBar
    
    local CloseBtn = Instance.new("TextButton")
    CloseBtn.Size = UDim2.new(0, 30, 0, 30)
    CloseBtn.Position = UDim2.new(1, -35, 0, 2)
    CloseBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
    CloseBtn.Text = "✕"
    CloseBtn.Parent = TitleBar
    CloseBtn.MouseButton1Click:Connect(function() MainFrame.Visible = false MenuOpen = false end)
    
    local ContentFrame = Instance.new("Frame")
    ContentFrame.Size = UDim2.new(1, 0, 1, -35)
    ContentFrame.Position = UDim2.new(0, 0, 0, 35)
    ContentFrame.BackgroundTransparency = 1
    ContentFrame.Parent = MainFrame
    
    local StatusLabel = Instance.new("TextLabel")
    StatusLabel.Size = UDim2.new(1, -20, 0, 30)
    StatusLabel.Position = UDim2.new(0, 10, 0, 15)
    StatusLabel.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    StatusLabel.Parent = ContentFrame
    
    local function updateStatus()
        StatusLabel.Text = "Status: " .. (DodgeEnabled and "✓ ON" or "✕ OFF")
        StatusLabel.TextColor3 = DodgeEnabled and Color3.fromRGB(100, 255, 100) or Color3.fromRGB(255, 100, 100)
    end
    updateStatus()
    
    local ToggleBtn = Instance.new("TextButton")
    ToggleBtn.Size = UDim2.new(1, -20, 0, 40)
    ToggleBtn.Position = UDim2.new(0, 10, 0, 60)
    ToggleBtn.BackgroundColor3 = Color3.fromRGB(50, 100, 200)
    ToggleBtn.Text = "Toggle Dodge"
    ToggleBtn.Parent = ContentFrame
    ToggleBtn.MouseButton1Click:Connect(function() DodgeEnabled = not DodgeEnabled updateStatus() end)
    
    return ScreenGui
end

UserInputService.InputBegan:Connect(function(input, gpe)
    if gpe then return end
    if input.KeyCode == CONFIG.TOGGLE_KEY or input.KeyCode == Enum.KeyCode.V then
        if not ScreenGui then ScreenGui = createMenu() end
        MenuOpen = not MenuOpen
        ScreenGui.Enabled = MenuOpen
    end
end)

ScreenGui = createMenu()
ScreenGui.Enabled = false
notif("✓ Auto Dodge Loaded", "Nhấn RightShift hoặc V để mở Menu")
