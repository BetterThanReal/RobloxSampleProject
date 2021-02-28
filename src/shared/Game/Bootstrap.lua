-- WRAPPER FUNCTION FOR REQUIRE [BEGIN] --------------------------------------
return function(global)
print "[LOAD] -> shared/Game/Bootstrap"

-- PRIVATE DATA AND HELPER FUNCTIONS [BEGIN] ---------------------------------
-- PRIVATE DATA AND HELPER FUNCTIONS [END] -----------------------------------

-- MODULE DEFINITION [BEGIN] -------------------------------------------------
local module = {}

function module.getAssert()
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

function module.getRequire(config)
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
        shared = ':ReplicatedStorage/Scripts',
        server = ':ServerScriptService/Scripts',
        ['shared/Assets'] = ':ReplicatedStorage/Assets',
      }
    })
end

global.Assert = module.getAssert()
global.Require = module.getRequire(global)

print "[LOAD] <- shared/Game/Bootstrap"
return module
-- MODULE DEFINITION [END] ---------------------------------------------------
end
-- WRAPPER FUNCTION FOR REQUIRE [END] ----------------------------------------