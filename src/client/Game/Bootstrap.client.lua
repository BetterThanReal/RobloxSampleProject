print "[LOAD] -> client/Game/Bootstrap.client"

require(
  game:GetService('ReplicatedStorage').Scripts.Game.Bootstrap
)({
  defaults = { logLevel = 'WARN', waitTimeout = 10 },
})

print "[LOAD] <- client/Game/Bootstrap.client"