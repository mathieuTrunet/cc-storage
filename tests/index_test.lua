local harness, root = ...
local index = dofile(root .. "/src/lib/index.lua")

local iron = { name = "minecraft:iron_ingot", count = 10 }
local stone = { name = "minecraft:stone", count = 5 }
local moreIron = { name = "minecraft:iron_ingot", count = 3 }

local results = {
  chest_a = {
    size = 27,
    items = { [1] = iron, [2] = stone },
  },
  chest_b = {
    size = 27,
    items = { [4] = moreIron },
  },
}

local idx = index.build(results)

harness.eq(index.getTotal(idx, "minecraft:iron_ingot"), 13, "sums an item across inventories")
harness.eq(index.getTotal(idx, "minecraft:stone"), 5, "sums a single stack")
harness.eq(index.getTotal(idx, "minecraft:dirt"), 0, "missing item total is zero")
harness.same(index.getLocations(idx, "minecraft:dirt"), {}, "missing item has no locations")
harness.same(index.itemNames(idx), {
  "minecraft:iron_ingot",
  "minecraft:stone",
}, "item names are sorted")

local function locationKeys(entries)
  local keys = {}
  for _, entry in ipairs(entries) do
    keys[#keys + 1] = entry.inventory .. ":" .. entry.slot .. ":" .. entry.count
  end
  table.sort(keys)
  return keys
end

harness.same(locationKeys(index.getLocations(idx, "minecraft:iron_ingot")), {
  "chest_a:1:10",
  "chest_b:4:3",
}, "locations keep inventory, slot, and count")

local ironEntries = index.getLocations(idx, "minecraft:iron_ingot")
local sawOriginal = false
for _, entry in ipairs(ironEntries) do
  if entry.item == iron then sawOriginal = true end
end
harness.check(sawOriginal, "location keeps the original item table")

local empty = index.build({})
harness.same(index.itemNames(empty), {}, "empty scan has no item names")
harness.eq(index.getTotal(empty, "minecraft:stone"), 0, "empty scan total is zero")
