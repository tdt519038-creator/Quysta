-- ============================================
-- SIMPLE AUTO DODGE MENU
-- ============================================
-- Detects: BridgeNet2.dataRemoteEvent dodge commands
-- Toggle: V key
-- ============================================

warn("!Started Simple Auto Dodge!")

-- ============================================
-- CONFIG
-- ============================================
local CONFIG = {
    TOGGLE_KEY = Enum.KeyCode.V,
    MENU_WIDTH = 280,
    MENU_HEIGHT = 180,
}

-- ============================================
-- SETUP
-- ============================================
local Enabled = true
local MenuOpen = true

local BridgeNet2 = game:GetService("ReplicatedStorage").BridgeNet2
local dataRemoteEvent = BridgeNet2.dataRemoteEvent
local UserInputService = game:GetService("UserInputService")

-- ============================================
-- DODGE FUNCTIONS
-- ============================================

-- Dodge Right
local function dodgeRight()
    local args = {
        [1] = {
            [1] = {
                [1] = {
                    [1] = Vector3.new(0.2535948157310486, -4.6824536130798174e-15, -0.9673105478286743),
                    [2] = "Right",
                    [3] = 0.23700376828491904,
                },
                [5] = false,
                [6] = false,
                [7] = Vector3.new(0.2535948157310486, -4.6824536130798174e-15, -0.9673105478286743),
                [9] = tick(),
            },
            [2] = "!",
        },
    }
    dataRemoteEvent:FireServer(table.unpack(args))
end

-- Dodge Left
local function dodgeLeft()
    local args = {
        [1] = {
            [1] = {
                [1] = {
                    [1] = Vector3.new(-0.6644957661628723, -2.235049574887335e-14, -0.747292160987854),
                    [2] = "Left",
                    [3] = 0.2316696966206694,
                },
                [5] = false,
                [6] = false,
                [7] = Vector3.new(-0.6644957661628723, -2.235049574887335e-14, -0.747292160987854),
                [9] = tick(),
            },
            [2] = "!",
        },
    }
    dataRemoteEvent:FireServer(table.unpack(args))
end

-- Notification
local function notif(title, text)
    game:GetService("StarterGui"):SetCore("SendNotification", {
        Title = title,
        Text = text,
        Duration = 2
    })
end

-- ============================================
-- HOOK BRIDGE NET 2 EVENT
-- ============================================

local originalFire = dataRemoteEvent.FireServer

dataRemoteEvent.FireServer = function(self, args)
    task.spawn(function()
        if not Enabled then
            return originalFire(self, args)
        end
        
        -- Check if this is a dodge attack from enemy
        if type(args) == "table" and args[1] then
            local data = args[1]
            if type(data) == "table" and data[1] then
                local attackData = data[1]
                if type(attackData) == "table" and attackData[1] then
                    local directionData = attackData[1]
                    if type(directionData) == "table" then
                        local direction = directionData[2]
                        
                        -- Detect enemy attack direction
                        if direction == "Right" then
                            task.wait(0.1) -- Small delay
                            dodgeLeft() -- Dodge opposite direction
                            notif("Auto Dodge", "← Dodged Right Attack!")
                            return
                        elseif direction == "Left" then
                            task.wait(0.1) -- Small delay
                            dodgeRight() -- Dodge opposite direction
                            notif("Auto Dodge", "→ Dodged Left Attack!")
                            return
                        end
                    end
                end
            end
        end
    end)
    return originalFire(self, args)
end

-- ============================================
-- UI MENU
-- ============================================

-- Remove duplicate menu
if game.Players.LocalPlayer:FindFirstChild("SimpleDodgeGui") then
    game.Players.LocalPlayer:FindFirstChild("SimpleDodgeGui"):Destroy()
end

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "SimpleDodgeGui"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = game.Players.LocalPlayer:WaitForChild("PlayerGui")

-- Main Frame
local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(0, CONFIG.MENU_WIDTH, 0, CONFIG.MENU_HEIGHT)
MainFrame.Position = UDim2.new(0.02, 0, 0.5, -CONFIG.MENU_HEIGHT/2)
MainFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
MainFrame.BorderColor3 = Color3.fromRGB(200, 80, 80)
MainFrame.BorderSizePixel = 2
MainFrame.Parent = ScreenGui

-- Title
local Title = Instance.new("TextLabel")
Title.Name = "Title"
Title.Size = UDim2.new(1, 0, 0, 35)
Title.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
Title.BorderSizePixel = 0
Title.TextColor3 = Color3.fromRGB(200, 80, 80)
Title.TextScaled = true
Title.Font = Enum.Font.GothamBold
Title.Text = "⚔️ AUTO DODGE"
Title.Parent = MainFrame

-- Close Button
local CloseBtn = Instance.new("TextButton")
CloseBtn.Name = "CloseBtn"
CloseBtn.Size = UDim2.new(0, 25, 0, 25)
CloseBtn.Position = UDim2.new(1, -30, 0, 5)
CloseBtn.BackgroundColor3 = Color3.fromRGB(200, 60, 60)
CloseBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
CloseBtn.TextScaled = true
CloseBtn.Font = Enum.Font.GothamBold
CloseBtn.Text = "✕"
CloseBtn.Parent = Title

-- Status Label
local StatusLabel = Instance.new("TextLabel")
StatusLabel.Name = "StatusLabel"
StatusLabel.Size = UDim2.new(1, -15, 0, 35)
StatusLabel.Position = UDim2.new(0, 8, 0, 40)
StatusLabel.BackgroundColor3 = Color3.fromRGB(35, 35, 45)
StatusLabel.BorderColor3 = Color3.fromRGB(100, 100, 120)
StatusLabel.BorderSizePixel = 1
StatusLabel.TextColor3 = Color3.fromRGB(100, 255, 100)
StatusLabel.TextScaled = true
StatusLabel.Font = Enum.Font.Gotham
StatusLabel.TextXAlignment = Enum.TextXAlignment.Left
StatusLabel.Text = " ✅ ACTIVE"
StatusLabel.Parent = MainFrame

-- Toggle Button
local ToggleBtn = Instance.new("TextButton")
ToggleBtn.Name = "ToggleBtn"
ToggleBtn.Size = UDim2.new(1, -15, 0, 35)
ToggleBtn.Position = UDim2.new(0, 8, 0, 80)
ToggleBtn.BackgroundColor3 = Color3.fromRGB(50, 150, 50)
ToggleBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
ToggleBtn.TextScaled = true
ToggleBtn.Font = Enum.Font.GothamBold
ToggleBtn.Text = "🟢 TOGGLE DODGE"
ToggleBtn.Parent = MainFrame

-- Info Label
local InfoLabel = Instance.new("TextLabel")
InfoLabel.Name = "InfoLabel"
InfoLabel.Size = UDim2.new(1, -15, 0, 25)
InfoLabel.Position = UDim2.new(0, 8, 1, -30)
InfoLabel.BackgroundColor3 = Color3.fromRGB(35, 35, 45)
InfoLabel.BorderSizePixel = 0
InfoLabel.TextColor3 = Color3.fromRGB(150, 150, 180)
InfoLabel.TextScaled = true
InfoLabel.Font = Enum.Font.Gotham
InfoLabel.Text = "Press V to toggle"
InfoLabel.Parent = MainFrame

-- ============================================
-- MENU FUNCTIONS
-- ============================================

local function updateStatus()
    if Enabled then
        StatusLabel.Text = " ✅ ACTIVE"
        StatusLabel.TextColor3 = Color3.fromRGB(100, 255, 100)
        ToggleBtn.Text = "🟢 TOGGLE DODGE"
        ToggleBtn.BackgroundColor3 = Color3.fromRGB(50, 150, 50)
    else
        StatusLabel.Text = " ❌ INACTIVE"
        StatusLabel.TextColor3 = Color3.fromRGB(255, 100, 100)
        ToggleBtn.Text = "🔴 TOGGLE DODGE"
        ToggleBtn.BackgroundColor3 = Color3.fromRGB(150, 50, 50)
    end
end

local function toggleDodge()
    Enabled = not Enabled
    updateStatus()
    notif("Auto Dodge", Enabled and "✅ Enabled" or "❌ Disabled")
end

local function toggleMenu()
    MenuOpen = not MenuOpen
    MainFrame.Visible = MenuOpen
end

-- ============================================
-- EVENTS
-- ============================================

CloseBtn.MouseButton1Click:Connect(toggleMenu)
ToggleBtn.MouseButton1Click:Connect(toggleDodge)

-- Keyboard
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    if input.KeyCode == CONFIG.TOGGLE_KEY then
        toggleMenu()
    end
end)

-- Drag
local dragging = false
local dragStart = nil
local frameStart = nil

Title.InputBegan:Connect(function(input, gameProcessed)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = true
        dragStart = input.Position
        frameStart = MainFrame.Position
    end
end)

Title.InputEnded:Connect(function(input, gameProcessed)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = false
    end
end)

UserInputService.InputChanged:Connect(function(input, gameProcessed)
    if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
        local delta = input.Position - dragStart
        MainFrame.Position = frameStart + UDim2.new(0, delta.X, 0, delta.Y)
    end
end)

-- ============================================
-- INIT
-- ============================================

updateStatus()
notif("Auto Dodge", "✅ Loaded! Press V to toggle")

print("✅ SimpleDodgeMenu loaded successfully!")
print("📌 Shortcut: V")
print("🎮 Status: ACTIVE")
