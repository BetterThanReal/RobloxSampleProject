-- WRAPPER FUNCTION FOR REQUIRE [BEGIN] --------------------------------------
return function(global)
print "[LOAD] -> client/Game/Gui/Main/Reducer"

-- PRIVATE DATA AND HELPER FUNCTIONS [BEGIN] ---------------------------------
local Assert = global.Assert
local Require = global.Require

local logger = Require.module('/shared/Helpers/Logger'):new(
  { level = 'WARN', warnLevel = 'DEBUG', name = 'MainGuiReducer' })

local imports = {
  MainGuiActions = Require.module('/client/Game/Gui/Main/Actions'),
  PlayerStateActions = Require.module('/client/Game/PlayerState/Actions'),
  Reducer = Require.module('/shared/Helpers/Reducer'),
  RoduxEffects = Require.module('/shared/Helpers/RoduxEffects'),
}
-- PRIVATE DATA AND HELPER FUNCTIONS [END] -----------------------------------

-- MODULE DEFINITION [BEGIN] -------------------------------------------------
local module = {}

local minWager, maxWager, incWager = 5, 25, 1

local function getInitialState()
  return {
    isRemoting = false,
    wagerAmount = maxWager,
  }
end

local function getBoundWagerAmount(wagerAmount, balance)
  balance = balance or 0
  local toWager = wagerAmount
  toWager = math.max(toWager, minWager)
  toWager = math.min(toWager, balance, maxWager)
  toWager = math.max(0, toWager)
  return toWager
end

local function onWagerConcluded(state, action, props)
  return {
    isRemoting = false,
  }
end

local function onWagerDecreased(state, action, props)
  return {
    wagerAmount = getBoundWagerAmount(
      state.wagerAmount - incWager, props.balance),
  }
end

local function onWagerIncreased(state, action, props)
  return {
    wagerAmount = getBoundWagerAmount(
      state.wagerAmount + incWager, props.balance),
  }
end

local function onWagerRequested(state, action, props)
  local wagerRequested = imports.PlayerStateActions.wagerRequested
  local wagerAmount = getBoundWagerAmount(
    state.wagerAmount, props.balance)

  return imports.RoduxEffects.add(
    {
      isRemoting = true,
      wagerAmount = wagerAmount,
    },
    wagerRequested(wagerAmount))
end

function module.create(transformer)
  local actions = imports.MainGuiActions
  local handlers = {}
  handlers[actions.ACTION_TYPE.wagerConcluded] = onWagerConcluded
  handlers[actions.ACTION_TYPE.wagerDecreased] = onWagerDecreased
  handlers[actions.ACTION_TYPE.wagerIncreased] = onWagerIncreased
  handlers[actions.ACTION_TYPE.wagerRequested] = onWagerRequested

  -- return imports.Reducer.create(getInitialState(), handlers, transformer)
  return imports.Reducer.create(getInitialState(), handlers)
end

function module.getInitialState()
  return getInitialState()
end

print "[LOAD] <- client/Game/Gui/Main/Reducer"
return module
-- MODULE DEFINITION [END] ---------------------------------------------------
end
-- WRAPPER FUNCTION FOR REQUIRE [END] ----------------------------------------