local dir = fs.getDir(shell.getRunningProgram())

local function load(relative)
  local path = fs.combine(dir, relative)
  local chunk, err = loadfile(path, nil, _ENV)
  if not chunk then error(err, 0) end
  return chunk()
end

local ui          = load("lib/ui.lua")
local peripherals = load("peripherals.lua")
local index       = load("lib/index.lua")
local format      = load("lib/format.lua")
local config      = load("config.lua")

local query = ""
local scroll = 0
local selected = nil
local status = ""
local idx = {}
local names = {}

local function excludedNames()
  local excluded = {}
  for _, name in ipairs(config.excluded) do
    excluded[#excluded + 1] = name
  end
  if config.outputChest then
    excluded[#excluded + 1] = config.outputChest
  end
  return excluded
end

local function firstError(errors)
  local found = {}
  for name in pairs(errors) do
    found[#found + 1] = name
  end
  table.sort(found)
  if #found == 0 then return nil end
  return "scan error: " .. found[1]
end

local function reload()
  local results, errors = peripherals.scanAll(excludedNames())
  idx = index.build(results)
  names = index.itemNames(idx)
  return errors
end

local function filteredNames()
  return ui.filter(names, query, format.itemName)
end

local function listed(list, name)
  for _, item in ipairs(list) do
    if item == name then return true end
  end
  return false
end

-- Move every indexed stack of itemName into outputChest.
-- Each pushItems returns how many items actually moved.
local function moveItem(itemName)
  local moved = 0
  for _, entry in ipairs(index.getLocations(idx, itemName)) do
    local inv = peripheral.wrap(entry.inventory)
    if not inv then
      return moved, "missing " .. entry.inventory
    end
    local ok, transferred = pcall(inv.pushItems, config.outputChest, entry.slot, entry.count)
    if not ok then
      return moved, transferred
    end
    if type(transferred) ~= "number" then
      return moved, "transfer failed"
    end
    moved = moved + transferred
  end
  return moved
end

local function take(filtered)
  if not config.outputChest then
    status = "no output chest"
    return
  end
  if not selected or not listed(filtered, selected) then
    status = "select an item"
    return
  end

  local moved, err = moveItem(selected)
  status = "moved " .. moved
  if err then
    status = status .. " " .. tostring(err):match("^[^\n]*")
  end
  reload()
end

local function redraw()
  local width, height = term.getSize()
  local layout = ui.layout(height)
  local filtered = filteredNames()
  local visibleNames, nextScroll = ui.window(filtered, scroll, layout.listHeight)
  scroll = nextScroll

  local visible = {}
  for i, name in ipairs(visibleNames) do
    visible[i] = {
      label = format.itemName(name),
      total = index.getTotal(idx, name),
      selected = name == selected,
    }
  end

  local drawn = ui.lines({
    width = width,
    height = height,
    query = query,
    visible = visible,
    status = status,
  })

  term.setBackgroundColor(colors.black)
  term.setTextColor(colors.white)
  for y, line in ipairs(drawn) do
    term.setCursorPos(1, y)
    term.write(line)
  end

  local cursorX = 3 + #query
  if cursorX > width then cursorX = width end
  if cursorX < 1 then cursorX = 1 end
  term.setCursorPos(cursorX, layout.searchY)
  term.setCursorBlink(true)
end

local function onClick(button, x, y)
  if button ~= 1 then return end
  local _, height = term.getSize()
  local filtered = filteredNames()
  local hit = ui.hit(x, y, {
    height = height,
    scroll = scroll,
    rowCount = #filtered,
  })
  if not hit then return end
  if hit.kind == "row" then
    selected = filtered[hit.index]
    return
  end
  if hit.kind == "button" and hit.id == "take" then
    take(filtered)
  end
end

local errors = reload()
local scanStatus = firstError(errors)
if scanStatus then status = scanStatus end

redraw()

while true do
  local event, a, b, c = os.pullEvent()
  if event == "char" or event == "paste" then
    query = ui.type(query, a)
    scroll = 0
  elseif event == "key" and (a == keys.backspace or a == keys.delete) then
    query = ui.erase(query)
    scroll = 0
  elseif event == "mouse_scroll" then
    local _, height = term.getSize()
    scroll = ui.scrollBy(scroll, a, #filteredNames(), ui.layout(height).listHeight)
  elseif event == "mouse_click" then
    onClick(a, b, c)
  end
  redraw()
end
