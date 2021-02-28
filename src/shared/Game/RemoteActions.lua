-- WRAPPER FUNCTION FOR REQUIRE [BEGIN] --------------------------------------
return function(global)
print "[LOAD] -> shared/Game/RemoteActions"

-- PRIVATE DATA AND HELPER FUNCTIONS [BEGIN] ---------------------------------
local moduleName = 'RemoteActions'
local Assert = global.Assert
local Require = global.Require

local logger = Require.module('/shared/Helpers/Logger'):new(
  { level = 'WARN', warnLevel = 'DEBUG', name = 'RemoteActions' })
-- PRIVATE DATA AND HELPER FUNCTIONS [END] -----------------------------------

-- MODULE DEFINITION [BEGIN] -------------------------------------------------
local module = {}

local typeBalanceUpdated = moduleName .. ":" .. "balanceUpdated"
local typeWagerConcluded = moduleName .. ":" .. 'wagerConcluded'
local typeWagerRequested = moduleName .. ":" .. 'wagerRequested'

module.ACTION_TYPE = {
  balanceUpdated = typeBalanceUpdated,
  wagerConcluded = typeWagerConcluded,
  wagerRequested = typeWagerRequested,
}

function module.balanceUpdated(player, balance)
  return {
    type = typeBalanceUpdated,
    player = player,
    balance = balance,
  }
end

function module.wagerConcluded(player, wagerAmount, earnings)
  return {
    type = typeWagerConcluded,
    player = player,
    earnings = earnings,
    wagerAmount = wagerAmount,
  }
end

function module.wagerRequested(player, wagerAmount)
  return {
    type = typeWagerRequested,
    player = player,
    wagerAmount = wagerAmount,
  }
end

print "[LOAD] <- shared/Game/RemoteActions"
return module
-- MODULE DEFINITION [END] ---------------------------------------------------
end
-- WRAPPER FUNCTION FOR REQUIRE [END] ----------------------------------------