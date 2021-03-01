print "[LOAD] -> server/Game/Bootstrap.server"

require(
  game:GetService('ReplicatedStorage').Scripts.Game.Bootstrap
)({
  defaults = { logLevel = 'WARN', waitTimeout = 10 },
})

print "[LOAD] <- server/Game/Bootstrap.server"