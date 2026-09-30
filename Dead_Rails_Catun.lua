--[[
    DEAD RAILS - CATUN SCRIPT v1.0
    Một file duy nhất với menu chấm nhỏ
    2 phần: Fix Lag (11 tính năng) + Catun (4 tính năng)
]]

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Lighting = game:GetService("Lighting")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")

local LocalPlayer = Players.LocalPlayer
local GUI_NAME = "DeadRailsCatun"
local PURPLE = Color3.fromRGB(128, 0, 255)

-- ==================== DỌN BẢN CŨ ====================
local genv = (getgenv and getgenv()) or _G
if genv.__CATUN_CLEANUP then
    pcall(genv.__CATUN_CLEANUP)
end

-- ==================== TIỆN ÍCH ====================
local function isOwn(obj)
    local char = LocalPlayer.Character
    return char ~= nil and obj:IsDescendantOf(char)
end

local function inCharacter(obj)
    local p = obj.Parent
    while p and p ~= Workspace do
        if p:IsA("Model") and p:FindFirstChildOfClass("Humanoid") then
            return true
        end
        p = p.Parent
    end
    return false
end

local function descendantFeature(match, hide, restore)
    local saved = {}
    local conn = nil
    local running = false

    local function handle(o)
        if saved[o] == nil and match(o) then
            local ok, orig = pcall(hide, o)
            if ok then
                saved[o] = { orig }
            end
        end
    end

    return {
        apply = function()
            running = true
            conn = Workspace.DescendantAdded:Connect(function(o)
                task.defer(handle, o)
            end)
            task.spawn(function()
                local n = 0
                for _, o in ipairs(Workspace:GetDescendants()) do
                    if not running then return end
                    handle(o)
                    n = n + 1
                    if n % 250 == 0 then task.wait() end
                end
            end)
        end,
        revert = function()
            running = false
            if conn then
                conn:Disconnect()
                conn = nil
            end
            for o, box in pairs(saved) do
                pcall(restore, o, box[1])
            end
            for k in pairs(saved) do
                saved[k] = nil
            end
        end,
    }
end

-- ==================== FIX LAG FEATURES ====================
local impl = {}

impl.fx = descendantFeature(
    function(o)
        return (o:IsA("ParticleEmitter") or o:IsA("Trail") or o:IsA("Beam")
            or o:IsA("Fire") or o:IsA("Smoke") or o:IsA("Sparkles"))
            and not isOwn(o)
    end,
    function(o) local v = o.Enabled; o.Enabled = false; return v end,
    function(o, v) o.Enabled = v end
)

impl.lights = descendantFeature(
    function(o)
        return (o:IsA("Light") or o:IsA("SurfaceGui")) and not isOwn(o)
    end,
    function(o) local v = o.Enabled; o.Enabled = false; return v end,
    function(o, v) o.Enabled = v end
)

impl.decals = descendantFeature(
    function(o)
        return (o:IsA("Decal") or o:IsA("Texture")) and not isOwn(o)
    end,
    function(o) local v = o.Transparency; o.Transparency = 1; return v end,
    function(o, v) o.Transparency = v end
)

impl.materials = descendantFeature(
    function(o)
        return o:IsA("BasePart") and not o:IsA("Terrain") and not isOwn(o)
    end,
    function(o) local v = o.Material; o.Material = Enum.Material.SmoothPlastic; return v end,
    function(o, v) o.Material = v end
)

impl.accessories = descendantFeature(
    function(o)
        return o:IsA("Accessory") and not isOwn(o)
    end,
    function(o)
        local h = o:FindFirstChild("Handle")
        if not h then return nil end
        local v = h.Transparency
        h.Transparency = 1
        return v
    end,
    function(o, v)
        local h = o:FindFirstChild("Handle")
        if h and v ~= nil then h.Transparency = v end
    end
)

impl.sounds = descendantFeature(
    function(o)
        return o:IsA("Sound") and not isOwn(o) and not inCharacter(o)
    end,
    function(o) local v = o.Volume; o.Volume = 0; return v end,
    function(o, v) o.Volume = v end
)

do
    local state = nil
    impl.lighting = {
        apply = function()
            state = { fx = {} }
            pcall(function()
                state.shadows = Lighting.GlobalShadows
                Lighting.GlobalShadows = false
            end)
            pcall(function()
                state.fogEnd = Lighting.FogEnd
                Lighting.FogEnd = 9e8
            end)
            for _, c in ipairs(Lighting:GetChildren()) do
                pcall(function()
                    if c:IsA("PostEffect") then
                        table.insert(state.fx, { c, "Enabled", c.Enabled })
                        c.Enabled = false
                    elseif c:IsA("Atmosphere") then
                        table.insert(state.fx, { c, "Density", c.Density })
                        c.Density = 0
                    end
                end)
            end
        end,
        revert = function()
            if not state then return end
            pcall(function() if state.shadows ~= nil then Lighting.GlobalShadows = state.shadows end end)
            pcall(function() if state.fogEnd ~= nil then Lighting.FogEnd = state.fogEnd end end)
            for _, item in ipairs(state.fx) do
                pcall(function() item[1][item[2]] = item[3] end)
            end
            state = nil
        end,
    }
end

do
    local state = nil
    impl.terrain = {
        apply = function()
            local t = Workspace:FindFirstChildOfClass("Terrain")
            if not t then return end
            state = {}
            for _, prop in ipairs({ "WaterWaveSize", "WaterWaveSpeed", "WaterReflectance" }) do
                pcall(function()
                    state[prop] = t[prop]
                    t[prop] = 0
                end)
            end
            pcall(function()
                state.Decoration = t.Decoration
                t.Decoration = false
            end)
        end,
        revert = function()
            local t = Workspace:FindFirstChildOfClass("Terrain")
            if not t or not state then return end
            for prop, v in pairs(state) do
                pcall(function() t[prop] = v end)
            end
            state = nil
        end,
    }
end

do
    local old = nil
    impl.quality = {
        apply = function()
            pcall(function()
                old = settings().Rendering.QualityLevel
                settings().Rendering.QualityLevel = Enum.QualityLevel.Level01
            end)
        end,
        revert = function()
            pcall(function()
                if old then settings().Rendering.QualityLevel = old end
            end)
            old = nil
        end,
    }
end

do
    local running = false
    impl.gc = {
        apply = function()
            running = true
            task.spawn(function()
                while running do
                    task.wait(60)
                    if not running then break end
                    pcall(function() collectgarbage("collect") end)
                end
            end)
        end,
        revert = function()
            running = false
        end,
    }
end

impl.render3d = {
    apply = function()
        pcall(function() RunService:Set3dRenderingEnabled(false) end)
    end,
    revert = function()
        pcall(function() RunService:Set3dRenderingEnabled(true) end)
    end,
}

-- ==================== CATUN FEATURES ====================

do
    local targeting = false
    local currentTarget = nil
    local autoTargetConn = nil
    
    impl.autotarget = {
        apply = function()
            targeting = true
            autoTargetConn = RunService.RenderStepped:Connect(function()
                if not targeting then return end
                
                local char = LocalPlayer.Character
                if not char or not char:FindFirstChild("HumanoidRootPart") then
                    currentTarget = nil
                    return
                end
                
                local playerPos = char.HumanoidRootPart.Position
                local camera = workspace.CurrentCamera
                local maxRange = 30 * 5
                
                if currentTarget and currentTarget.Parent then
                    local targetHum = currentTarget.Parent:FindFirstChild("Humanoid")
                    if targetHum and targetHum.Health <= 0 then
                        currentTarget = nil
                    end
                else
                    currentTarget = nil
                end
                
                local nearest = currentTarget
                local nearestDist = currentTarget and (currentTarget.Position - playerPos).Magnitude or maxRange
                
                for _, enemy in ipairs(Workspace:GetDescendants()) do
                    if enemy:IsA("Model") and enemy ~= char and enemy:FindFirstChild("Humanoid") then
                        local humanoid = enemy.Humanoid
                        local rootPart = enemy:FindFirstChild("HumanoidRootPart")
                        
                        if humanoid and rootPart and humanoid.Health > 0 then
                            local dist = (rootPart.Position - playerPos).Magnitude
                            
                            if dist < nearestDist and dist < maxRange then
                                local relPos = rootPart.Position - camera.CFrame.Position
                                local camForward = camera.CFrame.LookVector
                                local angle = math.deg(math.acos(math.min(1, relPos.Unit:Dot(camForward))))
                                
                                if angle < 70 then
                                    nearest = rootPart
                                    nearestDist = dist
                                end
                            end
                        end
                    end
                end
                
                currentTarget = nearest
            end)
        end,
        revert = function()
            targeting = false
            if autoTargetConn then
                autoTargetConn:Disconnect()
                autoTargetConn = nil
            end
            currentTarget = nil
        end,
    }
end

do
    local healthMult = 2
    local healthConn = nil
    
    impl.healthmult = {
        apply = function()
            healthMult = 2
            healthConn = RunService.Heartbeat:Connect(function()
                local char = LocalPlayer.Character
                if not char then return end
                local humanoid = char:FindFirstChild("Humanoid")
                if humanoid then
                    humanoid.MaxHealth = 100 * healthMult
                    if humanoid.Health <= 0 then
                        humanoid.Health = humanoid.MaxHealth
                    elseif humanoid.Health < humanoid.MaxHealth then
                        humanoid.Health = humanoid.MaxHealth
                    end
                end
            end)
        end,
        revert = function()
            if healthConn then
                healthConn:Disconnect()
                healthConn = nil
            end
            local char = LocalPlayer.Character
            if char then
                local humanoid = char:FindFirstChild("Humanoid")
                if humanoid then
                    humanoid.MaxHealth = 100
                    humanoid.Health = math.min(humanoid.Health, 100)
                end
            end
        end,
    }
end

do
    local damageMult = 2
    local damageConn = nil
    
    impl.damagemult = {
        apply = function()
            damageMult = 2
            
            damageConn = RunService.Heartbeat:Connect(function()
                local char = LocalPlayer.Character
                if not char then return end
                
                for _, tool in ipairs(char:GetChildren()) do
                    if tool:IsA("Tool") then
                        pcall(function()
                            if tool:FindFirstChild("Damage") then
                                tool.Damage.Value = math.floor((tool.Damage.Value or 10) * damageMult)
                            end
                            
                            if tool:FindFirstChild("Config") then
                                local config = tool.Config
                                if config:FindFirstChild("Damage") then
                                    config.Damage.Value = math.floor((config.Damage.Value or 10) * damageMult)
                                end
                            end
                        end)
                    end
                end
            end)
        end,
        revert = function()
            if damageConn then
                damageConn:Disconnect()
                damageConn = nil
            end
            damageMult = 1
        end,
    }
end

do
    local ammoConn = nil
    local UNLIMITED_AMMO = 9999
    
    impl.unlimitedammo = {
        apply = function()
            ammoConn = RunService.Heartbeat:Connect(function()
                local char = LocalPlayer.Character
                if not char then return end
                
                for _, tool in ipairs(char:GetChildren()) do
                    if tool:IsA("Tool") then
                        pcall(function()
                            if tool:FindFirstChild("Ammo") and tool.Ammo:IsA("IntValue") then
                                tool.Ammo.Value = UNLIMITED_AMMO
                            end
                            
                            if tool:FindFirstChild("Config") then
                                local config = tool.Config
                                if config:FindFirstChild("Ammo") then
                                    config.Ammo.Value = UNLIMITED_AMMO
                                end
                                if config:FindFirstChild("MaxAmmo") then
                                    config.MaxAmmo.Value = UNLIMITED_AMMO
                                end
                            end
                            
                            if tool:FindFirstChild("Storage") then
                                for _, item in ipairs(tool.Storage:GetChildren()) do
                                    if item:IsA("IntValue") then
                                        item.Value = UNLIMITED_AMMO
                                    end
                                end
                            end
                        end)
                    end
                end
                
                local backpack = LocalPlayer:FindFirstChild("Backpack")
                if backpack then
                    for _, tool in ipairs(backpack:GetChildren()) do
                        if tool:IsA("Tool") then
                            pcall(function()
                                if tool:FindFirstChild("Ammo") and tool.Ammo:IsA("IntValue") then
                                    tool.Ammo.Value = UNLIMITED_AMMO
                                end
                                if tool:FindFirstChild("Config") then
                                    local config = tool.Config
                                    if config:FindFirstChild("Ammo") then
                                        config.Ammo.Value = UNLIMITED_AMMO
                                    end
                                end
                            end)
                        end
                    end
                end
            end)
        end,
        revert = function()
            if ammoConn then
                ammoConn:Disconnect()
                ammoConn = nil
            end
        end,
    }
end

-- ==================== FEATURES ARRAY ====================
local fixlagFeatures = {
    { key = "fx",          label = "Xóa hiệu ứng lửa/khói/tia người khác" },
    { key = "lights",      label = "Tắt đèn & bảng UI 3D" },
    { key = "decals",      label = "Xóa ảnh dán trang trí" },
    { key = "materials",   label = "Bề mặt phẳng" },
    { key = "accessories", label = "Ẩn phụ kiện người chơi khác" },
    { key = "sounds",      label = "Tắt âm thanh môi trường" },
    { key = "lighting",    label = "Tắt bóng đổ, sương mù" },
    { key = "terrain",     label = "Tối ưu nước & địa hình" },
    { key = "quality",     label = "Đồ họa Roblox mức thấp" },
    { key = "gc",          label = "Tự dọn RAM mỗi 60 giây" },
    { key = "render3d",    label = "Tắt 3D khi AFK" },
}

local catunFeatures = {
    { key = "autotarget",    label = "🎯 Auto-ghim quái gần nhất" },
    { key = "healthmult",    label = "❤️ Tăng máu (nhân đôi)" },
    { key = "damagemult",    label = "⚔️ Tăng sát thương" },
    { key = "unlimitedammo", label = "🔫 Vô hạn đạn" },
}

local function setFeature(f, on)
    if f.on == on then return end
    f.on = on
    local fn = on and impl[f.key].apply or impl[f.key].revert
    local ok, err = pcall(fn)
    if not ok then
        warn("[Catun] " .. f.key .. ": " .. tostring(err))
    end
    if f.refresh then f.refresh() end
end

-- ==================== GIAO DIỆN ====================
local function round(inst, r)
    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(0, r)
    c.Parent = inst
end

local function removeOld()
    local parents = {}
    pcall(function() table.insert(parents, LocalPlayer:FindFirstChild("PlayerGui")) end)
    pcall(function() table.insert(parents, game:GetService("CoreGui")) end)
    pcall(function() if gethui then table.insert(parents, gethui()) end end)
    for _, p in ipairs(parents) do
        pcall(function()
            local old = p:FindFirstChild(GUI_NAME)
            if old then old:Destroy() end
        end)
    end
end

local function makeDraggable(handle, target, onTap)
    local dragging = false
    local moved = false
    local dragStart, startPos

    handle.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.Touch
            or input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            moved = false
            dragStart = input.Position
            startPos = target.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                    if not moved and onTap then onTap() end
                end
            end)
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.Touch
            or input.UserInputType == Enum.UserInputType.MouseMovement) then
            local d = input.Position - dragStart
            if d.Magnitude > 8 then moved = true end
            if moved then
                target.Position = UDim2.new(
                    startPos.X.Scale, startPos.X.Offset + d.X,
                    startPos.Y.Scale, startPos.Y.Offset + d.Y
                )
            end
        end
    end)
end

local function buildUI()
    removeOld()
    
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

    -- NÚT CHẤM NHỎ
    local dotBtn = Instance.new("TextButton")
    dotBtn.Name = "DotButton"
    dotBtn.Size = UDim2.new(0, 40, 0, 40)
    dotBtn.Position = UDim2.new(0, 12, 0.35, 0)
    dotBtn.BackgroundColor3 = PURPLE
    dotBtn.Text = "•"
    dotBtn.TextSize = 32
    dotBtn.TextColor3 = Color3.new(1, 1, 1)
    dotBtn.Font = Enum.Font.GothamBold
    dotBtn.AutoButtonColor = false
    dotBtn.BorderSizePixel = 0
    dotBtn.ZIndex = 10
    dotBtn.Parent = gui
    round(dotBtn, 20)

    -- BẢNG CHÍNH
    local panel = Instance.new("Frame")
    panel.Name = "MainPanel"
    panel.AnchorPoint = Vector2.new(0.5, 0.5)
    panel.Position = UDim2.new(0.5, 0, 0.5, 0)
    panel.Size = UDim2.new(0.85, 0, 0.8, 0)
    panel.BackgroundColor3 = Color3.fromRGB(28, 28, 38)
    panel.BorderSizePixel = 0
    panel.Visible = false
    panel.ZIndex = 5
    panel.Parent = gui
    round(panel, 16)

    local sizeLimit = Instance.new("UISizeConstraint")
    sizeLimit.MaxSize = Vector2.new(380, 500)
    sizeLimit.Parent = panel

    -- THANH TIÊU ĐỀ
    local header = Instance.new("Frame")
    header.Size = UDim2.new(1, 0, 0, 50)
    header.BackgroundColor3 = PURPLE
    header.BorderSizePixel = 0
    header.ZIndex = 6
    header.Parent = panel
    round(header, 16)

    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1, -50, 1, 0)
    title.Position = UDim2.new(0, 12, 0, 0)
    title.BackgroundTransparency = 1
    title.Text = "🎯 CATUN MENU"
    title.TextColor3 = Color3.new(1, 1, 1)
    title.TextSize = 18
    title.Font = Enum.Font.GothamBold
    title.TextXAlignment = Enum.TextXAlignment.Left
    title.ZIndex = 7
    title.Parent = header

    local fpsLabel = Instance.new("TextLabel")
    fpsLabel.Size = UDim2.new(0, 80, 1, 0)
    fpsLabel.Position = UDim2.new(1, -90, 0, 0)
    fpsLabel.BackgroundTransparency = 1
    fpsLabel.Text = "FPS: --"
    fpsLabel.TextColor3 = Color3.new(1, 1, 1)
    fpsLabel.TextSize = 12
    fpsLabel.Font = Enum.Font.Gotham
    fpsLabel.ZIndex = 7
    fpsLabel.Parent = header

    local closeBtn = Instance.new("TextButton")
    closeBtn.Size = UDim2.new(0, 34, 0, 34)
    closeBtn.Position = UDim2.new(1, -40, 0, 8)
    closeBtn.BackgroundColor3 = Color3.fromRGB(200, 40, 40)
    closeBtn.Text = "✕"
    closeBtn.TextColor3 = Color3.new(1, 1, 1)
    closeBtn.TextSize = 16
    closeBtn.Font = Enum.Font.GothamBold
    closeBtn.BorderSizePixel = 0
    closeBtn.ZIndex = 8
    closeBtn.Parent = header
    round(closeBtn, 8)
    closeBtn.Activated:Connect(function() panel.Visible = false end)

    -- NÚT TAB
    local tabContainer = Instance.new("Frame")
    tabContainer.Size = UDim2.new(1, -12, 0, 40)
    tabContainer.Position = UDim2.new(0, 6, 0, 54)
    tabContainer.BackgroundTransparency = 1
    tabContainer.ZIndex = 6
    tabContainer.Parent = panel

    local tabLayout = Instance.new("UIListLayout")
    tabLayout.FillDirection = Enum.FillDirection.Horizontal
    tabLayout.Padding = UDim.new(0, 6)
    tabLayout.Parent = tabContainer

    local currentTab = "fixlag"

    local function createTabButton(text, tabName)
        local b = Instance.new("TextButton")
        b.Size = UDim2.new(0.5, -3, 1, 0)
        b.BackgroundColor3 = Color3.fromRGB(100, 50, 150)
        b.Text = text
        b.TextColor3 = Color3.new(1, 1, 1)
        b.TextSize = 13
        b.Font = Enum.Font.GothamBold
        b.BorderSizePixel = 0
        b.ZIndex = 7
        b.Parent = tabContainer
        round(b, 8)
        b.Name = tabName
        return b
    end

    local fixlagBtn = createTabButton("⚡ FIX LAG", "fixlag")
    local catunBtn = createTabButton("🎯 CATUN", "catun")

    -- DANH SÁCH FEATURES
    local list = Instance.new("ScrollingFrame")
    list.Size = UDim2.new(1, -12, 1, -110)
    list.Position = UDim2.new(0, 6, 0, 100)
    list.BackgroundTransparency = 1
    list.BorderSizePixel = 0
    list.ScrollBarThickness = 6
    list.CanvasSize = UDim2.new(0, 0, 0, 0)
    list.AutomaticCanvasSize = Enum.AutomaticSize.Y
    list.ZIndex = 6
    list.Parent = panel

    local listLayout = Instance.new("UIListLayout")
    listLayout.Padding = UDim.new(0, 6)
    listLayout.Parent = list

    local function addFeatureRow(feature, category)
        feature.on = false

        local row = Instance.new("Frame")
        row.Size = UDim2.new(1, -8, 0, 42)
        row.BackgroundColor3 = Color3.fromRGB(45, 45, 58)
        row.BorderSizePixel = 0
        row.ZIndex = 7
        row.Parent = list
        row.Visible = (category == currentTab)
        round(row, 8)

        local catTag = Instance.new("StringValue")
        catTag.Name = "Category"
        catTag.Value = category
        catTag.Parent = row

        local label = Instance.new("TextLabel")
        label.Size = UDim2.new(1, -74, 1, 0)
        label.Position = UDim2.new(0, 10, 0, 0)
        label.BackgroundTransparency = 1
        label.Text = feature.label
        label.TextWrapped = true
        label.TextColor3 = Color3.new(1, 1, 1)
        label.TextSize = 11
        label.Font = Enum.Font.Gotham
        label.TextXAlignment = Enum.TextXAlignment.Left
        label.ZIndex = 8
        label.Parent = row

        local toggle = Instance.new("TextButton")
        toggle.Size = UDim2.new(0, 60, 0, 28)
        toggle.Position = UDim2.new(1, -66, 0.5, -14)
        toggle.TextColor3 = Color3.new(1, 1, 1)
        toggle.TextSize = 11
        toggle.Font = Enum.Font.GothamBold
        toggle.BorderSizePixel = 0
        toggle.ZIndex = 8
        toggle.Parent = row
        round(toggle, 6)

        feature.refresh = function()
            toggle.Text = feature.on and "BẬT" or "TẮT"
            toggle.BackgroundColor3 = feature.on and Color3.fromRGB(0, 170, 80) or Color3.fromRGB(120, 50, 50)
        end
        feature.refresh()

        toggle.Activated:Connect(function()
            setFeature(feature, not feature.on)
        end)

        return row
    end

    local featureRows = {}
    for _, f in ipairs(fixlagFeatures) do
        table.insert(featureRows, addFeatureRow(f, "fixlag"))
    end
    for _, f in ipairs(catunFeatures) do
        table.insert(featureRows, addFeatureRow(f, "catun"))
    end

    local function switchTab(tabName)
        currentTab = tabName
        fixlagBtn.BackgroundColor3 = tabName == "fixlag" and Color3.fromRGB(100, 50, 150) or Color3.fromRGB(45, 45, 58)
        catunBtn.BackgroundColor3 = tabName == "catun" and Color3.fromRGB(100, 50, 150) or Color3.fromRGB(45, 45, 58)

        for _, row in ipairs(list:GetChildren()) do
            if row:IsA("Frame") and row:FindFirstChild("Category") then
                row.Visible = row.Category.Value == tabName
            end
        end
    end

    fixlagBtn.Activated:Connect(function() switchTab("fixlag") end)
    catunBtn.Activated:Connect(function() switchTab("catun") end)

    -- NÚT HÀNH ĐỘNG
    local actionContainer = Instance.new("Frame")
    actionContainer.Size = UDim2.new(1, -12, 0, 36)
    actionContainer.Position = UDim2.new(0, 6, 1, -42)
    actionContainer.BackgroundTransparency = 1
    actionContainer.ZIndex = 6
    actionContainer.Parent = panel

    local actionLayout = Instance.new("UIListLayout")
    actionLayout.FillDirection = Enum.FillDirection.Horizontal
    actionLayout.Padding = UDim.new(0, 4)
    actionLayout.Parent = actionContainer

    local function actionButton(text, color, callback)
        local b = Instance.new("TextButton")
        b.Size = UDim2.new(0.333, -3, 1, 0)
        b.BackgroundColor3 = color
        b.Text = text
        b.TextColor3 = Color3.new(1, 1, 1)
        b.TextSize = 11
        b.Font = Enum.Font.GothamBold
        b.BorderSizePixel = 0
        b.ZIndex = 7
        b.Parent = actionContainer
        round(b, 6)
        b.Activated:Connect(callback)
        return b
    end

    actionButton("BẬT TẤT CẢ", Color3.fromRGB(0, 150, 70), function()
        local features = currentTab == "fixlag" and fixlagFeatures or catunFeatures
        for _, f in ipairs(features) do
            setFeature(f, true)
        end
    end)

    actionButton("TẮT TẤT CẢ", Color3.fromRGB(170, 50, 50), function()
        local features = currentTab == "fixlag" and fixlagFeatures or catunFeatures
        for _, f in ipairs(features) do
            setFeature(f, false)
        end
    end)

    local ramBtn
    ramBtn = actionButton("DỌN RAM", Color3.fromRGB(70, 100, 200), function()
        pcall(function() collectgarbage("collect") end)
        ramBtn.Text = "✓"
        task.delay(1.5, function()
            if ramBtn then ramBtn.Text = "DỌN RAM" end
        end)
    end)

    -- KÉO ĐƯỢC
    makeDraggable(dotBtn, dotBtn, function()
        panel.Visible = not panel.Visible
    end)
    makeDraggable(header, panel, nil)

    -- TÍNH FPS
    local frames, last = 0, os.clock()
    local fpsConn = RunService.RenderStepped:Connect(function()
        frames = frames + 1
        local now = os.clock()
        if now - last >= 0.5 then
            fpsLabel.Text = "FPS: " .. math.floor(frames / (now - last) + 0.5)
            frames = 0
            last = now
        end
    end)

    return gui, fpsConn
end

-- ==================== KHỞI CHẠY ====================
local okUI, gui, fpsConn = pcall(buildUI)
if not okUI then
    warn("[Catun] Lỗi tạo menu: " .. tostring(gui))
    return
end

genv.__CATUN_CLEANUP = function()
    for _, f in ipairs(fixlagFeatures) do
        if f.on then
            f.on = false
            pcall(impl[f.key].revert)
        end
    end
    for _, f in ipairs(catunFeatures) do
        if f.on then
            f.on = false
            pcall(impl[f.key].revert)
        end
    end
    if fpsConn then fpsConn:Disconnect() end
    if gui then gui:Destroy() end
end

print("✓ Dead Rails Catun v1.0 đã tải - bấm chấm nhỏ •  để mở menu")
