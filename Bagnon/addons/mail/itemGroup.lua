--[[
	itemGroup.lua
		Base group for bank and for the purchace
		TODO It would be useful to split bank and purchace for 2 different classes
--]]

local MODULE =  ...
local ADDON, Addon = MODULE:match('[^_]+'), _G[MODULE:match('[^_]+')]
local Group = Addon.ItemGroup:NewClass('GBItemGroup')
Group.Button = Addon.GBItem


--[[ Overrides ]]--

function Group:New(parent, bags, set_title)
	local f = self:Super(Group):New(parent, bags)
	if set_title then
		f.Title = f:CreateFontString(nil, nil, 'GameFontHighlight')
		f.Title:SetPoint('BOTTOMLEFT', f, 'TOPLEFT', 0, 5)
		f.Title:SetText(self:GetTitleText())
	end
	f.Transposed = false
	return f
end

function Group:RequestLayout()
	self:Layout()
end

function Group:Layout()
	self:Super(Group):Layout()
	if self.Title ~= nil then
		self.Title:SetText(self:GetTitleText())
	end
end

function Group:GetTitleText()
	return 'Покупка ' .. Addon:GetPurchaseSum() .. ' BP'
end

--[[ Properties ]]--

function Group:NumSlots(bag)
	if bag == Addon.constants.purchase_bag then
		return 12
	end
	local count = 0
	for _, _ in pairs(MailGuildBankData.person[Addon.default_bank]) do
		count = count + 1
	end
	return count
end

function Group:GetType()
	return self.bags[1].id  -- TODO WTF?
end

function Group:IsShowingBag(bag)
	return true
end

function Group:IsShowingItem(bag, slot)
	return true
end