--[[
	constants.lua
		Common constants for the module
--]]

local MODULE =  ...
local ADDON, Addon = MODULE:match('[^_]+'), _G[MODULE:match('[^_]+')]

Addon.constants = {
    bank_icon = 'Interface/ICONS/INV_MISC_BAG_10_BLUE.PNG',
    bank_bag = 'bank_bag',
    purchase_bag = 'purchase_bag',
    items_mock = {
        [0] = {id = 22589},
    }
}


