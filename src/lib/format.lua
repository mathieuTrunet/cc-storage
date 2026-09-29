local M = {}

-- "minecraft:iron_ingot" -> "iron ingot"
-- "sophisticatedstorage:limited_barrel_1" -> "limited barrel 1"
function M.itemName(name)
  local withoutMod = name:match("^[%w_]+:(.+)$") or name
  return (withoutMod:gsub("_", " "))
end

return M