--[[
    Fishy Hub / JNKIE Script Dumper (Forced Raw)
    Key đúng → server gửi code thật → CƯỠNG ÉP lấy hết code thô
    → nhét thẳng toàn bộ source vào bảng → Copy All 1 lần
    KHÔNG chạy script, chỉ dump raw code vào panel
]]

if not game:IsLoaded() then
    game.Loaded:Wait()
end

local S = {
    "74822d80686e92ab6eb7e466c26ccbb9cd03e3ae59b12fc06c5ddc832e4176dc",
    "1536b50dfd2ed63b9dd6399ea25f9cc943fdac63da6e7dea70ccd7d19fd2a886",
    "23a3bb48679cdf01c010b3493189a7c43bdd30111a4f7e310312b442bb4bb351",
    "48ce4ec4621f5e75fa03f41cc0e7fc8c7ecdb8f58bd5e2f1d6be63f157152f37",
    "a7f0377d90008043bd12e2b2e6e179c50cd19ffb1b86710614898d92ff1c8aa4",
    "f4b26174e42000ae07d24ae728c05e845e504153885b027dc36d4c239e1c4319",
    "09996b8988940f7097523d5c9d744e80435639f307610affe7f418535f1b9783",
    "b52a5dc2cae9a33a3e43bd8c9baf37925273f93108108ab476e2bcb8df91e0ca",
    "89b92d798daffca6d390fb6c7210972b0840ce6284be147a4c07ae0ab2a5ba02",
    "28372de749fbe959a76e3b208ae2db98e2fc4d4df6ee4a525faf149f6410763a",
    "a99b29c0d44c8656f30aa0618df57a2196d98d78460ff8c326cebcedea25f3af",
    "9d9226a10d080fa0f1c7d5c7dcaabcb66bb2ceb697f6bacef3377fd7a58c2140",
    "e3531aa3ff92ac36fe4a80d59ebb6da0396cf608ba104ba5bda47ca187aa7ef2",
    "aadd171f1384248c1f63bc0d54ac28fbef201ef7ffb726fb1b963b6edcd1c98d",
    "0bf194f0ad8dcc0f8da16a98201f6fc1f96396245031350523e90a541d5186bb",
    "548673436d9cb10a53a8d8e63edb7385254551b370ca4b0a472271af69cbd549",
    "d2273f598e3fd3638635552e42f31a1231e48f71f039c78c20b80cec3969181c",
    "9998422d4e5f45458f64e5aa7035d0731c900f4027fa664abf289eb95c8af0bd",
    "984a961c56c29608fc44cc74e17a0d46e329bd3d6b879cf8d6bc3efed7149148",
    "426b106a8bd839555ec6b0f6f756e61842f8da847a37b01609fe4fd7059766a9",
    "f499fede803a3767920ea63ce286b117b7a5b763d42b0a9c25af5391aca8c927",
    "b0f09e964edbb5228ec7bff942a40283d08b0efb71784fa0c944be40811d45d7",
    "de023d567c8502e7a2d323486db60ee3189fa2119ec705fe7fc1738285de60fb",
    "0452535733d8f391dc563eb0a8127cafd58bbbad2b0123bdeaf0f6c257fa0d7e",
    "2a7beb3b0dbb032c3b51c2b0a4192e34b4879ba7443fcc56b54df41feddd6cd2",
    "109a7923cdb4b52e2e8cae2b872f350a7da5a38abfe93e3e5bbba9126b1d61ef",
    "d726b350083abaef9f07c4834d1a0f192761e6ef337f12ab0b71355e80f9cb2f",
    "16294df57b2d7c5836775ca40c95164fdaa101344abbbf70c68f37d362e22665",
    "596b1ec8ecda40337ce40d0af8a95fdfc736ed3f3c191da4e4d0735961ecc340",
    "db9cd705aa17809ca506f0cbecae156589ddf4ff8926f963347edf4fc790effd",
    "24527053c4490e10a96ad06b6284922acaf064ea8efb979f5853c08bd4ce6194",
    "db1063a0e5a22ce5e9e47aeef3e50d893ff29e27a019b4f265a2fc6831e15308",
    "192f11ca26b0110e97a31d812f0f2dcc5a07c05e2de20ce7cfce5e125c8a08ef",
    "8788fbf4efa376db80d76a57e385cffa295c50ed93f4283d50138346ddfc9aad",
    "e2288a1070614f0bca986f5e885d5a788b6171fe3e04414d50806b06996964e8",
    "cbdf973271ecf6c1aa94bca028c35722b8f974bb9c9e9bcde55939018a84889d",
    "5847d5de2dfae77375c1d5ca826d9702c902c18c8b7310691599ce96dbcdde00",
    "6849e0ab6a31d677fa5a49c869a33f43508bfc636e62df7396c20c7a51bbea63",
    "51b405bde6669cdf97c703b1ccf5491d5b3020f4d2b036e8bb9ea2390af4e4e7",
    "1567e3a69371c3e15666874909056dc8609a700d3fc78e31c2b7e0f6273c39d3",
    "f59c07444d95be272efe55aa14ab5a30baff2c685dd3bdc123fede8c3adeb5e3",
    "fa0a1a070a8f60f3b15f65dbf9a2760d789ab51664139a0aac5b26ef0d7b0428",
    "fcca817d6fbb95f7b821e3c0f9eb3053e886a14a451c0776836ed603d479fba0",
    "6909844e2c530ab60946b4b89cd16c2b8bf990a952c3bf644ce70087b63ad100",
    "0bac92c2f06527d73266a135e679e8abb41ab9a403cd8845a8111f9947bf92d4",
    "d05eced11c68e3a6e32b029c856bb77dc77747902b6edf06992e72e424ec9b41",
    "03666d3afff7247d6f4075245bce511ba759bcc7a348333f73c3fb89347f5a38",
    "40c749c6df300f89083311efc78d257277d7c20c7d85cb2903e7a346d1f30b5e",
    "391d5d9461ad294206aa8ecf0d7d0523af9ce779a0c543bf50408ddc4bce54fb",
    "a5a65914a309a6ef20be4b507308710e1cad00925db2aa61c26ec33e9571a95e",
    "713b97a1f1b0826c04215ecc06c55f862a6886f30655999179559cf61743b65e",
    "5acc98861c34c21ca701c7cb9c1272fe8e68f945313e85c71f404883d51dd68a",
    "998ba773b91d62d46aaeb416ac8b52839aa042df0cdb5a6ec11cf67265511009",
    "2f49cb820d07e22b351df590c1415c71939c0536bdc4f18f656626090e25c16e",
    "9aed6dacaef5a40e99f2e098fe9e6834731b65b3626ae6c6f5c84611271d14e9",
    "4965c0d52f5d1dde43256d20cb1f511f225b45a1b370fccc4e6ba7252df76d88",
    "ce4fd2a2f2867e723ac9a303b40937a9e4b19f8b75df3dc34a1d9c6f338cec20",
    "b92498d1b465a2ab3d98d03520b8cc68a063abd4e9fdc8280ac3716c140a2a14",
    "a2c1de3e1021256b922f1ca4f2a3d80da34a6fc110fc9a4525b7d5fbdf7b19f1",
    "3a3b790165e2bdeab30368182e5bc89ed0ec060e9506d887b54c1a75709bb5fe",
    "a890268e17c8ebfedbd957958ef23e90986f8214b0756bd57e691436f7fb88d8",
    "a0f68b4061ab704107057991db3a566a7d61b6bb81cd97fb2d9ee29a3d6b3cc6",
    "8973d2d6a446e02067bd6ef4fd1db507d584923d961e0a8dd0a809f714f6e020",
}

local G = {
    [66654135] = 1, [210851291] = 2, [372226183] = 3, [703124385] = 4,
    [1202096104] = 5, [1268927906] = 6, [1686885941] = 7, [2380077519] = 8,
    [2440500124] = 9, [2619619496] = 10, [2668101271] = 11, [3317771874] = 12,
    [3508322461] = 13, [3647333358] = 14, [3808081382] = 15, [4348829796] = 16,
    [4730278139] = 17, [5203828273] = 18, [5361032378] = 19, [5595353122] = 20,
    [5750914919] = 21, [6035872082] = 22, [6331902150] = 23, [6739698191] = 24,
    [6760085372] = 25, [6931042565] = 26, [7094518649] = 27, [7108384194] = 28,
    [7219654364] = 29, [7326934954] = 30, [7585140258] = 31, [7613921865] = 32,
    [7633926880] = 33, [8356066619] = 34, [8964956538] = 35, [9051406594] = 36,
    [9199655655] = 37, [9641502068] = 38, [9656201728] = 39, [9855761734] = 40,
    [9880286438] = 41, [10035204815] = 42, [10144280947] = 43, [10173311467] = 44,
    [10187294555] = 45, [10199301628] = 46, [10399136326] = 47, [10405010493] = 48,
    [10410945205] = 49, [10456832990] = 50, [10475794799] = 51, [10502841145] = 52,
    [10526853622] = 53, [10530261598] = 54, [10539411000] = 55, [10563114921] = 56,
    [10634461028] = 57, [10675117523] = 58, [10690360998] = 59, [10708913337] = 60,
    [10756011174] = 61, [10764640833] = 62, [16116270224] = 63,
}

local ScriptIndex = G[game.GameId] or G[game.PlaceId]
if not ScriptIndex or not S[ScriptIndex] then
    game:GetService("StarterGui"):SetCore("SendNotification", {
        Title = "Fishy Dumper",
        Text = "Game này không được hỗ trợ.",
    })
    return
end

local ScriptHash = S[ScriptIndex]

local Junkie = loadstring(game:HttpGet("https://jnkie.com/sdk/library.lua"))()
Junkie.service = "Key"
Junkie.identifier = "1161164"
Junkie.provider = "Fishy"

local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local Players = game:GetService("Players")

local IsMobile = UserInputService.TouchEnabled and not UserInputService.KeyboardEnabled

local function Copy(text)
    if setclipboard then
        setclipboard(text)
    elseif toclipboard then
        toclipboard(text)
    end
end

local function hasFS()
    return pcall(function() return type(writefile) == "function" end)
        and pcall(function() return type(readfile) == "function" end)
        and pcall(function() return type(isfile) == "function" end)
end
local FS = hasFS()

local function saveKey(k)
    if not FS then return end
    pcall(function() writefile("verified_key.txt", k) end)
end

local function loadKey()
    if not FS then return nil end
    local ok, c = pcall(function() return readfile("verified_key.txt") end)
    if ok and c and c ~= "" then return c end
    return nil
end

local function clearKey()
    if not FS then return end
    pcall(function() if isfile("verified_key.txt") then delfile("verified_key.txt") end end)
end

local function getRequest()
    if type(syn) == "table" and type(syn.request) == "function" then return syn.request end
    if type(request) == "function" then return request end
    if type(http_request) == "function" then return http_request end
    if type(http) == "table" and type(http.request) == "function" then return http.request end
    return nil
end

local function httpRequest(opts)
    local req = getRequest()
    if not req then return false, nil end
    local done, result
    task.spawn(function()
        local ok, res = pcall(req, opts)
        done = true
        result = ok and res or nil
    end)
    local t0 = os.clock()
    repeat task.wait() until done or os.clock() - t0 > 20
    if not done then return false, nil end
    return true, result
end

-- CƯỠNG ÉP lấy toàn bộ code thô từ server
local function ForceFetchRawSource(key)
    local deliveryUrl = "https://api.jnkie.com/api/v1/luascripts/delivery/" .. ScriptHash .. "?v=2&errors=text"

    local ok, res = httpRequest({
        Url = deliveryUrl,
        Method = "POST",
        Headers = { ["Content-Type"] = "text/plain" },
        Body = tostring(key or ""),
    })

    if not ok or type(res) ~= "table" then
        return nil, "Không kết nối delivery server"
    end

    if res.StatusCode == 400 or res.StatusCode == 401 or res.StatusCode == 403 then
        local body = type(res.Body) == "string" and res.Body or ""
        local code, msg = body:match("^([^\r\n]+)\n([^\r\n]+)$")
        code = code or body
        if tostring(code):match("^LDR%-DENIED") then
            return nil, (msg and #msg <= 512 and msg) or "Key bị từ chối (LDR-DENIED)"
        end
        return nil, "Key không hợp lệ / bị chặn"
    end

    if res.StatusCode ~= 200 or type(res.Body) ~= "string" or not res.Body:match("^https://") then
        return nil, "Server không trả link script (Status: " .. tostring(res.StatusCode) .. ")"
    end

    local scriptUrl = res.Body

    local ok2, res2 = httpRequest({
        Url = scriptUrl,
        Method = "GET",
    })

    if not ok2 or type(res2) ~= "table" or res2.StatusCode ~= 200 then
        return nil, "Không tải được source (Status: " .. tostring(res2 and res2.StatusCode) .. ")"
    end

    local raw = res2.Body
    if type(raw) ~= "string" or #raw == 0 then
        return nil, "Body rỗng / không phải string"
    end

    -- Cưỡng ép giữ nguyên 100% raw, không cắt, không xử lý
    return raw, nil
end

-- ==================== UI ====================
local FromRGB = Color3.fromRGB
local UDim2New = UDim2.new
local UDimNew = UDim.new
local Vector2New = Vector2.new
local InstanceNew = Instance.new

local Theme = {
    Accent = FromRGB(157, 91, 255),
    AccentHover = FromRGB(205, 145, 255),
    Element = FromRGB(22, 16, 38),
    Hover = FromRGB(38, 28, 58),
    Danger = FromRGB(220, 70, 70),
    Success = FromRGB(70, 190, 120),
    White = FromRGB(248, 246, 253),
    Inactive = FromRGB(166, 155, 194),
    Text = FromRGB(248, 246, 253),
    Border = FromRGB(72, 35, 130),
    Background = FromRGB(13, 8, 24),
}

local FontFace = Enum.Font.GothamBold

local function SafeGetUI()
    local ok, res = pcall(function()
        return (gethui and gethui()) or game:GetService("CoreGui")
    end)
    return (ok and res) or game:GetService("CoreGui")
end

local function Create(class, props)
    local inst = InstanceNew(class)
    for k, v in pairs(props) do
        if k ~= "Parent" then inst[k] = v end
    end
    if props.Parent then inst.Parent = props.Parent end
    return inst
end

local function Corner(parent, r)
    return Create("UICorner", { Parent = parent, CornerRadius = UDimNew(0, r or 8) })
end

local function Stroke(parent, color, t)
    return Create("UIStroke", {
        Parent = parent,
        Color = color or Theme.Border,
        Thickness = 1,
        Transparency = t or 0.2,
        ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
    })
end

local function Tween(inst, info, goal)
    local tw = TweenService:Create(inst, info or TweenInfo.new(0.18, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), goal)
    tw:Play()
    return tw
end

local OpenInfo = TweenInfo.new(0.45, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
local CloseInfo = TweenInfo.new(0.22, Enum.EasingStyle.Quad, Enum.EasingDirection.In)

-- ==================== BẢNG DUMP – CƯỠNG ÉP CODE THÔ VÀO ĐÂY ====================
local function OpenDumpPanel(rawSource, keyNote)
    -- Ép rawSource phải là string đầy đủ
    rawSource = tostring(rawSource or "")
    local charCount = #rawSource

    local ScreenGui = Create("ScreenGui", {
        Parent = SafeGetUI(),
        Name = "FishyHubForcedDumper",
        ResetOnSpawn = false,
        IgnoreGuiInset = true,
        DisplayOrder = 1000,
        ZIndexBehavior = Enum.ZIndexBehavior.Global,
    })

    local UIScale = Create("UIScale", { Parent = ScreenGui, Scale = 1 })

    local MainW = IsMobile and 480 or 680
    local MainH = IsMobile and 440 or 560
    local TitleH = 44
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
    Corner(Main, 14)
    Stroke(Main, Theme.Border, 0.25)

    local TitleBar = Create("Frame", {
        Parent = Main,
        Size = UDim2New(1, 0, 0, TitleH),
        BackgroundColor3 = Theme.Element,
        BorderSizePixel = 0,
        ZIndex = 5,
    })
    Corner(TitleBar, 14)
    Create("Frame", {
        Parent = TitleBar,
        Size = UDim2New(1, 0, 0, 14),
        Position = UDim2New(0, 0, 1, -14),
        BackgroundColor3 = Theme.Element,
        BorderSizePixel = 0,
        ZIndex = 5,
    })

    Create("TextLabel", {
        Parent = TitleBar,
        Size = UDim2New(1, -110, 1, 0),
        Position = UDim2New(0, 14, 0, 0),
        BackgroundTransparency = 1,
        Font = FontFace,
        Text = "Fishy Hub  •  Forced Raw Dumper",
        TextColor3 = Theme.White,
        TextSize = 15,
        TextXAlignment = Enum.TextXAlignment.Left,
        ZIndex = 6,
    })

    local MinimizeBtn = Create("TextButton", {
        Parent = TitleBar,
        Size = UDim2New(0, 34, 0, 34),
        Position = UDim2New(1, -80, 0.5, -17),
        BackgroundColor3 = Theme.Hover,
        BorderSizePixel = 0,
        Font = FontFace,
        Text = "−",
        TextColor3 = Theme.White,
        TextSize = 20,
        AutoButtonColor = false,
        ZIndex = 7,
    })
    Corner(MinimizeBtn, 7)

    local CloseBtn = Create("TextButton", {
        Parent = TitleBar,
        Size = UDim2New(0, 34, 0, 34),
        Position = UDim2New(1, -40, 0.5, -17),
        BackgroundColor3 = Theme.Danger,
        BorderSizePixel = 0,
        Font = FontFace,
        Text = "×",
        TextColor3 = Theme.White,
        TextSize = 18,
        AutoButtonColor = false,
        ZIndex = 7,
    })
    Corner(CloseBtn, 7)

    local Content = Create("Frame", {
        Parent = Main,
        Size = UDim2New(1, -24, 1, -(TitleH + 18)),
        Position = UDim2New(0, 12, 0, TitleH + 10),
        BackgroundTransparency = 1,
        ZIndex = 3,
    })

    local InfoLabel = Create("TextLabel", {
        Parent = Content,
        Size = UDim2New(1, 0, 0, 22),
        BackgroundTransparency = 1,
        Font = FontFace,
        Text = "CƯỠNG ÉP THÀNH CÔNG  |  " .. (keyNote or "OK") .. "  |  " .. charCount .. " ký tự (raw đầy đủ)",
        TextColor3 = Theme.Success,
        TextSize = 13,
        TextXAlignment = Enum.TextXAlignment.Left,
        ZIndex = 4,
    })

    local CopyBtn = Create("TextButton", {
        Parent = Content,
        Size = UDim2New(1, 0, 0, 40),
        Position = UDim2New(0, 0, 0, 28),
        BackgroundColor3 = Theme.Accent,
        BorderSizePixel = 0,
        Font = FontFace,
        Text = "Copy All Code (1 lần) – toàn bộ " .. charCount .. " ký tự",
        TextColor3 = Theme.White,
        TextSize = 14,
        AutoButtonColor = false,
        ZIndex = 4,
    })
    Corner(CopyBtn, 9)

    CopyBtn.MouseEnter:Connect(function()
        Tween(CopyBtn, nil, { BackgroundColor3 = Theme.AccentHover })
    end)
    CopyBtn.MouseLeave:Connect(function()
        Tween(CopyBtn, nil, { BackgroundColor3 = Theme.Accent })
    end)

    CopyBtn.MouseButton1Click:Connect(function()
        -- Cưỡng ép copy 100% rawSource
        Copy(rawSource)
        CopyBtn.Text = "ĐÃ COPY TOÀN BỘ " .. charCount .. " KÝ TỰ!"
        CopyBtn.BackgroundColor3 = Theme.Success
        task.delay(2, function()
            if CopyBtn and CopyBtn.Parent then
                CopyBtn.Text = "Copy All Code (1 lần) – toàn bộ " .. charCount .. " ký tự"
                CopyBtn.BackgroundColor3 = Theme.Accent
            end
        end)
    end)

    -- Ô chứa code thô: dùng TextBox multi-line để giữ được toàn bộ, có thể scroll + select
    local CodeBox = Create("ScrollingFrame", {
        Parent = Content,
        Size = UDim2New(1, 0, 1, -80),
        Position = UDim2New(0, 0, 0, 76),
        BackgroundColor3 = Theme.Element,
        BorderSizePixel = 0,
        ScrollBarThickness = 6,
        CanvasSize = UDim2New(0, 0, 0, 0),
        AutomaticCanvasSize = Enum.AutomaticSize.Y,
        ZIndex = 4,
    })
    Corner(CodeBox, 9)

    -- TextBox: cưỡng ép nhét rawSource vào đây, ClearTextOnFocus = false, TextEditable = true để user select/copy thủ công nếu cần
    local CodeText = Create("TextBox", {
        Parent = CodeBox,
        Size = UDim2New(1, -16, 0, 0),
        Position = UDim2New(0, 8, 0, 6),
        BackgroundTransparency = 1,
        ClearTextOnFocus = false,
        MultiLine = true,
        TextEditable = true,
        Font = Enum.Font.Code,
        Text = rawSource, -- CƯỠNG ÉP TOÀN BỘ CODE THÔ VÀO ĐÂY
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
        local dragging, dragStart, startPos, changed
        TitleBar.InputBegan:Connect(function(input)
            if input.UserInputType ~= Enum.UserInputType.MouseButton1 and input.UserInputType ~= Enum.UserInputType.Touch then return end
            dragging = true
            dragStart = input.Position
            startPos = Main.Position
            if changed then return end
            changed = input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                    changed:Disconnect()
                    changed = nil
                end
            end)
        end)
        UserInputService.InputChanged:Connect(function(input)
            if not dragging then return end
            if input.UserInputType ~= Enum.UserInputType.MouseMovement and input.UserInputType ~= Enum.UserInputType.Touch then return end
            local delta = (input.Position - dragStart) / (UIScale.Scale or 1)
            Main.Position = UDim2New(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end)
    end

    local isMinimized = false
    local originalSize = Main.Size
    MinimizeBtn.MouseButton1Click:Connect(function()
        isMinimized = not isMinimized
        if isMinimized then
            Tween(Main, TweenInfo.new(0.25), { Size = UDim2New(0, MainW, 0, MinimizedH) })
            Content.Visible = false
            MinimizeBtn.Text = "+"
        else
            Tween(Main, TweenInfo.new(0.25), { Size = originalSize })
            Content.Visible = true
            MinimizeBtn.Text = "−"
        end
    end)

    CloseBtn.MouseButton1Click:Connect(function()
        Tween(Main, CloseInfo, { GroupTransparency = 1 })
        task.wait(0.22)
        ScreenGui:Destroy()
    end)

    MinimizeBtn.MouseEnter:Connect(function() Tween(MinimizeBtn, nil, { BackgroundColor3 = Theme.Accent }) end)
    MinimizeBtn.MouseLeave:Connect(function() Tween(MinimizeBtn, nil, { BackgroundColor3 = Theme.Hover }) end)
    CloseBtn.MouseEnter:Connect(function() Tween(CloseBtn, nil, { BackgroundColor3 = FromRGB(255, 90, 90) }) end)
    CloseBtn.MouseLeave:Connect(function() Tween(CloseBtn, nil, { BackgroundColor3 = Theme.Danger }) end)

    Tween(Main, OpenInfo, { GroupTransparency = 0 })
end

-- ==================== KEY UI ====================
local function OpenKeyUI(prefill)
    local Pad = IsMobile and 18 or 16
    local BtnH = IsMobile and 48 or 42
    local FieldH = IsMobile and 48 or 44
    local PanelW = IsMobile and 380 or 420
    local ContentW = PanelW - Pad * 2
    local HalfW = math.floor((ContentW - 10) / 2)

    local ScreenGui = Create("ScreenGui", {
        Parent = SafeGetUI(),
        Name = "FishyKeyForcedDumper",
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
        Size = UDim2New(0, PanelW, 0, 290),
        BackgroundColor3 = Theme.Background,
        BorderSizePixel = 0,
        ClipsDescendants = true,
        GroupTransparency = 1,
        ZIndex = 2,
    })
    Corner(Main, 14)
    Stroke(Main, Theme.Border, 0.3)

    local DragArea = Create("Frame", {
        Parent = Main,
        Size = UDim2New(1, 0, 0, 50),
        BackgroundTransparency = 1,
        ZIndex = 3,
    })

    Create("TextLabel", {
        Parent = Main,
        Size = UDim2New(1, -40, 0, 28),
        Position = UDim2New(0, 16, 0, 14),
        BackgroundTransparency = 1,
        Font = FontFace,
        Text = "Fishy Hub  •  Forced Raw Dumper",
        TextColor3 = Theme.White,
        TextSize = 16,
        TextXAlignment = Enum.TextXAlignment.Left,
        ZIndex = 4,
    })

    local CloseBtn = Create("TextButton", {
        Parent = Main,
        Size = UDim2New(0, 28, 0, 28),
        Position = UDim2New(1, -36, 0, 12),
        BackgroundTransparency = 1,
        Font = FontFace,
        Text = "×",
        TextColor3 = Theme.White,
        TextSize = 18,
        AutoButtonColor = false,
        ZIndex = 6,
    })

    Create("TextLabel", {
        Parent = Main,
        Size = UDim2New(1, -32, 0, 18),
        Position = UDim2New(0, 16, 0, 48),
        BackgroundTransparency = 1,
        Font = FontFace,
        Text = "Key đúng → Cưỡng ép code thô từ server vào bảng",
        TextColor3 = Theme.Inactive,
        TextSize = 12,
        TextXAlignment = Enum.TextXAlignment.Left,
        ZIndex = 4,
    })

    local KeyBox = Create("Frame", {
        Parent = Main,
        Size = UDim2New(0, ContentW, 0, FieldH),
        Position = UDim2New(0, Pad, 0, 78),
        BackgroundColor3 = Theme.Element,
        BorderSizePixel = 0,
        ZIndex = 3,
    })
    Corner(KeyBox, 10)
    local InputStroke = Stroke(KeyBox, Theme.Border, 0.2)

    local Box = Create("TextBox", {
        Parent = KeyBox,
        Size = UDim2New(1, -20, 1, 0),
        Position = UDim2New(0, 10, 0, 0),
        BackgroundTransparency = 1,
        ClearTextOnFocus = false,
        Font = FontFace,
        PlaceholderText = "Enter your key...",
        PlaceholderColor3 = Theme.Inactive,
        Text = type(prefill) == "string" and prefill or "",
        TextColor3 = Theme.Text,
        TextSize = 14,
        TextXAlignment = Enum.TextXAlignment.Left,
        ZIndex = 4,
    })

    local Status = Create("TextLabel", {
        Parent = Main,
        Size = UDim2New(1, -32, 0, 18),
        Position = UDim2New(0, 16, 0, 132),
        BackgroundTransparency = 1,
        Font = FontFace,
        Text = "Sẵn sàng cưỡng ép dump",
        TextColor3 = Theme.Inactive,
        TextSize = 12,
        TextXAlignment = Enum.TextXAlignment.Left,
        ZIndex = 4,
    })

    local function SideBtn(text, x, y, w, bg)
        local btn = Create("TextButton", {
            Parent = Main,
            Size = UDim2New(0, w, 0, BtnH),
            Position = UDim2New(0, x, 0, y),
            BackgroundColor3 = bg or Theme.Element,
            BorderSizePixel = 0,
            Font = FontFace,
            Text = text,
            TextColor3 = Theme.White,
            TextSize = 13,
            AutoButtonColor = false,
            ZIndex = 4,
        })
        Corner(btn, 10)
        if not bg then Stroke(btn, Theme.Border, 0.25) end
        btn.MouseEnter:Connect(function()
            Tween(btn, nil, { BackgroundColor3 = bg and Theme.AccentHover or Theme.Hover })
        end)
        btn.MouseLeave:Connect(function()
            Tween(btn, nil, { BackgroundColor3 = bg or Theme.Element })
        end)
        return btn
    end

    local DumpBtn = SideBtn("Cưỡng Ép Dump", Pad, 160, HalfW, Theme.Accent)
    local GetKeyBtn = SideBtn("Get Key", Pad + HalfW + 10, 160, HalfW)
    local DiscordBtn = SideBtn("Discord", Pad, 160 + BtnH + 10, ContentW)

    local Busy = false
    local Closed = false

    do
        local dragging, dragStart, startPos, changed
        DragArea.InputBegan:Connect(function(input)
            if input.UserInputType ~= Enum.UserInputType.MouseButton1 and input.UserInputType ~= Enum.UserInputType.Touch then return end
            dragging = true
            dragStart = input.Position
            startPos = Main.Position
            if changed then return end
            changed = input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                    changed:Disconnect()
                    changed = nil
                end
            end)
        end)
        UserInputService.InputChanged:Connect(function(input)
            if not dragging then return end
            if input.UserInputType ~= Enum.UserInputType.MouseMovement and input.UserInputType ~= Enum.UserInputType.Touch then return end
            local delta = (input.Position - dragStart) / (UIScale.Scale or 1)
            Main.Position = UDim2New(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end)
    end

    local function SetStatus(text, color)
        Status.Text = text
        Status.TextColor3 = color or Theme.Inactive
    end

    local function Dismiss(after)
        if Closed then return end
        Closed = true
        Tween(Main, CloseInfo, { GroupTransparency = 1 })
        task.wait(0.22)
        ScreenGui:Destroy()
        if after then after() end
    end

    local function RunForcedDump()
        if Busy or Closed then return end
        Busy = true
        DumpBtn.Text = "Đang cưỡng ép..."
        Box.TextEditable = false
        SetStatus("Đang kiểm tra key...", Theme.Inactive)

        task.spawn(function()
            local key = Box.Text:gsub("%s+", "")
            if key == "" then
                Busy = false
                DumpBtn.Text = "Cưỡng Ép Dump"
                Box.TextEditable = true
                SetStatus("Vui lòng nhập key.", Theme.Danger)
                return
            end

            local ok, res = pcall(function()
                return Junkie.check_key(key)
            end)

            if Closed then return end

            if not ok or not res or not res.valid then
                Busy = false
                DumpBtn.Text = "Cưỡng Ép Dump"
                Box.TextEditable = true
                Tween(InputStroke, nil, { Color = Theme.Danger, Transparency = 0 })
                SetStatus("Key không hợp lệ.", Theme.Danger)
                return
            end

            local note = "OK"
            if res.message == "KEYLESS" then
                getgenv().SCRIPT_KEY = "KEYLESS"
                clearKey()
                note = "KEYLESS"
            elseif res.message == "KEY_VALID" then
                saveKey(key)
                getgenv().SCRIPT_KEY = key
                note = "KEY_VALID"
            else
                Busy = false
                DumpBtn.Text = "Cưỡng Ép Dump"
                Box.TextEditable = true
                SetStatus("Key bị từ chối.", Theme.Danger)
                return
            end

            SetStatus("Key OK • Đang cưỡng ép lấy code thô từ server...", Theme.Success)

            local raw, err = ForceFetchRawSource(key)
            if Closed then return end

            if not raw then
                Busy = false
                DumpBtn.Text = "Cưỡng Ép Dump"
                Box.TextEditable = true
                SetStatus(err or "Lỗi cưỡng ép source", Theme.Danger)
                return
            end

            -- Thành công → đóng key UI → mở bảng và cưỡng ép nhét raw vào
            Dismiss(function()
                OpenDumpPanel(raw, note)
            end)
        end)
    end

    DumpBtn.MouseButton1Click:Connect(RunForcedDump)
    Box.FocusLost:Connect(function(enter)
        if enter then RunForcedDump() end
    end)

    GetKeyBtn.MouseButton1Click:Connect(function()
        Copy("https://discord.gg/fishyhub")
        SetStatus("Discord link đã copy", Theme.Accent)
    end)
    DiscordBtn.MouseButton1Click:Connect(function()
        Copy("https://discord.gg/fishyhub")
        SetStatus("Discord link đã copy", Theme.Accent)
    end)
    CloseBtn.MouseButton1Click:Connect(function() Dismiss() end)

    Tween(Main, OpenInfo, { GroupTransparency = 0, Position = UDim2New(0.5, 0, 0.5, 0) })
end

-- Silent
local function TrySilent(key)
    if not key or key == "" then return false end
    local ok, res = pcall(function() return Junkie.check_key(key) end)
    if not ok or not res or not res.valid then return false end

    if res.message == "KEYLESS" then
        getgenv().SCRIPT_KEY = "KEYLESS"
        clearKey()
    elseif res.message == "KEY_VALID" then
        saveKey(key)
        getgenv().SCRIPT_KEY = key
    else
        return false
    end

    local raw, err = ForceFetchRawSource(key)
    if raw then
        OpenDumpPanel(raw, res.message or "OK")
        return true
    end
    return false
end

local initial = getgenv().SCRIPT_KEY
if type(initial) ~= "string" or initial == "" then
    initial = loadKey()
end

if type(initial) == "string" and initial ~= "" and TrySilent(initial) then
    return
end

OpenKeyUI(initial)
