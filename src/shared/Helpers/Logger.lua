-- WRAPPER FUNCTION FOR REQUIRE [BEGIN] --------------------------------------
return function(global)
print "[LOAD] -> shared/Helpers/Logger"

-- PRIVATE DATA AND HELPER FUNCTIONS [BEGIN] ---------------------------------
local Assert = global.Assert

local ERR_INVALID_SELF = "Class method was invoked as a function"

local LOG_LEVEL = {
  NONE = 0,
  FATAL = 1,
  CRITICAL = 2,
  ERROR = 3,
  WARN = 4,
  INFO = 5,
  VERBOSE = 6,
  DEBUG = 7,
}

local PREFIX = {
  [LOG_LEVEL.FATAL] = 'FATAL',
  [LOG_LEVEL.CRITICAL] = 'CRITICAL',
  [LOG_LEVEL.ERROR] = 'ERROR',
  [LOG_LEVEL.WARN] = 'WARN',
  [LOG_LEVEL.INFO] = 'INFO',
  [LOG_LEVEL.VERBOSE] = 'INFO+',
  [LOG_LEVEL.DEBUG] = 'DEBUG',
}

local fnNoOp = function() end

local function getDefaultLogLevel()
  local defaults = global.defaults or {}
  local level = defaults.logLevel

  if type(level) == 'string' then
    level = LOG_LEVEL[string.upper(level)]
  end

  return level or LOG_LEVEL.ERROR
end

local function getLogLevel(level)
  if type(level) == 'string' then
    level = LOG_LEVEL[string.upper(level)]
  end
  return level
end

local function defaultLogFn(level, isWarn, ...)
  if isWarn then
    warn(...)
  else
    print(...)
  end
end

local function getPrefixForLevel(level, isWarn)
  local prefix = PREFIX[level]

  if isWarn and level ~= LOG_LEVEL.WARN then
    prefix = prefix .. "(WARN)"
  end

  return prefix or ""
end

local function log(self, msgLevel, isWarn, ...)
  local triggerLevel = not isWarn and self.level or
    math.max(self.level, self.warnLevel)

  msgLevel = msgLevel == nil and LOG_LEVEL.NONE or
    math.min(msgLevel, LOG_LEVEL.DEBUG)

  if msgLevel <= LOG_LEVEL.NONE or msgLevel > triggerLevel then
    return
  end

  local name = self.name and ("{" .. self.name .. "}: ") or ""
  local prefix = "[" .. getPrefixForLevel(msgLevel, isWarn) .. "] "

  self.logFn(msgLevel, isWarn, prefix .. name, ...)
end
-- PRIVATE DATA AND HELPER FUNCTIONS [END] -----------------------------------

-- CLASS DEFINITION [BEGIN] --------------------------------------------------
local class = {
  NONE = LOG_LEVEL.NONE,
  FATAL = LOG_LEVEL.FATAL,
  CRITICAL = LOG_LEVEL.CRITICAL,
  ERROR = LOG_LEVEL.ERROR,
  INFO = LOG_LEVEL.INFO,
  VERBOSE = LOG_LEVEL.VERBOSE,
  DEBUG = LOG_LEVEL.DEBUG,
}

function isClass(self)
  return self and self._class and self._class == class or false
end

function class.getNullLogger()
  return {
    fatal = fnNoOp,
    critical = fnNoOp,
    error = fnNoOp,
    warn = fnNoOp,
    info = fnNoOp,
    verbose = fnNoOp,
    debug = fnNoOp,
  }
end

function class:critical(...)
  Assert(isClass(self), ERR_INVALID_SELF, 2)
  log(self, LOG_LEVEL.CRITICAL, true, ...)
end

function class:debug(...)
  Assert(isClass(self), ERR_INVALID_SELF, 2)
  log(self, LOG_LEVEL.DEBUG, false, ...)
end

function class:error(...)
  Assert(isClass(self), ERR_INVALID_SELF, 2)
  log(self, LOG_LEVEL.ERROR, true, ...)
end

function class:fatal(...)
  Assert(isClass(self), ERR_INVALID_SELF, 2)
  log(self, LOG_LEVEL.FATAL, true, ...)
end

function class:info(...)
  Assert(isClass(self), ERR_INVALID_SELF, 2)
  log(self, LOG_LEVEL.INFO, false, ...)
end

function class:verbose(...)
  Assert(isClass(self), ERR_INVALID_SELF, 2)
  log(self, LOG_LEVEL.VERBOSE, false, ...)
end

function class:warn(...)
  Assert(isClass(self), ERR_INVALID_SELF, 2)
  log(self, LOG_LEVEL.WARN, true, ...)
end

function class:warnDebug(...)
  Assert(isClass(self), ERR_INVALID_SELF, 2)
  log(self, LOG_LEVEL.DEBUG, true, ...)
end

function class:warnInfo(...)
  Assert(isClass(self), ERR_INVALID_SELF, 2)
  log(self, LOG_LEVEL.INFO, true, ...)
end

function class:warnVerbose(...)
  Assert(isClass(self), ERR_INVALID_SELF, 2)
  log(self, LOG_LEVEL.VERBOSE, true, ...)
end

function class:new(config)
  Assert(self == class, ERR_INVALID_SELF, 2)

  local obj = { _class = class }
  setmetatable(obj, self)
  self.__index = self

  config = config or {}
  obj.level = getLogLevel(config.level) or getDefaultLogLevel()
  obj.warnLevel = getLogLevel(config.warnLevel) or obj.level
  obj.logFn = config.logFn or defaultLogFn
  obj.name = config.name
  return obj
end

print "[LOAD] <- shared/Helpers/Logger"
return class
-- CLASS DEFINITION [END] ----------------------------------------------------
end
-- WRAPPER FUNCTION FOR REQUIRE [END] ----------------------------------------