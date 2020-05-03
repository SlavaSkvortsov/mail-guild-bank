--[[
	sendBackMail.lua
		This mail will be returned to sender
--]]

local MODULE = ...
local ADDON, Addon = MODULE:match('[^_]+'), _G[MODULE:match('[^_]+')]
local SendBackMail = Addon.Mail:NewClass('SendBackMail', 'Frame')


function SendBackMail:New(sender, index)
    local mail = self:Super(SendBackMail):New(sender, index)
    mail.sentBack = false

    return mail
end


function SendBackMail:Process()
    if not self.sentBack then
        self:SendBack()
        return
    end

    self.processed = true
end


function SendBackMail:SendBack()
    ReturnInboxItem(self.index)
    self.sentBack = true
    self:NextIteration(2)
end