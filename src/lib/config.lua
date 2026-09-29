local M = {}

local function stringList(list)
  if type(list) ~= "table" then
    return nil, "excluded must be an array of strings"
  end

  local count = 0
  for key in pairs(list) do
    if type(key) ~= "number" or key % 1 ~= 0 or key < 1 then
      return nil, "excluded must be an array of strings"
    end
    count = count + 1
  end

  local names = {}
  for i = 1, count do
    local name = list[i]
    if type(name) ~= "string" or name == "" then
      return nil, "excluded must be an array of strings"
    end
    names[i] = name
  end
  return names
end

-- raw is the object parsed from config.json.
-- The "syntax" field is documentation and is ignored.
function M.fromTable(raw)
  if type(raw) ~= "table" then
    return nil, "config must be a JSON object"
  end

  if raw.outputChest ~= nil and (type(raw.outputChest) ~= "string" or raw.outputChest == "") then
    return nil, "outputChest must be a string or null"
  end

  local excluded, err = stringList(raw.excluded or {})
  if not excluded then
    return nil, err
  end

  return {
    outputChest = raw.outputChest,
    excluded = excluded,
  }
end

return M
