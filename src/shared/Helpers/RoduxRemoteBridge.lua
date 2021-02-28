-- WRAPPER FUNCTION FOR REQUIRE [BEGIN] --------------------------------------
return function(global)
print "[LOAD] -> shared/Helpers/RoduxRemoteBridge"

-- PRIVATE DATA AND HELPER FUNCTIONS [BEGIN] ---------------------------------
local Assert = global.Assert
local Require = global.Require

local logger = Require.module('/shared/Helpers/Logger'):new(
  { level = 'WARN', warnLevel = 'DEBUG', name = 'RoduxRemoteBridge' })

local imports = {
  RemoteListener = Require.module('/shared/Helpers/RemoteListener'),
}

local function withDispatchActionFromClient(store)
  local log = logger

  return function(player, action)
    return coroutine.wrap(
      function()
        if log then
          log:debug("Dispatching action from client to store:", action)
        end

        store:dispatch(action)
      end)()
  end
end

local function withDispatchActionFromServer(store)
  local log = logger

  return function(action)
    return coroutine.wrap(
      function()
        if log then
          log:debug("Dispatching action from server to store:", action)
        end

        store:dispatch(action)
      end)()
  end
end

local function withDispatchActionToClient(event)
  local log = logger

  return function(action)
    return coroutine.wrap(
      function()
        if log then
          log:debug("Dispatching action to client:", action)
        end

        event:FireClient(action.player, action)
      end)()
  end
end

local function withDispatchActionToServer(event)
  local log = logger

  return function(action)
    return coroutine.wrap(
      function()
        if log then
          log:debug("Dispatching action to server:", action)
        end

        event:FireServer(action)
      end)()
  end
end
-- PRIVATE DATA AND HELPER FUNCTIONS [END] -----------------------------------

-- MODULE DEFINITION [BEGIN] -------------------------------------------------
local module = { }

function module.withDispatchFromRemote(store)
  return global.isClient and
    withDispatchActionFromServer(store) or
    withDispatchActionFromClient(store)
end

function module.withDispatchToRemote(event)
  return global.isClient and
    withDispatchActionToServer(event) or
    withDispatchActionToClient(event)
end

function module.relayDispatchesFromRemote(event, store)
  local listenerLabel =
    global.isClient and 'ServerReceiver' or 'ClientReceiver'

  return imports.RemoteListener:new(
    event, module.withDispatchFromRemote(store), listenerLabel):connect()
end

print "[LOAD] <- shared/Helpers/RoduxRemoteBridge"
return module
-- MODULE DEFINITION [END] ---------------------------------------------------
end
-- WRAPPER FUNCTION FOR REQUIRE [END] ----------------------------------------