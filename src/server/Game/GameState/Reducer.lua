-- WRAPPER FUNCTION FOR REQUIRE [BEGIN] --------------------------------------
return function(global)
print "[LOAD] -> server/Game/GameState/Reducer"

-- PRIVATE DATA AND HELPER FUNCTIONS [BEGIN] ---------------------------------
local Assert = global.Assert
local Require = global.Require

local logger = Require.module('/shared/Helpers/Logger'):new(
  { level = 'WARN', warnLevel = 'DEBUG', name = 'GameStateReducer' })

local imports = {
  PlayerStateReducer = Require.module('/server/Game/PlayerState/Reducer'),
  Reducer = Require.module('/shared/Helpers/Reducer'),
}
-- PRIVATE DATA AND HELPER FUNCTIONS [END] -----------------------------------

-- MODULE DEFINITION [BEGIN] -------------------------------------------------
local module = {}

local function getInitialState()
  return {
    PlayerState = imports.PlayerStateReducer.getInitialState(),
  }
end

function module.create(remoteDispatcher)
  local playerStateReducer = imports.Reducer.withMergedState(
    imports.PlayerStateReducer.create(remoteDispatcher))

  return function(state, action)
    return {
      PlayerState = playerStateReducer(state.PlayerState, action),
    }
  end
end

function module.getInitialState()
  return getInitialState()
end

print "[LOAD] <- server/Game/GameState/Reducer"
return module
-- MODULE DEFINITION [END] ---------------------------------------------------
end
-- WRAPPER FUNCTION FOR REQUIRE [END] ----------------------------------------