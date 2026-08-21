-- Import.lua
-- Xal's Routes Data - hands the baked-in node data pack off to Xal's Xpedited
-- Routes, one time per data version, through the shared duplicate-check
-- logic Routes already runs on everything it records itself.
--
-- Routes exposes this contract as a global table (not a direct function
-- call into its namespace, since these are two separate addons):
--   _G.XalsXpeditedRoutesAPI.ImportNodeData(nodesByMapID)
--     -> returns { added = N, skipped = N, invalid = N }
-- `nodesByMapID` is addonTable.DataPack.nodes - the same [mapID] = { {x,y,type}, ... }
-- shape Routes already stores its own database in, so it can run each entry
-- straight through its own Helpers.FindNearbyNodeIndex duplicate scan before
-- inserting anything.

local addonName, addonTable = ...
addonTable.Import = {}
local Import = addonTable.Import

local ACCENT = "|cffb88c38"
local WHITE  = "|cffffffff"
local RESET  = "|r"

local function Say(msg)
    print(ACCENT .. "Xal's Routes Data:" .. RESET .. " " .. (msg or ""))
end

-- True when the baked-in data pack is newer than whatever this player last
-- actually imported - the same check both the WhatsNew splash button and
-- the manual /xrd import command gate on.
function Import:IsNewDataAvailable()
    local pack = addonTable.DataPack
    local db = XalsRoutesDataDB
    if not pack or not db then return false end
    return (pack.version or 0) > (db.importedVersion or 0)
end

function Import:Run()
    local pack = addonTable.DataPack
    if not pack then
        Say("no data pack loaded.")
        return
    end

    local api = _G.XalsXpeditedRoutesAPI
    if not api or not api.ImportNodeData then
        Say("Xal's Xpedited Routes isn't installed - install it, then run " .. WHITE .. "/xrd import" .. RESET .. " again.")
        return
    end

    local result = api.ImportNodeData(pack.nodes) or {}
    XalsRoutesDataDB.importedVersion = pack.version

    local added, skipped, invalid = result.added or 0, result.skipped or 0, result.invalid or 0
    local msg = "imported " .. WHITE .. added .. RESET .. " node(s) into Xal's Xpedited Routes."
    if skipped > 0 then
        msg = msg .. " (" .. WHITE .. skipped .. RESET .. " already recorded, skipped.)"
    end
    if invalid > 0 then
        msg = msg .. " (" .. WHITE .. invalid .. RESET .. " invalid entries ignored.)"
    end
    Say(msg)
end
