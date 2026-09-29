local M = {}

-- From scanResults = { [invName] = { size=, items= } },
-- build the index:
--   index[itemName] = {
--     { inventory = invName, slot = n, count = c, item = <table item> },
--     ...
--   }
function M.build(scanResults)
  local index = {}

  for invName, data in pairs(scanResults) do
    for slot, item in pairs(data.items) do
      local entries = index[item.name]
      if not entries then
        entries = {}
        index[item.name] = entries
      end

      entries[#entries + 1] = {
        inventory = invName,
        slot = slot,
        count = item.count,
        item = item,
      }
    end
  end

  return index
end

function M.getTotal(index, itemName)
  local entries = index[itemName]
  if not entries then return 0 end

  local total = 0
  for _, e in ipairs(entries) do
    total = total + e.count
  end
  return total
end

function M.getLocations(index, itemName)
  return index[itemName] or {}
end

function M.itemNames(index)
  local names = {}
  for name in pairs(index) do names[#names + 1] = name end
  table.sort(names)
  return names
end

return M