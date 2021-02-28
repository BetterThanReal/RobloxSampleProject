-- WRAPPER FUNCTION FOR REQUIRE [BEGIN] --------------------------------------
return function(global)
print "[LOAD] -> server/Game/PlayerState/Reducer"

-- PRIVATE DATA AND HELPER FUNCTIONS [BEGIN] ---------------------------------
local Assert = global.Assert
local Require = global.Require

local logger = Require.module('/shared/Helpers/Logger'):new(
  { level = 'WARN', warnLevel = 'DEBUG', name = 'PlayerStateReducer' })

local imports = {
  PlayerStateActions = Require.module('/server/Game/PlayerState/Actions'),
  Reducer = Require.module('/shared/Helpers/Reducer'),
  RemoteActions = Require.module('/shared/Game/RemoteActions'),
  RoduxEffects = Require.module('/shared/Helpers/RoduxEffects'),
  TableHelper = Require.module('/shared/Helpers/TableHelper'),
  remoteDispatcher = nil, -- to be provided by the invoker of 'module.create'
}
-- PRIVATE DATA AND HELPER FUNCTIONS [END] -----------------------------------

-- MODULE DEFINITION [BEGIN] -------------------------------------------------

local module = {}

local function getInitialPlayerState()
  return {
    balance = 100,
  }
end

local function getInitialState()
  return {
    players = {},
  }
end

local function doWagerRequestedFn(player, wagerAmount)
  local actions = imports.PlayerStateActions

  return function(store)
    wait(math.random(1, 1))

    local state = store:getState().PlayerState
    local playerState = state.players[player]

    if (playerState) then
      local balance = playerState.balance
      local toWager = math.min(wagerAmount, balance)
      local earnings = math.random(-toWager, toWager)

      store:dispatch(actions.balanceAdjusted(player, earnings))
      store:dispatch(actions.wagerConcluded(player, wagerAmount, earnings))
    end
  end
end

local function onBalanceAdjusted(state, action)
  local assign = imports.TableHelper.assign
  local player = action.player
  local playerState = state.players[player]

  if playerState then
    local balance = playerState.balance + action.adjustedAmount

    playerState = assign({}, playerState, {
      balance = balance,
    })

    local players = assign({}, state.players)
    players[action.player] = playerState

    return imports.RoduxEffects.add(
      {
        players = players,
      },
      imports.remoteDispatcher(
        imports.RemoteActions.balanceUpdated(player, balance)))
  end
  return {}
end

local function onBalanceUpdated(state, action)
  local assign = imports.TableHelper.assign
  local player = action.player
  local playerState = state.players[action.player]

  if playerState then
    local balance = action.balance

    playerState = assign({}, playerState, {
      balance = balance,
    })

    local players = assign({}, state.players)
    players[action.player] = playerState

    return imports.RoduxEffects.add(
      {
        players = players,
      },
      imports.remoteDispatcher(
        imports.RemoteActions.balanceUpdated(player, balance)))
  end
  return {}
end

local function onPlayerAdded(state, action)
  local player = action.player
  local playerState = getInitialPlayerState()
  local players = imports.TableHelper.assign({}, state.players)
  players[player] = playerState

  return imports.RoduxEffects.add(
    {
      players = players,
    },
    imports.remoteDispatcher(
      imports.RemoteActions.balanceUpdated(player, playerState.balance)))
end

local function onPlayerRemoving(state, action)
  local players = imports.TableHelper.assign({}, state.players)
  players[action.player] = nil

  return {
    players = players,
  }
end

local function onWagerConcluded(state, action)
  return imports.RoduxEffects.add({},
    imports.remoteDispatcher(
      imports.RemoteActions.wagerConcluded(
        action.player, action.wagerAmount, action.earnings)))
end

local function onWagerRequested(state, action)
  return imports.RoduxEffects.add({},
    doWagerRequestedFn(action.player, action.wagerAmount))
end

function module.create(remoteDispatcher)
  local actionTypes = imports.PlayerStateActions.ACTION_TYPE
  local remoteActionTypes = imports.RemoteActions.ACTION_TYPE

  local handlers = {}
  handlers[actionTypes.balanceAdjusted] = onBalanceAdjusted
  handlers[actionTypes.balanceUpdated] = onBalanceUpdated
  handlers[actionTypes.playerAdded] = onPlayerAdded
  handlers[actionTypes.playerRemoving] = onPlayerRemoving
  handlers[actionTypes.wagerConcluded] = onWagerConcluded
  handlers[remoteActionTypes.wagerRequested] = onWagerRequested

  imports.remoteDispatcher = remoteDispatcher
  return imports.Reducer.create(getInitialState(), handlers)
end

function module.getInitialState()
  return getInitialState()
end

print "[LOAD] <- server/Game/PlayerState/Reducer"
return module
-- MODULE DEFINITION [END] ---------------------------------------------------
end
-- WRAPPER FUNCTION FOR REQUIRE [END] ----------------------------------------