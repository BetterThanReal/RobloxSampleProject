-- WRAPPER FUNCTION FOR REQUIRE [BEGIN] --------------------------------------
return function(global)
print "[LOAD] -> server/Game/init"

-- PRIVATE DATA AND HELPER FUNCTIONS [BEGIN] ---------------------------------
local Assert = global.Assert
local Require = global.Require

local logger = Require.module('/shared/Helpers/Logger'):new(
  { level = 'WARN', warnLevel = 'DEBUG', name = 'GameServer' })

local imports = {
  PlayerState = Require.module('/runEnv/Game/PlayerState'),
}
-- PRIVATE DATA AND HELPER FUNCTIONS [END] -----------------------------------

-- MODULE DEFINITION [BEGIN] -------------------------------------------------
local module = {}

function module.initRunEnv(initializeStoreFn)
  local log = logger
  if log then
    log:info("Starting game")
  end

  local store = coroutine.wrap(initializeStoreFn)()
  imports.PlayerState.listenForPlayerAdded(store)
end

print "[LOAD] <- server/Game/init"
return module
-- MODULE DEFINITION [END] ---------------------------------------------------
end
-- WRAPPER FUNCTION FOR REQUIRE [END] ----------------------------------------