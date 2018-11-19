phu = {}

function phu:strip(s)
    return (s:gsub("^%s*(.-)%s*$", "%1"))
end

function phu:log(s, level)
    if level == nil then
        level = 'DEBUG'
    end
    if level == 'DEBUG' and phDebug then
        print('PHR[' .. level .. ']: ' .. s)
    end
end
