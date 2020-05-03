--[[
	bank_points_frame.lua
		A frame for the current value of BankPoints
--]]

local MODULE =  ...
local ADDON, Addon = MODULE:match('[^_]+'), _G[MODULE:match('[^_]+')]
local BankPointsFrame = Addon.Parented:NewClass('BankPointsFrame', 'Frame')


--[[ Construct ]]--

function BankPointsFrame:New(parent)
	local f = self:Super(BankPointsFrame):New(parent)
	f.text = f:CreateFontString(nil, nil, 'GameFontHighlight')
	f.text:SetPoint('BOTTOMRIGHT', f, 'BOTTOMRIGHT', 0, 0)
	f:RegisterEvents()
	return f
end

function BankPointsFrame:Construct()
	local f = self:Super(BankPointsFrame):Construct()
	f:SetScript('OnShow', f.RegisterEvents)
	f:SetScript('OnHide', f.UnregisterAll)
	f:SetScript('OnEvent', nil)
	f:SetHeight(24)

	return f
end

function BankPointsFrame:RegisterEvents()
	self:RegisterFrameSignal('OWNER_CHANGED', 'Update')

    -- TODO Guild note changed
	self:RegisterEvent('PLAYER_MONEY', 'Update')
	self:Update()
end


function BankPointsFrame:Update()
    self.text:SetText('Всего ' .. Addon:GetBP() .. ' BP')
end
