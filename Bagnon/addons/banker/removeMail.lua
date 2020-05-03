--[[
	removeMail.lua
		This mail will be deleted
--]]

local MODULE = ...
local ADDON, Addon = MODULE:match('[^_]+'), _G[MODULE:match('[^_]+')]
local RemoveMail = Addon.Mail:NewClass('RemoveMail', 'Frame')


function RemoveMail:Process()
    if not self.deleted then
        self:DeleteMail()
        return
    end

    self.processed = true
end
