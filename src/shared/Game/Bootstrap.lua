-- WRAPPER FUNCTION FOR REQUIRE [BEGIN] --------------------------------------
return function(config)
print "[LOAD] -> shared/Game/Bootstrap"

-- PRIVATE DATA AND HELPER FUNCTIONS [BEGIN] ---------------------------------
local function getAssert()
  return function(test, message, level, ...)
    if (test == false or test == nil) then
      level = level or 1
      warn("\n", debug.traceback())
      if type(message) == 'function' then
        message = message(...)
      end
      error(message, 2 + (level - 1))
    end
  end
end

local function getRequire(config, global)
  config = config or {}

  local defaults = config.defaults or {}
  local waitTimeout =
    defaults.waitTimeout and tonumber(defaults.waitTimeout) or 10

  return require(
    game:GetService('ReplicatedStorage')
      :WaitForChild('Scripts', waitTimeout)
      :WaitForChild('Helpers', waitTimeout)
      :WaitForChild('Require', waitTimeout)
    )(global, {
      mapping = {
        client = ':StarterPlayer/StarterPlayerScripts/Scripts',
        runEnv = '/' .. global.runEnv,
        shared = ':ReplicatedStorage/Scripts',
        server = ':ServerScriptService/Scripts',
        ['shared/Assets'] = ':ReplicatedStorage/Assets',
      }
    })
end

local isClient = game:GetService("RunService"):IsClient()
-- PRIVATE DATA AND HELPER FUNCTIONS [END] -----------------------------------

-- MODULE DEFINITION [BEGIN] -------------------------------------------------
local global = {
  Assert = getAssert(),
  game = game,
  isClient = isClient,
  runEnv = isClient and 'client' or 'server',
  RunEnv = isClient and 'Client' or 'Server',
}

global.Require = getRequire(config, global)
global.Require.module('/shared/Game').start()

print "[LOAD] <- shared/Game/Bootstrap"
return global
-- MODULE DEFINITION [END] ---------------------------------------------------
end
-- WRAPPER FUNCTION FOR REQUIRE [END] ----------------------------------------