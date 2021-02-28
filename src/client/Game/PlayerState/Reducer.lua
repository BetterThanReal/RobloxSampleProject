-- WRAPPER FUNCTION FOR REQUIRE [BEGIN] --------------------------------------
return function(global)
print "[LOAD] -> client/Game/PlayerState/Reducer"

-- PRIVATE DATA AND HELPER FUNCTIONS [BEGIN] ---------------------------------
local Assert = global.Assert
local Require = global.Require

local logger = Require.module('/shared/Helpers/Logger'):new(
  { level = 'WARN', warnLevel = 'DEBUG', name = 'PlayerStateReducer' })

local imports = {
  MainGuiActions = Require.module('/client/Game/Gui/Main/Actions'),
  PlayerStateActions = Require.module('/client/Game/PlayerState/Actions'),
  Players = Require.service('Players'),
  Reducer = Require.module('/shared/Helpers/Reducer'),
  RemoteActions = Require.module('/shared/Game/RemoteActions'),
  RoduxEffects = Require.module('/shared/Helpers/RoduxEffects'),
  remoteDispatcher = nil, -- to be provided by the invoker of 'module.create'
}
-- PRIVATE DATA AND HELPER FUNCTIONS [END] -----------------------------------

-- MODULE DEFINITION [BEGIN] -------------------------------------------------
local module = {}

local function getInitialState()
  return {
    balance = nil,
  }
end

local function onBalanceUpdated(state, action)
  return {
    balance = action.balance
  }
end

local function onWagerConcluded(state, action)
  return imports.RoduxEffects.add({},
    imports.MainGuiActions.wagerConcluded(action))
end

local function onWagerRequested(state, action)
  local Players = imports.Players

  return imports.RoduxEffects.add({},
    imports.remoteDispatcher(
      imports.RemoteActions.wagerRequested(
        Players.LocalPlayer, action.wagerAmount)))
end

function module.create(remoteDispatcher)
  local actionTypes = imports.PlayerStateActions.ACTION_TYPE
  local remoteTypes = imports.RemoteActions.ACTION_TYPE

  local handlers = {}
  handlers[actionTypes.wagerRequested] = onWagerRequested
  handlers[remoteTypes.balanceUpdated] = onBalanceUpdated
  handlers[remoteTypes.wagerConcluded] = onWagerConcluded

  imports.remoteDispatcher = remoteDispatcher
  return imports.Reducer.create(getInitialState(), handlers)
end

function module.getInitialState()
  return getInitialState()
end

print "[LOAD] <- client/Game/PlayerState/Reducer"
return module
-- MODULE DEFINITION [END] ---------------------------------------------------
end
-- WRAPPER FUNCTION FOR REQUIRE [END] ----------------------------------------