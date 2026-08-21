-- WhatsNew.lua
-- Xal's Routes Data
--
-- Shows a "what's new" splash automatically the FIRST time a player logs in
-- after the addon has been updated to a new version - never during normal,
-- unchanged play. Compares the addon's real installed version (read from the
-- .toc at runtime) against the last version this player actually saw, and
-- only pops up when they differ.
--
-- Claude already writes CHANGELOG.md by hand before every release, in Dev,
-- before Jason ever commits/pushes anything - same moment, update WHATS_NEW
-- below (the "date" field and the intro/sections content) to match. The
-- version NUMBER shown on the splash does NOT need updating here - it's
-- read live from the real installed .toc version, same value used for the
-- update-check itself, so there's only ever one place that can go stale.
local addonName, addonTable = ...
addonTable.WhatsNew = {}
local W = addonTable.WhatsNew
local Brand = addonTable.BrandStyle

-- ── Update this block every release to match CHANGELOG.md ──────
-- (no "version" field here on purpose - see note above)
W.WHATS_NEW = {
    date = "August 20, 2026",
    intro = "Pre-collected gathering node data you can import straight into Xal's Xpedited Routes.",
    sections = {
        { heading = "New", items = {
            "Initial data pack - hit Import Now below to add it to your Routes database.",
            "Current expansion only for now - no Classic or older-expansion zones yet.",
        } },
    },
}

-- ── Version check ────────────────────────────────────────────
-- C_AddOns.GetAddOnMetadata is the current namespaced API (available on
-- Retail, MoP Classic, and Classic Era alike since Dragonflight); the bare
-- global is kept as a fallback only, same defensive pattern used elsewhere
-- in Jason's addons for other C_* namespaces.
local function GetInstalledVersion()
    local v
    if C_AddOns and C_AddOns.GetAddOnMetadata then
        v = C_AddOns.GetAddOnMetadata(addonName, "Version")
    elseif _G.GetAddOnMetadata then
        v = _G.GetAddOnMetadata(addonName, "Version")
    end
    -- The .toc's "@project-version@" token only gets replaced with a real
    -- number by the packager, which only runs on an actual tagged release.
    -- Testing straight from local files (no tag pushed) leaves it as this
    -- literal, unsubstituted text - show a friendly fallback instead of the
    -- broken-looking placeholder string.
    if v == "@project-version@" then
        return "dev"
    end
    return v
end

local FW = 460
local MAX_FH = 560 -- clamp so an unusually long release note can't run off-screen

local function BuildFrame(installedVersion)
    local f = CreateFrame("Frame", "XalsRoutesDataWhatsNewFrame", UIParent)
    f:SetSize(FW, 360) -- placeholder height; set for real below once content is laid out
    f:SetPoint("CENTER")
    f:SetFrameStrata("DIALOG")
    f:SetMovable(true)
    f:EnableMouse(true)
    f:RegisterForDrag("LeftButton")
    f:SetScript("OnDragStart", f.StartMoving)
    f:SetScript("OnDragStop", f.StopMovingOrSizing)
    f:SetClampedToScreen(true)

    Brand.ApplyBackground(f)
    Brand.ApplyBackgroundImage(f)
    Brand.DrawBorder(f)

    local data = W.WHATS_NEW
    Brand.Title(f, "What's New", 26, "TOP", f, "TOP", 0, -24)

    local discord = Brand.MakeDiscordLink(f)
    discord:SetPoint("TOPRIGHT", f, "TOPRIGHT", -Brand.SAFE_MARGIN, -Brand.SAFE_MARGIN)

    -- "installedVersion" is the REAL live version (from CheckAndShow), not a
    -- hand-typed field - it always matches whatever actually got tagged.
    local verLine = Brand.FS(f, "Version " .. installedVersion .. (data.date and ("  ·  " .. data.date) or ""),
        Brand.BODY_FONT_PATH, 12, "", Brand.GOLD[1], Brand.GOLD[2], Brand.GOLD[3])
    verLine:SetPoint("TOP", f, "TOP", 0, -58)
    verLine:SetJustifyH("CENTER")

    Brand.DrawDivider(f, 30, 78, FW - 60)

    local y = 92
    if data.intro and data.intro ~= "" then
        local intro = Brand.FS(f, data.intro, Brand.BODY_FONT_PATH, 12, "", 0.85, 0.85, 0.85)
        intro:SetPoint("TOPLEFT", f, "TOPLEFT", 30, -y)
        intro:SetWidth(FW - 60)
        intro:SetJustifyH("LEFT")
        intro:SetWordWrap(true)
        y = y + (intro:GetStringHeight() or 14) + 14
    end

    for _, section in ipairs(data.sections or {}) do
        local head = Brand.FS(f, section.heading, Brand.BODY_FONT_PATH, 13, "OUTLINE",
            Brand.ACCENT[1], Brand.ACCENT[2], Brand.ACCENT[3])
        head:SetPoint("TOPLEFT", f, "TOPLEFT", 30, -y)
        y = y + 20

        for _, item in ipairs(section.items or {}) do
            local bullet = Brand.FS(f, "-  " .. item, Brand.BODY_FONT_PATH, 12, "",
                Brand.GOLD[1], Brand.GOLD[2], Brand.GOLD[3])
            bullet:SetPoint("TOPLEFT", f, "TOPLEFT", 36, -y)
            bullet:SetWidth(FW - 76)
            bullet:SetJustifyH("LEFT")
            bullet:SetWordWrap(true)
            y = y + (bullet:GetStringHeight() or 14) + 6
        end
        y = y + 10
    end

    -- Import button - only when the baked-in data pack is actually newer
    -- than what this player last imported, AND they haven't turned the
    -- prompt off in Settings. Sits above "Got it" rather than replacing it,
    -- since closing the splash and importing are two separate choices.
    local db = XalsRoutesDataDB
    local showImport = addonTable.Import:IsNewDataAvailable()
        and (not db or db.showImportPrompt ~= false)
    local closeY = 18

    if showImport then
        local importBtn = Brand.MakeButton(f, "Import Now", 150, 30, function()
            addonTable.Import:Run()
            f:Hide()
        end)
        importBtn:SetPoint("BOTTOM", f, "BOTTOM", 0, 54)
        closeY = 18
        y = y + 46 -- reserve room so the import button doesn't overlap the content above it
    end

    local closeBtn = Brand.MakeButton(f, "Got it", 110, 28, function()
        f:Hide()
    end)
    closeBtn:SetPoint("BOTTOM", f, "BOTTOM", 0, closeY)

    -- Size the frame to its ACTUAL content (y = how far the layout got, plus
    -- room for the close button + bottom padding) instead of a guessed fixed
    -- height - a longer release's content would otherwise clip or overlap
    -- the button. BOTTOM-anchored elements (the button, the border/background,
    -- both resize-safe) re-settle automatically once the frame's real size
    -- is set.
    f:SetHeight(math.min(y + (showImport and 92 or 56), MAX_FH))

    return f
end

-- Call this from Engine's Init - checks the version and shows the splash
-- only when it's genuinely changed since this player last saw it.
function W:CheckAndShow()
    local installed = GetInstalledVersion()
    if not installed then return end -- metadata unavailable, don't error, just skip

    -- Uses the addon's account-wide DB - XalsRoutesDataDB - same table
    -- every other saved setting lives in, so no extra SavedVariables entry
    -- needs registering in the .toc.
    local db = _G["XalsRoutesDataDB"]
    if not db then return end

    if db.lastSeenVersion ~= installed then
        db.lastSeenVersion = installed
        -- pcall so a bad edit to WHATS_NEW (typo, missing field) can never
        -- break the rest of the addon's login - worst case, the splash just
        -- silently doesn't show that one time.
        local ok, frame = pcall(BuildFrame, installed)
        if ok and frame then frame:Show() end
    end
end
