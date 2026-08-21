-- Engine.lua
-- Xal's Routes Data - startup and saved variables.

local addonName, addonTable = ...
local Engine = addonTable.Engine

local frame = CreateFrame("Frame")

local function EnsureDB()
    if type(XalsRoutesDataDB) ~= "table" then XalsRoutesDataDB = {} end
end

function Engine:Init()
    EnsureDB()

    addonTable.SettingsPanel:Init()

    addonTable.WhatsNew:CheckAndShow()
end

frame:RegisterEvent("PLAYER_LOGIN")
frame:SetScript("OnEvent", function(_, event)
    if event == "PLAYER_LOGIN" then
        Engine:Init()
    end
end)
