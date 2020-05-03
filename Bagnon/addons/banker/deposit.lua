--[[
	deposit.lua
		Code for handling one deposit mail
--]]

local MODULE = ...
local ADDON, Addon = MODULE:match('[^_]+'), _G[MODULE:match('[^_]+')]
local Deposit = Addon.Mail:NewClass('Deposit', 'Frame')


function Deposit:New(sender, index)
    local deposit = self:Super(Deposit):New(sender, index)

    deposit.items_received = false
    deposit.bp_added = false
    deposit.reply_sent = false

    deposit.current_slot = 0
    deposit.should_return = false
    deposit.unpriced_items = {}
    deposit.total_bp = 0
    deposit.error_text = nil

    deposit.isTakeable = select(3, GetInboxText(index))

    return deposit
end


function Deposit:Process()
    if not self.items_received then
        self.current_slot = self.current_slot + 1

        if self.current_slot >= 17 then
            self.items_received = true
            self:NextIteration()
            return
        end

        self:ProcessSlot(self.current_slot)
        return
    end

    if self.should_return then
       self:ProcessReturn()
    end

    if self.isTakeable and not self.deleted then
        self:DeleteMail()
    end

    if not self.bp_added then
        self:AddBP()
    end

    if not self.reply_sent then
        self:SendReply()
    end

    if not self.outbox_prepared then
        self:PrepareOutbox()
        return
    end

    if not self.placed_to_outbox then
        self:PlaceToOutbox()
        return
    end

    Addon:Log('Отправляю на склад')
    SendMail(Addon.warehouse, 'ИТЕМЫЫыыы')

    self.processed = true
end


function Deposit:ProcessSlot(slot)
    if not HasInboxItem(self.index, slot) then
        self:NextIteration()
        return
    end

    local name, itemID, _, count = GetInboxItem(self.index, slot)
    local price = MailGuildBankData.price[itemID]

    if price == nil then
        self.should_return = true
        self.unpriced_items[#self.unpriced_items + 1] = name

        self:NextIteration()
        return
    end

    self.total_bp = self.total_bp + price * count

    if self.should_be_sent[itemID] == nil then
        self.should_be_sent[itemID] = 0
    end

    self.should_be_sent[itemID] = self.should_be_sent[itemID] + count

    TakeInboxItem(self.index, slot)
    self:NextIteration()
end


function Deposit:ProcessReturn()
    Addon:Log('Возвращаем некоторые предметы из письма')
    ReturnInboxItem(self.index)
    self.error_text = 'К сожалению мы не принимаем пречисленные ниже предметы. '
    self.error_text = self.error_text .. 'Если Вы считаете что стоило бы - пишите в дискорде, обсудим \n P.S. сами предметы в другом письме \n'
    for _, itemName in pairs(self.unpriced_items) do
        self.error_text = self.error_text .. itemName .. '\n'
    end

    self.should_return = false
    self:NextIteration(2)
end


function Deposit:AddBP()
    Addon:ChangeBP(self.sender, self.total_bp)

    self.bp_added = true
    self:NextIteration()
end


function Deposit:SendReply()
    local text = 'Доброго времени суток! \n'
    text = text .. 'За Ваш вклад в банк гильдии Вам было начислено ' .. self.total_bp .. ' BP! \n'
    text = text .. 'Спасибо!\n'
    if self.error_text ~= nil then
        text = text .. '\n' .. self.error_text
    end

    SendMail(self.sender, 'RE: Вклад!', text)

    self.reply_sent = true
    self:NextIteration(2)
end