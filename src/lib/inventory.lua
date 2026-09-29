local M = {}

-- True when a peripheral method list exposes the generic inventory interface.
function M.hasInventoryInterface(methods)
  if type(methods) ~= "table" then return false end
  local set = {}
  for _, name in ipairs(methods) do set[name] = true end
  return set.size and set.list and true or false
end

-- Read one inventory.
-- inv.size and inv.list are called with no self, same as a wrapped CC peripheral.
-- Returns { size, items } or nil plus an error message.
function M.scan(inv)
  if type(inv) ~= "table" or type(inv.size) ~= "function" or type(inv.list) ~= "function" then
    return nil, "not an inventory"
  end

  local okSize, size = pcall(inv.size)
  if not okSize then
    return nil, "size() failed"
  end

  local okList, items = pcall(inv.list)
  if not okList then
    return nil, "list() failed"
  end

  return { size = size, items = items }
end

return M
