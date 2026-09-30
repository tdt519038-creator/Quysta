repeat wait() until game:IsLoaded()

if LPH_OBFUSCATED == nil then
	LPH_NO_VIRTUALIZE = function(...) return (...) end
	LPH_ENCSTR = function(...) return (...) end
	LRM_SANITIZE = function(...) return ... end
end

local cloneref = cloneref or function(o) return o end
local TweenService = cloneref(game:GetService("TweenService"))
local UserInputService = cloneref(game:GetService("UserInputService"))
local Players = cloneref(game:GetService("Players"))
local HttpService = cloneref(game:GetService("HttpService"))
local StarterGui = cloneref(game:GetService("StarterGui"))

local LocalPlayer = cloneref(Players.LocalPlayer)
local IsMobile = UserInputService.TouchEnabled and not UserInputService.KeyboardEnabled and not UserInputService.MouseEnabled

if identifyexecutor and identifyexecutor() == "Wave" then
	getgenv().gethui = function()
		return game:GetService("CoreGui")
	end
end

local Folder_Configs = {
	Directory = "sportsclub",
	Images = "sportsclub/Images",
}

if type(isfolder) == "function" and type(makefolder) == "function" then
	if not isfolder(Folder_Configs.Directory) then makefolder(Folder_Configs.Directory) end
	if not isfolder(Folder_Configs.Images) then makefolder(Folder_Configs.Images) end
end

local ProjectId = "22cad4542e792a9c"
local SdkUrl = "https://api.polsec.sh/sdk"
local LoaderBase = "https://api.polsec.sh/loader"

local Config = {
	File = "sportsclub/license_key.json",
	Settings = "sportsclub/loader_settings.json",
	KeyLink = "https://getsportsclub.com/adsystem",
	Shop = "https://sportsclub.fun/#store",
	Discord = "https://discord.gg/gUbZegrB6g",
}

local GameList = {
	[66654135] = "009ff4a78983f850",
	[73885730] = "c1383e4dbc04c894",
	[113491250] = "c4d3ef0c29176832",
	[184199275] = "3b7bd9142a45d559",
	[372226183] = "6bf87ae2d1b86339",
	[383310974] = "c3114c8b9a6def3c",
	[1054526971] = "68a89638f9889f79",
	[2459091562] = "75fba2f42d4b54f3",
	[4293374620] = "0f10cc5ff028f81e",
	[4730278139] = "fa8f91a1fc10377a",
	[4777817887] = "8a66fc1161d29f0e",
	[4931927012] = "1231151b59c9dcf8",
	[4949420752] = "cc50c53a4adb4571",
	[5595353122] = "f941ecf9c2893c84",
	[5995470825] = "c9da2143136ce8d5",
	[6035872082] = "c8a45ca0b25139a3",
	[6061766680] = "d52ba1c5c0dc5c11",
	[6216285188] = "e8147fe214540335",
	[6260656796] = "b0d2c57249d2ec06",
	[6331902150] = "ade0e0dfb65b8dab",
	[6726637224] = "bf1f1aa1d5bec70f",
	[6739698191] = "30bd8f3b21d19783",
	[6931042565] = "98c663b5cac918d2",
	[7094518649] = "ea549e345bb6bc5c",
	[7108384194] = "a25ea6b8888984e3",
	[7264587281] = "5f0b619a6d027235",
	[7585140258] = "db37f21dad9c7ac1",
	[7633926880] = "981acf63e98b3571",
	[7883776681] = "ecfb28ceae344a4e",
	[7884563721] = "137bb216d0fdab55",
	[7996365376] = "7e52ef54881d0706",
	[8307114974] = "32a3f9f1781977ef",
	[8795154789] = "931dcf7ba70b7dc5",
	[9112256336] = "34a15184cb6a7ee4",
	[9167377564] = "82f7f927a73f1de1",
	[9294074907] = "31655f9162e3aa8f",
	[9534705677] = "e2fabbf7654aed38",
	[9561553764] = "e823cdbf57675025",
	[9641502068] = "d65fbd7db286df7d",
	[9908641400] = "e648818e624401de",
	[9931749389] = "858f757ed4641d2b",
	[10031562156] = "e930337182b904f9",
	[10057403337] = "b92fa39292be5ddc",
	[10144280947] = "31696135af052840",
	[10155360168] = "f135c2d3a0febabf",
	[10230942274] = "dc478626c0c0f9de",
	[10476380360] = "67b2e03a3469e076",
	[10539411000] = "308fe2805126001d",
	[10563114921] = "ebcff09f785a4a30",
	[10648640958] = "24b4a31160224f3c",
}

local ScriptId = GameList[game.GameId]

if type(ScriptId) ~= "string" or ScriptId == "" then
	StarterGui:SetCore("SendNotification", {
		Title = "sportsclub",
		Text = "This game is not supported.",
	})
	return
end

local Library = loadstring(game:HttpGet(SdkUrl))()
Library.script_id = ScriptId

local function Copy(Text)
	if setclipboard then
		setclipboard(Text)
	elseif toclipboard then
		toclipboard(Text)
	end
end

local function ReadJson(Path)
	if not isfile or not readfile or not isfile(Path) then return nil end
	local Ok, Raw = pcall(readfile, Path)
	if not Ok or type(Raw) ~= "string" or Raw == "" then return nil end
	local Decoded, Data = pcall(HttpService.JSONDecode, HttpService, Raw)
	if not Decoded or type(Data) ~= "table" then return nil end
	return Data
end

local function LoadSavedKey()
	local Data = ReadJson(Config.File)
	if not Data or type(Data.key) ~= "string" or Data.key == "" then return nil end
	local Expires = tonumber(Data.expires_at)
	if Expires and Expires > 0 and Expires < os.time() then
		if delfile then pcall(delfile, Config.File) end
		return nil
	end
	return Data.key
end

local function SaveKey(Key, Data)
	if not writefile then return end
	if makefolder and isfolder and not isfolder(Folder_Configs.Directory) then
		pcall(makefolder, Folder_Configs.Directory)
	end
	pcall(writefile, Config.File, HttpService:JSONEncode({
		key = Key,
		note = Data and Data.note or nil,
		discord_id = Data and Data.discord_id or nil,
		expires_at = Data and Data.expires_at or nil,
		saved_at = os.time(),
	}))
end

local function ApplyKey(Key, Data)
	script_key = Key
	getgenv().script_key = Key
	getgenv().PolSec_Note = Data and Data.note or nil
	getgenv().PolSec_Key_Note = Data and Data.note or nil
	getgenv().PolSec_Expiry = Data and Data.expires_at or nil
	getgenv().PolSec_UserId = Data and Data.discord_id or nil
	getgenv().PolSec_Discord_Id = Data and Data.discord_id and tostring(Data.discord_id) or nil
	getgenv().polsec_script_id = ScriptId
	local Note = Data and Data.note
	if type(Note) == "string" then
		local Clean = string.lower((Note:gsub("^%s+", ""):gsub("%s+$", "")))
		getgenv().sportsclub_premium = Clean ~= "" and Clean ~= "keysystem" and Clean ~= "trail"
	else
		getgenv().sportsclub_premium = false
	end
	SaveKey(Key, Data)
end

local function TimeLeft(Expires)
	Expires = tonumber(Expires)
	if not Expires or Expires <= 0 then return "Lifetime" end
	local Left = Expires - os.time()
	if Left < 0 then return "Expired" end
	local Days = math.floor(Left / 86400)
	local Hours = math.floor((Left % 86400) / 3600)
	local Minutes = math.floor((Left % 3600) / 60)
	local Seconds = math.floor(Left % 60)
	if Days > 0 then
		return string.format("%dd %dh %dm", Days, Hours, Minutes)
	elseif Hours > 0 then
		return string.format("%dh %dm %ds", Hours, Minutes, Seconds)
	elseif Minutes > 0 then
		return string.format("%dm %ds", Minutes, Seconds)
	end
	return string.format("%ds", Seconds)
end

local ErrorMessages = {
	key_expired = "Your key is expired!",
	key_blacklisted = "This key is banned. Join Discord for help.",
	key_banned = "This key is banned. Join Discord for help.",
	invalid_fingerprint = "HWID not valid! Reset HWID on the panel.",
	key_hwid_locked = "HWID not valid! Reset HWID on the panel.",
	hwid_mismatch = "HWID not valid! Reset HWID on the panel.",
	invalid_key = "Wrong key. Check it and try again.",
	key_incorrect = "Wrong key. Check it and try again.",
	key_invalid = "That doesnt look like a key.",
	invalid_script_id = "Script not found.",
	script_id_incorrect = "Script not found.",
	script_id_invalid = "Script deleted.",
	invalid_executor = "Your executor isnt supported.",
	security_error = "Something went wrong. Try again.",
	time_error = "Fix your PC clock and try again.",
	key_disabled = "This key is disabled. Join Discord for help.",
	rate_limited = "Too many tries. Wait a bit and try again.",
	error = "Something broke. Join Discord for help.",
	unknown_error = "Something broke. Join Discord for help.",
	enter_a_key = "Enter a key",
	network_error = "Could not reach license server. Try again.",
}

local function NormalizeError(Value)
	if type(Value) ~= "string" then return "" end
	return string.lower((Value:gsub("^%s+", ""):gsub("%s+$", ""):gsub("[%s%-]+", "_")))
end

local function ResolveError(...)
	local Count = select("#", ...)
	for Index = 1, Count do
		local Key = NormalizeError(select(Index, ...))
		if Key ~= "" and ErrorMessages[Key] then
			return ErrorMessages[Key]
		end
	end
	for Index = 1, Count do
		local Value = select(Index, ...)
		if type(Value) == "string" then
			local Trimmed = Value:gsub("^%s+", ""):gsub("%s+$", "")
			if Trimmed ~= "" and not string.find(Trimmed, "^[%w_]+$") then
				return Trimmed
			end
		end
	end
	return ErrorMessages.unknown_error
end

local function CheckKey(Key)
	Key = type(Key) == "string" and Key:gsub("^%s+", ""):gsub("%s+$", "") or ""
	if Key == "" then return false, ErrorMessages.enter_a_key end
	local Ok, Result = pcall(Library.check_key, Key)
	if not Ok then return false, ErrorMessages.network_error end
	if type(Result) ~= "table" then return false, ResolveError(Result) end
	if Result.status ~= "key_valid" then
		local User = type(Result.user) == "table" and Result.user or nil
		return false, ResolveError(Result.status, Result.message, User and User.blacklist_reason)
	end
	local User = type(Result.user) == "table" and Result.user or {}
	return true, {
		note = User.note,
		expires_at = User.key_expires,
		discord_id = User.discord_id or User.discordId,
		ad_key = User.ad_key == true,
	}, Key
end

-- ==================== UI ====================
do
	local wait = task.wait
	local spawn = task.spawn
	local FromRGB = Color3.fromRGB
	local UDim2New = UDim2.new
	local UDimNew = UDim.new
	local Vector2New = Vector2.new
	local InstanceNew = Instance.new

	local Theme = {
		Accent = FromRGB(61, 158, 255),
		AccentHover = FromRGB(10, 124, 255),
		Element = FromRGB(22, 24, 32),
		Hover = FromRGB(32, 36, 48),
		Danger = FromRGB(220, 70, 70),
		Success = FromRGB(70, 190, 120),
		White = FromRGB(255, 255, 255),
		Inactive = FromRGB(150, 150, 158),
		Text = FromRGB(255, 255, 255),
		Border = FromRGB(55, 55, 62),
		Background = FromRGB(12, 14, 20),
	}

	local FontFace do
		local Ok, Face = pcall(function()
			return Font.new("rbxasset://fonts/families/BuilderSans.json", Enum.FontWeight.Medium, Enum.FontStyle.Normal)
		end)
		FontFace = (Ok and Face) or Font.fromEnum(Enum.Font.GothamMedium)
	end

	local GetUI = gethui or function() return game:GetService("CoreGui") end
	local function SafeGetUI()
		local Ok, Result = pcall(GetUI)
		if Ok and Result then return Result end
		return game:GetService("CoreGui")
	end

	local function Create(Class, Props)
		local Inst = InstanceNew(Class)
		for Key, Value in Props do
			if Key ~= "Parent" then Inst[Key] = Value end
		end
		if Props.Parent then Inst.Parent = Props.Parent end
		return Inst
	end

	local function Corner(Parent, Radius)
		return Create("UICorner", { Parent = Parent, CornerRadius = UDimNew(0, Radius or 5) })
	end

	local function Stroke(Parent, Color, Transparency)
		return Create("UIStroke", {
			Parent = Parent,
			Color = Color or Theme.Border,
			Thickness = 1,
			Transparency = Transparency or 0,
			ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
		})
	end

	local function Tween(Inst, Info, Goal)
		local Tw = TweenService:Create(Inst, Info or TweenInfo.new(0.16, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), Goal)
		Tw:Play()
		return Tw
	end

	local OpenInfo = TweenInfo.new(0.48, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
	local CloseInfo = TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.In)

	-- ==================== BẢNG DUMP SCRIPT ====================
	local function OpenDumpPanel(SourceCode, KeyData)
		local ScreenGui = Create("ScreenGui", {
			Parent = SafeGetUI(),
			Name = "SportsClubDumper",
			ResetOnSpawn = false,
			IgnoreGuiInset = true,
			DisplayOrder = 1000,
			ZIndexBehavior = Enum.ZIndexBehavior.Global,
		})

		local UIScale = Create("UIScale", { Parent = ScreenGui, Scale = 1 })

		local MainW = IsMobile and 460 or 620
		local MainH = IsMobile and 420 or 520
		local TitleH = 42
		local MinimizedH = TitleH

		local Main = Create("CanvasGroup", {
			Parent = ScreenGui,
			AnchorPoint = Vector2New(0.5, 0.5),
			Position = UDim2New(0.5, 0, 0.5, 0),
			Size = UDim2New(0, MainW, 0, MainH),
			BackgroundColor3 = Theme.Background,
			BorderSizePixel = 0,
			ClipsDescendants = true,
			GroupTransparency = 1,
			ZIndex = 2,
		})
		Corner(Main, 12)
		Stroke(Main, Theme.Border, 0.2)

		-- Title Bar
		local TitleBar = Create("Frame", {
			Parent = Main,
			Size = UDim2New(1, 0, 0, TitleH),
			BackgroundColor3 = Theme.Element,
			BorderSizePixel = 0,
			ZIndex = 5,
		})
		Corner(TitleBar, 12)
		Create("Frame", {
			Parent = TitleBar,
			Size = UDim2New(1, 0, 0, 12),
			Position = UDim2New(0, 0, 1, -12),
			BackgroundColor3 = Theme.Element,
			BorderSizePixel = 0,
			ZIndex = 5,
		})

		Create("TextLabel", {
			Parent = TitleBar,
			Size = UDim2New(1, -110, 1, 0),
			Position = UDim2New(0, 14, 0, 0),
			BackgroundTransparency = 1,
			FontFace = FontFace,
			Text = "sportsclub  •  Script Dumper",
			TextColor3 = Theme.White,
			TextSize = 15,
			TextXAlignment = Enum.TextXAlignment.Left,
			ZIndex = 6,
		})

		local MinimizeBtn = Create("TextButton", {
			Parent = TitleBar,
			Size = UDim2New(0, 32, 0, 32),
			Position = UDim2New(1, -76, 0.5, -16),
			BackgroundColor3 = Theme.Hover,
			BorderSizePixel = 0,
			FontFace = FontFace,
			Text = "−",
			TextColor3 = Theme.White,
			TextSize = 20,
			AutoButtonColor = false,
			ZIndex = 7,
		})
		Corner(MinimizeBtn, 6)

		local CloseBtn = Create("TextButton", {
			Parent = TitleBar,
			Size = UDim2New(0, 32, 0, 32),
			Position = UDim2New(1, -38, 0.5, -16),
			BackgroundColor3 = Theme.Danger,
			BorderSizePixel = 0,
			FontFace = FontFace,
			Text = "×",
			TextColor3 = Theme.White,
			TextSize = 18,
			AutoButtonColor = false,
			ZIndex = 7,
		})
		Corner(CloseBtn, 6)

		-- Content
		local Content = Create("Frame", {
			Parent = Main,
			Size = UDim2New(1, -24, 1, -(TitleH + 20)),
			Position = UDim2New(0, 12, 0, TitleH + 10),
			BackgroundTransparency = 1,
			ZIndex = 3,
		})

		local InfoLabel = Create("TextLabel", {
			Parent = Content,
			Size = UDim2New(1, 0, 0, 20),
			BackgroundTransparency = 1,
			FontFace = FontFace,
			Text = "Key Valid  |  Time Left: " .. (KeyData and TimeLeft(KeyData.expires_at) or "N/A") .. "  |  Characters: " .. #SourceCode,
			TextColor3 = Theme.Success,
			TextSize = 13,
			TextXAlignment = Enum.TextXAlignment.Left,
			ZIndex = 4,
		})

		-- Nút Copy All
		local CopyBtn = Create("TextButton", {
			Parent = Content,
			Size = UDim2New(1, 0, 0, 36),
			Position = UDim2New(0, 0, 0, 28),
			BackgroundColor3 = Theme.Accent,
			BorderSizePixel = 0,
			FontFace = FontFace,
			Text = "Copy All Code (1 lần)",
			TextColor3 = Theme.White,
			TextSize = 14,
			AutoButtonColor = false,
			ZIndex = 4,
		})
		Corner(CopyBtn, 8)

		CopyBtn.MouseEnter:Connect(function()
			Tween(CopyBtn, nil, { BackgroundColor3 = Theme.AccentHover })
		end)
		CopyBtn.MouseLeave:Connect(function()
			Tween(CopyBtn, nil, { BackgroundColor3 = Theme.Accent })
		end)

		CopyBtn.MouseButton1Click:Connect(function()
			Copy(SourceCode)
			CopyBtn.Text = "Đã Copy Toàn Bộ Code!"
			CopyBtn.BackgroundColor3 = Theme.Success
			task.delay(1.8, function()
				if CopyBtn and CopyBtn.Parent then
					CopyBtn.Text = "Copy All Code (1 lần)"
					CopyBtn.BackgroundColor3 = Theme.Accent
				end
			end)
		end)

		-- Ô hiển thị code
		local CodeBox = Create("ScrollingFrame", {
			Parent = Content,
			Size = UDim2New(1, 0, 1, -75),
			Position = UDim2New(0, 0, 0, 72),
			BackgroundColor3 = Theme.Element,
			BorderSizePixel = 0,
			ScrollBarThickness = 5,
			CanvasSize = UDim2New(0, 0, 0, 0),
			AutomaticCanvasSize = Enum.AutomaticSize.Y,
			ZIndex = 4,
		})
		Corner(CodeBox, 8)

		local CodeText = Create("TextLabel", {
			Parent = CodeBox,
			Size = UDim2New(1, -16, 0, 0),
			Position = UDim2New(0, 8, 0, 6),
			BackgroundTransparency = 1,
			FontFace = FontFace,
			Text = SourceCode,
			TextColor3 = Theme.Text,
			TextSize = 12,
			TextXAlignment = Enum.TextXAlignment.Left,
			TextYAlignment = Enum.TextYAlignment.Top,
			TextWrapped = true,
			AutomaticSize = Enum.AutomaticSize.Y,
			ZIndex = 5,
		})

		-- Drag
		do
			local Dragging, DragStart, StartPos, Changed
			TitleBar.InputBegan:Connect(function(Input)
				if Input.UserInputType ~= Enum.UserInputType.MouseButton1 and Input.UserInputType ~= Enum.UserInputType.Touch then return end
				Dragging = true
				DragStart = Input.Position
				StartPos = Main.Position
				if Changed then return end
				Changed = Input.Changed:Connect(function()
					if Input.UserInputState == Enum.UserInputState.End then
						Dragging = false
						Changed:Disconnect()
						Changed = nil
					end
				end)
			end)
			UserInputService.InputChanged:Connect(function(Input)
				if not Dragging then return end
				if Input.UserInputType ~= Enum.UserInputType.MouseMovement and Input.UserInputType ~= Enum.UserInputType.Touch then return end
				local Delta = (Input.Position - DragStart) / (UIScale.Scale or 1)
				Main.Position = UDim2New(StartPos.X.Scale, StartPos.X.Offset + Delta.X, StartPos.Y.Scale, StartPos.Y.Offset + Delta.Y)
			end)
		end

		-- Minimize
		local IsMinimized = false
		local OriginalSize = Main.Size
		MinimizeBtn.MouseButton1Click:Connect(function()
			IsMinimized = not IsMinimized
			if IsMinimized then
				Tween(Main, TweenInfo.new(0.25), { Size = UDim2New(0, MainW, 0, MinimizedH) })
				Content.Visible = false
				MinimizeBtn.Text = "+"
			else
				Tween(Main, TweenInfo.new(0.25), { Size = OriginalSize })
				Content.Visible = true
				MinimizeBtn.Text = "−"
			end
		end)

		CloseBtn.MouseButton1Click:Connect(function()
			Tween(Main, CloseInfo, { GroupTransparency = 1 })
			wait(0.22)
			ScreenGui:Destroy()
		end)

		MinimizeBtn.MouseEnter:Connect(function() Tween(MinimizeBtn, nil, { BackgroundColor3 = Theme.Accent }) end)
		MinimizeBtn.MouseLeave:Connect(function() Tween(MinimizeBtn, nil, { BackgroundColor3 = Theme.Hover }) end)
		CloseBtn.MouseEnter:Connect(function() Tween(CloseBtn, nil, { BackgroundColor3 = FromRGB(255, 80, 80) }) end)
		CloseBtn.MouseLeave:Connect(function() Tween(CloseBtn, nil, { BackgroundColor3 = Theme.Danger }) end)

		Tween(Main, OpenInfo, { GroupTransparency = 0 })
	end

	-- ==================== KEY UI ====================
	local function OpenKeyUI(Prefill)
		local Pad = IsMobile and 18 or 16
		local LogoS = IsMobile and 42 or 38
		local BtnH = IsMobile and 48 or 40
		local BtnGap = 8
		local FieldH = IsMobile and 46 or 40
		local PanelW = IsMobile and 380 or 430
		local ContentW = PanelW - Pad * 2
		local HalfW = math.floor((ContentW - BtnGap) / 2)
		local DescY = Pad + LogoS + 8
		local FieldY = DescY + 20
		local HintH = 16
		local HintY = FieldY + FieldH + 6
		local BtnY = HintY + HintH + 8
		local Row2Y = BtnY + BtnH + BtnGap
		local Row3Y = Row2Y + BtnH + BtnGap
		local TimeY = Row3Y + BtnH + 8
		local PanelH = TimeY + 18
		local CloseSize = IsMobile and 24 or 22

		local ScreenGui = Create("ScreenGui", {
			Parent = SafeGetUI(),
			Name = "\0",
			ResetOnSpawn = false,
			IgnoreGuiInset = true,
			DisplayOrder = 999,
			ZIndexBehavior = Enum.ZIndexBehavior.Global,
		})

		local UIScale = Create("UIScale", { Parent = ScreenGui, Scale = 1 })

		local Main = Create("CanvasGroup", {
			Parent = ScreenGui,
			AnchorPoint = Vector2New(0.5, 0.5),
			Position = UDim2New(0.5, 0, 0.5, 20),
			Size = UDim2New(0, PanelW, 0, PanelH),
			BackgroundColor3 = Theme.Background,
			BorderSizePixel = 0,
			ClipsDescendants = true,
			GroupTransparency = 1,
			ZIndex = 2,
		})
		Corner(Main, 12)

		local DragArea = Create("Frame", {
			Parent = Main,
			Size = UDim2New(1, 0, 0, Pad + LogoS),
			BackgroundTransparency = 1,
			ZIndex = 3,
		})

		local CloseBtn = Create("TextButton", {
			Parent = Main,
			Size = UDim2New(0, CloseSize, 0, CloseSize),
			Position = UDim2New(0, Pad, 0, Pad + math.floor((LogoS - CloseSize) / 2)),
			BackgroundTransparency = 1,
			FontFace = FontFace,
			Text = "×",
			TextColor3 = Theme.White,
			TextSize = 18,
			AutoButtonColor = false,
			ZIndex = 6,
		})

		Create("TextLabel", {
			Parent = Main,
			Size = UDim2New(0, ContentW, 0, 16),
			Position = UDim2New(0, Pad, 0, DescY),
			BackgroundTransparency = 1,
			FontFace = FontFace,
			Text = "Enter key → Dump full script from server",
			TextColor3 = Theme.Text,
			TextSize = 13,
			TextXAlignment = Enum.TextXAlignment.Left,
			ZIndex = 4,
		})

		local KeyBox = Create("Frame", {
			Parent = Main,
			Size = UDim2New(0, ContentW, 0, FieldH),
			Position = UDim2New(0, Pad, 0, FieldY),
			BackgroundColor3 = Theme.Element,
			BorderSizePixel = 0,
			ZIndex = 3,
		})
		Corner(KeyBox, 10)
		local InputStroke = Stroke(KeyBox, Theme.Border, 0.15)

		local Box = Create("TextBox", {
			Parent = KeyBox,
			Size = UDim2New(1, -20, 1, 0),
			Position = UDim2New(0, 10, 0, 0),
			BackgroundTransparency = 1,
			ClearTextOnFocus = false,
			FontFace = FontFace,
			PlaceholderText = "Enter your key",
			PlaceholderColor3 = Theme.Inactive,
			Text = type(Prefill) == "string" and Prefill or "",
			TextColor3 = Theme.Text,
			TextSize = 14,
			TextXAlignment = Enum.TextXAlignment.Left,
			ZIndex = 4,
		})

		local function SideBtn(Text, X, Y, W)
			local Btn = Create("TextButton", {
				Parent = Main,
				Size = UDim2New(0, W, 0, BtnH),
				Position = UDim2New(0, X, 0, Y),
				BackgroundColor3 = Theme.Element,
				BorderSizePixel = 0,
				FontFace = FontFace,
				Text = Text,
				TextColor3 = Theme.Text,
				TextSize = 13,
				AutoButtonColor = false,
				ZIndex = 4,
			})
			Corner(Btn, 10)
			Stroke(Btn, Theme.Border, 0.15)
			Btn.MouseEnter:Connect(function() Tween(Btn, nil, { BackgroundColor3 = Theme.Hover }) end)
			Btn.MouseLeave:Connect(function() Tween(Btn, nil, { BackgroundColor3 = Theme.Element }) end)
			return Btn
		end

		local ContinueBtn = Create("TextButton", {
			Parent = Main,
			Size = UDim2New(0, HalfW, 0, BtnH),
			Position = UDim2New(0, Pad, 0, BtnY),
			BackgroundColor3 = Theme.Accent,
			BorderSizePixel = 0,
			FontFace = FontFace,
			Text = "Dump Script",
			TextColor3 = Theme.White,
			TextSize = 13,
			AutoButtonColor = false,
			ZIndex = 4,
		})
		Corner(ContinueBtn, 10)
		ContinueBtn.MouseEnter:Connect(function() Tween(ContinueBtn, nil, { BackgroundColor3 = Theme.AccentHover }) end)
		ContinueBtn.MouseLeave:Connect(function() Tween(ContinueBtn, nil, { BackgroundColor3 = Theme.Accent }) end)

		local GetKeyBtn = SideBtn("Get Key", Pad + HalfW + BtnGap, BtnY, HalfW)
		local SkipBtn = SideBtn("Store", Pad, Row2Y, ContentW)
		local DiscordBtn = SideBtn("Discord", Pad, Row3Y, ContentW)

		local Status = Create("TextLabel", {
			Parent = Main,
			Size = UDim2New(1, -(Pad * 2), 0, 16),
			Position = UDim2New(0, Pad, 0, TimeY),
			BackgroundTransparency = 1,
			FontFace = FontFace,
			Text = "Time Left: N/A",
			TextColor3 = Theme.Inactive,
			TextSize = 13,
			TextXAlignment = Enum.TextXAlignment.Left,
			ZIndex = 4,
		})

		local Busy = false
		local Closed = false

		-- Drag key UI
		do
			local Dragging, DragStart, StartPos, Changed
			DragArea.InputBegan:Connect(function(Input)
				if Input.UserInputType ~= Enum.UserInputType.MouseButton1 and Input.UserInputType ~= Enum.UserInputType.Touch then return end
				Dragging = true
				DragStart = Input.Position
				StartPos = Main.Position
				if Changed then return end
				Changed = Input.Changed:Connect(function()
					if Input.UserInputState == Enum.UserInputState.End then
						Dragging = false
						Changed:Disconnect()
						Changed = nil
					end
				end)
			end)
			UserInputService.InputChanged:Connect(function(Input)
				if not Dragging then return end
				if Input.UserInputType ~= Enum.UserInputType.MouseMovement and Input.UserInputType ~= Enum.UserInputType.Touch then return end
				local Delta = (Input.Position - DragStart) / (UIScale.Scale or 1)
				Main.Position = UDim2New(StartPos.X.Scale, StartPos.X.Offset + Delta.X, StartPos.Y.Scale, StartPos.Y.Offset + Delta.Y)
			end)
		end

		local function SetStatus(Text, Color)
			Status.Text = Text
			Status.TextColor3 = Color or Theme.Inactive
		end

		local function Dismiss(After)
			if Closed then return end
			Closed = true
			Tween(Main, CloseInfo, { GroupTransparency = 1 })
			wait(0.22)
			ScreenGui:Destroy()
			if After then After() end
		end

		local function RunDump()
			if Busy or Closed then return end
			Busy = true
			ContinueBtn.Text = "Dumping..."
			Box.TextEditable = false
			SetStatus("Validating key...", Theme.Inactive)

			spawn(function()
				local Ok, DataOrErr, Key = CheckKey(Box.Text)
				if Closed then return end
				if not Ok then
					Busy = false
					ContinueBtn.Text = "Dump Script"
					Box.TextEditable = true
					Tween(InputStroke, nil, { Color = Theme.Danger, Transparency = 0 })
					SetStatus(tostring(DataOrErr), Theme.Danger)
					return
				end

				SetStatus("Key OK • Fetching script...", Theme.Success)
				ApplyKey(Key, DataOrErr)

				-- Lấy source code thật từ server
				local Url = LoaderBase .. "/" .. ProjectId .. "/" .. ScriptId
				local Success, Source = pcall(function()
					return game:HttpGet(Url)
				end)

				if not Success or type(Source) ~= "string" or Source == "" then
					Busy = false
					ContinueBtn.Text = "Dump Script"
					Box.TextEditable = true
					SetStatus("Failed to fetch script from server", Theme.Danger)
					return
				end

				-- Đóng key UI → mở bảng dump
				Dismiss(function()
					OpenDumpPanel(Source, DataOrErr)
				end)
			end)
		end

		ContinueBtn.MouseButton1Click:Connect(RunDump)
		Box.FocusLost:Connect(function(Enter)
			if Enter then RunDump() end
		end)

		GetKeyBtn.MouseButton1Click:Connect(function()
			Copy(Config.KeyLink)
			SetStatus("Key link copied", Theme.Accent)
		end)
		SkipBtn.MouseButton1Click:Connect(function()
			Copy(Config.Shop)
			SetStatus("Store link copied", Theme.Accent)
		end)
		DiscordBtn.MouseButton1Click:Connect(function()
			Copy(Config.Discord)
			SetStatus("Discord link copied", Theme.Accent)
		end)
		CloseBtn.MouseButton1Click:Connect(function() Dismiss() end)

		Tween(Main, OpenInfo, { GroupTransparency = 0, Position = UDim2New(0.5, 0, 0.5, 0) })
	end

	-- Silent key
	local function TrySilent(Key)
		local Ok, Data, Normalized = CheckKey(Key)
		if not Ok then return false end
		ApplyKey(Normalized, Data)

		local Url = LoaderBase .. "/" .. ProjectId .. "/" .. ScriptId
		local Success, Source = pcall(function()
			return game:HttpGet(Url)
		end)
		if Success and type(Source) == "string" and Source ~= "" then
			OpenDumpPanel(Source, Data)
			return true
		end
		return false
	end

	local Initial = getgenv().script_key
	if type(Initial) ~= "string" or Initial == "" then Initial = script_key end
	if type(Initial) ~= "string" or Initial == "" then Initial = LoadSavedKey() end

	if type(Initial) == "string" and Initial ~= "" and TrySilent(Initial) then
		return
	end

	OpenKeyUI(Initial)
end
