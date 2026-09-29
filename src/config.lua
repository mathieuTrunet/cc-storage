local dir = fs.getDir(shell.getRunningProgram())
local parse = dofile(fs.combine(dir, "lib/config.lua"))
local path = fs.combine(dir, "config.json")

if not fs.exists(path) then
  error("Missing " .. path .. ". Copy config.json from the repository and edit it.", 0)
end

local handle = fs.open(path, "r")
if not handle then
  error("Cannot read " .. path, 0)
end
local text = handle.readAll()
handle.close()

-- null becomes nil. An empty array becomes a normal empty table.
local decoded, jsonErr = textutils.unserializeJSON(text, { parse_empty_array = false })
if type(decoded) ~= "table" then
  error(path .. ": " .. (jsonErr or "invalid JSON"), 0)
end

local values, message = parse.fromTable(decoded)
if not values then
  error(path .. ": " .. message, 0)
end

return values
