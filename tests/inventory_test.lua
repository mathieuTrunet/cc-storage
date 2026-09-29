local harness, root = ...
local inventory = dofile(root .. "/src/lib/inventory.lua")

harness.check(
  inventory.hasInventoryInterface({ "pushItems", "list", "size" }),
  "size and list mark an inventory"
)
harness.check(not inventory.hasInventoryInterface({ "size" }), "list is required")
harness.check(not inventory.hasInventoryInterface({ "list" }), "size is required")
harness.check(not inventory.hasInventoryInterface({}), "empty method list is not an inventory")
harness.check(not inventory.hasInventoryInterface(nil), "nil method list is not an inventory")

local items = { [1] = { name = "minecraft:dirt", count = 2 } }
local data, err = inventory.scan({
  size = function() return 27 end,
  list = function() return items end,
})
harness.eq(err, nil, "successful scan has no error")
harness.eq(data.size, 27, "scan reports size")
harness.eq(data.items, items, "scan returns the list() table")

local failedSize, sizeErr = inventory.scan({
  size = function() error("boom") end,
  list = function() return {} end,
})
harness.eq(failedSize, nil, "size failure yields no data")
harness.eq(sizeErr, "size() failed", "size failure message")

local failedList, listErr = inventory.scan({
  size = function() return 9 end,
  list = function() error("boom") end,
})
harness.eq(failedList, nil, "list failure yields no data")
harness.eq(listErr, "list() failed", "list failure message")

local missing, missingErr = inventory.scan(nil)
harness.eq(missing, nil, "nil is not scanned")
harness.eq(missingErr, "not an inventory", "nil scan error")

local noSize, noSizeErr = inventory.scan({
  list = function() return {} end,
})
harness.eq(noSize, nil, "missing size is not scanned")
harness.eq(noSizeErr, "not an inventory", "missing size error")
