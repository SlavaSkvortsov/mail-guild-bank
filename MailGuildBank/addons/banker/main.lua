--[[
	main.lua
		Receiving new mails, sending orders
--]]

local MODULE = ...
local ADDON, Addon = MODULE:match('[^_]+'), _G[MODULE:match('[^_]+')]
local Main = Addon.Parented:NewClass('Main', 'Frame')


function Addon:OnMailShow()
    local main = Main(InboxFrame)
    main:MainLoop()
end

Addon:RegisterEvent('MAIL_SHOW', 'OnMailShow')


function Main:New(parent)
    local main = self:Super(Main):New(parent)
    main.mail_in_process = nil
    return main
end


function Main:MainLoop()
    if not MailFrame:IsVisible() then
        return
    end
    if self.mail_in_process ~= nil then
        if self.mail_in_process.processed then
            self.mail_in_process = nil
        end
    else
        local mail = self:GetMailToProcess()
        if mail ~= nil then
            self.mail_in_process = mail
            self.mail_in_process:Process()
        else
            CheckInbox();
        end
    end
    self:Delay(5, 'MainLoop')
end

function Main:GetMailToProcess()
	for i = 1, GetInboxNumItems() do
		local _, _, sender, subject = GetInboxHeaderInfo(i)
        if sender then
            if subject == 'Покупка!' then
                Addon:Log('Найдена покупка от игрока ' .. sender)
                local text = GetInboxText(i)
                Addon:Log('Текст ' .. text)
                local request = self:ExtractRequestItemsFromMessage(text)
                return Addon.Purchase(request, sender, i)
            elseif subject == 'Вклад!' then
                Addon:Log('Найдена вклад от игрока ' .. sender)
                return Addon.Deposit(sender, i)
            elseif subject == 'Склад!' then
                local hasItems = false
                for slot = 1, 16 do
                    hasItems = hasItems or HasInboxItem(i, slot)
                end
                if not hasItems then
                    return Addon.RemoveMail(sender, i)
                end
            else
                return Addon.SendBackMail(sender, i)
            end
        end
    end
end


function Main:ExtractRequestItemsFromMessage(text)
    local result = {}
    local items = Addon:Split(text, ';')
    for _, item in pairs(items) do
        local data = Addon:Split(item, 'x')
        local itemID, count = tonumber(data[1]), tonumber(data[2])
        if result[itemID] == nil then
            result[itemID] = 0
        end
        result[itemID] = result[itemID] + count
    end
    
    return result
end
