-- AHK SKIL v3 (Mobile) | Flags * Skin * FZ/FC * Macro * AHK SKIL * Clitch * Fontes * Mods
-- LocalScript / executor de cliente (Roblox, Luau)

local Players = game:GetService("Players")
local UIS = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local HttpService = game:GetService("HttpService")
local TweenService = game:GetService("TweenService")
local VIM = game:GetService("VirtualInputManager")
local Stats = game:GetService("Stats")
local Lighting = game:GetService("Lighting")
local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")
local genv = (getgenv and getgenv()) or _G

local BG_URL = "https://i.ibb.co/S7KSH0Nb/484875eff7636b4cf2a572a7c392ee21.jpg"
local BTN_URL = "https://i.ibb.co/93kmgT5d/7db1b1d0590c906e0cc407ea206c2177.jpg"

-- icones da barra lateral (texto/simbolo). Para usar imagem, ponha "rbxassetid://ID"
local ICONS = {
	Flags = "F", Skin = "S", ["FZ/FC"] = "Z", ["AHK SKIL"] = "A", Macro = "M",
	Clitch = "C", Fontes = "T", Fleasion = "R", Mods = "*",
}

-- ==========================================================
-- Limpeza de execucao anterior
-- ==========================================================
if genv.AHKSkilKill then pcall(genv.AHKSkilKill) end
local Conns, KillFns, Alive = {}, {}, true
local function on(sig, fn) local c = sig:Connect(fn); Conns[#Conns + 1] = c; return c end
local function onKill(fn) KillFns[#KillFns + 1] = fn end

print("[AHK SKIL] carregando...")
local function new(class, props, parent)
	local o = Instance.new(class)
	for k, v in pairs(props or {}) do o[k] = v end
	if parent then o.Parent = parent end
	return o
end
local function round(o, r) return new("UICorner", {CornerRadius = UDim.new(0, r)}, o) end
local function isPress(i)
	return i.UserInputType == Enum.UserInputType.Touch or i.UserInputType == Enum.UserInputType.MouseButton1
end
local function isMove(i)
	return i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch
end

-- arquivos
local FS = {}
function FS.write(n, t) return (pcall(function() writefile(n, t) end)) end
function FS.read(n)
	local ok, r = pcall(function() if isfile and isfile(n) then return readfile(n) end end)
	return ok and r or nil
end
function FS.exists(n) local ok, r = pcall(function() return isfile(n) end); return ok and r == true end
local function jenc(t) local ok, r = pcall(HttpService.JSONEncode, HttpService, t); return ok and r or nil end
local function jdec(s) local ok, r = pcall(HttpService.JSONDecode, HttpService, s); return ok and r or nil end
local function clip(t) return (pcall(function() setclipboard(t) end)) end

-- ==========================================================
-- TEMA
-- ==========================================================
local C = {
	bg = Color3.fromRGB(12, 12, 16), side = Color3.fromRGB(16, 16, 21), card = Color3.fromRGB(22, 22, 29),
	row = Color3.fromRGB(30, 30, 39), text = Color3.fromRGB(235, 235, 243), sub = Color3.fromRGB(130, 130, 148),
	acc = Color3.fromRGB(96, 140, 255), pill = Color3.fromRGB(10, 10, 14), stroke = Color3.fromRGB(44, 44, 56),
	ok = Color3.fromRGB(70, 210, 130), bad = Color3.fromRGB(255, 100, 110),
}

-- ==========================================================
-- GUI BASE
-- ==========================================================
local U = {regs = {}, rows = {}, pages = {}, tabs = {}, cur = nil, n = 0, pageOf = {}}
local parentGui = (gethui and gethui()) or PlayerGui
pcall(function() local o = parentGui:FindFirstChild("AHKSkilGUI"); if o then o:Destroy() end end)
local Gui = new("ScreenGui", {Name = "AHKSkilGUI", ResetOnSpawn = false, ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
	IgnoreGuiInset = true}, parentGui)
onKill(function() pcall(function() Gui:Destroy() end) end)

local Open = new("ImageButton", {Size = UDim2.fromOffset(56, 56), Position = UDim2.fromScale(0.03, 0.2),
	BackgroundColor3 = C.bg, Image = "", ScaleType = Enum.ScaleType.Crop, AutoButtonColor = false, ZIndex = 50}, Gui)
round(Open, 28)
new("UIStroke", {Color = Color3.fromRGB(235, 235, 245), Thickness = 2}, Open)

local Main = new("Frame", {Size = UDim2.fromOffset(640, 340), Position = UDim2.fromScale(0.5, 0.5),
	AnchorPoint = Vector2.new(0.5, 0.5), BackgroundColor3 = C.bg, BorderSizePixel = 0, Active = true,
	ClipsDescendants = true, Visible = false, ZIndex = 1}, Gui)
round(Main, 12)
new("UIStroke", {Color = C.stroke, Thickness = 1.2}, Main)
local MainSize = Main.Size

local function loadImage(url, file, imgObj)
	task.spawn(function()
		local ok, asset = pcall(function() writefile(file, game:HttpGet(url)); return getcustomasset(file) end)
		if ok and asset and imgObj.Parent then imgObj.Image = asset end
	end)
end
loadImage(BTN_URL, "ahk_btn.jpg", Open)

-- arrastar generico (toque sem arrastar = onTap)
local function makeDrag(obj, onTap, target)
	target = target or obj
	local dragging, moved, dInput, dStart, sPos = false, false
	obj.InputBegan:Connect(function(i)
		if isPress(i) then
			dragging, moved, dStart, sPos = true, false, i.Position, target.Position
			i.Changed:Connect(function()
				if i.UserInputState == Enum.UserInputState.End then
					dragging = false
					if not moved and onTap then onTap() end
				end
			end)
		end
	end)
	obj.InputChanged:Connect(function(i) if isMove(i) then dInput = i end end)
	on(UIS.InputChanged, function(i)
		if dragging and i == dInput then
			local d = i.Position - dStart
			if d.Magnitude > 6 then moved = true end
			if moved then target.Position = UDim2.new(sPos.X.Scale, sPos.X.Offset + d.X, sPos.Y.Scale, sPos.Y.Offset + d.Y) end
		end
	end)
end
makeDrag(Open, function() Main.Visible = not Main.Visible end)

-- Sidebar
local Side = new("Frame", {Size = UDim2.new(0, 140, 1, 0), BackgroundColor3 = C.side, BorderSizePixel = 0, ZIndex = 2}, Main)
new("TextLabel", {Size = UDim2.new(1, -16, 0, 22), Position = UDim2.fromOffset(14, 10), BackgroundTransparency = 1,
	Text = "AHK SKIL", TextColor3 = C.text, Font = Enum.Font.GothamBold, TextSize = 17,
	TextXAlignment = Enum.TextXAlignment.Left, ZIndex = 3}, Side)
new("TextLabel", {Size = UDim2.new(1, -16, 0, 12), Position = UDim2.fromOffset(14, 32), BackgroundTransparency = 1,
	Text = "v3", TextColor3 = C.sub, Font = Enum.Font.Gotham, TextSize = 10,
	TextXAlignment = Enum.TextXAlignment.Left, ZIndex = 3}, Side)
local SideList = new("ScrollingFrame", {Size = UDim2.new(1, 0, 1, -54), Position = UDim2.fromOffset(0, 50),
	BackgroundTransparency = 1, BorderSizePixel = 0, ScrollBarThickness = 0, CanvasSize = UDim2.new(),
	AutomaticCanvasSize = Enum.AutomaticSize.Y, ZIndex = 3}, Side)
new("UIListLayout", {Padding = UDim.new(0, 2), SortOrder = Enum.SortOrder.LayoutOrder}, SideList)
new("UIPadding", {PaddingLeft = UDim.new(0, 8), PaddingRight = UDim.new(0, 8)}, SideList)

-- Barra superior
local Top = new("Frame", {Size = UDim2.new(1, -140, 0, 40), Position = UDim2.fromOffset(140, 0),
	BackgroundTransparency = 1, ZIndex = 3}, Main)
makeDrag(Top, nil, Main)
local Pages = new("Frame", {Size = UDim2.new(1, -156, 1, -50), Position = UDim2.fromOffset(148, 44),
	BackgroundTransparency = 1, ZIndex = 2}, Main)

-- Overlay (menus dropdown flutuantes)
local Overlay = new("TextButton", {Size = UDim2.fromScale(1, 1), BackgroundTransparency = 1, Text = "", Visible = false,
	ZIndex = 100, AutoButtonColor = false}, Main)
local Menu = new("ScrollingFrame", {Size = UDim2.fromOffset(120, 100), BackgroundColor3 = C.row, BorderSizePixel = 0,
	ScrollBarThickness = 2, CanvasSize = UDim2.new(), AutomaticCanvasSize = Enum.AutomaticSize.Y, ZIndex = 101}, Overlay)
round(Menu, 8)
new("UIStroke", {Color = C.stroke, Thickness = 1}, Menu)
new("UIListLayout", {SortOrder = Enum.SortOrder.LayoutOrder}, Menu)
Overlay.MouseButton1Click:Connect(function() Overlay.Visible = false end)

function U.openMenu(anchor, options, current, onPick)
	for _, c in ipairs(Menu:GetChildren()) do if c:IsA("TextButton") then c:Destroy() end end
	if type(options) == "function" then options = options() end
	if #options == 0 then options = {"(vazio)"} end
	local w = math.max(anchor.AbsoluteSize.X, 110)
	for i, o in ipairs(options) do
		local b = new("TextButton", {Size = UDim2.new(1, 0, 0, 24), BackgroundTransparency = 1, LayoutOrder = i,
			Text = "  " .. tostring(o), TextColor3 = (o == current) and C.acc or C.text, Font = Enum.Font.GothamMedium,
			TextSize = 11, TextXAlignment = Enum.TextXAlignment.Left, AutoButtonColor = true, ZIndex = 102}, Menu)
		b.MouseButton1Click:Connect(function() Overlay.Visible = false; onPick(o) end)
	end
	local h = math.min(#options * 24, 132)
	local rel = anchor.AbsolutePosition - Main.AbsolutePosition
	local y = rel.Y + anchor.AbsoluteSize.Y + 3
	if y + h > Main.AbsoluteSize.Y - 4 then y = rel.Y - h - 3 end
	local x = math.clamp(rel.X + anchor.AbsoluteSize.X - w, 4, Main.AbsoluteSize.X - w - 4)
	Menu.Size = UDim2.fromOffset(w, h)
	Menu.Position = UDim2.fromOffset(x, y)
	Overlay.Visible = true
end

-- ==========================================================
-- Paginas, categorias e abas
-- ==========================================================
function U.category(text)
	U.n = U.n + (1)
	new("TextLabel", {Size = UDim2.new(1, 0, 0, 20), BackgroundTransparency = 1, LayoutOrder = U.n,
		Text = string.upper(text), TextColor3 = C.sub, Font = Enum.Font.GothamBold, TextSize = 9,
		TextXAlignment = Enum.TextXAlignment.Left, ZIndex = 4}, SideList)
end

function U.setTab(name)
	U.cur = name
	for n, p in pairs(U.pages) do p.sc.Visible = (n == name) end
	for n, t in pairs(U.tabs) do
		local sel = n == name
		TweenService:Create(t.btn, TweenInfo.new(0.12), {BackgroundTransparency = sel and 0.78 or 1}):Play()
		t.bar.Visible = sel
		t.txt.TextColor3 = sel and C.text or C.sub
		if t.ico:IsA("TextLabel") then t.ico.TextColor3 = sel and C.acc or C.sub else t.ico.ImageColor3 = sel and C.acc or C.sub end
	end
	if U.searchBox then U.searchBox.Text = ""; U.filter("") end
end

function U.addTab(name)
	U.n = U.n + (1)
	local btn = new("TextButton", {Size = UDim2.new(1, 0, 0, 30), BackgroundColor3 = C.acc, BackgroundTransparency = 1,
		Text = "", AutoButtonColor = false, LayoutOrder = U.n, ZIndex = 4}, SideList)
	round(btn, 7)
	local bar = new("Frame", {Size = UDim2.fromOffset(3, 16), Position = UDim2.new(0, 0, 0.5, -8), BackgroundColor3 = C.acc,
		BorderSizePixel = 0, Visible = false, ZIndex = 5}, btn)
	round(bar, 2)
	local icon = ICONS[name] or "*"
	local ico
	if tostring(icon):find("rbxasset") then
		ico = new("ImageLabel", {Size = UDim2.fromOffset(16, 16), Position = UDim2.fromOffset(10, 7), BackgroundTransparency = 1,
			Image = icon, ImageColor3 = C.sub, ZIndex = 5}, btn)
	else
		ico = new("TextLabel", {Size = UDim2.fromOffset(18, 30), Position = UDim2.fromOffset(9, 0), BackgroundTransparency = 1,
			Text = icon, TextColor3 = C.sub, Font = Enum.Font.GothamBold, TextSize = 13, ZIndex = 5}, btn)
	end
	local txt = new("TextLabel", {Size = UDim2.new(1, -34, 1, 0), Position = UDim2.fromOffset(32, 0), BackgroundTransparency = 1,
		Text = name, TextColor3 = C.sub, Font = Enum.Font.GothamMedium, TextSize = 12,
		TextXAlignment = Enum.TextXAlignment.Left, ZIndex = 5}, btn)
	local sc = new("ScrollingFrame", {Size = UDim2.fromScale(1, 1), BackgroundTransparency = 1, BorderSizePixel = 0,
		ScrollBarThickness = 3, CanvasSize = UDim2.new(), AutomaticCanvasSize = Enum.AutomaticSize.Y, Visible = false,
		ZIndex = 3}, Pages)
	local function col(px)
		local f = new("Frame", {Size = UDim2.new(0.5, -5, 0, 0), Position = UDim2.new(px, px == 0 and 0 or 5, 0, 0),
			AutomaticSize = Enum.AutomaticSize.Y, BackgroundTransparency = 1, ZIndex = 3}, sc)
		new("UIListLayout", {Padding = UDim.new(0, 4), SortOrder = Enum.SortOrder.LayoutOrder}, f)
		return f
	end
	local P = {sc = sc, L = col(0), R = col(0.5), name = name}
	U.pages[name], U.tabs[name] = P, {btn = btn, bar = bar, txt = txt, ico = ico}
	btn.MouseButton1Click:Connect(function() U.setTab(name) end)
	return P
end


-- executa cada aba protegida: se uma falhar, as outras continuam e o erro aparece na tela
local function Safe(name, fn)
	local ok, err = pcall(fn)
	if not ok then
		warn("[AHK SKIL] erro na aba " .. name .. ": " .. tostring(err))
		U.errs = (U.errs or 0) + 1
		new("TextLabel", {Size = UDim2.new(0, 520, 0, 16), Position = UDim2.new(0, 6, 1, -18 * U.errs - 4),
			BackgroundColor3 = Color3.new(0, 0, 0), BackgroundTransparency = 0.3, TextColor3 = C.bad, Font = Enum.Font.Code,
			TextSize = 10, TextXAlignment = Enum.TextXAlignment.Left, ZIndex = 200,
			Text = "ERRO aba " .. name .. ": " .. string.sub(tostring(err), 1, 150)}, Gui)
	end
end

-- secao: titulo discreto + cartao
function U.section(col, title)
	U.n = U.n + (1)
	new("TextLabel", {Size = UDim2.new(1, 0, 0, 16), BackgroundTransparency = 1, LayoutOrder = U.n, Text = "  " .. title,
		TextColor3 = C.sub, Font = Enum.Font.GothamBold, TextSize = 10, TextXAlignment = Enum.TextXAlignment.Left,
		ZIndex = 4}, col)
	U.n = U.n + (1)
	local card = new("Frame", {Size = UDim2.new(1, 0, 0, 0), AutomaticSize = Enum.AutomaticSize.Y, BackgroundColor3 = C.card,
		BorderSizePixel = 0, LayoutOrder = U.n, ZIndex = 4}, col)
	round(card, 8)
	new("UIStroke", {Color = C.stroke, Thickness = 1}, card)
	new("UIListLayout", {Padding = UDim.new(0, 1), SortOrder = Enum.SortOrder.LayoutOrder}, card)
	new("UIPadding", {PaddingTop = UDim.new(0, 3), PaddingBottom = UDim.new(0, 3), PaddingLeft = UDim.new(0, 8),
		PaddingRight = UDim.new(0, 8)}, card)
	local pg = col.Parent.Parent == Pages and col.Parent or nil
	U.pageOf[card] = pg
	return card
end

-- registra para busca e perfis
local function regRow(card, row, text)
	U.n = U.n + (1)
	row.LayoutOrder = U.n
	U.rows[#U.rows + 1] = {row = row, text = string.lower(text), card = card}
end
local function regKey(key, get, set) if key then U.regs[key] = {get = get, set = set} end end

local function rowBase(card, text, h)
	local row = new("Frame", {Size = UDim2.new(1, 0, 0, h or 30), BackgroundTransparency = 1, ZIndex = 5}, card)
	local lbl = new("TextLabel", {Size = UDim2.new(0.5, 0, 1, 0), BackgroundTransparency = 1, Text = text, TextColor3 = C.text,
		Font = Enum.Font.GothamMedium, TextSize = 11, TextXAlignment = Enum.TextXAlignment.Left, TextTruncate = Enum.TextTruncate.AtEnd,
		ZIndex = 6}, row)
	regRow(card, row, text)
	return row, lbl
end
local function lockScroll(obj, state)
	local s = obj:FindFirstAncestorWhichIsA("ScrollingFrame")
	if s then s.ScrollingEnabled = state end
end

-- Switch deslizante arredondado
function U.switch(card, text, init, cb, key)
	local row = rowBase(card, text)
	local pill = new("TextButton", {Size = UDim2.fromOffset(38, 20), Position = UDim2.new(1, -38, 0.5, -10), Text = "",
		AutoButtonColor = false, BackgroundColor3 = C.row, ZIndex = 6}, row)
	round(pill, 10)
	local knob = new("Frame", {Size = UDim2.fromOffset(14, 14), Position = UDim2.fromOffset(3, 3),
		BackgroundColor3 = Color3.new(1, 1, 1), BorderSizePixel = 0, ZIndex = 7}, pill)
	round(knob, 7)
	local S = {v = false}
	function S.set(v, silent)
		v = v and true or false
		S.v = v
		local ti = TweenInfo.new(0.12)
		TweenService:Create(knob, ti, {Position = v and UDim2.fromOffset(21, 3) or UDim2.fromOffset(3, 3)}):Play()
		TweenService:Create(pill, ti, {BackgroundColor3 = v and C.acc or C.row}):Play()
		if not silent and cb then task.spawn(cb, v) end
	end
	function S.get() return S.v end
	pill.MouseButton1Click:Connect(function() S.set(not S.v) end)
	S.set(init, true)
	regKey(key, S.get, S.set)
	return S
end

-- Keybind (pilula escura)
function U.keybind(card, text, init, cb, key)
	local row = rowBase(card, text)
	local b = new("TextButton", {Size = UDim2.fromOffset(70, 22), Position = UDim2.new(1, -70, 0.5, -11), BackgroundColor3 = C.pill,
		Text = init or "None", TextColor3 = C.text, Font = Enum.Font.GothamBold, TextSize = 10, AutoButtonColor = false,
		ZIndex = 6}, row)
	round(b, 11)
	new("UIStroke", {Color = C.stroke, Thickness = 1}, b)
	local K = {v = init or "None", waiting = false}
	function K.set(v, silent)
		K.v = v or "None"; b.Text = K.v
		if not silent and cb then task.spawn(cb, K.v) end
	end
	function K.get() return K.v end
	b.MouseButton1Click:Connect(function()
		if K.waiting then return end
		K.waiting = true; b.Text = "..."
		local c
		c = UIS.InputBegan:Connect(function(i)
			if i.UserInputType == Enum.UserInputType.Keyboard then
				c:Disconnect(); K.waiting = false
				K.set(i.KeyCode == Enum.KeyCode.Escape and "None" or i.KeyCode.Name)
			end
		end)
		task.delay(6, function() if K.waiting then c:Disconnect(); K.waiting = false; b.Text = K.v end end)
	end)
	regKey(key, K.get, K.set)
	return K
end

-- Slider com barra colorida, ponto e caixa numerica
function U.slider(card, text, min, max, init, step, cb, key)
	step = step or 1
	local row, lbl = rowBase(card, text)
	lbl.Size = UDim2.new(0.34, 0, 1, 0)
	local box = new("TextBox", {Size = UDim2.fromOffset(42, 20), Position = UDim2.new(1, -42, 0.5, -10), BackgroundColor3 = C.pill,
		Text = "", TextColor3 = C.text, Font = Enum.Font.GothamBold, TextSize = 10, ClearTextOnFocus = false, ZIndex = 6}, row)
	round(box, 6)
	local hit = new("TextButton", {Size = UDim2.new(0.66, -52, 0, 24), Position = UDim2.new(0.34, 0, 0.5, -12),
		BackgroundTransparency = 1, Text = "", ZIndex = 6}, row)
	local track = new("Frame", {Size = UDim2.new(1, -6, 0, 4), Position = UDim2.new(0, 3, 0.5, -2), BackgroundColor3 = C.pill,
		BorderSizePixel = 0, ZIndex = 6}, hit)
	round(track, 2)
	local fill = new("Frame", {Size = UDim2.fromScale(0, 1), BackgroundColor3 = C.acc, BorderSizePixel = 0, ZIndex = 7}, track)
	round(fill, 2)
	local dot = new("Frame", {Size = UDim2.fromOffset(12, 12), Position = UDim2.new(0, -6, 0.5, -6), BackgroundColor3 = Color3.new(1, 1, 1),
		BorderSizePixel = 0, ZIndex = 8}, track)
	round(dot, 6)
	local S = {v = init}
	local function fmt(v) return (step < 1) and string.format("%.2f", v):gsub("0+$", ""):gsub("%.$", "") or tostring(v) end
	function S.set(v, silent)
		v = tonumber(v) or S.v
		v = math.clamp(math.floor(v / step + 0.5) * step, min, max)
		v = tonumber(string.format("%.4f", v))
		S.v = v
		local a = (v - min) / (max - min)
		fill.Size = UDim2.fromScale(a, 1); dot.Position = UDim2.new(a, -6, 0.5, -6)
		box.Text = fmt(v)
		if not silent and cb then task.spawn(cb, v) end
	end
	function S.get() return S.v end
	local dragging = false
	local function setX(x)
		local a = math.clamp((x - track.AbsolutePosition.X) / math.max(track.AbsoluteSize.X, 1), 0, 1)
		S.set(min + (max - min) * a)
	end
	hit.InputBegan:Connect(function(i)
		if isPress(i) then
			dragging = true; lockScroll(hit, false); setX(i.Position.X)
			i.Changed:Connect(function()
				if i.UserInputState == Enum.UserInputState.End then dragging = false; lockScroll(hit, true) end
			end)
		end
	end)
	on(UIS.InputChanged, function(i) if dragging and isMove(i) then setX(i.Position.X) end end)
	box.FocusLost:Connect(function() S.set(tonumber(box.Text:match("-?[%d%.]+")) or S.v) end)
	S.set(init, true)
	regKey(key, S.get, S.set)
	return S
end

-- Dropdown compacto com menu flutuante
function U.dropdown(card, text, options, init, cb, key)
	local row = rowBase(card, text)
	local b = new("TextButton", {Size = UDim2.fromOffset(104, 22), Position = UDim2.new(1, -104, 0.5, -11), BackgroundColor3 = C.pill,
		Text = "", AutoButtonColor = false, ZIndex = 6}, row)
	round(b, 6)
	new("UIStroke", {Color = C.stroke, Thickness = 1}, b)
	local t = new("TextLabel", {Size = UDim2.new(1, -20, 1, 0), Position = UDim2.fromOffset(7, 0), BackgroundTransparency = 1,
		Text = "", TextColor3 = C.text, Font = Enum.Font.GothamMedium, TextSize = 10, TextXAlignment = Enum.TextXAlignment.Left,
		TextTruncate = Enum.TextTruncate.AtEnd, ZIndex = 7}, b)
	new("TextLabel", {Size = UDim2.fromOffset(14, 22), Position = UDim2.new(1, -16, 0, 0), BackgroundTransparency = 1, Text = "v",
		TextColor3 = C.sub, Font = Enum.Font.GothamBold, TextSize = 10, ZIndex = 7}, b)
	local D = {v = init}
	function D.set(v, silent)
		D.v = v; t.Text = tostring(v or "-")
		if not silent and cb then task.spawn(cb, v) end
	end
	function D.get() return D.v end
	b.MouseButton1Click:Connect(function() U.openMenu(b, options, D.v, function(o) D.set(o) end) end)
	D.set(init, true)
	regKey(key, D.get, D.set)
	return D
end

function U.textbox(card, text, init, cb, key, ph)
	local row = rowBase(card, text)
	local tb = new("TextBox", {Size = UDim2.fromOffset(104, 22), Position = UDim2.new(1, -104, 0.5, -11), BackgroundColor3 = C.pill,
		Text = init or "", PlaceholderText = ph or "", PlaceholderColor3 = C.sub, TextColor3 = C.text, Font = Enum.Font.GothamMedium,
		TextSize = 10, ClearTextOnFocus = false, ZIndex = 6}, row)
	round(tb, 6)
	local T = {}
	function T.set(v, silent) tb.Text = tostring(v or ""); if not silent and cb then task.spawn(cb, tb.Text) end end
	function T.get() return tb.Text end
	tb.FocusLost:Connect(function() if cb then cb(tb.Text) end end)
	regKey(key, T.get, T.set)
	T.box = tb
	return T
end

-- botoes em linha (1..3)
function U.buttons(card, list)
	local row = new("Frame", {Size = UDim2.new(1, 0, 0, 30), BackgroundTransparency = 1, ZIndex = 5}, card)
	regRow(card, row, "")
	local n = #list
	local out = {}
	for i, d in ipairs(list) do
		local b = new("TextButton", {Size = UDim2.new(1 / n, -4, 0, 24), Position = UDim2.new((i - 1) / n, (i == 1) and 0 or 2, 0.5, -12),
			BackgroundColor3 = d.color or C.row, Text = d[1], TextColor3 = d.tcolor or C.text, Font = Enum.Font.GothamBold,
			TextSize = 10, AutoButtonColor = true, ZIndex = 6}, row)
		round(b, 6)
		b.MouseButton1Click:Connect(function() if d[2] then d[2](b) end end)
		out[i] = b
	end
	return out
end

function U.note(card, text, color, h)
	local l = new("TextLabel", {Size = UDim2.new(1, 0, 0, h or 28), BackgroundTransparency = 1, Text = text, TextColor3 = color or C.sub,
		Font = Enum.Font.Gotham, TextSize = 10, TextWrapped = true, TextXAlignment = Enum.TextXAlignment.Left,
		TextYAlignment = Enum.TextYAlignment.Top, ZIndex = 6}, card)
	regRow(card, l, text)
	return l
end

-- ==========================================================
-- Barra superior: perfis (dropdown + editar) e busca
-- ==========================================================
do
	local PFILE = "AHKSKIL_profiles.json"
	local store = jdec(FS.read(PFILE) or "") or {}
	store.list = store.list or {}
	store.cur = store.cur or "Padrao"
	if not store.list[store.cur] then store.list[store.cur] = {} end
	local function names() local t = {}; for n in pairs(store.list) do t[#t + 1] = n end; table.sort(t); return t end
	local function persist() FS.write(PFILE, jenc(store) or "{}") end
	local function snapshot()
		local d = {}
		for k, r in pairs(U.regs) do local ok, v = pcall(r.get); if ok and v ~= nil then d[k] = v end end
		return d
	end
	local function apply(d)
		for k, v in pairs(d or {}) do local r = U.regs[k]; if r then pcall(r.set, v) end end
	end

	local pbtn = new("TextButton", {Size = UDim2.fromOffset(120, 24), Position = UDim2.fromOffset(0, 8), BackgroundColor3 = C.row,
		Text = "", AutoButtonColor = false, ZIndex = 4}, Top)
	round(pbtn, 7)
	local ptxt = new("TextLabel", {Size = UDim2.new(1, -22, 1, 0), Position = UDim2.fromOffset(8, 0), BackgroundTransparency = 1,
		Text = store.cur, TextColor3 = C.text, Font = Enum.Font.GothamMedium, TextSize = 11, TextXAlignment = Enum.TextXAlignment.Left,
		TextTruncate = Enum.TextTruncate.AtEnd, ZIndex = 5}, pbtn)
	new("TextLabel", {Size = UDim2.fromOffset(14, 24), Position = UDim2.new(1, -16, 0, 0), BackgroundTransparency = 1, Text = "v",
		TextColor3 = C.sub, Font = Enum.Font.GothamBold, TextSize = 10, ZIndex = 5}, pbtn)
	pbtn.MouseButton1Click:Connect(function()
		U.openMenu(pbtn, names, store.cur, function(n)
			store.cur = n; ptxt.Text = n; persist(); apply(store.list[n])
		end)
	end)

	-- icone editar (lapis desenhado)
	local ebtn = new("TextButton", {Size = UDim2.fromOffset(26, 24), Position = UDim2.fromOffset(126, 8), BackgroundColor3 = C.row,
		Text = "", AutoButtonColor = false, ZIndex = 4}, Top)
	round(ebtn, 7)
	local pen = new("Frame", {Size = UDim2.fromOffset(12, 4), Position = UDim2.new(0.5, -6, 0.5, -2), Rotation = -45,
		BackgroundColor3 = C.text, BorderSizePixel = 0, ZIndex = 5}, ebtn)
	round(pen, 1)

	local panel = new("Frame", {Size = UDim2.fromOffset(250, 62), Position = UDim2.fromOffset(0, 36), BackgroundColor3 = C.row,
		Visible = false, ZIndex = 20}, Top)
	round(panel, 8)
	new("UIStroke", {Color = C.stroke, Thickness = 1}, panel)
	local nameBox = new("TextBox", {Size = UDim2.new(1, -16, 0, 22), Position = UDim2.fromOffset(8, 6), BackgroundColor3 = C.pill,
		Text = store.cur, TextColor3 = C.text, Font = Enum.Font.GothamMedium, TextSize = 11, ClearTextOnFocus = false, ZIndex = 21}, panel)
	round(nameBox, 6)
	local function pbtn2(txt, x, w, fn, col)
		local b = new("TextButton", {Size = UDim2.fromOffset(w, 22), Position = UDim2.fromOffset(x, 34), BackgroundColor3 = col or C.pill,
			Text = txt, TextColor3 = C.text, Font = Enum.Font.GothamBold, TextSize = 10, ZIndex = 21}, panel)
		round(b, 6)
		b.MouseButton1Click:Connect(fn)
	end
	pbtn2("Salvar", 8, 72, function()
		local n = nameBox.Text:gsub("^%s+", ""):gsub("%s+$", "")
		if n == "" then return end
		store.cur = n; store.list[n] = snapshot(); ptxt.Text = n; persist(); panel.Visible = false
	end, C.acc)
	pbtn2("Novo", 86, 72, function()
		local n = nameBox.Text:gsub("^%s+", ""):gsub("%s+$", "")
		if n == "" or store.list[n] then return end
		store.list[n] = snapshot(); store.cur = n; ptxt.Text = n; persist(); panel.Visible = false
	end)
	pbtn2("Excluir", 164, 78, function()
		if store.cur == "Padrao" then return end
		store.list[store.cur] = nil; store.cur = "Padrao"; ptxt.Text = "Padrao"
		store.list["Padrao"] = store.list["Padrao"] or {}
		persist(); panel.Visible = false
	end, Color3.fromRGB(120, 40, 50))
	ebtn.MouseButton1Click:Connect(function() nameBox.Text = store.cur; panel.Visible = not panel.Visible end)

	-- minimizar / fechar
	local function tbtn(txt, x, fn)
		local b = new("TextButton", {Size = UDim2.fromOffset(24, 24), Position = UDim2.new(1, x, 0, 8), BackgroundColor3 = C.row,
			Text = txt, TextColor3 = C.text, Font = Enum.Font.GothamBold, TextSize = 12, AutoButtonColor = true, ZIndex = 4}, Top)
		round(b, 7)
		b.MouseButton1Click:Connect(fn)
	end
	local mini = false
	tbtn("-", -56, function()
		mini = not mini
		Main.Size = mini and UDim2.fromOffset(640, 40) or MainSize
	end)
	tbtn("x", -28, function() Main.Visible = false end)

	-- busca (lupa desenhada)
	local sbtn = new("TextButton", {Size = UDim2.fromOffset(26, 24), Position = UDim2.new(1, -86, 0, 8), BackgroundColor3 = C.row,
		Text = "", AutoButtonColor = false, ZIndex = 4}, Top)
	round(sbtn, 7)
	local lens = new("Frame", {Size = UDim2.fromOffset(10, 10), Position = UDim2.fromOffset(6, 5), BackgroundTransparency = 1, ZIndex = 5}, sbtn)
	round(lens, 5)
	new("UIStroke", {Color = C.text, Thickness = 1.6}, lens)
	local handle = new("Frame", {Size = UDim2.fromOffset(6, 2), Position = UDim2.fromOffset(14, 16), Rotation = 45,
		BackgroundColor3 = C.text, BorderSizePixel = 0, ZIndex = 5}, sbtn)
	local sb = new("TextBox", {Size = UDim2.fromOffset(110, 24), Position = UDim2.new(1, -202, 0, 8), BackgroundColor3 = C.pill,
		Text = "", PlaceholderText = "buscar...", PlaceholderColor3 = C.sub, TextColor3 = C.text, Font = Enum.Font.GothamMedium,
		TextSize = 11, ClearTextOnFocus = false, Visible = false, ZIndex = 4}, Top)
	round(sb, 7)
	U.searchBox = sb
	function U.filter(q)
		q = string.lower(q or "")
		local cardVis = {}
		local pg = U.pages[U.cur]
		for _, r in ipairs(U.rows) do
			if pg and r.row:IsDescendantOf(pg.sc) then
				local show = (q == "") or (r.text ~= "" and string.find(r.text, q, 1, true) ~= nil)
				r.row.Visible = show
				if show then cardVis[r.card] = true end
			end
		end
	end
	sbtn.MouseButton1Click:Connect(function()
		sb.Visible = not sb.Visible
		if sb.Visible then sb:CaptureFocus() else sb.Text = ""; U.filter("") end
	end)
	sb:GetPropertyChangedSignal("Text"):Connect(function() U.filter(sb.Text) end)
end

local function customRow(card, h, text)
	local f = new("Frame", {Size = UDim2.new(1, 0, 0, h), BackgroundTransparency = 1, ZIndex = 5}, card)
	regRow(card, f, text or "")
	return f
end

-- ==========================================================
-- FLAGS ENGINE
-- ==========================================================
local SAVE = "delta_fastflags.txt"
local PREFIXES = {"DFFlag", "DFInt", "DFString", "DFLog", "FFlag", "FInt", "FString", "FLog", "SFFlag"}
local FlagOpts = {variants = true, blockRisky = true, verify = true, batch = 80}
local FlagResults = {}

local function stripPrefix(n)
	for _, p in ipairs(PREFIXES) do
		if #n > #p and n:sub(1, #p) == p then return n:sub(#p + 1), p end
	end
	return n, nil
end

local function getSetters()
	local t = {}
	local function add(n, f) if type(f) == "function" then t[#t + 1] = {n = n, f = f} end end
	add("setfflag", setfflag)
	add("set_fflag", set_fflag)
	add("setfastflag", setfastflag)
	add("set_fast_flag", set_fast_flag)
	add("setfastflagforall", setfastflagforall)
	pcall(function() if syn then add("syn.setfflag", syn.setfflag) end end)
	pcall(function() if fluxus then add("fluxus.setfflag", fluxus.setfflag) end end)
	pcall(function() add("genv.setfflag", genv.setfflag) end)
	return t
end
local Setters = getSetters()
local Getter = (type(getfflag) == "function" and getfflag) or (type(get_fflag) == "function" and get_fflag) or nil

local function normVal(v)
	if v == nil then return "" end
	if type(v) == "boolean" then return v and "True" or "False" end
	local s = tostring(v):gsub("^%s+", ""):gsub("%s+$", ""):gsub(",%s*$", "")
	if s:match('^".*"$') then s = s:sub(2, -2) end
	local l = s:lower()
	if l == "true" then return "True" elseif l == "false" then return "False" end
	return s
end

local function trySet(name, sval)
	for _, s in ipairs(Setters) do
		if pcall(s.f, name, sval) then return true end
	end
	return false
end
local function verified(name, sval)
	if not Getter then return false end
	local ok, cur = pcall(Getter, name)
	if ok and cur ~= nil and tostring(cur) ~= "" then
		return tostring(cur):lower() == sval:lower()
	end
	return false
end

-- aplica o nome original, o nome sem prefixo e variantes (como o Masterstrap); devolve ok, nomeUsado, verificado, motivo
local function injectFlag(rawName, rawVal)
	local name = tostring(rawName):gsub("%s+", ""):gsub('"', "")
	if name == "" then return false, nil, false, "nome vazio" end
	if #Setters == 0 then return false, nil, false, "executor sem setfflag" end
	local sval = normVal(rawVal)
	local base = stripPrefix(name)
	local cand, seen = {}, {}
	local function add(n) if n ~= "" and not seen[n] then seen[n] = true; cand[#cand + 1] = n end end
	add(name)
	add(base)
	if FlagOpts.variants and base == name then
		local l = sval:lower()
		local order
		if l == "true" or l == "false" then order = {"FFlag", "DFFlag"}
		elseif tonumber(sval) then order = {"FInt", "DFInt"}
		else order = {"FString", "DFString"} end
		for _, p in ipairs(order) do add(p .. base) end
	end
	local any, ver, used = false, false, nil
	for _, c in ipairs(cand) do
		if trySet(c, sval) then
			any = true
			used = used or c
			if not ver and verified(c, sval) then ver = true end
		end
	end
	if any then return true, used, ver end
	return false, nil, false, "executor recusou"
end

local Risky = {"crash", "assert", "abort", "terminate", "forcequit", "deadlock", "nullderef", "disablevalidation"}
local function riskOf(name)
	local l = name:lower()
	for _, r in ipairs(Risky) do if l:find(r, 1, true) then return r end end
end

-- Parser: JSON (achatado), Nome=Valor, e JSON truncado/minificado
local function parseEntries(content)
	local entries, idx = {}, {}
	local function put(k, v)
		k = tostring(k):gsub("%s+", "")
		if k == "" then return end
		if idx[k] then entries[idx[k]].val = v
		else entries[#entries + 1] = {name = k, val = v}; idx[k] = #entries end
	end
	local function flat(t)
		for k, v in pairs(t) do
			if type(v) == "table" then flat(v)
			elseif type(k) == "string" then put(k, v) end
		end
	end
	local data = jdec(content)
	if type(data) == "table" then flat(data); if #entries > 0 then return entries end end
	-- texto livre / JSON quebrado
	for k, v in content:gmatch('"([%w_%.]+)"%s*:%s*"([^"]*)"') do put(k, v) end
	for k, v in content:gmatch('"([%w_%.]+)"%s*:%s*(%-?[%d%.]+)%s*[,}\r\n]') do put(k, v) end
	for k, v in content:gmatch('"([%w_%.]+)"%s*:%s*(%a+)%s*[,}\r\n]') do
		local l = v:lower(); if l == "true" or l == "false" then put(k, l) end
	end
	for line in content:gmatch("[^\r\n]+") do
		line = line:match("^%s*(.-)%s*$")
		if line ~= "" and not line:match("^[{%[%]}]") and not line:find('^"[%w_%.]+"%s*:') then
			local n, v = line:match('^([%w_%.]+)%s*[=:]%s*"?(.-)"?%s*,?$')
			if not n then n, v = line:match("^([%w_%.]+)%s+(.+)$") end
			if n then put(n, v) end
		end
	end
	return entries
end

local function parseAndInject(content, onEach)
	local entries = parseEntries(content)
	local N = #entries
	local total, success, failed, verif = 0, 0, 0, 0
	FlagResults = {}
	local i = 1
	while i <= N do
		local bEnd = math.min(i + FlagOpts.batch - 1, N)
		for j = i, bEnd do
			local e = entries[j]
			total = total + (1)
			local ok, used, ver, reason
			local risk = FlagOpts.blockRisky and riskOf(e.name)
			if risk then ok, reason = false, "bloqueada (" .. risk .. ")"
			else ok, used, ver, reason = injectFlag(e.name, e.val) end
			if ok then success = success + (1); if ver then verif = verif + (1) end else failed = failed + (1) end
			FlagResults[#FlagResults + 1] = {name = e.name, val = e.val, ok = ok, reason = reason}
			if onEach then onEach(e.name, e.val, ok, success, total, N, reason, verif) end
		end
		i = bEnd + 1
		if i <= N then task.wait() end
	end
	return total, success, failed, verif
end

-- ==========================================================
-- ABA FLAGS
-- ==========================================================
U.category("Principal")
Safe("Flags", function()
	local P = U.addTab("Flags")
	local function loadSaved() return FS.read(SAVE) or "" end
	local saved = loadSaved()
	local big
	if #saved > 30000 then big = saved; saved = "" end

	local cList = U.section(P.L, "Lista de flags")
	local boxRow = customRow(cList, 150)
	local scroll = new("ScrollingFrame", {Size = UDim2.new(1, 0, 1, -4), Position = UDim2.fromOffset(0, 2), BackgroundColor3 = C.pill,
		BorderSizePixel = 0, ScrollBarThickness = 3, CanvasSize = UDim2.new(), AutomaticCanvasSize = Enum.AutomaticSize.Y, ZIndex = 6}, boxRow)
	round(scroll, 6)
	local FlagBox = new("TextBox", {Size = UDim2.new(1, -8, 0, 140), Position = UDim2.fromOffset(4, 2), AutomaticSize = Enum.AutomaticSize.Y,
		BackgroundTransparency = 1, Text = saved, PlaceholderText = big and ("Lista grande salva (" .. #big .. " caracteres). Cole outra para substituir.")
			or 'Cole as flags (JSON ou Nome=Valor)', PlaceholderColor3 = C.sub, TextColor3 = C.text, Font = Enum.Font.Code, TextSize = 10,
		TextXAlignment = Enum.TextXAlignment.Left, TextYAlignment = Enum.TextYAlignment.Top, MultiLine = true, ClearTextOnFocus = false,
		TextWrapped = true, ZIndex = 7}, scroll)

	local cRes = U.section(P.R, "Resultado")
	local stat = U.note(cRes, "Total 0  |  OK 0  |  Falhou 0  |  Verif. 0", C.text, 16)
	local pbRow = customRow(cRes, 12)
	local barBg = new("Frame", {Size = UDim2.new(1, 0, 0, 6), Position = UDim2.new(0, 0, 0.5, -3), BackgroundColor3 = C.pill,
		BorderSizePixel = 0, ZIndex = 6}, pbRow)
	round(barBg, 3)
	local bar = new("Frame", {Size = UDim2.fromScale(0, 1), BackgroundColor3 = C.acc, BorderSizePixel = 0, ZIndex = 7}, barBg)
	round(bar, 3)
	local logLbl = U.note(cRes, "Setters: " .. #Setters .. (#Setters > 0 and (" (" .. Setters[1].n .. ")") or " (nenhum!)") ..
		(Getter and " | getfflag ok" or " | sem getfflag"), C.sub, 26)

	local cFail = U.section(P.R, "Falhas")
	local failRow = customRow(cFail, 78)
	local failList = new("ScrollingFrame", {Size = UDim2.fromScale(1, 1), BackgroundColor3 = C.pill, BorderSizePixel = 0,
		ScrollBarThickness = 3, CanvasSize = UDim2.new(), AutomaticCanvasSize = Enum.AutomaticSize.Y, ZIndex = 6}, failRow)
	round(failList, 6)
	new("UIListLayout", {SortOrder = Enum.SortOrder.LayoutOrder}, failList)
	local shown = 0
	local function clearFails()
		for _, c in ipairs(failList:GetChildren()) do if c:IsA("TextLabel") then c:Destroy() end end
		shown = 0
	end
	local function addFail(name, v, reason, order)
		if shown >= 300 then return end
		shown = shown + (1)
		new("TextLabel", {Size = UDim2.new(1, -6, 0, 12), BackgroundTransparency = 1, LayoutOrder = order,
			Text = " " .. name .. " = " .. tostring(v) .. " (" .. tostring(reason) .. ")", TextColor3 = C.bad, Font = Enum.Font.Code,
			TextSize = 9, TextXAlignment = Enum.TextXAlignment.Left, TextTruncate = Enum.TextTruncate.AtEnd, ZIndex = 7}, failList)
	end

	local injecting = false
	local function setStats(t, o, f, v) stat.Text = ("Total %d  |  OK %d  |  Falhou %d  |  Verif. %d"):format(t, o, f, v or 0) end
	local function run(content, mode, live)
		if injecting then return end
		if content:gsub("%s", "") == "" then logLbl.Text = "Nenhuma flag para injetar!"; return end
		injecting = true
		clearFails(); setStats(0, 0, 0, 0); bar.Size = UDim2.fromScale(0, 1)
		logLbl.Text = "Lendo lista..."
		task.spawn(function()
			task.wait(0.05)
			local t, o, f, v = parseAndInject(content, live and function(name, val, ok, success, total, N, reason, verif)
				if total % 10 == 0 or total == N then
					bar.Size = UDim2.fromScale(N > 0 and total / N or 0, 1)
					setStats(total, success, total - success, verif)
					logLbl.Text = (ok and "OK " or "ERRO ") .. name .. "  " .. total .. "/" .. N
				end
				if not ok then addFail(name, val, reason, total) end
			end or nil)
			if not live then
				local n = 0
				for _, r in ipairs(FlagResults) do if not r.ok then n = n + (1); addFail(r.name, r.val, r.reason, n) end end
			end
			bar.Size = UDim2.fromScale(1, 1)
			setStats(t, o, f, v)
			logLbl.Text = mode .. ": " .. t .. " lidas, " .. o .. " aceitas, " .. f .. " falharam" ..
				(Getter and (", " .. v .. " confirmadas") or "")
			injecting = false
		end)
	end
	local function current()
		local t = FlagBox.Text
		if t:gsub("%s", "") ~= "" then return t end
		return big or ""
	end
	U.buttons(cList, {
		{"Linha a linha", function() local c = current(); FS.write(SAVE, c); run(c, "Linha a linha", true) end},
		{"Injetar tudo", function() local c = current(); FS.write(SAVE, c); run(c, "Injetar tudo", false) end, color = C.acc},
		{"Limpar", function()
			if injecting then return end
			FlagBox.Text = ""; big = nil; FlagResults = {}; clearFails(); setStats(0, 0, 0, 0); bar.Size = UDim2.fromScale(0, 1)
			pcall(function() if delfile then delfile(SAVE) end end)
			logLbl.Text = "Limpo!"
		end},
	})

	local cFile = U.section(P.L, "Arquivo (listas grandes)")
	U.note(cFile, "Coloque o JSON na pasta do executor e injete direto, sem colar (evita limite de texto do celular).", C.sub, 28)
	local fname = U.textbox(cFile, "Nome do arquivo", "flags.json", nil, "flags_file")
	U.buttons(cFile, {
		{"Injetar do arquivo", function()
			local names = {fname.get(), "flags.json", "fastflags.json", "ClientAppSettings.json", "flags.txt"}
			for _, n in ipairs(names) do
				local c = FS.read(n)
				if c and c ~= "" then logLbl.Text = "Arquivo: " .. n; run(c, "Arquivo " .. n, false); return end
			end
			logLbl.Text = "Arquivo nao encontrado: " .. tostring(fname.get())
		end, color = C.acc},
		{"Carregar na caixa", function()
			local c = FS.read(fname.get())
			if not c then logLbl.Text = "Arquivo nao encontrado"; return end
			if #c > 30000 then big = c; FlagBox.Text = ""; logLbl.Text = "Lista grande carregada (" .. #c .. " chars)"
			else FlagBox.Text = c end
		end},
	})

	local cOpt = U.section(P.L, "Opcoes")
	U.switch(cOpt, "Testar variantes de prefixo", true, function(v) FlagOpts.variants = v end, "fl_variants")
	U.switch(cOpt, "Bloquear flags de crash", true, function(v) FlagOpts.blockRisky = v end, "fl_risky")
	U.slider(cOpt, "Lote por ciclo", 20, 300, 80, 10, function(v) FlagOpts.batch = v end, "fl_batch")

	U.buttons(cFail, {{"Copiar falhas", function(b)
		local out = ""
		for _, r in ipairs(FlagResults) do if not r.ok then out = out .. r.name .. " = " .. tostring(r.val) .. "\n" end end
		if out == "" then out = "Nenhuma falha." end
		clip(out); b.Text = "Copiado!"; task.delay(1.5, function() b.Text = "Copiar falhas" end)
	end}})
end)

-- ==========================================================
-- SKIN
-- ==========================================================
local Presets = {
	{"White", Color3.fromRGB(245, 248, 255)}, {"Purple", Color3.fromRGB(145, 65, 255)}, {"Red", Color3.fromRGB(255, 48, 72)},
	{"Divine", Color3.fromRGB(255, 205, 55)}, {"Cosmic Nebula", Color3.fromRGB(95, 55, 235)},
	{"Electric Pink", Color3.fromRGB(255, 45, 165)}, {"Sunset Horizon", Color3.fromRGB(255, 115, 55)},
	{"Black", Color3.fromRGB(10, 10, 12)},
}
local Skin = {Enabled = false, Color = Presets[2][2], Orig = {}, Conns = {}}
local Keywords = {"portal", "rift", "dimension", "warp", "void", "gate", "door", "tele"}
local function matches(name)
	name = string.lower(name)
	for _, kw in ipairs(Keywords) do if string.find(name, kw, 1, true) then return true end end
	return false
end
local function inPortal(inst)
	local c, d = inst, 0
	while c and c ~= game and d < 8 do
		if matches(c.Name) then return true end
		c = c.Parent; d = d + (1)
	end
	return false
end
local function skinSave(inst, key, val)
	Skin.Orig[inst] = Skin.Orig[inst] or {}
	if Skin.Orig[inst][key] == nil then Skin.Orig[inst][key] = val end
end
local function applyColor(inst, col)
	if not inst or not inst.Parent then return end
	pcall(function()
		if inst:IsA("ParticleEmitter") or inst:IsA("Trail") or inst:IsA("Beam") then
			skinSave(inst, "Color", inst.Color); inst.Color = ColorSequence.new(col)
		elseif inst:IsA("PointLight") or inst:IsA("SpotLight") or inst:IsA("SurfaceLight") then
			skinSave(inst, "Color", inst.Color); inst.Color = col
		elseif inst:IsA("Highlight") then
			skinSave(inst, "Fill", inst.FillColor); skinSave(inst, "Outline", inst.OutlineColor)
			inst.FillColor = col; inst.OutlineColor = col:Lerp(Color3.new(1, 1, 1), 0.35)
		elseif inst:IsA("BasePart") then
			local ch = LocalPlayer.Character
			if ch and inst:IsDescendantOf(ch) and not (matches(inst.Name) or inPortal(inst)) then return end
			skinSave(inst, "Color", inst.Color); inst.Color = col
		end
	end)
end
local function restoreSkin()
	for inst, o in pairs(Skin.Orig) do
		pcall(function()
			if inst.Parent then
				if inst:IsA("Highlight") then
					if o.Fill then inst.FillColor = o.Fill end
					if o.Outline then inst.OutlineColor = o.Outline end
				elseif o.Color then inst.Color = o.Color end
			end
		end)
	end
	table.clear(Skin.Orig)
end
local function shouldAffect(inst)
	if not inst or not inst.Parent then return false end
	if inst:IsDescendantOf(PlayerGui) or inst:IsDescendantOf(Gui) or inst:IsA("Camera") then return false end
	local ch = LocalPlayer.Character
	if ch and inst:IsDescendantOf(ch) then
		if inst:IsA("ParticleEmitter") or inst:IsA("Trail") or inst:IsA("Beam") or inst:IsA("PointLight") or inst:IsA("Highlight") then return true end
		if matches(inst.Name) or inPortal(inst) then return true end
	end
	if inst:IsDescendantOf(workspace) and (matches(inst.Name) or inPortal(inst)) then return true end
	return false
end
local function skinScan()
	if not Skin.Enabled then return end
	local targets = {}
	if LocalPlayer.Character then table.insert(targets, LocalPlayer.Character) end
	for _, c in ipairs(workspace:GetChildren()) do
		if matches(c.Name) or c.Name == "Effects" or c.Name == "FX" or c.Name == "Debris" then table.insert(targets, c) end
	end
	for _, root in ipairs(targets) do
		if shouldAffect(root) then applyColor(root, Skin.Color) end
		for _, d in ipairs(root:GetDescendants()) do if shouldAffect(d) then applyColor(d, Skin.Color) end end
	end
end
on(workspace.DescendantAdded, function(d)
	if not Skin.Enabled then return end
	task.defer(function() if Skin.Enabled and shouldAffect(d) then applyColor(d, Skin.Color) end end)
end)
on(LocalPlayer.CharacterAdded, function() table.clear(Skin.Orig); task.wait(0.3); skinScan() end)
task.spawn(function() while Alive do task.wait(1.4); if Skin.Enabled then skinScan() end end end)
onKill(function() Skin.Enabled = false; restoreSkin() end)

Safe("Skin", function()
	local P = U.addTab("Skin")
	local names = {}
	for _, p in ipairs(Presets) do names[#names + 1] = p[1] end
	local c = U.section(P.L, "Cor das skills / Portal")
	local pick = names[2]
	local function colorOf(n) for _, p in ipairs(Presets) do if p[1] == n then return p[2] end end return Presets[2][2] end
	local sw
	local dd = U.dropdown(c, "Preset", names, pick, function(v)
		pick = v
		Skin.Color = colorOf(v)
		if Skin.Enabled then restoreSkin(); skinScan() end
	end, "skin_preset")
	sw = U.switch(c, "Aplicar skin", false, function(v)
		Skin.Enabled = v
		Skin.Color = colorOf(pick)
		if v then skinScan() else restoreSkin() end
	end, "skin_on")
	local c2 = U.section(P.R, "Info")
	U.note(c2, "Troca a cor de efeitos, luzes e partes ligadas a portal/rift no seu personagem e no mapa. Desligar restaura as cores originais.", C.sub, 56)
end)

-- ==========================================================
-- INFRA COMPARTILHADA (entrada, equipar, eventos, mira/predict)
-- ==========================================================
local Lock = {busy = false, synth = false, lastInput = 0, quietUntil = 0}
local Sys = {ignoreJump = 0, jumpF = 60, jumpSoru = 18}
on(UIS.InputBegan, function() if not Lock.synth then Lock.lastInput = os.clock() end end)

local Hooks = {}
function Hooks.tap(name, hold)
	local kc = Enum.KeyCode[name]
	if not kc then return end
	Lock.synth = true
	VIM:SendKeyEvent(true, kc, false, game)
	task.wait((hold and hold > 0) and hold or 0.04)
	VIM:SendKeyEvent(false, kc, false, game)
	task.delay(0.15, function() Lock.synth = false end)
end
local function normKey(s)
	s = tostring(s or "")
	if #s == 1 then return s:upper() end
	return s:sub(1, 1):upper() .. s:sub(2)
end
local function findTool(pred)
	local ch = LocalPlayer.Character
	if ch then for _, t in ipairs(ch:GetChildren()) do if t:IsA("Tool") and pred(t) then return t, true end end end
	local bp = LocalPlayer:FindFirstChild("Backpack")
	if bp then for _, t in ipairs(bp:GetChildren()) do if t:IsA("Tool") and pred(t) then return t, false end end end
end
-- retorna achou, trocou
function Hooks.equipWhere(pred)
	local ch = LocalPlayer.Character
	local hum = ch and ch:FindFirstChildOfClass("Humanoid")
	if not hum then return false, false end
	local t, equipped = findTool(pred)
	if not t then return false, false end
	if equipped then return true, false end
	hum:EquipTool(t)
	local t0 = os.clock()
	while os.clock() - t0 < 0.6 do
		if t.Parent == ch then break end
		task.wait()
	end
	task.wait(0.03)
	return t.Parent == ch, true
end
function Hooks.equipTip(tip, nameLike)
	nameLike = (nameLike and nameLike ~= "") and nameLike:lower() or nil
	return Hooks.equipWhere(function(t)
		if tip and t.ToolTip ~= tip then return false end
		if nameLike and not t.Name:lower():find(nameLike, 1, true) then return false end
		return true
	end)
end
function Hooks.equipName(like)
	like = like:lower()
	return Hooks.equipWhere(function(t) return t.Name:lower():find(like, 1, true) ~= nil end)
end
local function portalEquipped()
	local ch = LocalPlayer.Character
	if not ch then return false end
	for _, t in ipairs(ch:GetChildren()) do
		if t:IsA("Tool") and t.Name:lower():find("portal", 1, true) then return true end
	end
	return false
end
local function getPing()
	local ok, v = pcall(function() return Stats.Network.ServerStatsItem["Data Ping"]:GetValue() end)
	return (ok and v) and v or 0
end

-- barramento de eventos (F / Soru) com debounce
local Bus = {l = {}, last = {}}
function Bus.on(name, fn) Bus.l[name] = Bus.l[name] or {}; table.insert(Bus.l[name], fn) end
function Bus.emit(name, ...)
	local now = os.clock()
	if Bus.last[name] and now - Bus.last[name] < 0.7 then return end
	Bus.last[name] = now
	for _, fn in ipairs(Bus.l[name] or {}) do task.spawn(fn, ...) end
end
genv.AHKSkilBus = function(name, ...) Bus.emit(name, ...) end

-- MIRA + PREDICT
local Aim = {on = false, pos = Vector3.zero, target = nil, silent = true, range = 300, mode = "Mais proximo",
	lead = 0.12, autoPing = true, projSpeed = 0, time = 0.45}
genv.AHKSkilAim = Aim

local function enemyRoots()
	local list = {}
	for _, p in ipairs(Players:GetPlayers()) do
		if p ~= LocalPlayer and p.Character then
			local h = p.Character:FindFirstChildOfClass("Humanoid")
			local r = p.Character:FindFirstChild("HumanoidRootPart")
			if h and r and h.Health > 0 then list[#list + 1] = r end
		end
	end
	local en = workspace:FindFirstChild("Enemies")
	if en then
		for _, m in ipairs(en:GetChildren()) do
			local h = m:FindFirstChildOfClass("Humanoid")
			local r = m:FindFirstChild("HumanoidRootPart")
			if h and r and h.Health > 0 then list[#list + 1] = r end
		end
	end
	return list
end
function Aim.pick()
	local ch = LocalPlayer.Character
	local me = ch and ch:FindFirstChild("HumanoidRootPart")
	local cam = workspace.CurrentCamera
	if not me or not cam then return nil end
	local best, bs
	for _, r in ipairs(enemyRoots()) do
		local d = (r.Position - me.Position).Magnitude
		if d <= Aim.range then
			local s
			if Aim.mode == "Centro da tela" then
				local dir = (r.Position - cam.CFrame.Position).Unit
				s = math.acos(math.clamp(dir:Dot(cam.CFrame.LookVector), -1, 1)) * 1000 + d * 0.01
			else s = d end
			if not bs or s < bs then best, bs = r, s end
		end
	end
	return best
end
function Aim.predict(r)
	local ch = LocalPlayer.Character
	local me = ch and ch:FindFirstChild("HumanoidRootPart")
	local t = Aim.lead + (Aim.autoPing and getPing() / 1000 or 0)
	if Aim.projSpeed > 0 and me then t = t + ((r.Position - me.Position).Magnitude / Aim.projSpeed) end
	local v = r.AssemblyLinearVelocity
	v = Vector3.new(v.X, v.Y * 0.4, v.Z)
	return r.Position + v * t
end
local aimConn
function Aim.stop()
	Aim.on = false; Aim.target = nil
	if aimConn then aimConn:Disconnect(); aimConn = nil end
end
function Aim.begin(r, dur)
	Aim.stop()
	if not r then return false end
	Aim.target = r
	Aim.pos = Aim.predict(r)
	Aim.on = true
	local t0 = os.clock()
	aimConn = RunService.RenderStepped:Connect(function()
		if not Aim.on or not r.Parent or os.clock() - t0 > (dur or Aim.time) then Aim.stop(); return end
		Aim.pos = Aim.predict(r)
		local cam = workspace.CurrentCamera
		if cam then cam.CFrame = CFrame.new(cam.CFrame.Position, Aim.pos) end
	end)
	return true
end
onKill(function() Aim.stop() end)

-- hook: observa F / Soru (FireServer e InvokeServer) e reescreve o Vector3 da skill enquanto a mira esta ativa
if hookmetamethod and getnamecallmethod and not genv.AHKSkilHook3 then
	pcall(function()
		local old
		old = hookmetamethod(game, "__namecall", function(self, ...)
			local m = getnamecallmethod()
			if m == "FireServer" or m == "InvokeServer" then
				local a1, a2 = ...
				local s = (typeof(a1) == "string" and a1) or (typeof(a2) == "string" and a2) or nil
				if s then
					local u = s:upper()
					genv.AHKSkilLast = s
					if (u == "F" or u == "SORU") and genv.AHKSkilBus then
						task.defer(genv.AHKSkilBus, u == "F" and "F" or "Soru")
					end
				end
				local aim = genv.AHKSkilAim
				if aim and aim.on and aim.silent and m == "FireServer" then
					local args = {n = select("#", ...), ...}
					local changed = false
					pcall(function()
						for i = 1, args.n do
							local a = args[i]
							if typeof(a) == "Vector3" then args[i] = aim.pos; changed = true
							elseif typeof(a) == "CFrame" then args[i] = CFrame.new(aim.pos); changed = true end
						end
					end)
					if changed then return old(self, unpack(args, 1, args.n)) end
				end
			end
			return old(self, ...)
		end)
		genv.AHKSkilHook3 = true
	end)
end

-- gatilhos por teclado e por teleporte (reserva quando o hook nao ve o remote)
on(UIS.InputBegan, function(i, gp)
	if not gp and i.KeyCode == Enum.KeyCode.F and not Lock.synth then Bus.emit("F") end
end)
do
	local samples = {}
	local lastJ = 0
	on(RunService.Heartbeat, function()
		local ch = LocalPlayer.Character
		local hrp = ch and ch:FindFirstChild("HumanoidRootPart")
		if not hrp then table.clear(samples) return end
		local now, pos = os.clock(), hrp.Position
		samples[#samples + 1] = {now, pos}
		while #samples > 1 and now - samples[1][1] > 0.25 do table.remove(samples, 1) end
		if Lock.busy or now < Lock.quietUntil or now < Sys.ignoreJump or now - lastJ < 0.7 then return end
		local d = pos - samples[1][2]
		local dist = Vector3.new(d.X, 0, d.Z).Magnitude
		if dist >= Sys.jumpSoru then
			lastJ = now
			table.clear(samples)
			if dist >= Sys.jumpF and portalEquipped() then Bus.emit("F") else Bus.emit("Soru") end
		end
	end)
end

-- ==========================================================
-- ABA FZ/FC
-- ==========================================================
U.category("Combate")
Safe("FZ/FC", function()
	local P = U.addTab("FZ/FC")
	local FZ = {Mode = nil, DelayFZ = 0.1, DelayFC = 0.25, needPortal = true}
	local status
	local function doAfterF(mode)
		if not FZ.Mode or Lock.busy then return end
		if FZ.needPortal and not portalEquipped() then
			if status then status.Text = "F visto, mas a Portal nao esta equipada" end
			return
		end
		Lock.busy = true
		task.spawn(function()
			local ok, err = pcall(function()
				if mode == "FZ" then
					task.wait(FZ.DelayFZ)
					local r = Aim.pick()
					if r then Aim.begin(r, Aim.time) end
					task.wait(0.05)
					Hooks.tap("Z")
					task.wait(0.25)
				else
					task.wait(FZ.DelayFC)
					local _, changed = Hooks.equipName("sanguine")
					if changed then task.wait(0.06) end
					local r = Aim.pick()
					if r then Aim.begin(r, Aim.time) end
					task.wait(0.05)
					Hooks.tap("C")
					task.wait(0.25)
				end
			end)
			Aim.stop()
			Lock.busy = false
			Lock.quietUntil = os.clock() + 0.8
			if status then status.Text = ok and ("Executado " .. mode) or ("Erro: " .. tostring(err)) end
		end)
	end
	Bus.on("F", function() doAfterF(FZ.Mode) end)

	local c1 = U.section(P.L, "Combo apos F (Portal)")
	local fzSw, fcSw
	fzSw = U.switch(c1, "FZ  F -> Z (Portal)", false, function(v)
		if v then FZ.Mode = "FZ"; fcSw.set(false, true) elseif FZ.Mode == "FZ" then FZ.Mode = nil end
	end, "fz_on")
	fcSw = U.switch(c1, "FC  F -> C (Sanguine)", false, function(v)
		if v then FZ.Mode = "FC"; fzSw.set(false, true) elseif FZ.Mode == "FC" then FZ.Mode = nil end
	end, "fc_on")
	U.slider(c1, "Delay apos F -> Z", 0, 1, 0.1, 0.01, function(v) FZ.DelayFZ = v end, "fz_delay")
	U.slider(c1, "Delay apos F -> C", 0, 1, 0.25, 0.01, function(v) FZ.DelayFC = v end, "fc_delay")
	U.switch(c1, "Exigir Portal equipada", true, function(v) FZ.needPortal = v end, "fz_needportal")
	status = U.note(c1, "Use o F da Portal normalmente.", C.sub, 16)

	local c2 = U.section(P.R, "Predict / Mira")
	U.slider(c2, "Lead (segundos)", 0, 0.6, 0.12, 0.01, function(v) Aim.lead = v end, "aim_lead")
	U.switch(c2, "Somar ping automatico", true, function(v) Aim.autoPing = v end, "aim_ping")
	U.slider(c2, "Veloc. projetil", 0, 400, 0, 10, function(v) Aim.projSpeed = v end, "aim_proj")
	U.slider(c2, "Duracao da mira", 0.15, 1.2, 0.45, 0.05, function(v) Aim.time = v end, "aim_time")
	U.slider(c2, "Alcance", 50, 800, 300, 10, function(v) Aim.range = v end, "aim_range")
	U.dropdown(c2, "Alvo", {"Mais proximo", "Centro da tela"}, "Mais proximo", function(v) Aim.mode = v end, "aim_mode")
	U.switch(c2, "Mirar tambem no remote", true, function(v) Aim.silent = v end, "aim_silent")

	local c3 = U.section(P.L, "Deteccao do F / Soru")
	local seen = U.note(c3, "", C.sub, 28)
	U.slider(c3, "Salto min. Soru", 8, 60, 18, 1, function(v) Sys.jumpSoru = v end, "det_soru")
	U.slider(c3, "Salto min. F (Portal)", 30, 300, 60, 5, function(v) Sys.jumpF = v end, "det_f")
	task.spawn(function()
		while Alive do
			seen.Text = (genv.AHKSkilHook3 and "Hook ativo. " or "Sem hook (usa teclado/teleporte). ") .. "Ultimo remote: " .. tostring(genv.AHKSkilLast or "-")
			task.wait(0.4)
		end
	end)
end)

-- ==========================================================
-- ABA AHK SKIL (Soru -> skills) + janela flutuante com editor de sequencia
-- ==========================================================
local AHK = {On = false, mode = "Apos Soru", startDelay = 0.12, switchDelay = 0.08, order = {}, cfg = {}, filt = {},
	running = false, winOn = false, status = function() end}
local Cats = {
	{name = "Melee", tip = "Melee", slot = "One", keys = {"Z", "X", "C"}},
	{name = "Sword", tip = "Sword", slot = "Three", keys = {"Z", "X"}},
	{name = "Fruit", tip = "Blox Fruit", slot = "Two", keys = {"Z", "X", "C", "V", "F"}},
	{name = "Gun", tip = "Gun", slot = "Four", keys = {"Z", "X"}},
}
local catInfo = {}
for _, c in ipairs(Cats) do catInfo[c.name] = c end
local AHK_FILE = "AHKSKIL_seq.json"
local MODES = {"Apos Soru", "Manual (botao)", "Apos F (Portal)"}

local function ahkReset()
	AHK.order = {}
	for _, c in ipairs(Cats) do
		AHK.cfg[c.name] = {}
		AHK.filt[c.name] = ""
		for _, k in ipairs(c.keys) do AHK.cfg[c.name][k] = {on = false, t = 0.2, mode = "D"} end
	end
end
ahkReset()
local function ahkExport()
	return {cfg = AHK.cfg, order = AHK.order, mode = AHK.mode, startDelay = AHK.startDelay, switchDelay = AHK.switchDelay, filt = AHK.filt}
end
local function ahkImport(d)
	if type(d) ~= "table" then return false end
	ahkReset()
	for cn, keys in pairs(d.cfg or {}) do
		if AHK.cfg[cn] and type(keys) == "table" then
			for kn, v in pairs(keys) do
				local dst = AHK.cfg[cn][kn]
				if dst and type(v) == "table" then
					dst.on = v.on == true
					dst.t = math.clamp(tonumber(v.t) or 0.2, 0, 5)
					dst.mode = (v.mode == "H") and "H" or "D"
				end
			end
		end
	end
	for _, o in ipairs(d.order or {}) do
		if type(o) == "table" and AHK.cfg[o.cat] and AHK.cfg[o.cat][o.key] and AHK.cfg[o.cat][o.key].on then
			AHK.order[#AHK.order + 1] = {cat = o.cat, key = o.key}
		end
	end
	for cn, v in pairs(d.filt or {}) do if AHK.filt[cn] ~= nil then AHK.filt[cn] = tostring(v) end end
	for _, m in ipairs(MODES) do if d.mode == m then AHK.mode = m end end
	AHK.startDelay = math.clamp(tonumber(d.startDelay) or AHK.startDelay, 0, 2)
	AHK.switchDelay = math.clamp(tonumber(d.switchDelay) or AHK.switchDelay, 0, 2)
	return true
end
local function ahkSave() return FS.write(AHK_FILE, jenc(ahkExport()) or "{}") end
do local s = FS.read(AHK_FILE); if s then ahkImport(jdec(s)) end end

local function orderIndex(cat, key)
	for i, o in ipairs(AHK.order) do if o.cat == cat and o.key == key then return i end end
end

function AHK.run()
	if AHK.running or Lock.busy then return end
	if #AHK.order == 0 then AHK.status("Fila vazia: ative alguma skill na janela"); return end
	AHK.running = true; Lock.busy = true
	local seq = table.clone(AHK.order)
	task.spawn(function()
		AHK.status("Executando...")
		task.wait(AHK.startDelay)
		local ok, err = pcall(function()
			local lastCat
			for idx, st in ipairs(seq) do
				local d = AHK.cfg[st.cat][st.key]
				if d.on then
					local info = catInfo[st.cat]
					if lastCat ~= st.cat then
						local found, changed = Hooks.equipTip(info.tip, AHK.filt[st.cat])
						if not found then Hooks.tap(info.slot); task.wait(0.12) end
						if changed or not found then task.wait(AHK.switchDelay) end
						lastCat = st.cat
					end
					if d.mode == "H" then Hooks.tap(st.key, math.max(d.t, 0.04))
					else Hooks.tap(st.key); if d.t > 0 then task.wait(d.t) end end
					AHK.status(("[%d] %s %s ok"):format(idx, st.cat, st.key))
				end
			end
		end)
		AHK.running = false; Lock.busy = false
		Lock.quietUntil = os.clock() + 0.8
		AHK.status(ok and "Pronto" or ("Erro: " .. tostring(err)))
	end)
end
Bus.on("Soru", function() if AHK.On and AHK.mode == "Apos Soru" then AHK.run() end end)
Bus.on("F", function() if AHK.On and AHK.mode == "Apos F (Portal)" then task.wait(0.05); AHK.run() end end)

local AhkWin, AhkBtn, MacroBtn
local buildAhkWindow
local function ahkWinSet(on)
	AHK.winOn = on
	if AhkWin then AhkWin:Destroy(); AhkWin = nil end
	if on then AhkWin = buildAhkWindow() end
end
onKill(function() if AhkWin then AhkWin:Destroy() end end)

function buildAhkWindow()
	local W = new("Frame", {Size = UDim2.fromOffset(540, 300), Position = UDim2.new(0.5, 0, 0.5, 0), AnchorPoint = Vector2.new(0.5, 0.5),
		BackgroundColor3 = C.bg, BorderSizePixel = 0, Active = true, ZIndex = 30}, Gui)
	round(W, 10)
	new("UIStroke", {Color = C.acc, Thickness = 1.3}, W)
	local H = new("Frame", {Size = UDim2.new(1, 0, 0, 32), BackgroundTransparency = 1, ZIndex = 31}, W)
	makeDrag(H, nil, W)
	new("TextLabel", {Size = UDim2.new(0, 160, 1, 0), Position = UDim2.fromOffset(12, 0), BackgroundTransparency = 1, Text = "AHK SKIL - Sequencia",
		TextColor3 = C.text, Font = Enum.Font.GothamBold, TextSize = 12, TextXAlignment = Enum.TextXAlignment.Left, ZIndex = 32}, H)
	local modeBtn = new("TextButton", {Size = UDim2.fromOffset(130, 22), Position = UDim2.new(1, -196, 0, 5), BackgroundColor3 = C.pill,
		Text = AHK.mode .. "  v", TextColor3 = C.acc, Font = Enum.Font.GothamBold, TextSize = 10, ZIndex = 32}, H)
	round(modeBtn, 6)
	local closeB = new("TextButton", {Size = UDim2.fromOffset(26, 22), Position = UDim2.new(1, -32, 0, 5), BackgroundColor3 = C.row,
		Text = "x", TextColor3 = C.text, Font = Enum.Font.GothamBold, TextSize = 12, ZIndex = 32}, H)
	round(closeB, 6)
	closeB.MouseButton1Click:Connect(function() AHK.winOn = false; if AhkWin then AhkWin:Destroy(); AhkWin = nil end end)
	-- seletor de modo (menu simples dentro da janela)
	local mm = new("Frame", {Size = UDim2.fromOffset(130, #MODES * 22), Position = UDim2.new(1, -196, 0, 28), BackgroundColor3 = C.row,
		Visible = false, ZIndex = 60}, W)
	round(mm, 6)
	for i, m in ipairs(MODES) do
		local b = new("TextButton", {Size = UDim2.new(1, 0, 0, 22), Position = UDim2.fromOffset(0, (i - 1) * 22), BackgroundTransparency = 1,
			Text = m, TextColor3 = C.text, Font = Enum.Font.GothamMedium, TextSize = 10, ZIndex = 61}, mm)
		b.MouseButton1Click:Connect(function() AHK.mode = m; modeBtn.Text = m .. "  v"; mm.Visible = false end)
	end
	modeBtn.MouseButton1Click:Connect(function() mm.Visible = not mm.Visible end)

	-- esquerda: categorias e teclas
	local L = new("Frame", {Size = UDim2.fromOffset(300, 258), Position = UDim2.fromOffset(8, 34), BackgroundColor3 = C.card, BorderSizePixel = 0,
		ZIndex = 31}, W)
	round(L, 8)
	local R = new("Frame", {Size = UDim2.fromOffset(220, 258), Position = UDim2.fromOffset(312, 34), BackgroundColor3 = C.card, BorderSizePixel = 0,
		ZIndex = 31}, W)
	round(R, 8)

	local pageFrames, tabBtns = {}, {}
	local filtBox
	local curCat = "Melee"
	local function showCat(n)
		curCat = n
		for name, pg in pairs(pageFrames) do pg.Visible = (name == n) end
		for name, b in pairs(tabBtns) do b.TextColor3 = (name == n) and C.acc or C.sub end
		if filtBox then filtBox.Text = AHK.filt[n] or "" end
	end

	-- direita: sequencia
	new("TextLabel", {Size = UDim2.new(1, -10, 0, 16), Position = UDim2.fromOffset(8, 4), BackgroundTransparency = 1, Text = "FILA (ordem de execucao)",
		TextColor3 = C.sub, Font = Enum.Font.GothamBold, TextSize = 9, TextXAlignment = Enum.TextXAlignment.Left, ZIndex = 32}, R)
	local QS = new("ScrollingFrame", {Size = UDim2.new(1, -12, 0, 118), Position = UDim2.fromOffset(6, 22), BackgroundColor3 = C.pill,
		BorderSizePixel = 0, ScrollBarThickness = 2, CanvasSize = UDim2.new(), AutomaticCanvasSize = Enum.AutomaticSize.Y, ZIndex = 32}, R)
	round(QS, 6)
	new("UIListLayout", {Padding = UDim.new(0, 2), SortOrder = Enum.SortOrder.LayoutOrder}, QS)
	local statusL = new("TextLabel", {Size = UDim2.new(1, -12, 0, 14), Position = UDim2.fromOffset(6, 142), BackgroundTransparency = 1,
		Text = "Pronto", TextColor3 = C.ok, Font = Enum.Font.Code, TextSize = 9, TextXAlignment = Enum.TextXAlignment.Left,
		TextTruncate = Enum.TextTruncate.AtEnd, ZIndex = 32}, R)
	AHK.status = function(t) if statusL.Parent then statusL.Text = t end end

	local setters = {}
	local redraw
	function redraw()
		for _, c in ipairs(QS:GetChildren()) do if c:IsA("Frame") then c:Destroy() end end
		for i, o in ipairs(AHK.order) do
			local d = AHK.cfg[o.cat][o.key]
			local row = new("Frame", {Size = UDim2.new(1, -4, 0, 20), BackgroundColor3 = C.row, BorderSizePixel = 0, LayoutOrder = i, ZIndex = 33}, QS)
			round(row, 4)
			new("TextLabel", {Size = UDim2.new(1, -66, 1, 0), Position = UDim2.fromOffset(5, 0), BackgroundTransparency = 1,
				Text = ("%d. %s %s  %s%.2fs"):format(i, o.cat, o.key, d.mode == "H" and "H" or "D", d.t), TextColor3 = C.text,
				Font = Enum.Font.GothamMedium, TextSize = 9, TextXAlignment = Enum.TextXAlignment.Left, ZIndex = 34}, row)
			local function sb(txt, x, fn)
				local b = new("TextButton", {Size = UDim2.fromOffset(16, 16), Position = UDim2.new(1, x, 0.5, -8), BackgroundColor3 = C.pill,
					Text = txt, TextColor3 = C.text, Font = Enum.Font.GothamBold, TextSize = 9, ZIndex = 34}, row)
				round(b, 4)
				b.MouseButton1Click:Connect(fn)
			end
			sb("^", -58, function() if i > 1 then AHK.order[i], AHK.order[i - 1] = AHK.order[i - 1], AHK.order[i]; redraw() end end)
			sb("v", -40, function() if i < #AHK.order then AHK.order[i], AHK.order[i + 1] = AHK.order[i + 1], AHK.order[i]; redraw() end end)
			sb("x", -20, function()
				d.on = false
				table.remove(AHK.order, i)
				local s = setters[o.cat .. o.key]; if s then s(false) end
				redraw()
			end)
		end
	end

	-- abas de categoria
	for ci, c in ipairs(Cats) do
		local name = c.name
		local tb = new("TextButton", {Size = UDim2.new(0.25, 0, 0, 22), Position = UDim2.new((ci - 1) * 0.25, 0, 0, 4), BackgroundTransparency = 1,
			Text = name, Font = Enum.Font.GothamBold, TextSize = 11, TextColor3 = C.sub, ZIndex = 32}, L)
		tabBtns[name] = tb
		tb.MouseButton1Click:Connect(function() showCat(name) end)
		local pg = new("ScrollingFrame", {Size = UDim2.new(1, -10, 1, -62), Position = UDim2.fromOffset(5, 30), BackgroundTransparency = 1,
			BorderSizePixel = 0, ScrollBarThickness = 2, CanvasSize = UDim2.new(), AutomaticCanvasSize = Enum.AutomaticSize.Y, Visible = false,
			ZIndex = 32}, L)
		new("UIListLayout", {Padding = UDim.new(0, 3), SortOrder = Enum.SortOrder.LayoutOrder}, pg)
		pageFrames[name] = pg
		for ki, key in ipairs(c.keys) do
			local d = AHK.cfg[name][key]
			local row = new("Frame", {Size = UDim2.new(1, -4, 0, 30), BackgroundColor3 = C.row, BorderSizePixel = 0, LayoutOrder = ki, ZIndex = 33}, pg)
			round(row, 6)
			new("TextLabel", {Size = UDim2.fromOffset(52, 30), Position = UDim2.fromOffset(8, 0), BackgroundTransparency = 1, Text = "Skill " .. key,
				TextColor3 = C.text, Font = Enum.Font.GothamBold, TextSize = 10, TextXAlignment = Enum.TextXAlignment.Left, ZIndex = 34}, row)
			local pill = new("TextButton", {Size = UDim2.fromOffset(34, 18), Position = UDim2.new(1, -40, 0.5, -9), Text = "", AutoButtonColor = false,
				BackgroundColor3 = C.pill, ZIndex = 34}, row)
			round(pill, 9)
			local knob = new("Frame", {Size = UDim2.fromOffset(12, 12), Position = UDim2.fromOffset(3, 3), BackgroundColor3 = Color3.new(1, 1, 1),
				BorderSizePixel = 0, ZIndex = 35}, pill)
			round(knob, 6)
			local function paint(v)
				pill.BackgroundColor3 = v and C.acc or C.pill
				knob.Position = v and UDim2.fromOffset(19, 3) or UDim2.fromOffset(3, 3)
			end
			paint(d.on)
			setters[name .. key] = paint
			pill.MouseButton1Click:Connect(function()
				d.on = not d.on
				paint(d.on)
				local idx = orderIndex(name, key)
				if d.on and not idx then AHK.order[#AHK.order + 1] = {cat = name, key = key}
				elseif not d.on and idx then table.remove(AHK.order, idx) end
				redraw()
			end)
			local tbx = new("TextBox", {Size = UDim2.fromOffset(52, 22), Position = UDim2.fromOffset(66, 4), BackgroundColor3 = C.pill,
				Text = tostring(d.t), TextColor3 = C.acc, Font = Enum.Font.GothamBold, TextSize = 10, ClearTextOnFocus = false, ZIndex = 34}, row)
			round(tbx, 5)
			tbx.FocusLost:Connect(function()
				d.t = math.clamp(tonumber(tbx.Text:match("[%d%.]+")) or d.t, 0, 5)
				tbx.Text = tostring(d.t); redraw()
			end)
			local mb = new("TextButton", {Size = UDim2.fromOffset(58, 22), Position = UDim2.fromOffset(124, 4), BackgroundColor3 = C.pill,
				Text = d.mode == "H" and "Hold" or "Delay", TextColor3 = C.text, Font = Enum.Font.GothamBold, TextSize = 9, ZIndex = 34}, row)
			round(mb, 5)
			mb.MouseButton1Click:Connect(function()
				d.mode = (d.mode == "H") and "D" or "H"
				mb.Text = d.mode == "H" and "Hold" or "Delay"
				redraw()
			end)
		end
	end
	-- filtro por nome da tool (opcional) da categoria atual
	filtBox = new("TextBox", {Size = UDim2.new(1, -10, 0, 22), Position = UDim2.new(0, 5, 1, -28), BackgroundColor3 = C.pill, Text = "",
		PlaceholderText = "Nome da tool contem (opcional)", PlaceholderColor3 = C.sub, TextColor3 = C.text, Font = Enum.Font.GothamMedium,
		TextSize = 10, ClearTextOnFocus = false, ZIndex = 33}, L)
	round(filtBox, 5)
	filtBox.FocusLost:Connect(function() AHK.filt[curCat] = filtBox.Text end)

	-- botoes da direita
	local function rb(txt, x, y, w, fn, col)
		local b = new("TextButton", {Size = UDim2.fromOffset(w, 24), Position = UDim2.fromOffset(x, y), BackgroundColor3 = col or C.row, Text = txt,
			TextColor3 = C.text, Font = Enum.Font.GothamBold, TextSize = 10, ZIndex = 33}, R)
		round(b, 6)
		b.MouseButton1Click:Connect(function() fn(b) end)
	end
	rb("Montar", 6, 160, 66, function() redraw(); AHK.status(#AHK.order .. " passos na fila") end)
	rb("Rodar", 76, 160, 66, function() redraw(); AHK.run() end, C.acc)
	rb("Reset", 146, 160, 66, function()
		ahkReset(); AHK.status("Resetado")
		ahkWinSet(true)
	end, Color3.fromRGB(120, 40, 50))
	rb("Save", 6, 188, 66, function(b) b.Text = ahkSave() and "Salvo!" or "Erro"; task.delay(1.2, function() if b.Parent then b.Text = "Save" end end) end)
	rb("Share", 76, 188, 66, function(b)
		local ok = clip(jenc(ahkExport()) or "")
		b.Text = ok and "Copiado!" or "Sem clip"; task.delay(1.2, function() if b.Parent then b.Text = "Share" end end)
	end)
	local impBox = new("TextBox", {Size = UDim2.fromOffset(136, 22), Position = UDim2.fromOffset(6, 218), BackgroundColor3 = C.pill, Text = "",
		PlaceholderText = "cole o JSON aqui", PlaceholderColor3 = C.sub, TextColor3 = C.text, Font = Enum.Font.Code, TextSize = 9,
		ClearTextOnFocus = false, ZIndex = 33}, R)
	round(impBox, 5)
	rb("Importar", 146, 217, 68, function()
		local d = jdec(impBox.Text)
		if ahkImport(d) then ahkSave(); ahkWinSet(true) else AHK.status("JSON invalido") end
	end)
	showCat("Melee")
	redraw()
	return W
end

Safe("AHK SKIL", function()
	local P = U.addTab("AHK SKIL")
	local c1 = U.section(P.L, "Soru -> Skill")
	U.switch(c1, "Ativar AHK", false, function(v) AHK.On = v end, "ahk_on")
	U.dropdown(c1, "Modo", MODES, AHK.mode, function(v) AHK.mode = v end, "ahk_mode")
	U.slider(c1, "Delay inicial", 0, 1, AHK.startDelay, 0.01, function(v) AHK.startDelay = v end, "ahk_start")
	U.slider(c1, "Delay troca arma", 0, 1, AHK.switchDelay, 0.01, function(v) AHK.switchDelay = v end, "ahk_switch")
	local st = U.note(c1, "Escolha as skills na janela. Ao usar o Soru, o script troca para a arma/fruta/estilo e solta a fila.", C.sub, 40)

	local c2 = U.section(P.R, "Janela de sequencia")
	local winSw
	winSw = U.switch(c2, "Janela flutuante", false, function(v) ahkWinSet(v) end)
	U.switch(c2, "Botao p/ abrir janela", false, function(v)
		if AhkBtn then AhkBtn:Destroy(); AhkBtn = nil end
		if v then
			AhkBtn = new("TextButton", {Size = UDim2.fromOffset(40, 40), Position = UDim2.fromScale(0.03, 0.55), BackgroundColor3 = C.bg,
				Text = "AHK", TextColor3 = C.acc, Font = Enum.Font.GothamBold, TextSize = 11, AutoButtonColor = false, ZIndex = 45}, Gui)
			round(AhkBtn, 20)
			new("UIStroke", {Color = C.acc, Thickness = 1.5}, AhkBtn)
			makeDrag(AhkBtn, function() ahkWinSet(not AHK.winOn); winSw.set(AHK.winOn, true) end)
		end
	end)
	U.switch(c2, "Botao RODAR flutuante", false, function(v)
		if MacroBtn then MacroBtn:Destroy(); MacroBtn = nil end
		if v then
			MacroBtn = new("TextButton", {Size = UDim2.fromOffset(52, 32), Position = UDim2.fromScale(0.85, 0.4), BackgroundColor3 = C.bg,
				Text = "RODAR", TextColor3 = C.text, Font = Enum.Font.GothamBold, TextSize = 10, AutoButtonColor = false, ZIndex = 46}, Gui)
			round(MacroBtn, 8)
			new("UIStroke", {Color = C.acc, Thickness = 1.5}, MacroBtn)
			makeDrag(MacroBtn, function() AHK.run() end)
		end
	end)
	U.buttons(c2, {
		{"Rodar agora", function() AHK.run() end, color = C.acc},
		{"Salvar", function() ahkSave() end},
		{"Resetar", function() ahkReset(); if AHK.winOn then ahkWinSet(true) end end},
	})
	AHK.status = function(t) st.Text = t end
	onKill(function() if AhkBtn then AhkBtn:Destroy() end; if MacroBtn then MacroBtn:Destroy() end end)
end)

-- ==========================================================
-- ABA MACRO (arquivo hotkey.txt)
-- ==========================================================
local Macro = {On = false, last = nil, blocks = {}, running = false, cancel = false, count = 0}
local MFILE, MSAVED = "hotkey.txt", "hotkey_saved.txt"
local MTEMPLATE = [[# AHK SKIL - arquivo hotkey (uma linha = um comando, # comenta)
# Comandos: press Z | hold Z 0.4 | down Z | up Z | wait 0.2
#   equip melee|sword|fruit|gun | equip name sanguine | slot One
#   aim | aimstop | repeat 3 ... end | log texto
# Gatilhos: on Soru | on F | key Q | main (roda no botao RODAR)
# Exemplo (tire o # para usar):
# on Soru
#   equip sword
#   press Z
#   wait 0.2
#   press X
# end
]]
local TIPS = {melee = "Melee", sword = "Sword", fruit = "Blox Fruit", gun = "Gun"}

local function parseMacro(text)
	local blocks = {}
	local main = {kind = "main", trig = "main", body = {}}
	local stack, cur, curBlock = {}, main.body, nil
	for raw in text:gmatch("[^\r\n]+") do
		local line = raw:gsub("#.*$", ""):gsub("%-%-.*$", ""):match("^%s*(.-)%s*$")
		if line ~= "" then
			local w = {}
			for t in line:gmatch("%S+") do w[#w + 1] = t end
			local cmd = w[1]:lower()
			if (cmd == "on" or cmd == "key" or cmd == "main") and not curBlock then
				local trig = (cmd == "main") and "main" or (cmd .. ":" .. tostring(w[2] or ""):upper())
				curBlock = {trig = trig, body = {}}
				blocks[#blocks + 1] = curBlock
				cur = curBlock.body
			elseif cmd == "repeat" or cmd == "loop" then
				local st = {op = "repeat", n = math.clamp(tonumber(w[2]) or 1, 1, 500), body = {}}
				cur[#cur + 1] = st
				stack[#stack + 1] = cur
				cur = st.body
			elseif cmd == "end" then
				if #stack > 0 then cur = table.remove(stack)
				elseif curBlock then curBlock = nil; cur = main.body end
			else
				cur[#cur + 1] = {op = cmd, a = w[2], b = w[3], rest = table.concat(w, " ", 2)}
			end
		end
	end
	if #main.body > 0 then table.insert(blocks, 1, main) end
	local n = 0
	local function count(b) for _, s in ipairs(b) do n = n + (1); if s.body then count(s.body) end end end
	for _, b in ipairs(blocks) do count(b.body) end
	return blocks, n
end

local function runBody(body, tok)
	for _, s in ipairs(body) do
		if tok.cancel then return end
		local op = s.op
		if op == "press" or op == "tap" then Hooks.tap(normKey(s.a))
		elseif op == "hold" then Hooks.tap(normKey(s.a), tonumber(s.b) or 0.3)
		elseif op == "down" then local kc = Enum.KeyCode[normKey(s.a)]; if kc then Lock.synth = true; VIM:SendKeyEvent(true, kc, false, game) end
		elseif op == "up" then local kc = Enum.KeyCode[normKey(s.a)]; if kc then VIM:SendKeyEvent(false, kc, false, game); task.delay(0.15, function() Lock.synth = false end) end
		elseif op == "wait" or op == "delay" or op == "sleep" then task.wait(math.clamp(tonumber(s.a) or 0.1, 0, 30))
		elseif op == "equip" then
			local a = tostring(s.a or ""):lower()
			if a == "name" then Hooks.equipName(tostring(s.b or ""))
			elseif TIPS[a] then Hooks.equipTip(TIPS[a]) else Hooks.equipName(a) end
			task.wait(0.05)
		elseif op == "slot" then Hooks.tap(normKey(s.a))
		elseif op == "aim" then local r = Aim.pick(); if r then Aim.begin(r, 3) end
		elseif op == "aimstop" then Aim.stop()
		elseif op == "log" then warn("[AHK macro] " .. s.rest)
		elseif op == "repeat" then
			for _ = 1, s.n do
				if tok.cancel then return end
				runBody(s.body, tok)
				task.wait()
			end
		end
	end
end

local MStatus
local function runBlock(b)
	if Macro.running then return end
	Macro.running = true
	local tok = {cancel = false}
	Macro.tok = tok
	task.spawn(function()
		local ok, err = pcall(runBody, b.body, tok)
		Aim.stop()
		Macro.running = false
		Lock.quietUntil = os.clock() + 0.6
		if MStatus then MStatus.Text = ok and ("Rodou: " .. b.trig) or ("Erro: " .. tostring(err)) end
	end)
end
local function macroReload(force)
	local txt = FS.read(MFILE)
	if not txt then
		FS.write(MFILE, MTEMPLATE); txt = MTEMPLATE
	end
	if txt == Macro.last and not force then return end
	Macro.last = txt
	local blocks, n = parseMacro(txt)
	Macro.blocks = blocks
	if n > 0 then FS.write(MSAVED, txt) end
	if MStatus then
		MStatus.Text = (n == 0) and "Arquivo sem comandos ainda (so comentarios)" or ("Detectado e salvo: " .. n .. " comandos, " .. #blocks .. " bloco(s)")
	end
end
for _, ev in ipairs({"F", "Soru"}) do
	Bus.on(ev, function()
		if not Macro.On then return end
		for _, b in ipairs(Macro.blocks) do if b.trig == "on:" .. ev:upper() then runBlock(b); return end end
	end)
end
on(UIS.InputBegan, function(i, gp)
	if gp or not Macro.On or i.UserInputType ~= Enum.UserInputType.Keyboard then return end
	local t = "key:" .. i.KeyCode.Name:upper()
	for _, b in ipairs(Macro.blocks) do if b.trig == t then runBlock(b); return end end
end)
task.spawn(function()
	while Alive do
		task.wait(1)
		if Macro.On then pcall(macroReload) end
	end
end)

Safe("Macro", function()
	local P = U.addTab("Macro")
	local c1 = U.section(P.L, "Arquivo hotkey.txt")
	U.switch(c1, "Macro ativa", false, function(v)
		Macro.On = v
		if v then macroReload(true) end
	end, "macro_on")
	U.buttons(c1, {
		{"Criar arquivo", function()
			if not FS.exists(MFILE) then FS.write(MFILE, MTEMPLATE) end
			if MStatus then MStatus.Text = "Arquivo hotkey.txt pronto na pasta do executor" end
		end},
		{"Recarregar", function() macroReload(true) end},
	})
	U.buttons(c1, {
		{"Rodar main", function()
			macroReload(true)
			for _, b in ipairs(Macro.blocks) do if b.trig == "main" then runBlock(b); return end end
			if MStatus then MStatus.Text = "Sem bloco main" end
		end, color = C.acc},
		{"Parar", function() if Macro.tok then Macro.tok.cancel = true end; Aim.stop() end},
	})
	MStatus = U.note(c1, "Ative e edite o arquivo: o script detecta mudancas sozinho.", C.sub, 30)
	local c2 = U.section(P.R, "Comandos")
	U.note(c2, "press Z | hold Z 0.4 | wait 0.2\nequip sword|melee|fruit|gun\nequip name sanguine | slot One\naim | aimstop | repeat 3 ... end\nGatilhos: on Soru | on F | key Q | main\nBloco termina com end.", C.sub, 92)
	U.switch(c2, "Botao RODAR flutuante", false, function(v)
		if Macro.btn then Macro.btn:Destroy(); Macro.btn = nil end
		if v then
			Macro.btn = new("TextButton", {Size = UDim2.fromOffset(52, 32), Position = UDim2.fromScale(0.85, 0.55), BackgroundColor3 = C.bg,
				Text = "MACRO", TextColor3 = C.text, Font = Enum.Font.GothamBold, TextSize = 10, AutoButtonColor = false, ZIndex = 46}, Gui)
			round(Macro.btn, 8)
			new("UIStroke", {Color = C.acc, Thickness = 1.5}, Macro.btn)
			makeDrag(Macro.btn, function()
				macroReload(true)
				for _, b in ipairs(Macro.blocks) do if b.trig == "main" then runBlock(b); return end end
			end)
		end
	end)
	onKill(function() if Macro.btn then Macro.btn:Destroy() end; if Macro.tok then Macro.tok.cancel = true end end)
end)

-- ==========================================================
-- ABA CLITCH (movimento local do proprio personagem)
-- ==========================================================
U.category("Personagem")
Safe("Clitch", function()
	local P = U.addTab("Clitch")
	local Cl = {holdOn = false, holdKey = "Z", holdMin = 0.5, force = 60, dur = 0.25, dir = "Camera", animOn = false, animFilter = "",
		dashMode = "Desligado", dashForce = 90, dashDur = 0.18, dashCd = 1.5, dashDir = "Movimento", lastDash = 0, btn = nil}

	local function dirVec(kind)
		local ch = LocalPlayer.Character
		local hrp = ch and ch:FindFirstChild("HumanoidRootPart")
		local hum = ch and ch:FindFirstChildOfClass("Humanoid")
		local cam = workspace.CurrentCamera
		if not hrp then return nil end
		local function flat(v) v = Vector3.new(v.X, 0, v.Z); return v.Magnitude > 0.01 and v.Unit or nil end
		if kind == "Movimento" then
			local md = hum and flat(hum.MoveDirection)
			return md or flat(hrp.CFrame.LookVector)
		elseif kind == "Camera" then return cam and flat(cam.CFrame.LookVector)
		elseif kind == "Frente" then return flat(hrp.CFrame.LookVector)
		elseif kind == "Tras" then local v = flat(hrp.CFrame.LookVector); return v and -v
		elseif kind == "Esquerda" then return flat(-hrp.CFrame.RightVector)
		elseif kind == "Direita" then return flat(hrp.CFrame.RightVector)
		elseif kind == "Cima" then return Vector3.new(0, 1, 0) end
	end
	local DIRS = {"Movimento", "Camera", "Frente", "Tras", "Esquerda", "Direita", "Cima"}

	local function impulse(kind, force, dur)
		local ch = LocalPlayer.Character
		local hrp = ch and ch:FindFirstChild("HumanoidRootPart")
		local d = dirVec(kind)
		if not hrp or not d then return end
		Sys.ignoreJump = os.clock() + dur + 0.4
		local att = new("Attachment", {}, hrp)
		local lv = new("LinearVelocity", {Attachment0 = att, MaxForce = 1e7, RelativeTo = Enum.ActuatorRelativeTo.World,
			VectorVelocity = d * force}, hrp)
		task.spawn(function()
			local t0 = os.clock()
			while Alive and lv.Parent and os.clock() - t0 < dur do
				local a = 1 - (os.clock() - t0) / dur
				lv.VectorVelocity = d * force * (0.35 + 0.65 * a)
				RunService.Heartbeat:Wait()
			end
			pcall(function() lv:Destroy(); att:Destroy() end)
		end)
	end

	-- (a) impulso apos segurar tecla / animacao
	local downAt = {}
	on(UIS.InputBegan, function(i, gp)
		if i.UserInputType == Enum.UserInputType.Keyboard then downAt[i.KeyCode.Name] = os.clock() end
	end)
	on(UIS.InputEnded, function(i)
		if i.UserInputType ~= Enum.UserInputType.Keyboard then return end
		local t0 = downAt[i.KeyCode.Name]; downAt[i.KeyCode.Name] = nil
		if Cl.holdOn and t0 and i.KeyCode.Name == Cl.holdKey and os.clock() - t0 >= Cl.holdMin then
			impulse(Cl.dir, Cl.force, Cl.dur)
		end
	end)
	local animConn
	local function hookAnimator(ch)
		if animConn then animConn:Disconnect(); animConn = nil end
		local hum = ch:WaitForChild("Humanoid", 5)
		local an = hum and (hum:FindFirstChildOfClass("Animator") or hum:WaitForChild("Animator", 3))
		if not an then return end
		animConn = an.AnimationPlayed:Connect(function(track)
			if not Cl.animOn then return end
			local f = Cl.animFilter:lower()
			local nm = (track.Name .. " " .. tostring(track.Animation and track.Animation.AnimationId)):lower()
			if f ~= "" and not nm:find(f, 1, true) then return end
			task.delay(Cl.holdMin, function()
				if Cl.animOn and track.IsPlaying then impulse(Cl.dir, Cl.force, Cl.dur) end
			end)
		end)
	end
	if LocalPlayer.Character then task.spawn(hookAnimator, LocalPlayer.Character) end
	on(LocalPlayer.CharacterAdded, function(ch) task.spawn(hookAnimator, ch) end)
	onKill(function() if animConn then animConn:Disconnect() end end)

	local c1 = U.section(P.L, "Impulso apos segurar")
	U.switch(c1, "Por tecla", false, function(v) Cl.holdOn = v end, "cl_hold")
	U.dropdown(c1, "Tecla", {"Z", "X", "C", "V", "F"}, "Z", function(v) Cl.holdKey = v end, "cl_key")
	U.switch(c1, "Por animacao", false, function(v) Cl.animOn = v end, "cl_anim")
	U.textbox(c1, "Filtro animacao", "", function(v) Cl.animFilter = v end, "cl_animf", "nome/id")
	U.slider(c1, "Tempo min. (s)", 0.1, 3, 0.5, 0.05, function(v) Cl.holdMin = v end, "cl_min")
	U.dropdown(c1, "Direcao", DIRS, "Camera", function(v) Cl.dir = v end, "cl_dir")
	U.slider(c1, "Forca", 10, 200, 60, 5, function(v) Cl.force = v end, "cl_force")
	U.slider(c1, "Duracao (s)", 0.05, 1, 0.25, 0.05, function(v) Cl.dur = v end, "cl_dur")

	-- (b) dash
	local function doDash()
		local now = os.clock()
		if now - Cl.lastDash < Cl.dashCd then return end
		Cl.lastDash = now
		impulse(Cl.dashDir, Cl.dashForce, Cl.dashDur)
	end
	local c2 = U.section(P.R, "Dash")
	local function setBtn(on)
		if Cl.btn then Cl.btn:Destroy(); Cl.btn = nil end
		if not on then return end
		Cl.btn = new("TextButton", {Size = UDim2.fromOffset(52, 52), Position = UDim2.fromScale(0.8, 0.6), BackgroundColor3 = C.bg, Text = "DASH",
			TextColor3 = C.text, Font = Enum.Font.GothamBold, TextSize = 11, AutoButtonColor = false, ZIndex = 47}, Gui)
		round(Cl.btn, 26)
		new("UIStroke", {Color = C.acc, Thickness = 2}, Cl.btn)
		makeDrag(Cl.btn, doDash)
	end
	U.dropdown(c2, "Modo", {"Desligado", "Manual", "Automatico"}, "Desligado", function(v)
		Cl.dashMode = v; setBtn(v == "Manual")
	end, "cl_dmode")
	U.dropdown(c2, "Direcao", DIRS, "Movimento", function(v) Cl.dashDir = v end, "cl_ddir")
	U.slider(c2, "Impulso/veloc.", 20, 250, 90, 5, function(v) Cl.dashForce = v end, "cl_dforce")
	U.slider(c2, "Duracao (s)", 0.05, 0.6, 0.18, 0.01, function(v) Cl.dashDur = v end, "cl_ddur")
	U.slider(c2, "Cooldown (s)", 0.2, 6, 1.5, 0.1, function(v) Cl.dashCd = v end, "cl_dcd")
	task.spawn(function()
		while Alive do
			task.wait(0.1)
			local left = Cl.dashCd - (os.clock() - Cl.lastDash)
			if Cl.btn then Cl.btn.Text = left > 0 and string.format("%.1f", left) or "DASH" end
			if Cl.dashMode == "Automatico" and left <= 0 then
				local hum = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
				if hum and hum.MoveDirection.Magnitude > 0.1 then doDash() end
			end
		end
	end)
	onKill(function() if Cl.btn then Cl.btn:Destroy() end end)

	-- (c) escala com restauracao
	local Sc = {orig = nil, on = false, f = 1}
	local function storeOrig(ch)
		local o = {parts = {}, joints = {}, atts = {}, meshes = {}}
		for _, d in ipairs(ch:GetDescendants()) do
			if d:IsA("BasePart") then o.parts[d] = d.Size
			elseif d:IsA("Motor6D") or d:IsA("Weld") then o.joints[d] = {d.C0, d.C1}
			elseif d:IsA("Attachment") then o.atts[d] = d.CFrame
			elseif d:IsA("SpecialMesh") then o.meshes[d] = d.Scale end
		end
		local hum = ch:FindFirstChildOfClass("Humanoid")
		o.hip = hum and hum.HipHeight
		o.hum = hum
		return o
	end
	local function scaleCF(cf, f) return CFrame.new(cf.Position * f) * (cf - cf.Position) end
	local function applyScale(f)
		local ch = LocalPlayer.Character
		if not ch then return end
		if not Sc.orig then Sc.orig = storeOrig(ch) end
		local o = Sc.orig
		for p, s in pairs(o.parts) do if p.Parent then pcall(function() p.Size = Vector3.new(math.max(s.X * f, 0.05), math.max(s.Y * f, 0.05), math.max(s.Z * f, 0.05)) end) end end
		for j, c in pairs(o.joints) do if j.Parent then pcall(function() j.C0 = scaleCF(c[1], f); j.C1 = scaleCF(c[2], f) end) end end
		for a, cf in pairs(o.atts) do if a.Parent then pcall(function() a.CFrame = scaleCF(cf, f) end) end end
		for m, s in pairs(o.meshes) do if m.Parent then pcall(function() m.Scale = s * f end) end end
		if o.hum and o.hip then pcall(function() o.hum.HipHeight = o.hip * f end) end
	end
	local function restoreScale()
		local o = Sc.orig
		if not o then return end
		for p, s in pairs(o.parts) do if p.Parent then pcall(function() p.Size = s end) end end
		for j, c in pairs(o.joints) do if j.Parent then pcall(function() j.C0 = c[1]; j.C1 = c[2] end) end end
		for a, cf in pairs(o.atts) do if a.Parent then pcall(function() a.CFrame = cf end) end end
		for m, s in pairs(o.meshes) do if m.Parent then pcall(function() m.Scale = s end) end end
		if o.hum and o.hip then pcall(function() o.hum.HipHeight = o.hip end) end
		Sc.orig = nil
	end
	local PRE = {Mini = 0.5, Pequeno = 0.75, Normal = 1, Grande = 1.5, Gigante = 2.2}
	local c3 = U.section(P.L, "Escala do personagem")
	local slider
	U.switch(c3, "Ativar escala", false, function(v)
		Sc.on = v
		if v then applyScale(Sc.f) else restoreScale() end
	end, "cl_scale_on")
	U.dropdown(c3, "Preset", {"Mini", "Pequeno", "Normal", "Grande", "Gigante"}, "Normal", function(v)
		Sc.f = PRE[v]; if slider then slider.set(Sc.f, true) end
		if Sc.on then applyScale(Sc.f) end
	end, "cl_preset")
	slider = U.slider(c3, "Escala", 0.3, 3, 1, 0.05, function(v) Sc.f = v; if Sc.on then applyScale(v) end end, "cl_scale")
	U.note(c3, "Guarda partes, acessorios e juntas originais; desligar restaura tudo. Efeito so local.", C.sub, 30)
	on(LocalPlayer.CharacterAdded, function() Sc.orig = nil; if Sc.on then task.wait(1); applyScale(Sc.f) end end)
	onKill(function() restoreScale() end)
end)

-- ==========================================================
-- ABAS SISTEMA: FONTES e MODS
-- ==========================================================
U.category("Sistema")
Safe("Fontes", function()
	local P = U.addTab("Fontes")
	local FFILE = "fontes.txt"
	local FTEMPLATE = "# Uma fonte por linha. Nome do Enum.Font (Arcade, Bangers, Fantasy...) ou familia (Montserrat, BuilderSans)\n# ou rbxasset://fonts/families/Nome.json\nArcade\nFantasy\nBangers\nSciFi\nCreepster\nMontserrat\n"
	local Fn = {list = {}, sel = nil, orig = {}, active = false, conn = nil}
	local function reload()
		local txt = FS.read(FFILE)
		if not txt then FS.write(FFILE, FTEMPLATE); txt = FTEMPLATE end
		Fn.list = {}
		for line in txt:gmatch("[^\r\n]+") do
			line = line:match("^%s*(.-)%s*$")
			if line ~= "" and line:sub(1, 1) ~= "#" then Fn.list[#Fn.list + 1] = line end
		end
		if not Fn.sel and Fn.list[1] then Fn.sel = Fn.list[1] end
	end
	reload()
	local function resolve(name)
		local ok, f = pcall(function() return Enum.Font[name] end)
		if ok and f then return {enum = f} end
		local o3, ff = pcall(function()
			if name:find("rbxasset") then return Font.new(name) end
			return Font.fromName(name)
		end)
		if o3 and ff then return {face = ff} end
	end
	local function isText(d) return d:IsA("TextLabel") or d:IsA("TextButton") or d:IsA("TextBox") end
	local function applyTo(d, face)
		if not isText(d) or d:IsDescendantOf(Gui) then return end
		if not Fn.orig[d] then Fn.orig[d] = {d.Font, d.FontFace} end
		pcall(function()
			if face.enum then d.Font = face.enum else d.FontFace = face.face end
		end)
	end
	local function applyAll()
		local face = Fn.sel and resolve(Fn.sel)
		if not face then return false end
		Fn.active = true
		task.spawn(function()
			local n = 0
			for _, d in ipairs(PlayerGui:GetDescendants()) do
				applyTo(d, face); n = n + 1
				if n % 200 == 0 then task.wait() end
			end
		end)
		if Fn.conn then Fn.conn:Disconnect() end
		Fn.conn = PlayerGui.DescendantAdded:Connect(function(d) if Fn.active then task.defer(applyTo, d, face) end end)
		return true
	end
	local function restore()
		Fn.active = false
		if Fn.conn then Fn.conn:Disconnect(); Fn.conn = nil end
		for d, f in pairs(Fn.orig) do if d.Parent then pcall(function() d.Font = f[1]; d.FontFace = f[2] end) end end
		table.clear(Fn.orig)
	end
	onKill(restore)
	local c1 = U.section(P.L, "Selecionar fontes")
	local note
	local dd = U.dropdown(c1, "Selecionar fonte", function() reload(); return Fn.list end, Fn.sel, function(v)
		Fn.sel = v
		if Fn.active then restore(); applyAll() end
	end, "font_sel")
	U.switch(c1, "Aplicar no jogo", false, function(v)
		if v then
			if not applyAll() then note.Text = "Fonte invalida: " .. tostring(Fn.sel) end
		else restore() end
	end)
	U.buttons(c1, {
		{"Recarregar lista", function() reload(); note.Text = #Fn.list .. " fontes no arquivo" end},
		{"Restaurar", function() restore(); note.Text = "Fontes originais" end},
	})
	local c2 = U.section(P.R, "Arquivo")
	note = U.note(c2, "Edite fontes.txt (uma fonte por linha) e toque em Recarregar. Elas aparecem em Selecionar fonte.", C.sub, 44)
	U.buttons(c2, {{"Criar fontes.txt", function()
		if not FS.exists(FFILE) then FS.write(FFILE, FTEMPLATE) end
		reload(); note.Text = "fontes.txt pronto (" .. #Fn.list .. " fontes)"
	end}})
end)


-- ==========================================================
-- ABA FLEASION (troca local de assets por ID)
-- ==========================================================
Safe("Fleasion", function()
	local P = U.addTab("Fleasion")
	local FL_FILE = "fleasion.txt"
	local Fl = {map = {}, count = 0, orig = {}, active = false, auto = true, conn = nil, changed = 0}
	local PROPS = {
		Decal = {"Texture"}, Texture = {"Texture"}, MeshPart = {"MeshId", "TextureID"},
		SpecialMesh = {"MeshId", "TextureId"}, Sound = {"SoundId"}, ImageLabel = {"Image"}, ImageButton = {"Image"},
		Shirt = {"ShirtTemplate"}, Pants = {"PantsTemplate"}, ShirtGraphic = {"Graphic"}, ParticleEmitter = {"Texture"},
		Beam = {"Texture"}, Trail = {"Texture"}, SurfaceAppearance = {"ColorMap", "NormalMap", "MetalnessMap", "RoughnessMap"},
		Sky = {"SkyboxBk", "SkyboxDn", "SkyboxFt", "SkyboxLf", "SkyboxRt", "SkyboxUp"},
	}
	local function idOf(s) return tostring(s):match("%d%d%d%d+") end
	local function parse(text)
		local map, n = {}, 0
		local function put(a, b)
			local ida = idOf(a)
			if not ida then return end
			local nb
			if tostring(b):find("rbxasset", 1, true) and not idOf(b) then nb = tostring(b):match("^%s*(.-)%s*$")
			else
				local idb = idOf(b)
				if idb then nb = "rbxassetid://" .. idb end
			end
			if nb then if not map[ida] then n = n + 1 end; map[ida] = nb end
		end
		for line in text:gmatch("[^\r\n]+") do
			line = line:gsub("#.*$", "")
			local a, b = line:match("^(.-)%s*%->%s*(.+)$")
			if not a then a, b = line:match("^(.-)%s*=%s*(.+)$") end
			if not a then a, b = line:match("^(%S+)%s+(%S+)$") end
			if not a then a, b = line:match("^([^,]+),%s*(.+)$") end
			if a and b then put(a, b) end
		end
		return map, n
	end
	local function applyTo(inst)
		local props = PROPS[inst.ClassName]
		if not props then return end
		for _, p in ipairs(props) do
			local ok, cur = pcall(function() return inst[p] end)
			if ok and type(cur) == "string" and cur ~= "" then
				local id = idOf(cur)
				local new_ = id and Fl.map[id]
				if new_ and cur ~= new_ then
					Fl.orig[inst] = Fl.orig[inst] or {}
					if Fl.orig[inst][p] == nil then Fl.orig[inst][p] = cur end
					if pcall(function() inst[p] = new_ end) then Fl.changed = Fl.changed + 1 end
				end
			end
		end
	end
	local roots = {workspace, Lighting, PlayerGui, game:GetService("SoundService")}
	local function scanAll()
		Fl.changed = 0
		for _, r in ipairs(roots) do
			local n = 0
			for _, d in ipairs(r:GetDescendants()) do
				if not d:IsDescendantOf(Gui) then applyTo(d) end
				n = n + 1
				if n % 300 == 0 then task.wait() end
			end
		end
	end
	local note
	local function stop()
		Fl.active = false
		if Fl.conn then Fl.conn:Disconnect(); Fl.conn = nil end
		for inst, props in pairs(Fl.orig) do
			if inst.Parent then for p, v in pairs(props) do pcall(function() inst[p] = v end) end end
		end
		table.clear(Fl.orig)
	end
	local function start(text)
		local map, n = parse(text)
		if n == 0 then note.Text = "Nenhum codigo valido (use ID_ANTIGO=ID_NOVO)"; return end
		stop()
		Fl.map, Fl.count, Fl.active = map, n, true
		note.Text = n .. " codigos. Aplicando..."
		task.spawn(function()
			scanAll()
			note.Text = n .. " codigos | " .. Fl.changed .. " itens trocados"
		end)
		Fl.conn = game.DescendantAdded:Connect(function(d)
			if Fl.active and Fl.auto then task.defer(function() if d.Parent and not d:IsDescendantOf(Gui) then applyTo(d) end end) end
		end)
	end
	onKill(stop)

	local c1 = U.section(P.L, "Codigos Fleasion")
	local boxRow = customRow(c1, 150)
	local sc = new("ScrollingFrame", {Size = UDim2.new(1, 0, 1, -4), Position = UDim2.fromOffset(0, 2), BackgroundColor3 = C.pill,
		BorderSizePixel = 0, ScrollBarThickness = 3, CanvasSize = UDim2.new(), AutomaticCanvasSize = Enum.AutomaticSize.Y, ZIndex = 6}, boxRow)
	round(sc, 6)
	local box = new("TextBox", {Size = UDim2.new(1, -8, 0, 140), Position = UDim2.fromOffset(4, 2), AutomaticSize = Enum.AutomaticSize.Y,
		BackgroundTransparency = 1, Text = FS.read(FL_FILE) or "", PlaceholderText = "ID_ANTIGO=ID_NOVO (um por linha)\n123456789=987654321",
		PlaceholderColor3 = C.sub, TextColor3 = C.text, Font = Enum.Font.Code, TextSize = 10, TextXAlignment = Enum.TextXAlignment.Left,
		TextYAlignment = Enum.TextYAlignment.Top, MultiLine = true, ClearTextOnFocus = false, TextWrapped = true, ZIndex = 7}, sc)
	U.buttons(c1, {
		{"Aplicar", function() FS.write(FL_FILE, box.Text); start(box.Text) end, color = C.acc},
		{"Restaurar", function() stop(); note.Text = "Assets originais restaurados" end},
	})
	local c2 = U.section(P.R, "Opcoes")
	U.switch(c2, "Aplicar em objetos novos", true, function(v) Fl.auto = v end, "fl_auto")
	U.buttons(c2, {
		{"Salvar arquivo", function() FS.write(FL_FILE, box.Text); note.Text = "Salvo em fleasion.txt" end},
		{"Carregar arquivo", function()
			local t = FS.read(FL_FILE)
			if t then box.Text = t; note.Text = "Carregado de fleasion.txt" else note.Text = "fleasion.txt nao existe" end
		end},
	})
	note = U.note(c2, "Troca local de assets (texturas, meshes, sons, imagens) por ID. Formatos: 123=456 | 123 -> 456 | rbxassetid://123=rbxassetid://456", C.sub, 56)
end)

Safe("Mods", function()
	local P = U.addTab("Mods")
	local c = U.section(P.L, "Visual")
	local GS = {skies = {}, mine = nil}
	U.switch(c, "Gray Sky", false, function(on2)
		if on2 then
			for _, ch in ipairs(Lighting:GetChildren()) do
				if ch:IsA("Sky") or ch:IsA("Atmosphere") then table.insert(GS.skies, ch); ch.Parent = nil end
			end
			local a = Instance.new("Atmosphere")
			a.Color, a.Decay = Color3.fromRGB(150, 150, 155), Color3.fromRGB(150, 150, 155)
			a.Density, a.Offset, a.Glare, a.Haze = 0.3, 1, 0, 0
			a.Parent = Lighting; GS.mine = a
		else
			if GS.mine then GS.mine:Destroy(); GS.mine = nil end
			for _, ch in ipairs(GS.skies) do ch.Parent = Lighting end
			table.clear(GS.skies)
		end
	end, "mod_gray")
	local fpsLbl, fpsConn
	U.switch(c, "Display FPS", false, function(v)
		if fpsConn then fpsConn:Disconnect(); fpsConn = nil end
		if fpsLbl then fpsLbl:Destroy(); fpsLbl = nil end
		if not v then return end
		fpsLbl = new("TextLabel", {Size = UDim2.fromOffset(150, 20), Position = UDim2.new(1, -160, 0, 6), BackgroundColor3 = Color3.new(0, 0, 0),
			BackgroundTransparency = 0.4, TextColor3 = Color3.new(1, 1, 1), Font = Enum.Font.GothamBold, TextSize = 11, Text = "FPS: --", ZIndex = 60}, Gui)
		round(fpsLbl, 6)
		local frames, t0 = 0, os.clock()
		fpsConn = RunService.RenderStepped:Connect(function()
			frames = frames + (1)
			local dt = os.clock() - t0
			if dt >= 0.5 then fpsLbl.Text = ("FPS: %d  Ping: %dms"):format(math.floor(frames / dt), math.floor(getPing())); frames, t0 = 0, os.clock() end
		end)
	end, "mod_fps")
	onKill(function() if fpsConn then fpsConn:Disconnect() end; if fpsLbl then fpsLbl:Destroy() end end)
	local AL
	U.switch(c, "Anti-Lag", false, function(v)
		pcall(function()
			local r = settings().Rendering
			if v then
				AL = {q = r.QualityLevel, sh = Lighting.GlobalShadows, deco = workspace.Terrain.Decoration}
				r.QualityLevel = Enum.QualityLevel.Level01; Lighting.GlobalShadows = false; workspace.Terrain.Decoration = false
			elseif AL then
				r.QualityLevel = AL.q; Lighting.GlobalShadows = AL.sh; workspace.Terrain.Decoration = AL.deco; AL = nil
			end
		end)
	end, "mod_lag")
	local Oof = {on = false, orig = {}}
	local function oofApply(ch)
		task.spawn(function()
			local head = ch:WaitForChild("Head", 5)
			local d = head and head:WaitForChild("Died", 5)
			if d and Oof.on then Oof.orig[d] = Oof.orig[d] or d.SoundId; d.SoundId = "rbxasset://sounds/uuhhh.mp3" end
		end)
	end
	on(LocalPlayer.CharacterAdded, oofApply)
	U.switch(c, "Old Oof Sound", false, function(v)
		Oof.on = v
		if v then if LocalPlayer.Character then oofApply(LocalPlayer.Character) end
		else for d, id in pairs(Oof.orig) do if d.Parent then d.SoundId = id end end; table.clear(Oof.orig) end
	end, "mod_oof")
	local c2 = U.section(P.R, "Camera")
	U.slider(c2, "Sensibilidade", 1, 7, 4, 1, function(v)
		pcall(function() UserSettings():GetService("Us