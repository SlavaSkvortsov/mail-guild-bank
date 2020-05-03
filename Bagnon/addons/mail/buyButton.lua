--[[
	buyButton.lua
		A frame for the button to perform a purchase
--]]

local MODULE =  ...
local ADDON, Addon = MODULE:match('[^_]+'), _G[MODULE:match('[^_]+')]
local BuyButton = Addon.Tipped:NewClass('BuyButton', 'Button', 'GameMenuButtonTemplate')


function BuyButton:New(...)
	local button = self:Super(BuyButton):New(...)
	button:SetScript('OnClick', button.OnClick)
    button:SetText('Купить')
	button:SetSize(64, 32)

	return button
end


function BuyButton:OnClick()
    local sum = Addon:GetPurchaseSum()
    local total = Addon:GetBP()
    if sum > total then
        print('У Вас не хватает BP для совершения этой покупки')
        return
    end

    local body = self:GetBody()
    if body == '' then
        print('Ваша корзина пуста :(')
        return
    end

    local banker = self:GetBanker()
    if banker == nil then
        print('Банкир не опознан. Релогнитесь и попробуйте еще раз')
        return
    end

    SendMail(banker, "Покупка!", body)
    print('Ваш заказ отправлен!')
    Addon.purchase_items = {}
    Addon:SendSignal('UPDATE_ALL')
end

function BuyButton:GetBody()
    local result = ''
	for _slot, item in pairs(Addon.purchase_items) do
        if result ~= '' then
            result = result .. ';'
        end
		result = result .. item.id .. 'x' .. item.count
    end

    return result
end

function BuyButton:GetBanker()
    return Addon.default_bank
end