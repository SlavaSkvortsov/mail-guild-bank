local MODULE =  ...
local ADDON, Addon = MODULE:match('[^_]+'), _G[MODULE:match('[^_]+')]


Addon.TEST = string.sub(GetBuildInfo(), 1, 1) ~= '1'


Addon.default_bank = 'Енотовед'
Addon.warehouse = 'Вашабанка'

if Addon.TEST then
    Addon.default_bank = 'Ференир'
    Addon.warehouse = 'Тритирий'
end


function Addon:Split(msg, delim)
    if msg == nil then
        return {}
    end
	local args = {}
	local count = 1
	for i in (msg .. delim):gmatch("([^"..delim.."]*)" .. delim) do
		args[count] = i
		count = count + 1
	end
	return args;
end


function Addon:SendAddonMsg(channel, message, person)
    SendAddonMessage(self.pefix, message, channel, person);
end

function Addon:NormilizeName(name)
    if string.find(name, "-") then
        return name.sub(name, 0, string.find(name, "-") - 1);
    end
    return name
end

function Addon:GetFreeSlot(table)
    for i = 1, #table do
        if table[i] == nil then
            return i
        end
    end
    return #table + 1
end


function Addon:GetOfficerNote(player_name)
    if Addon.TEST then
        return '123,123,1000'
    end

    if player_name == nil then
        player_name = UnitName('player')
    end
    player_name = Addon:NormilizeName(player_name)

    for i = 1, GetNumGuildMembers() do
        local name, _, _, _, _, _, _, officerNote = GetGuildRosterInfo(i);
		name = Addon:NormilizeName(name)
        if player_name == name then
            return officerNote, i
        end
    end
    print('Не могу найти игрока ' .. player_name .. ' в гильдии')
end


function Addon:GetBP(player_name)
    local officerNote = self:GetOfficerNote(player_name)
    if officerNote == nil then
        return 0
    end

    local data = {}
    for i in officerNote:gmatch("([^,%s]+)") do
        data[#data + 1] = i
    end
    return tonumber(data[3]) or 0
end
