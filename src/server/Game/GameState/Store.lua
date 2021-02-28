-- WRAPPER FUNCTION FOR REQUIRE [BEGIN] --------------------------------------
return function(global)
print "[LOAD] -> server/Game/GameState/Store"

-- PRIVATE DATA AND HELPER FUNCTIONS [BEGIN] ---------------------------------
local Assert = global.Assert
local Require = global.Require

local logger = Require.module('/shared/Helpers/Logger'):new(
  { level = 'WARN', warnLevel = 'DEBUG', name = 'GameStateStore' })

local imports = {
  GameStateReducer = Require.module('/server/Game/GameState/Reducer'),
  Rodux = Require.module('/shared/Lib/Rodux'),
  RoduxEffects = Require.module('/shared/Helpers/RoduxEffects'),
}
-- PRIVATE DATA AND HELPER FUNCTIONS [END] -----------------------------------

-- MODULE DEFINITION [BEGIN] -------------------------------------------------

local module = {}

function module.create(remoteDispatcher)
  local reducer = imports.RoduxEffects.withChildEffects(
    imports.GameStateReducer.create(remoteDispatcher))

  local middleware = { imports.RoduxEffects.create() }

  return imports.Rodux.Store.new(
    reducer, imports.GameStateReducer.getInitialState(), middleware)
end

print "[LOAD] <- server/Game/GameState/Store"
return module
-- MODULE DEFINITION [END] ---------------------------------------------------
end
-- WRAPPER FUNCTION FOR REQUIRE [END] ----------------------------------------