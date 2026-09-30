--[[ 
╔═══════════════════════════════════════════════════════════════════════════════╗
║         ROBLOX ULTIMATE MENU v5.0 - FIX LAG + CATUN FEATURES                ║
║  Chạy trên Arceus X Neo Executor - Combat Safe                               ║
╚═══════════════════════════════════════════════════════════════════════════════╝
--]]

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetWorkspace()

local LocalPlayer = Players.LocalPlayer
local LocalCharacter = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
local Camera = workspace.CurrentCamera

-- ==================== CẤU HÌNH LAG ====================
local LAG_CONFIG = {
    LOC_TIEU_CHUAN = true,
    CHE_DO_SANG_TINH = true,
    LOC_AM_THANH = true,
    DON_GIAN_NHAN_VAT = true,
    TAT_DEN = true,
    TIEU_CHINH_ANIMATION = true,
    DQN_RAC_NHAN_CAP = true,
    GIAM_KHOP = false,
    GIAM_GOC_CAMERA = true,
    TAT_RAGDOLL = true,
    TOI_UU_MESH = true,
    GIAM_TAI_XU_LY = true,
    CHE_DO_TIET_KIEM_PIN = true,
    
    SO_AM_THANH_TOI_DA = 7,
    TAM_AM_THANH = 20,
    TAM_TIEU_CHUAN_COMBAT = 15,
    TAM_LOAI_BO_TIEU_CHUAN = 50,
    KHOANG_CACH_XA = 30,
    KHOANG_CACH_GIUA = 15,
    KHOANG_THOI_DQN_RAC = 60,
    GIA_TRI_GOC_CAMERA = 50,
}

-- ==================== CẤU HÌNH CATUN ====================
local CATUN_CONFIG = {
    AUTO_TARGET = true,
    HP_MULTIPLIER = 2,                  -- Gấp đôi máu (2-100x)
    DAMAGE_MULTIPLIER = 1,              -- Nhân sát thương (1-100x)
    INFINITE_AMMO = true,
    
    -- Tầm ghim
    TARGET_RANGE = 30,
    AUTO_TARGET_RANGE_VISION = true,    -- Chỉ ghim khi trong tầm nhìn
    VISION_CHECK = true,                -- Kiểm tra xem trong tầm nhìn không
}

local CurrentTarget = nil

-- ==================== UTILITY ====================
local function GetDistance(pos1, pos2)
    return (pos1 - pos2).Magnitude
end

local function IsLocalPlayer(character)
    return character == LocalCharacter
end

local function UpdateLocalCharacter()
    if not LocalPlayer.Character then
        LocalCharacter = LocalPlayer.CharacterAdded:Wait()
    else
        LocalCharacter = LocalPlayer.Character
    end
end

local function IsInViewport(position)
    local screenPos, inViewport = Camera:WorldToScreenPoint(position)
    return inViewport
end

-- ==================== LAG FEATURES ====================

local function InitParticleCulling()
    if not LAG_CONFIG.LOC_TIEU_CHUAN then return end
    
    local function FilterParticles()
        for _, obj in Workspace:GetDescendants() do
            if obj:IsA("ParticleEmitter") or obj:IsA("Trail") or obj:IsA("Beam") then
                UpdateLocalCharacter()
                
                local character = obj:FindFirstAncestorWhichIsA("Character")
                
                if character == LocalCharacter then
                    obj.Enabled = true
                elseif obj:GetAttribute("KeepVFX") then
                    obj.Enabled = true
                elseif character then
                    local dist = GetDistance(character:GetPivot().Position, LocalCharacter:GetPivot().Position)
                    if dist > LAG_CONFIG.TAM_LOAI_BO_TIEU_CHUAN then
                        obj.Enabled = false
                    elseif dist > LAG_CONFIG.TAM_TIEU_CHUAN_COMBAT then
                        obj.Enabled = true
                        if obj:IsA("ParticleEmitter") then
                            obj.Rate = math.max(obj.Rate * 0.5, 1)
                        end
                    end
                else
                    obj.Enabled = false
                end
            end
        end
    end
    
    Workspace.DescendantAdded:Connect(function(obj)
        if obj:IsA("ParticleEmitter") or obj:IsA("Trail") or obj:IsA("Beam") then
            task.wait(0.05)
            FilterParticles()
        end
    end)
    
    FilterParticles()
end

local function InitStaticLighting()
    if not LAG_CONFIG.CHE_DO_SANG_TINH then return end
    
    local lighting = game.Lighting
    
    pcall(function()
        lighting.GlobalShadows = false
        lighting.Technology = Enum.Technology.Compatibility
        lighting.EnvironmentDiffuseScale = 0
        lighting.EnvironmentSpecularScale = 0
        
        for _, effect in lighting:GetChildren() do
            if effect:IsA("PostEffect") then
                effect.Enabled = false
            end
        end
    end)
end

local function InitAudioCulling()
    if not LAG_CONFIG.LOC_AM_THANH then return end
    
    local function UpdateAudio()
        local sounds = {}
        
        for _, sound in Workspace:GetDescendants() do
            if sound:IsA("Sound") then
                UpdateLocalCharacter()
                local distance = GetDistance(sound.Parent:GetPivot().Position, Camera.CFrame.Position)
                
                if sound:GetAttribute("CombatSound") then
                    sound.Enabled = true
                elseif distance > LAG_CONFIG.TAM_AM_THANH then
                    sound.Enabled = false
                else
                    table.insert(sounds, sound)
                end
            end
        end
        
        if #sounds > LAG_CONFIG.SO_AM_THANH_TOI_DA then
            for i = LAG_CONFIG.SO_AM_THANH_TOI_DA + 1, #sounds do
                sounds[i].Enabled = false
            end
        end
    end
    
    RunService.Heartbeat:Connect(function()
        task.spawn(UpdateAudio)
    end)
end

local function InitSimplifyCharacter()
    if not LAG_CONFIG.DON_GIAN_NHAN_VAT then return end
    
    local function SimplifyCharacter(character)
        if IsLocalPlayer(character) then return end
        
        for _, obj in character:GetDescendants() do
            if obj:IsA("Accessory") then
                obj:Destroy()
            end
        end
        
        local head = character:FindFirstChild("Head")
        if head then
            for _, hair in head:GetChildren() do
                if hair.Name:match("Hair") or hair.Name:match("hair") then
                    pcall(function() hair:Destroy() end)
                end
            end
        end
        
        local humanoid = character:FindFirstChild("Humanoid")
        if humanoid then
            humanoid.HealthDisplayDistance = 0
        end
    end
    
    for _, character in Workspace:FindPartOfClass("Model") do
        if character:FindFirstChild("Humanoid") then
            SimplifyCharacter(character)
        end
    end
    
    Players.PlayerAdded:Connect(function(player)
        player.CharacterAdded:Connect(SimplifyCharacter)
    end)
end

local function InitDisableLights()
    if not LAG_CONFIG.TAT_DEN then return end
    
    local function DisableLightsAndUIs()
        UpdateLocalCharacter()
        
        for _, obj in Workspace:GetDescendants() do
            if obj:IsA("PointLight") then
                if obj:FindFirstAncestorWhichIsA("Character") ~= LocalCharacter then
                    obj.Enabled = false
                end
            elseif obj:IsA("SurfaceGui") then
                obj.Enabled = false
            end
        end
    end
    
    Workspace.DescendantAdded:Connect(function(obj)
        if obj:IsA("PointLight") or obj:IsA("SurfaceGui") then
            task.wait(0.05)
            if obj:IsA("PointLight") and obj:FindFirstAncestorWhichIsA("Character") ~= LocalCharacter then
                obj.Enabled = false
            elseif obj:IsA("SurfaceGui") then
                obj.Enabled = false
            end
        end
    end)
    
    DisableLightsAndUIs()
end

local function InitAnimatorSpeed()
    if not LAG_CONFIG.TIEU_CHINH_ANIMATION then return end
    
    local function AdjustAnimationSpeed()
        UpdateLocalCharacter()
        
        for _, character in Workspace:FindPartOfClass("Model") do
            if IsLocalPlayer(character) then goto continue end
            if not character:FindFirstChild("Humanoid") then goto continue end
            
            local humanoid = character:FindFirstChild("Humanoid")
            local animator = humanoid:FindFirstChild("Animator")
            if not animator then goto continue end
            
            local distance = GetDistance(character:GetPivot().Position, LocalCharacter:GetPivot().Position)
            
            if distance > LAG_CONFIG.KHOANG_CACH_XA then
                animator.AnimationSpeed = 0.3
            elseif distance > LAG_CONFIG.KHOANG_CACH_GIUA then
                animator.AnimationSpeed = 0.7
            else
                animator.AnimationSpeed = 1.0
            end
            
            ::continue::
        end
    end
    
    RunService.Heartbeat:Connect(function()
        task.spawn(AdjustAnimationSpeed)
    end)
end

local function InitMemoryGC()
    if not LAG_CONFIG.DQN_RAC_NHAN_CAP then return end
    
    local connections = {}
    
    local function CleanupConnections()
        for i = #connections, 1, -1 do
            if not connections[i].Connected then
                table.remove(connections, i)
            end
        end
    end
    
    task.spawn(function()
        while true do
            task.wait(LAG_CONFIG.KHOANG_THOI_DQN_RAC)
            CleanupConnections()
            collectgarbage("collect")
        end
    end)
end

local function InitOtherLagFeatures()
    if LAG_CONFIG.GIAM_KHOP then
        -- Weld reduction
    end
    
    if LAG_CONFIG.GIAM_GOC_CAMERA then
        pcall(function()
            Camera.FieldOfView = LAG_CONFIG.GIA_TRI_GOC_CAMERA
        end)
    end
    
    if LAG_CONFIG.TAT_RAGDOLL then
        -- Humanoid ragdoll disable
    end
    
    if LAG_CONFIG.TOI_UU_MESH then
        -- Mesh LOD
    end
end

-- ==================== CATUN FEATURES ====================

local function GetNearestEnemy()
    UpdateLocalCharacter()
    if not LocalCharacter:FindFirstChild("HumanoidRootPart") then return nil end
    
    local localPos = LocalCharacter:GetPivot().Position
    local nearestEnemy = nil
    local nearestDist = LAG_CONFIG.TARGET_RANGE
    
    for _, character in Workspace:FindPartOfClass("Model") do
        if IsLocalPlayer(character) then goto skip_enemy end
        if not character:FindFirstChild("Humanoid") then goto skip_enemy end
        if not character:FindFirstChild("HumanoidRootPart") then goto skip_enemy end
        
        local humanoid = character:FindFirstChild("Humanoid")
        if humanoid.Health <= 0 then goto skip_enemy end
        
        local enemyPos = character:GetPivot().Position
        local dist = GetDistance(localPos, enemyPos)
        
        if dist > nearestDist then goto skip_enemy end
        
        -- Kiểm tra tầm nhìn nếu bật
        if LAG_CONFIG.VISION_CHECK then
            if not IsInViewport(enemyPos) then goto skip_enemy end
        end
        
        if dist < nearestDist then
            nearestDist = dist
            nearestEnemy = character
        end
        
        ::skip_enemy::
    end
    
    return nearestEnemy
end

local function InitAutoTarget()
    if not CATUN_CONFIG.AUTO_TARGET then return end
    
    RunService.Heartbeat:Connect(function()
        local newTarget = GetNearestEnemy()
        
        if newTarget and newTarget:FindFirstChild("Humanoid") then
            if newTarget:FindFirstChild("Humanoid").Health > 0 then
                CurrentTarget = newTarget
            else
                CurrentTarget = nil
            end
        else
            CurrentTarget = nil
        end
    end)
end

local function InitHPMultiplier()
    UpdateLocalCharacter()
    local humanoid = LocalCharacter:FindFirstChild("Humanoid")
    
    if humanoid then
        local baseMaxHealth = humanoid.MaxHealth
        humanoid.MaxHealth = baseMaxHealth * CATUN_CONFIG.HP_MULTIPLIER
        humanoid.Health = humanoid.MaxHealth
    end
    
    -- Update khi respawn
    LocalPlayer.CharacterAdded:Connect(function(char)
        task.wait(0.1)
        local newHumanoid = char:FindFirstChild("Humanoid")
        if newHumanoid then
            local baseMaxHealth = newHumanoid.MaxHealth
            newHumanoid.MaxHealth = baseMaxHealth * CATUN_CONFIG.HP_MULTIPLIER
            newHumanoid.Health = newHumanoid.MaxHealth
        end
    end)
end

local function InitDamageMultiplier()
    if CATUN_CONFIG.DAMAGE_MULTIPLIER <= 1 then return end
    
    UpdateLocalCharacter()
    
    -- Hook vào sự kiện damage (tùy vào game cách xử lý khác nhau)
    -- Đây là placeholder cho game có RemoteEvent damage
    local damageMultiplier = CATUN_CONFIG.DAMAGE_MULTIPLIER
    
    -- Tìm RemoteEvent damage nếu có
    local function applyDamageMultiplier()
        for _, event in pairs(LocalCharacter:GetDescendants()) do
            if event:IsA("RemoteEvent") and event.Name:match("[Dd]amage") then
                local originalFire = event.FireServer
                event.FireServer = function(self, ...)
                    local args = {...}
                    if args[1] then
                        args[1] = args[1] * damageMultiplier
                    end
                    return originalFire(self, unpack(args))
                end
            end
        end
    end
    
    applyDamageMultiplier()
end

local function InitInfiniteAmmo()
    if not CATUN_CONFIG.INFINITE_AMMO then return end
    
    UpdateLocalCharacter()
    
    -- Patch Humanoid:TakeDamage hoặc RemoteEvent ammo
    local function applyInfiniteAmmo()
        for _, tool in pairs(LocalCharacter:FindPartOfClass("Tool")) do
            if tool:FindFirstChild("Ammo") then
                local ammo = tool:FindFirstChild("Ammo")
                if ammo:IsA("IntValue") or ammo:IsA("NumberValue") then
                    local maxAmmo = ammo.Value
                    ammo.Changed:Connect(function()
                        if ammo.Value <= 0 then
                            ammo.Value = maxAmmo
                        end
                    end)
                end
            end
        end
    end
    
    applyInfiniteAmmo()
    
    -- Cập nhật khi lấy tool mới
    LocalCharacter.ChildAdded:Connect(function(child)
        if child:IsA("Tool") then
            task.wait(0.1)
            applyInfiniteAmmo()
        end
    end)
end

-- ==================== MENU UI ====================
local ScreenGui = nil
local CurrentMenu = "MAIN"

local function CreateUI()
    if ScreenGui then ScreenGui:Destroy() end
    
    ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "UltimateMenuUI"
    ScreenGui.ResetOnSpawn = false
    ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")
    
    -- Nút nổi
    local FloatingButton = Instance.new("ImageButton")
    FloatingButton.Name = "NutNoi"
    FloatingButton.Size = UDim2.new(0, 60, 0, 60)
    FloatingButton.Position = UDim2.new(0.9, 0, 0.5, 0)
    FloatingButton.BackgroundColor3 = Color3.fromRGB(128, 0, 255)
    FloatingButton.BackgroundTransparency = 0.3
    FloatingButton.BorderSizePixel = 0
    FloatingButton.Parent = ScreenGui
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 30)
    corner.Parent = FloatingButton
    
    local textLabel = Instance.new("TextLabel")
    textLabel.Name = "Icon"
    textLabel.Size = UDim2.new(1, 0, 1, 0)
    textLabel.BackgroundTransparency = 1
    textLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    textLabel.TextSize = 24
    textLabel.Font = Enum.Font.GothamBold
    textLabel.Text = "⚡"
    textLabel.Parent = FloatingButton
    
    -- Khung Menu Chính
    local MenuFrame = Instance.new("Frame")
    MenuFrame.Name = "KhungMenu"
    MenuFrame.Size = UDim2.new(0, 380, 0, 650)
    MenuFrame.Position = UDim2.new(0.5, -190, 0.5, -325)
    MenuFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
    MenuFrame.BorderSizePixel = 0
    MenuFrame.Visible = false
    MenuFrame.Parent = ScreenGui
    
    local menuCorner = Instance.new("UICorner")
    menuCorner.CornerRadius = UDim.new(0, 15)
    menuCorner.Parent = MenuFrame
    
    -- Tiêu đề
    local Title = Instance.new("TextLabel")
    Title.Name = "TieuDe"
    Title.Size = UDim2.new(1, 0, 0, 50)
    Title.BackgroundColor3 = Color3.fromRGB(128, 0, 255)
    Title.TextColor3 = Color3.fromRGB(255, 255, 255)
    Title.TextSize = 16
    Title.Font = Enum.Font.GothamBold
    Title.Text = "⚡ MENU CHÍNH v5.0"
    Title.BorderSizePixel = 0
    Title.Parent = MenuFrame
    
    local titleCorner = Instance.new("UICorner")
    titleCorner.CornerRadius = UDim.new(0, 15)
    titleCorner.Parent = Title
    
    -- Tab buttons (Fix Lag / Catun)
    local TabContainer = Instance.new("Frame")
    TabContainer.Name = "TabContainer"
    TabContainer.Size = UDim2.new(1, 0, 0, 45)
    TabContainer.Position = UDim2.new(0, 0, 0, 50)
    TabContainer.BackgroundColor3 = Color3.fromRGB(50, 50, 60)
    TabContainer.BorderSizePixel = 0
    TabContainer.Parent = MenuFrame
    
    -- Fix Lag Tab
    local FixLagTab = Instance.new("TextButton")
    FixLagTab.Name = "FixLagTab"
    FixLagTab.Size = UDim2.new(0.5, -5, 1, 0)
    FixLagTab.Position = UDim2.new(0, 5, 0, 0)
    FixLagTab.BackgroundColor3 = Color3.fromRGB(100, 150, 255)
    FixLagTab.TextColor3 = Color3.fromRGB(255, 255, 255)
    FixLagTab.TextSize = 13
    FixLagTab.Font = Enum.Font.GothamBold
    FixLagTab.Text = "FIX LAG"
    FixLagTab.BorderSizePixel = 0
    FixLagTab.Parent = TabContainer
    
    local fixLagCorner = Instance.new("UICorner")
    fixLagCorner.CornerRadius = UDim.new(0, 5)
    fixLagCorner.Parent = FixLagTab
    
    -- Catun Tab
    local CatunTab = Instance.new("TextButton")
    CatunTab.Name = "CatunTab"
    CatunTab.Size = UDim2.new(0.5, -5, 1, 0)
    CatunTab.Position = UDim2.new(0.5, 5, 0, 0)
    CatunTab.BackgroundColor3 = Color3.fromRGB(80, 80, 90)
    CatunTab.TextColor3 = Color3.fromRGB(255, 255, 255)
    CatunTab.TextSize = 13
    CatunTab.Font = Enum.Font.GothamBold
    CatunTab.Text = "CATUN"
    CatunTab.BorderSizePixel = 0
    CatunTab.Parent = TabContainer
    
    local catunCorner = Instance.new("UICorner")
    catunCorner.CornerRadius = UDim.new(0, 5)
    catunCorner.Parent = CatunTab
    
    -- Content Frame (để swap giữa Fix Lag và Catun)
    local ContentFrame = Instance.new("Frame")
    ContentFrame.Name = "ContentFrame"
    ContentFrame.Size = UDim2.new(1, 0, 1, -100)
    ContentFrame.Position = UDim2.new(0, 0, 0, 95)
    ContentFrame.BackgroundTransparency = 1
    ContentFrame.Parent = MenuFrame
    
    -- ========== FIX LAG CONTENT ==========
    local FixLagContent = Instance.new("ScrollingFrame")
    FixLagContent.Name = "FixLagContent"
    FixLagContent.Size = UDim2.new(1, 0, 1, 0)
    FixLagContent.Position = UDim2.new(0, 0, 0, 0)
    FixLagContent.BackgroundTransparency = 1
    FixLagContent.ScrollBarThickness = 8
    FixLagContent.CanvasSize = UDim2.new(0, 0, 0, 1000)
    FixLagContent.Visible = true
    FixLagContent.Parent = ContentFrame
    
    local lagToggles = {
        {"LOC_TIEU_CHUAN", "Lọc Hiệu Ứng"},
        {"CHE_DO_SANG_TINH", "Chế độ Sáng Tĩnh"},
        {"LOC_AM_THANH", "Lọc Âm Thanh"},
        {"DON_GIAN_NHAN_VAT", "Đơn Giản Nhân Vật"},
        {"TAT_DEN", "Tắt Đèn & UI 3D"},
        {"TIEU_CHINH_ANIMATION", "Tiêu Chỉnh Animation"},
        {"DQN_RAC_NHAN_CAP", "Dọn Rác Nhân Cấp"},
        {"GIAM_GOC_CAMERA", "Giảm Góc Camera"},
        {"TAT_RAGDOLL", "Tắt Ragdoll"},
        {"TOI_UU_MESH", "Tối Ưu Mesh"},
        {"GIAM_TAI_XU_LY", "Giảm Tải Xử Lý"},
        {"CHE_DO_TIET_KIEM_PIN", "Chế độ Tiết Kiệm Pin"},
    }
    
    local yPos = 0
    for _, toggleData in ipairs(lagToggles) do
        local toggleName = toggleData[1]
        local toggleLabel = toggleData[2]
        
        local ToggleContainer = Instance.new("Frame")
        ToggleContainer.Name = toggleName
        ToggleContainer.Size = UDim2.new(1, 0, 0, 40)
        ToggleContainer.Position = UDim2.new(0, 0, 0, yPos)
        ToggleContainer.BackgroundColor3 = Color3.fromRGB(50, 50, 60)
        ToggleContainer.BorderSizePixel = 0
        ToggleContainer.Parent = FixLagContent
        
        local Label = Instance.new("TextLabel")
        Label.Size = UDim2.new(0.65, 0, 1, 0)
        Label.BackgroundTransparency = 1
        Label.TextColor3 = Color3.fromRGB(255, 255, 255)
        Label.TextSize = 11
        Label.Font = Enum.Font.Gotham
        Label.Text = toggleLabel
        Label.TextXAlignment = Enum.TextXAlignment.Left
        Label.Parent = ToggleContainer
        
        local ToggleButton = Instance.new("TextButton")
        ToggleButton.Name = "BatTat"
        ToggleButton.Size = UDim2.new(0.35, -10, 0, 30)
        ToggleButton.Position = UDim2.new(0.65, 5, 0.5, -15)
        ToggleButton.BackgroundColor3 = LAG_CONFIG[toggleName] and Color3.fromRGB(0, 200, 0) or Color3.fromRGB(200, 0, 0)
        ToggleButton.TextColor3 = Color3.fromRGB(255, 255, 255)
        ToggleButton.TextSize = 11
        ToggleButton.Font = Enum.Font.GothamBold
        ToggleButton.Text = LAG_CONFIG[toggleName] and "BẬT" or "TẮT"
        ToggleButton.BorderSizePixel = 0
        ToggleButton.Parent = ToggleContainer
        
        local toggleCorner = Instance.new("UICorner")
        toggleCorner.CornerRadius = UDim.new(0, 5)
        toggleCorner.Parent = ToggleButton
        
        ToggleButton.MouseButton1Click:Connect(function()
            LAG_CONFIG[toggleName] = not LAG_CONFIG[toggleName]
            ToggleButton.BackgroundColor3 = LAG_CONFIG[toggleName] and Color3.fromRGB(0, 200, 0) or Color3.fromRGB(200, 0, 0)
            ToggleButton.Text = LAG_CONFIG[toggleName] and "BẬT" or "TẮT"
        end)
        
        yPos = yPos + 45
    end
    
    -- ========== CATUN CONTENT ==========
    local CatunContent = Instance.new("ScrollingFrame")
    CatunContent.Name = "CatunContent"
    CatunContent.Size = UDim2.new(1, 0, 1, 0)
    CatunContent.Position = UDim2.new(0, 0, 0, 0)
    CatunContent.BackgroundTransparency = 1
    CatunContent.ScrollBarThickness = 8
    CatunContent.CanvasSize = UDim2.new(0, 0, 0, 900)
    CatunContent.Visible = false
    CatunContent.Parent = ContentFrame
    
    local catunToggles = {
        {"AUTO_TARGET", "Tự Động Ghim Quái"},
        {"INFINITE_AMMO", "Vô Hạn Đạn"},
    }
    
    yPos = 0
    for _, toggleData in ipairs(catunToggles) do
        local toggleName = toggleData[1]
        local toggleLabel = toggleData[2]
        
        local ToggleContainer = Instance.new("Frame")
        ToggleContainer.Name = toggleName
        ToggleContainer.Size = UDim2.new(1, 0, 0, 40)
        ToggleContainer.Position = UDim2.new(0, 0, 0, yPos)
        ToggleContainer.BackgroundColor3 = Color3.fromRGB(50, 50, 60)
        ToggleContainer.BorderSizePixel = 0
        ToggleContainer.Parent = CatunContent
        
        local Label = Instance.new("TextLabel")
        Label.Size = UDim2.new(0.65, 0, 1, 0)
        Label.BackgroundTransparency = 1
        Label.TextColor3 = Color3.fromRGB(255, 255, 255)
        Label.TextSize = 11
        Label.Font = Enum.Font.Gotham
        Label.Text = toggleLabel
        Label.TextXAlignment = Enum.TextXAlignment.Left
        Label.Parent = ToggleContainer
        
        local ToggleButton = Instance.new("TextButton")
        ToggleButton.Name = "BatTat"
        ToggleButton.Size = UDim2.new(0.35, -10, 0, 30)
        ToggleButton.Position = UDim2.new(0.65, 5, 0.5, -15)
        ToggleButton.BackgroundColor3 = CATUN_CONFIG[toggleName] and Color3.fromRGB(0, 200, 0) or Color3.fromRGB(200, 0, 0)
        ToggleButton.TextColor3 = Color3.fromRGB(255, 255, 255)
        ToggleButton.TextSize = 11
        ToggleButton.Font = Enum.Font.GothamBold
        ToggleButton.Text = CATUN_CONFIG[toggleName] and "BẬT" or "TẮT"
        ToggleButton.BorderSizePixel = 0
        ToggleButton.Parent = ToggleContainer
        
        local toggleCorner = Instance.new("UICorner")
        toggleCorner.CornerRadius = UDim.new(0, 5)
        toggleCorner.Parent = ToggleButton
        
        ToggleButton.MouseButton1Click:Connect(function()
            CATUN_CONFIG[toggleName] = not CATUN_CONFIG[toggleName]
            ToggleButton.BackgroundColor3 = CATUN_CONFIG[toggleName] and Color3.fromRGB(0, 200, 0) or Color3.fromRGB(200, 0, 0)
            ToggleButton.Text = CATUN_CONFIG[toggleName] and "BẬT" or "TẮT"
        end)
        
        yPos = yPos + 45
    end
    
    -- HP Multiplier Slider
    local HPContainer = Instance.new("Frame")
    HPContainer.Name = "HPContainer"
    HPContainer.Size = UDim2.new(1, 0, 0, 70)
    HPContainer.Position = UDim2.new(0, 0, 0, yPos)
    HPContainer.BackgroundColor3 = Color3.fromRGB(50, 50, 60)
    HPContainer.BorderSizePixel = 0
    HPContainer.Parent = CatunContent
    
    local HPLabel = Instance.new("TextLabel")
    HPLabel.Size = UDim2.new(1, -20, 0, 25)
    HPLabel.Position = UDim2.new(0, 10, 0, 5)
    HPLabel.BackgroundTransparency = 1
    HPLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    HPLabel.TextSize = 11
    HPLabel.Font = Enum.Font.Gotham
    HPLabel.Text = "Máu Nhân Vật: x" .. CATUN_CONFIG.HP_MULTIPLIER
    HPLabel.TextXAlignment = Enum.TextXAlignment.Left
    HPLabel.Parent = HPContainer
    
    local HPInput = Instance.new("TextBox")
    HPInput.Name = "HPInput"
    HPInput.Size = UDim2.new(1, -20, 0, 30)
    HPInput.Position = UDim2.new(0, 10, 0, 35)
    HPInput.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
    HPInput.TextColor3 = Color3.fromRGB(255, 255, 255)
    HPInput.TextSize = 12
    HPInput.Font = Enum.Font.Gotham
    HPInput.PlaceholderText = "2-100"
    HPInput.Text = tostring(CATUN_CONFIG.HP_MULTIPLIER)
    HPInput.BorderSizePixel = 0
    HPInput.Parent = HPContainer
    
    local hpInputCorner = Instance.new("UICorner")
    hpInputCorner.CornerRadius = UDim.new(0, 5)
    hpInputCorner.Parent = HPInput
    
    HPInput.FocusLost:Connect(function()
        local value = tonumber(HPInput.Text) or CATUN_CONFIG.HP_MULTIPLIER
        value = math.max(2, math.min(100, value))
        CATUN_CONFIG.HP_MULTIPLIER = value
        HPInput.Text = tostring(value)
        HPLabel.Text = "Máu Nhân Vật: x" .. value
        InitHPMultiplier()
    end)
    
    yPos = yPos + 75
    
    -- Damage Multiplier Slider
    local DamageContainer = Instance.new("Frame")
    DamageContainer.Name = "DamageContainer"
    DamageContainer.Size = UDim2.new(1, 0, 0, 70)
    DamageContainer.Position = UDim2.new(0, 0, 0, yPos)
    DamageContainer.BackgroundColor3 = Color3.fromRGB(50, 50, 60)
    DamageContainer.BorderSizePixel = 0
    DamageContainer.Parent = CatunContent
    
    local DamageLabel = Instance.new("TextLabel")
    DamageLabel.Size = UDim2.new(1, -20, 0, 25)
    DamageLabel.Position = UDim2.new(0, 10, 0, 5)
    DamageLabel.BackgroundTransparency = 1
    DamageLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    DamageLabel.TextSize = 11
    DamageLabel.Font = Enum.Font.Gotham
    DamageLabel.Text = "Sát Thương: x" .. CATUN_CONFIG.DAMAGE_MULTIPLIER
    DamageLabel.TextXAlignment = Enum.TextXAlignment.Left
    DamageLabel.Parent = DamageContainer
    
    local DamageInput = Instance.new("TextBox")
    DamageInput.Name = "DamageInput"
    DamageInput.Size = UDim2.new(1, -20, 0, 30)
    DamageInput.Position = UDim2.new(0, 10, 0, 35)
    DamageInput.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
    DamageInput.TextColor3 = Color3.fromRGB(255, 255, 255)
    DamageInput.TextSize = 12
    DamageInput.Font = Enum.Font.Gotham
    DamageInput.PlaceholderText = "1-100"
    DamageInput.Text = tostring(CATUN_CONFIG.DAMAGE_MULTIPLIER)
    DamageInput.BorderSizePixel = 0
    DamageInput.Parent = DamageContainer
    
    local damageInputCorner = Instance.new("UICorner")
    damageInputCorner.CornerRadius = UDim.new(0, 5)
    damageInputCorner.Parent = DamageInput
    
    DamageInput.FocusLost:Connect(function()
        local value = tonumber(DamageInput.Text) or CATUN_CONFIG.DAMAGE_MULTIPLIER
        value = math.max(1, math.min(100, value))
        CATUN_CONFIG.DAMAGE_MULTIPLIER = value
        DamageInput.Text = tostring(value)
        DamageLabel.Text = "Sát Thương: x" .. value
        InitDamageMultiplier()
    end)
    
    -- Tab switching
    FixLagTab.MouseButton1Click:Connect(function()
        FixLagContent.Visible = true
        CatunContent.Visible = false
        FixLagTab.BackgroundColor3 = Color3.fromRGB(100, 150, 255)
        CatunTab.BackgroundColor3 = Color3.fromRGB(80, 80, 90)
    end)
    
    CatunTab.MouseButton1Click:Connect(function()
        FixLagContent.Visible = false
        CatunContent.Visible = true
        FixLagTab.BackgroundColor3 = Color3.fromRGB(80, 80, 90)
        CatunTab.BackgroundColor3 = Color3.fromRGB(100, 150, 255)
    end)
    
    -- Close button
    local CloseButton = Instance.new("TextButton")
    CloseButton.Name = "NutDong"
    CloseButton.Size = UDim2.new(1, -20, 0, 35)
    CloseButton.Position = UDim2.new(0, 10, 1, -45)
    CloseButton.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
    CloseButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    CloseButton.TextSize = 13
    CloseButton.Font = Enum.Font.GothamBold
    CloseButton.Text = "ĐÓNG"
    CloseButton.BorderSizePixel = 0
    CloseButton.Parent = MenuFrame
    
    local closeCorner = Instance.new("UICorner")
    closeCorner.CornerRadius = UDim.new(0, 8)
    closeCorner.Parent = CloseButton
    
    CloseButton.MouseButton1Click:Connect(function()
        MenuFrame.Visible = false
    end)
    
    -- Toggle menu visibility
    FloatingButton.MouseButton1Click:Connect(function()
        MenuFrame.Visible = not MenuFrame.Visible
    end)
end

-- ==================== KHỞI TẠO ====================
local function InitializeAll()
    print("═══════════════════════════════════════════════════════════")
    print("MENU ULTIMATE v5.0 - FIX LAG + CATUN")
    print("Đang khởi tạo...")
    print("═══════════════════════════════════════════════════════════")
    
    -- Init lag features
    InitParticleCulling()
    InitStaticLighting()
    InitAudioCulling()
    InitSimplifyCharacter()
    InitDisableLights()
    InitAnimatorSpeed()
    InitMemoryGC()
    InitOtherLagFeatures()
    
    -- Init Catun features
    InitAutoTarget()
    InitHPMultiplier()
    InitDamageMultiplier()
    InitInfiniteAmmo()
    
    CreateUI()
    
    print("═══════════════════════════════════════════════════════════")
    print("✓ TẤT CẢ CHỨC NĂNG ĐÃ KHỞI TẠO THÀNH CÔNG")
    print("Nhấn nút ⚡ để mở menu")
    print("═══════════════════════════════════════════════════════════")
end

pcall(function()
    InitializeAll()
end)

print("Menu Ultimate v5.0 đã tải. Sẵn sàng dùng trên Arceus X Neo!")
