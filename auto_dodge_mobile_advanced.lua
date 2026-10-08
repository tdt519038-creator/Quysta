--// Created By CDHW/Kohrynth - Mobile Advanced + Attack Detection
--// Untitled Boxing Game | Smart Auto Dodge (Mobile Edition)

local player = game.Players.LocalPlayer
local RS = game.RunService
local ReplicatedStorage = game.ReplicatedStorage

local lastPerfect
local lastDodgeTime = 0
local lastAttackDetected = 0

-- Config
local LEGIT_MODE = true
local LIGHT_CHANCE = 0.3
local HEAVY_CHANCE = 0.75
local MIN_DODGE_INTERVAL = 0.1
local PREDICT_DODGE = true -- Enable attack prediction

-- Cleanup
if getgenv().dodge then
    getgenv().dodge:Disconnect()
end
if getgenv().dodgeChar then
    getgenv().dodgeChar:Disconnect()
end
if getgenv().effectHook then
    getgenv().effectHook:Disconnect()
end

local function getState()
    local states = game.Workspace:FindFirstChild("States")
    return states and states:FindFirstChild(player.Name)
end

local function getOpponent()
    local state = getState()
    if not state then return end
    
    local occupied = state:FindFirstChild("Occupied")
    if not occupied then return end
    
    local locked = occupied:FindFirstChild("LockedOn")
    return locked and locked.Value
end

local function isDashing()
    local state = getState()
    if not state then return false end
    
    local occupied = state:FindFirstChild("Occupied")
    if not occupied then return false end
    
    local dash = occupied:FindFirstChild("Dashing")
    return dash and dash.Value or false
end

-- Predict dodge direction based on opponent position
local function predictDodgeDirection()
    local character = player.Character
    if not character then return end
    
    local opponent = getOpponent()
    if not opponent then return end
    
    local root = character:FindFirstChild("HumanoidRootPart")
    local eroot = opponent:FindFirstChild("HumanoidRootPart")
    
    if not (root and eroot) then return end
    
    -- Calculate relative position
    local toOpponent = (eroot.Position - root.Position)
    local dotLeft = toOpponent:Dot(root.CFrame.RightVector)
    local dotBack = toOpponent:Dot(-root.CFrame.LookVector)
    
    -- Pick direction based on opponent position
    if math.abs(dotLeft) > math.abs(dotBack) then
        return dotLeft > 0 and "Right" or "Left"
    else
        return dotBack > 0 and "Backward" or "Forward"
    end
end

-- Random delay: 40-80ms
local function getReactionDelay()
    if LEGIT_MODE then
        return (40 + math.random(40)) / 1000
    end
    return 0.05
end

-- Legit mode: random chance skip
local function shouldDodge()
    if not LEGIT_MODE then
        return true
    end
    
    local roll = math.random()
    return roll < HEAVY_CHANCE
end

-- Core dodge function
local function performDodge(overrideDirection)
    local character = player.Character
    if not character then return end

    local perfect = character:GetAttribute("Perfect")
    if perfect == nil or perfect == lastPerfect then
        return
    end

    -- Cooldown check
    local currentTime = tick()
    if (currentTime - lastDodgeTime) < MIN_DODGE_INTERVAL then
        return
    end

    -- Get direction: override > attribute > predict
    local direction = overrideDirection or character:GetAttribute("NeededDirection")
    
    if not direction and PREDICT_DODGE then
        direction = predictDodgeDirection()
    end
    
    if not (direction == "Left" or direction == "Right" or direction == "Backward" or direction == "Forward") then
        return
    end

    local opponent = getOpponent()
    if not opponent then return end

    -- State validation
    if opponent:GetAttribute("IsFeinting") or opponent:GetAttribute("LocalIsFeinting") then
        return
    end

    -- Distance check (7 studs)
    local root = character:FindFirstChild("HumanoidRootPart")
    local eroot = opponent:FindFirstChild("HumanoidRootPart")
    if root and eroot then
        if (root.Position - eroot.Position).Magnitude > 7 then
            return
        end
    end

    if isDashing() then
        return
    end

    -- Legit check
    if not shouldDodge() then
        return
    end

    local events = ReplicatedStorage:FindFirstChild("Events")
    local dash = events and events:FindFirstChild("ForceDash")
    if not dash then return end

    lastPerfect = perfect
    lastDodgeTime = currentTime

    -- Main dodge
    dash:Fire({Direction = direction})

    -- Delayed second fire
    local delay = getReactionDelay()
    RS.Heartbeat:Once(function()
        task.wait(delay)
        if player.Character == character and character:GetAttribute("Perfect") == perfect and not isDashing() then
            dash:Fire({Direction = direction})
        end
    end)
end

-- EFFECT HOOK (từ script 2) - Detect attack incoming
local function hookEffectSystem()
    local Effect = ReplicatedStorage:FindFirstChild("Modules") and ReplicatedStorage.Modules:FindFirstChild("EffectHelper")
    
    if not Effect then
        warn("⚠ EffectHelper not found - prediction mode disabled")
        return
    end

    local shared_BaseEffectFunction = shared.BaseEffectFunction or {}
    
    for i, v in pairs(Effect) do
        shared_BaseEffectFunction[i] = shared_BaseEffectFunction[i] or v
        
        Effect[i] = function(d, ...)
            -- d[1] = effect type
            -- d[2] = character/target
            
            if not d[1] then
                return shared_BaseEffectFunction[i](d, ...)
            end

            -- Detect attack incoming
            if d[1] == "AttackTrail" or d[1] == "StartupHighlight" or d[1] == "UltimateHighlight" then
                local targetChar = d[2]
                
                -- Nếu attack aimed at us
                if targetChar and targetChar.Name == player.Name then
                    lastAttackDetected = tick()
                    
                    -- Predictive dodge
                    if PREDICT_DODGE then
                        local predictedDir = predictDodgeDirection()
                        if predictedDir then
                            task.spawn(function()
                                task.wait(0.02) -- 20ms delay trước khi dodge
                                performDodge(predictedDir)
                            end)
                        end
                    end
                end
            end

            return shared_BaseEffectFunction[i](d, ...)
        end
    end
    
    shared.BaseEffectFunction = shared_BaseEffectFunction
    print("✓ Effect hook installed - attack detection active")
end

-- Main dodge loop (passive dodge when NeededDirection available)
getgenv().dodge = RS.Heartbeat:Connect(function()
    if player.Character then
        performDodge()
    end
end)

-- Reset on respawn
getgenv().dodgeChar = player.CharacterAdded:Connect(function()
    lastPerfect = nil
    lastDodgeTime = 0
    lastAttackDetected = 0
end)

-- Initialize effect hook
task.wait(0.5) -- Đợi game load xong
hookEffectSystem()

print("✓ Auto Dodge Mobile Advanced v3 loaded")
print("✓ LEGIT_MODE:", LEGIT_MODE)
print("✓ PREDICT_DODGE:", PREDICT_DODGE)
print("✓ Attack detection + direction prediction enabled")
