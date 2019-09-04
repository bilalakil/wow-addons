local function UpdateItemTooltip(tooltip, skipMouseCheck)
  if
    tooltip == GameTooltip and
    GameTooltipMoneyFrame1 and
    GameTooltipMoneyFrame1:IsShown()
  then return end

	local link = select(2, tooltip:GetItem())

	if link then
    local _,_,_,_,_,_,_,_,_,_, sellPrice = GetItemInfo(link)

		if sellPrice and sellPrice > 0 then
			local stackCount = 1

      local frame = GetMouseFocus()
      local objectType = frame:GetObjectType()

      if objectType == "Button" then
        stackCount = frame.count or 1
      end

			SetTooltipMoney(tooltip, sellPrice * stackCount)
		end
	end
end

GameTooltip:HookScript("OnTooltipSetItem", UpdateItemTooltip)
ShoppingTooltip1:HookScript("OnTooltipSetItem", UpdateItemTooltip)
ShoppingTooltip2:HookScript("OnTooltipSetItem", UpdateItemTooltip)
