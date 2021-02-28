-- WRAPPER FUNCTION FOR REQUIRE [BEGIN] --------------------------------------
return function(global)
print "[LOAD] -> shared/Helpers/RoduxEffects"

-- PRIVATE DATA AND HELPER FUNCTIONS [BEGIN] ---------------------------------
local Assert = global.Assert
local Require = global.Require

local logger = Require.module('/shared/Helpers/Logger'):new(
  { level = 'WARN', warnLevel = 'DEBUG', name = 'RoduxEffects' })

local imports = {
  TableHelper = Require.module('/shared/Helpers/TableHelper'),
}

local function dispatchEffect(store, effect)
  local log = logger

  coroutine.wrap(function()
    if type(effect) == "function" then
      if log then
        log:debug("Dispatching effect:", store:getState())
      end
      effect(store)
    else
      if log then
        log:debug("Dispatching action to store:", effect, store:getState())
      end
      store:dispatch(effect)
    end
  end)()
end

function tablify(effects)
  if type(effects) == 'table' then
    return effects
  elseif type(effects) == 'nil' then
    return {}
  else
    return { effects }
  end
end
-- PRIVATE DATA AND HELPER FUNCTIONS [END] -----------------------------------

-- MODULE DEFINITION [BEGIN] -------------------------------------------------
local module = {}

function module.add(state, ...)
  local n = select('#', ...)
  local args = { n = n, ... }

  state = state or {}
  local _state = {}
  local added = {}
  local existing = state[module]

  if existing then
    for i, e in ipairs(tablify(existing)) do
      added[#added + 1] = e
    end
  end

  for i, e in ipairs(args) do
    added[#added + 1] = e
  end

  if #added > 0 then
    _state[module] = added
  end

  return imports.TableHelper.augment(_state, state)
end

function module.create(callback, name)
  local log = logger
  if log then
    log:verbose("Connecting RoduxEffects")
  end

  return function(nextDispatch, store)
    if log then
      log:verbose(
        "Attaching RoduxEffects to middleware")
    end

    return function(action)
      Assert(action, "Function parameter 'action' was not provided")

      if log then
        log:debug(
          "RoduxEffects middleware calling next dispatcher in chain", action)
      end

      local next = nextDispatch(action)
      local state = store:getState()

      if log then
        log:debug(
          "Executing RoduxEffects middleware", action, state)
      end

      for _, effect in ipairs(state[module] or {}) do
        dispatchEffect(store, effect)
      end

      return next
    end
  end
end

function module.withChildEffects(reducer)
  return function(state, action, ...)
    local _state = reducer(state, action, ...)

    if type(_state) == 'table' then
      local effects = {}

      for k, v in pairs(_state) do
        if type(v) == 'table' then
          local _effects = v[module]
          if _effects then
            if type(_effects) == 'table' then
              for _, e in ipairs(_effects) do
                effects[#effects + 1] = e
              end
            else
              effects[#effects + 1] = _effects
            end
            v[module] = nil
          end
        end
      end
      if #effects > 0 then
        _state[module] = effects
      end
    end

    return _state
  end
end

print "[LOAD] <- shared/Helpers/RoduxEffects"
return module
-- MODULE DEFINITION [END] ---------------------------------------------------
end
-- WRAPPER FUNCTION FOR REQUIRE [END] ----------------------------------------