--// Created By CDHW/Kohrynth
--// Untitled Boxing Game | Auto Dodge - Correct Direction Detection

local player = game.Players.LocalPlayer
local RS = game.RunService
local ReplicatedStorage = game.ReplicatedStorage

local lastPerfect

if getgenv().dodge then
    getgenv().dodge:Disconnect()
end

if getgenv().dodgeChar then
    getgenv().dodgeChar:Disconnect()
end

local function getState()
    local states = game.Workspace:FindFirstChild("States")

    if not states then
        return
    end

    return states:FindFirstChild(player.Name)
end

local function getOpponent()
    local state = getState()

    if not state then
        return
    end

    local occupied = state:FindFirstChild("Occupied")

    if not occupied then
        return
    end

    local locked = occupied:FindFirstChild("LockedOn")

    if locked then
        return locked.Value
    end
end

local function dashing()
    local state = getState()

    if not state then
        return false
    end

    local occupied = state:FindFirstChild("Occupied")

    if not occupied then
        return false
    end

    local dash = occupied:FindFirstChild("Dashing")

    if dash then
        return dash.Value
    end

    return false
end

--// Kiểm tra opponent có highlight (sắp tấn công)
local function isOpponentHighlighted()
    local opponent = getOpponent()
    
    if not opponent then
        return false
    end
    
    -- Kiểm tra highlight attribute (khi opponent sắp punch)
    local highlight = opponent:GetAttribute("Highlight")
    if highlight ~= nil and highlight ~= false then
        return true
    end
    
    -- Hoặc kiểm tra IsAttacking
    if opponent:GetAttribute("IsAttacking") == true then
        return true
    end
    
    -- Hoặc IsCharging (M2 heavy)
    if opponent:GetAttribute("IsCharging") == true then
        return true
    end
    
    return false
end

local function dodge()
    local character = player.Character

    if not character then
        return
    end

    local perfect = character:GetAttribute("Perfect")

    if perfect == nil or perfect == lastPerfect then
        return
    end

    --// Lấy hướng cần dodge từ game (NeededDirection)
    local direction = character:GetAttribute("NeededDirection")

    if direction ~= "Left" and direction ~= "Right" and direction ~= "Backward" and direction ~= "Forward" then
        return
    end

    local opponent = getOpponent()

    if not opponent then
        return
    end

    --// Bỏ qua nếu opponent feinting
    if opponent:GetAttribute("IsFeinting") == true or opponent:GetAttribute("LocalIsFeinting") == true then
        return
    end

    --// ✅ QUAN TRỌNG: Chỉ dodge khi opponent highlight (sắp punch)
    if not isOpponentHighlighted() then
        return
    end

    local root = character:FindFirstChild("HumanoidRootPart")
    local eroot = opponent:FindFirstChild("HumanoidRootPart")

    if root and eroot then
        if (root.Position - eroot.Position).Magnitude > 7 then
            return
        end
    end

    if dashing() then
        return
    end

    local events = ReplicatedStorage:FindFirstChild("Events")
    local dash = events and events:FindFirstChild("ForceDash")

    if not dash then
        return
    end

    lastPerfect = perfect

    --// Dodge theo NeededDirection (đúng hướng)
    dash:Fire({Direction = direction})

    RS.Heartbeat:Once(function()
        if player.Character == character and character:GetAttribute("Perfect") == perfect and not dashing() then
            dash:Fire({Direction = direction})
        end
    end)

    RS.Heartbeat:Once(function()
        if player.Character == character and character:GetAttribute("Perfect") == perfect and not dashing() then
            dash:Fire({Direction = direction})
        end
    end)
end

getgenv().dodge = RS.Heartbeat:Connect(function()
    if not player.Character then
        return
    end

    dodge()
end)

getgenv().dodgeChar = player.CharacterAdded:Connect(function()
    lastPerfect = nil
end)
