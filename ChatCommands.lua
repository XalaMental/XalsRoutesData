-- ChatCommands.lua
-- Xal's Routes Data - slash command handling.
--
-- This is the power-user fallback, not the main way in - a real GUI panel is
-- the intended interface once the import feature is built.

local addonName, addonTable = ...
local ChatCommands = addonTable.ChatCommands

local ACCENT = "|cffb88c38"
local RESET  = "|r"

local function Say(msg)
    print(ACCENT .. "Xal's Routes Data:" .. RESET .. " " .. (msg or ""))
end

local function PrintHelp()
    Say("commands:")
    print("  |cffffffff/xrd import|r - import the data pack into Xal's Xpedited Routes")
    print("  |cffffffff/xrd options|r - open the settings window")
end

function ChatCommands:Handle(input)
    input = (input or ""):gsub("^%s+", ""):gsub("%s+$", "")
    local cmd = (input:match("^(%S*)") or ""):lower()

    if cmd == "options" or cmd == "config" or cmd == "settings" then
        addonTable.SettingsPanel:Open()
    elseif cmd == "import" then
        addonTable.Import:Run()
    else
        PrintHelp()
    end
end

SLASH_XALSROUTESDATA1 = "/xrd"
SlashCmdList["XALSROUTESDATA"] = function(input)
    ChatCommands:Handle(input)
end
