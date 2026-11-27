-- ============================================================================
-- 8. INTERFACE VISUAL COMPACTA + BOTAO UNICO (ESCONDE TUDO + JANELAS)
-- ============================================================================
local UI = {}
UI.Profiles = { Default = {} }
UI.CurrentProfile = "Default"
UI.ControlsRegistry = {}
UI.OpenPopups = {}

local function closeAllPopups()
    for _, pop in ipairs(UI.OpenPopups) do
        pcall(function()
            if pop and pop.Parent then
                pop.Visible = false
            end
        end)
    end
end

local function loadProfiles()
    pcall(function()
        if isfile and readfile and isfile(PROFILES_FILE) then
            local decoded = HttpService:JSONDecode(readfile(PROFILES_FILE))
            if type(decoded) == "table" then
                UI.Profiles = decoded
            end
        end
    end)
end
loadProfiles()

local function saveProfiles()
    pcall(function()
        if writefile then
            writefile(PROFILES_FILE, HttpService:JSONEncode(UI.Profiles))
        end
    end)
end

local function createGUI()
    for _, g in ipairs(game:GetService("CoreGui"):GetChildren()) do
        if g.Name == "UnifiedSuiteUI" then g:Destroy() end
    end
    UI.OpenPopups = {}

    local sg = Instance.new("ScreenGui")
    sg.Name = "UnifiedSuiteUI"
    sg.ResetOnSpawn = false
    sg.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    sg.Parent = game:GetService("CoreGui")

    -- Botao flutuante unico que guarda toda a interface e janelas abertas
    local toggleBtn = Instance.new("TextButton")
    toggleBtn.Name = "SuiteToggleBtn"
    toggleBtn.Size = UDim2.new(0, 78, 0, 30)
    toggleBtn.Position = UDim2.new(0.02, 0, 0.14, 0)
    toggleBtn.BackgroundColor3 = Color3.fromRGB(48, 86, 175)
    toggleBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    toggleBtn.Font = Enum.Font.GothamBold
    toggleBtn.TextSize = 11
    toggleBtn.Text = "MENU"
    toggleBtn.Active = true
    toggleBtn.Draggable = true
    toggleBtn.ZIndex = 50
    toggleBtn.Parent = sg
    Instance.new("UICorner", toggleBtn).CornerRadius = UDim.new(0, 8)

    local main = Instance.new("Frame")
    main.Name = "MainWindow"
    main.Size = UDim2.new(0, 500, 0, 310)
    main.Position = UDim2.new(0.5, -250, 0.5, -155)
    main.BackgroundColor3 = Color3.fromRGB(16, 18, 24)
    main.BorderSizePixel = 0
    main.Visible = false
    main.Active = true
    main.Draggable = true
    main.Parent = sg
    Instance.new("UICorner", main).CornerRadius = UDim.new(0, 9)

    local uiScale = Instance.new("UIScale")
    uiScale.Parent = main

    local function syncScaleToScreen()
        local vp = workspace.CurrentCamera and workspace.CurrentCamera.ViewportSize or Vector2.new(854, 480)
        local sx = (vp.X * 0.90) / 500
        local sy = (vp.Y * 0.86) / 310
        uiScale.Scale = math.clamp(math.min(sx, sy, 1), 0.55, 1)
    end
    syncScaleToScreen()
    if workspace.CurrentCamera then
        workspace.CurrentCamera:GetPropertyChangedSignal("ViewportSize"):Connect(syncScaleToScreen)
    end

    local function setInterfaceVisible(show)
        main.Visible = show
        if not show then
            closeAllPopups()
        end
        toggleBtn.Text = show and "FECHAR" or "MENU"
    end

    toggleBtn.MouseButton1Click:Connect(function()
        setInterfaceVisible(not main.Visible)
    end)

    -- 1. Navegacao Lateral Compacta
    local sidebar = Instance.new("ScrollingFrame")
    sidebar.Size = UDim2.new(0, 128, 1, -8)
    sidebar.Position = UDim2.new(0, 4, 0, 4)
    sidebar.BackgroundColor3 = Color3.fromRGB(21, 24, 32)
    sidebar.BorderSizePixel = 0
    sidebar.ScrollBarThickness = 2
    sidebar.CanvasSize = UDim2.new(0, 0, 0, 520)
    sidebar.Parent = main
    Instance.new("UICorner", sidebar).CornerRadius = UDim.new(0, 8)

    local sideLayout = Instance.new("UIListLayout")
    sideLayout.Padding = UDim.new(0, 3)
    sideLayout.Parent = sidebar

    local sidePad = Instance.new("UIPadding")
    sidePad.PaddingTop = UDim.new(0, 6)
    sidePad.PaddingLeft = UDim.new(0, 6)
    sidePad.PaddingRight = UDim.new(0, 6)
    sidePad.Parent = sidebar

    local contentArea = Instance.new("Frame")
    contentArea.Size = UDim2.new(1, -138, 1, -8)
    contentArea.Position = UDim2.new(0, 135, 0, 4)
    contentArea.BackgroundTransparency = 1
    contentArea.Parent = main

    -- 2. Barra Superior Compacta
    local topBar = Instance.new("Frame")
    topBar.Size = UDim2.new(1, 0, 0, 28)
    topBar.BackgroundColor3 = Color3.fromRGB(22, 26, 35)
    topBar.BorderSizePixel = 0
    topBar.Parent = contentArea
    Instance.new("UICorner", topBar).CornerRadius = UDim.new(0, 7)

    local profileBtn = Instance.new("TextButton")
    profileBtn.Size = UDim2.new(0, 112, 0, 20)
    profileBtn.Position = UDim2.new(0, 6, 0.5, -10)
    profileBtn.BackgroundColor3 = Color3.fromRGB(30, 35, 48)
    profileBtn.TextColor3 = Color3.fromRGB(235, 240, 250)
    profileBtn.Font = Enum.Font.GothamSemibold
    profileBtn.TextSize = 10
    profileBtn.Text = "Perfil: " .. UI.CurrentProfile .. " v"
    profileBtn.Parent = topBar
    Instance.new("UICorner", profileBtn).CornerRadius = UDim.new(0, 5)

    local editProfileBtn = Instance.new("TextButton")
    editProfileBtn.Size = UDim2.new(0, 20, 0, 20)
    editProfileBtn.Position = UDim2.new(0, 122, 0.5, -10)
    editProfileBtn.BackgroundColor3 = Color3.fromRGB(36, 42, 58)
    editProfileBtn.TextColor3 = Color3.fromRGB(160, 195, 255)
    editProfileBtn.Font = Enum.Font.GothamBold
    editProfileBtn.TextSize = 10
    editProfileBtn.Text = "✎"
    editProfileBtn.Parent = topBar
    Instance.new("UICorner", editProfileBtn).CornerRadius = UDim.new(0, 5)

    local searchBox = Instance.new("TextBox")
    searchBox.Size = UDim2.new(0, 130, 0, 20)
    searchBox.Position = UDim2.new(1, -136, 0.5, -10)
    searchBox.BackgroundColor3 = Color3.fromRGB(29, 34, 46)
    searchBox.TextColor3 = Color3.fromRGB(240, 244, 255)
    searchBox.PlaceholderText = "Buscar..."
    searchBox.PlaceholderColor3 = Color3.fromRGB(130, 140, 160)
    searchBox.Font = Enum.Font.Gotham
    searchBox.TextSize = 10
    searchBox.Text = ""
    searchBox.ClearTextOnFocus = false
    searchBox.Parent = topBar
    Instance.new("UICorner", searchBox).CornerRadius = UDim.new(0, 5)

    local profileMenu = Instance.new("Frame")
    profileMenu.Size = UDim2.new(0, 136, 0, 88)
    profileMenu.Position = UDim2.new(0, 6, 0, 30)
    profileMenu.BackgroundColor3 = Color3.fromRGB(26, 30, 41)
    profileMenu.Visible = false
    profileMenu.ZIndex = 25
    profileMenu.Parent = contentArea
    Instance.new("UICorner", profileMenu).CornerRadius = UDim.new(0, 6)
    UI.OpenPopups[#UI.OpenPopups + 1] = profileMenu

    local pmList = Instance.new("UIListLayout")
    pmList.Padding = UDim.new(0, 2)
    pmList.Parent = profileMenu

    local function rebuildProfileMenu()
        for _, ch in ipairs(profileMenu:GetChildren()) do
            if ch:IsA("TextButton") then ch:Destroy() end
        end
        for pName in pairs(UI.Profiles) do
            local b = Instance.new("TextButton")
            b.Size = UDim2.new(1, -4, 0, 20)
            b.BackgroundColor3 = Color3.fromRGB(34, 39, 53)
            b.TextColor3 = Color3.fromRGB(235, 240, 250)
            b.Font = Enum.Font.Gotham
            b.TextSize = 10
            b.Text = pName
            b.ZIndex = 26
            b.Parent = profileMenu
            Instance.new("UICorner", b).CornerRadius = UDim.new(0, 4)
            b.MouseButton1Click:Connect(function()
                UI.CurrentProfile = pName
                profileBtn.Text = "Perfil: " .. pName .. " v"
                profileMenu.Visible = false
                local saved = UI.Profiles[pName] or {}
                for id, setter in pairs(UI.ControlsRegistry) do
                    if saved[id] ~= nil then
                        pcall(setter, saved[id])
                    end
                end
            end)
        end
    end

    profileBtn.MouseButton1Click:Connect(function()
        local nextVis = not profileMenu.Visible
        closeAllPopups()
        rebuildProfileMenu()
        profileMenu.Visible = nextVis
    end)

    editProfileBtn.MouseButton1Click:Connect(function()
        UI.Profiles[UI.CurrentProfile] = UI.Profiles[UI.CurrentProfile] or {}
        saveProfiles()
        editProfileBtn.Text = "✓"
        task.delay(0.8, function() editProfileBtn.Text = "✎" end)
    end)

    local pagesHolder = Instance.new("Frame")
    pagesHolder.Size = UDim2.new(1, 0, 1, -32)
    pagesHolder.Position = UDim2.new(0, 0, 0, 32)
    pagesHolder.BackgroundTransparency = 1
    pagesHolder.Parent = contentArea

    local tabButtons, pages = {}, {}

    local function addCategoryHeader(catTitle)
        local lbl = Instance.new("TextLabel")
        lbl.Size = UDim2.new(1, 0, 0, 14)
        lbl.BackgroundTransparency = 1
        lbl.Text = string.upper(catTitle)
        lbl.TextColor3 = Color3.fromRGB(128, 134, 148)
        lbl.Font = Enum.Font.GothamBold
        lbl.TextSize = 9
        lbl.TextXAlignment = Enum.TextXAlignment.Left
        lbl.Parent = sidebar
    end

    local function selectTab(name)
        closeAllPopups()
        for tName, page in pairs(pages) do page.Visible = (tName == name) end
        for tName, btn in pairs(tabButtons) do
            local isSel = (tName == name)
            btn.BackgroundColor3 = isSel and Color3.fromRGB(48, 86, 175) or Color3.fromRGB(27, 31, 42)
            btn.TextColor3 = isSel and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(185, 192, 208)
        end
    end

    local function createTab(name, icon)
        local btn = Instance.new("TextButton")
        btn.Size = UDim2.new(1, 0, 0, 24)
        btn.BackgroundColor3 = Color3.fromRGB(27, 31, 42)
        btn.TextColor3 = Color3.fromRGB(185, 192, 208)
        btn.Font = Enum.Font.GothamSemibold
        btn.TextSize = 10
        btn.TextXAlignment = Enum.TextXAlignment.Left
        btn.Text = " " .. icon .. " " .. name
        btn.Parent = sidebar
        Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 5)

        local page = Instance.new("Frame")
        page.Size = UDim2.new(1, 0, 1, 0)
        page.BackgroundTransparency = 1
        page.Visible = false
        page.Parent = pagesHolder

        local leftCol = Instance.new("ScrollingFrame")
        leftCol.Size = UDim2.new(0.5, -3, 1, 0)
        leftCol.BackgroundTransparency = 1
        leftCol.ScrollBarThickness = 2
        leftCol.CanvasSize = UDim2.new(0, 0, 0, 480)
        leftCol.Parent = page

        local rightCol = Instance.new("ScrollingFrame")
        rightCol.Size = UDim2.new(0.5, -3, 1, 0)
        rightCol.Position = UDim2.new(0.5, 3, 0, 0)
        rightCol.BackgroundTransparency = 1
        rightCol.ScrollBarThickness = 2
        rightCol.CanvasSize = UDim2.new(0, 0, 0, 480)
        rightCol.Parent = page

        Instance.new("UIListLayout", leftCol).Padding = UDim.new(0, 5)
        Instance.new("UIListLayout", rightCol).Padding = UDim.new(0, 5)

        btn.MouseButton1Click:Connect(function() selectTab(name) end)
        tabButtons[name] = btn
        pages[name] = page
        return leftCol, rightCol
    end

    local function createCard(parentCol, sectionTitle)
        local card = Instance.new("Frame")
        card.Size = UDim2.new(1, 0, 0, 34)
        card.AutomaticSize = Enum.AutomaticSize.Y
        card.BackgroundColor3 = Color3.fromRGB(22, 26, 35)
        card.BorderSizePixel = 0
        card.Parent = parentCol
        Instance.new("UICorner", card).CornerRadius = UDim.new(0, 7)

        Instance.new("UIListLayout", card).Padding = UDim.new(0, 4)
        local pad = Instance.new("UIPadding")
        pad.PaddingTop = UDim.new(0, 6)
        pad.PaddingBottom = UDim.new(0, 6)
        pad.PaddingLeft = UDim.new(0, 7)
        pad.PaddingRight = UDim.new(0, 7)
        pad.Parent = card

        local hdr = Instance.new("TextLabel")
        hdr.Size = UDim2.new(1, 0, 0, 13)
        hdr.BackgroundTransparency = 1
        hdr.Text = sectionTitle
        hdr.TextColor3 = Color3.fromRGB(145, 160, 190)
        hdr.Font = Enum.Font.GothamBold
        hdr.TextSize = 10
        hdr.TextXAlignment = Enum.TextXAlignment.Left
        hdr.Parent = card
        return card
    end

    local function newRow(card, labelText)
        local row = Instance.new("Frame")
        row.Name = labelText
        row.Size = UDim2.new(1, 0, 0, 22)
        row.BackgroundTransparency = 1
        row.Parent = card

        local lbl = Instance.new("TextLabel")
        lbl.Size = UDim2.new(0.55, 0, 1, 0)
        lbl.BackgroundTransparency = 1
        lbl.Text = labelText
        lbl.TextColor3 = Color3.fromRGB(228, 233, 244)
        lbl.Font = Enum.Font.Gotham
        lbl.TextSize = 10
        lbl.TextXAlignment = Enum.TextXAlignment.Left
        lbl.Parent = row
        return row
    end

    local function addSwitch(card, id, text, defaultVal, callback)
        local row = newRow(card, text)
        local pill = Instance.new("TextButton")
        pill.Size = UDim2.new(0, 34, 0, 18)
        pill.Position = UDim2.new(1, -34, 0.5, -9)
        pill.BackgroundColor3 = defaultVal and Color3.fromRGB(66, 133, 244) or Color3.fromRGB(45, 50, 64)
        pill.Text = ""
        pill.Parent = row
        Instance.new("UICorner", pill).CornerRadius = UDim.new(1, 0)

        local knob = Instance.new("Frame")
        knob.Size = UDim2.new(0, 14, 0, 14)
        knob.Position = defaultVal and UDim2.new(1, -16, 0.5, -7) or UDim2.new(0, 2, 0.5, -7)
        knob.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        knob.Parent = pill
        Instance.new("UICorner", knob).CornerRadius = UDim.new(1, 0)

        local state = defaultVal == true
        local function setVal(v)
            state = v == true
            pill.BackgroundColor3 = state and Color3.fromRGB(66, 133, 244) or Color3.fromRGB(45, 50, 64)
            knob:TweenPosition(state and UDim2.new(1, -16, 0.5, -7) or UDim2.new(0, 2, 0.5, -7), Enum.EasingDirection.Out, Enum.EasingStyle.Quad, 0.12, true)
            UI.Profiles[UI.CurrentProfile] = UI.Profiles[UI.CurrentProfile] or {}
            UI.Profiles[UI.CurrentProfile][id] = state
            if callback then pcall(callback, state) end
        end

        pill.MouseButton1Click:Connect(function() setVal(not state) end)
        UI.ControlsRegistry[id] = setVal
        if defaultVal then task.defer(function() pcall(callback, true) end) end
    end

    local function addKeybind(card, id, text, defaultKey, callback)
        local row = newRow(card, text)
        local keyPill = Instance.new("TextButton")
        keyPill.Size = UDim2.new(0, 52, 0, 18)
        keyPill.Position = UDim2.new(1, -52, 0.5, -9)
        keyPill.BackgroundColor3 = Color3.fromRGB(27, 30, 38)
        keyPill.TextColor3 = Color3.fromRGB(220, 228, 245)
        keyPill.Font = Enum.Font.GothamBold
        keyPill.TextSize = 10
        keyPill.Text = defaultKey or "F"
        keyPill.Parent = row
        Instance.new("UICorner", keyPill).CornerRadius = UDim.new(1, 0)

        local listening = false
        keyPill.MouseButton1Click:Connect(function()
            listening = true
            keyPill.Text = "..."
        end)
        UserInputService.InputBegan:Connect(function(inp, gp)
            if not listening or gp then return end
            if inp.UserInputType == Enum.UserInputType.Keyboard then
                listening = false
                keyPill.Text = inp.KeyCode.Name
                if callback then pcall(callback, inp.KeyCode, inp.KeyCode.Name) end
            end
        end)
    end

    local function addSlider(card, id, text, minVal, maxVal, defaultVal, decimals, callback)
        local row = newRow(card, text)
        local box = Instance.new("TextBox")
        box.Size = UDim2.new(0, 34, 0, 18)
        box.Position = UDim2.new(1, -34, 0.5, -9)
        box.BackgroundColor3 = Color3.fromRGB(31, 36, 48)
        box.TextColor3 = Color3.fromRGB(235, 240, 250)
        box.Font = Enum.Font.GothamSemibold
        box.TextSize = 10
        box.Text = tostring(defaultVal)
        box.Parent = row
        Instance.new("UICorner", box).CornerRadius = UDim.new(0, 4)

        local track = Instance.new("Frame")
        track.Size = UDim2.new(0, 58, 0, 5)
        track.Position = UDim2.new(1, -98, 0.5, -2.5)
        track.BackgroundColor3 = Color3.fromRGB(40, 45, 58)
        track.Parent = row
        Instance.new("UICorner", track).CornerRadius = UDim.new(1, 0)

        local fill = Instance.new("Frame")
        fill.Size = UDim2.new(0.5, 0, 1, 0)
        fill.BackgroundColor3 = Color3.fromRGB(82, 148, 255)
        fill.Parent = track
        Instance.new("UICorner", fill).CornerRadius = UDim.new(1, 0)

        local function roundNum(n)
            local mult = 10 ^ (decimals or 0)
            return math.floor(n * mult + 0.5) / mult
        end

        local function setSlider(val)
            local clamped = math.clamp(roundNum(tonumber(val) or defaultVal), minVal, maxVal)
            local pct = (maxVal == minVal) and 0 or ((clamped - minVal) / (maxVal - minVal))
            fill.Size = UDim2.new(pct, 0, 1, 0)
            box.Text = tostring(clamped)
            if callback then pcall(callback, clamped) end
        end

        local dragging = false
        local function updateFromInput(posX)
            local rel = math.clamp((posX - track.AbsolutePosition.X) / math.max(track.AbsoluteSize.X, 1), 0, 1)
            setSlider(minVal + rel * (maxVal - minVal))
        end

        track.InputBegan:Connect(function(i)
            if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
                dragging = true
                updateFromInput(i.Position.X)
            end
        end)
        UserInputService.InputChanged:Connect(function(i)
            if dragging and (i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch) then
                updateFromInput(i.Position.X)
            end
        end)
        UserInputService.InputEnded:Connect(function(i)
            if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
                dragging = false
            end
        end)
        box.FocusLost:Connect(function() setSlider(box.Text) end)

        setSlider(defaultVal)
        UI.ControlsRegistry[id] = setSlider
    end

    local function addDropdown(card, id, text, optionsList, defaultOpt, callback)
        local row = newRow(card, text)
        local current = defaultOpt or (optionsList and optionsList[1]) or ""

        local ddBtn = Instance.new("TextButton")
        ddBtn.Size = UDim2.new(0, 82, 0, 18)
        ddBtn.Position = UDim2.new(1, -82, 0.5, -9)
        ddBtn.BackgroundColor3 = Color3.fromRGB(32, 37, 50)
        ddBtn.TextColor3 = Color3.fromRGB(235, 240, 250)
        ddBtn.Font = Enum.Font.GothamSemibold
        ddBtn.TextSize = 10
        ddBtn.Text = current .. " v"
        ddBtn.Parent = row
        Instance.new("UICorner", ddBtn).CornerRadius = UDim.new(0, 5)

        local pop = Instance.new("Frame")
        pop.Size = UDim2.new(0, 82, 0, math.min(#optionsList * 20 + 4, 110))
        pop.Position = UDim2.new(1, -82, 1, 2)
        pop.BackgroundColor3 = Color3.fromRGB(26, 30, 41)
        pop.Visible = false
        pop.ZIndex = 30
        pop.Parent = row
        Instance.new("UICorner", pop).CornerRadius = UDim.new(0, 5)
        UI.OpenPopups[#UI.OpenPopups + 1] = pop

        Instance.new("UIListLayout", pop).Padding = UDim.new(0, 2)

        for _, opt in ipairs(optionsList) do
            local itemBtn = Instance.new("TextButton")
            itemBtn.Size = UDim2.new(1, -4, 0, 18)
            itemBtn.Position = UDim2.new(0, 2, 0, 0)
            itemBtn.BackgroundColor3 = Color3.fromRGB(35, 40, 55)
            itemBtn.TextColor3 = Color3.fromRGB(230, 236, 248)
            itemBtn.Font = Enum.Font.Gotham
            itemBtn.TextSize = 10
            itemBtn.Text = opt
            itemBtn.ZIndex = 31
            itemBtn.Parent = pop
            Instance.new("UICorner", itemBtn).CornerRadius = UDim.new(0, 4)
            itemBtn.MouseButton1Click:Connect(function()
                current = opt
                ddBtn.Text = opt .. " v"
                pop.Visible = false
                if callback then pcall(callback, opt) end
            end)
        end

        ddBtn.MouseButton1Click:Connect(function()
            local nextVis = not pop.Visible
            closeAllPopups()
            pop.Visible = nextVis
        end)
        UI.ControlsRegistry[id] = function(opt)
            current = opt
            ddBtn.Text = opt .. " v"
            pop.Visible = false
            if callback then pcall(callback, opt) end
        end
    end

    local function addActionButton(card, text, callback)
        local row = newRow(card, text)
        local actBtn = Instance.new("TextButton")
        actBtn.Size = UDim2.new(0, 68, 0, 18)
        actBtn.Position = UDim2.new(1, -68, 0.5, -9)
        actBtn.BackgroundColor3 = Color3.fromRGB(58, 108, 212)
        actBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
        actBtn.Font = Enum.Font.GothamBold
        actBtn.TextSize = 10
        actBtn.Text = "Rodar"
        actBtn.Parent = row
        Instance.new("UICorner", actBtn).CornerRadius = UDim.new(0, 5)
        actBtn.MouseButton1Click:Connect(function() if callback then pcall(callback) end end)
        return actBtn
    end

    searchBox:GetPropertyChangedSignal("Text"):Connect(function()
        local q = searchBox.Text:lower():gsub("^%s*(.-)%s*$", "%1")
        for _, page in pairs(pages) do
            for _, col in ipairs(page:GetChildren()) do
                for _, card in ipairs(col:GetChildren()) do
                    if card:IsA("Frame") then
                        for _, child in ipairs(card:GetChildren()) do
                            if child:IsA("Frame") and child.Name ~= "" then
                                child.Visible = (q == "" or child.Name:lower():find(q, 1, true) ~= nil)
                            end
                        end
                    end
                end
            end
        end
    end)

    addCategoryHeader("1. Combate & Macro")
    local cMacroL, cMacroR = createTab("Macro", "⌨")
    local cAHKL, cAHKR = createTab("AHK Skill", "⚡")
    local cCtrlL, cCtrlR = createTab("Control", "🌀")

    addCategoryHeader("2. Movimento & Glitch")
    local cGlitchL, cGlitchR = createTab("Glitch", "✦")

    addCategoryHeader("3. Visual & Fonte")
    local cFontL, cFontR = createTab("Fonte", "Aa")
    local cFleaL, cFleaR = createTab("Fleasion", "{}")

    addCategoryHeader("4. Flags")
    local cFlagL, cFlagR = createTab("Flags", "⚑")

    local fCard1 = createCard(cFlagL, "Motor Flags")
    addSwitch(fCard1, "AutoFlags", "Aplicar 700+ Flags", false, function(v)
        if v then FlagsEngine.Run(700) end
    end)
    local fRunBtn = addActionButton(fCard1, "Rodar Flags", function()
        local okCount = FlagsEngine.Run(700)
        fRunBtn.Text = tostring(okCount) .. " OK"
    end)

    local fCard2 = createCard(cFlagR, "Portal & Sanguine")
    addSwitch(fCard2, "PortalFZ", "Portal F->Z Predict", false, function(v) CombatHelper.PortalFZEnabled = v end)
    addSwitch(fCard2, "SanguineFC", "Sanguine F/C Predict", false, function(v) CombatHelper.SanguineFCEnabled = v end)
    addSlider(fCard2, "PredTime", "Predict (s)", 0.02, 0.35, 0.12, 2, function(v) CombatHelper.PredictTime = v end)

    local mCard1 = createCard(cMacroL, "hotkey.txt")
    addSwitch(mCard1, "FileMacroToggle", "Ativar Arquivo", false, function(v)
        MacroSystem.FileMacroEnabled = v
        if v then MacroSystem.SyncHotkeyFile() end
    end)
    local mSyncBtn = addActionButton(mCard1, "Detectar", function()
        mSyncBtn.Text = tostring(MacroSystem.SyncHotkeyFile()) .. "p"
    end)
    addActionButton(mCard1, "Executar", function()
        MacroSystem.FileMacroEnabled = true
        task.spawn(MacroSystem.RunParsedSteps)
    end)

    local mCard2 = createCard(cMacroR, "Atalho")
    addKeybind(mCard2, "MacroBind", "Tecla Macro", "G", function(kc)
        UserInputService.InputBegan:Connect(function(inp, gp)
            if not gp and inp.KeyCode == kc and MacroSystem.FileMacroEnabled then
                task.spawn(MacroSystem.RunParsedSteps)
            end
        end)
    end)

    local ctrlCard1 = createCard(cCtrlL, "Control + Estilo")
    addSwitch(ctrlCard1, "CtrlComboToggle", "Combo Control", false, function(v) MacroSystem.ControlComboEnabled = v end)
    addSlider(ctrlCard1, "CtrlDelay", "Delay (s)", 0.05, 1.0, 0.2, 2, function(v) MacroSystem.ControlDelay = v end)
    addActionButton(ctrlCard1, "Rodar Combo", function() task.spawn(MacroSystem.RunControlStyleCombo) end)

    local ahkCard1 = createCard(cAHKL, "Pos-Soru")
    addSwitch(ahkCard1, "PostSoruToggle", "Apos Soru", false, function(v) AHKSkill.SoruAutoEnabled = v end)
    addDropdown(ahkCard1, "PostSoruCat", "Trocar", { "Portal", "Melee", "Gun", "Sword" }, "Portal", function(v) AHKSkill.PostSoruCategory = v end)
    addDropdown(ahkCard1, "PostSoruSkill", "Skill", { "Z", "X", "C", "V", "F" }, "Z", function(v) AHKSkill.PostSoruSkill = v end)
    addSlider(ahkCard1, "PostSoruDelay", "Delay (s)", 0.01, 0.5, 0.08, 2, function(v) AHKSkill.PostSoruDelay = v end)

    local ahkCard2 = createCard(cAHKR, "Sequenciador")
    addDropdown(ahkCard2, "SeqMode", "Modo", { "Sequential", "Reverse", "Shuffle" }, "Sequential", function(v) AHKSkill.SeqMode = v end)
    addSlider(ahkCard2, "GlobalSeqDelay", "Delay (s)", 0.05, 1.0, 0.2, 2, function(v)
        for _, step in ipairs(AHKSkill.Sequence) do step.delay = v end
    end)
    addActionButton(ahkCard2, "Rodar Seq", function() task.spawn(AHKSkill.RunSequence) end)
    addActionButton(ahkCard2, "Resetar", function() AHKSkill.ResetSequence() end)
    local expBox = Instance.new("TextBox")
    expBox.Size = UDim2.new(1, 0, 0, 20)
    expBox.BackgroundColor3 = Color3.fromRGB(30, 35, 48)
    expBox.TextColor3 = Color3.fromRGB(220, 230, 245)
    expBox.Font = Enum.Font.Code
    expBox.TextSize = 9
    expBox.PlaceholderText = "JSON Export/Import"
    expBox.Parent = ahkCard2
    Instance.new("UICorner", expBox).CornerRadius = UDim.new(0, 4)
    addActionButton(ahkCard2, "Exportar", function()
        expBox.Text = AHKSkill.ExportConfig()
        if setclipboard then pcall(setclipboard, expBox.Text) end
    end)
    addActionButton(ahkCard2, "Importar", function() AHKSkill.ImportConfig(expBox.Text) end)

    local gCard1 = createCard(cGlitchL, "Impulso Hold")
    addSwitch(gCard1, "HoldImpToggle", "Ativar Hold", false, function(v) GlitchModule.HoldImpulseEnabled = v end)
    addSlider(gCard1, "HoldMinSlider", "Tempo Min (s)", 0.1, 2.5, 0.6, 2, function(v) GlitchModule.HoldMinTime = v end)
    addSlider(gCard1, "ImpPowerSlider", "Forca", 50, 900, 380, 0, function(v) GlitchModule.ImpulsePower = v end)
    addSlider(gCard1, "ImpDurSlider", "Duracao (s)", 0.1, 1.5, 0.45, 2, function(v) GlitchModule.ImpulseDuration = v end)

    local gCard2 = createCard(cGlitchR, "Dash & Escala")
    addSwitch(gCard2, "GlitchDashToggle", "Glitch Dash", false, function(v)
        GlitchModule.DashEnabled = v
        GlitchModule.UpdateDashState()
    end)
    addDropdown(gCard2, "GlitchDashMode", "Modo Dash", { "Manual", "Auto" }, "Manual", function(v) GlitchModule.DashMode = v end)
    addSlider(gCard2, "GlitchDashCd", "Cooldown (s)", 0.2, 4.0, 1.2, 1, function(v) GlitchModule.DashCooldown = v end)
    addSlider(gCard2, "GlitchDashSpd", "Velocidade", 80, 800, 320, 0, function(v) GlitchModule.DashSpeed = v end)
    addSwitch(gCard2, "ScalePresetToggle", "Preset Escala", false, function(v)
        GlitchModule.ScalePresetEnabled = v
        if v then GlitchModule.SaveAndApplyScale() else GlitchModule.RestoreScale() end
    end)
    addSlider(gCard2, "ScaleMultSlider", "Escala", 0.5, 3.0, 1.65, 2, function(v)
        GlitchModule.ScaleMultiplier = v
        if GlitchModule.ScalePresetEnabled then GlitchModule.SaveAndApplyScale() end
    end)

    local fnCard1 = createCard(cFontL, "Seleciona Fontes")
    local availableFonts = FontSystem.RefreshFontList()
    addDropdown(fnCard1, "FontSelectDD", "Fonte", availableFonts, availableFonts[1], function(v)
        FontSystem.SelectedFont = v
        if FontSystem.Enabled then FontSystem.ApplyAll() end
    end)
    addSwitch(fnCard1, "FontChangerToggle", "Trocar Fonte", false, function(v)
        FontSystem.Enabled = v
        if v then FontSystem.ApplyAll() else FontSystem.RestoreAll() end
    end)
    local fnReloadBtn = addActionButton(fnCard1, "Pasta", function()
        fnReloadBtn.Text = "OK"
        FontSystem.RefreshFontList()
    end)

    local flCard1 = createCard(cFleaL, "Regras Fleasion")
    local flJsonBox = Instance.new("TextBox")
    flJsonBox.Size = UDim2.new(1, 0, 0, 44)
    flJsonBox.BackgroundColor3 = Color3.fromRGB(30, 35, 48)
    flJsonBox.TextColor3 = Color3.fromRGB(220, 230, 245)
    flJsonBox.Font = Enum.Font.Code
    flJsonBox.TextSize = 9
    flJsonBox.MultiLine = true
    flJsonBox.Text = DEFAULT_FLEASION_JSON
    flJsonBox.Parent = flCard1
    Instance.new("UICorner", flJsonBox).CornerRadius = UDim.new(0, 5)

    local flApplyBtn = addActionButton(flCard1, "Aplicar", function()
        FleasionModule.ParseJSON(flJsonBox.Text)
        flApplyBtn.Text = tostring(FleasionModule.ApplyRules()) .. "x"
    end)

    selectTab("Flags")
    setInterfaceVisible(false)
end

createGUI()
ooldown)
            end
        end
    end
end)

-- Preset de escala do personagem com restauracao completa
GlitchModule.ScalePresetEnabled = false
GlitchModule.ScaleMultiplier = 1.65
GlitchModule.SavedRig = { parts = {}, joints = {}, accessories = {} }

function GlitchModule.SaveAndApplyScale()
    local char = lp.Character
    if not char then return end
    GlitchModule.SavedRig = { parts = {}, joints = {}, accessories = {} }

    for _, d in ipairs(char:GetDescendants()) do
        if d:IsA("BasePart") then
            GlitchModule.SavedRig.parts[d] = { Size = d.Size, CanCollide = d.CanCollide }
            if d.Name ~= "HumanoidRootPart" then
                d.Size = d.Size * GlitchModule.ScaleMultiplier
            end
        elseif d:IsA("Motor6D") then
            GlitchModule.SavedRig.joints[d] = { C0 = d.C0, C1 = d.C1 }
            d.C0 = CFrame.new(d.C0.Position * GlitchModule.ScaleMultiplier) * (d.C0 - d.C0.Position)
        elseif d:IsA("Accessory") then
            GlitchModule.SavedRig.accessories[d] = d.Parent
        end
    end
end

function GlitchModule.RestoreScale()
    for part, info in pairs(GlitchModule.SavedRig.parts) do
        pcall(function()
            if part and part.Parent then
                part.Size = info.Size
                part.CanCollide = info.CanCollide
            end
        end)
    end
    for joint, info in pairs(GlitchModule.SavedRig.joints) do
        pcall(function()
            if joint and joint.Parent then
                joint.C0 = info.C0
                joint.C1 = info.C1
            end
        end)
    end
    for acc, parent in pairs(GlitchModule.SavedRig.accessories) do
        pcall(function()
            if acc and parent then acc.Parent = parent end
        end)
    end
    GlitchModule.SavedRig = { parts = {}, joints = {}, accessories = {} }
end

-- ============================================================================
-- 7. FLEASION JSON RULES PARSER & MANAGER
-- ============================================================================
local FleasionModule = {}
FleasionModule.Rules = {}
FleasionModule.AppliedCount = 0

local DEFAULT_FLEASION_JSON = [[
{
  "replacement_rules": [
    { "name": "Control z", "replace_ids": [130002991386896], "mode": "id", "enabled": true },
    { "name": "Profile 1", "replace_ids": [130002991386896], "mode": "id", "enabled": true },
    { "name": "Profile 2", "replace_ids": [135584181153647, 108802825433341], "mode": "id", "enabled": true }
  ]
}
]]

function FleasionModule.ParseJSON(jsonText)
    local ok, decoded = pcall(HttpService.JSONDecode, HttpService, jsonText or DEFAULT_FLEASION_JSON)
    if not ok or type(decoded) ~= "table" or type(decoded.replacement_rules) ~= "table" then
        return false, 0
    end
    FleasionModule.Rules = decoded.replacement_rules
    return true, #FleasionModule.Rules
end

function FleasionModule.ApplyRules()
    if #FleasionModule.Rules == 0 then
        FleasionModule.ParseJSON(DEFAULT_FLEASION_JSON)
    end
    local mapReplace = {}
    for _, rule in ipairs(FleasionModule.Rules) do
        if rule.enabled ~= false and type(rule.replace_ids) == "table" then
            local targetId = rule.with_id and tostring(rule.with_id) or ""
            for _, idVal in ipairs(rule.replace_ids) do
                mapReplace[tostring(idVal)] = targetId
            end
        end
    end

    local count = 0
    local function scan(inst)
        for _, d in ipairs(inst:GetDescendants()) do
            pcall(function()
                if d:IsA("Decal") or d:IsA("Texture") then
                    local idNum = tostring(d.Texture):match("%d+")
                    if idNum and mapReplace[idNum] ~= nil then
                        d.Texture = mapReplace[idNum] ~= "" and ("rbxassetid://" .. mapReplace[idNum]) or ""
                        count += 1
                    end
                elseif d:IsA("ImageLabel") or d:IsA("ImageButton") then
                    local idNum = tostring(d.Image):match("%d+")
                    if idNum and mapReplace[idNum] ~= nil then
                        d.Image = mapReplace[idNum] ~= "" and ("rbxassetid://" .. mapReplace[idNum]) or ""
                        count += 1
                    end
                elseif d:IsA("SpecialMesh") then
                    local idNum = tostring(d.MeshId):match("%d+")
                    if idNum and mapReplace[idNum] ~= nil then
                        d.MeshId = mapReplace[idNum] ~= "" and ("rbxassetid://" .. mapReplace[idNum]) or ""
                        count += 1
                    end
                end
            end)
        end
    end

    scan(workspace)
    local pg = lp:FindFirstChild("PlayerGui")
    if pg then scan(pg) end
    FleasionModule.AppliedCount = count
    return count
end

-- ============================================================================
-- 8. INTERFACE VISUAL (CATEGORIAS | PERFIS + BUSCA | 2 COLUNAS | COMPONENTES)
-- ============================================================================
local UI = {}
UI.Profiles = { Default = {} }
UI.CurrentProfile = "Default"
UI.ControlsRegistry = {}

local function loadProfiles()
    pcall(function()
        if isfile and readfile and isfile(PROFILES_FILE) then
            local decoded = HttpService:JSONDecode(readfile(PROFILES_FILE))
            if type(decoded) == "table" then
                UI.Profiles = decoded
            end
        end
    end)
end
loadProfiles()

local function saveProfiles()
    pcall(function()
        if writefile then
            writefile(PROFILES_FILE, HttpService:JSONEncode(UI.Profiles))
        end
    end)
end

local function createGUI()
    for _, g in ipairs(game:GetService("CoreGui"):GetChildren()) do
        if g.Name == "UnifiedSuiteUI" then g:Destroy() end
    end

    local sg = Instance.new("ScreenGui")
    sg.Name = "UnifiedSuiteUI"
    sg.ResetOnSpawn = false
    sg.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    sg.Parent = game:GetService("CoreGui")

    local main = Instance.new("Frame")
    main.Size = UDim2.new(0, 740, 0, 470)
    main.Position = UDim2.new(0.5, -370, 0.5, -235)
    main.BackgroundColor3 = Color3.fromRGB(16, 18, 24)
    main.BorderSizePixel = 0
    main.Active = true
    main.Draggable = true
    main.Parent = sg
    Instance.new("UICorner", main).CornerRadius = UDim.new(0, 10)

    -- 1. Navegacao Lateral Categorizada
    local sidebar = Instance.new("ScrollingFrame")
    sidebar.Size = UDim2.new(0, 185, 1, 0)
    sidebar.BackgroundColor3 = Color3.fromRGB(21, 24, 32)
    sidebar.BorderSizePixel = 0
    sidebar.ScrollBarThickness = 2
    sidebar.CanvasSize = UDim2.new(0, 0, 0, 680)
    sidebar.Parent = main
    Instance.new("UICorner", sidebar).CornerRadius = UDim.new(0, 10)

    local sideLayout = Instance.new("UIListLayout")
    sideLayout.Padding = UDim.new(0, 4)
    sideLayout.Parent = sidebar

    local sidePad = Instance.new("UIPadding")
    sidePad.PaddingTop = UDim.new(0, 10)
    sidePad.PaddingLeft = UDim.new(0, 8)
    sidePad.PaddingRight = UDim.new(0, 8)
    sidePad.Parent = sidebar

    -- Area de conteudo
    local contentArea = Instance.new("Frame")
    contentArea.Size = UDim2.new(1, -193, 1, -16)
    contentArea.Position = UDim2.new(0, 189, 0, 8)
    contentArea.BackgroundTransparency = 1
    contentArea.Parent = main

    -- 2. Barra Superior (Dropdown Perfis + Editar à esquerda | Lupa/Busca à direita)
    local topBar = Instance.new("Frame")
    topBar.Size = UDim2.new(1, 0, 0, 36)
    topBar.BackgroundColor3 = Color3.fromRGB(22, 26, 35)
    topBar.BorderSizePixel = 0
    topBar.Parent = contentArea
    Instance.new("UICorner", topBar).CornerRadius = UDim.new(0, 8)

    local profileBtn = Instance.new("TextButton")
    profileBtn.Size = UDim2.new(0, 150, 0, 26)
    profileBtn.Position = UDim2.new(0, 8, 0.5, -13)
    profileBtn.BackgroundColor3 = Color3.fromRGB(30, 35, 48)
    profileBtn.TextColor3 = Color3.fromRGB(235, 240, 250)
    profileBtn.Font = Enum.Font.GothamSemibold
    profileBtn.TextSize = 12
    profileBtn.Text = "Perfil: " .. UI.CurrentProfile .. " v"
    profileBtn.Parent = topBar
    Instance.new("UICorner", profileBtn).CornerRadius = UDim.new(0, 6)

    local editProfileBtn = Instance.new("TextButton")
    editProfileBtn.Size = UDim2.new(0, 26, 0, 26)
    editProfileBtn.Position = UDim2.new(0, 164, 0.5, -13)
    editProfileBtn.BackgroundColor3 = Color3.fromRGB(36, 42, 58)
    editProfileBtn.TextColor3 = Color3.fromRGB(160, 195, 255)
    editProfileBtn.Font = Enum.Font.GothamBold
    editProfileBtn.TextSize = 12
    editProfileBtn.Text = "✎"
    editProfileBtn.Parent = topBar
    Instance.new("UICorner", editProfileBtn).CornerRadius = UDim.new(0, 6)

    local searchBox = Instance.new("TextBox")
    searchBox.Size = UDim2.new(0, 185, 0, 26)
    searchBox.Position = UDim2.new(1, -193, 0.5, -13)
    searchBox.BackgroundColor3 = Color3.fromRGB(29, 34, 46)
    searchBox.TextColor3 = Color3.fromRGB(240, 244, 255)
    searchBox.PlaceholderText = "🔍 Buscar funcao..."
    searchBox.PlaceholderColor3 = Color3.fromRGB(130, 140, 160)
    searchBox.Font = Enum.Font.Gotham
    searchBox.TextSize = 12
    searchBox.Text = ""
    searchBox.ClearTextOnFocus = false
    searchBox.Parent = topBar
    Instance.new("UICorner", searchBox).CornerRadius = UDim.new(0, 6)

    local profileMenu = Instance.new("Frame")
    profileMenu.Size = UDim2.new(0, 165, 0, 110)
    profileMenu.Position = UDim2.new(0, 8, 0, 38)
    profileMenu.BackgroundColor3 = Color3.fromRGB(26, 30, 41)
    profileMenu.Visible = false
    profileMenu.ZIndex = 20
    profileMenu.Parent = contentArea
    Instance.new("UICorner", profileMenu).CornerRadius = UDim.new(0, 6)
    local pmList = Instance.new("UIListLayout")
    pmList.Padding = UDim.new(0, 2)
    pmList.Parent = profileMenu

    local function rebuildProfileMenu()
        for _, ch in ipairs(profileMenu:GetChildren()) do
            if ch:IsA("TextButton") then ch:Destroy() end
        end
        for pName in pairs(UI.Profiles) do
            local b = Instance.new("TextButton")
            b.Size = UDim2.new(1, -6, 0, 24)
            b.BackgroundColor3 = Color3.fromRGB(34, 39, 53)
            b.TextColor3 = Color3.fromRGB(235, 240, 250)
            b.Font = Enum.Font.Gotham
            b.TextSize = 11
            b.Text = pName
            b.ZIndex = 21
            b.Parent = profileMenu
            Instance.new("UICorner", b).CornerRadius = UDim.new(0, 5)
            b.MouseButton1Click:Connect(function()
                UI.CurrentProfile = pName
                profileBtn.Text = "Perfil: " .. pName .. " v"
                profileMenu.Visible = false
                local saved = UI.Profiles[pName] or {}
                for id, setter in pairs(UI.ControlsRegistry) do
                    if saved[id] ~= nil then
                        pcall(setter, saved[id])
                    end
                end
            end)
        end
    end

    profileBtn.MouseButton1Click:Connect(function()
        rebuildProfileMenu()
        profileMenu.Visible = not profileMenu.Visible
    end)

    editProfileBtn.MouseButton1Click:Connect(function()
        UI.Profiles[UI.CurrentProfile] = UI.Profiles[UI.CurrentProfile] or {}
        saveProfiles()
        editProfileBtn.Text = "✓"
        task.delay(0.8, function() editProfileBtn.Text = "✎" end)
    end)

    -- Container das paginas de abas
    local pagesHolder = Instance.new("Frame")
    pagesHolder.Size = UDim2.new(1, 0, 1, -44)
    pagesHolder.Position = UDim2.new(0, 0, 0, 44)
    pagesHolder.BackgroundTransparency = 1
    pagesHolder.Parent = contentArea

    local tabButtons = {}
    local pages = {}
    local activeTabName = nil

    local function addCategoryHeader(catTitle)
        local lbl = Instance.new("TextLabel")
        lbl.Size = UDim2.new(1, 0, 0, 18)
        lbl.BackgroundTransparency = 1
        lbl.Text = string.upper(catTitle)
        lbl.TextColor3 = Color3.fromRGB(128, 134, 148)
        lbl.Font = Enum.Font.GothamBold
        lbl.TextSize = 10
        lbl.TextXAlignment = Enum.TextXAlignment.Left
        lbl.Parent = sidebar
    end

    local function selectTab(name)
        activeTabName = name
        for tName, page in pairs(pages) do
            page.Visible = (tName == name)
        end
        for tName, btn in pairs(tabButtons) do
            local isSel = (tName == name)
            btn.BackgroundColor3 = isSel and Color3.fromRGB(48, 86, 175) or Color3.fromRGB(27, 31, 42)
            btn.TextColor3 = isSel and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(185, 192, 208)
        end
    end

    local function createTab(name, icon)
        local btn = Instance.new("TextButton")
        btn.Size = UDim2.new(1, 0, 0, 30)
        btn.BackgroundColor3 = Color3.fromRGB(27, 31, 42)
        btn.TextColor3 = Color3.fromRGB(185, 192, 208)
        btn.Font = Enum.Font.GothamSemibold
        btn.TextSize = 12
        btn.TextXAlignment = Enum.TextXAlignment.Left
        btn.Text = "  " .. icon .. "   " .. name
        btn.Parent = sidebar
        Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 6)

        -- 3. Duas Colunas de Cartoes (Esquerda e Direita)
        local page = Instance.new("Frame")
        page.Size = UDim2.new(1, 0, 1, 0)
        page.BackgroundTransparency = 1
        page.Visible = false
        page.Parent = pagesHolder

        local leftCol = Instance.new("ScrollingFrame")
        leftCol.Size = UDim2.new(0.5, -5, 1, 0)
        leftCol.Position = UDim2.new(0, 0, 0, 0)
        leftCol.BackgroundTransparency = 1
        leftCol.ScrollBarThickness = 2
        leftCol.CanvasSize = UDim2.new(0, 0, 0, 650)
        leftCol.Parent = page

        local rightCol = Instance.new("ScrollingFrame")
        rightCol.Size = UDim2.new(0.5, -5, 1, 0)
        rightCol.Position = UDim2.new(0.5, 5, 0, 0)
        rightCol.BackgroundTransparency = 1
        rightCol.ScrollBarThickness = 2
        rightCol.CanvasSize = UDim2.new(0, 0, 0, 650)
        rightCol.Parent = page

        local lList = Instance.new("UIListLayout")
        lList.Padding = UDim.new(0, 8)
        lList.Parent = leftCol

        local rList = Instance.new("UIListLayout")
        rList.Padding = UDim.new(0, 8)
        rList.Parent = rightCol

        btn.MouseButton1Click:Connect(function()
            selectTab(name)
        end)

        tabButtons[name] = btn
        pages[name] = page
        return leftCol, rightCol
    end

    -- 4. Componentes Padronizados dentro dos Cartoes
    local function createCard(parentCol, sectionTitle)
        local card = Instance.new("Frame")
        card.Size = UDim2.new(1, 0, 0, 44)
        card.AutomaticSize = Enum.AutomaticSize.Y
        card.BackgroundColor3 = Color3.fromRGB(22, 26, 35)
        card.BorderSizePixel = 0
        card.Parent = parentCol
        Instance.new("UICorner", card).CornerRadius = UDim.new(0, 8)

        local cList = Instance.new("UIListLayout")
        cList.Padding = UDim.new(0, 6)
        cList.Parent = card

        local cPad = Instance.new("UIPadding")
        cPad.PaddingTop = UDim.new(0, 8)
        cPad.PaddingBottom = UDim.new(0, 8)
        cPad.PaddingLeft = UDim.new(0, 10)
        cPad.PaddingRight = UDim.new(0, 10)
        cPad.Parent = card

        local hdr = Instance.new("TextLabel")
        hdr.Size = UDim2.new(1, 0, 0, 16)
        hdr.BackgroundTransparency = 1
        hdr.Text = sectionTitle
        hdr.TextColor3 = Color3.fromRGB(145, 160, 190)
        hdr.Font = Enum.Font.GothamBold
        hdr.TextSize = 11
        hdr.TextXAlignment = Enum.TextXAlignment.Left
        hdr.Parent = card

        return card
    end

    local function newRow(card, labelText)
        local row = Instance.new("Frame")
        row.Name = labelText
        row.Size = UDim2.new(1, 0, 0, 26)
        row.BackgroundTransparency = 1
        row.Parent = card

        local lbl = Instance.new("TextLabel")
        lbl.Size = UDim2.new(0.58, 0, 1, 0)
        lbl.BackgroundTransparency = 1
        lbl.Text = labelText
        lbl.TextColor3 = Color3.fromRGB(228, 233, 244)
        lbl.Font = Enum.Font.Gotham
        lbl.TextSize = 12
        lbl.TextXAlignment = Enum.TextXAlignment.Left
        lbl.Parent = row
        return row
    end

    local function addSwitch(card, id, text, defaultVal, callback)
        local row = newRow(card, text)
        local pill = Instance.new("TextButton")
        pill.Size = UDim2.new(0, 42, 0, 22)
        pill.Position = UDim2.new(1, -42, 0.5, -11)
        pill.BackgroundColor3 = defaultVal and Color3.fromRGB(66, 133, 244) or Color3.fromRGB(45, 50, 64)
        pill.Text = ""
        pill.Parent = row
        Instance.new("UICorner", pill).CornerRadius = UDim.new(1, 0)

        local knob = Instance.new("Frame")
        knob.Size = UDim2.new(0, 16, 0, 16)
        knob.Position = defaultVal and UDim2.new(1, -19, 0.5, -8) or UDim2.new(0, 3, 0.5, -8)
        knob.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        knob.Parent = pill
        Instance.new("UICorner", knob).CornerRadius = UDim.new(1, 0)

        local state = defaultVal == true
        local function setVal(v)
            state = v == true
            pill.BackgroundColor3 = state and Color3.fromRGB(66, 133, 244) or Color3.fromRGB(45, 50, 64)
            knob:TweenPosition(state and UDim2.new(1, -19, 0.5, -8) or UDim2.new(0, 3, 0.5, -8), Enum.EasingDirection.Out, Enum.EasingStyle.Quad, 0.12, true)
            UI.Profiles[UI.CurrentProfile] = UI.Profiles[UI.CurrentProfile] or {}
            UI.Profiles[UI.CurrentProfile][id] = state
            if callback then pcall(callback, state) end
        end

        pill.MouseButton1Click:Connect(function() setVal(not state) end)
        UI.ControlsRegistry[id] = setVal
        if defaultVal then task.defer(function() pcall(callback, true) end) end
    end

    local function addKeybind(card, id, text, defaultKey, callback)
        local row = newRow(card, text)
        local keyPill = Instance.new("TextButton")
        keyPill.Size = UDim2.new(0, 68, 0, 22)
        keyPill.Position = UDim2.new(1, -68, 0.5, -11)
        keyPill.BackgroundColor3 = Color3.fromRGB(27, 30, 38)
        keyPill.TextColor3 = Color3.fromRGB(220, 228, 245)
        keyPill.Font = Enum.Font.GothamBold
        keyPill.TextSize = 11
        keyPill.Text = defaultKey or "F"
        keyPill.Parent = row
        Instance.new("UICorner", keyPill).CornerRadius = UDim.new(1, 0)

        local listening = false
        keyPill.MouseButton1Click:Connect(function()
            listening = true
            keyPill.Text = "..."
        end)
        UserInputService.InputBegan:Connect(function(inp, gp)
            if not listening or gp then return end
            if inp.UserInputType == Enum.UserInputType.Keyboard then
                listening = false
                local kName = inp.KeyCode.Name
                keyPill.Text = kName
                if callback then pcall(callback, inp.KeyCode, kName) end
            end
        end)
    end

    local function addSlider(card, id, text, minVal, maxVal, defaultVal, decimals, callback)
        local row = newRow(card, text)
        local box = Instance.new("TextBox")
        box.Size = UDim2.new(0, 44, 0, 20)
        box.Position = UDim2.new(1, -44, 0.5, -10)
        box.BackgroundColor3 = Color3.fromRGB(31, 36, 48)
        box.TextColor3 = Color3.fromRGB(235, 240, 250)
        box.Font = Enum.Font.GothamSemibold
        box.TextSize = 11
        box.Text = tostring(defaultVal)
        box.Parent = row
        Instance.new("UICorner", box).CornerRadius = UDim.new(0, 5)

        local track = Instance.new("Frame")
        track.Size = UDim2.new(0, 96, 0, 6)
        track.Position = UDim2.new(1, -148, 0.5, -3)
        track.BackgroundColor3 = Color3.fromRGB(40, 45, 58)
        track.Parent = row
        Instance.new("UICorner", track).CornerRadius = UDim.new(1, 0)

        local fill = Instance.new("Frame")
        fill.Size = UDim2.new(0.5, 0, 1, 0)
        fill.BackgroundColor3 = Color3.fromRGB(82, 148, 255)
        fill.Parent = track
        Instance.new("UICorner", fill).CornerRadius = UDim.new(1, 0)

        local dot = Instance.new("Frame")
        dot.Size = UDim2.new(0, 12, 0, 12)
        dot.AnchorPoint = Vector2.new(0.5, 0.5)
        dot.Position = UDim2.new(0.5, 0, 0.5, 0)
        dot.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        dot.Parent = track
        Instance.new("UICorner", dot).CornerRadius = UDim.new(1, 0)

        local function roundNum(n)
            local mult = 10 ^ (decimals or 0)
            return math.floor(n * mult + 0.5) / mult
        end

        local function setSlider(val)
            local clamped = math.clamp(roundNum(tonumber(val) or defaultVal), minVal, maxVal)
            local pct = (maxVal == minVal) and 0 or ((clamped - minVal) / (maxVal - minVal))
            fill.Size = UDim2.new(pct, 0, 1, 0)
            dot.Position = UDim2.new(pct, 0, 0.5, 0)
            box.Text = tostring(clamped)
            if callback then pcall(callback, clamped) end
        end

        local dragging = false
        local function updateFromInput(posX)
            local rel = math.clamp((posX - track.AbsolutePosition.X) / math.max(track.AbsoluteSize.X, 1), 0, 1)
            setSlider(minVal + rel * (maxVal - minVal))
        end

        track.InputBegan:Connect(function(i)
            if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
                dragging = true
                updateFromInput(i.Position.X)
            end
        end)
        UserInputService.InputChanged:Connect(function(i)
            if dragging and (i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch) then
                updateFromInput(i.Position.X)
            end
        end)
        UserInputService.InputEnded:Connect(function(i)
            if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
                dragging = false
            end
        end)
        box.FocusLost:Connect(function() setSlider(box.Text) end)

        setSlider(defaultVal)
        UI.ControlsRegistry[id] = setSlider
    end

    local function addDropdown(card, id, text, optionsList, defaultOpt, callback)
        local row = newRow(card, text)
        local current = defaultOpt or (optionsList and optionsList[1]) or ""

        local ddBtn = Instance.new("TextButton")
        ddBtn.Size = UDim2.new(0, 118, 0, 22)
        ddBtn.Position = UDim2.new(1, -118, 0.5, -11)
        ddBtn.BackgroundColor3 = Color3.fromRGB(32, 37, 50)
        ddBtn.TextColor3 = Color3.fromRGB(235, 240, 250)
        ddBtn.Font = Enum.Font.GothamSemibold
        ddBtn.TextSize = 11
        ddBtn.Text = current .. " ▾"
        ddBtn.Parent = row
        Instance.new("UICorner", ddBtn).CornerRadius = UDim.new(0, 6)

        local pop = Instance.new("Frame")
        pop.Size = UDim2.new(0, 118, 0, math.min(#optionsList * 24 + 4, 140))
        pop.Position = UDim2.new(1, -118, 1, 2)
        pop.BackgroundColor3 = Color3.fromRGB(26, 30, 41)
        pop.Visible = false
        pop.ZIndex = 30
        pop.Parent = row
        Instance.new("UICorner", pop).CornerRadius = UDim.new(0, 6)

        local pList = Instance.new("UIListLayout")
        pList.Padding = UDim.new(0, 2)
        pList.Parent = pop

        local function selectOption(opt)
            current = opt
            ddBtn.Text = opt .. " ▾"
            pop.Visible = false
            if callback then pcall(callback, opt) end
        end

        for _, opt in ipairs(optionsList) do
            local itemBtn = Instance.new("TextButton")
            itemBtn.Size = UDim2.new(1, -4, 0, 22)
            itemBtn.Position = UDim2.new(0, 2, 0, 0)
            itemBtn.BackgroundColor3 = Color3.fromRGB(35, 40, 55)
            itemBtn.TextColor3 = Color3.fromRGB(230, 236, 248)
            itemBtn.Font = Enum.Font.Gotham
            itemBtn.TextSize = 11
            itemBtn.Text = opt
            itemBtn.ZIndex = 31
            itemBtn.Parent = pop
            Instance.new("UICorner", itemBtn).CornerRadius = UDim.new(0, 4)
            itemBtn.MouseButton1Click:Connect(function() selectOption(opt) end)
        end

        ddBtn.MouseButton1Click:Connect(function() pop.Visible = not pop.Visible end)
        UI.ControlsRegistry[id] = selectOption
    end

    local function addActionButton(card, text, callback)
        local row = newRow(card, text)
        local actBtn = Instance.new("TextButton")
        actBtn.Size = UDim2.new(0, 96, 0, 22)
        actBtn.Position = UDim2.new(1, -96, 0.5, -11)
        actBtn.BackgroundColor3 = Color3.fromRGB(58, 108, 212)
        actBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
        actBtn.Font = Enum.Font.GothamBold
        actBtn.TextSize = 11
        actBtn.Text = "Executar"
        actBtn.Parent = row
        Instance.new("UICorner", actBtn).CornerRadius = UDim.new(0, 6)
        actBtn.MouseButton1Click:Connect(function() if callback then pcall(callback) end end)
        return actBtn
    end

    -- Busca em tempo real nas linhas dos cartoes
    searchBox:GetPropertyChangedSignal("Text"):Connect(function()
        local q = searchBox.Text:lower():gsub("^%s*(.-)%s*$", "%1")
        for _, page in pairs(pages) do
            for _, col in ipairs(page:GetChildren()) do
                for _, card in ipairs(col:GetChildren()) do
                    if card:IsA("Frame") then
                        for _, child in ipairs(card:GetChildren()) do
                            if child:IsA("Frame") and child.Name ~= "" then
                                child.Visible = (q == "" or child.Name:lower():find(q, 1, true) ~= nil)
                            end
                        end
                    end
                end
            end
        end
    end)

    -- ==================== MONTAGEM DAS ABAS CATEGORIZADAS ====================
    addCategoryHeader("Categoria 1 - Combate & Macro")
    local cMacroL, cMacroR = createTab("Macro", "⌨")
    local cAHKL, cAHKR = createTab("AHK Skill", "⚡")
    local cCtrlL, cCtrlR = createTab("Control Macro", "🌀")

    addCategoryHeader("Categoria 2 - Movimento & Glitch")
    local cGlitchL, cGlitchR = createTab("Glitch", "✦")

    addCategoryHeader("Categoria 3 - Visual & Fonte")
    local cFontL, cFontR = createTab("Fonte", "Aa")
    local cFleaL, cFleaR = createTab("Fleasion", "{}")

    addCategoryHeader("Categoria 4 - Performance & Flags")
    local cFlagL, cFlagR = createTab("Flags", "⚑")

    -- ABA: FLAGS
    local fCard1 = createCard(cFlagL, "Motor de 1500+ Flags")
    addSwitch(fCard1, "AutoFlags", "Aplicar 700+ Flags (Sem Erro)", false, function(v)
        if v then FlagsEngine.Run(700) end
    end)
    local fRunBtn = addActionButton(fCard1, "Rodar Flags Agora", function()
        local okCount = FlagsEngine.Run(700)
        fRunBtn.Text = tostring(okCount) .. " OK"
    end)

    local fCard2 = createCard(cFlagR, "Portal & Sanguine Predict")
    addSwitch(fCard2, "PortalFZ", "Portal F -> Z Predict", false, function(v)
        CombatHelper.PortalFZEnabled = v
    end)
    addSwitch(fCard2, "SanguineFC", "Sanguine F/C Predict", false, function(v)
        CombatHelper.SanguineFCEnabled = v
    end)
    addSlider(fCard2, "PredTime", "Predict Tempo (s)", 0.02, 0.35, 0.12, 2, function(v)
        CombatHelper.PredictTime = v
    end)

    -- ABA: MACRO (ARQUIVO hotkey.txt)
    local mCard1 = createCard(cMacroL, "Arquivo hotkey.txt")
    addSwitch(mCard1, "FileMacroToggle", "Monitorar & Ativar Arquivo", false, function(v)
        MacroSystem.FileMacroEnabled = v
        if v then MacroSystem.SyncHotkeyFile() end
    end)
    local mSyncBtn = addActionButton(mCard1, "Detectar & Salvar", function()
        local count = MacroSystem.SyncHotkeyFile()
        mSyncBtn.Text = tostring(count) .. " passos"
    end)
    addActionButton(mCard1, "Rodar Macro", function()
        MacroSystem.FileMacroEnabled = true
        task.spawn(MacroSystem.RunParsedSteps)
    end)

    local mCard2 = createCard(cMacroR, "Status do Arquivo")
    addKeybind(mCard2, "MacroBind", "Tecla Rapida Macro", "G", function(kc)
        UserInputService.InputBegan:Connect(function(inp, gp)
            if not gp and inp.KeyCode == kc and MacroSystem.FileMacroEnabled then
                task.spawn(MacroSystem.RunParsedSteps)
            end
        end)
    end)

    -- ABA: CONTROL FRUIT + FIGHTING STYLE MACRO
    local ctrlCard1 = createCard(cCtrlL, "Control + Estilo de Luta")
    addSwitch(ctrlCard1, "CtrlComboToggle", "Ativar Combo Control", false, function(v)
        MacroSystem.ControlComboEnabled = v
    end)
    addSlider(ctrlCard1, "CtrlDelay", "Delay Etapas (s)", 0.05, 1.0, 0.2, 2, function(v)
        MacroSystem.ControlDelay = v
    end)
    addActionButton(ctrlCard1, "Executar Combo", function()
        task.spawn(MacroSystem.RunControlStyleCombo)
    end)

    -- ABA: AHK SKILL (SORU + SEQUENCIADOR)
    local ahkCard1 = createCard(cAHKL, "Pos-Soru Auto Switch & Skill")
    addSwitch(ahkCard1, "PostSoruToggle", "Ativar Apos Soru", false, function(v)
        AHKSkill.SoruAutoEnabled = v
    end)
    addDropdown(ahkCard1, "PostSoruCat", "Trocar Para", { "Portal", "Melee", "Gun", "Sword" }, "Portal", function(v)
        AHKSkill.PostSoruCategory = v
    end)
    addDropdown(ahkCard1, "PostSoruSkill", "Skill Apos Soru", { "Z", "X", "C", "V", "F" }, "Z", function(v)
        AHKSkill.PostSoruSkill = v
    end)
    addSlider(ahkCard1, "PostSoruDelay", "Delay Pos-Soru (s)", 0.01, 0.5, 0.08, 2, function(v)
        AHKSkill.PostSoruDelay = v
    end)

    local ahkCard2 = createCard(cAHKR, "Sequenciador (Melee/Sword/Fruit/Gun)")
    addDropdown(ahkCard2, "SeqMode", "Modo Sequencia", { "Sequential", "Reverse", "Shuffle" }, "Sequential", function(v)
        AHKSkill.SeqMode = v
    end)
    addSlider(ahkCard2, "GlobalSeqDelay", "Hold/Delay Padrao (s)", 0.05, 1.0, 0.2, 2, function(v)
        for _, step in ipairs(AHKSkill.Sequence) do step.delay = v end
    end)
    addActionButton(ahkCard2, "Montar & Rodar", function()
        task.spawn(AHKSkill.RunSequence)
    end)
    addActionButton(ahkCard2, "Reset Sequencia", function()
        AHKSkill.ResetSequence()
    end)
    local expBox = Instance.new("TextBox")
    expBox.Size = UDim2.new(1, 0, 0, 24)
    expBox.BackgroundColor3 = Color3.fromRGB(30, 35, 48)
    expBox.TextColor3 = Color3.fromRGB(220, 230, 245)
    expBox.Font = Enum.Font.Code
    expBox.TextSize = 10
    expBox.PlaceholderText = "JSON Share (Exportar / Colar para Importar)"
    expBox.Parent = ahkCard2
    Instance.new("UICorner", expBox).CornerRadius = UDim.new(0, 5)
    addActionButton(ahkCard2, "Exportar JSON", function()
        expBox.Text = AHKSkill.ExportConfig()
        if setclipboard then pcall(setclipboard, expBox.Text) end
    end)
    addActionButton(ahkCard2, "Importar JSON", function()
        AHKSkill.ImportConfig(expBox.Text)
    end)

    -- ABA: GLITCH (SEM TECLAS Z/C)
    local gCard1 = createCard(cGlitchL, "Impulso por Animacao")
    addSwitch(gCard1, "HoldImpToggle", "Ativar Impulso Hold", false, function(v)
        GlitchModule.HoldImpulseEnabled = v
    end)
    addSlider(gCard1, "HoldMinSlider", "Tempo Minimo (s)", 0.1, 2.5, 0.6, 2, function(v)
        GlitchModule.HoldMinTime = v
    end)
    addSlider(gCard1, "ImpPowerSlider", "Forca Impulso", 50, 900, 380, 0, function(v)
        GlitchModule.ImpulsePower = v
    end)
    addSlider(gCard1, "ImpDurSlider", "Duracao Impulso (s)", 0.1, 1.5, 0.45, 2, function(v)
        GlitchModule.ImpulseDuration = v
    end)

    local gCard2 = createCard(cGlitchR, "Dash & Escala Personagem")
    addSwitch(gCard2, "GlitchDashToggle", "Ativar Glitch Dash", false, function(v)
        GlitchModule.DashEnabled = v
        GlitchModule.UpdateDashState()
    end)
    addDropdown(gCard2, "GlitchDashMode", "Modo do Dash", { "Manual", "Auto" }, "Manual", function(v)
        GlitchModule.DashMode = v
    end)
    addSlider(gCard2, "GlitchDashCd", "Cooldown Dash (s)", 0.2, 4.0, 1.2, 1, function(v)
        GlitchModule.DashCooldown = v
    end)
    addSlider(gCard2, "GlitchDashSpd", "Velocidade Dash", 80, 800, 320, 0, function(v)
        GlitchModule.DashSpeed = v
    end)
    addSwitch(gCard2, "ScalePresetToggle", "Preset Escala (Restaura)", false, function(v)
        GlitchModule.ScalePresetEnabled = v
        if v then GlitchModule.SaveAndApplyScale() else GlitchModule.RestoreScale() end
    end)
    addSlider(gCard2, "ScaleMultSlider", "Escala Personagem", 0.5, 3.0, 1.65, 2, function(v)
        GlitchModule.ScaleMultiplier = v
        if GlitchModule.ScalePresetEnabled then GlitchModule.SaveAndApplyScale() end
    end)

    -- ABA: FONTE
    local fnCard1 = createCard(cFontL, "Seleciona Fontes")
    local availableFonts = FontSystem.RefreshFontList()
    addDropdown(fnCard1, "FontSelectDD", "Seleciona fontes", availableFonts, availableFonts[1], function(v)
        FontSystem.SelectedFont = v
        if FontSystem.Enabled then FontSystem.ApplyAll() end
    end)
    addSwitch(fnCard1, "FontChangerToggle", "Ativar Troca de Fonte", false, function(v)
        FontSystem.Enabled = v
        if v then FontSystem.ApplyAll() else FontSystem.RestoreAll() end
    end)
    local fnReloadBtn = addActionButton(fnCard1, "Atualizar Pasta", function()
        fnReloadBtn.Text = "Pasta OK"
        FontSystem.RefreshFontList()
    end)

    -- ABA: FLEASION
    local flCard1 = createCard(cFleaL, "Regras Fleasion (JSON)")
    local flJsonBox = Instance.new("TextBox")
    flJsonBox.Size = UDim2.new(1, 0, 0, 56)
    flJsonBox.BackgroundColor3 = Color3.fromRGB(30, 35, 48)
    flJsonBox.TextColor3 = Color3.fromRGB(220, 230, 245)
    flJsonBox.Font = Enum.Font.Code
    flJsonBox.TextSize = 10
    flJsonBox.MultiLine = true
    flJsonBox.Text = DEFAULT_FLEASION_JSON
    flJsonBox.Parent = flCard1
    Instance.new("UICorner", flJsonBox).CornerRadius = UDim.new(0, 6)

    local flApplyBtn = addActionButton(flCard1, "Aplicar Regras", function()
        FleasionModule.ParseJSON(flJsonBox.Text)
        local n = FleasionModule.ApplyRules()
        flApplyBtn.Text = tostring(n) .. " itens"
    end)

    selectTab("Flags")
end

createGUI()
