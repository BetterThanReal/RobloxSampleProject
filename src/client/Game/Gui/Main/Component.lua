-- WRAPPER FUNCTION FOR REQUIRE [BEGIN] --------------------------------------
return function(global)
print "[LOAD] -> client/Game/Gui/Main/Component"

-- PRIVATE DATA AND HELPER FUNCTIONS [BEGIN] ---------------------------------
local Assert = global.Assert
local Require = global.Require

local logger = Require.module('/shared/Helpers/Logger'):new(
  { level = 'WARN', warnLevel = 'DEBUG', name = 'MainGuiComponent' })

local imports = {
  Roact = Require.module('/client/Lib/Roact'),
}
-- PRIVATE DATA AND HELPER FUNCTIONS [END] -----------------------------------

-- MODULE DEFINITION [BEGIN] -------------------------------------------------
local module = {}

local inactiveBgColor = Color3.new(0.75, 0.75, 0.75)
local inactiveTextColor = Color3.new(0.25, 0.25, 0.25)

function module.create()
  local Roact = imports.Roact

  return function(props)
    local balance = props.balance
    local wagerAmount = props.wagerAmount
    local isRemoting = props.isRemoting
    local onClickInc = props.onClickInc
    local onClickDec = props.onClickDec
    local onClickWager = props.onClickWager

    local isUiActive = balance ~= nil
    local isWagerable = isUiActive and not isRemoting

    local activeOnlyBgColor =
      not isUiActive and inactiveBgColor or nil
    local activeOnlyTextColor =
      not isUiActive and inactiveTextColor or nil
    local wagerableOnlyBgColor =
      not isWagerable and inactiveBgColor or nil
    local wagerableOnlyTextColor =
      not isWagerable and inactiveTextColor or nil

    return Roact.createElement('ScreenGui', {
      Name = 'MainGui',
    }, {
      btnInc = Roact.createElement('TextButton', {
        Text = "Increase",
        Size = UDim2.new(0, 100, 0, 50),
        Position = UDim2.new(0, 25, 0, 25),
        BackgroundColor3 = activeOnlyBgColor,
        TextColor3 = activeOnlyTextColor,
        Active = isUiActive,
        AutoButtonColor = isUiActive,

        [Roact.Event.Activated] = onClickInc,
      }),
      lblWager = Roact.createElement('TextLabel', {
        Text = "Wager Amount: " .. wagerAmount,
        Size = UDim2.new(0, 125, 0, 50),
        Position = UDim2.new(0, 150, 0, 25),
        BackgroundColor3 = activeOnlyBgColor,
        TextColor3 = activeOnlyTextColor,
      }),
      btnDec = Roact.createElement('TextButton', {
        Text = "Decrease",
        Size = UDim2.new(0, 100, 0, 50),
        Position = UDim2.new(0, 300, 0, 25),
        BackgroundColor3 = activeOnlyBgColor,
        TextColor3 = activeOnlyTextColor,
        Active = isUiActive,
        AutoButtonColor = isUiActive,

        [Roact.Event.Activated] = onClickDec,
      }),
      btnWager = Roact.createElement('TextButton', {
        Text = isRemoting and "Placing Wager..." or "Wager!",
        Size = UDim2.new(0, 100, 0, 50),
        Position = UDim2.new(0, 425, 0, 25),
        BackgroundColor3 = wagerableOnlyBgColor,
        TextColor3 = wagerableOnlyTextColor,
        Active = isWagerable,
        AutoButtonColor = isWagerable,

        [Roact.Event.Activated] = onClickWager,
      }),
      lblBalance = Roact.createElement('TextLabel', {
        Text = "Balance: " .. (balance ~= nil and balance or "..."),
        Size = UDim2.new(0, 100, 0, 50),
        Position = UDim2.new(0, 550, 0, 25),
        BackgroundColor3 = activeOnlyBgColor,
        TextColor3 = activeOnlyTextColor,
      }),
    })
  end
end

print "[LOAD] <- client/Game/Gui/Main/Component"
return module
-- MODULE DEFINITION [END] ---------------------------------------------------
end
-- WRAPPER FUNCTION FOR REQUIRE [END] ----------------------------------------