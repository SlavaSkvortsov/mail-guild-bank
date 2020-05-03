--[[
	warehouseButton.lua
		A frame for the button to open send mail frame with prepared name and body of the mail
--]]

local MODULE =  ...
local ADDON, Addon = MODULE:match('[^_]+'), _G[MODULE:match('[^_]+')]
local WarehouseButton = Addon.Tipped:NewClass('WarehouseButton', 'Button', 'GameMenuButtonTemplate')


--[[ New ]]--
function WarehouseButton:New(...)
	local button = self:Super(WarehouseButton):New(...)
	button:SetPoint('TOPLEFT', 80, -25)

	button:SetScript('OnEnter', button.OnEnter)
	button:SetScript('OnLeave', button.OnLeave)
	button:SetScript('OnClick', button.OnClick)

	return button
end


--[[ Construct ]]--
function WarehouseButton:Construct()
	local button = self:Super(WarehouseButton):Construct()

	local texture = button:CreateTexture()
	texture:SetTexture('Interface/ICONS/Ability_Creature_Cursed_01.PNG')
	texture:SetAllPoints(button)
	button.texture = texture

	button:SetSize(32, 32)

	return button
end

function WarehouseButton:OnEnter()
	GameTooltip:SetOwner(self:GetTipAnchor())
	GameTooltip:SetText('Отправить на склад')
	GameTooltip:Show()
end

--[[ Events ]]--

function WarehouseButton:OnClick()
	MailFrameTab2:Click()
	SendMailNameEditBox:SetText(Addon.default_bank)
	SendMailBodyEditBox:SetText('Я понимаю, что за это мне не дадут очков. НЕ УДАЛЯТЬ ЭТОТ ТЕКСТ!')
	SendMailSubjectEditBox:SetText('Склад!')
end

local button = Addon.WarehouseButton:New(InboxFrame)
button:Show()