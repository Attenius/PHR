print('hi world!')

local frame = CreateFrame('Frame', 'PhrFrame')
local events = {}

function events:ADDON_LOADED(self, addonName)
    print('Addon loaded')
    if addonName != 'PHR' then
        print(addonName)
        return
    end
    print('PHR loaded')
    if phrKeyVals != nil then
        return
    end
    print('PHR: loading defaults')
    phrKeyVals = {}

SLASH_PHROLL1 = '/phr'
SlashCmdList['PHROLL'] = function(subcommandText)
    print(subcommandText)
end

SLASH_PHSET1 = '/phs'
SlashCmdList['PHSET'] = function(subcommandText)
    print(subcommandText)
end

SLASH_PHSETSTRING1 = '/phss'
SlashCmdList['PHSETSTRING'] = function(subcommandText)
    print(subcommandText)
end

frame:SetScript("OnEvent", function(self, event, ...)
    events[event](self, ...)
end)
for k, v in pairs(events) do
    frame:RegisterEvent(k)
end

-- ### Roadmap
-- * Save a user-defined number with /phs key value
-- * Save a user-defined string with /phss key value
-- * Print a user-defined value with /php key
-- * Roll a die with /phr d20 -> /e rolls d20: 19! (19)
-- * Roll two dice with /phr 2d20 -> /e rolls 2d20: 16! (10 + 6)
-- * Roll dice with modifiers /phr d20 + 1 - 3 -> /e rolls d20 + 1 - 3: 10! (12 + 1 - 3)
-- * Roll dice using stored modifiers
-- * Frame which displays all stored values
-- * Character creator
--  * example choose: 
--      warrior (+2 con or str or dex, +1 any stat, +1 any stat)
--      adventurer (+2 dex or int or cha, +1 any stat, +1 any stat)
--      scholar (+2 int or spr or cha, +1 any stat, +1 any stat)
--      expert (+3 any stat, +1 any other stat)
-- [str, dex, con, int, spr, cha]
--  * or something like:
--      All stats start at -1. 
--      Distribute 9 points between your stats. No stat can have higher than +2.
--      a charismatic wizard: -1 0 1 2 0 2
--      a skilled, impulsive fighter: 2 0 1 2 0 2
--      
-- * Built-in list of abilities to choose from, e.g.
-- 
-- 
-- 
-- 
-- 
-- 
-- 
-- 
-- 
-- 
-- 
-- 
-- 
-- 
