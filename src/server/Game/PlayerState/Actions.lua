-- WRAPPER FUNCTION FOR REQUIRE [BEGIN] --------------------------------------
return function(global)
print "[LOAD] -> server/Game/PlayerState/Actions"

-- PRIVATE DATA AND HELPER FUNCTIONS [BEGIN] ---------------------------------
local moduleName = 'PlayerStateActions'
local Assert = global.Assert
local Require = global.Require

local logger = Require.module('/shared/Helpers/Logger'):new(
  { level = 'WARN', warnLevel = 'DEBUG', name = moduleName })
-- PRIVATE DATA AND HELPER FUNCTIONS [END] -----------------------------------

-- MODULE DEFINITION [BEGIN] -------------------------------------------------
local module = {}

local typeBalanceAdjusted = moduleName .. ":" .. 'balanceAdjusted'
local typeBalanceUpdated = moduleName .. ":" .. 'balanceUpdated'
local typePlayerAdded = moduleName .. ":" .. 'playerAdded'
local typePlayerRemoving = moduleName .. ":" .. 'playerRemoving'
local typeWagerConcluded = moduleName .. ":" .. 'wagerConcluded'

module.ACTION_TYPE = {
  balanceAdjusted = typeBalanceAdjusted,
  balanceUpdated = typeBalanceUpdated,
  playerAdded = typePlayerAdded,
  playerRemoving = typePlayerRemoving,
  wagerConcluded = typeWagerConcluded,
}

function module.balanceAdjusted(player, adjustedAmount)
  return {
    type = typeBalanceAdjusted,
    player = player,
    adjustedAmount = adjustedAmount,
  }
end

function module.balanceUpdated(player, balance)
  return {
    type = typeBalanceUpdated,
    player = player,
    balance = balance,
  }
end

function module.playerAdded(player)
  return {
    type = typePlayerAdded,
    player = player,
  }
end

function module.playerRemoving(player)
  return {
    type = typePlayerRemoving,
    player = player,
  }
end

function module.wagerConcluded(player, wagerAmount, earnings)
  return {
    type = typeWagerConcluded,
    player = player,
    wagerAmount = wagerAmount,
    earnings = earnings,
  }
end

print "[LOAD] <- server/Game/PlayerState/Actions"
return module
-- MODULE DEFINITION [END] ---------------------------------------------------
end
-- WRAPPER FUNCTION FOR REQUIRE [END] ----------------------------------------