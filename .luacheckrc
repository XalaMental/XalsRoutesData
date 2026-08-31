-- .luacheckrc
-- Xal's Routes Data
--
-- Scoped to the actual WoW API calls and globals this addon uses (not a
-- copy-pasted full addon's config) - add to `globals`/`read_globals` as new
-- API calls get added, rather than pulling in a giant generic list.
std = "lua51"

globals = {
    "XalsRoutesDataDB",
    "SLASH_XALSROUTESDATA1",
    "SlashCmdList",
    "StaticPopupDialogs", -- a real mutable table addons add popup entries to
}

read_globals = {
    "CreateFrame",
    "UIParent",
    "PixelUtil",
    "Settings",
    "InterfaceOptions_AddCategory",
    "C_AddOns",
    "GameFontHighlightSmall",
    "InputBoxTemplate",
    "UISpecialFrames",
    "IsControlKeyDown",
    "tinsert",
}

-- Textures/backdrop tables and long chained SetPoint calls read as "unused
-- variable"/line-length noise in generated UI code like this - not real bugs.
-- `addonName` specifically comes from the standard
-- `local addonName, addonTable = ...` header every file carries and is
-- intentionally unused in most of them.
max_line_length = false
unused_args = false
ignore = { "211/addonName" }
