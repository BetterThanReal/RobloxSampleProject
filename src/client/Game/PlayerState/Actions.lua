-- WRAPPER FUNCTION FOR REQUIRE [BEGIN] --------------------------------------
return function(global)
print "[LOAD] -> client/Game/PlayerState/Actions"

-- PRIVATE DATA AND HELPER FUNCTIONS [BEGIN] ---------------------------------
local moduleName = 'PlayerStateActions'
local Assert = global.Assert
local Require = global.Require

local logger = Require.module('/shared/Helpers/Logger'):new(
  { level = 'WARN', warnLevel = 'DEBUG', name = moduleName })

local typeBalanceUpdated = moduleName .. ":" .. 'balanceUpdated'
local typeWagerRequested = moduleName .. ":" .. 'wagerRequested'
-- PRIVATE DATA AND HELPER FUNCTIONS [END] -----------------------------------

-- MODULE DEFINITION [BEGIN] -------------------------------------------------
local module = {}

module.ACTION_TYPE = {
  balanceUpdated = typeBalanceUpdated,
  wagerRequested = typeWagerRequested,
}

function module.balanceUpdated(balance)
  return {
    type = typeBalanceUpdated,
    balance = balance,
  }
end

function module.wagerRequested(wagerAmount)
  return {
    type = typeWagerRequested,
    wagerAmount = wagerAmount,
  }
end

print "[LOAD] <- client/Game/PlayerState/Actions"
return module
-- MODULE DEFINITION [END] ---------------------------------------------------
end
-- WRAPPER FUNCTION FOR REQUIRE [END] ----------------------------------------