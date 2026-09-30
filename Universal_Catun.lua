--[[
    UNIVERSAL CATUN SCRIPT v2.0
    Hoạt động trên tất cả các game
    - Máu nhân X (slider 1-600)
    - Sát thương nhân X (slider 1-600)
    - Auto-ghim hoạt động
]]

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")

local LocalPlayer = Players.LocalPlayer
local GUI_NAME = "UniversalCatun"

-- ==================== DỌN BẢN CŨ ====================
local genv = (getgenv and getgenv()) or _G
if genv.__UNIVERSAL_CLEANUP then
    pcall(genv.__UNIVERSAL_CLEANUP)
end

-- ==================== BIẾN TOÀN CỤC ====================
local healthMult = 1
local damageMult = 1
local autoAimActive = false
local currentTarget = nil
local isMenuVisible = false

-- ==================== AUTO-AIM ====================
local function startAutoAim()
    autoAimActive = true
    
    RunService.RenderStepped:Connect(function()
        if not autoAimActive then return end
        
        local char = LocalPlayer.Character
        if not char or not char:FindFirstChild("HumanoidRootPart") then return end
        
        local playerPos = char.HumanoidRootPart.Position
        local camera = workspace.CurrentCamera
        local maxRange = 150
        
        -- Kiểm tra target hiện tại
        if currentTarget and currentTarget.Parent then
            local targetHum = currentTarget.Parent:FindFirstChild("Humanoid")
            if targetHum and targetHum.Health <= 0 then
                currentTarget = nil
            end
        else
            currentTarget = nil
        end
        
        -- Tìm target gần nhất
        local nearest = currentTarget
        local nearestDist = currentTarget and (currentTarget.Position - playerPos).Magnitude or maxRange
        
        for _, enemy in ipairs(Workspace:GetDescendants()) do
            if enemy:IsA("Model") and enemy ~= char and enemy:FindFirstChild("Humanoid") then
                local humanoid = enemy.Humanoid
                local rootPart = enemy:FindFirstChild("HumanoidRootPart") or enemy:FindFirstChild("Head")
                
                if humanoid and rootPart and humanoid.Health > 0 then
                    local dist = (rootPart.Position - playerPos).Magnitude
                    
                    if dist < nearestDist and dist < maxRange then
                        nearest = rootPart
                        nearestDist = dist
                    end
                end
            end
        end
        
        currentTarget = nearest
    end)
end

-- ==================== HEALTH MULTIPLIER ====================
local function updateHealth()
    RunService.Heartbeat:Connect(function()
        local char = LocalPlayer.Character
        if not char then return end
        
        local humanoid = char:FindFirstChild("Humanoid")
        if humanoid then
            local maxHP = 100 * healthMult
            humanoid.MaxHealth = maxHP
            
            if humanoid.Health <= 0 then
                humanoid.Health = maxHP
            elseif humanoid.Health < maxHP then
                humanoid.Health = maxHP
            end
        end
    end)
end

-- ==================== DAMAGE MULTIPLIER ====================
local function updateDamage()
    RunService.Heartbeat:Connect(function()
        if damageMult == 1 then return end
        
        local char = LocalPlayer.Character
        if not char then return end
        
        for _, tool in ipairs(char:GetChildren()) do
            if tool:IsA("Tool") then
                pcall(function()
                    -- Tìm trong tool
                    if tool:FindFirstChild("Damage") and tool.Damage:IsA("IntValue") then
                        tool.Damage.Value = math.floor(10 * damageMult)
                    end
                    
                    -- Tìm trong Config
                    if tool:FindFirstChild("Config") then
                        local config = tool.Config
                        if config:FindFirstChild("Damage") and config.Damage:IsA("IntValue") then
                            config.Damage.Value = math.floor(10 * damageMult)
                        end
                    end
                    
                    -- Hook Activated event
                    if not tool:GetAttribute("DamageHooked") then
                        tool.Activated:Connect(function()
                            task.wait(0.01)
                            if tool:FindFirstChild("Damage") and tool.Damage:IsA("IntValue") then
                                tool.Damage.Value = math.floor(10 * damageMult)
                            end
                        end)
                        tool:SetAttribute("DamageHooked", true)
                    end
                end)
            end
        end
    end)
end

-- ==================== GIAO DIỆN ====================
local function round(inst, r)
    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(0, r)
    c.Parent = inst
end

local function makeGui()
    local gui = Instance.new("ScreenGui")
    gui.Name = GUI_NAME
    gui.ResetOnSpawn = false
    gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    gui.DisplayOrder = 999

    local done = false
    if gethui then
        done = pcall(function() gui.Parent = gethui() end) and gui.Parent ~= nil
    end
    if not done then
        done = pcall(function() gui.Parent = game:GetService("CoreGui") end) and gui.Parent ~= nil
    end
    if not done then
        gui.Parent = LocalPlayer:WaitForChild("PlayerGui")
    end

    return gui
end

local function buildUI()
    local gui = makeGui()

    -- NÚT CHẤM NHỎ
    local dotBtn = Instance.new("TextButton")
    dotBtn.Name = "DotButton"
    dotBtn.Size = UDim2.new(0, 40, 0, 40)
    dotBtn.Position = UDim2.new(0, 15, 0.3, 0)
    dotBtn.BackgroundColor3 = Color3.fromRGB(128, 0, 255)
    dotBtn.Text = "•"
    dotBtn.TextSize = 32
    dotBtn.TextColor3 = Color3.new(1, 1, 1)
    dotBtn.Font = Enum.Font.GothamBold
    dotBtn.AutoButtonColor = false
    dotBtn.BorderSizePixel = 0
    dotBtn.ZIndex = 100
    dotBtn.Parent = gui
    round(dotBtn, 20)

    -- BẢNG CHÍNH
    local panel = Instance.new("Frame")
    panel.Name = "MainPanel"
    panel.AnchorPoint = Vector2.new(0.5, 0.5)
    panel.Position = UDim2.new(0.5, 0, 0.5, 0)
    panel.Size = UDim2.new(0.8, 0, 0.75, 0)
    panel.BackgroundColor3 = Color3.fromRGB(28, 28, 38)
    panel.BorderSizePixel = 0
    panel.Visible = false
    panel.ZIndex = 50
    panel.Parent = gui
    round(panel, 16)

    local sizeLimit = Instance.new("UISizeConstraint")
    sizeLimit.MaxSize = Vector2.new(400, 550)
    sizeLimit.Parent = panel

    -- THANH TIÊU ĐỀ
    local header = Instance.new("Frame")
    header.Size = UDim2.new(1, 0, 0, 50)
    header.BackgroundColor3 = Color3.fromRGB(128, 0, 255)
    header.BorderSizePixel = 0
    header.ZIndex = 51
    header.Parent = panel
    round(header, 16)

    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1, -50, 1, 0)
    title.Position = UDim2.new(0, 15, 0, 0)
    title.BackgroundTransparency = 1
    title.Text = "🎯 CATUN MENU"
    title.TextColor3 = Color3.new(1, 1, 1)
    title.TextSize = 20
    title.Font = Enum.Font.GothamBold
    title.TextXAlignment = Enum.TextXAlignment.Left
    title.ZIndex = 52
    title.Parent = header

    local closeBtn = Instance.new("TextButton")
    closeBtn.Size = UDim2.new(0, 36, 0, 36)
    closeBtn.Position = UDim2.new(1, -42, 0, 7)
    closeBtn.BackgroundColor3 = Color3.fromRGB(200, 40, 40)
    closeBtn.Text = "✕"
    closeBtn.TextColor3 = Color3.new(1, 1, 1)
    closeBtn.TextSize = 18
    closeBtn.Font = Enum.Font.GothamBold
    closeBtn.BorderSizePixel = 0
    closeBtn.ZIndex = 53
    closeBtn.Parent = header
    round(closeBtn, 8)

    closeBtn.MouseButton1Click:Connect(function()
        panel.Visible = false
        isMenuVisible = false
    end)

    -- CONTAINER MAIN
    local container = Instance.new("Frame")
    container.Size = UDim2.new(1, -20, 1, -70)
    container.Position = UDim2.new(0, 10, 0, 60)
    container.BackgroundTransparency = 1
    container.ZIndex = 51
    container.Parent = panel

    local listLayout = Instance.new("UIListLayout")
    listLayout.Padding = UDim.new(0, 15)
    listLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
    listLayout.Parent = container

    -- ==================== AUTO-AIM TOGGLE ====================
    local autoaimFrame = Instance.new("Frame")
    autoaimFrame.Size = UDim2.new(0, 360, 0, 45)
    autoaimFrame.BackgroundColor3 = Color3.fromRGB(45, 45, 58)
    autoaimFrame.BorderSizePixel = 0
    autoaimFrame.ZIndex = 52
    autoaimFrame.Parent = container
    round(autoaimFrame, 8)

    local autoaimLabel = Instance.new("TextLabel")
    autoaimLabel.Size = UDim2.new(0, 280, 1, 0)
    autoaimLabel.BackgroundTransparency = 1
    autoaimLabel.Text = "🎯 Auto-Ghim Quái"
    autoaimLabel.TextColor3 = Color3.new(1, 1, 1)
    autoaimLabel.TextSize = 14
    autoaimLabel.Font = Enum.Font.GothamBold
    autoaimLabel.TextXAlignment = Enum.TextXAlignment.Left
    autoaimLabel.ZIndex = 53
    autoaimLabel.Parent = autoaimFrame

    local autoaimToggle = Instance.new("TextButton")
    autoaimToggle.Size = UDim2.new(0, 60, 0, 32)
    autoaimToggle.Position = UDim2.new(1, -65, 0.5, -16)
    autoaimToggle.BackgroundColor3 = Color3.fromRGB(120, 50, 50)
    autoaimToggle.Text = "TẮT"
    autoaimToggle.TextColor3 = Color3.new(1, 1, 1)
    autoaimToggle.TextSize = 12
    autoaimToggle.Font = Enum.Font.GothamBold
    autoaimToggle.BorderSizePixel = 0
    autoaimToggle.ZIndex = 53
    autoaimToggle.Parent = autoaimFrame
    round(autoaimToggle, 6)

    autoaimToggle.MouseButton1Click:Connect(function()
        autoAimActive = not autoAimActive
        if autoAimActive then
            autoaimToggle.Text = "BẬT"
            autoaimToggle.BackgroundColor3 = Color3.fromRGB(0, 170, 80)
            startAutoAim()
        else
            autoaimToggle.Text = "TẮT"
            autoaimToggle.BackgroundColor3 = Color3.fromRGB(120, 50, 50)
        end
    end)

    -- ==================== HEALTH MULTIPLIER SLIDER ====================
    local healthFrame = Instance.new("Frame")
    healthFrame.Size = UDim2.new(0, 360, 0, 80)
    healthFrame.BackgroundColor3 = Color3.fromRGB(45, 45, 58)
    healthFrame.BorderSizePixel = 0
    healthFrame.ZIndex = 52
    healthFrame.Parent = container
    round(healthFrame, 8)

    local healthLabel = Instance.new("TextLabel")
    healthLabel.Size = UDim2.new(1, 0, 0, 25)
    healthLabel.BackgroundTransparency = 1
    healthLabel.Text = "❤️ Máu (HP × " .. tostring(healthMult) .. ")"
    healthLabel.TextColor3 = Color3.new(1, 1, 1)
    healthLabel.TextSize = 14
    healthLabel.Font = Enum.Font.GothamBold
    healthLabel.ZIndex = 53
    healthLabel.Parent = healthFrame

    local healthSlider = Instance.new("TextButton")
    healthSlider.Size = UDim2.new(0, 340, 0, 6)
    healthSlider.Position = UDim2.new(0, 10, 0, 35)
    healthSlider.BackgroundColor3 = Color3.fromRGB(60, 60, 80)
    healthSlider.Text = ""
    healthSlider.BorderSizePixel = 0
    healthSlider.ZIndex = 53
    healthSlider.Parent = healthFrame
    round(healthSlider, 3)

    local healthFill = Instance.new("Frame")
    healthFill.Size = UDim2.new(0, 0, 1, 0)
    healthFill.BackgroundColor3 = Color3.fromRGB(0, 170, 80)
    healthFill.BorderSizePixel = 0
    healthFill.ZIndex = 54
    healthFill.Parent = healthSlider
    round(healthFill, 3)

    local healthValue = Instance.new("TextLabel")
    healthValue.Size = UDim2.new(1, 0, 0, 20)
    healthValue.Position = UDim2.new(0, 0, 1, 5)
    healthValue.BackgroundTransparency = 1
    healthValue.Text = "1x"
    healthValue.TextColor3 = Color3.new(1, 1, 1)
    healthValue.TextSize = 12
    healthValue.Font = Enum.Font.Gotham
    healthValue.ZIndex = 53
    healthValue.Parent = healthFrame

    local function updateHealthSlider(x)
        local relX = math.max(0, math.min(x - healthSlider.AbsolutePosition.X, healthSlider.AbsoluteSize.X))
        local ratio = relX / healthSlider.AbsoluteSize.X
        healthMult = math.max(1, math.floor(ratio * 599 + 1))
        
        healthFill.Size = UDim2.new(ratio, 0, 1, 0)
        healthValue.Text = healthMult .. "x"
        healthLabel.Text = "❤️ Máu (HP × " .. tostring(healthMult) .. ")"
        updateHealth()
    end

    healthSlider.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            updateHealthSlider(input.Position.X)
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement then
            if healthSlider:FindFirstAncestorOfClass("TextButton") or 
               healthSlider.Parent:FindFirstAncestorOfClass("TextButton") then
                -- Đang kéo slider
            end
        end
    end)

    -- ==================== DAMAGE MULTIPLIER SLIDER ====================
    local damageFrame = Instance.new("Frame")
    damageFrame.Size = UDim2.new(0, 360, 0, 80)
    damageFrame.BackgroundColor3 = Color3.fromRGB(45, 45, 58)
    damageFrame.BorderSizePixel = 0
    damageFrame.ZIndex = 52
    damageFrame.Parent = container
    round(damageFrame, 8)

    local damageLabel = Instance.new("TextLabel")
    damageLabel.Size = UDim2.new(1, 0, 0, 25)
    damageLabel.BackgroundTransparency = 1
    damageLabel.Text = "⚔️ Sát Thương (DMG × " .. tostring(damageMult) .. ")"
    damageLabel.TextColor3 = Color3.new(1, 1, 1)
    damageLabel.TextSize = 14
    damageLabel.Font = Enum.Font.GothamBold
    damageLabel.ZIndex = 53
    damageLabel.Parent = damageFrame

    local damageSlider = Instance.new("TextButton")
    damageSlider.Size = UDim2.new(0, 340, 0, 6)
    damageSlider.Position = UDim2.new(0, 10, 0, 35)
    damageSlider.BackgroundColor3 = Color3.fromRGB(60, 60, 80)
    damageSlider.Text = ""
    damageSlider.BorderSizePixel = 0
    damageSlider.ZIndex = 53
    damageSlider.Parent = damageFrame
    round(damageSlider, 3)

    local damageFill = Instance.new("Frame")
    damageFill.Size = UDim2.new(0, 0, 1, 0)
    damageFill.BackgroundColor3 = Color3.fromRGB(220, 100, 50)
    damageFill.BorderSizePixel = 0
    damageFill.ZIndex = 54
    damageFill.Parent = damageSlider
    round(damageFill, 3)

    local damageValue = Instance.new("TextLabel")
    damageValue.Size = UDim2.new(1, 0, 0, 20)
    damageValue.Position = UDim2.new(0, 0, 1, 5)
    damageValue.BackgroundTransparency = 1
    damageValue.Text = "1x"
    damageValue.TextColor3 = Color3.new(1, 1, 1)
    damageValue.TextSize = 12
    damageValue.Font = Enum.Font.Gotham
    damageValue.ZIndex = 53
    damageValue.Parent = damageFrame

    local function updateDamageSlider(x)
        local relX = math.max(0, math.min(x - damageSlider.AbsolutePosition.X, damageSlider.AbsoluteSize.X))
        local ratio = relX / damageSlider.AbsoluteSize.X
        damageMult = math.max(1, math.floor(ratio * 599 + 1))
        
        damageFill.Size = UDim2.new(ratio, 0, 1, 0)
        damageValue.Text = damageMult .. "x"
        damageLabel.Text = "⚔️ Sát Thương (DMG × " .. tostring(damageMult) .. ")"
        updateDamage()
    end

    damageSlider.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            updateDamageSlider(input.Position.X)
        end
    end)

    -- ==================== NÚT HÀNH ĐỘNG ====================
    local actionFrame = Instance.new("Frame")
    actionFrame.Size = UDim2.new(0, 360, 0, 40)
    actionFrame.BackgroundTransparency = 1
    actionFrame.ZIndex = 51
    actionFrame.Parent = container

    local resetBtn = Instance.new("TextButton")
    resetBtn.Size = UDim2.new(1, 0, 1, 0)
    resetBtn.BackgroundColor3 = Color3.fromRGB(70, 100, 200)
    resetBtn.Text = "🔄 RESET"
    resetBtn.TextColor3 = Color3.new(1, 1, 1)
    resetBtn.TextSize = 13
    resetBtn.Font = Enum.Font.GothamBold
    resetBtn.BorderSizePixel = 0
    resetBtn.ZIndex = 53
    resetBtn.Parent = actionFrame
    round(resetBtn, 8)

    resetBtn.MouseButton1Click:Connect(function()
        healthMult = 1
        damageMult = 1
        autoAimActive = false
        
        healthFill.Size = UDim2.new(0, 0, 1, 0)
        healthValue.Text = "1x"
        healthLabel.Text = "❤️ Máu (HP × 1)"
        
        damageFill.Size = UDim2.new(0, 0, 1, 0)
        damageValue.Text = "1x"
        damageLabel.Text = "⚔️ Sát Thương (DMG × 1)"
        
        autoaimToggle.Text = "TẮT"
        autoaimToggle.BackgroundColor3 = Color3.fromRGB(120, 50, 50)
    end)

    -- ==================== KÉO ĐƯỢC ====================
    local dragging = false
    local dragStart, startPos

    dotBtn.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStart = input.Position
            startPos = dotBtn.Position
        end
    end)

    dotBtn.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
            panel.Visible = not panel.Visible
            isMenuVisible = panel.Visible
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            local delta = input.Position - dragStart
            dotBtn.Position = UDim2.new(
                startPos.X.Scale, startPos.X.Offset + delta.X,
                startPos.Y.Scale, startPos.Y.Offset + delta.Y
            )
        end
    end)

    dotBtn.MouseButton1Click:Connect(function()
        if not dragging then
            panel.Visible = not panel.Visible
            isMenuVisible = panel.Visible
        end
    end)

    return gui
end

-- ==================== KHỞI CHẠY ====================
local ok, err = pcall(buildUI)
if not ok then
    warn("[Universal Catun] Lỗi: " .. tostring(err))
    return
end

genv.__UNIVERSAL_CLEANUP = function()
    autoAimActive = false
    healthMult = 1
    damageMult = 1
end

print("✓ Universal Catun v2.0 đã tải - bấm chấm (•) để mở menu")
