--[[
	FIX LAG MENU (LocalScript)
	Đặt vào: StarterPlayer > StarterPlayerScripts

	- Chạy 100% phía client của CHÍNH BẠN: không ảnh hưởng server và người chơi khác.
	- Vùng tải kiểu Minecraft: chỉ giữ map / người chơi / NPC trong bán kính quanh nhân vật,
	  phần ngoài vùng bị gỡ khỏi Workspace (phía client), đi tới đâu tải lại tới đó.
	- Đơn vị bán kính là studs. 1 stud ≈ 0.28 m  (5 m ≈ 18 studs, 10 m ≈ 36 studs).
	- Phím mở/đóng menu: RightShift (hoặc bấm nút ⚡ bên trái màn hình).
	- Muốn một vật KHÔNG bao giờ bị ẩn (thang máy, bẫy di chuyển...): gắn tag "NoCull".
]]

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Lighting = game:GetService("Lighting")
local UserInputService = game:GetService("UserInputService")
local CollectionService = game:GetService("CollectionService")

local player = Players.LocalPlayer

--------------------------------------------------------------------------------
-- CẤU HÌNH
--------------------------------------------------------------------------------
local CONFIG = {
	RADIUS_DEFAULT = 150,
	RADIUS_MIN = 18, -- ≈ 5 m
	RADIUS_MAX = 600,
	STUD_TO_M = 0.28,

	CELL_SIZE = 32, -- kích thước ô lưới chia map
	HYSTERESIS = 16, -- đệm chống nhấp nháy ở mép vùng
	UPDATE_INTERVAL = 0.2, -- giây giữa 2 lần cập nhật vùng
	PARTS_PER_FRAME = 1500, -- giới hạn số part bật/tắt mỗi frame (chống giật)
	MAX_PART_EXTENT = 48, -- part lớn hơn mức này (sàn, baseplate...) luôn được giữ lại
	SCAN_CHUNK = 2500, -- số instance quét mỗi frame

	-- Các tag này KHÔNG bị ẩn (giữ cho Auto Farm / Auto Loot / ESP hoạt động)
	KEEP_TAGS = { "FarmableEnemy", "LootChest", "DevilFruit", "NoCull" },

	TOGGLE_KEY = Enum.KeyCode.RightShift,
}

--------------------------------------------------------------------------------
-- TRẠNG THÁI
--------------------------------------------------------------------------------
local FLAG_ORDER = {
	"cull", "cullPlayers", "cullNPC",
	"fogEdge", "fogOff",
	"shadows", "postfx", "particles", "lights",
	"simpleMaterial", "simpleSky", "lowTerrain", "lowQuality",
	"blank3d",
}

local flags = {}
for _, name in ipairs(FLAG_ORDER) do
	flags[name] = false
end

local radius = CONFIG.RADIUS_DEFAULT

-- forward declarations (UI gán sau)
local toast = function(_) end
local refreshAll = function() end
local setRadius = function(_) end

--------------------------------------------------------------------------------
-- LƯU / KHÔI PHỤC THUỘC TÍNH GỐC
--------------------------------------------------------------------------------
local saved = {} -- [group] = weak{ [instance] = { prop = originalValue } }

local function assign(inst, prop, value)
	inst[prop] = value
end

local function groupTable(group)
	local g = saved[group]
	if not g then
		g = setmetatable({}, { __mode = "k" })
		saved[group] = g
	end
	return g
end

-- Bản nhanh (không pcall) cho instance chắc chắn có thuộc tính
local function setFast(group, inst, prop, value)
	local g = groupTable(group)
	local p = g[inst]
	if not p then
		p = {}
		g[inst] = p
	end
	if p[prop] == nil then
		p[prop] = inst[prop]
	end
	inst[prop] = value
end

-- Bản an toàn (pcall) cho Lighting / Terrain / settings
local function setProp(group, inst, prop, value)
	local ok = pcall(function()
		setFast(group, inst, prop, value)
	end)
	return ok
end

local function isFresh(group, inst)
	local g = saved[group]
	return not (g and g[inst])
end

local function restoreGroup(group)
	local g = saved[group]
	if not g then
		return
	end
	saved[group] = nil
	for inst, props in pairs(g) do
		for prop, value in pairs(props) do
			pcall(assign, inst, prop, value)
		end
	end
end

--------------------------------------------------------------------------------
-- TAG GIỮ LẠI + NHẬN DIỆN NHÂN VẬT / NPC
--------------------------------------------------------------------------------
local excluded = {} -- [Instance] = true

for _, tag in ipairs(CONFIG.KEEP_TAGS) do
	for _, inst in ipairs(CollectionService:GetTagged(tag)) do
		excluded[inst] = true
	end
	CollectionService:GetInstanceAddedSignal(tag):Connect(function(inst)
		excluded[inst] = true
	end)
	CollectionService:GetInstanceRemovedSignal(tag):Connect(function(inst)
		excluded[inst] = nil
	end)
end

local humanoidCache = setmetatable({}, { __mode = "k" })

local function isEntityModel(model)
	local cached = humanoidCache[model]
	if cached == nil then
		cached = model:FindFirstChildOfClass("Humanoid") ~= nil
		humanoidCache[model] = cached
	end
	return cached
end

--------------------------------------------------------------------------------
-- VÙNG TẢI CHO MAP (lưới ô + hàng đợi chia nhỏ theo frame)
--------------------------------------------------------------------------------
local cells = {} -- [key] = cell
local partInfo = {} -- [part] = info
local showQ, hideQ = {}, {}
local showHead, hideHead = 1, 1
local cullStarted = false
local statHidden, statTotal = 0, 0

local function getCell(pos)
	local cs = CONFIG.CELL_SIZE
	local cx = math.clamp(math.floor(pos.X / cs), -2048, 2047)
	local cy = math.clamp(math.floor(pos.Y / cs), -2048, 2047)
	local cz = math.clamp(math.floor(pos.Z / cs), -2048, 2047)
	local key = ((cx + 2048) * 4096 + (cz + 2048)) * 4096 + (cy + 2048)
	local cell = cells[key]
	if not cell then
		cell = {
			parts = {},
			count = 0,
			wantHidden = false,
			dirty = false,
			dist = 0,
			maxExtent = 0,
			minX = cx * cs, minY = cy * cs, minZ = cz * cs,
			maxX = (cx + 1) * cs, maxY = (cy + 1) * cs, maxZ = (cz + 1) * cs,
		}
		cells[key] = cell
	end
	return cell
end

local function ancestorBlocked(part)
	local cam = workspace.CurrentCamera
	local a = part.Parent
	while a do
		if a == workspace then
			return false
		end
		if a == cam or excluded[a] then
			return true
		end
		if a:IsA("Model") and isEntityModel(a) then
			return true -- phần của nhân vật / NPC: xử lý ở hệ thống entity
		end
		a = a.Parent
	end
	return true -- không nằm trong Workspace
end

local function registerPart(part)
	if partInfo[part] or not part.Anchored then
		return -- chỉ cull part tĩnh (Anchored) để không phá vật lý / weld
	end
	if part:IsA("Terrain") or part:IsA("Seat") or part:IsA("VehicleSeat") or part:IsA("SpawnLocation") then
		return
	end
	local extent = part.Size.Magnitude * 0.5
	if extent > CONFIG.MAX_PART_EXTENT then
		return -- part khổng lồ (sàn, tường lớn) luôn giữ để không rơi xuyên map
	end
	if excluded[part] or ancestorBlocked(part) then
		return
	end

	local cell = getCell(part.Position)
	if extent > cell.maxExtent then
		cell.maxExtent = extent
	end
	local info = { hidden = false, parent = nil, cell = cell }
	cell.parts[part] = info
	cell.count += 1
	partInfo[part] = info

	if cell.wantHidden then
		cell.dirty = true
		hideQ[#hideQ + 1] = cell
	end
end

-- Áp trạng thái mong muốn lên toàn bộ part của 1 ô. Trả về số part đã xử lý.
local function applyCell(cell)
	cell.dirty = false
	local n = 0
	for part, info in pairs(cell.parts) do
		if cell.wantHidden then
			if not info.hidden then
				local parent = part.Parent
				if parent then
					info.parent = parent
					part.Parent = nil
					info.hidden = true
					n += 1
				else
					-- part đã bị game huỷ
					cell.parts[part] = nil
					cell.count -= 1
					partInfo[part] = nil
				end
			end
		elseif info.hidden then
			local parent = info.parent
			local ok = false
			if parent and parent:IsDescendantOf(game) then
				ok = pcall(assign, part, "Parent", parent)
			end
			if ok then
				info.hidden = false
				info.parent = nil
				n += 1
			else
				cell.parts[part] = nil
				cell.count -= 1
				partInfo[part] = nil
			end
		end
	end
	return n
end

local function processQueues()
	local budget = CONFIG.PARTS_PER_FRAME
	while budget > 0 do
		local cell
		if showHead <= #showQ then
			cell = showQ[showHead]
			showHead += 1
		elseif hideHead <= #hideQ then
			cell = hideQ[hideHead]
			hideHead += 1
		else
			break
		end
		if cell.dirty then
			budget -= math.max(applyCell(cell), 1)
		end
	end
	if showHead > #showQ then
		showQ, showHead = {}, 1
	end
	if hideHead > #hideQ then
		hideQ, hideHead = {}, 1
	end
end

local function updateCells(pos)
	local cullOn = flags.cull
	local hyst = CONFIG.HYSTERESIS
	local showList = {}
	local hiddenTotal, total = 0, 0

	for _, cell in pairs(cells) do
		local m = cell.maxExtent
		local dx = math.max(cell.minX - m - pos.X, 0, pos.X - (cell.maxX + m))
		local dy = math.max(cell.minY - m - pos.Y, 0, pos.Y - (cell.maxY + m))
		local dz = math.max(cell.minZ - m - pos.Z, 0, pos.Z - (cell.maxZ + m))
		local d = math.sqrt(dx * dx + dy * dy + dz * dz)
		cell.dist = d

		local want = cell.wantHidden
		if not cullOn or d <= radius then
			want = false
		elseif d > radius + hyst then
			want = true
		end

		if want ~= cell.wantHidden then
			cell.wantHidden = want
			cell.dirty = true
			if want then
				hideQ[#hideQ + 1] = cell
			else
				showList[#showList + 1] = cell
			end
		end

		total += cell.count
		if cell.wantHidden then
			hiddenTotal += cell.count
		end
	end

	if #showList > 0 then
		-- ô gần người chơi nhất được tải trước (tránh rơi xuyên map)
		table.sort(showList, function(a, b)
			return a.dist < b.dist
		end)
		for _, cell in ipairs(showList) do
			showQ[#showQ + 1] = cell
		end
	end

	statHidden, statTotal = hiddenTotal, total
end

local function buildIndex()
	if cullStarted then
		return
	end
	cullStarted = true
	task.spawn(function()
		local list = workspace:GetDescendants()
		for i, inst in ipairs(list) do
			if inst:IsA("BasePart") then
				registerPart(inst)
			end
			if i % CONFIG.SCAN_CHUNK == 0 then
				task.wait()
			end
		end
	end)
end

--------------------------------------------------------------------------------
-- VÙNG TẢI CHO NGƯỜI CHƠI KHÁC + NPC
--------------------------------------------------------------------------------
local entities = {} -- [Model] = { hidden, parent, kind, owner }
local statEntitiesHidden = 0

local function trackNPC(hum)
	local model = hum.Parent
	if not model or not model:IsA("Model") then
		return
	end
	if model == player.Character or Players:GetPlayerFromCharacter(model) or excluded[model] then
		return
	end
	if not entities[model] then
		entities[model] = { hidden = false, parent = nil, kind = "npc" }
	end
end

local function updateEntities(pos)
	if flags.cullPlayers then
		for _, plr in ipairs(Players:GetPlayers()) do
			local char = plr.Character
			if plr ~= player and char and not entities[char] then
				entities[char] = { hidden = false, parent = nil, kind = "player", owner = plr }
			end
		end
	end

	local hiddenCount = 0
	local hyst = CONFIG.HYSTERESIS

	for model, rec in pairs(entities) do
		-- còn tồn tại không?
		local alive
		if rec.kind == "player" then
			alive = rec.owner ~= nil and rec.owner.Parent == Players and rec.owner.Character == model
		elseif rec.hidden then
			alive = rec.parent ~= nil and rec.parent:IsDescendantOf(game)
		else
			alive = model:IsDescendantOf(workspace)
		end

		if not alive then
			if rec.hidden then
				pcall(model.Destroy, model)
			end
			entities[model] = nil
		else
			local enabled = (rec.kind == "player" and flags.cullPlayers) or (rec.kind == "npc" and flags.cullNPC)
			local okPivot, pivot = pcall(model.GetPivot, model)
			if okPivot then
				local d = (pivot.Position - pos).Magnitude - 4
				if rec.hidden then
					if not enabled or d <= radius then
						if pcall(assign, model, "Parent", rec.parent) then
							rec.hidden = false
							rec.parent = nil
						end
					end
				elseif enabled and d > radius + hyst then
					rec.parent = model.Parent
					if rec.parent then
						model.Parent = nil
						rec.hidden = true
					end
				end
			end
			if rec.hidden then
				hiddenCount += 1
			end
		end
	end

	statEntitiesHidden = hiddenCount
end

--------------------------------------------------------------------------------
-- GIẢM HIỆU ỨNG THEO TỪNG INSTANCE
--------------------------------------------------------------------------------
local PARTICLE_SET = { ParticleEmitter = true, Trail = true, Beam = true, Fire = true, Smoke = true, Sparkles = true }
local LIGHT_SET = { PointLight = true, SpotLight = true, SurfaceLight = true }
local POST_SET = {
	BloomEffect = true, BlurEffect = true, ColorCorrectionEffect = true,
	DepthOfFieldEffect = true, SunRaysEffect = true,
}

local function applyToInstance(inst)
	local cls = inst.ClassName

	if flags.particles and PARTICLE_SET[cls] then
		if isFresh("particles", inst) then
			setFast("particles", inst, "Enabled", false)
		end
	elseif flags.lights and LIGHT_SET[cls] then
		if isFresh("lights", inst) then
			setFast("lights", inst, "Enabled", false)
		end
	elseif flags.postfx and POST_SET[cls] then
		if isFresh("postfx", inst) then
			setFast("postfx", inst, "Enabled", false)
		end
	end

	if flags.simpleMaterial and cls ~= "Terrain" and inst:IsA("BasePart") and isFresh("simpleMaterial", inst) then
		setFast("simpleMaterial", inst, "Material", Enum.Material.SmoothPlastic)
		setFast("simpleMaterial", inst, "Reflectance", 0)
		if cls == "MeshPart" then
			setFast("simpleMaterial", inst, "RenderFidelity", Enum.RenderFidelity.Performance)
		end
	end
end

local scanToken = 0
local function scanWorkspace()
	scanToken += 1
	local token = scanToken
	task.spawn(function()
		local list = workspace:GetDescendants()
		for i, inst in ipairs(list) do
			if token ~= scanToken then
				return
			end
			pcall(applyToInstance, inst)
			if i % CONFIG.SCAN_CHUNK == 0 then
				task.wait()
			end
		end
	end)
end

local function scanLightingAndCamera()
	for _, inst in ipairs(Lighting:GetDescendants()) do
		pcall(applyToInstance, inst)
	end
	local cam = workspace.CurrentCamera
	if cam then
		for _, inst in ipairs(cam:GetDescendants()) do
			pcall(applyToInstance, inst)
		end
	end
end

workspace.DescendantAdded:Connect(function(inst)
	if inst:IsA("BasePart") then
		if cullStarted then
			registerPart(inst)
		end
	elseif inst.ClassName == "Humanoid" then
		trackNPC(inst)
	end
	pcall(applyToInstance, inst)
end)

Lighting.DescendantAdded:Connect(function(inst)
	pcall(applyToInstance, inst)
end)

local function hookCamera()
	local cam = workspace.CurrentCamera
	if cam then
		cam.DescendantAdded:Connect(function(inst)
			pcall(applyToInstance, inst)
		end)
	end
end
hookCamera()
workspace:GetPropertyChangedSignal("CurrentCamera"):Connect(hookCamera)

--------------------------------------------------------------------------------
-- CÁC CHỨC NĂNG (bật / tắt)
--------------------------------------------------------------------------------
local function atmosphereOff(group)
	for _, child in ipairs(Lighting:GetChildren()) do
		if child:IsA("Atmosphere") then
			setProp(group, child, "Density", 0)
			setProp(group, child, "Haze", 0)
			setProp(group, child, "Glare", 0)
		end
	end
end

local function applyFogEdge()
	-- sương mù che mép vùng tải: nhìn như Minecraft, không thấy "vực" khi map bị gỡ
	setProp("fogEdge", Lighting, "FogStart", math.max(radius * 0.5, 0))
	setProp("fogEdge", Lighting, "FogEnd", math.max(radius, 10))
	atmosphereOff("fogEdge")
end

local features = {}

features.cull = {
	on = function()
		buildIndex()
	end,
	off = function() end, -- vòng cập nhật sẽ tự khôi phục các ô đang ẩn
}

features.cullPlayers = { on = function() end, off = function() end }
features.cullNPC = { on = function() end, off = function() end }

features.fogEdge = {
	on = applyFogEdge,
	off = function()
		restoreGroup("fogEdge")
	end,
}

features.fogOff = {
	on = function()
		setProp("fogOff", Lighting, "FogEnd", 1000000)
		setProp("fogOff", Lighting, "FogStart", 0)
		atmosphereOff("fogOff")
	end,
	off = function()
		restoreGroup("fogOff")
	end,
}

features.shadows = {
	on = function()
		setProp("shadows", Lighting, "GlobalShadows", false)
		setProp("shadows", Lighting, "ShadowSoftness", 0)
	end,
	off = function()
		restoreGroup("shadows")
	end,
}

features.postfx = {
	on = scanLightingAndCamera,
	off = function()
		restoreGroup("postfx")
	end,
}

features.particles = {
	on = scanWorkspace,
	off = function()
		restoreGroup("particles")
	end,
}

features.lights = {
	on = scanWorkspace,
	off = function()
		restoreGroup("lights")
	end,
}

features.simpleMaterial = {
	on = scanWorkspace,
	off = function()
		restoreGroup("simpleMaterial")
	end,
}

features.simpleSky = {
	on = function()
		for _, child in ipairs(workspace.Terrain:GetChildren()) do
			if child:IsA("Clouds") then
				setProp("simpleSky", child, "Enabled", false)
			end
		end
		for _, child in ipairs(Lighting:GetChildren()) do
			if child:IsA("Sky") then
				setProp("simpleSky", child, "StarCount", 0)
				setProp("simpleSky", child, "CelestialBodiesShown", false)
			end
		end
	end,
	off = function()
		restoreGroup("simpleSky")
	end,
}

features.lowTerrain = {
	on = function()
		local t = workspace.Terrain
		setProp("lowTerrain", t, "Decoration", false)
		setProp("lowTerrain", t, "WaterWaveSize", 0)
		setProp("lowTerrain", t, "WaterWaveSpeed", 0)
		setProp("lowTerrain", t, "WaterReflectance", 0)
	end,
	off = function()
		restoreGroup("lowTerrain")
	end,
}

features.lowQuality = {
	on = function()
		local okSettings, rendering = pcall(function()
			return settings().Rendering
		end)
		if not okSettings then
			return false
		end
		local ok = setProp("lowQuality", rendering, "QualityLevel", Enum.QualityLevel.Level01)
		setProp("lowQuality", rendering, "MeshPartDetailLevel", Enum.MeshPartDetailLevel.Level04)
		return ok
	end,
	off = function()
		restoreGroup("lowQuality")
	end,
}

features.blank3d = {
	on = function()
		local ok = pcall(function()
			RunService:Set3dRenderingEnabled(false)
		end)
		return ok
	end,
	off = function()
		pcall(function()
			RunService:Set3dRenderingEnabled(true)
		end)
	end,
}

local function setFlag(name, value)
	if flags[name] == value then
		return
	end

	if value then
		-- 2 kiểu sương mù loại trừ nhau
		if name == "fogOff" then
			setFlag("fogEdge", false)
		elseif name == "fogEdge" then
			setFlag("fogOff", false)
		end

		flags[name] = true
		local result = features[name].on()
		if result == false then
			flags[name] = false
			toast("Client này không hỗ trợ chức năng đó")
		end
	else
		flags[name] = false
		features[name].off()
	end

	refreshAll()
end

setRadius = function(value) end -- được gán lại sau khi dựng UI

--------------------------------------------------------------------------------
-- GIAO DIỆN
--------------------------------------------------------------------------------
local COLORS = {
	bg = Color3.fromRGB(22, 24, 30),
	header = Color3.fromRGB(32, 35, 44),
	row = Color3.fromRGB(34, 37, 47),
	text = Color3.fromRGB(230, 232, 238),
	sub = Color3.fromRGB(150, 156, 170),
	accent = Color3.fromRGB(70, 160, 255),
	on = Color3.fromRGB(60, 190, 110),
	off = Color3.fromRGB(80, 85, 98),
}

local function new(class, props, parent)
	local inst = Instance.new(class)
	for k, v in pairs(props) do
		inst[k] = v
	end
	inst.Parent = parent
	return inst
end

local function corner(parent, r)
	new("UICorner", { CornerRadius = UDim.new(0, r or 8) }, parent)
end

local playerGui = player:WaitForChild("PlayerGui")
local old = playerGui:FindFirstChild("FixLagMenu")
if old then
	old:Destroy()
end

local gui = new("ScreenGui", {
	Name = "FixLagMenu",
	ResetOnSpawn = false,
	DisplayOrder = 999,
	ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
	IgnoreGuiInset = false,
}, playerGui)

local viewport = workspace.CurrentCamera and workspace.CurrentCamera.ViewportSize or Vector2.new(800, 600)
local frameW = math.min(330, viewport.X - 20)
local frameH = math.min(500, viewport.Y - 40)

local main = new("Frame", {
	Name = "Main",
	Size = UDim2.fromOffset(frameW, frameH),
	Position = UDim2.new(0, 64, 0.5, -frameH / 2),
	BackgroundColor3 = COLORS.bg,
	BorderSizePixel = 0,
	Visible = true,
	Active = true,
}, gui)
corner(main, 12)

local header = new("Frame", {
	Size = UDim2.new(1, 0, 0, 38),
	BackgroundColor3 = COLORS.header,
	BorderSizePixel = 0,
	Active = true,
}, main)
corner(header, 12)

new("TextLabel", {
	Size = UDim2.new(1, -120, 1, 0),
	Position = UDim2.new(0, 12, 0, 0),
	BackgroundTransparency = 1,
	Text = "⚡ Fix Lag Menu",
	TextColor3 = COLORS.text,
	TextXAlignment = Enum.TextXAlignment.Left,
	Font = Enum.Font.GothamBold,
	TextSize = 15,
}, header)

local fpsLabel = new("TextLabel", {
	Size = UDim2.fromOffset(64, 38),
	Position = UDim2.new(1, -100, 0, 0),
	BackgroundTransparency = 1,
	Text = "-- FPS",
	TextColor3 = COLORS.on,
	Font = Enum.Font.GothamBold,
	TextSize = 13,
}, header)

local closeBtn = new("TextButton", {
	Size = UDim2.fromOffset(28, 28),
	Position = UDim2.new(1, -34, 0, 5),
	BackgroundColor3 = COLORS.off,
	Text = "✕",
	TextColor3 = COLORS.text,
	Font = Enum.Font.GothamBold,
	TextSize = 14,
	AutoButtonColor = true,
}, header)
corner(closeBtn, 8)

local body = new("ScrollingFrame", {
	Size = UDim2.new(1, 0, 1, -38 - 26),
	Position = UDim2.new(0, 0, 0, 38),
	BackgroundTransparency = 1,
	BorderSizePixel = 0,
	ScrollBarThickness = 4,
	CanvasSize = UDim2.new(),
	AutomaticCanvasSize = Enum.AutomaticSize.Y,
}, main)
new("UIListLayout", { Padding = UDim.new(0, 6), SortOrder = Enum.SortOrder.LayoutOrder }, body)
new("UIPadding", {
	PaddingTop = UDim.new(0, 8), PaddingBottom = UDim.new(0, 8),
	PaddingLeft = UDim.new(0, 8), PaddingRight = UDim.new(0, 12),
}, body)

local statusLabel = new("TextLabel", {
	Size = UDim2.new(1, -16, 0, 22),
	Position = UDim2.new(0, 8, 1, -24),
	BackgroundTransparency = 1,
	Text = "",
	TextColor3 = COLORS.sub,
	TextXAlignment = Enum.TextXAlignment.Left,
	Font = Enum.Font.Gotham,
	TextSize = 11,
}, main)

local layoutCounter = 0
local function nextOrder()
	layoutCounter += 1
	return layoutCounter
end

local function addSection(text)
	new("TextLabel", {
		Size = UDim2.new(1, 0, 0, 20),
		BackgroundTransparency = 1,
		Text = text,
		TextColor3 = COLORS.accent,
		TextXAlignment = Enum.TextXAlignment.Left,
		Font = Enum.Font.GothamBold,
		TextSize = 12,
		LayoutOrder = nextOrder(),
	}, body)
end

local function makeButton(parent, text, size, position, color)
	local btn = new("TextButton", {
		Size = size,
		Position = position,
		BackgroundColor3 = color or COLORS.off,
		Text = text,
		TextColor3 = COLORS.text,
		Font = Enum.Font.GothamMedium,
		TextSize = 12,
		AutoButtonColor = true,
	}, parent)
	corner(btn, 6)
	return btn
end

-- Preset ----------------------------------------------------------------------
local PRESETS = {
	{
		name = "Siêu nhẹ", radius = 36,
		set = {
			cull = true, cullPlayers = true, cullNPC = true, fogEdge = true,
			shadows = true, postfx = true, particles = true, lights = true,
			simpleMaterial = true, simpleSky = true, lowTerrain = true, lowQuality = true,
		},
	},
	{
		name = "Cân bằng", radius = 150,
		set = {
			cull = true, cullPlayers = true, fogOff = true,
			shadows = true, postfx = true, particles = true, simpleSky = true,
		},
	},
	{ name = "Mặc định", radius = CONFIG.RADIUS_DEFAULT, set = {} },
}

addSection("PRESET NHANH")
do
	local row = new("Frame", {
		Size = UDim2.new(1, 0, 0, 30), BackgroundTransparency = 1, LayoutOrder = nextOrder(),
	}, body)
	local layout = new("UIListLayout", {
		FillDirection = Enum.FillDirection.Horizontal, Padding = UDim.new(0, 6),
	}, row)
	for _, preset in ipairs(PRESETS) do
		local btn = makeButton(row, preset.name, UDim2.new(1 / #PRESETS, -4, 1, 0), UDim2.new(), COLORS.accent)
		btn.Activated:Connect(function()
			-- tắt trước, bật sau để các chức năng loại trừ nhau không đè lẫn nhau
			for _, name in ipairs(FLAG_ORDER) do
				if not preset.set[name] then
					setFlag(name, false)
				end
			end
			for _, name in ipairs(FLAG_ORDER) do
				if preset.set[name] then
					setFlag(name, true)
				end
			end
			setRadius(preset.radius)
			toast("Đã áp dụng preset: " .. preset.name)
		end)
	end
end

-- Thanh trượt bán kính --------------------------------------------------------
addSection("VÙNG TẢI QUANH NHÂN VẬT")
local radiusLabel
local sliderFill, sliderKnob
do
	local row = new("Frame", {
		Size = UDim2.new(1, 0, 0, 92), BackgroundColor3 = COLORS.row, LayoutOrder = nextOrder(),
	}, body)
	corner(row, 8)

	radiusLabel = new("TextLabel", {
		Size = UDim2.new(1, -16, 0, 22),
		Position = UDim2.new(0, 8, 0, 4),
		BackgroundTransparency = 1,
		Text = "",
		TextColor3 = COLORS.text,
		TextXAlignment = Enum.TextXAlignment.Left,
		Font = Enum.Font.GothamMedium,
		TextSize = 13,
	}, row)

	local hit = new("Frame", {
		Size = UDim2.new(1, -24, 0, 28),
		Position = UDim2.new(0, 12, 0, 28),
		BackgroundTransparency = 1,
		Active = true,
	}, row)
	local bar = new("Frame", {
		Size = UDim2.new(1, 0, 0, 8),
		Position = UDim2.new(0, 0, 0.5, -4),
		BackgroundColor3 = COLORS.off,
		BorderSizePixel = 0,
	}, hit)
	corner(bar, 4)
	sliderFill = new("Frame", {
		Size = UDim2.new(0, 0, 1, 0), BackgroundColor3 = COLORS.accent, BorderSizePixel = 0,
	}, bar)
	corner(sliderFill, 4)
	sliderKnob = new("Frame", {
		Size = UDim2.fromOffset(18, 18),
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.new(0, 0, 0.5, 0),
		BackgroundColor3 = Color3.new(1, 1, 1),
		BorderSizePixel = 0,
	}, bar)
	corner(sliderKnob, 9)

	local function fromInput(x)
		local t = math.clamp((x - bar.AbsolutePosition.X) / math.max(bar.AbsoluteSize.X, 1), 0, 1)
		-- thang bậc hai: dễ chỉnh chính xác ở vùng gần (5–50 m)
		setRadius(CONFIG.RADIUS_MIN + (CONFIG.RADIUS_MAX - CONFIG.RADIUS_MIN) * t * t)
	end

	local draggingSlider = false
	hit.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			draggingSlider = true
			body.ScrollingEnabled = false
			fromInput(input.Position.X)
		end
	end)
	UserInputService.InputChanged:Connect(function(input)
		if draggingSlider
			and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
			fromInput(input.Position.X)
		end
	end)
	UserInputService.InputEnded:Connect(function(input)
		if draggingSlider
			and (input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch) then
			draggingSlider = false
			body.ScrollingEnabled = true
		end
	end)

	local quick = new("Frame", {
		Size = UDim2.new(1, -16, 0, 24),
		Position = UDim2.new(0, 8, 0, 62),
		BackgroundTransparency = 1,
	}, row)
	new("UIListLayout", { FillDirection = Enum.FillDirection.Horizontal, Padding = UDim.new(0, 4) }, quick)
	for _, item in ipairs({ { "5 m", 18 }, { "10 m", 36 }, { "25 m", 89 }, { "50 m", 179 }, { "100 m", 357 } }) do
		local btn = makeButton(quick, item[1], UDim2.new(0.2, -4, 1, 0), UDim2.new(), COLORS.off)
		btn.Activated:Connect(function()
			setRadius(item[2])
		end)
	end
end

setRadius = function(value)
	radius = math.clamp(math.floor(value + 0.5), CONFIG.RADIUS_MIN, CONFIG.RADIUS_MAX)
	local t = math.sqrt((radius - CONFIG.RADIUS_MIN) / (CONFIG.RADIUS_MAX - CONFIG.RADIUS_MIN))
	sliderFill.Size = UDim2.new(t, 0, 1, 0)
	sliderKnob.Position = UDim2.new(t, 0, 0.5, 0)
	radiusLabel.Text = string.format("Bán kính: %d studs (≈ %.0f m)", radius, radius * CONFIG.STUD_TO_M)
	if flags.fogEdge then
		applyFogEdge()
	end
end

-- Công tắc --------------------------------------------------------------------
local toggleRefresh = {}

local function addToggle(name, text)
	local row = new("Frame", {
		Size = UDim2.new(1, 0, 0, 38), BackgroundColor3 = COLORS.row, LayoutOrder = nextOrder(),
	}, body)
	corner(row, 8)
	new("TextLabel", {
		Size = UDim2.new(1, -76, 1, 0),
		Position = UDim2.new(0, 10, 0, 0),
		BackgroundTransparency = 1,
		Text = text,
		TextColor3 = COLORS.text,
		TextXAlignment = Enum.TextXAlignment.Left,
		TextWrapped = true,
		Font = Enum.Font.Gotham,
		TextSize = 12,
	}, row)
	local btn = makeButton(row, "TẮT", UDim2.fromOffset(54, 24), UDim2.new(1, -62, 0.5, -12), COLORS.off)
	btn.Font = Enum.Font.GothamBold
	btn.Activated:Connect(function()
		setFlag(name, not flags[name])
	end)
	toggleRefresh[name] = function()
		btn.Text = flags[name] and "BẬT" or "TẮT"
		btn.BackgroundColor3 = flags[name] and COLORS.on or COLORS.off
	end
	toggleRefresh[name]()
end

addSection("GỠ VẬT THỂ NGOÀI VÙNG")
addToggle("cull", "Vùng tải map kiểu Minecraft")
addToggle("cullPlayers", "Ẩn người chơi khác ngoài vùng")
addToggle("cullNPC", "Ẩn NPC ngoài vùng")

addSection("SƯƠNG MÙ")
addToggle("fogEdge", "Sương mù che mép vùng tải")
addToggle("fogOff", "Tắt hẳn sương mù")

addSection("GIẢM HIỆU ỨNG")
addToggle("shadows", "Tắt bóng đổ")
addToggle("postfx", "Tắt hiệu ứng hậu kỳ (Bloom, Blur, ...)")
addToggle("particles", "Tắt hạt / Trail / Beam / Lửa / Khói")
addToggle("lights", "Tắt đèn động (Point / Spot / Surface)")
addToggle("simpleMaterial", "Vật liệu & mesh đơn giản")
addToggle("simpleSky", "Tắt mây / sao / thiên thể")
addToggle("lowTerrain", "Giảm Terrain & sóng nước")
addToggle("lowQuality", "Hạ chất lượng đồ họa xuống thấp nhất")

addSection("KHÁC")
addToggle("blank3d", "Tắt render 3D (chỉ để treo máy, màn hình đen)")

new("TextLabel", {
	Size = UDim2.new(1, 0, 0, 44),
	BackgroundTransparency = 1,
	Text = "Chỉ ảnh hưởng máy bạn. Part di chuyển (thang máy, bẫy) nên gắn tag \"NoCull\".",
	TextColor3 = COLORS.sub,
	TextWrapped = true,
	TextXAlignment = Enum.TextXAlignment.Left,
	TextYAlignment = Enum.TextYAlignment.Top,
	Font = Enum.Font.Gotham,
	TextSize = 11,
	LayoutOrder = nextOrder(),
}, body)

refreshAll = function()
	for _, refresh in pairs(toggleRefresh) do
		refresh()
	end
end

local toastText, toastUntil = nil, 0
toast = function(message)
	toastText = message
	toastUntil = os.clock() + 3
end

-- Nút nổi + kéo cửa sổ ---------------------------------------------------------
local openBtn = new("TextButton", {
	Name = "Open",
	Size = UDim2.fromOffset(44, 44),
	Position = UDim2.new(0, 10, 0.5, -22),
	BackgroundColor3 = COLORS.accent,
	Text = "⚡",
	TextColor3 = Color3.new(1, 1, 1),
	Font = Enum.Font.GothamBold,
	TextSize = 22,
}, gui)
corner(openBtn, 22)

local function toggleMenu()
	main.Visible = not main.Visible
end
openBtn.Activated:Connect(toggleMenu)
closeBtn.Activated:Connect(function()
	main.Visible = false
end)
UserInputService.InputBegan:Connect(function(input, processed)
	if not processed and input.KeyCode == CONFIG.TOGGLE_KEY then
		toggleMenu()
	end
end)

do
	local draggingWin, dragStart, startPos = false, nil, nil
	header.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			draggingWin = true
			dragStart = input.Position
			startPos = main.Position
		end
	end)
	UserInputService.InputChanged:Connect(function(input)
		if draggingWin
			and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
			local delta = input.Position - dragStart
			main.Position = UDim2.new(
				startPos.X.Scale, startPos.X.Offset + delta.X,
				startPos.Y.Scale, startPos.Y.Offset + delta.Y
			)
		end
	end)
	UserInputService.InputEnded:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			draggingWin = false
		end
	end)
end

--------------------------------------------------------------------------------
-- VÒNG LẶP CHÍNH
--------------------------------------------------------------------------------
local function focusPosition()
	local char = player.Character
	local root = char and char:FindFirstChild("HumanoidRootPart")
	if root then
		return root.Position
	end
	local cam = workspace.CurrentCamera
	return cam and cam.CFrame.Position
end

local updateAcc = 0
RunService.Heartbeat:Connect(function(dt)
	updateAcc += dt
	if updateAcc >= CONFIG.UPDATE_INTERVAL then
		updateAcc = 0
		local pos = focusPosition()
		if pos then
			updateCells(pos)
			updateEntities(pos)
		end
	end
	processQueues()
end)

do
	local frames, acc = 0, 0
	RunService.RenderStepped:Connect(function(dt)
		frames += 1
		acc += dt
		if acc >= 0.5 then
			fpsLabel.Text = string.format("%d FPS", math.floor(frames / acc + 0.5))
			frames, acc = 0, 0
			if toastText and os.clock() < toastUntil then
				statusLabel.Text = toastText
			else
				statusLabel.Text = string.format(
					"Part ẩn: %d/%d  •  Người/NPC ẩn: %d",
					statHidden, statTotal, statEntitiesHidden
				)
			end
		end
	end)
end

-- Quét sẵn NPC (Humanoid không thuộc người chơi) để hệ thống entity biết
task.spawn(function()
	local list = workspace:GetDescendants()
	for i, inst in ipairs(list) do
		if inst.ClassName == "Humanoid" then
			trackNPC(inst)
		end
		if i % CONFIG.SCAN_CHUNK == 0 then
			task.wait()
		end
	end
end)

setRadius(radius)
refreshAll()
