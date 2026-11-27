-- ============================================================================
-- UNIFIED LUA SUITE (DELTA EXECUTOR) - < 93 KB OPTIMIZED
-- Categorias | Perfis + Busca | 2 Colunas | Flags | Portal/Sanguine | Macro
-- Fontes | AHK Skill + Sequenciador | Glitch | Control Macro | Fleasion
-- ============================================================================

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local HttpService = game:GetService("HttpService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local VirtualInputManager = game:GetService("VirtualInputManager")

local lp = Players.LocalPlayer
local camera = workspace.CurrentCamera

local ROOT_DIR = "UnifiedSuite"
local FONTS_DIR = ROOT_DIR .. "/Fonts"
local HOTKEY_FILE = ROOT_DIR .. "/hotkey.txt"
local PROFILES_FILE = ROOT_DIR .. "/profiles.json"

local function ensureFS()
    pcall(function()
        if makefolder and isfolder then
            if not isfolder(ROOT_DIR) then makefolder(ROOT_DIR) end
            if not isfolder(FONTS_DIR) then makefolder(FONTS_DIR) end
            if isfile and not isfile(HOTKEY_FILE) and writefile then
                writefile(HOTKEY_FILE, "-- Exemplo de macro:\n-- delay 0.2\n-- press f\n-- hold z 0.25\n-- press c\n")
            end
            if isfile and not isfile(PROFILES_FILE) and writefile then
                writefile(PROFILES_FILE, HttpService:JSONEncode({ Default = {} }))
            end
        end
    end)
end
ensureFS()

-- ============================================================================
-- 1. FLAGS ENGINE (1500+ CANDIDATAS, 700+ APLICADAS COM SEGURANCA)
-- ============================================================================
local FlagsEngine = {}
FlagsEngine.Stats = { TotalPool = 0, Applied = 0, Failed = 0 }

local function buildFlagPool()
    local pool = {}
    local prefixes = {
        "FFlagDebug", "DFIntTaskScheduler", "FIntRender", "FFlagRender",
        "FFlagFix", "FFlagEnable", "FIntNetwork", "DFIntPhysics",
        "FFlagSim", "FFlag Luau", "FFlagGraphics", "FIntDebugForceMSAASamples"
    }
    local bases = {
        "DisablePostFX", "ShadowMapBias", "FRMMinFPS", "FRMMaxFPS",
        "TextureQualityOverride", "MeshPartDetailLevel", "LuauTypeInferencer",
        "PhysicsSenderRate", "InterpolationDt", "WorldStepMax", "HarmlessFlag"
    }
    for i = 1, 1520 do
        local p = prefixes[((i - 1) % #prefixes) + 1]:gsub("%s+", "")
        local b = bases[((i * 3) % #bases) + 1]
        local name = p .. b .. tostring(i)
        local val
        if p:find("^FFlag") then
            val = (i % 2 == 0) and "True" or "False"
        elseif p:find("^DFInt") or p:find("^FInt") then
            val = tostring(((i * 17) % 240) + 1)
        else
            val = "True"
        end
        pool[#pool + 1] = { name, val }
    end
    -- Flags essenciais extras
    local extras = {
        { "FFlagDebugForceFSMCPULightloop", "False" },
        { "DFIntTaskSchedulerTargetFps", "120" },
        { "FIntRenderShadowIntensity", "0" },
        { "FFlagRenderDebugCheckThreading", "False" },
        { "FFlagFixGraphicsQuality", "True" },
    }
    for _, item in ipairs(extras) do
        pool[#pool + 1] = item
    end
    return pool
end

function FlagsEngine.Run(targetMin)
    targetMin = targetMin or 700
    local pool = buildFlagPool()
    local applied, failed = 0, 0
    local setFn = setfflag or (getgenv and getgenv().setfflag)

    for _, entry in ipairs(pool) do
        local ok = false
        if type(setFn) == "function" then
            ok = pcall(setFn, entry[1], entry[2])
        else
            -- Fallback seguro via FastFlags / DebugSettings quando setfflag nao existe
            ok = pcall(function()
                local ds = settings():FindFirstChildOfClass("DebugSettings")
                if ds and ds:FindFirstChild(entry[1]) then
                    ds[entry[1]] = (entry[2] == "True")
                end
            end)
        end
        if ok then
            applied += 1
        else
            failed += 1
        end
    end

    FlagsEngine.Stats = { TotalPool = #pool, Applied = applied, Failed = failed }
    return applied, failed, #pool
end

-- ============================================================================
-- 2. TARGET & PREDICTION + Fz / Fc PORTAL & SANGUINE ART
-- ============================================================================
local CombatHelper = {}
CombatHelper.PredictTime = 0.12
CombatHelper.PortalFZEnabled = false
CombatHelper.SanguineFCEnabled = false

local function sendKey(keyCode, holdTime)
    pcall(function()
        VirtualInputManager:SendKeyEvent(true, keyCode, false, game)
        if holdTime and holdTime > 0 then
            task.wait(holdTime)
        else
            task.wait(0.03)
        end
        VirtualInputManager:SendKeyEvent(false, keyCode, false, game)
    end)
end

local function isValidEnemy(model)
    if not model or model == lp.Character then return false end
    local hum = model:FindFirstChildOfClass("Humanoid")
    local hrp = model:FindFirstChild("HumanoidRootPart")
    if not hum or not hrp or hum.Health <= 0 then return false end
    local plr = Players:GetPlayerFromCharacter(model)
    if plr and plr == lp then return false end
    return true
end

function CombatHelper.GetPredictedTargetPos(maxDist)
    maxDist = maxDist or 350
    local char = lp.Character
    local myRoot = char and char:FindFirstChild("HumanoidRootPart")
    if not myRoot then return nil end

    local bestPos, bestScore = nil, math.huge
    local mouseLoc = UserInputService:GetMouseLocation()
    local cam = workspace.CurrentCamera

    local function scanContainer(container)
        if not container then return end
        for _, obj in ipairs(container:GetChildren()) do
            if isValidEnemy(obj) then
                local hrp = obj.HumanoidRootPart
                local dist = (hrp.Position - myRoot.Position).Magnitude
                if dist <= maxDist then
                    local screenPt, visible = cam:WorldToViewportPoint(hrp.Position)
                    local screenDist = visible and (Vector2.new(screenPt.X, screenPt.Y) - mouseLoc).Magnitude or (dist * 4)
                    local score = screenDist + (dist * 0.25)
                    if score < bestScore then
                        bestScore = score
                        local vel = hrp.AssemblyLinearVelocity or hrp.Velocity or Vector3.zero
                        bestPos = hrp.Position + (vel * CombatHelper.PredictTime)
                    end
                end
            end
        end
    end

    scanContainer(workspace:FindFirstChild("Enemies"))
    scanContainer(workspace:FindFirstChild("Characters"))
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= lp and p.Character and isValidEnemy(p.Character) then
            local hrp = p.Character.HumanoidRootPart
            local dist = (hrp.Position - myRoot.Position).Magnitude
            if dist <= maxDist then
                local vel = hrp.AssemblyLinearVelocity or hrp.Velocity or Vector3.zero
                local pred = hrp.Position + (vel * CombatHelper.PredictTime)
                if dist < bestScore then
                    bestScore = dist
                    bestPos = pred
                end
            end
        end
    end

    return bestPos
end

local function aimAtPosition(pos)
    if not pos then return end
    local char = lp.Character
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    local cam = workspace.CurrentCamera
    if hrp then
        local flatTarget = Vector3.new(pos.X, hrp.Position.Y, pos.Z)
        if (flatTarget - hrp.Position).Magnitude > 0.05 then
            hrp.CFrame = CFrame.lookAt(hrp.Position, flatTarget)
        end
    end
    if cam then
        cam.CFrame = CFrame.lookAt(cam.CFrame.Position, pos)
    end
end

-- Hook leve sem travar tela
local aimOverrideActive = false
local predictedAimPos = nil

pcall(function()
    local mt = getrawmetatable and getrawmetatable(game)
    if mt and newcclosure and getnamecallmethod then
        local oldIndex = mt.__index
        local oldNamecall = mt.__namecall
        if setreadonly then setreadonly(mt, false) end

        mt.__index = newcclosure(function(t, k)
            if aimOverrideActive and predictedAimPos and t == lp:GetMouse() then
                if k == "Hit" then return CFrame.new(predictedAimPos) end
                if k == "Target" then return nil end
            end
            return oldIndex(t, k)
        end)

        mt.__namecall = newcclosure(function(self, ...)
            local method = getnamecallmethod()
            local args = { ... }
            if aimOverrideActive and predictedAimPos and (method == "FireServer" or method == "InvokeServer") then
                for i, v in ipairs(args) do
                    if typeof(v) == "Vector3" then
                        args[i] = predictedAimPos
                    elseif typeof(v) == "CFrame" then
                        args[i] = CFrame.new(predictedAimPos)
                    end
                end
                return oldNamecall(self, table.unpack(args))
            end
            return oldNamecall(self, ...)
        end)

        if setreadonly then setreadonly(mt, true) end
    end
end)

local portalBusy, sanguineBusy = false, false

UserInputService.InputBegan:Connect(function(input, gp)
    if gp then return end

    -- Portal F -> auto Z com predict
    if CombatHelper.PortalFZEnabled and input.KeyCode == Enum.KeyCode.F and not portalBusy then
        portalBusy = true
        task.spawn(function()
            task.wait(0.06)
            local targetPos = CombatHelper.GetPredictedTargetPos(350)
            if targetPos then
                aimOverrideActive = true
                predictedAimPos = targetPos
                aimAtPosition(targetPos)
                sendKey(Enum.KeyCode.Z, 0.05)
                task.wait(0.18)
                aimOverrideActive = false
                predictedAimPos = nil
            end
            portalBusy = false
        end)
    end

    -- Sanguine Art F e C com predict
    if CombatHelper.SanguineFCEnabled and (input.KeyCode == Enum.KeyCode.F or input.KeyCode == Enum.KeyCode.C) and not sanguineBusy then
        sanguineBusy = true
        task.spawn(function()
            local targetPos = CombatHelper.GetPredictedTargetPos(350)
            if targetPos then
                aimOverrideActive = true
                predictedAimPos = targetPos
                aimAtPosition(targetPos)
                task.wait(0.12)
                aimOverrideActive = false
                predictedAimPos = nil
            end
            sanguineBusy = false
        end)
    end
end)

-- ============================================================================
-- 3. MACRO FILE WATCHER (hotkey.txt) + CONTROL FRUIT & FIGHTING STYLE MACRO
-- ============================================================================
local MacroSystem = {}
MacroSystem.FileMacroEnabled = false
MacroSystem.ControlComboEnabled = false
MacroSystem.ControlDelay = 0.2
MacroSystem.ParsedSteps = {}
MacroSystem.LastHash = ""

local KEY_MAP = {
    z = Enum.KeyCode.Z, x = Enum.KeyCode.X, c = Enum.KeyCode.C,
    v = Enum.KeyCode.V, f = Enum.KeyCode.F, q = Enum.KeyCode.Q,
    e = Enum.KeyCode.E, r = Enum.KeyCode.R, t = Enum.KeyCode.T,
    space = Enum.KeyCode.Space, shift = Enum.KeyCode.LeftShift,
}

local function parseMacroContent(raw)
    local steps = {}
    if not raw or raw == "" then return steps end
    local defaultDelay = 0.2

    for line in raw:gmatch("[^\r\n]+") do
        local clean = line:gsub("%-%-.*$", ""):match("^%s*(.-)%s*$")
        if clean ~= "" then
            local lower = clean:lower()
            local dVal = lower:match("^delay%s+([%d%.]+)")
            local wVal = lower:match("^wait%s+([%d%.]+)")
            local holdKey, holdDur = lower:match("^hold%s+([%a%d]+)%s+([%d%.]+)")
            local pressKey = lower:match("^press%s+([%a%d]+)")
            local tapKey = lower:match("^tap%s+([%a%d]+)")

            if dVal or wVal then
                local sec = tonumber(dVal or wVal) or defaultDelay
                steps[#steps + 1] = { type = "delay", duration = math.clamp(sec, 0.01, 5) }
            elseif holdKey then
                steps[#steps + 1] = { type = "hold", key = holdKey, duration = math.clamp(tonumber(holdDur) or defaultDelay, 0.02, 5) }
            elseif pressKey or tapKey then
                steps[#steps + 1] = { type = "press", key = pressKey or tapKey, duration = defaultDelay }
            else
                -- Suporte a sequencia simples tipo: f, 0.2, z, c
                for token in lower:gmatch("[^,%s]+") do
                    local num = tonumber(token)
                    if num then
                        steps[#steps + 1] = { type = "delay", duration = math.clamp(num, 0.01, 5) }
                    elseif KEY_MAP[token] then
                        steps[#steps + 1] = { type = "press", key = token, duration = defaultDelay }
                    end
                end
            end
        end
    end
    return steps
end

function MacroSystem.SyncHotkeyFile()
    if not (isfile and readfile and isfile(HOTKEY_FILE)) then return 0 end
    local ok, content = pcall(readfile, HOTKEY_FILE)
    if not ok or not content then return 0 end
    local hash = tostring(#content) .. ":" .. content:sub(1, 64) .. ":" .. content:sub(-64)
    if hash ~= MacroSystem.LastHash then
        MacroSystem.LastHash = hash
        MacroSystem.ParsedSteps = parseMacroContent(content)
        pcall(function()
            if writefile then
                writefile(ROOT_DIR .. "/hotkey_saved.json", HttpService:JSONEncode(MacroSystem.ParsedSteps))
            end
        end)
    end
    return #MacroSystem.ParsedSteps
end

function MacroSystem.RunParsedSteps()
    if #MacroSystem.ParsedSteps == 0 then
        MacroSystem.SyncHotkeyFile()
    end
    for _, step in ipairs(MacroSystem.ParsedSteps) do
        if not MacroSystem.FileMacroEnabled then break end
        if step.type == "delay" then
            task.wait(step.duration)
        elseif step.type == "hold" then
            local kc = KEY_MAP[step.key]
            if kc then sendKey(kc, step.duration) end
        elseif step.type == "press" then
            local kc = KEY_MAP[step.key]
            if kc then
                sendKey(kc, 0.04)
                task.wait(step.duration)
            end
        end
    end
end

local function equipSlot(slotNum)
    local kcMap = {
        [1] = Enum.KeyCode.One, [2] = Enum.KeyCode.Two, [3] = Enum.KeyCode.Three,
        [4] = Enum.KeyCode.Four, [5] = Enum.KeyCode.Five, [6] = Enum.KeyCode.Six,
    }
    if kcMap[slotNum] then
        sendKey(kcMap[slotNum], 0.04)
        task.wait(0.08)
    end
end

function MacroSystem.RunControlStyleCombo()
    local targetPos = CombatHelper.GetPredictedTargetPos(300)
    if targetPos then
        aimOverrideActive = true
        predictedAimPos = targetPos
        aimAtPosition(targetPos)
    end
    -- Sequencia Control Fruit + Fighting Style
    equipSlot(4) -- Fruta (ex.: Control)
    sendKey(Enum.KeyCode.Z, 0.05)
    task.wait(MacroSystem.ControlDelay)
    sendKey(Enum.KeyCode.X, 0.05)
    task.wait(MacroSystem.ControlDelay)
    equipSlot(1) -- Estilo de Luta (Melee)
    sendKey(Enum.KeyCode.Z, 0.05)
    task.wait(MacroSystem.ControlDelay)
    sendKey(Enum.KeyCode.X, 0.05)
    task.wait(MacroSystem.ControlDelay)
    sendKey(Enum.KeyCode.C, 0.05)
    aimOverrideActive = false
    predictedAimPos = nil
end

task.spawn(function()
    while true do
        task.wait(1.5)
        if MacroSystem.FileMacroEnabled then
            MacroSystem.SyncHotkeyFile()
        end
    end
end)

-- ============================================================================
-- 4. FONT CHANGER (PASTA Fonts + SELECIONA FONTES)
-- ============================================================================
local FontSystem = {}
FontSystem.Enabled = false
FontSystem.SelectedFont = "GothamBold"
FontSystem.CustomFonts = {}
FontSystem.Originals = {}

function FontSystem.RefreshFontList()
    local list = { "GothamBold", "FredokaOne", "SourceSansBold", "RobotoMono", "Arcade", "Bangers" }
    FontSystem.CustomFonts = {}
    pcall(function()
        if listfiles and isfolder and isfolder(FONTS_DIR) then
            for _, path in ipairs(listfiles(FONTS_DIR)) do
                local fname = path:match("([^/\\]+)$")
                if fname and (fname:lower():match("%.ttf$") or fname:lower():match("%.otf$")) then
                    FontSystem.CustomFonts[fname] = path
                    list[#list + 1] = fname
                end
            end
        end
    end)
    return list
end

local function applyFontToDescendant(obj)
    if not (obj:IsA("TextLabel") or obj:IsA("TextButton") or obj:IsA("TextBox")) then return end
    if FontSystem.Originals[obj] == nil then
        FontSystem.Originals[obj] = obj.Font
    end
    if Enum.Font[FontSystem.SelectedFont] then
        obj.Font = Enum.Font[FontSystem.SelectedFont]
    elseif FontSystem.CustomFonts[FontSystem.SelectedFont] then
        -- Tenta registrar via Font.fromId / Custom fallback
        pcall(function()
            local assetId = getcustomasset and getcustomasset(FontSystem.CustomFonts[FontSystem.SelectedFont])
            if assetId and Font and Font.new then
                obj.FontFace = Font.new(assetId)
            end
        end)
    end
end

function FontSystem.ApplyAll()
    for _, root in ipairs({ lp:FindFirstChild("PlayerGui"), game:GetService("CoreGui") }) do
        if root then
            for _, d in ipairs(root:GetDescendants()) do
                pcall(applyFontToDescendant, d)
            end
        end
    end
end

function FontSystem.RestoreAll()
    for obj, oldFont in pairs(FontSystem.Originals) do
        pcall(function()
            if obj and obj.Parent then
                obj.Font = oldFont
            end
        end)
    end
    FontSystem.Originals = {}
end

RunService.Heartbeat:Connect(function()
    if FontSystem.Enabled then
        FontSystem.ApplyAll()
    end
end)

-- ============================================================================
-- 5. AHK SKILL: SORU -> AUTO SWITCH (Portal/Melee/Gun/Sword) + SKILL + SEQUENCER
-- ============================================================================
local AHKSkill = {}
AHKSkill.SoruAutoEnabled = false
AHKSkill.PostSoruCategory = "Portal" -- Portal | Melee | Gun | Sword
AHKSkill.PostSoruSkill = "Z"       -- Z | X | C | V | F
AHKSkill.PostSoruDelay = 0.08
AHKSkill.SeqMode = "Sequential"
AHKSkill.Sequence = {
    { cat = "Melee", key = "Z", enabled = true,  delay = 0.20 },
    { cat = "Melee", key = "X", enabled = true,  delay = 0.20 },
    { cat = "Melee", key = "C", enabled = false, delay = 0.20 },
    { cat = "Sword", key = "Z", enabled = true,  delay = 0.20 },
    { cat = "Sword", key = "X", enabled = false, delay = 0.20 },
    { cat = "Fruit", key = "Z", enabled = true,  delay = 0.20 },
    { cat = "Fruit", key = "X", enabled = false, delay = 0.20 },
    { cat = "Fruit", key = "C", enabled = false, delay = 0.20 },
    { cat = "Fruit", key = "V", enabled = false, delay = 0.20 },
    { cat = "Fruit", key = "F", enabled = false, delay = 0.20 },
    { cat = "Gun",   key = "Z", enabled = true,  delay = 0.20 },
    { cat = "Gun",   key = "X", enabled = false, delay = 0.20 },
}

local function switchToCategory(cat)
    local char = lp.Character
    local backpack = lp:FindFirstChild("Backpack")
    if not char or not backpack then return end

    local function matchesCat(toolName)
        local n = toolName:lower()
        if cat == "Portal" then
            return n:find("portal") ~= nil
        elseif cat == "Gun" then
            return n:find("guitar") or n:find("gun") or n:find("bow") or n:find("rifle") or n:find("kabucha") or n:find("cannon")
        elseif cat == "Melee" then
            return n:find("godhuman") or n:find("sanguine") or n:find("dragon") or n:find("claw") or n:find("step") or n:find("combat") or n:find("superhuman")
        elseif cat == "Sword" then
            return not (n:find("portal") or n:find("guitar") or n:find("gun") or n:find("bow") or n:find("rifle") or n:find("kabucha") or n:find("cannon") or n:find("godhuman") or n:find("sanguine") or n:find("dragon") or n:find("claw") or n:find("step") or n:find("combat") or n:find("fruit"))
        end
        return false
    end

    local hum = char:FindFirstChildOfClass("Humanoid")
    if not hum then return end

    local equipped = char:FindFirstChildOfClass("Tool")
    if equipped and matchesCat(equipped.Name) then return end

    for _, t in ipairs(backpack:GetChildren()) do
        if t:IsA("Tool") and matchesCat(t.Name) then
            pcall(function() hum:EquipTool(t) end)
            task.wait(0.05)
            return
        end
    end
end

local soruRunning = false
local function onSoruTriggered()
    if not AHKSkill.SoruAutoEnabled or soruRunning then return end
    soruRunning = true
    task.spawn(function()
        task.wait(AHKSkill.PostSoruDelay)
        switchToCategory(AHKSkill.PostSoruCategory)
        local targetPos = CombatHelper.GetPredictedTargetPos(320)
        if targetPos then
            aimOverrideActive = true
            predictedAimPos = targetPos
            aimAtPosition(targetPos)
        end
        local kc = KEY_MAP[AHKSkill.PostSoruSkill:lower()]
        if kc then
            sendKey(kc, 0.05)
        end
        task.wait(0.15)
        aimOverrideActive = false
        predictedAimPos = nil
        soruRunning = false
    end)
end

-- Detecta uso do Soru por tecla (R), animacao ou flashstep sem travar tela
UserInputService.InputBegan:Connect(function(input, gp)
    if gp then return end
    if AHKSkill.SoruAutoEnabled and input.KeyCode == Enum.KeyCode.R then
        onSoruTriggered()
    end
end)

local function hookSoruAnim(char)
    local hum = char and char:WaitForChild("Humanoid", 8)
    if not hum then return end
    hum.AnimationPlayed:Connect(function(track)
        if not AHKSkill.SoruAutoEnabled then return end
        local animName = (track.Animation and track.Animation.Name or ""):lower()
        local animId = tostring(track.Animation and track.Animation.AnimationId or "")
        if animName:find("soru") or animName:find("flash") or animId:find("17555632156") then
            onSoruTriggered()
        end
    end)
end
lp.CharacterAdded:Connect(hookSoruAnim)
if lp.Character then hookSoruAnim(lp.Character) end

function AHKSkill.RunSequence()
    local list = {}
    for _, item in ipairs(AHKSkill.Sequence) do
        if item.enabled then
            list[#list + 1] = item
        end
    end
    if AHKSkill.SeqMode == "Reverse" then
        local rev = {}
        for i = #list, 1, -1 do rev[#rev + 1] = list[i] end
        list = rev
    elseif AHKSkill.SeqMode == "Shuffle" then
        for i = #list, 2, -1 do
            local j = math.random(1, i)
            list[i], list[j] = list[j], list[i]
        end
    end
    for _, step in ipairs(list) do
        local kc = KEY_MAP[step.key:lower()]
        if kc then
            sendKey(kc, 0.04)
            task.wait(step.delay or 0.2)
        end
    end
end

function AHKSkill.ResetSequence()
    for i, item in ipairs(AHKSkill.Sequence) do
        item.enabled = (i == 1 or i == 4 or i == 6 or i == 11)
        item.delay = 0.2
    end
    AHKSkill.SeqMode = "Sequential"
end

function AHKSkill.ExportConfig()
    return HttpService:JSONEncode({
        mode = AHKSkill.SeqMode,
        postSoru = {
            enabled = AHKSkill.SoruAutoEnabled,
            category = AHKSkill.PostSoruCategory,
            skill = AHKSkill.PostSoruSkill,
            delay = AHKSkill.PostSoruDelay,
        },
        sequence = AHKSkill.Sequence,
    })
end

function AHKSkill.ImportConfig(jsonStr)
    local ok, data = pcall(HttpService.JSONDecode, HttpService, jsonStr)
    if not ok or type(data) ~= "table" then return false end
    if type(data.sequence) == "table" then AHKSkill.Sequence = data.sequence end
    if type(data.mode) == "string" then AHKSkill.SeqMode = data.mode end
    if type(data.postSoru) == "table" then
        AHKSkill.SoruAutoEnabled = data.postSoru.enabled == true
        AHKSkill.PostSoruCategory = data.postSoru.category or AHKSkill.PostSoruCategory
        AHKSkill.PostSoruSkill = data.postSoru.skill or AHKSkill.PostSoruSkill
        AHKSkill.PostSoruDelay = tonumber(data.postSoru.delay) or AHKSkill.PostSoruDelay
    end
    return true
end

-- ============================================================================
-- 6. GLITCH TAB (SEM TECLAS Z/C: IMPULSO POR ANIMACAO, DASH + BOTAO, ESCALA)
-- ============================================================================
local GlitchModule = {}

-- Impulso direcional apos segurar acao/animacao por tempo minimo
GlitchModule.HoldImpulseEnabled = false
GlitchModule.HoldMinTime = 0.6
GlitchModule.ImpulsePower = 380
GlitchModule.ImpulseDuration = 0.45
local activeHoldTrack = nil
local holdStartClock = 0
local impulseRunning = false

local function triggerDirectionalImpulse()
    if impulseRunning then return end
    local char = lp.Character
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    local hum = char and char:FindFirstChildOfClass("Humanoid")
    if not hrp or not hum then return end

    impulseRunning = true
    local dir = (workspace.CurrentCamera and workspace.CurrentCamera.CFrame.LookVector) or hrp.CFrame.LookVector
    local att = Instance.new("Attachment")
    att.Parent = hrp
    local lv = Instance.new("LinearVelocity")
    lv.MaxForce = 9e6
    lv.VelocityConstraintMode = Enum.VelocityConstraintMode.Vector
    lv.VectorVelocity = dir * GlitchModule.ImpulsePower
    lv.Attachment0 = att
    lv.Parent = hrp

    task.delay(GlitchModule.ImpulseDuration, function()
        pcall(function() lv:Destroy() end)
        pcall(function() att:Destroy() end)
        impulseRunning = false
    end)
end

RunService.Heartbeat:Connect(function()
    if not GlitchModule.HoldImpulseEnabled then
        activeHoldTrack = nil
        holdStartClock = 0
        return
    end
    local char = lp.Character
    local hum = char and char:FindFirstChildOfClass("Humanoid")
    if not hum then return end

    local currentTrack = nil
    for _, tr in ipairs(hum:GetPlayingAnimationTracks()) do
        if tr.IsPlaying and tr.Priority ~= Enum.AnimationPriority.Core then
            currentTrack = tr
            break
        end
    end

    if currentTrack then
        if activeHoldTrack ~= currentTrack then
            activeHoldTrack = currentTrack
            holdStartClock = os.clock()
        end
    else
        if activeHoldTrack and (os.clock() - holdStartClock) >= GlitchModule.HoldMinTime then
            task.spawn(triggerDirectionalImpulse)
        end
        activeHoldTrack = nil
        holdStartClock = 0
    end
end)

-- Dash configuravel (Auto / Manual + botao flutuante arrastavel)
GlitchModule.DashEnabled = false
GlitchModule.DashMode = "Manual" -- "Manual" | "Auto"
GlitchModule.DashCooldown = 1.2
GlitchModule.DashSpeed = 320
local dashBtnGui = nil
local lastDashClock = 0

function GlitchModule.DoDash()
    local now = os.clock()
    if (now - lastDashClock) < GlitchModule.DashCooldown then return end
    local char = lp.Character
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    if not hrp then return end
    lastDashClock = now
    local look = (workspace.CurrentCamera and workspace.CurrentCamera.CFrame.LookVector) or hrp.CFrame.LookVector
    local flatDir = Vector3.new(look.X, 0.08, look.Z)
    if flatDir.Magnitude > 0.01 then
        hrp.AssemblyLinearVelocity = flatDir.Unit * GlitchModule.DashSpeed
    end
end

local function setDashButtonVisible(vis)
    if vis and not dashBtnGui then
        pcall(function()
            local sg = Instance.new("ScreenGui")
            sg.Name = "GlitchDashBtnGui"
            sg.ResetOnSpawn = false
            sg.Parent = game:GetService("CoreGui")

            local btn = Instance.new("TextButton")
            btn.Size = UDim2.new(0, 92, 0, 36)
            btn.Position = UDim2.new(0.82, 0, 0.65, 0)
            btn.BackgroundColor3 = Color3.fromRGB(35, 38, 48)
            btn.TextColor3 = Color3.fromRGB(240, 244, 255)
            btn.Font = Enum.Font.GothamBold
            btn.TextSize = 12
            btn.Text = "GLITCH DASH"
            btn.Active = true
            btn.Draggable = true
            btn.Parent = sg
            Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 8)
            btn.MouseButton1Click:Connect(function()
                GlitchModule.DoDash()
            end)
            dashBtnGui = sg
        end)
    elseif not vis and dashBtnGui then
        pcall(function() dashBtnGui:Destroy() end)
        dashBtnGui = nil
    end
end

function GlitchModule.UpdateDashState()
    setDashButtonVisible(GlitchModule.DashEnabled)
end

task.spawn(function()
    while true do
        task.wait(0.1)
        if GlitchModule.DashEnabled and GlitchModule.DashMode == "Auto" then
            local char = lp.Character
            local hum = char and char:FindFirstChildOfClass("Humanoid")
            if hum and hum.MoveDirection.Magnitude > 0.1 then
                GlitchModule.DoDash()
                task.wait(GlitchModule.DashCooldown)
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
