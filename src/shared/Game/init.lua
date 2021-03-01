-- WRAPPER FUNCTION FOR REQUIRE [BEGIN] --------------------------------------
return function(global)
print "[LOAD] -> shared/Game/init"

-- PRIVATE DATA AND HELPER FUNCTIONS [BEGIN] ---------------------------------
local Assert = global.Assert
local Require = global.Require

local logger = Require.module('/shared/Helpers/Logger'):new(
  { level = 'WARN', warnLevel = 'DEBUG', name = 'Game' })

local imports = {
  ClientServerEvent = Require.instance('/shared/Assets/Game/ClientServerEvent'),
  Game = Require.module('/runEnv/Game'),
  GameStateStore = Require.module('/runEnv/Game/GameState/Store'),
  RoduxRemoteBridge = Require.module('/shared/Helpers/RoduxRemoteBridge'),
}

function initializeStore()
  local log = logger
  if log then
    log:info("Initializing game Rodux store")
  end

  local event = imports.ClientServerEvent

  local remoteDispatcher =
    imports.RoduxRemoteBridge.withDispatchToRemote(event)

  local store = imports.GameStateStore.create(remoteDispatcher)

  imports.RoduxRemoteBridge.relayDispatchesFromRemote(event, store)
  return store
end

-- PRIVATE DATA AND HELPER FUNCTIONS [END] -----------------------------------

-- MODULE DEFINITION [BEGIN] -------------------------------------------------
local module = {}

function module.start()
  imports.Game.initRunEnv(initializeStore)
end

print "[LOAD] <- shared/Game/init"
return module
-- MODULE DEFINITION [END] ---------------------------------------------------
end
-- WRAPPER FUNCTION FOR REQUIRE [END] ----------------------------------------