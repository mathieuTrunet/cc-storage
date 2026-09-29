local dir = fs.getDir(shell.getRunningProgram())
local inventory = dofile(fs.combine(dir, "lib/inventory.lua"))

local M = {}

function M.isInventory(name)
  if peripheral.hasType and peripheral.hasType(name, "inventory") then
    return true
  end
  return inventory.hasInventoryInterface(peripheral.getMethods(name))
end

function M.getInventoryNames(excluded)
  local excludeSet = {}
  if excluded then
    for _, name in ipairs(excluded) do excludeSet[name] = true end
  end

  local names = {}
  for _, name in ipairs(peripheral.getNames()) do
    if M.isInventory(name) and not excludeSet[name] then
      names[#names + 1] = name
    end
  end
  table.sort(names)
  return names
end

function M.scanAll(excluded)
  local names = M.getInventoryNames(excluded)
  local results, errors = {}, {}

  for _, name in ipairs(names) do
    local inv = peripheral.wrap(name)
    if not inv then
      errors[name] = "wrap failed"
    else
      local data, err = inventory.scan(inv)
      if data then
        results[name] = data
      else
        errors[name] = err
      end
    end
  end

  return results, errors
end

return M
