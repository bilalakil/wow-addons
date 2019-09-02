local class = UnitClass("player")
if class ~= "Rogue" then return end

local BAR_WIDTH = 100
local BAR_HEIGHT = 20
local BAR_INSET = 3
local STATUS_BAR_WIDTH = BAR_WIDTH - BAR_INSET * 2

local FONT, FONT_SIZE = _G["SystemFont_Small"]:GetFont()
local TICK_TIME = 2.0

local bar = CreateFrame("Frame", nil, UIParent)
bar:SetSize(BAR_WIDTH, BAR_HEIGHT)
bar:SetPoint("CENTER", 0, -125)
bar:SetBackdrop({
  bgFile = "Interface/Tooltips/UI-Tooltip-Background",
  insets = {
    left = BAR_INSET,
    right = BAR_INSET,
    top = BAR_INSET,
    bottom = BAR_INSET
  }
})
bar:SetBackdropColor(0, 0, 0)
bar:Hide()

local barBorder = bar:CreateTexture("EnergyTickerBarBorder", "OVERLAY")
barBorder:SetSize(BAR_WIDTH, BAR_HEIGHT)
barBorder:SetTexture("Interface\\Tooltips\\UI-StatusBar-Border")
barBorder:SetPoint("CENTER", 0, 0)

local energy = CreateFrame("StatusBar", nil, bar)
energy:SetSize(STATUS_BAR_WIDTH, BAR_HEIGHT - BAR_INSET * 2)
energy:SetPoint("CENTER", 0, 0)
energy:SetFrameLevel(bar:GetFrameLevel())
energy:SetStatusBarTexture("Interface\\TARGETINGFRAME\\UI-StatusBar")
energy:SetStatusBarColor(1, 1, 0)
energy:SetMinMaxValues(0, 100)
energy:SetValue(0)

local spark = energy:CreateTexture(nil, "OVERLAY")
spark:SetTexture("Interface\\CastingBar\\UI-CastingBar-Spark")
spark:SetPoint("CENTER", energy, "LEFT")
spark:SetWidth(10)
spark:SetBlendMode("ADD")

local text = energy:CreateFontString(nil, "ARTWORK")
text:SetTextColor(1,1,1,1)
text:SetAllPoints()
text:SetJustifyH("CENTER")
text:SetFont(FONT, FONT_SIZE, "OUTLINE")

local tickEnd = -1
bar:SetScript(
  "OnUpdate",
  function ()
    if tickEnd == -1 then return end

    local time = GetTime()
    if time > tickEnd then tickEnd = time + TICK_TIME end

    local pctComplete = 1 - (tickEnd - time) / TICK_TIME
    spark:SetPoint("CENTER", energy, "LEFT", STATUS_BAR_WIDTH * pctComplete, 0)
  end
)

local events = {}
bar:SetScript(
  "OnEvent",
  function (self, event, ...)
    if events[event] then
      return events[event](self, event, ...)
    end
  end
)

local prevEnergy = 100
function events:UNIT_POWER_UPDATE(self, event, power)
  if (power == "ENERGY") then
    local curEnergy = UnitPower("player")
    energy:SetValue(curEnergy)
    text:SetText(curEnergy)

    if curEnergy > prevEnergy then
      tickEnd = GetTime() + TICK_TIME
      bar:Show()
    end
    prevEnergy = curEnergy
  end
end

for k, v in pairs(events) do
  bar:RegisterEvent(k)
end
