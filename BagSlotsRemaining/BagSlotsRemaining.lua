local frame = CreateFrame("Frame")

local FONT, FONT_SIZE = _G["TextStatusBarText"]:GetFont()

local text = MainMenuBarBackpackButton:CreateFontString(nil, "OVERLAY")
text:SetFont(FONT, FONT_SIZE, "OUTLINE")
text:SetPoint("BOTTOMRIGHT", -2, 2)

local function UpdateSlotsRemaining()
  local totalSlotsRemaining = 0
  for i = 0, NUM_BAG_SLOTS do
    local slotsRemaining, bagType = GetContainerNumFreeSlots(i)
    if bagType == 0 then
      totalSlotsRemaining = totalSlotsRemaining + slotsRemaining
    end
  end

  text:SetFormattedText("%d", totalSlotsRemaining)
end
UpdateSlotsRemaining()

frame:SetScript("OnEvent", UpdateSlotsRemaining)
frame:RegisterEvent("BAG_UPDATE")
frame:RegisterEvent("PLAYER_LOGIN")
