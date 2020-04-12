--[[
	item.lua
		A guild bank item slot button
--]]

local MODULE =  ...
local ADDON, Addon = MODULE:match('[^_]+'), _G[MODULE:match('[^_]+')]
local Item = Addon.Item:NewClass('GuildBankItem')


--[[ Construct ]]--

function Item:Construct()
	local b = self:Super(Item):Construct()
	b:SetScript('OnReceiveDrag', self.OnDragStart)
	b:SetScript('OnDragStart', self.OnDragStart)
	b:SetScript('OnClick', self.OnClick)
	b:SetScript('PreClick', nil)
	return b
end

function Item:GetBlizzard()
end


--[[ Interaction ]]--

function Item:OnClick(button)
	-- TODO What happening here?
	if HandleModifiedItemClick(self.info.link) or self:FlashFind(button) or IsModifiedClick() then
		return
	elseif self:GetBag() == 'bank' then
		local isRight = button == 'RightButton'
		local type, _, link = GetCursorInfo()

		-- TODO Here should be an event of moving from virtual guild
		if not isRight and type == 'item' and link then
			for bag = BACKPACK_CONTAINER, NUM_BAG_SLOTS do
				for slot = 1, GetContainerNumSlots(bag) do
					if GetContainerItemLink(bag, slot) == link then
						UseContainerItem(bag, slot)
					end
				end
			end
		elseif isRight and self.info.locked then
			for i = 1,9 do
				if GetVoidTransferWithdrawalInfo(i) == self.info.id then
					ClickVoidTransferWithdrawalSlot(i, true)
				end
			end
		else
			ClickVoidStorageSlot(1, self:GetID(), isRight)
		end
	end
end

function Item:OnDragStart()
	self:OnClick('LeftButton')
end


--[[ Proprieties ]]--

function Item:IsCached()
	-- TODO Why do we need to cache?
	-- delicious hack: behave as cached (disable interaction) while vault has not been purchased
	return not CanUseVoidStorage() or self:Super(Item):IsCached()
end

function Item:IsQuestItem() end
function Item:IsNew() end
function Item:IsNewItem()
	return false
end
function Item:IsPaid() end
function Item:IsUpgrade() end
function Item:UpdateSlotColor() end
function Item:UpdateCooldown() end
