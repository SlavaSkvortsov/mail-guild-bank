--[[
	constants.lua
		Common constants for the module
--]]

local MODULE =  ...
local ADDON, Addon = MODULE:match('[^_]+'), _G[MODULE:match('[^_]+')]

Addon.constants = {
    bank_icon = 'Interface/ICONS/INV_MISC_BAG_10_BLUE.PNG',
    deposit_icon = 'Interface/ICONS/Ability_TheBlackArrow.PNG',
    bank_bag = 'bank_bag',
    purchase_bag = 'purchase_bag',
}


Addon.channel = {
    party = 'PARTY',
    raid = 'RAID',
    guild = 'GUILD',
    whisper = 'WHISPER',
}
