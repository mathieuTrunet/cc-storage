local dir = fs.getDir(shell.getRunningProgram())
local peripherals = dofile(fs.combine(dir, "peripherals.lua"))
local index       = dofile(fs.combine(dir, "lib/index.lua"))
local format      = dofile(fs.combine(dir, "lib/format.lua"))
local config      = dofile(fs.combine(dir, "config.lua"))

local verbose = ({ ... })[1] == "-v"

local excluded = {}
for _, name in ipairs(config.excluded) do
  excluded[#excluded + 1] = name
end
if config.outputChest then
  excluded[#excluded + 1] = config.outputChest
end

local results, errors = peripherals.scanAll(excluded)

local invCount = 0
for _ in pairs(results) do invCount = invCount + 1 end
print("=== Inventories scanned: " .. invCount .. " ===")

if next(errors) then
  print("\n=== Errors ===")
  for name, err in pairs(errors) do
    print(name .. " -> " .. err)
  end
end

if verbose then
  print("\n=== Inventory details ===")
  local names = {}
  for name in pairs(results) do names[#names + 1] = name end
  table.sort(names)

  for _, name in ipairs(names) do
    local data = results[name]
    local used = 0
    for _ in pairs(data.items) do used = used + 1 end
    print(string.format("[%s] slots %d/%d", name, used, data.size))
  end
end

local idx = index.build(results)
local names = index.itemNames(idx)

print("\n=== Totals per item ===")
local grandTotal = 0
for _, name in ipairs(names) do
  local total = index.getTotal(idx, name)
  grandTotal = grandTotal + total
  print(string.format("\n%s | %d", format.itemName(name), total))
end

print(string.format(
"\nGrand total: %d items, %d different types",
  grandTotal, #names
))