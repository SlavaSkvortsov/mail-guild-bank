local MODULE =  ...
local ADDON, Addon = MODULE:match('[^_]+'), _G[MODULE:match('[^_]+')]

--[[ Server Ready ]]--
Addon.purchase_items = {}


function Addon:PLAYER_LOGIN()
	self:SetupBank()
end

function Addon:SetupBank()
    MailGuildBankData = MailGuildBankData or {}
    MailGuildBankData.price = {
        [22589] = 10,
        [13444] = 5,
        [17026] = 3,
        [3033] = 1,
        [124104] = 1,
    }
--    if MailGuildBankData.price == nil then
--        MailGuildBankData.price = {
--            [22589] = 10,
--            [13444] = 5,
--        }
--    end

    if MailGuildBankData.update_time == nil then
        MailGuildBankData.update_time = 0
    end

    MailGuildBankData.person = {}
    MailGuildBankData.person[self.default_bank] = {
        [1] = 22589,
        [2] = 13444,
        [3] = 17026,
        [4] = 3033,
    }
    if Addon.TEST then
        MailGuildBankData.person[self.default_bank][5] = 124104
    end

--
--    if MailGuildBankData.person == nil then
--        MailGuildBankData.person = {}
--        MailGuildBankData.person[self.default_bank] = {
--            [1] = {
--                id = 22589,
--                count = 1,
--            },
--            [2] = {
--                id = 13444,
--                count = 2,
--            },
--        }
--    end
end


--[[ Communication ]]--

function Addon:CHAT_MSG_ADDON(prefix, message, distribution_type, sender)
    -- TODO ALL COMUNICATION DISABLED
    if true then
        return
    end

    if prefix ~= self.prefix then
        return
    end
    local args = Addon:Split(message, ';')

    sender = Addon:NormilizeName(sender)

    local event = args[1]

    if event == 'getPrices' then
        self:PriceShareHandler(sender, tonumber(args[2]))
    elseif event == 'gbPrices' then
        local prices = {}
        local update_time = args[2]
        for i = 3, #args do
            prices[i - 2] = args[i]
        end
        self:RefreshPrices(sender, update_time, prices)
    end
end

function Addon:PriceShareHandler(sender, current_update_time)
    local _, _, guild_rank_index = GetGuildInfo('player');
    if guild_rank_index > 2 then
        return
    end

    if MailGuildBankData.update_time > current_update_time then
        self:SharePrices(sender)
    end
end

function Addon:RefreshPrices(sender, update_time, prices)
    -- TODO Validate sender

    if update_time <= MailGuildBankData.update_time then
        return
    end
    local price = {}
    for _, data in pairs(prices) do
        local parsed_data = self:Split(data, ':')
        local id, price = tonumber(parsed_data[1]), tonumber(parsed_data[2])
        price[id] = price
    end

    MailGuildBankData.update_time = update_time
    MailGuildBankData.price = price
end


function Addon:SharePrices(name)
    local message = 'gbPrices;' .. MailGuildBankData.update_time
    for id, price in pairs(MailGuildBankData.price) do
        message = message .. ';' .. id .. ':' ..price
    end
    local channel = self.channel.guild

    if name ~= nil then
        channel = self.channel.whisper
    end
    self:SendAddonMsg(channel, message, name)
end

--[[ Register events ]]--

Addon:RegisterEvent('PLAYER_LOGIN')
Addon:RegisterEvent('CHAT_MSG_ADDON')