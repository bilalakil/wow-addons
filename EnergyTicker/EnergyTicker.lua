-- TODO: Support Druid in cat form
local class = UnitClass("player")
if class ~= "Rogue" then return end

local TICK_TIME = 2.0

local frame = CreateFrame("Frame")
local bar
local energy
local text
local spark
local sparkWidth

local function InitEnergyTickerBar()
  local FONT, FONT_SIZE = _G["TextStatusBarText"]:GetFont()
  local BAR_WIDTH = 100
  local BAR_HEIGHT = 20
  local BAR_INSET = 3
  local STATUS_BAR_WIDTH = BAR_WIDTH - BAR_INSET * 2

  bar = CreateFrame("Frame", nil, UIParent)
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

  local barBorder = bar:CreateTexture(nil, "OVERLAY")
  barBorder:SetSize(BAR_WIDTH, BAR_HEIGHT)
  barBorder:SetTexture("Interface\\Tooltips\\UI-StatusBar-Border")
  barBorder:SetPoint("CENTER", 0, 0)

  energy = CreateFrame("StatusBar", nil, bar)
  energy:SetSize(STATUS_BAR_WIDTH, BAR_HEIGHT - BAR_INSET * 2)
  energy:SetPoint("CENTER", 0, 0)
  energy:SetFrameLevel(bar:GetFrameLevel())
  energy:SetStatusBarTexture("Interface\\TARGETINGFRAME\\UI-StatusBar")
  energy:SetStatusBarColor(1, 1, 0)
  energy:SetMinMaxValues(0, 100)
  energy:SetValue(0)

  spark = energy:CreateTexture(nil, "OVERLAY")
  spark:SetTexture("Interface\\CastingBar\\UI-CastingBar-Spark")
  spark:SetPoint("CENTER", energy, "LEFT")
  spark:SetWidth(10)
  spark:SetBlendMode("ADD")

  text = energy:CreateFontString(nil, "OVERLAY")
  text:SetTextColor(1,1,1,1)
  text:SetAllPoints()
  text:SetJustifyH("CENTER")
  text:SetFont(FONT, FONT_SIZE, "OUTLINE")

  sparkWidth = STATUS_BAR_WIDTH
end

local function InitPlayerFrameEnergyTicker()
  spark = PlayerFrameManaBar:CreateTexture(nil, "OVERLAY")
  spark:SetTexture("Interface\\CastingBar\\UI-CastingBar-Spark")
  spark:SetPoint("CENTER", PlayerFrameManaBar, "LEFT")
  spark:SetSize(10, 20)
  spark:SetBlendMode("ADD")
  spark:Hide()

  sparkWidth = PlayerFrameManaBar:GetWidth()
end

local tickEnd = -1
frame:SetScript(
  "OnUpdate",
  function ()
    if tickEnd == -1 then return end

    local time = GetTime()
    if time > tickEnd then tickEnd = time + TICK_TIME end

    local pctComplete = 1 - (tickEnd - time) / TICK_TIME
    spark:SetPoint(
      "CENTER",
      IsOnCharacterFrame and PlayerFrameManaBar or energy,
      "LEFT",
      sparkWidth * pctComplete,
      0
    )
  end
)

local prevEnergy = 100
frame:SetScript(
  "OnEvent",
  function (self, event, arg1, power)
    if event == "ADDON_LOADED" and arg1 == "EnergyTicker" then
      if IsOnCharacterFrame or IsOnCharacterFrame == nil then
        IsOnCharacterFrame = true
        InitPlayerFrameEnergyTicker()
      else
        InitEnergyTickerBar()
      end
    elseif
      event == "UNIT_POWER_UPDATE" and
      arg1 == "player" and
      power == "ENERGY"
    then
      local curEnergy = UnitPower("player")

      if curEnergy > prevEnergy then
        tickEnd = GetTime() + TICK_TIME
        spark:Show()

        if not IsOnCharacterFrame then
          bar:Show()
          energy:SetValue(curEnergy)
          text:SetText(curEnergy)
        end
      end
      prevEnergy = curEnergy
    end
  end
)
frame:RegisterEvent("ADDON_LOADED")
frame:RegisterEvent("UNIT_POWER_UPDATE")

SLASH_ENERGYTICKER1 = "/energyticker";
function SlashCmdList.ENERGYTICKER(msg)
  if msg == "toggle" then
    IsOnCharacterFrame = not IsOnCharacterFrame
    ReloadUI()
  else
    print("\"/energyticker toggle\": Toggle bar vs player frame display")
  end
end
