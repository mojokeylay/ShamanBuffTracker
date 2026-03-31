-- Save Variables
ShamanBuffTrackerDB = ShamanBuffTrackerDB or {
    isEnhancement = true,
    trackMainHand = true,
    trackSkyfury = true,
    trackLightningShield = true,
    trackEarthShield = false,
    frameScale = 1.0,
    posX = 0,
    posY = -50,
    point = "TOP"
}

StaticPopupDialogs["SHAMAN_TRACKER_CONFIRM_RESET"] = {
    text = "Are you sure you want to reset the Shaman Buff Tracker to default position and scale?",
    button1 = "Yes",
    button2 = "No",
    OnAccept = function()
        ShamanBuffTrackerDB.posX = 0
        ShamanBuffTrackerDB.posY = -50
        ShamanBuffTrackerDB.point = "TOP"
        ShamanBuffTrackerDB.frameScale = 1.0
        
        ShamanSelfCheckFrame:ClearAllPoints()
        ShamanSelfCheckFrame:SetPoint("TOP", UIParent, "TOP", 0, -50)
        ShamanSelfCheckFrame:SetUserPlaced(false)
        ShamanSelfCheckFrame:SetScale(1.0)
        
        if ShamanTrackerScaleSlider then ShamanTrackerScaleSlider:SetValue(1.0) end
        if ShamanBuffTrackerOptions and ShamanBuffTrackerOptions.moveBtn then 
            ShamanBuffTrackerOptions.moveBtn:SetChecked(false) 
        end
        ShamanSelfCheckFrame.moveOverlay:Hide()
        
        print("|cff00ff00Shaman Tracker: Reset to default successful.|r")
        ShamanSelfCheckFrame:UpdateStatus()
    end,
    timeout = 0,
    whileDead = true,
    hideOnEscape = true,
    preferredIndex = 3,
}

-- Main frame
local frame = CreateFrame("Frame", "ShamanSelfCheckFrame", UIParent, "BackdropTemplate")
frame:SetSize(200, 40)
frame:SetFrameStrata("HIGH")
frame:SetMovable(true)
frame:SetClampedToScreen(true)
frame:SetBackdrop({
    bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background",
    edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Border",
    tile = true, tileSize = 32, edgeSize = 16,
    insets = { left = 5, right = 5, top = 5, bottom = 5 }
})

local text = frame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
text:SetPoint("CENTER", 0, 0)
text:SetTextColor(1, 0.82, 0)

-- Moving Frame
local moveOverlay = CreateFrame("Frame", nil, frame, "BackdropTemplate")
moveOverlay:SetAllPoints()
moveOverlay:SetFrameLevel(frame:GetFrameLevel() + 10)
moveOverlay:SetBackdrop({ edgeFile = "Interface\\Buttons\\UI-SliderBar-Border", edgeSize = 12 })
moveOverlay:Hide()
frame.moveOverlay = moveOverlay 

local moveText = moveOverlay:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
moveText:SetPoint("CENTER", 0, 0)
moveText:SetText("DRAG TO MOVE")

moveOverlay:EnableMouse(true)
moveOverlay:RegisterForDrag("LeftButton")
moveOverlay:SetScript("OnDragStart", function() frame:StartMoving() end)
moveOverlay:SetScript("OnDragStop", function() 
    frame:StopMovingOrSizing() 
    local point, _, _, x, y = frame:GetPoint()
    ShamanBuffTrackerDB.point, ShamanBuffTrackerDB.posX, ShamanBuffTrackerDB.posY = point, x, y
end)

-- Options
local options = CreateFrame("Frame", "ShamanBuffTrackerOptions", InterfaceOptionsFramePanelContainer)
options.name = "Shaman Buff Tracker"
ShamanBuffTrackerOptions = options 

local title = options:CreateFontString(nil, "ARTWORK", "GameFontNormalLarge")
title:SetPoint("TOPLEFT", 16, -16)
title:SetText("Shaman Buff Tracker Settings")

local moveBtn = CreateFrame("CheckButton", nil, options, "InterfaceOptionsCheckButtonTemplate")
moveBtn:SetPoint("TOPLEFT", title, "BOTTOMLEFT", 0, -15)
moveBtn.Text:SetText("|cffffff00Enable Move Mode|r")
options.moveBtn = moveBtn
moveBtn:SetScript("OnClick", function(self)
    if self:GetChecked() then 
        moveOverlay:Show() 
        frame:Show() 
        text:SetText("")
    else 
        moveOverlay:Hide() 
        frame:UpdateStatus() 
    end
end)

local function CreateOptionCheckbox(label, dbKey, relativeTo, yOffset)
    local cb = CreateFrame("CheckButton", nil, options, "InterfaceOptionsCheckButtonTemplate")
    cb:SetPoint("TOPLEFT", relativeTo, "BOTTOMLEFT", 0, yOffset)
    cb.Text:SetText(label)
    cb:SetScript("OnClick", function(self)
        ShamanBuffTrackerDB[dbKey] = self:GetChecked()
        frame:UpdateStatus() 
    end)
    return cb
end

local enhCB = CreateOptionCheckbox("Enhancement Mode (Tracks Off-Hand)", "isEnhancement", moveBtn, -10)
local mhCB  = CreateOptionCheckbox("Track Main-Hand Imbue", "trackMainHand", enhCB, -10)
local skyCB = CreateOptionCheckbox("Track Skyfury", "trackSkyfury", mhCB, -10)
local lsCB  = CreateOptionCheckbox("Track Lightning Shield", "trackLightningShield", skyCB, -10)
local esCB  = CreateOptionCheckbox("Track Earth Shield", "trackEarthShield", lsCB, -10)

-- Slider
local scaleSlider = CreateFrame("Slider", "ShamanTrackerScaleSlider", options, "BackdropTemplate")
scaleSlider:SetPoint("TOPLEFT", esCB, "BOTTOMLEFT", 20, -40)
scaleSlider:SetSize(180, 15)
scaleSlider:SetOrientation("HORIZONTAL")
scaleSlider:SetMinMaxValues(0.5, 2.0)
scaleSlider:SetValueStep(0.1)
scaleSlider:SetObeyStepOnDrag(true)
scaleSlider:SetBackdrop({
    bgFile = "Interface\\Buttons\\UI-SliderBar-Background",
    edgeFile = "Interface\\Buttons\\UI-SliderBar-Border",
    tile = true, tileSize = 8, edgeSize = 8,
    insets = { left = 3, right = 3, top = 6, bottom = 6 }
})
local thumb = scaleSlider:CreateTexture(nil, "ARTWORK")
thumb:SetTexture("Interface\\Buttons\\UI-SliderBar-Button-Horizontal")
thumb:SetSize(32, 32)
scaleSlider:SetThumbTexture(thumb)

local sliderLabel = scaleSlider:CreateFontString(nil, "ARTWORK", "GameFontNormalSmall")
sliderLabel:SetPoint("BOTTOM", scaleSlider, "TOP", 0, 5)

scaleSlider:SetScript("OnValueChanged", function(self, value)
    ShamanBuffTrackerDB.frameScale = value
    sliderLabel:SetText("Scale: " .. string.format("%.1f", value))
    frame:SetScale(value)
end)

-- RESET BUTTON
local resetBtn = CreateFrame("Button", nil, options, "UIPanelButtonTemplate")
resetBtn:SetSize(120, 25)
resetBtn:SetPoint("TOPLEFT", scaleSlider, "BOTTOMLEFT", -10, -30)
resetBtn:SetText("Reset to Default")
resetBtn:SetScript("OnClick", function()
    StaticPopup_Show("SHAMAN_TRACKER_CONFIRM_RESET")
end)

if Settings and Settings.RegisterCanvasLayoutCategory then
    local category = Settings.RegisterCanvasLayoutCategory(options, options.name)
    Settings.RegisterAddOnCategory(category)
else
    InterfaceOptions_AddCategory(options)
end

-- TAINT-SAFE LOGIC HELPERS
local function GetIconString(id)
    local texture = type(id) == "number" and (C_Spell.GetSpellTexture(id) or id) or id
    return "|T" .. texture .. ":16:16:0:0|t "
end

local function PlayerHasAura(spellName, spellID)
    if C_UnitAuras.GetPlayerAuraBySpellID(spellID) then return true end
    if spellName == "Lightning Shield" and C_UnitAuras.GetPlayerAuraBySpellID(192109) then return true end
    if AuraUtil.FindAuraByName(spellName, "player") then return true end
    return false
end

function frame:UpdateStatus()
    if moveOverlay:IsShown() then return end
    
    -- THIS IS WHY IT HIDES IN COMBAT:
    if InCombatLockdown() then 
        frame:Hide() 
        return 
    end

    local _, class = UnitClass("player")
    if class ~= "SHAMAN" or UnitIsDeadOrGhost("player") then 
        frame:Hide() 
        return 
    end

    local missing = {}
    local hasMH, _, _, _, hasOH = GetWeaponEnchantInfo()
    
    if ShamanBuffTrackerDB.trackMainHand and not hasMH then table.insert(missing, "|T132314:16:16:0:0|t Main-hand imbue") end
    if ShamanBuffTrackerDB.isEnhancement and not hasOH then table.insert(missing, "|T237581:16:16:0:0|t Off-hand imbue") end

    if ShamanBuffTrackerDB.trackLightningShield then
        if not PlayerHasAura("Lightning Shield", 192106) then
            table.insert(missing, GetIconString(192106) .. "Lightning Shield")
        end
    end

    if ShamanBuffTrackerDB.trackEarthShield then
        if not PlayerHasAura("Earth Shield", 974) then
            table.insert(missing, GetIconString(974) .. "Earth Shield")
        end
    end

    if ShamanBuffTrackerDB.trackSkyfury then
        if not (PlayerHasAura("Skyfury", 375986) or PlayerHasAura("Skyfury", 462854)) then
            table.insert(missing, GetIconString(462854) .. "Skyfury")
        end
    end

    if #missing > 0 then
        text:SetText("MISSING: " .. table.concat(missing, "  "))
        frame:SetWidth(text:GetStringWidth() + 50)
        frame:Show()
    else 
        frame:Hide() 
    end
end

-- EVENT HANDLING
frame:RegisterUnitEvent("UNIT_AURA", "player")
frame:RegisterEvent("PLAYER_EQUIPMENT_CHANGED")
frame:RegisterEvent("PLAYER_ENTERING_WORLD")
frame:RegisterEvent("ADDON_LOADED")
frame:RegisterEvent("PLAYER_REGEN_DISABLED") 
frame:RegisterEvent("PLAYER_REGEN_ENABLED")  

local lastUpdate = 0
frame:SetScript("OnUpdate", function(self, elapsed)
    lastUpdate = lastUpdate + elapsed
    if lastUpdate > 0.5 then
        self:UpdateStatus()
        lastUpdate = 0
    end
end)

frame:SetScript("OnEvent", function(self, event, arg1)
    if event == "ADDON_LOADED" and arg1 == "ShamanBuffTracker" then
        local p, x, y = ShamanBuffTrackerDB.point or "TOP", ShamanBuffTrackerDB.posX or 0, ShamanBuffTrackerDB.posY or -50
        self:ClearAllPoints()
        self:SetPoint(p, UIParent, p, x, y)
        local scale = ShamanBuffTrackerDB.frameScale or 1.0
        scaleSlider:SetValue(scale)
        self:SetScale(scale)
        enhCB:SetChecked(ShamanBuffTrackerDB.isEnhancement)
        mhCB:SetChecked(ShamanBuffTrackerDB.trackMainHand)
        skyCB:SetChecked(ShamanBuffTrackerDB.trackSkyfury)
        lsCB:SetChecked(ShamanBuffTrackerDB.trackLightningShield)
        esCB:SetChecked(ShamanBuffTrackerDB.trackEarthShield)
    end
    self:UpdateStatus()
end)
