--[[
	itemGroup.lua
		Base group for bank and for the purchace
		TODO It would be useful to split bank and purchace for 2 different classes
--]]

local MODULE =  ...
local ADDON, Addon = MODULE:match('[^_]+'), _G[MODULE:match('[^_]+')]
local Group = Addon.ItemGroup:NewClass('GBItemGroup')
Group.Button = Addon.GuildBankItem


--[[ Overrides ]]--

function Group:New(parent, bags, title)
	local f = self:Super(Group):New(parent, bags)
	f.Title = f:CreateFontString(nil, nil, 'GameFontHighlight')
	f.Title:SetPoint('BOTTOMLEFT', f, 'TOPLEFT', 0, 5)
	f.Title:SetText(title)
	f.Transposed = false
	return f
end

function Group:RegisterEvents()
end

function Group:Layout()
	self:Super(Group):Layout()

	if self.Title:GetText() then
		local anyItems = self:NumButtons() > 0
		self:SetHeight(self:GetHeight() + (anyItems and 20 or 0))
		self.Title:SetShown(anyItems)
	end
end


--[[ Properties ]]--

function Group:NumSlots(bag)
	if bag == Addon.constants.purchase_bag then
		return 2
	end
	-- TODO Get from the banker ??
	return 16
end

function Group:GetType()
	return self.bags[1].id  -- TODO WTF?
end
