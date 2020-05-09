--[[
	item.lua
		A guild bank item slot button
--]]

local MODULE =  ...
local ADDON, Addon = MODULE:match('[^_]+'), _G[MODULE:match('[^_]+')]
local Item = Addon.Item:NewClass('GBItem')

--[[ New ]]--

function Item:New(parent, bag, slot)
	local b = self:Super(Item):New(parent, bag, slot)
	b.slot = slot
	return b
end

--[[ Construct ]]--

function Item:Construct()
	local b = self:Super(Item):Construct()
	b:SetScript('OnReceiveDrag', self.OnDragStart)
	b:SetScript('OnDragStart', self.OnDragStart)
	b:SetScript('OnClick', self.OnClick)
	b:SetScript('PreClick', nil)
	return b
end


function Item:GetBlizzard(id) end
function Item:IsQuestItem() end
function Item:IsNew() end
function Item:IsNewItem(bag, slot) return false end
function Item:IsPaid() end
function Item:IsUpgrade() end
function Item:UpdateSlotColor() end
function Item:UpdateCooldown() end

function Item:ShowTooltip()
    if self.info.link == nil then
        return
    end
	GameTooltip:SetOwner(self:GetTipAnchor())
    GameTooltip:SetHyperlink(self.info.link);
	local price = self:GetPrice()
	if price ~= nil then
		GameTooltip:AddLine('Цена - ' .. self:GetPrice() .. ' BP')
	else
		GameTooltip:AddLine('Цена не известна, не продается')
	end
	GameTooltip:Show()
	CursorUpdate(self)

	if IsModifiedClick('DRESSUP') then
		ShowInspectCursor()
	end
end

function Item:GetID()
    return self.info.id
end

function Item:GetPrice()
    return MailGuildBankData.price[self.info.id]
end

function Item:OnClick(button)
	if self.bag == Addon.constants.purchase_bag then
		local item = Addon.purchase_items[self.slot]
		if item == nil then
			return
		end
		if IsShiftKeyDown() or item.count == 1 then
			Addon.purchase_items[self.slot] = nil
		else
			item.count = item.count - 1
		end
	else
		local item_id = MailGuildBankData.person[Addon.default_bank][self.slot]
		local amount = 1
		if IsShiftKeyDown() then
			amount = select(8, GetItemInfo(item_id))
		end
		self:AddPurchase(item_id, amount)
	end
	Addon:SendSignal('UPDATE_ALL')
end

function Item:AddPurchase(item_id, amount)
	for _slot, item in pairs(Addon.purchase_items) do
		if item.id == item_id then
			if item.count + amount < item.stack then
				item.count = item.count + amount
				return
			elseif item.count < item.stack then
				amount = amount - (item.stack - item.count)
				item.count = item.stack
			end
		end
	end

	local free_slot = Addon:GetFreeSlot(Addon.purchase_items)
	if free_slot > 12 then
		print('Нельзя за раз запросить больше 12 предметов')
		return
	end

	local item_data = Addon:RestoreItemData({id = item_id})
	item_data.count = amount
	Addon.purchase_items[free_slot] = item_data
	return
end