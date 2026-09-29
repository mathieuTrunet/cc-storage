local src = debug.getinfo(1, "S").source
if src:sub(1, 1) == "@" then src = src:sub(2) end
local testsDir = src:match("^(.*)/") or "."
local root = testsDir:match("^(.*)/") or "."

local harness = dofile(testsDir .. "/harness.lua")

local files = {
  "config_test.lua",
  "format_test.lua",
  "index_test.lua",
  "inventory_test.lua",
  "ui_test.lua",
}

for _, file in ipairs(files) do
  assert(loadfile(testsDir .. "/" .. file))(harness, root)
end

harness.finish()
