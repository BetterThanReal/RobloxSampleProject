-- WRAPPER FUNCTION FOR REQUIRE [BEGIN] --------------------------------------
return function(global)
print "[LOAD] -> shared/Helpers/Reducer"

-- PRIVATE DATA AND HELPER FUNCTIONS [BEGIN] ---------------------------------
local Assert = global.Assert
local Require = global.Require

local logger = Require.module('/shared/Helpers/Logger'):new(
  { level = 'WARN', warnLevel = 'DEBUG', name = 'Reducer' })

local imports = {
  TableHelper = Require.module('/shared/Helpers/TableHelper'),
}
-- PRIVATE DATA AND HELPER FUNCTIONS [END] -----------------------------------

-- MODULE DEFINITION [BEGIN] -------------------------------------------------
local module = {}

function module.create(initialState, handlers)
  Assert(initialState, "Initial state for reducer was not provided")
  Assert(handlers, "Handler function table for reducer was not provided")

  return function(state, action, ...)
    state = state or initialState
    local handler = handlers[action.type]

    if handler then
      state = handler(state, action, ...)
    end

    return state
  end
end

function module.withLogging(logger, reducer)
  return function(state, action, ...)
    if not logger then
      return reducer(state, action)
    end

    logger:debug("State prior to reducer:", state, "with action:", action)
    local _state = reducer(state, action)
    logger:debug("State after reducer:", _state)
    return _state
  end
end

function module.withMergedState(reducer)
  local augment = imports.TableHelper.augment

  return function (state, action, ...)
    return augment({}, reducer(state, action, ...), state)
  end
end

print "[LOAD] <- shared/Helpers/Reducer"
return module
-- MODULE DEFINITION [END] ---------------------------------------------------
end
-- WRAPPER FUNCTION FOR REQUIRE [END] ----------------------------------------