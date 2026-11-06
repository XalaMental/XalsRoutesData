-- DataForever.lua
-- Xal's Routes Data
--
-- Pre-collected gathering nodes for WoW: Forever, kept apart from the Retail pack
-- in Data.lua because Forever uses its own map IDs. Import.lua picks whichever
-- pack matches the client it's running on. Bump ersion any time this table's
-- contents change; WhatsNew.lua only offers the import button when it is newer
-- than the last version that client imported.
--
-- Same shape as Data.lua: `nodes` is keyed by uiMapID, each entry { x, y, type }.
local addonName, addonTable = ...

addonTable.DataPackForever = {
    version = 1,
    nodes = {
        [1438] = {
            { x = 0.5525833964347839, y = 0.3736409544944763, type = "herb" },
            { x = 0.5550495386123657, y = 0.3621138334274292, type = "herb" },
            { x = 0.6024924516677856, y = 0.3254719376564026, type = "herb" },
            { x = 0.5446487665176392, y = 0.3295847773551941, type = "herb" },
            { x = 0.5427857637405396, y = 0.4629157781600952, type = "herb" },
            { x = 0.5469393134117126, y = 0.4310427904129028, type = "herb" },
            { x = 0.5447818040847778, y = 0.4148992896080017, type = "herb" },
            { x = 0.5453364253044128, y = 0.4003556370735169, type = "herb" },
            { x = 0.533287525177002, y = 0.3872122764587402, type = "herb" },
            { x = 0.5381101369857788, y = 0.4013251066207886, type = "herb" },
        },
    },
}
