--[[
================================================================
  QUY OUTFIT - PLUGIN CAI DAT NHANH
----------------------------------------------------------------
  CACH CAI (lam 1 LAN DUY NHAT, dung cho MOI game sau nay):

  1. Mo Roblox Studio (mo game nao cung duoc, hoac Baseplate trong).
  2. Vao tab "PLUGINS" > "Plugins Folder" (mo thu muc Plugins).
  3. Doi ten file nay thanh gi cung duoc, duoi ".lua",
     copy vao dung thu muc Plugins do.
  4. Dong va mo lai Roblox Studio.
  5. Se thay 1 nut moi ten "Cai Quy Outfit" trong tab Plugins.

  CACH DUNG (cho TUNG GAME):
  - Mo game do trong Studio.
  - Bam nut "Cai Quy Outfit" 1 cai.
  - Xong! Server + Client tu dong duoc tao dung cho, dung ten,
    khong can sua gi het. Bam Publish la choi duoc.
  - Lan sau ban sua/nang cap script nay (file plugin), chi can
    bam lai nut do o game cu la no TU CAP NHAT code moi (khong
    tao trung/lap).
================================================================
--]]

local ChangeHistoryService = game:GetService("ChangeHistoryService")
local ServerScriptService  = game:GetService("ServerScriptService")
local StarterPlayer        = game:GetService("StarterPlayer")

local SERVER_NAME = "QuyOutfitServer"
local CLIENT_NAME = "QuyOutfitClient"

-- ============================================================
-- CODE SERVER (nhung y het ban SERVER da co, khong doi logic)
-- ============================================================
local SERVER_SOURCE = [====[
local Players            = game:GetService("Players")
local ReplicatedStorage  = game:GetService("ReplicatedStorage")
local MarketplaceService = game:GetService("MarketplaceService")
local InsertService      = game:GetService("InsertService")

local CONFIG = {
    RemoteName    = "QuyOutfitRemote",
    Cooldown      = 0.6,
    KeepOnRespawn = true,
}

local remote = ReplicatedStorage:FindFirstChild(CONFIG.RemoteName)
if not remote then
    remote = Instance.new("RemoteFunction")
    remote.Name = CONFIG.RemoteName
    remote.Parent = ReplicatedStorage
end

local original = {}
local current  = {}
local modified = {}
local busy     = {}
local lastUse  = {}
local typeCache = {}
local forced    = {}
local assetCache = {}

local FORCE_ATTR = "QuyForced"

local ACC_TYPES = {
    [8]  = "Hat",  [41] = "Hair", [42] = "Face", [43] = "Neck", [44] = "Shoulder",
    [45] = "Front", [46] = "Back", [47] = "Waist",
    [64] = "TShirt", [65] = "Shirt", [66] = "Pants", [67] = "Jacket", [68] = "Sweater",
    [69] = "Shorts", [70] = "LeftShoe", [71] = "RightShoe", [72] = "DressSkirt",
    [76] = "Eyebrow", [77] = "Eyelash",
}
local LAYERED = { [64]=true, [65]=true, [66]=true, [67]=true, [68]=true,
                  [69]=true, [70]=true, [71]=true, [72]=true }
local DESC_PROPS = {
    [2] = "GraphicTShirt", [11] = "Shirt", [12] = "Pants", [18] = "Face",
    [17] = "Head", [79] = "Head", [27] = "Torso",
    [28] = "RightArm", [29] = "LeftArm", [30] = "LeftLeg", [31] = "RightLeg",
}

local function getHumanoid(player)
    local c = player.Character
    return c and c:FindFirstChildOfClass("Humanoid") or nil
end

local function assetTypeId(id)
    local c = typeCache[id]
    if c then return c end
    local ok, info = pcall(function()
        return MarketplaceService:GetProductInfo(id, Enum.InfoType.Asset)
    end)
    if ok and info and info.AssetTypeId then
        typeCache[id] = info.AssetTypeId
        return info.AssetTypeId
    end
    return nil
end

local function addAsset(desc, id)
    local t = assetTypeId(id)
    if not t then return false end

    local prop = DESC_PROPS[t]
    if prop then
        desc[prop] = id
        return true
    end

    local accName = ACC_TYPES[t]
    if accName then
        local accType = Enum.AccessoryType[accName]
        local list, maxOrder = {}, 0
        for _, a in ipairs(desc:GetAccessories(true)) do
            if a.AccessoryType ~= accType then list[#list + 1] = a end
            maxOrder = math.max(maxOrder, a.Order or 0)
        end
        list[#list + 1] = {
            Order = maxOrder + 1,
            AssetId = id,
            AccessoryType = accType,
            IsLayered = LAYERED[t] or false,
        }
        desc:SetAccessories(list, true)
        return true
    end
    return false
end

local function addBundle(desc, bundleId)
    local ok, info = pcall(function()
        return MarketplaceService:GetProductInfo(bundleId, Enum.InfoType.Bundle)
    end)
    if not ok or not info or not info.Items then return false end
    local any = false
    for _, it in ipairs(info.Items) do
        if it.Type == "Asset" and addAsset(desc, it.Id) then any = true end
    end
    if not any then
        for _, it in ipairs(info.Items) do
            if it.Type == "UserOutfit" then
                local ok2, d = pcall(function()
                    return Players:GetHumanoidDescriptionFromOutfitId(it.Id)
                end)
                if ok2 and d then
                    for _, p in ipairs({ "Head", "Torso", "LeftArm", "RightArm", "LeftLeg", "RightLeg" }) do
                        desc[p] = d[p]
                    end
                    any = true
                end
            end
        end
    end
    return any
end

local function getTemplate(id)
    local t = assetCache[id]
    if t then return t end
    local ok, model = pcall(function() return InsertService:LoadAsset(id) end)
    if not ok or not model then
        warn("[QuyOutfit] LoadAsset that bai:", id, model)
        return nil
    end
    local acc = model:FindFirstChildOfClass("Accessory")
    if not acc then model:Destroy() return nil end
    acc.Parent = nil
    model:Destroy()
    assetCache[id] = acc
    return acc
end

local function attachForced(player)
    local char = player.Character
    local hum = getHumanoid(player)
    if not char or not hum or hum.Health <= 0 then return end
    for _, c in ipairs(char:GetChildren()) do
        if c:IsA("Accessory") and c:GetAttribute(FORCE_ATTR) then c:Destroy() end
    end
    local list = forced[player]
    if not list then return end
    for _, id in pairs(list) do
        local tpl = getTemplate(id)
        if tpl and player.Character == char then
            local a = tpl:Clone()
            a:SetAttribute(FORCE_ATTR, true)
            pcall(function() hum:AddAccessory(a) end)
        end
    end
end

local function extractLayered(player, desc, replaceAll)
    if replaceAll or not forced[player] then forced[player] = {} end
    local keep = {}
    for _, a in ipairs(desc:GetAccessories(true)) do
        if a.IsLayered and a.AssetId and a.AssetId > 0 then
            forced[player][a.AccessoryType.Name] = a.AssetId
        else
            keep[#keep + 1] = a
        end
    end
    desc:SetAccessories(keep, true)
end

local function applyDesc(player, desc, reset)
    local hum = getHumanoid(player)
    if not hum or hum.Health <= 0 then return false end
    local ok = pcall(function()
        if reset then
            hum:ApplyDescriptionReset(desc)
        else
            hum:ApplyDescription(desc)
        end
    end)
    if ok then attachForced(player) end
    return ok
end

local function ensureBase(player)
    local hum = getHumanoid(player)
    if not hum then return false end
    if not original[player] then
        local ok, d = pcall(function() return hum:GetAppliedDescription() end)
        if not ok or not d then
            ok, d = pcall(function()
                return Players:GetHumanoidDescriptionFromUserId(player.UserId)
            end)
        end
        if not ok or not d then return false end
        original[player] = d
    end
    if not current[player] then current[player] = original[player]:Clone() end
    return true
end

local function handleTry(player, payload)
    if type(payload) ~= "table" then return false, "invalid" end
    local id, itemType = payload.Id, payload.ItemType
    if type(id) ~= "number" or id ~= math.floor(id) or id <= 0 or id > 1e15 then
        return false, "invalid"
    end
    if itemType ~= "Asset" and itemType ~= "Bundle" then return false, "invalid" end
    if not ensureBase(player) then return false, "nochar" end

    local desc = current[player]:Clone()
    local added
    if itemType == "Bundle" then
        added = addBundle(desc, id)
    else
        added = addAsset(desc, id)
    end
    if not added then return false, "unsupported" end

    local backup = {}
    for k, v in pairs(forced[player] or {}) do backup[k] = v end
    extractLayered(player, desc, false)
    if not applyDesc(player, desc) then
        forced[player] = backup
        return false, "apply"
    end

    current[player] = desc
    modified[player] = true
    return true
end

local function handleUser(player, name)
    if type(name) ~= "string" then return false, "invalid" end
    name = name:match("^%s*(.-)%s*$")
    if #name < 1 or #name > 40 then return false, "invalid" end
    if not ensureBase(player) then return false, "nochar" end

    local desc, srcPlayer
    local lname = name:lower()
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= player and (p.Name:lower() == lname or p.DisplayName:lower() == lname) then
            local h = getHumanoid(p)
            if h then
                local ok, d = pcall(function() return h:GetAppliedDescription() end)
                if ok and d then desc = d; srcPlayer = p end
            end
            break
        end
    end
    if not desc then
        local ok, uid = pcall(function() return Players:GetUserIdFromNameAsync(name) end)
        if not ok then return false, "notfound" end
        local ok2, d = pcall(function() return Players:GetHumanoidDescriptionFromUserId(uid) end)
        if not ok2 or not d then return false, "notfound" end
        desc = d
    end

    local backup = {}
    for k, v in pairs(forced[player] or {}) do backup[k] = v end
    extractLayered(player, desc, true)
    if srcPlayer and forced[srcPlayer] then
        for slot, id in pairs(forced[srcPlayer]) do forced[player][slot] = id end
    end

    if not applyDesc(player, desc, true) then
        forced[player] = backup
        return false, "apply"
    end
    current[player] = desc:Clone()
    modified[player] = true
    return true, name
end

local function handleReset(player)
    if not original[player] then return false, "nothing" end
    local desc = original[player]:Clone()
    extractLayered(player, desc, true)
    if not applyDesc(player, desc, true) then return false, "apply" end
    current[player] = desc:Clone()
    modified[player] = nil
    return true
end

local function parseInput(text)
    if type(text) ~= "string" or #text > 300 then return nil end
    text = text:match("^%s*(.-)%s*$")

    local function num(s)
        if s and #s <= 15 then return tonumber(s) end
    end

    local n = num(text:match("^(%d+)$"))
    if n then return n, nil end

    n = num(text:match("/bundles/(%d+)"))
    if n then return n, "Bundle" end

    n = num(text:match("/catalog/(%d+)"))
        or num(text:match("/library/(%d+)"))
        or num(text:match("/marketplace/asset/(%d+)"))
        or num(text:match("rbxassetid://(%d+)"))
        or num(text:match("[?&][Ii][Dd]=(%d+)"))
    if n then return n, "Asset" end
    return nil
end

local function handleSearch(player, text)
    local id, kind = parseInput(text)
    if not id or id <= 0 then return false, "invalid" end
    if not kind then
        kind = assetTypeId(id) and "Asset" or "Bundle"
    end
    return handleTry(player, { Id = id, ItemType = kind })
end

remote.OnServerInvoke = function(player, action, payload)
    local now = os.clock()
    if busy[player] or (lastUse[player] and now - lastUse[player] < CONFIG.Cooldown) then
        return false, "cooldown"
    end
    lastUse[player] = now
    busy[player] = true

    local ok, res, msg = pcall(function()
        if action == "Try" then
            return handleTry(player, payload)
        elseif action == "User" then
            return handleUser(player, payload)
        elseif action == "Search" then
            return handleSearch(player, payload)
        elseif action == "Reset" then
            return handleReset(player)
        end
        return false, "invalid"
    end)

    busy[player] = nil
    lastUse[player] = os.clock()
    if not ok then
        warn("[QuyOutfit] loi:", res)
        return false, "error"
    end
    return res, msg
end

local function onAppearance(player)
    if not original[player] then
        ensureBase(player)
    elseif CONFIG.KeepOnRespawn and modified[player] and current[player] then
        applyDesc(player, current[player])
    end
end

local function onPlayerAdded(player)
    player.CharacterAppearanceLoaded:Connect(function()
        onAppearance(player)
    end)
end

Players.PlayerAdded:Connect(onPlayerAdded)
for _, p in ipairs(Players:GetPlayers()) do onPlayerAdded(p) end

Players.PlayerRemoving:Connect(function(player)
    original[player], current[player], modified[player] = nil, nil, nil
    forced[player] = nil
    busy[player], lastUse[player] = nil, nil
end)
]====]

-- ============================================================
-- CODE CLIENT (menu GUI, y het ban truoc)
-- ============================================================
local CLIENT_SOURCE = [====[
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local RemoteName = "QuyOutfitRemote"

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

local remote = ReplicatedStorage:WaitForChild(RemoteName, 15)
if not remote then
    warn("[QuyOutfit] Khong tim thay RemoteFunction '"..RemoteName.."'.")
    return
end

local ERR_TEXT = {
    invalid    = "Du lieu khong hop le.",
    nochar     = "Khong tim thay nhan vat.",
    unsupported= "Mon do nay khong ho tro.",
    apply      = "Loi khi mac do.",
    notfound   = "Khong tim thay nguoi choi / tai khoan nay.",
    cooldown   = "Ban thao tac qua nhanh, cho 1 chut.",
    error      = "Co loi xay ra o server.",
}

local gui = Instance.new("ScreenGui")
gui.Name = "QuyOutfitGui"
gui.ResetOnSpawn = false
gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
gui.Parent = playerGui

local toggleBtn = Instance.new("TextButton")
toggleBtn.Name = "ToggleButton"
toggleBtn.Size = UDim2.new(0, 56, 0, 56)
toggleBtn.Position = UDim2.new(0, 16, 0.5, -28)
toggleBtn.BackgroundColor3 = Color3.fromRGB(35, 35, 45)
toggleBtn.Text = "👕"
toggleBtn.TextScaled = true
toggleBtn.Font = Enum.Font.GothamBold
toggleBtn.TextColor3 = Color3.new(1, 1, 1)
toggleBtn.AutoButtonColor = true
toggleBtn.Parent = gui
Instance.new("UICorner", toggleBtn).CornerRadius = UDim.new(1, 0)

local main = Instance.new("Frame")
main.Name = "MainPanel"
main.Size = UDim2.new(0, 300, 0, 360)
main.Position = UDim2.new(0, 84, 0.5, -180)
main.BackgroundColor3 = Color3.fromRGB(28, 28, 36)
main.Visible = false
main.Parent = gui
Instance.new("UICorner", main).CornerRadius = UDim.new(0, 12)

local stroke = Instance.new("UIStroke", main)
stroke.Color = Color3.fromRGB(70, 70, 90)
stroke.Thickness = 1

local titleBar = Instance.new("Frame")
titleBar.Name = "TitleBar"
titleBar.Size = UDim2.new(1, 0, 0, 40)
titleBar.BackgroundColor3 = Color3.fromRGB(20, 20, 28)
titleBar.Parent = main
Instance.new("UICorner", titleBar).CornerRadius = UDim.new(0, 12)

local title = Instance.new("TextLabel")
title.BackgroundTransparency = 1
title.Size = UDim2.new(1, -40, 1, 0)
title.Position = UDim2.new(0, 12, 0, 0)
title.Text = "Quy Outfit"
title.TextXAlignment = Enum.TextXAlignment.Left
title.Font = Enum.Font.GothamBold
title.TextColor3 = Color3.new(1, 1, 1)
title.TextSize = 18
title.Parent = titleBar

local closeBtn = Instance.new("TextButton")
closeBtn.Size = UDim2.new(0, 32, 0, 32)
closeBtn.Position = UDim2.new(1, -36, 0, 4)
closeBtn.BackgroundColor3 = Color3.fromRGB(60, 30, 30)
closeBtn.Text = "X"
closeBtn.Font = Enum.Font.GothamBold
closeBtn.TextColor3 = Color3.new(1, 1, 1)
closeBtn.Parent = titleBar
Instance.new("UICorner", closeBtn).CornerRadius = UDim.new(0, 8)

local content = Instance.new("Frame")
content.BackgroundTransparency = 1
content.Size = UDim2.new(1, -24, 1, -52)
content.Position = UDim2.new(0, 12, 0, 46)
content.Parent = main

local layout = Instance.new("UIListLayout", content)
layout.Padding = UDim.new(0, 8)
layout.SortOrder = Enum.SortOrder.LayoutOrder

local function makeSection(order, labelText, placeholder, buttonText)
    local holder = Instance.new("Frame")
    holder.Size = UDim2.new(1, 0, 0, 70)
    holder.BackgroundTransparency = 1
    holder.LayoutOrder = order
    holder.Parent = content

    local lbl = Instance.new("TextLabel")
    lbl.BackgroundTransparency = 1
    lbl.Size = UDim2.new(1, 0, 0, 18)
    lbl.Text = labelText
    lbl.Font = Enum.Font.Gotham
    lbl.TextSize = 14
    lbl.TextColor3 = Color3.fromRGB(200, 200, 210)
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.Parent = holder

    local box = Instance.new("TextBox")
    box.Size = UDim2.new(1, -84, 0, 36)
    box.Position = UDim2.new(0, 0, 0, 24)
    box.PlaceholderText = placeholder
    box.Text = ""
    box.ClearTextOnFocus = false
    box.Font = Enum.Font.Gotham
    box.TextSize = 14
    box.TextColor3 = Color3.new(1, 1, 1)
    box.BackgroundColor3 = Color3.fromRGB(45, 45, 56)
    box.Parent = holder
    Instance.new("UICorner", box).CornerRadius = UDim.new(0, 8)
    local pad = Instance.new("UIPadding", box)
    pad.PaddingLeft = UDim.new(0, 8)
    pad.PaddingRight = UDim.new(0, 8)

    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0, 76, 0, 36)
    btn.Position = UDim2.new(1, -76, 0, 24)
    btn.Text = buttonText
    btn.Font = Enum.Font.GothamBold
    btn.TextSize = 14
    btn.TextColor3 = Color3.new(1, 1, 1)
    btn.BackgroundColor3 = Color3.fromRGB(70, 110, 220)
    btn.Parent = holder
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 8)

    return box, btn
end

local searchBox, searchBtn = makeSection(1, "Nhap ID / link san pham (hoac bundle):", "Vi du: 123456 hoac link roblox.com/...", "Mac thu")
local userBox, userBtn = makeSection(2, "Copy do dang mac cua nguoi choi:", "Ten nguoi choi", "Copy")

local resetBtn = Instance.new("TextButton")
resetBtn.LayoutOrder = 3
resetBtn.Size = UDim2.new(1, 0, 0, 36)
resetBtn.Text = "Tra ve do goc"
resetBtn.Font = Enum.Font.GothamBold
resetBtn.TextSize = 14
resetBtn.TextColor3 = Color3.new(1, 1, 1)
resetBtn.BackgroundColor3 = Color3.fromRGB(160, 60, 60)
resetBtn.Parent = content
Instance.new("UICorner", resetBtn).CornerRadius = UDim.new(0, 8)

local status = Instance.new("TextLabel")
status.LayoutOrder = 4
status.BackgroundTransparency = 1
status.Size = UDim2.new(1, 0, 0, 40)
status.Text = ""
status.TextWrapped = true
status.Font = Enum.Font.Gotham
status.TextSize = 13
status.TextColor3 = Color3.fromRGB(180, 220, 180)
status.Parent = content

local working = false

local function setStatus(text, isError)
    status.Text = text
    status.TextColor3 = isError and Color3.fromRGB(230, 110, 110) or Color3.fromRGB(150, 220, 150)
end

local function callRemote(action, payload, doneText)
    if working then return end
    working = true
    setStatus("Dang xu ly...", false)

    local ok, res, msg = pcall(function()
        return remote:InvokeServer(action, payload)
    end)

    working = false

    if not ok then
        setStatus("Loi ket noi toi server.", true)
        return
    end
    if res then
        setStatus(doneText or "Xong.", false)
    else
        setStatus(ERR_TEXT[msg] or ("Loi: " .. tostring(msg)), true)
    end
end

searchBtn.MouseButton1Click:Connect(function()
    local text = searchBox.Text
    if text == "" then setStatus("Nhap ID hoac link truoc da.", true) return end
    callRemote("Search", text, "Da mac thu!")
end)

userBtn.MouseButton1Click:Connect(function()
    local text = userBox.Text
    if text == "" then setStatus("Nhap ten nguoi choi truoc da.", true) return end
    callRemote("User", text, "Da copy do!")
end)

resetBtn.MouseButton1Click:Connect(function()
    callRemote("Reset", nil, "Da tra ve do goc!")
end)

searchBox.FocusLost:Connect(function(enterPressed)
    if enterPressed then searchBtn.MouseButton1Click:Fire() end
end)
userBox.FocusLost:Connect(function(enterPressed)
    if enterPressed then userBtn.MouseButton1Click:Fire() end
end)

local function setOpen(open)
    main.Visible = open
end

toggleBtn.MouseButton1Click:Connect(function()
    setOpen(not main.Visible)
end)
closeBtn.MouseButton1Click:Connect(function()
    setOpen(false)
end)

do
    local dragging, dragStart, startPos
    titleBar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1
            or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = main.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)
    titleBar.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement
            or input.UserInputType == Enum.UserInputType.Touch) then
            local delta = input.Position - dragStart
            main.Position = UDim2.new(
                startPos.X.Scale, startPos.X.Offset + delta.X,
                startPos.Y.Scale, startPos.Y.Offset + delta.Y
            )
        end
    end)
end
]====]

-- ============================================================
-- HAM CAI DAT: tao moi hoac cap nhat script co san
-- ============================================================
local function installScript(parent, name, className, source)
    local existing = parent:FindFirstChild(name)
    if existing then
        local ok = pcall(function() existing.Source = source end)
        if not ok then
            warn("[QuyOutfit] Khong the ghi de source cua "..name..". Studio co the chua cap quyen 'Script Injection' cho plugin nay. Vao File > Game Settings > Security, bat 'Allow Script Injection', hoac cho phep khi Studio hoi.")
        end
        return existing, ok
    else
        local s = Instance.new(className)
        s.Name = name
        local ok = pcall(function() s.Source = source end)
        s.Parent = parent
        if not ok then
            warn("[QuyOutfit] Da tao "..name.." nhung khong ghi duoc code. Hay cho phep 'Script Injection' roi bam lai nut.")
        end
        return s, ok
    end
end

local toolbar = plugin:CreateToolbar("Quy Outfit")
local button = toolbar:CreateButton(
    "Cai Quy Outfit",
    "Tu dong tao/cap nhat Server + Client cho he thong thu do trong game nay",
    "rbxassetid://4458901886"
)
button.ClickableWhenViewportHidden = true

button.Click:Connect(function()
    ChangeHistoryService:SetWaypoint("QuyOutfit_Before")

    local starterPlayerScripts = StarterPlayer:FindFirstChild("StarterPlayerScripts")
    if not starterPlayerScripts then
        warn("[QuyOutfit] Khong tim thay StarterPlayerScripts.")
        return
    end

    local _, okS = installScript(ServerScriptService, SERVER_NAME, "Script", SERVER_SOURCE)
    local _, okC = installScript(starterPlayerScripts, CLIENT_NAME, "LocalScript", CLIENT_SOURCE)

    ChangeHistoryService:SetWaypoint("QuyOutfit_After")

    if okS and okC then
        print("[QuyOutfit] Da cai dat xong! Bam Play de thu, hoac Publish game.")
    else
        print("[QuyOutfit] Cai dat xong nhung co canh bao o tren, doc ky.")
    end
end)
