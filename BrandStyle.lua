-- BrandStyle.lua
-- Xal's Routes Data
--
-- Xal's shared visual brand - NEW DEFAULT as of 2026-09-02 (Xpedited Routes'
-- "Compact" redesign): dark indigo solid background + deep orange accent,
-- replacing the older bronze-gold/dark-swirl-image look everywhere except an
-- addon that explicitly offers a "Classic" style option (in which case
-- Classic gets its OWN separate bronze-gold constant, not this one - see
-- [[project_addon_visual_brand]]). Button style is from Xal's Compendium
-- (Courier's beveled "steel" buttons looked visually off - inconsistent
-- highlight/shadow read - once placed in a horizontal row, so Compendium's
-- flat button replaced it as the standard, confirmed 2026-08-09). Every
-- border/divider line is at least 2px - a 1px line can fail to render
-- reliably depending on UI scale.
--
-- Use these helpers for splash screens, settings panels, and any other
-- custom-drawn frame. Standard interactive controls that AREN'T part of this
-- brand spec (sliders, edit boxes) should still use Blizzard's native
-- templates unless MakeEditBox below is a better fit - only buttons/borders/
-- titles/checkboxes get the custom treatment.
local addonName, addonTable = ...
addonTable.BrandStyle = {}
local Brand = addonTable.BrandStyle

-- ── Colours (r, g, b) ─────────────────────────────────────────
Brand.ACCENT = { 0.72, 0.30, 0.0 }    -- deep, dark, burnt orange (the new default accent - NOT a light/gold-leaning orange)
Brand.GOLD   = { 0.60, 0.47, 0.30 }   -- secondary/body text tone (unchanged - still used for muted body copy like item lists)
Brand.BG     = { 0.03, 0.028, 0.06, 1 } -- dark indigo leaning purple (#08070f), fully opaque - solid color, no background image by default

-- Family-wide rollout, confirmed 2026-09-20 (worked out on Xal's Roster
-- Roundup, then confirmed as the standard for EVERY addon - see
-- project_addon_visual_brand.md). Narrow, specific scope for each:
Brand.HEADER_COLOR = { 0.4078, 0.0784, 0.0902 } -- #681417, dark brick red.
    -- ONLY for: a window's main title text (Brand.Title()'s front layer),
    -- the ONE header divider directly under that title (DrawHeaderDivider),
    -- and a selected/active link in a standalone window's own sidebar.
    -- Do not spread this to anything else without asking first.
Brand.DIVIDER_COLOR = { 0.0627, 0.0627, 0.1255 } -- #101020, near-black indigo.
    -- Every OTHER divider (section/list dividers), plus panel/card edges
    -- (DrawBorder()'s default color) and the outer window border.
Brand.SIDEBAR_UNSELECTED = { 0.196, 0.196, 0.392 } -- #323264, muted blue-gray.
    -- An UNselected link in a standalone window's own sidebar. Selected
    -- uses Brand.HEADER_COLOR above, not white and not accent-orange.
Brand.LINE_THICKNESS = 2 -- minimum for ANY border/divider - never go below this
-- Minimum gap between a panel's true outer edge and the nearest button/text
-- (close buttons especially). DrawBorder()'s line occupies out to 8px in
-- (6px inset + 2px thick) - the FIRST version of this constant was set to
-- exactly 8, which technically cleared the border but left ZERO actual
-- visual gap (content started precisely where the border line ended), so
-- it still read as crammed/touching. Bumped to 14 (a real ~6px of clear
-- space beyond the border) after seeing this live in-game - confirmed
-- 2026-08-09.
Brand.SAFE_MARGIN = 14

-- ── T()  ─ solid-colour texture rectangle.
-- x, y measured from the parent's TOP-LEFT corner (y increases downward).
-- Uses PixelUtil so every edge snaps to a whole physical screen pixel -
-- at a non-integer UI Scale (e.g. 71%), a plain SetPoint/SetSize can land
-- a 2px line on a fractional pixel, which the renderer then blurs/dims.
-- Confirmed 2026-08-09: this was making some sidebar tab borders look
-- randomly "less pronounced" than others, reproducibly, at 71% scale.
function Brand.T(parent, x, y, w, h, r, g, b, a, layer)
    local tex = parent:CreateTexture(nil, layer or "ARTWORK")
    PixelUtil.SetPoint(tex, "TOPLEFT", parent, "TOPLEFT", x, -y)
    PixelUtil.SetSize(tex, w, h)
    tex:SetColorTexture(r, g, b, a or 1)
    return tex
end

-- ── FS()  ─ a FontString with a specific font/size/colour.
function Brand.FS(parent, text, fontPath, size, flags, r, g, b)
    local fs = parent:CreateFontString(nil, "OVERLAY")
    fs:SetFont(fontPath, size, flags or "")
    fs:SetText(text)
    fs:SetTextColor(r, g, b, 1)
    -- Real, confirmed bug (2026-09-22, Roster Roundup): a plain FontString's
    -- own default justification is CENTER, not LEFT. Nearly everything built
    -- with this helper is meant to read left-aligned under its own heading,
    -- so that default gets overridden here once instead of by hand at every
    -- call site (several already forgot to). Brand.Title() below still
    -- explicitly re-sets CENTER afterward for its own use, unaffected.
    fs:SetJustifyH("LEFT")
    return fs
end

-- ── BodyFS()  ─ Brand.FS pre-wired to the body font, with a subtle drop
-- shadow so small body text stays legible over busy backgrounds - added
-- 2026-09-22 (previously reinvented separately, with two different
-- signatures, on Xpedited Routes and Roster Roundup and never ported back
-- into this template).
function Brand.BodyFS(parent, text, size, r, g, b)
    local fs = Brand.FS(parent, text, Brand.BODY_FONT_PATH, size, "", r or 0.85, g or 0.85, b or 0.85)
    fs:SetShadowOffset(1, -1)
    fs:SetShadowColor(0, 0, 0, 1)
    return fs
end

-- ── Font paths ────────────────────────────────────────────────
-- Header/title font: Cinzel Bold (bundled, SIL OFL). Body/label font: Inter
-- Regular/SemiBold (bundled, SIL OFL) - current go-forward pairing,
-- confirmed 2026-09-19 (Xals Guild Council), matching Quest Compass's
-- floating tracker window. Must ship in this addon's own Fonts/ folder
-- (Fonts/Cinzel-Bold.ttf, Fonts/Inter-Regular.ttf, Fonts/Inter-SemiBold.ttf,
-- plus their LICENSE.txt files) - copy them from an existing addon that
-- already has them (e.g. XalsQuestCompass/Fonts/ or XalsGuildCouncil/Fonts/).
-- NOT Fonts\CustomFont.ttf/FiraSans-Medium.ttf (Simply Sans/Fira Sans) -
-- that was this template's default until 2026-09-19, superseded but still
-- fine to see in older addons that haven't been touched since.
Brand.TITLE_FONT_PATH = "Interface\\AddOns\\XalsRoutesData\\Fonts\\Cinzel-Bold.ttf"
Brand.BODY_FONT_PATH = "Interface\\AddOns\\XalsRoutesData\\Fonts\\Inter-Regular.ttf"
Brand.BODY_FONT_PATH_SEMIBOLD = "Interface\\AddOns\\XalsRoutesData\\Fonts\\Inter-SemiBold.ttf"

-- ── Title()  ─ the branded Simply-Sans-Bold title treatment, with its
-- drop-shadow layer, in one call. Returns the visible (front) fontstring.
function Brand.Title(parent, text, size, anchorPoint, relTo, relPoint, x, y)
    -- Shadow stays pure black regardless of front-layer color (unchanged by
    -- the 2026-09-20 rollout). Front layer uses Brand.HEADER_COLOR now, not
    -- Brand.ACCENT - confirmed as the new default for every window's main
    -- title text. A caller that needs a differently-colored title (e.g. one
    -- explicitly staying "Classic") re-tints the returned fontstring with
    -- :SetTextColor() afterward rather than this function taking a color arg.
    local shadow = Brand.FS(parent, text, Brand.TITLE_FONT_PATH, size, "OUTLINE", 0, 0, 0)
    PixelUtil.SetPoint(shadow, anchorPoint, relTo, relPoint, x + 4, y - 4)
    shadow:SetJustifyH("CENTER")

    local title = Brand.FS(parent, text, Brand.TITLE_FONT_PATH, size, "OUTLINE",
        Brand.HEADER_COLOR[1], Brand.HEADER_COLOR[2], Brand.HEADER_COLOR[3])
    PixelUtil.SetPoint(title, anchorPoint, relTo, relPoint, x, y)
    title:SetJustifyH("CENTER")
    return title
end

-- Unselected label color - same as Brand.ACCENT, one unified orange for
-- both titles/borders and button labels (was its own separate amber-orange
-- before 2026-09-02).
local BTN_LABEL_UNSELECTED = Brand.ACCENT

-- ── MakeButton()  ─ text-link style (confirmed 2026-08-17/18, originated on
-- Xal's Xpedited Routes - "I don't like the blocky look... the link style
-- looks better"). Supersedes the earlier boxed/bordered version entirely -
-- plain text, no fill, no border. Selected vs. normal state is carried
-- entirely by label color/brightness. Call btn:SetSelected(true/false) to
-- toggle white (selected) vs. the unselected amber-orange.
function Brand.MakeButton(parent, text, w, h, onClick)
    local btn = CreateFrame("Button", nil, parent)
    PixelUtil.SetSize(btn, w, h)

    local label = btn:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    label:SetPoint("CENTER")
    label:SetText(text)
    label:SetTextColor(BTN_LABEL_UNSELECTED[1], BTN_LABEL_UNSELECTED[2], BTN_LABEL_UNSELECTED[3], 1)
    btn.label = label

    -- Default selected/unselected colors are the standard white/orange pair.
    -- A standalone window's own SIDEBAR nav buttons override both to the
    -- family-wide sidebar link colors instead (confirmed 2026-09-20, see
    -- project_addon_visual_brand.md - narrowly scoped to sidebar links only):
    --   btn:SetSelectedColor(unpack(Brand.HEADER_COLOR))
    --   btn:SetUnselectedColor(unpack(Brand.SIDEBAR_UNSELECTED))
    btn.selectedColor = { 1, 1, 1 }
    btn.unselectedColor = BTN_LABEL_UNSELECTED

    btn:SetScript("OnEnter", function(self)
        if not self.selected then label:SetTextColor(1, 1, 1, 1) end
    end)
    btn:SetScript("OnLeave", function(self)
        if not self.selected then
            local c = self.unselectedColor
            label:SetTextColor(c[1], c[2], c[3], 1)
        end
    end)
    if onClick then btn:SetScript("OnClick", onClick) end

    function btn:SetSelected(selected)
        self.selected = selected
        local c = selected and self.selectedColor or self.unselectedColor
        label:SetTextColor(c[1], c[2], c[3], 1)
    end

    function btn:SetSelectedColor(r, g, b)
        self.selectedColor = { r, g, b }
        if self.selected then label:SetTextColor(r, g, b, 1) end
    end

    function btn:SetUnselectedColor(r, g, b)
        self.unselectedColor = { r, g, b }
        if not self.selected then label:SetTextColor(r, g, b, 1) end
    end

    -- Was a border-color hook before the box existed - kept as the same
    -- method name/signature so call sites don't need touching, just now
    -- tints the label itself instead of a border that no longer exists.
    function btn:SetBorderColor(r, g, bC, a)
        label:SetTextColor(r, g, bC, a)
    end

    return btn
end

-- ── MakeCloseButton()  ─ text-link style close ("Close" in accent gold,
-- brightens to white on hover) - replaces the boxed "X" button. Doesn't set
-- its own anchor point; call sites position it themselves.
function Brand.MakeCloseButton(parent, onClick)
    local btn = CreateFrame("Button", nil, parent)
    btn:SetSize(50, 20)

    local label = btn:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    label:SetPoint("CENTER")
    label:SetText("Close")
    label:SetTextColor(Brand.ACCENT[1], Brand.ACCENT[2], Brand.ACCENT[3], 1)
    btn.label = label

    btn:SetScript("OnEnter", function() label:SetTextColor(1, 1, 1, 1) end)
    btn:SetScript("OnLeave", function()
        label:SetTextColor(Brand.ACCENT[1], Brand.ACCENT[2], Brand.ACCENT[3], 1)
    end)
    btn:SetScript("OnClick", onClick or function() parent:Hide() end)

    return btn
end

-- ── MakeLinkButton()  ─ a second, deliberately plain button style for
-- inline quick-toggles (no border/fill). Hover feedback is wired via
-- HookScript, not SetScript, so a call site can still add its own
-- OnEnter/OnLeave (e.g. a tooltip) without one silently overwriting the
-- other.
function Brand.MakeLinkButton(parent)
    local btn = CreateFrame("Button", nil, parent)
    local label = btn:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    label:SetFont(Brand.BODY_FONT_PATH, 12, "")
    label:SetPoint("CENTER")
    btn.label = label

    function btn:SetLabel(text, r, g, b)
        label:SetText(text)
        if r then label:SetTextColor(r, g, b, 1) end
        btn.baseColor = { r or Brand.ACCENT[1], g or Brand.ACCENT[2], b or Brand.ACCENT[3] }
    end

    btn:HookScript("OnEnter", function() label:SetTextColor(1, 1, 1, 1) end)
    btn:HookScript("OnLeave", function()
        local c = btn.baseColor or Brand.ACCENT
        label:SetTextColor(c[1], c[2], c[3], 1)
    end)

    return btn
end

-- ── MakeDiscordLink()  ─ the standing Discord text-link (see
-- project_discord_link_standard). Takes only the parent - it does NOT
-- position itself, same as MakeButton/MakeCloseButton; the call site sets
-- its own point (usually TOPRIGHT near the title). Passing extra anchor
-- args here instead of calling :SetPoint() on the result is the exact bug
-- that shipped broken on Xals Guild Council's What's New splash
-- (2026-09-19) - a mismatched call signature threw a Lua error mid-build
-- and silently left half the frame unbuilt. Do not add anchor parameters
-- to this function's signature.
Brand.DISCORD_URL = "https://discord.gg/9SwrQDJeCe"

StaticPopupDialogs["XALSROUTESDATA_COPY_URL"] = {
    text = "Copy this link:",
    button1 = "Close",
    hasEditBox = true,
    editBoxWidth = 260,
    OnShow = function(self, data)
        self.editBox:SetText(data)
        self.editBox:HighlightText()
        self.editBox:SetFocus()
    end,
    EditBoxOnEscapePressed = function(self) self:GetParent():Hide() end,
    timeout = 0,
    whileDead = true,
    hideOnEscape = true,
    preferredIndex = 3,
}

-- Icon-only Discord mark (official brand asset, white symbol variant), used
-- next to the text link so it pops instead of reading as plain text -
-- confirmed 2026-09-19 (Xals Guild Council). Ship
-- Textures/DiscordIcon.png in every new addon's own folder, copied from
-- D:\WoW_Addons\Dev\Assets\Icons\Discord-Symbol-White_64.png (already
-- resized to a game-ready size - do NOT re-source or re-download the logo,
-- and do not recolor/distort it per Discord's brand guidelines).
Brand.DISCORD_ICON = "Interface\\AddOns\\XalsRoutesData\\Textures\\DiscordIcon.png"

function Brand.MakeDiscordLink(parent)
    local btn = Brand.MakeLinkButton(parent)
    btn:SetSize(92, 20)

    -- Icon sits left of the label - real aspect ratio (84x64 source)
    -- preserved so the mark doesn't look squashed at this size.
    local icon = btn:CreateTexture(nil, "ARTWORK")
    icon:SetSize(21, 16)
    icon:SetPoint("LEFT", btn, "LEFT", 0, 0)
    icon:SetTexture(Brand.DISCORD_ICON)
    btn.icon = icon

    btn.label:ClearAllPoints()
    btn.label:SetPoint("LEFT", icon, "RIGHT", 5, 0)
    btn:SetLabel("Discord", 0.45, 0.55, 0.95)

    btn:HookScript("OnEnter", function() icon:SetVertexColor(1, 1, 1, 1) end)
    btn:HookScript("OnLeave", function() icon:SetVertexColor(0.45, 0.55, 0.95, 1) end)
    icon:SetVertexColor(0.45, 0.55, 0.95, 1)

    btn:SetScript("OnClick", function()
        StaticPopup_Show("XALSROUTESDATA_COPY_URL", nil, nil, Brand.DISCORD_URL)
    end)
    return btn
end

-- ── DrawBorder()  ─ single clean line around a frame, in Brand.DIVIDER_COLOR
-- (was Brand.ACCENT/bright orange before the 2026-09-20 rollout - a border
-- that loud read as the wrong kind of emphasis once seen next to the new
-- subtler mockup). Deliberately simple - no corner ornaments or tick marks.
-- Each side is anchored to BOTH ends of that edge (not a fixed x/y/w/h), so
-- it auto-stretches if the frame resizes later - important for anything
-- that grows or shrinks at runtime (a list that adds/removes rows, etc.),
-- not just fixed-size splash screens. Use inset 1 for a standalone window's
-- true outer edge, inset 0 (or the default 6) for a panel/card edge within
-- a page - see project_addon_visual_brand.md for which inset an existing
-- addon's specific border already uses.
function Brand.DrawBorder(f, inset)
    inset = inset or 6
    local thick = Brand.LINE_THICKNESS
    local r, g, b = Brand.DIVIDER_COLOR[1], Brand.DIVIDER_COLOR[2], Brand.DIVIDER_COLOR[3]

    local top = f:CreateTexture(nil, "ARTWORK")
    PixelUtil.SetPoint(top, "TOPLEFT", f, "TOPLEFT", inset, -inset)
    PixelUtil.SetPoint(top, "TOPRIGHT", f, "TOPRIGHT", -inset, -inset)
    PixelUtil.SetHeight(top, thick)
    top:SetColorTexture(r, g, b, 1)

    local bottom = f:CreateTexture(nil, "ARTWORK")
    PixelUtil.SetPoint(bottom, "BOTTOMLEFT", f, "BOTTOMLEFT", inset, inset)
    PixelUtil.SetPoint(bottom, "BOTTOMRIGHT", f, "BOTTOMRIGHT", -inset, inset)
    PixelUtil.SetHeight(bottom, thick)
    bottom:SetColorTexture(r, g, b, 1)

    local left = f:CreateTexture(nil, "ARTWORK")
    PixelUtil.SetPoint(left, "TOPLEFT", f, "TOPLEFT", inset, -inset)
    PixelUtil.SetPoint(left, "BOTTOMLEFT", f, "BOTTOMLEFT", inset, inset)
    PixelUtil.SetWidth(left, thick)
    left:SetColorTexture(r, g, b, 1)

    local right = f:CreateTexture(nil, "ARTWORK")
    PixelUtil.SetPoint(right, "TOPRIGHT", f, "TOPRIGHT", -inset, -inset)
    PixelUtil.SetPoint(right, "BOTTOMRIGHT", f, "BOTTOMRIGHT", -inset, inset)
    PixelUtil.SetWidth(right, thick)
    right:SetColorTexture(r, g, b, 1)

    return top, bottom, left, right
end

-- ── DrawDivider()  ─ the thin section-separator line used between content
-- blocks (feature lists, header bars, etc.) - Brand.DIVIDER_COLOR (was a
-- hardcoded muted brown before the 2026-09-20 rollout).
function Brand.DrawDivider(parent, x, y, width)
    return Brand.T(parent, x, y, width, Brand.LINE_THICKNESS,
        Brand.DIVIDER_COLOR[1], Brand.DIVIDER_COLOR[2], Brand.DIVIDER_COLOR[3], 1)
end

-- ── DrawHeaderDivider()  ─ the ONE divider directly under a window's main
-- title, in Brand.HEADER_COLOR - confirmed 2026-09-20 as its own distinct
-- color, separate from every other divider (which uses DrawDivider above).
-- Do not spread HEADER_COLOR to any other divider without asking first.
function Brand.DrawHeaderDivider(parent, x, y, width)
    return Brand.T(parent, x, y, width, Brand.LINE_THICKNESS,
        Brand.HEADER_COLOR[1], Brand.HEADER_COLOR[2], Brand.HEADER_COLOR[3], 1)
end

-- ── ApplyBackground()  ─ the standard opaque near-black frame background.
function Brand.ApplyBackground(f)
    local bg = f:CreateTexture(nil, "BACKGROUND")
    bg:SetAllPoints()
    bg:SetColorTexture(Brand.BG[1], Brand.BG[2], Brand.BG[3], Brand.BG[4])
    return bg
end

-- ── ApplyBackgroundImage()  ─ the OLD shared dark-swirl texture art. NOT
-- called by default anymore (2026-09-02) - the new default look is
-- ApplyBackground()'s flat indigo color alone, no image layered on top.
-- Kept here only for an addon that deliberately wants a "Classic" style
-- option matching the old look, or another explicit exception - not for new
-- panels by default. If actually used, copy Textures/PanelBackground.jpg
-- from an existing addon that has it (e.g. XalsXpeditedRoutes/Textures/)
-- into this addon's own Textures/ folder, and call AFTER ApplyBackground so
-- the flat color shows through anywhere the image doesn't cover.
function Brand.ApplyBackgroundImage(f)
    local img = f:CreateTexture(nil, "BORDER")
    img:SetAllPoints(f)
    img:SetTexture("Interface\\AddOns\\XalsRoutesData\\Textures\\PanelBackground.jpg")
    return img
end

-- ── MakeCheckbox()  ─ hand-drawn checkbox, same reason/technique as
-- MakeButton's hand-drawn border: Blizzard's native UICheckButtonTemplate
-- was found rendering incomplete (missing its bottom edge entirely, not
-- just uneven thickness) in a real in-game screenshot - confirmed
-- 2026-08-12 on Roster Roundup's Options window. Rather than chase why the
-- native template's art is unreliable, this uses the exact same
-- pixel-snapped 4-texture border technique already proven reliable for
-- Brand.MakeButton/DrawBorder, so it can't have a side silently fail to
-- render. This is now the brand standard for checkboxes - stop using
-- UICheckButtonTemplate in new code.
--
-- Usage differs slightly from a native CheckButton: set `cb.OnToggle =
-- function(self) ... end` instead of `cb:SetScript("OnClick", ...)`, since
-- OnClick is used internally to flip the checked state before your handler
-- runs (matching the native behavior where GetChecked() already reflects
-- the NEW state inside OnClick).
-- ── MakeEditBox()  ─ hand-drawn text input, same 4-texture border technique
-- as MakeButton/MakeCheckbox -- no Blizzard InputBoxTemplate art, whose
-- endcap textures render wider than its SetSize (bled fields past the
-- panel's safe margin on Xal's AutoMac, 2026-08-23). Exact, predictable
-- width instead.
function Brand.MakeEditBox(parent, w, h)
    h = h or 22
    local box = CreateFrame("EditBox", nil, parent)
    PixelUtil.SetSize(box, w, h)

    local bg = box:CreateTexture(nil, "BACKGROUND")
    bg:SetAllPoints()
    bg:SetColorTexture(0.1, 0.1, 0.1, 0.6)

    local thick = Brand.LINE_THICKNESS
    local r, g, b = Brand.ACCENT[1], Brand.ACCENT[2], Brand.ACCENT[3]

    local borderTop = box:CreateTexture(nil, "ARTWORK")
    PixelUtil.SetPoint(borderTop, "TOPLEFT", box, "TOPLEFT", 0, 0)
    PixelUtil.SetPoint(borderTop, "TOPRIGHT", box, "TOPRIGHT", 0, 0)
    PixelUtil.SetHeight(borderTop, thick)
    borderTop:SetColorTexture(r, g, b, 1)

    local borderBottom = box:CreateTexture(nil, "ARTWORK")
    PixelUtil.SetPoint(borderBottom, "BOTTOMLEFT", box, "BOTTOMLEFT", 0, 0)
    PixelUtil.SetPoint(borderBottom, "BOTTOMRIGHT", box, "BOTTOMRIGHT", 0, 0)
    PixelUtil.SetHeight(borderBottom, thick)
    borderBottom:SetColorTexture(r, g, b, 1)

    local borderLeft = box:CreateTexture(nil, "ARTWORK")
    PixelUtil.SetPoint(borderLeft, "TOPLEFT", box, "TOPLEFT", 0, 0)
    PixelUtil.SetPoint(borderLeft, "BOTTOMLEFT", box, "BOTTOMLEFT", 0, 0)
    PixelUtil.SetWidth(borderLeft, thick)
    borderLeft:SetColorTexture(r, g, b, 1)

    local borderRight = box:CreateTexture(nil, "ARTWORK")
    PixelUtil.SetPoint(borderRight, "TOPRIGHT", box, "TOPRIGHT", 0, 0)
    PixelUtil.SetPoint(borderRight, "BOTTOMRIGHT", box, "BOTTOMRIGHT", 0, 0)
    PixelUtil.SetWidth(borderRight, thick)
    borderRight:SetColorTexture(r, g, b, 1)

    box:SetFont(Brand.BODY_FONT_PATH, 13, "")
    box:SetTextColor(0.9, 0.9, 0.9, 1)
    box:SetTextInsets(6, 6, 0, 0)
    box:SetAutoFocus(false)

    return box
end

function Brand.MakeCheckbox(parent, size)
    size = size or 22
    local cb = CreateFrame("Button", nil, parent)
    PixelUtil.SetSize(cb, size, size)

    local bg = cb:CreateTexture(nil, "BACKGROUND")
    bg:SetAllPoints()
    bg:SetColorTexture(0.1, 0.1, 0.1, 0.6)

    local thick = Brand.LINE_THICKNESS
    local r, g, b = Brand.ACCENT[1], Brand.ACCENT[2], Brand.ACCENT[3]

    local borderTop = cb:CreateTexture(nil, "ARTWORK")
    PixelUtil.SetPoint(borderTop, "TOPLEFT", cb, "TOPLEFT", 0, 0)
    PixelUtil.SetPoint(borderTop, "TOPRIGHT", cb, "TOPRIGHT", 0, 0)
    PixelUtil.SetHeight(borderTop, thick)
    borderTop:SetColorTexture(r, g, b, 1)

    local borderBottom = cb:CreateTexture(nil, "ARTWORK")
    PixelUtil.SetPoint(borderBottom, "BOTTOMLEFT", cb, "BOTTOMLEFT", 0, 0)
    PixelUtil.SetPoint(borderBottom, "BOTTOMRIGHT", cb, "BOTTOMRIGHT", 0, 0)
    PixelUtil.SetHeight(borderBottom, thick)
    borderBottom:SetColorTexture(r, g, b, 1)

    local borderLeft = cb:CreateTexture(nil, "ARTWORK")
    PixelUtil.SetPoint(borderLeft, "TOPLEFT", cb, "TOPLEFT", 0, 0)
    PixelUtil.SetPoint(borderLeft, "BOTTOMLEFT", cb, "BOTTOMLEFT", 0, 0)
    PixelUtil.SetWidth(borderLeft, thick)
    borderLeft:SetColorTexture(r, g, b, 1)

    local borderRight = cb:CreateTexture(nil, "ARTWORK")
    PixelUtil.SetPoint(borderRight, "TOPRIGHT", cb, "TOPRIGHT", 0, 0)
    PixelUtil.SetPoint(borderRight, "BOTTOMRIGHT", cb, "BOTTOMRIGHT", 0, 0)
    PixelUtil.SetWidth(borderRight, thick)
    borderRight:SetColorTexture(r, g, b, 1)

    -- Texture, not a FontString "X" - a font glyph's CENTER anchor centers
    -- against the font's full line-height box (ascender/descender padding
    -- included), not the glyph's actual ink, so it visually drifts off-true-
    -- center. Blizzard's own checkmark texture centers exactly where told,
    -- no font-metrics guesswork. This superseded the FontString "X" version
    -- 2026-08-13; this template still had the old version until 2026-08-14.
    local check = cb:CreateTexture(nil, "OVERLAY")
    check:SetTexture("Interface\\Buttons\\UI-CheckBox-Check")
    check:SetVertexColor(r, g, b, 1)
    PixelUtil.SetSize(check, size - 4, size - 4)
    check:SetPoint("CENTER", cb, "CENTER", 0, 0)
    check:Hide()

    cb.checked = false
    function cb:SetChecked(state)
        self.checked = state and true or false
        if self.checked then check:Show() else check:Hide() end
    end
    function cb:GetChecked()
        return self.checked
    end

    cb:SetScript("OnEnter", function() bg:SetColorTexture(0.18, 0.18, 0.18, 0.75) end)
    cb:SetScript("OnLeave", function() bg:SetColorTexture(0.1, 0.1, 0.1, 0.6) end)
    cb:SetScript("OnClick", function(self)
        self:SetChecked(not self.checked)
        if self.OnToggle then self.OnToggle(self) end
    end)

    return cb
end

-- ── ShowContextMenu()  ─ a right-click menu built entirely from brand
-- widgets (bordered background, text-link entries) - NOT Blizzard's
-- UIDropDownMenu/EasyMenu. Confirmed 2026-09-19 (Xals Guild Council): never
-- default to Blizzard's own menu chrome for a context menu - build it
-- ourselves like everything else in this brand.
--
-- options is an array of { label, r, g, b, onClick } - r/g/b optional
-- (defaults to Brand.ACCENT).
local contextMenu, clickCatcher

function Brand.ShowContextMenu(options)
    if not clickCatcher then
        clickCatcher = CreateFrame("Button", nil, UIParent)
        clickCatcher:SetAllPoints(UIParent)
        clickCatcher:SetFrameStrata("FULLSCREEN")
        clickCatcher:Hide()
    end

    if not contextMenu then
        contextMenu = CreateFrame("Frame", nil, UIParent)
        contextMenu:SetFrameStrata("FULLSCREEN_DIALOG")
        Brand.ApplyBackground(contextMenu)
        Brand.DrawBorder(contextMenu, 4)
        contextMenu.buttons = {}
        contextMenu:Hide()
    end

    local ROW_H, PAD = 22, 10
    local width = 90
    for i, opt in ipairs(options) do
        local btn = contextMenu.buttons[i]
        if not btn then
            btn = Brand.MakeLinkButton(contextMenu)
            btn:SetHeight(ROW_H)
            contextMenu.buttons[i] = btn
        end
        btn:SetLabel(opt.label, opt.r or Brand.ACCENT[1], opt.g or Brand.ACCENT[2], opt.b or Brand.ACCENT[3])
        btn:SetPoint("TOPLEFT", contextMenu, "TOPLEFT", PAD, -PAD - (i - 1) * ROW_H)
        btn:SetScript("OnClick", function()
            clickCatcher:Hide()
            contextMenu:Hide()
            if opt.onClick then opt.onClick() end
        end)
        btn:Show()
        local w = btn.label:GetStringWidth() + 4
        if w > width then width = w end
    end
    for i = #options + 1, #contextMenu.buttons do
        contextMenu.buttons[i]:Hide()
    end
    for _, btn in ipairs(contextMenu.buttons) do btn:SetWidth(width) end

    contextMenu:SetSize(width + PAD * 2, #options * ROW_H + PAD * 2)

    local x, y = GetCursorPosition()
    local scale = UIParent:GetEffectiveScale()
    contextMenu:ClearAllPoints()
    contextMenu:SetPoint("TOPLEFT", UIParent, "BOTTOMLEFT", x / scale, y / scale)

    clickCatcher:Show()
    clickCatcher:SetScript("OnClick", function()
        clickCatcher:Hide()
        contextMenu:Hide()
    end)
    contextMenu:Show()
end
