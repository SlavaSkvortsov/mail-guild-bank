--[[
	depositButton.lua
		A frame for the button to perform a deposit
--]]

local MODULE =  ...
local ADDON, Addon = MODULE:match('[^_]+'), _G[MODULE:match('[^_]+')]
local DepositButton = Addon.Tipped:NewClass('DepositButton', 'Button', 'GameMenuButtonTemplate')


--[[ New ]]--
function DepositButton:New(...)
	local button = self:Super(DepositButton):New(...)
	button:SetPoint('TOPRIGHT', -100, -25)

	button:SetScript('OnEnter', button.OnEnter)
	button:SetScript('OnLeave', button.OnLeave)
	button:SetScript('OnClick', button.OnClick)

	return button
end


--[[ Construct ]]--
function DepositButton:Construct()
	local button = self:Super(DepositButton):Construct()

	local texture = button:CreateTexture()
	texture:SetTexture(Addon.constants.deposit_icon)
	texture:SetAllPoints(button)
	button.texture = texture

	button:SetSize(32, 32)

	return button
end

function DepositButton:OnEnter()
	GameTooltip:SetOwner(self:GetTipAnchor())
	GameTooltip:SetText('Сделать вклад в банк гильдии')
	GameTooltip:Show()
end

--[[ Events ]]--

function DepositButton:OnClick()
	MailFrameTab2:Click()
	SendMailNameEditBox:SetText(Addon.default_bank)
	SendMailSubjectEditBox:SetText('Вклад!')
end

local button = Addon.DepositButton:New(InboxFrame)
button:Show()