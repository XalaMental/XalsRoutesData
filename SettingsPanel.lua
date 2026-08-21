-- SettingsPanel.lua
-- Xal's Routes Data - settings.
--
-- Two ways in, per the standard: a standalone floating window (the PRIMARY
-- one, opened by /xrd options) and an entry in Blizzard's own AddOns list
-- (secondary, so it's findable where people expect it).

local addonName, addonTable = ...
local SettingsPanel = addonTable.SettingsPanel
local Brand         = addonTable.BrandStyle

local PANEL_NAME = "Xal's Routes Data"
local WIN_W, WIN_H = 420, 260

local window, rootPanel

local function BuildWindow()
    if window then return window end

    local f = CreateFrame("Frame", "XalsRoutesDataOptionsWindow", UIParent)
    f:SetSize(WIN_W, WIN_H)
    f:SetFrameStrata("HIGH")
    f:SetToplevel(true)
    f:SetMovable(true)
    f:EnableMouse(true)
    f:RegisterForDrag("LeftButton")
    f:SetScript("OnDragStart", f.StartMoving)
    f:SetScript("OnDragStop", function(self)
        self:StopMovingOrSizing()
        if type(XalsRoutesDataDB) == "table" then
            local point, _, relPoint, x, y = self:GetPoint()
            XalsRoutesDataDB.optionsPos = { point = point, relPoint = relPoint, x = x, y = y }
        end
    end)
    f:SetClampedToScreen(true)

    local pos = type(XalsRoutesDataDB) == "table" and XalsRoutesDataDB.optionsPos or nil
    if pos and pos.point then
        f:SetPoint(pos.point, UIParent, pos.relPoint, pos.x, pos.y)
    else
        f:SetPoint("CENTER", UIParent, "CENTER", -300, 60)
    end

    Brand.ApplyBackground(f)
    Brand.ApplyBackgroundImage(f)
    Brand.DrawBorder(f)

    Brand.Title(f, "Xal's Routes Data", 22, "TOP", f, "TOP", 0, -Brand.SAFE_MARGIN - 6)

    local discord = Brand.MakeDiscordLink(f)
    discord:SetPoint("TOPRIGHT", f, "TOPRIGHT", -Brand.SAFE_MARGIN, -Brand.SAFE_MARGIN)

    Brand.DrawDivider(f, 0, 66, WIN_W - (Brand.SAFE_MARGIN * 2))

    local note = Brand.FS(f, "New data updates get offered on the What's New splash. Run "
        .. "/xrd import any time to check for one manually.",
        Brand.BODY_FONT_PATH, 13, nil, Brand.GOLD[1], Brand.GOLD[2], Brand.GOLD[3])
    note:SetPoint("TOPLEFT", f, "TOPLEFT", Brand.SAFE_MARGIN + 6, -84)
    note:SetPoint("RIGHT", f, "RIGHT", -Brand.SAFE_MARGIN - 6, 0)
    note:SetJustifyH("LEFT")
    note:SetWordWrap(true)

    -- Off switch for the WhatsNew splash's auto-offered import button - the
    -- manual /xrd import command always works regardless of this setting.
    local importCheck = Brand.MakeCheckbox(f, 22)
    importCheck:SetPoint("TOPLEFT", f, "TOPLEFT", Brand.SAFE_MARGIN + 6, -136)

    local importLabel = Brand.FS(f, "Show import prompt on update", Brand.BODY_FONT_PATH, 14, nil,
        Brand.GOLD[1], Brand.GOLD[2], Brand.GOLD[3])
    importLabel:SetPoint("LEFT", importCheck, "RIGHT", 8, 0)
    importLabel:SetPoint("RIGHT", f, "RIGHT", -Brand.SAFE_MARGIN, 0)
    importLabel:SetJustifyH("LEFT")
    importLabel:SetWordWrap(true)

    importCheck:SetChecked(type(XalsRoutesDataDB) ~= "table" or XalsRoutesDataDB.showImportPrompt ~= false)
    importCheck.OnToggle = function(self)
        if type(XalsRoutesDataDB) == "table" then
            XalsRoutesDataDB.showImportPrompt = self:GetChecked() and true or false
        end
    end

    local close = Brand.MakeCloseButton(f, function() f:Hide() end)
    close:SetPoint("BOTTOM", f, "BOTTOM", 0, Brand.SAFE_MARGIN)

    f:Hide()
    window = f
    return f
end

-- The AddOns-list entry. Points people at the standalone window rather than
-- duplicating controls in two places.
local function BuildCanvasPanel()
    if rootPanel then return rootPanel end

    local panel = CreateFrame("Frame")
    panel.name = PANEL_NAME

    local title = Brand.FS(panel, PANEL_NAME, Brand.TITLE_FONT_PATH, 22, nil,
        Brand.ACCENT[1], Brand.ACCENT[2], Brand.ACCENT[3])
    title:SetPoint("TOPLEFT", panel, "TOPLEFT", 16, -16)

    local blurb = Brand.FS(panel, "Pre-collected gathering node data you can import into "
        .. "Xal's Xpedited Routes.", Brand.BODY_FONT_PATH, 13, nil,
        Brand.GOLD[1], Brand.GOLD[2], Brand.GOLD[3])
    blurb:SetPoint("TOPLEFT", title, "BOTTOMLEFT", 0, -10)

    local open = Brand.MakeButton(panel, "Open Xal's Routes Data options", 260, 28, function()
        SettingsPanel:Open()
    end)
    open:SetPoint("TOPLEFT", blurb, "BOTTOMLEFT", 0, -20)

    rootPanel = panel
    return panel
end

function SettingsPanel:Init()
    BuildCanvasPanel()

    if Settings and Settings.RegisterCanvasLayoutCategory then
        local category = Settings.RegisterCanvasLayoutCategory(rootPanel, rootPanel.name)
        category.ID = rootPanel.name
        Settings.RegisterAddOnCategory(category)
        SettingsPanel.category = category
    elseif InterfaceOptions_AddCategory then
        InterfaceOptions_AddCategory(rootPanel)
    end
end

-- The primary entry point: the standalone window.
function SettingsPanel:Open()
    local f = BuildWindow()
    if f:IsShown() then f:Hide() else f:Show() end
end
