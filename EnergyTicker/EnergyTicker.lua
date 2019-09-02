-- TODO: Support Druid in cat form
local class = UnitClass("player")
if class ~= "Rogue" then return end

local frame = CreateFrame("Frame")

local FONT, FONT_SIZE = _G["SystemFont_Small"]:GetFont()
local TICK_TIME = 2.0

local spark = PlayerFrameManaBar:CreateTexture(nil, "OVERLAY")
spark:SetTexture("Interface\\CastingBar\\UI-CastingBar-Spark")
spark:SetPoint("CENTER", PlayerFrameManaBar, "LEFT")
spark:SetSize(10, 20)
spark:SetBlendMode("ADD")
spark:Hide()

local barWidth = PlayerFrameManaBar:GetWidth()
local tickEnd = -1
frame:SetScript(
  "OnUpdate",
  function ()
    if tickEnd == -1 then return end

    local time = GetTime()
    if time > tickEnd then tickEnd = time + TICK_TIME end

    local pctComplete = 1 - (tickEnd - time) / TICK_TIME
    spark:SetPoint("CENTER", PlayerFrameManaBar, "LEFT", barWidth * pctComplete, 0)
  end
)

local prevEnergy = 100
frame:SetScript(
  "OnEvent",
  function (self, event, unit, power)
    if unit == "player" and power == "ENERGY" then
      local curEnergy = UnitPower("player")

      if curEnergy > prevEnergy then
        tickEnd = GetTime() + TICK_TIME
        spark:Show()
      end
      prevEnergy = curEnergy
    end
  end
)
frame:RegisterEvent("UNIT_POWER_UPDATE")
