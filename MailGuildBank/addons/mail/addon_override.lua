--[[
	addon_override.lua
		Constant specifics for the addon
--]]

local MODULE =  ...
local ADDON, Addon = MODULE:match('[^_]+'), _G[MODULE:match('[^_]+')]
local ItemCache = LibStub('LibItemCache-2.0')


function Addon:Super()
    return ItemCache
end


function Addon.IsBaseBag(bag)
    return bag ~= Addon.constants.bank_bag and bag ~= Addon.constants.purchase_bag
end


function Addon:GetBagInfo(owner, bag)
    if self.IsBaseBag(bag) then
        return self:Super():GetBagInfo(owner, bag)
    end

    local item = {
        cached = true,
        free = 40,  -- TODO
        count = 50, -- TODO
        icon = Addon.constants.bank_icon,
    }

	return Addon:RestoreItemData(item)
end
