local frame = CreateFrame('Frame', 'PhrFrame')
local events = {}

function events:ADDON_LOADED(addonName)
    print('PHR loaded')
    if phrKeyVals ~= nil then
        print('PHR keyvals')
        for k, v in pairs(phrKeyVals) do
            print('\t' .. k .. ':\t' .. v)
        end
        return
    end
    print('PHR: loading defaults')
    phrKeyVals = {}
end

SLASH_PHROLL1 = '/phr'
SlashCmdList['PHROLL'] = function(subcommandText)
    outTextRolls = {}
    total = 0
    for text in string.gmatch(subcommandText, "%S+") do
        if string.match(text, "%d*d%d+") then -- handles things that look like "d20", "2d20", "3d6", etc.
            dIndex = string.find(text, 'd')[1] -- index of 'd' in '2d6'
            if dIndex == 1 then
                count = 1
            else
                count = tonumber(text:sub(1, dIndex + 1))
            end

            upper = tonumber(text:sub(dIndex + 1))
            if count == nil or upper == nil then
                print("Unable to convert " .. text .. " to numbers.")
                return
            end

            rolls = {}
            for i=1,count do
                rolledVal = math.random(1, upper)
                table.insert(rolls, rolledVal)
                total = total + rolledVal
            end
            table.insert(outTextRolls, text .. ' (' .. table.concat(rolls), "," .. ')')
        end
    end
    print(total .. ' = ' .. table.concat(outTextRolls, ' + '))
end

SLASH_PHSET1 = '/phs'
SlashCmdList['PHSET'] = function(subcommandText)
    for k, v in string.gmatch(s, "(%w+)=(%w+)") do
        v = tonumber(v)
        if v == nil then
            print("Unable to convert " .. v .. " to a number.")
        else
            print("Setting " .. k .. " to " .. v)
            phrKeyVals[k] = v
        end
    end
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
-- * Allow other characters to view each others stored values
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
