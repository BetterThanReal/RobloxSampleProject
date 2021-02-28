-- WRAPPER FUNCTION FOR REQUIRE [BEGIN] --------------------------------------
return function(global)
print "[LOAD] -> client/Game/Gui/Main/Actions"

-- PRIVATE DATA AND HELPER FUNCTIONS [BEGIN] ---------------------------------
local moduleName = 'MainGuiActions'
local Assert = global.Assert
local Require = global.Require

local logger = Require.module('/shared/Helpers/Logger'):new(
  { level = 'WARN', warnLevel = 'DEBUG', name = 'MainGuiActions' })
-- PRIVATE DATA AND HELPER FUNCTIONS [END] -----------------------------------

-- MODULE DEFINITION [BEGIN] -------------------------------------------------
local module = {}

local actionTypeWagerConcluded = moduleName .. ":" .. 'wagerConcluded'
local actionTypeWagerDecreased = moduleName .. ":" .. 'wagerDecreased'
local actionTypeWagerIncreased = moduleName .. ":" .. 'wagerIncreased'
local actionTypeWagerRequested = moduleName .. ":" .. 'wagerRequested'

module.ACTION_TYPE = {
  wagerConcluded = actionTypeWagerConcluded,
  wagerDecreased = actionTypeWagerDecreased,
  wagerIncreased = actionTypeWagerIncreased,
  wagerRequested = actionTypeWagerRequested,
}

function module.wagerConcluded()
  return {
    type = actionTypeWagerConcluded,
  }
end

function module.wagerDecreased(amount)
  return {
    type = actionTypeWagerDecreased,
    amount = amount,
  }
end

function module.wagerIncreased(amount)
  return {
    type = actionTypeWagerIncreased,
    amount = amount,
  }
end

function module.wagerRequested()
  return {
    type = actionTypeWagerRequested,
  }
end

print "[LOAD] <- client/Game/Gui/Main/Actions"
return module
-- MODULE DEFINITION [END] ---------------------------------------------------
end
-- WRAPPER FUNCTION FOR REQUIRE [END] ----------------------------------------