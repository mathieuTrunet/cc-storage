-- Read the sign in front of the wired block reader named blockReader_0.
-- Prints every value the reader returns, then the text fields if they are present.

local NAME = "blockReader_0"

local reader = peripheral.wrap(NAME)
if not reader then
  error(NAME .. " is not connected", 0)
end

local function call(method)
  local fn = reader[method]
  if type(fn) ~= "function" then
    return false, "absent"
  end
  return pcall(fn)
end

local function show(label, ok, value)
  print("--- " .. label .. " ---")
  if not ok then
    print(tostring(value))
    return
  end
  print(textutils.serialize(value))
end

print("methods:")
local methods = peripheral.getMethods(NAME) or {}
table.sort(methods)
for _, method in ipairs(methods) do
  print("  " .. method)
end

show("getBlockName", call("getBlockName"))
show("getBlockStates", call("getBlockStates"))
show("getBlockState", call("getBlockState"))
show("isTileEntity", call("isTileEntity"))
show("hasBlockEntity", call("hasBlockEntity"))

local dataOk, data = call("getBlockData")
show("getBlockData", dataOk, data)

print("--- sign lines ---")
if type(data) ~= "table" then
  print("no block data")
  return
end

local function showMessages(label, side)
  print(label)
  if type(side) ~= "table" or type(side.messages) ~= "table" then
    print("  (no messages)")
    return
  end
  for i, line in ipairs(side.messages) do
    print("  " .. i .. ": " .. textutils.serialize(line))
  end
end

showMessages("front_text", data.front_text)
showMessages("back_text", data.back_text)

for i = 1, 4 do
  local key = "Text" .. i
  if data[key] ~= nil then
    print(key .. ": " .. textutils.serialize(data[key]))
  end
end
