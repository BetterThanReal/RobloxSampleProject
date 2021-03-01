-- WRAPPER FUNCTION FOR REQUIRE [BEGIN] --------------------------------------
return function(global)
print "[LOAD] -> client/Game/init"

-- PRIVATE DATA AND HELPER FUNCTIONS [BEGIN] ---------------------------------
local Assert = global.Assert
local Require = global.Require

local logger = Require.module('/shared/Helpers/Logger'):new(
  { level = 'WARN', warnLevel = 'DEBUG', name = 'GameClient' })

local imports = {
  MainGui = Require.module('/runEnv/Game/Gui/Main'),
  Players = Require.service('Players'),
}
-- PRIVATE DATA AND HELPER FUNCTIONS [END] -----------------------------------

-- MODULE DEFINITION [BEGIN] -------------------------------------------------
local module = {}

function module.initRunEnv(initializeStoreFn)
  local log = logger
  if log then
    log:info("Starting game")
  end

  local store = initializeStoreFn()
  imports.MainGui.mount(store, imports.Players)
end

print "[LOAD] <- client/Game/init"
return module
-- MODULE DEFINITION [END] ---------------------------------------------------
end
-- WRAPPER FUNCTION FOR REQUIRE [END] ----------------------------------------