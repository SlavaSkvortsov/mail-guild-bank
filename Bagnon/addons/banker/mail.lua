--[[
	mail.lua
		Abstract class for mail processing
--]]

local MODULE = ...
local ADDON, Addon = MODULE:match('[^_]+'), _G[MODULE:match('[^_]+')]
local Mail = Addon.Base:NewClass('Mail')


-- Base logic

function Mail:New(sender, index)
    local mail = self:Super(Mail):New()
    mail.should_be_sent = {}
    mail.sender = sender
    mail.index = index
    mail.processed = false

    mail.outbox_prepared = false
    mail.placed_to_outbox = false
    mail.deleted = false
    mail.sent = false
    mail.outbox_slots = {}
    mail.outbox_total = {}

    return mail
end

function Mail:Process() end


function Mail:NextIteration(wait)
    if wait == nil then
        wait = 0.1
    end
    self:Delay(wait, 'Process')
end


function Mail:PrepareOutbox()
    if next(self.should_be_sent) == nil then
        self.placed_to_outbox = true
        self.outbox_prepared = true
        self.sent = true
        self:NextIteration()
        return
    end

    -- Here must be 1 bag operation per cycle. Will use events in the future, now stick with the delay
    local itemID, amount = self:GetUnprocessedItem()
    if itemID == nil then
        Addon:Log('Вещи для отправки готовы')
        self.outbox_prepared = true
        self:NextIteration()
        return
    end

    local bag, slot = self:FindAppropriatePile(itemID, amount)

    if bag == nil then
        bag, slot = self:FindAppropriatePile(itemID, amount, true)
        self:SplitPile(bag, slot, amount)
        self:NextIteration(2)
        return
    end

    self.outbox_slots[#self.outbox_slots + 1] = {bag = bag, slot = slot}
    if self.outbox_total[itemID] == nil then
        self.outbox_total[itemID] = 0
    end
    self.outbox_total[itemID] = self.outbox_total[itemID] + amount
    self:NextIteration()
end


function Mail:PlaceToOutbox()
    MailFrameTab2:Click()

    if #self.outbox_slots == 0 then
        Addon:Log('Все вещи для отправки положены в почту')
        self.placed_to_outbox = true
        self:NextIteration()
        return
    end

    local data = self.outbox_slots[#self.outbox_slots]
    self.outbox_slots[#self.outbox_slots] = nil

    PickupContainerItem(data.bag, data.slot)
    SendMailAttachmentButton_OnDropAny()
    self:NextIteration()
end


function Mail:SplitPile(bag, slot, amount)
    Addon:Log('Разделяю предметы. Необходимо ' .. amount)
    SplitContainerItem(bag, slot, amount)
    local free_bag, free_slot = self:GetFreeBagSlot()

    if free_bag == nil then
        Addon:Log('Не могу разделить итемы - нет пустого слота!')
        return
    end
    PickupContainerItem(free_bag, free_slot)
end


function Mail:GetFreeBagSlot()
    for bag = 0, 4 do
        for slot = 1, GetContainerNumSlots(bag) do
            local id = GetContainerItemID(bag, slot)
            if id == nil then
                return bag, slot
            end
        end
    end

    return nil, nil
end


function Mail:FindAppropriatePile(itemID, amount, allow_greater)
    for bag = 0, 4 do
        for slot = 1, GetContainerNumSlots(bag) do
            local id = GetContainerItemID(bag, slot)
            if id == itemID then
                local _, count = GetContainerItemInfo(bag, slot)
                if count <= amount or count > amount and allow_greater then
                    return bag, slot
                end
            end
        end
    end
end


function Mail:GetUnprocessedItem()
    for itemID, amount in pairs(self.should_be_sent) do
        local _, _, _, _, _, _, _, itemStackCount = GetItemInfo(itemID)

        if self.outbox_total[itemID] == nil then
            return itemID, min(itemStackCount, amount)
        end
        if self.outbox_total[itemID] < amount then
            return itemID, min(itemStackCount, amount - self.outbox_total[itemID])
        end
    end
end

function Mail:DeleteMail()
    Addon:Log('Удаляю письмо')
    DeleteInboxItem(self.index)
    self.deleted = true
    self:NextIteration(2)
end
