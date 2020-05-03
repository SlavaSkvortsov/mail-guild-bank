--[[
	frame.lua
		A specialized version of the window frame for void storage
--]]

local MODULE =  ...
local ADDON, Addon = MODULE:match('[^_]+'), _G[MODULE:match('[^_]+')]
local Frame = Addon.Frame:NewClass('Mail_guild_bankFrame')

Frame.Title = 'Гильдбанк'
Frame.OpenSound = SOUNDKIT.UI_ETHEREAL_WINDOW_OPEN
Frame.CloseSound = SOUNDKIT.UI_ETHEREAL_WINDOW_CLOSE
Frame.ItemGroup = Addon.GBItemGroup
Frame.BankPointsFrame = Addon.BankPointsFrame
Frame.MoneySpacing = 30
Frame.BrokerSpacing = 2
Frame.Bags = {Addon.constants.bank_bag}


--[[ Overrides ]]--

function Frame:New(id)
	local f = self:Super(Frame):New(id)
	f.purchase = self.ItemGroup(f, {Addon.constants.purchase_bag}, true)
	f.purchase:SetPoint('TOPLEFT', f.itemGroup, 'BOTTOMLEFT', 0, -5)
	return f
end

function Frame:OnHide()
	self:Super(Frame):OnHide()
	Addon.purchase_items = {}
end


function Frame:RegisterSignals()
	self:RegisterEvent('MAIL_CLOSED', 'Hide')
	self:RegisterSignal('UPDATE_ALL', 'Update')
	self:RegisterFrameSignal('ITEM_FRAME_RESIZED', 'Layout')
	self:Update()
end


function Frame:Layout()
	local width, height = 44, 36

	--place top menu frames
	width = width + self:PlaceMenuButtons()
	width = width + self:PlaceOptionsToggle()
	width = width + self:PlaceTitle()
	self:PlaceSearchFrame()

	--place middle frames
	local w, h = self:PlaceBagGroup()
	width = max(w, width)
	height = height + h

	local w, h = self:PlaceItemGroup()
	width = max(w, width)
	height = height + h

	--place bottom menu frames
	local w, h = self:PlaceBankPointsFrame()
	width = max(w, width)
	height = height + h

	--place purchase bag
	local w, h = self:PlacePurchaseGroup()
	width = max(w, width)
	height = height + h

	--place buy button
	local w, h = self:PlaceBuyButton()
	width = max(w, width)
	height = height + h

	--adjust size
	self:SetSize(max(width, 156) + 16, height)
end

function Frame:PlaceBankPointsFrame()
	if self.bank_points_frame == nil then
		self.bank_points_frame = self.BankPointsFrame(self)
	end
	self.bank_points_frame:ClearAllPoints()
	self.bank_points_frame:SetWidth(self.purchase:GetWidth())
	self.bank_points_frame:SetPoint('BOTTOMRIGHT', self.purchase, 'TOPRIGHT', 0, 0)
	self.bank_points_frame:Show()

	return self.bank_points_frame:GetSize()
end


function Frame:PlacePurchaseGroup()
	local title_height = self.purchase.Title:GetHeight();
	self.purchase:SetPoint('TOPLEFT', self.itemGroup, 'BOTTOMLEFT', 0, -4 - title_height)
	return self.purchase:GetWidth() - 2, self.purchase:GetHeight()
end


function Frame:PlaceBuyButton()
	if self.buyButton == nil then
		self.buyButton = Addon.BuyButton:New(self)
		self.buyButton:Show()
	end
	self.buyButton:SetPoint('TOPLEFT', self.purchase, 'BOTTOMLEFT', 0, -4)
	return self.buyButton:GetWidth(), self.buyButton:GetHeight()
end


function Frame:GetItemInfo(bag, slot)
	local data = {}
    if bag == Addon.constants.purchase_bag then
        data = Addon.purchase_items[slot]
	elseif bag == Addon.constants.bank_bag then
		data = {id = MailGuildBankData.person[Addon.default_bank][slot]}
	end

	if data == nil or data.id == nil then
		return {}
	end

    local restored_data = Addon:RestoreItemData(data)
	restored_data.count = data.count or 1
	return restored_data
end


--[[ Properties ]]--
function Frame:IsBagGroupShown() end
function Frame:HasBagToggle() end
function Frame:HasMoneyFrame()
	return true
end

function Frame:IsCached()
	return false
end
