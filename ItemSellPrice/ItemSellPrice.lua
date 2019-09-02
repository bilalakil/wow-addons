local function UpdateItemTooltip(tooltip, isMouseOver)
  if (not isMouseOver) and MerchantFrame:IsShown() then return end

	local link = select(2, tooltip:GetItem())

	if link then
    local _,_,_,_,_,_,_,_,_,_, sellPrice = GetItemInfo(link)

		if sellPrice and sellPrice > 0 then
			local stackCount = 1

			if isMouseOver then
				local frame = GetMouseFocus()
				local objectType = frame:GetObjectType()

				if objectType == "Button" then
					stackCount = frame.count or 1
				end
			end

			SetTooltipMoney(tooltip, sellPrice * stackCount)
		end
	end
end

local function UpdateItemTooltipWithStackCheck(tooltip)
  UpdateItemTooltip(tooltip, true)
end

GameTooltip:HookScript("OnTooltipSetItem", UpdateItemTooltip)
ItemRefTooltip:HookScript("OnTooltipSetItem", UpdateItemTooltipWithStackCheck)
