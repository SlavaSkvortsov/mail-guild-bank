local MODULE =  ...
local ADDON, Addon = MODULE:match('[^_]+'), _G[MODULE:match('[^_]+')]


Addon.prefix = 'mailGB'


function Addon:GetPurchaseSum()
	if Addon.purchase_items == {} then
		return 0
	end

	local sum = 0
	for _slot, item in pairs(Addon.purchase_items) do
		sum = sum + MailGuildBankData.price[item.id] * item.count
    end
    return sum
end