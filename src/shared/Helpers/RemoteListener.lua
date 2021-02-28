-- WRAPPER FUNCTION FOR REQUIRE [BEGIN] --------------------------------------
return function(global)
print "[LOAD] -> client/Game/Helpers/RemoteListener"

-- PRIVATE DATA AND HELPER FUNCTIONS [BEGIN] ---------------------------------
local Assert = global.Assert
local Require = global.Require

local ERR_INVALID_SELF = "Class method was invoked as a function"

local logger = Require.module('/shared/Helpers/Logger'):new(
  { level = 'WARN', warnLevel = 'DEBUG', name = 'RemoteListener' })
-- PRIVATE DATA AND HELPER FUNCTIONS [END] -----------------------------------

-- CLASS DEFINITION [BEGIN] --------------------------------------------------
local class = {}

function isClass(self)
  return self and self._class and self._class == class or false
end

function class:connect()
  Assert(isClass(self), ERR_INVALID_SELF, 2)
  self:disconnect()

  local parameters = self.connection.parameters

  local log = logger
  if log then
    log:verbose("Connecting RemoteListener", parameters)
  end

  local event = parameters.event
  local eventFn = parameters.isClient and event.OnClientEvent
    or event.onServerEvent

  self.handler = eventFn:Connect(

    function(...)
      if log then
        log:debug("Calling RemoteListener callback", parameters, ...)
      end

      return parameters.callback(...)
    end)

  return self.handler
end

function class:disconnect()
  Assert(isClass(self), ERR_INVALID_SELF, 2)
  local parameters = self.connection.parameters

  local log = logger
  if log then
    log:verbose("Disconnecting RemoteListener", parameters)
  end

  local event = parameters.event
  local handler = self.connection.handler

  if event and handler then
    local eventFn = parameters.isClient and event.OnClientEvent
      or event.onServerEvent

    eventFn:Disconnect(handler)
    self.connection.handler = nil
  end
end

function class:new(event, callback, name)
  Assert(class == self, ERR_INVALID_SELF, 2)

  local obj = { _class = self }
  setmetatable(obj, self)
  self.__index = self

  obj.connection = {
    handler = nil,
    parameters = {
      callback = callback,
      event = event,
      isClient = global.isClient,
      name = name,
    },
  }
  return obj
end

print "[LOAD] <- client/Game/Helpers/RemoteListener"
return class
-- CLASS DEFINITION [END] ----------------------------------------------------
end
-- WRAPPER FUNCTION FOR REQUIRE [END] ----------------------------------------