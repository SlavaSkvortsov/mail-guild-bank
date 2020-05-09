--[[
	purchase.lua
		Code for handling one purchase
--]]

local MODULE = ...
local ADDON, Addon = MODULE:match('[^_]+'), _G[MODULE:match('[^_]+')]
local Purchase = Addon.Mail:NewClass('Purchase', 'Frame')


function Purchase:New(request, sender, index)
    local purchase = self:Super(Purchase):New(sender, index)

    purchase.sorted = false
    purchase.warehouseBrowsed = false
    purchase.bpChanged = false
    purchase.itemsChecked = false

    purchase.should_be_sent = request
    purchase.message = nil
    purchase.missingItems = nil
    purchase:RegisterSignal('SORTING_STATUS', 'CheckSorted')

    return purchase
end


function Purchase:Process()
    if not self.sorted then
        Addon.Sorting:Start(Addon:NormilizeName(UnitName('player')), {0, 1, 2, 3, 4}, 'ITEM_UNLOCKED')
        return
    end

    if not self.warehouseBrowsed then
        self:BrowseWarehouse()
        return
    end

    if not self.itemsChecked then
        self:CheckItems()
        return
    end

    if not self.outbox_prepared then
        self:PrepareOutbox()
        return
    end

    if not self.placed_to_outbox then
        self:PlaceToOutbox()
        return
    end

    if not self.bpChanged then
        self:ChangeBP()
        return
    end

    if not self.sent then
        self:SendMail()
        return
    end

    if not self.deleted then
        self:DeleteMail()
        return
    end

    Addon:Log('Готово!')
    self.processed = true
end


function Purchase:CheckSorted(_, _, bags)
    if bags == nil then
        self.sorted = true
        self:NextIteration()
    end
end


function Purchase:BrowseWarehouse()
    if self.missingItems == nil then
        self:FindMissingItems()
    end

    if next(self.missingItems) == nil then
        self.warehouseBrowsed = true
        self:NextIteration()
        return
    end

	for index = 1, GetInboxNumItems() do
		local subject = select(4, GetInboxHeaderInfo(index))
        if subject == 'Склад!' then
            for slot = 1, 16 do
                if HasInboxItem(index, slot) then
                    local _, itemID, _, count = GetInboxItem(index, slot)
                    if self.missingItems[itemID] ~= nil then
                        if count > self.missingItems[itemID] then
                            self.missingItems[itemID] = nil
                        else
                            self.missingItems[itemID] = self.missingItems[itemID] - count
                        end

                        Addon:Log('Нашел на складе ' .. itemID .. ' в размере ' .. count .. ' штук')
                        TakeInboxItem(index, slot)
                        self:NextIteration(2)
                        return
                    end
                end
            end
        end
    end

    self.warehouseBrowsed = true
    self:NextIteration()
end


function Purchase:FindMissingItems()
    local items = self:GetItems()
    self.missingItems = {}

    for itemID, count in pairs(self.should_be_sent) do
        local needMore = self:IsEnoughItems(itemID, count, items)
        if needMore > 0 then
            self.missingItems[itemID] = needMore
        end
    end
end

function Purchase:CheckItems()
    if next(self.missingItems) == nil then
        self.itemsChecked = true
        self:NextIteration()
        return
    end

    local msg = ''
    for itemID, required in pairs(self.missingItems) do
        local name = GetItemInfo(itemID)
        if name == nil then
            name = itemID
        end
        msg = msg .. '\n ' .. name .. ' x ' .. required
        if self.should_be_sent[itemID] == required then
            self.should_be_sent[itemID] = nil
        else
            self.should_be_sent[itemID] = self.should_be_sent[itemID] - required
        end
    end

    msg = 'К сожалению, в банке не хватает некоторых предметов из Вашего заказа, а именно:' .. msg
    if next(self.should_be_sent) ~= nil then
        msg = msg .. '\nОстальное будет доставлено через час'
    end
    SendMail(self.sender, 'Невозможно полностью выполнить заказ', msg)

    self.itemsChecked = true
    self:NextIteration(2)
end

function Purchase:IsEnoughItems(itemID, count, items)
    if items[itemID] == nil or items[itemID] < count then
        local haveItems = items[itemID] or 0
        return count - haveItems
    end
    return 0
end


function Purchase:GetItems()
    local items = {}
    for bag = 0, 4 do
        for slot = 1, GetContainerNumSlots(bag) do
            local id = GetContainerItemID(bag, slot)
            if id ~= nil then
                if items[id] == nil then
                    items[id] = 0
                end

                local _, count = GetContainerItemInfo(bag, slot)
                items[id] = items[id] + count
            end
        end
    end
    return items
end


function Purchase:ChangeBP()
    Addon:Log('Изменяю значение BP')
    local total_bp = 0
    for itemID, count in pairs(self.should_be_sent) do
        total_bp = total_bp + MailGuildBankData.price[itemID] * count
    end

    Addon:ChangeBP(self.sender, -total_bp)
    self.bpChanged = true
    self:NextIteration()
end


function Purchase:SendMail()
    Addon:Log('Отправляю заказ')
    SendMail(self.sender, 'Заказ')
    self.sent = true
    self:NextIteration(2)
end