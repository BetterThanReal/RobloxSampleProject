-- WRAPPER FUNCTION FOR REQUIRE [BEGIN] --------------------------------------
return function(global)
print "[LOAD] -> client/Game/Gui/Main/init"

-- PRIVATE DATA AND HELPER FUNCTIONS [BEGIN] ---------------------------------
local Assert = global.Assert
local Require = global.Require

local logger = Require.module('/shared/Helpers/Logger'):new(
  { level = 'WARN', warnLevel = 'DEBUG', name = 'MainGui' })

local imports = {
  MainGuiActions = Require.module('/client/Game/Gui/Main/Actions'),
  MainGuiComponent = Require.module('/client/Game/Gui/Main/Component'),
  Roact = Require.module('/client/Lib/Roact'),
  RoactRodux = Require.module('/client/Lib/RoactRodux'),
}
-- PRIVATE DATA AND HELPER FUNCTIONS [END] -----------------------------------

-- MODULE DEFINITION [BEGIN] -------------------------------------------------
local module = {}

local function getDispatcher()
  local actions = imports.MainGuiActions

  return function(dispatch)
    return {
      onClickInc = function()
        dispatch(actions.wagerIncreased())
      end,
      onClickDec = function()
        dispatch(actions.wagerDecreased())
      end,
      onClickWager = function(...)
        dispatch(actions.wagerRequested())
      end,
    }
  end
end

local function mapStateToProps(state, props, ...)
  return {
    isRemoting = state.MainGui.isRemoting,
    balance = state.PlayerState.balance,
    wagerAmount = state.MainGui.wagerAmount,
  }
end

local function connect(component)
  return imports.RoactRodux.connect(
    mapStateToProps, getDispatcher())(component)
end

local function create(store)
  local mainGuiComponent = imports.MainGuiComponent
  local Roact = imports.Roact
  local RoactRodux = imports.RoactRodux

  return Roact.createElement(
    RoactRodux.StoreProvider,
    { store = store },
    { MainGui = Roact.createElement(
      connect(mainGuiComponent.create())) })
end

function module.mount(store, Players)
  return imports.Roact.mount(create(store), Players.LocalPlayer.PlayerGui)
end

print "[LOAD] <- client/Game/Gui/Main/init"
return module
-- MODULE DEFINITION [END] ---------------------------------------------------
end
-- WRAPPER FUNCTION FOR REQUIRE [END] ----------------------------------------