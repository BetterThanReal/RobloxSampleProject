-- WRAPPER FUNCTION FOR REQUIRE [BEGIN] --------------------------------------
return function(global)
print "[LOAD] -> server/Game/PlayerState/init"

-- PRIVATE DATA AND HELPER FUNCTIONS [BEGIN] ---------------------------------
local Assert = global.Assert
local Require = global.Require

local logger = Require.module('/shared/Helpers/Logger'):new(
  { level = 'WARN', warnLevel = 'DEBUG', name = 'PlayerState' })

local imports = {
  PlayerStateActions = Require.module('/server/Game/PlayerState/Actions'),
  Players = Require.service('Players'),
}

local function addPlayers(callback)
  local Players = imports.Players

  for _, player in ipairs(Players:GetPlayers()) do
    callback(player)
  end
end

local function onPlayerRemovingFn(store)
  return function(player)
    coroutine.wrap(
      function()
        local log = logger
        if log then
          log:debug("Dispatching action for PlayerRemoving", player)
        end

        store:dispatch(imports.PlayerStateActions.playerRemoving(player))
      end
    )()
  end
end

local function onPlayerAddedFn(store)
  return function(player)
    coroutine.wrap(
      function()
        local log = logger
        if log then
          log:debug("Dispatching action for PlayerAdded", player)
        end

        imports.Players.PlayerRemoving:Connect(onPlayerRemovingFn(store))
        store:dispatch(imports.PlayerStateActions.playerAdded(player))
      end
    )()
  end
end
-- PRIVATE DATA AND HELPER FUNCTIONS [END] -----------------------------------

-- MODULE DEFINITION [BEGIN] -------------------------------------------------
local module = {}

function module.listenForPlayerAdded(store)
  local playerAddedFn = onPlayerAddedFn(store)
  imports.Players.PlayerAdded:Connect(playerAddedFn)
  addPlayers(playerAddedFn)
end

print "[LOAD] <- server/Game/PlayerState/init"
return module
-- MODULE DEFINITION [END] ---------------------------------------------------
end
-- WRAPPER FUNCTION FOR REQUIRE [END] ----------------------------------------