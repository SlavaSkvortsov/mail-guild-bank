--[[
	openButton.lua
		Button for GB opening, avaliable from a mailbox
--]]

local MODULE =  ...
local ADDON, Addon = MODULE:match('[^_]+'), _G[MODULE:match('[^_]+')]
local OpenButton = Addon.Tipped:NewClass('OpenButton', 'Button')

--[[ New ]]--
function OpenButton:New(...)
	local button = self:Super(OpenButton):New(...)
	button:SetPoint('TOPRIGHT', -60, -25)

	button:SetScript('OnEnter', button.OnEnter)
	button:SetScript('OnLeave', button.OnLeave)
	button:SetScript('OnClick', button.OnClick)

	return button
end


--[[ Construct ]]--
function OpenButton:Construct()
	local button = self:Super(OpenButton):Construct()

	local texture = button:CreateTexture()
	texture:SetTexture(Addon.constants.bank_icon)
	texture:SetAllPoints(button)
	button.texture = texture

	button:SetSize(32, 32)

	return button
end

function OpenButton:OnEnter()
	GameTooltip:SetOwner(self:GetTipAnchor())
	GameTooltip:SetText('Открыть банк гильдии')
	GameTooltip:Show()
end

--[[ Events ]]--

function OpenButton:OnClick()
	Addon.Frames:Toggle('mail_guild_bank')
end


--[[ Update ]]--

-- TODO Perform it on a mailbox openning. Close the frame with the mailbox closing
local button = Addon.OpenButton:New(InboxFrame)
button:Show()