print "[LOAD] -> server/Game/Bootstrap.server"
local waitTimeout = 10

local global = {
  defaults = { logLevel = 'WARN', waitTimeout = waitTimeout },
  game = game,
  isClient = game:GetService("RunService"):IsClient(),
}

local Bootstrap = require(
  game:GetService('ReplicatedStorage')
    :WaitForChild('Scripts', waitTimeout)
    :WaitForChild('Game', waitTimeout)
    :WaitForChild('Bootstrap', waitTimeout)
  )(global)

local Game = global.Require.module('/server/Game')
Game.start()

print "[LOAD] <- server/Game/Bootstrap.server"