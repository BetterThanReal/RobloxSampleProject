-- WRAPPER FUNCTION FOR REQUIRE [BEGIN] --------------------------------------
return function(global, config)
print "[LOAD] -> shared/Helpers/Require"

global = global or {}
config = config or {}

-- PRIVATE DATA AND HELPER FUNCTIONS [BEGIN] ---------------------------------
local Assert = global.Assert
local game = global.game
local defaults = global.defaults or {}
local waitTimeout =
  defaults.waitTimeout and tonumber(defaults.waitTimeout) or 10

local STR = string.format

local function ERR_MSG_FN(msg)
  return function(...)
    return STR(msg, ...)
  end
end

local ERR_FN_PARAM_MISSING = ERR_MSG_FN(
  "Required function parameter '%s' was empty or not specified")

local ERR_INVALID_SELF = "Class method was invoked as a function"

local ERR_M_PARAM_MISSING = ERR_MSG_FN(
  "Required method parameter '%s' was empty or not specified")

local instancesByPath = {}
local modulesByPath = {}

-- Thanks to Steve Donovan
-- https://github.com/stevedonovan/Microlight/blob/master/ml.lua#L23
function strSplit(s,re,n)
    local find,sub,append = string.find, string.sub, table.insert
    local i1,ls = 1,{}
    if not re then re = '%s+' end
    if re == '' then return {s} end
    while true do
        local i2,i3 = find(s,re,i1)
        if not i2 then
            local last = sub(s,i1)
            if last ~= '' then append(ls,last) end
            if #ls == 1 and ls[1] == '' then
                return {}
            else
                return ls
            end
        end
        append(ls,sub(s,i1,i2-1))
        if n and #ls == n then
            ls[#ls] = sub(s,i1)
            return ls
        end
        i1 = i3+1
    end
end

local function getCanonicalPath(path)
  if path then
    path = string.gsub(path, "/+", "/")
    local children = strSplit(path, "/")
    if children[1] == "" then
      table.remove(children, 1)
    end
    path = table.concat(children, "/")
    return path, children
  end
end

local function resolveService(serviceName)
  Assert(serviceName, ERR_FN_PARAM_MISSING, 2, 'serviceName')

  if string.sub(serviceName, 1, 1) == ":" then
    serviceName = string.sub(serviceName, 2)
  end

  local service = game:GetService(serviceName)
  Assert(service, STR("Unable to get requested service '%s'", serviceName), 2)

  return service
end

local function resolveInstanceChild(
  instance, instancePath, childName, childPath)

  Assert(instance, ERR_FN_PARAM_MISSING, 2, 'instance')
  Assert(instancePath, ERR_FN_PARAM_MISSING, 2, 'instancePath')
  Assert(childName, ERR_FN_PARAM_MISSING, 2, 'childName')
  Assert(childPath, ERR_FN_PARAM_MISSING, 2, 'childPath')

  local child = instance:WaitForChild(childName, waitTimeout)
  Assert(child, STR, 2,
    "Unable to resolve child '%s' of instance '%s'", childName, instancePath)

  instancesByPath[childPath] = child
  return child
end

local function resolveInstance(path, visited)
  Assert(path, ERR_FN_PARAM_MISSING, 2, 'path')

  local paths = nil
  path, paths = getCanonicalPath(path)
  Assert(#paths > 0, ERR_FN_PARAM_MISSING('path'), 2)

  visited = visited or {}
  Assert(not visited[path], STR, 2,
    "Encountered circular dependency resolving instance '%s'", path)

  visited[path] = true

  local instancePath = paths[1]
  local instancePaths = { instancePath }

  for i = 2, #paths do
    instancePath = instancePath .. '/' .. paths[i]
    instancePaths[#instancePaths + 1] = instancePath
  end

  local instance = nil
  local found = nil

  for i = 1, #paths do
    local check = instancesByPath[instancePaths[i]]
    if check then
      instance = check
      found = i
    end
  end

  if type(instance) == 'function' then
    instance = instance()
  end

  if type(instance) == 'string' then
    instance = resolveInstance(instance, visited)
  end

  if string.sub(paths[1], 1, 1) == ":" then
    instance = resolveService(paths[1])
    found = 1
  end

  Assert(instance, STR, 2,
    "Unable to resolve requested path '%s'", path)

  for i = found, #paths - 1 do
    local childName = paths[i + 1]
    local childPath = instancePaths[i + 1]
    instancePath = instancePaths[i]
    instance = resolveInstanceChild(
      instance, instancePath, childName, childPath)

    Assert(instance, STR, 2,
      "Unable to resolve requested path '%s'", instancePath)
  end

  return instance
end

local function requireByPath(path)
  Assert(path, ERR_FN_PARAM_MISSING, 2, 'path')

  local paths = nil
  path, paths = getCanonicalPath(path)
  Assert(#paths > 0, ERR_FN_PARAM_MISSING, 2, 'path')

  if modulesByPath[path] then
    return modulesByPath[path]
  end

  local instance = resolveInstance(path)
  Assert(instance, STR, 2, "Unable to resolve module '%s'", path)

  local status, module = pcall(function() return require(instance) end)
  Assert(status, STR, 2, "Error requiring module '%s': [%s]", path, module)

  if type(module) == 'function' then
    status, module = pcall(function() return module(global) end)
    Assert(status, STR, 2, "Error requiring module function '%s': [%s]", path, module)
  end

  modulesByPath[path] = module
  return module
end

local function mapInstance(path, instance)
  Assert(path, ERR_M_PARAM_MISSING, 2, 'path')
  Assert(instance, ERR_M_PARAM_MISSING, 2, 'instance')

  local paths = nil
  path, paths = getCanonicalPath(path)
  Assert(#paths > 0,
    "A Require mapping contained an empty name", 2)
  Assert(string.sub(paths[1], 1, 1) ~= ":",
    "A Require mapping contained a name that starts with a service", 2)

  if type(instance) == 'string' then
    local instancePaths = nil
    instance, instancePaths = getCanonicalPath(instance)
    Assert(#instancePaths > 0,
      "A Require mapping contained an empty value", 2)
  end

  instancesByPath[path] = instance
end

local function mapInstances(mapping)
  mapping = mapping or {}

  for path, instance in pairs(mapping) do
    mapInstance(path, instance)
  end
end
-- PRIVATE DATA AND HELPER FUNCTIONS [END] -----------------------------------

-- MODULE DEFINITION [BEGIN] -------------------------------------------------
local module = {}

function module.instance(path)
  Assert(path, ERR_M_PARAM_MISSING, 2, 'path')
  return resolveInstance(path)
end

function module.map(path, instance)
  Assert(path, ERR_M_PARAM_MISSING, 2, 'path')
  Assert(instance, ERR_M_PARAM_MISSING, 2, 'instance')
  return mapInstance(path, instance)
end

function module.module(path)
  Assert(path, ERR_M_PARAM_MISSING, 2, 'path')
  return requireByPath(path)
end

function module.service(name)
  Assert(name, ERR_M_PARAM_MISSING, 2, 'name')
  return resolveService(name)
end

do
  mapInstances(config.mapping)
end

print "[LOAD] <- shared/Helpers/Require"
return module
-- MODULE DEFINITION [END] ---------------------------------------------------
end
-- WRAPPER FUNCTION FOR REQUIRE [END] ----------------------------------------