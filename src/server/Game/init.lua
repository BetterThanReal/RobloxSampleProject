-- WRAPPER FUNCTION FOR REQUIRE [BEGIN] --------------------------------------
return function(global)
print "[LOAD] -> server/Game/init"

-- PRIVATE DATA AND HELPER FUNCTIONS [BEGIN] ---------------------------------
local Assert = global.Assert
local Require = global.Require

local logger = Require.module('/shared/Helpers/Logger'):new(
  { level = 'WARN', warnLevel = 'DEBUG', name = 'Game' })

local imports = {
  ClientServerEvent = Require.instance('/shared/Assets/Game/ClientServerEvent'),
  GameStateStore = Require.module('/server/Game/GameState/Store'),
  PlayerState = Require.module('/server/Game/PlayerState'),
  RoduxRemoteBridge = Require.module('/shared/Helpers/RoduxRemoteBridge'),
}
-- PRIVATE DATA AND HELPER FUNCTIONS [END] -----------------------------------

-- MODULE DEFINITION [BEGIN] -------------------------------------------------
local module = {}

function module.start()
  local log = logger
  if log then
    log:info("Starting Game")
  end

  local event = imports.ClientServerEvent

  local remoteDispatcher =
    imports.RoduxRemoteBridge.withDispatchToRemote(event)

  local store = imports.GameStateStore.create(remoteDispatcher)

  imports.RoduxRemoteBridge.relayDispatchesFromRemote(event, store)
  imports.PlayerState.listenForPlayerAdded(store)
end

print "[LOAD] <- server/Game/init"
return module
-- MODULE DEFINITION [END] ---------------------------------------------------
end
-- WRAPPER FUNCTION FOR REQUIRE [END] ----------------------------------------
