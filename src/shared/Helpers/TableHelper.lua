-- WRAPPER FUNCTION FOR REQUIRE [BEGIN] --------------------------------------
return function(global)
print "[LOAD] -> shared/Helpers/Table"

-- PRIVATE DATA AND HELPER FUNCTIONS [BEGIN] ---------------------------------
local Assert = global.Assert
local Require = global.Require

local logger = Require.module('/shared/Helpers/Logger'):new(
  { level = 'WARN', warnLevel = 'DEBUG', name = 'TableHelper' })
-- PRIVATE DATA AND HELPER FUNCTIONS [END] -----------------------------------

-- MODULE DEFINITION [BEGIN] -------------------------------------------------
local module = {}

function module.append(obj, ...)
  local n = select('#', ...)
  local arg = { n = n, ... }

  for i = 1, n do
    local member = arg[i]

    if member ~= nil then
      for _, v in ipairs(member or {}) do
        obj[#obj + 1] = v
      end
    end
  end

  return obj
end

function module.assign(obj, ...)
  local n = select('#', ...)
  local args = { n = n, ... }

  for _, arg in ipairs(args) do
    if arg ~= nil then
      for i, v in ipairs(arg) do
        obj[i] = v
      end
      for k, v in pairs(arg) do
        obj[k] = v
      end
    end
  end

  return obj
end

function module.augment(obj, ...)
  local n = select('#', ...)
  local args = { n = n, ... }

  for _, arg in ipairs(args) do
    if arg ~= nil then
      for i, v in ipairs(arg) do
        if obj[i] == nil then
          obj[i] = v
        end
      end
      for k, v in pairs(arg) do
        if obj[k] == nil then
          obj[k] = v
        end
      end
    end
  end

  return obj
end

function module.compose(...)
  local n = select('#', ...)
  local args = { n = n, ... }
  local currFn = nil

  for _, nextFn in ipairs(args) do
    if type(nextFn) == 'function' then
      currFn = currFn and (function(prev, next)
        return function(...)
          return next(prev(...))
        end
      end)(currFn, nextFn) or nextFn
    end
  end

  return currFn
end

print "[LOAD] <- shared/Helpers/Table"
return module
-- MODULE DEFINITION [END] ---------------------------------------------------
end
-- WRAPPER FUNCTION FOR REQUIRE [END] ----------------------------------------