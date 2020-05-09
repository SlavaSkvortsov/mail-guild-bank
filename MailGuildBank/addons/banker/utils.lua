local MODULE =  ...
local ADDON, Addon = MODULE:match('[^_]+'), _G[MODULE:match('[^_]+')]


function Addon:Log(msg)
    if BankerLog == nil then
        BankerLog = {}
    end
    BankerLog[#BankerLog + 1] = time() .. msg

    print(msg)
end


function Addon:ChangeBP(player_name, add_bp)
    local officerNote, index = self:GetOfficerNote(player_name)
    if index == nil then
        return
    end

    local EP, GP, BP
    if officerNote == nil or officerNote == '' then
        EP, GP, BP = 0, 0, 0
    else
        local data = {}
        for i in officerNote:gmatch("([^,%s]+)") do
            data[#data + 1] = i
        end
        EP, GP, BP = data[1], data[2], data[3]
    end

    BP = BP + add_bp
    self:Log('Изменяю значение BP игрока ' .. player_name .. ' на ' .. add_bp)
    if Addon.TEST then
        return
    end
    GuildRosterSetOfficerNote(index, EP .. ',' .. GP .. ',' .. BP)
end