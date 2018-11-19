print('Welcome to PHR, an addon for tabletop-style roleplay! Type "/ph" for a list of commands.')  -- TODO

local frame = CreateFrame('Frame', 'PhrFrame')
local events = {}

local allowedChannels = {RAID=true, EMOTE=true, SAY=true, YELL=true, SILENT=true}

function events:ADDON_LOADED(addonName)
    if addonName ~= 'PHR' then return end

    if phDebug == nil then
        phDebug = false
    end

    phu:log('PHR: loaded')
    if phrKeyVals ~= nil then
        phu:log('PHR: phrKeyVals')
        for k, v in pairs(phrKeyVals) do
            phu:log(k .. ':' .. v)
        end
        phu:log()
    else
        phu:log('PHR: loading default phrKeyVals')
        phrKeyVals = {}
    end

    if phrDefaultChannel ~= nil then
        print('PHR: phrDefaultChannel is ' .. phrDefaultChannel)
    else
        print('PHR: loading default phrDefaultChannel (SILENT). You might want also to try /phc RAID or /phc EMOTE')
        phrDefaultChannel = 'SILENT'
    end
end

local function rollDice(text)
    -- Takes a string like "xdy" and returns a list of x rolls from 1 to y and their total value
    -- Also returns maxRolled, which is true if one die had its maximum value rolled, and
    -- minRolled, which is true if one die had its minimum value rolled.
    local total_mul = 1
    if text:sub(1, 1) == '+' then
        text = text:sub(2)
    elseif text:sub(1, 1) == '-' then
        text = text:sub(2)
        total_mul = -1
    end

    local dIndex = string.find(text, 'd') -- index of 'd' in '2d6'
    local count = 1
    if dIndex ~= 1 then
        count = tonumber(text:sub(1, dIndex - 1))
    end

    local upper = tonumber(text:sub(dIndex + 1))
    if count == nil or upper == nil then
        print("Unable to convert " .. text .. " to numbers.")
        return
    end

    local rolls = {}
    local total = 0
    local maxRolled, minRolled = false, false
    for i=1,count do
        local rolledVal = math.random(1, upper)
        if rolledVal == upper then
            maxRolled = true
        end
        if rolledVal == 1 then
            minRolled = true
        end
        rolls[#rolls + 1] = rolledVal
        total = total + rolledVal
    end
    return rolls, total * total_mul, maxRolled, minRolled  -- todo blue text/green text/red text for both/max/min rolls
end

local function getStoredNumber(text)
    local total_mul = 1
    if text:sub(1, 1) == '+' then
        text = text:sub(2)
    elseif text:sub(1, 1) == '-' then
        text = text:sub(2)
        total_mul = -1
    end

    local val = phrKeyVals[text]
    if val == nil then
        print('"' .. text ..'" not understood or not set with "/phs key=value".')
        return
    end
    local valnum = tonumber(val)
    if valnum == nil then
        print('"' .. text .. '=' .. valnum'" is not a number!')
        return
    end

    return valnum * total_mul
end

SLASH_PHHELP1 = '/ph'
SlashCmdList['PHHELP'] = function(subcommandText)
    print('PHR version 0.0.1, developed by Attenius.\n')
    print([[/phr -- Rolls dice using dice specifiers, numbers, and named modifiers stored beforehand. \
"/phr 3d20 - 4 + INT" will roll three 20-sided dice, subtract 4, and add the number stored as \
"INT" (using /phs) to the result.]])
    print([[/phs -- Set a named value. "/phs AGI=-2" will store the value -2 with the key "AGI". \
When you add AGI to a roll, -2 will be substituted in. These values are stored per-character.]])
    print([[/phc -- Set the output channel for rolls and easter egg text. "/phc EMOTE" will cause rolls to be output as \
emotes. Available values are SILENT (only you will see the result), SAY, RAID, EMOTE and YELL.]])
end

SLASH_PHROLL1 = '/phr'
SlashCmdList['PHROLL'] = function(subcommandText)
    -- Takes a Roll20-style roll/dice string like "3d6 - 3 + STR" 
    -- and prints something like "3d6 (1, 5, 3) - 3 + STR (5) = 11"
    -- subcommandText = subcommandText:gsub("%s+", "")
    local outTextRolls = {}
    local total = 0
    for text in string.gmatch(subcommandText, "[%+%-]?[^%+%-]+") do
        local outtext = text
        text = text:gsub("%s+", "")

        if string.match(text, "[%+%-]?%d*d%d+") then -- handles things that look like "d20", "2d20", "3d6", etc.
            local rolls, subtotal = rollDice(text)
            total = total + subtotal
            outTextRolls[#outTextRolls + 1] = outtext .. ' (' .. table.concat(rolls, ",") .. ')'

        elseif string.match(text, "[%+%-]?%d") then -- handles plain numbers
            total = total + tonumber(text)
            outTextRolls[#outTextRolls + 1] = outtext

        else -- handles stored values
            local valnum = getStoredNumber(text)
            total = total + valnum
            outTextRolls[#outTextRolls + 1] = outtext .. ' (' .. valnum .. ')'
        end
    end

    rollText = table.concat(outTextRolls, ' ') .. ' = ' .. total
    rollText = rollText:gsub("%s+", " ")
    if phrDefaultChannel == 'SILENT' then
        print(rollText)
    else
        SendChatMessage(rollText, phrDefaultChannel)
    end
end

SLASH_PHSET1 = '/phs'
SlashCmdList['PHSET'] = function(subcommandText)
    -- Set an arbitrary string key to a numerical value.
    -- These key/value pairs are stored per-character.
    for k, v in string.gmatch(subcommandText, "(%w+)=(%w+)") do
        vnum = tonumber(v)
        if vnum == nil then
            print("Unable to convert " .. v .. " to a number.")
        else
            print("Setting " .. k .. " to " .. vnum)
            phrKeyVals[k] = vnum
        end
    end
end

SLASH_PHSETSTRING1 = '/phss'
SlashCmdList['PHSETSTRING'] = function(subcommandText)
    print(subcommandText)
    print("This doesn't work yet.")
end

SLASH_PHPRINT1 = '/php'
SlashCmdList['PHPRINT'] = function(subcommandText)
    print(subcommandText .. "=" .. phrKeyVals[string.match(subcommandText, "%S+")])
end

SLASH_PHDEBUG1 = '/phdebug'
SlashCmdList['PHDEBUG'] = function(subcommandText)
    if subcommandText == '1' then
        phDebug = true
        print('Debug logging enabled.')
    else
        phDebug = false
        print('Debug logging disabled.')
    end
end

SLASH_PHSETCHANNEL1 = '/phc'
SlashCmdList['PHSETCHANNEL'] = function(subcommandText)
    -- Sets the default channel for roll text.
    subcommandText = phu:strip(subcommandText)

    if allowedChannels[phrDefaultChannel] ~= nil then
        phrDefaultChannel = subcommandText
        print("Set default channel for rolls to '" .. phu:strip(subcommandText) .. "'.")
    else
        print("Currently only the following channels are supported: ")
        for chan, _ in pairs(allowedChannels) do
            print(chan)
        end
    end
end

SLASH_PHPHY1 = '/phy'
SlashCmdList['PHPHY'] = function(subcommandText)
    -- Easter eggs!
    eggs = {}
    eggs[#eggs + 1] = "Kimbee and Brela Songdew will be avenged!"
    eggs[#eggs + 1] = "Nobody reads your TRP."
    eggs[#eggs + 1] = "I'm reading your TRP."
    eggs[#eggs + 1] = "Basic Campfire for Warchief!"
    eggs[#eggs + 1] = "As if I could forgetti. Listen, Uther, there's something about the plaguette you should knead."
    eggs[#eggs + 1] = "You are not my chef yet, boyardee. Nor would I obey that command if you were!"
    eggs[#eggs + 1] = "BRAH BRAH OI OI OI GOR'WATHA!"
    eggs[#eggs + 1] = "We will never forget the pizza incident."
    eggs[#eggs + 1] = "Adventure. Romance. Ejaculating live bees and the bees are angry."
    eggs[#eggs + 1] = "IF THESE FALSE CHAMPIONS WILL NOT YIELD THE AEGIS BY CHOICE THEN THEY WILL SURRENDER IT IN DEATH! GIVE UP THE AEGIS OR DIE!"
    eggs[#eggs + 1] = "Long ago, in a distant land, I, Andrew, the shapeshifting master of darkness, unleashed an UNSPEAKABLE evil--"
    eggs[#eggs + 1] = "--but a foolish orc warrior wielding a magic sword stepped forth to oppose me."
    eggs[#eggs + 1] = "Two elves, chilling in a moonwell, five feet apart 'cause they're not gay!"
    eggs[#eggs + 1] = "Glarr'glarr cried while watching Click."
    -- eggs[#eggs + 1] = [[Look, having fel — my uncle was a great professor and arcanist and enchanter, Dr. Jarod Tarelvir at ZIT; noble blood, 
-- very noble blood, OK, very smart, Nar’thalas Academy, very good, very smart -]]
    -- eggs[#eggs + 1] = [[You know, if you’re a Duskwatch loyalist, if I were a rebel, if, like, OK, if I ran as a Nightfallen rebel, they would say I’m one of the smartest people anywhere on Azeroth — it’s true! — but...]] 
    -- eggs[#eggs + 1] = [[But when you’re a loyalist they try — oh, do they do a number — that’s why I always start off: Went to Nar’thalas, was a good student, went there, went there, did this, built a fortune — ]] 
    -- eggs[#eggs + 1] = [[You know I have to give my like credentials all the time, because we’re a little disadvantaged — but you look at the Legion deal, the thing that really bothers me — it would have been so easy, and it’s not as important as these lives are — ]]
    -- eggs[#eggs + 1] = [[Fel is powerful; my uncle explained that to me many, many years ago, the power and that was 10,000 years ago; he 
-- would explain the power of what’s going to happen and he was right, who would have thought?]]
    -- eggs[#eggs + 1] = [[But when you look at what’s going on with the four races of elves — now it used to be three, now it’s four — but when it was three and even now, I would have said it’s all in the messenger, ]] 
    -- eggs[#eggs + 1] = [[Arcanists, and it is arcanists because, you know, they don’t, they haven’t figured that the warlocks are smarter right now than the mages, so, you know, it’s gonna take them about another 10,000 years — ]] 
    -- eggs[#eggs + 1] = [[But the Eredar are great negotiators, the Legion are great negotiators, so, and they, they just killed, they just killed us.]]

    if phrDefaultChannel == 'SILENT' then
        print(eggs[math.random(1, #eggs)])
    else
        SendChatMessage(eggs[math.random(1, #eggs)], phrDefaultChannel)
    end
end

frame:SetScript("OnEvent", function(self, event, ...)
    events[event](self, ...)
end)
for k, v in pairs(events) do
    frame:RegisterEvent(k)
end

-- ### Roadmap
-- * Color crits and crit fails and mixed crit/fails
-- * More pretty colors
-- * Character sheet UI
-- * Allow other characters to view each others' character sheets
