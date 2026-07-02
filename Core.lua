-- QuickFocus core: binding, attribute hooking, events, options.
-- Modules call QuickFocus:HookFrame() and QuickFocus:HookChildren().

local QF = CreateFrame("Frame", "QuickFocus", UIParent)

-- ── Module Registry ────────────────────────────────────────────────────

QF.modules = {}

--- Register a unit-frame module.
-- @param name     Display name (e.g. "ElvUI")
-- @param hookFunc Called on every re-hook pass. Signature: hookFunc()
function QF:RegisterModule(name, hookFunc)
    self.modules[#self.modules + 1] = { name = name, hook = hookFunc }
end

-- ── Defaults & DB ──────────────────────────────────────────────────────

local DEFAULTS = {
    enable = true,
    modifier = "shift",
    button = "BUTTON1",
    setMark = false,
    safeMark = false,
    markNumber = 3,
}

local pending = {}
local button

local function InitDB()
    if not QuickFocusDB then QuickFocusDB = {} end
    for k, v in pairs(DEFAULTS) do
        if QuickFocusDB[k] == nil then QuickFocusDB[k] = v end
    end
end

-- ── Macro & Binding ────────────────────────────────────────────────────

local function GetMacroText(db)
    local lines = { "/focus mouseover" }
    if db.setMark and db.markNumber and db.markNumber >= 1 and db.markNumber <= 8 then
        local markArg = "~" .. db.markNumber
        if db.safeMark then
            lines[#lines + 1] = "/tm [@focus,exists,help][@focus,exists,harm] " .. markArg
        else
            lines[#lines + 1] = "/tm [@focus,exists] " .. markArg
        end
    end
    return table.concat(lines, "\n")
end

local function UpdateBinding()
    if not button then return end
    local db = QuickFocusDB
    button:SetAttribute("macrotext", GetMacroText(db))
    ClearOverrideBindings(button)
    SetOverrideBindingClick(button, true, db.modifier .. "-" .. db.button, "QuickFocusButton")
end

-- ── Public API for modules ─────────────────────────────────────────────

--- Set the focus attribute on a single frame.
function QF:HookFrame(frame)
    if not frame or frame.quickFocusHooked then return end
    local db = QuickFocusDB
    if not InCombatLockdown() then
        frame:SetAttribute(db.modifier .. "-type" .. strsub(db.button, 7, 7), "focus")
        frame.quickFocusHooked = true
        pending[frame] = nil
    else
        pending[frame] = true
    end
end

--- Walk a frame's children recursively and hook any frame with a "unit" attr.
function QF:HookChildren(frame)
    if not frame then return end
    if frame.GetAttribute and frame:GetAttribute("unit") then
        self:HookFrame(frame)
    end
    if frame.GetNumChildren then
        for i = 1, frame:GetNumChildren() do
            self:HookChildren(select(i, frame:GetChildren()))
        end
    end
end

--- Hook a named global frame (looks up via _G).
function QF:HookByName(name)
    local f = _G[name]
    if f then self:HookFrame(f) end
end

--- Hook the children of a named global frame.
function QF:HookChildrenByName(name)
    local f = _G[name]
    if f then self:HookChildren(f) end
end

-- ── Master Hook (runs all modules) ─────────────────────────────────────

local function HookAllFrames()
    for _, mod in ipairs(QF.modules) do
        pcall(mod.hook)
    end
end

-- ── Slash Commands ─────────────────────────────────────────────────────

local function Print(msg)
    print("|cFF00CCFFQuickFocus|r: " .. msg)
end

SLASH_QUICKFOCUS1 = "/qf"
SLASH_QUICKFOCUS2 = "/quickfocus"
SlashCmdList["QUICKFOCUS"] = function(msg)
    msg = strtrim(msg or ""):lower()
    if msg == "toggle" then
        QuickFocusDB.enable = not QuickFocusDB.enable
        if QuickFocusDB.enable then
            UpdateBinding()
            Print("Enabled")
        else
            if button then ClearOverrideBindings(button) end
            Print("Disabled")
        end
    elseif msg == "help" or msg == "" then
        Print("Commands:")
        print("  /qf toggle - Enable/Disable")
        print("  /qf config - Open settings")
        print("  /qf status - Show current settings")
    elseif msg == "status" then
        local db = QuickFocusDB
        Print("Status:")
        print("  Enabled: " .. tostring(db.enable))
        print("  Modifier: " .. db.modifier)
        print("  Button: " .. db.button)
        print("  Set Mark: " .. tostring(db.setMark))
        if db.setMark then
            print("  Mark: " .. db.markNumber)
            print("  Safe Mark: " .. tostring(db.safeMark))
        end
    elseif msg == "config" then
        if QF.category and Settings and Settings.OpenToCategory then
            local id = QF.category:GetID()
            if id then Settings.OpenToCategory(id) end
        elseif InterfaceOptionsFrame_OpenToCategory then
            InterfaceOptionsFrame_OpenToCategory("QuickFocus")
        end
    else
        Print("Unknown command. Type /qf help")
    end
end

-- ── Events ─────────────────────────────────────────────────────────────

local events = CreateFrame("Frame")
events:RegisterEvent("PLAYER_LOGIN")
events:RegisterEvent("PLAYER_ENTERING_WORLD")
events:RegisterEvent("PLAYER_REGEN_ENABLED")
events:RegisterEvent("ADDON_LOADED")

events:SetScript("OnEvent", function(self, event, arg1)
    if event == "ADDON_LOADED" and arg1 == "QuickFocus" then
        InitDB()
    elseif event == "PLAYER_LOGIN" then
        button = CreateFrame("Button", "QuickFocusButton", UIParent, "SecureActionButtonTemplate")
        button:SetAttribute("type*", "macro")
        button:SetAttribute("macrotext", GetMacroText(QuickFocusDB))
        button:RegisterForClicks("AnyDown", "AnyUp")

        if QuickFocusDB.enable then
            UpdateBinding()
        end

        local rehook = CreateFrame("Frame")
        rehook:RegisterEvent("ZONE_CHANGED_NEW_AREA")
        rehook:RegisterEvent("GROUP_ROSTER_UPDATE")
        rehook:SetScript("OnEvent", function()
            HookAllFrames()
            C_Timer.After(1, HookAllFrames)
        end)
    elseif event == "PLAYER_ENTERING_WORLD" then
        HookAllFrames()
        C_Timer.After(2, HookAllFrames)
    elseif event == "PLAYER_REGEN_ENABLED" then
        if next(pending) then
            for frame in next, pending do
                QF:HookFrame(frame)
            end
        end
    end
end)

-- ── Options Panel ──────────────────────────────────────────────────────

local optionsPanel = CreateFrame("Frame", "QuickFocusOptions", UIParent)
optionsPanel.name = "QuickFocus"

local title = optionsPanel:CreateFontString(nil, "ARTWORK", "GameFontNormalLarge")
title:SetPoint("TOPLEFT", 16, -16)
title:SetText("QuickFocus")

local subtitle = optionsPanel:CreateFontString(nil, "ARTWORK", "GameFontHighlight")
subtitle:SetPoint("TOPLEFT", title, "BOTTOMLEFT", 0, -8)
subtitle:SetText("Modifier + Click on any unit frame to set focus.")

local enableCheck = CreateFrame("CheckButton", "QuickFocusEnableCheck", optionsPanel, "InterfaceOptionsCheckButtonTemplate")
enableCheck:SetPoint("TOPLEFT", subtitle, "BOTTOMLEFT", 0, -16)
enableCheck.Text:SetText("Enable QuickFocus")
enableCheck:SetScript("OnClick", function(self)
    QuickFocusDB.enable = self:GetChecked()
    if QuickFocusDB.enable then UpdateBinding()
    elseif button then ClearOverrideBindings(button) end
end)

local modifierLabel = optionsPanel:CreateFontString(nil, "ARTWORK", "GameFontHighlight")
modifierLabel:SetPoint("TOPLEFT", enableCheck, "BOTTOMLEFT", 4, -16)
modifierLabel:SetText("Modifier Key:")

local modifierDropdown = CreateFrame("Frame", "QuickFocusModifierDropdown", optionsPanel, "UIDropDownMenuTemplate")
modifierDropdown:SetPoint("TOPLEFT", modifierLabel, "BOTTOMLEFT", -16, -8)

local modifierValues = { "shift", "ctrl", "alt" }
local modifierLabels = { "Shift", "Ctrl", "Alt" }

UIDropDownMenu_SetWidth(modifierDropdown, 120)
UIDropDownMenu_SetInitializeFunction(modifierDropdown, function()
    for i, val in ipairs(modifierValues) do
        local info = UIDropDownMenu_CreateInfo()
        info.text = modifierLabels[i]
        info.arg1 = val
        info.func = function(_, arg1)
            QuickFocusDB.modifier = arg1
            UIDropDownMenu_SetText(modifierDropdown, modifierLabels[i])
            UpdateBinding()
        end
        info.checked = QuickFocusDB.modifier == val
        UIDropDownMenu_AddButton(info)
    end
end)

local buttonLabel = optionsPanel:CreateFontString(nil, "ARTWORK", "GameFontHighlight")
buttonLabel:SetPoint("TOPLEFT", modifierDropdown, "BOTTOMLEFT", 16, -8)
buttonLabel:SetText("Mouse Button:")

local buttonDropdown = CreateFrame("Frame", "QuickFocusButtonDropdown", optionsPanel, "UIDropDownMenuTemplate")
buttonDropdown:SetPoint("TOPLEFT", buttonLabel, "BOTTOMLEFT", -16, -8)

local buttonValues = { "BUTTON1", "BUTTON2", "BUTTON3", "BUTTON4", "BUTTON5" }
local buttonLabels = { "Left", "Right", "Middle", "Side 4", "Side 5" }

UIDropDownMenu_SetWidth(buttonDropdown, 120)
UIDropDownMenu_SetInitializeFunction(buttonDropdown, function()
    for i, val in ipairs(buttonValues) do
        local info = UIDropDownMenu_CreateInfo()
        info.text = buttonLabels[i]
        info.arg1 = val
        info.func = function(_, arg1)
            QuickFocusDB.button = arg1
            UIDropDownMenu_SetText(buttonDropdown, buttonLabels[i])
            UpdateBinding()
        end
        info.checked = QuickFocusDB.button == val
        UIDropDownMenu_AddButton(info)
    end
end)

local setMarkCheck = CreateFrame("CheckButton", "QuickFocusSetMarkCheck", optionsPanel, "InterfaceOptionsCheckButtonTemplate")
setMarkCheck:SetPoint("TOPLEFT", buttonDropdown, "BOTTOMLEFT", 16, -16)
setMarkCheck.Text:SetText("Set Raid Marker on Focus")
setMarkCheck:SetScript("OnClick", function(self)
    QuickFocusDB.setMark = self:GetChecked()
    UpdateBinding()
end)

local markLabel = optionsPanel:CreateFontString(nil, "ARTWORK", "GameFontHighlight")
markLabel:SetPoint("TOPLEFT", setMarkCheck, "BOTTOMLEFT", 4, -8)
markLabel:SetText("Marker:")

local markDropdown = CreateFrame("Frame", "QuickFocusMarkDropdown", optionsPanel, "UIDropDownMenuTemplate")
markDropdown:SetPoint("TOPLEFT", markLabel, "BOTTOMLEFT", -16, -8)

local markIcons = {
    "|TInterface\\TargetingFrame\\UI-RaidTargetingIcon_1:16|t Star",
    "|TInterface\\TargetingFrame\\UI-RaidTargetingIcon_2:16|t Circle",
    "|TInterface\\TargetingFrame\\UI-RaidTargetingIcon_3:16|t Diamond",
    "|TInterface\\TargetingFrame\\UI-RaidTargetingIcon_4:16|t Triangle",
    "|TInterface\\TargetingFrame\\UI-RaidTargetingIcon_5:16|t Moon",
    "|TInterface\\TargetingFrame\\UI-RaidTargetingIcon_6:16|t Square",
    "|TInterface\\TargetingFrame\\UI-RaidTargetingIcon_7:16|t Cross",
    "|TInterface\\TargetingFrame\\UI-RaidTargetingIcon_8:16|t Skull",
}

UIDropDownMenu_SetWidth(markDropdown, 150)
UIDropDownMenu_SetInitializeFunction(markDropdown, function()
    for i = 1, 8 do
        local info = UIDropDownMenu_CreateInfo()
        info.text = markIcons[i]
        info.arg1 = i
        info.func = function(_, arg1)
            QuickFocusDB.markNumber = arg1
            UIDropDownMenu_SetText(markDropdown, markIcons[arg1])
            UpdateBinding()
        end
        info.checked = QuickFocusDB.markNumber == i
        UIDropDownMenu_AddButton(info)
    end
end)

local safeMarkCheck = CreateFrame("CheckButton", "QuickFocusSafeMarkCheck", optionsPanel, "InterfaceOptionsCheckButtonTemplate")
safeMarkCheck:SetPoint("TOPLEFT", markDropdown, "BOTTOMLEFT", 16, -16)
safeMarkCheck.Text:SetText("Safe Mark (only castable targets)")
safeMarkCheck.tooltipText = "Only set raid markers on castable targets to prevent 'invalid target' errors."
safeMarkCheck:SetScript("OnClick", function(self)
    QuickFocusDB.safeMark = self:GetChecked()
    UpdateBinding()
end)

local function RefreshOptions()
    if not QuickFocusDB then return end
    enableCheck:SetChecked(QuickFocusDB.enable)
    local modIdx = 1
    for i, v in ipairs(modifierValues) do
        if v == QuickFocusDB.modifier then modIdx = i; break end
    end
    UIDropDownMenu_SetText(modifierDropdown, modifierLabels[modIdx])
    local btnIdx = 1
    for i, v in ipairs(buttonValues) do
        if v == QuickFocusDB.button then btnIdx = i; break end
    end
    UIDropDownMenu_SetText(buttonDropdown, buttonLabels[btnIdx])
    setMarkCheck:SetChecked(QuickFocusDB.setMark)
    UIDropDownMenu_SetText(markDropdown, markIcons[QuickFocusDB.markNumber] or markIcons[3])
    safeMarkCheck:SetChecked(QuickFocusDB.safeMark)
end

optionsPanel:Show()
optionsPanel:SetScript("OnShow", RefreshOptions)
optionsPanel:Hide()

if Settings and Settings.RegisterCanvasLayoutCategory then
    local category = Settings.RegisterCanvasLayoutCategory(optionsPanel, "QuickFocus")
    QF.category = category
    Settings.RegisterAddOnCategory(category)
elseif InterfaceOptions_AddCategory then
    InterfaceOptions_AddCategory(optionsPanel)
end
