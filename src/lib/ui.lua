local M = {}

local TAKE = { id = "take", x = 1, label = "[Take]" }

-- Search on y=1, list under it, status above the button, button on the last line.
function M.layout(height)
  local buttonY = height
  local statusY = height - 1
  local listHeight = height - 3
  if listHeight < 0 then listHeight = 0 end
  if height < 2 then buttonY = nil end
  if height < 3 then statusY = nil end
  return {
    searchY = 1,
    listY = 2,
    listHeight = listHeight,
    statusY = statusY,
    buttonY = buttonY,
    button = TAKE,
  }
end

-- names stay in their current order. query is matched against labelOf(name).
function M.filter(names, query, labelOf)
  local needle = (query or ""):lower()
  if needle == "" then
    local copy = {}
    for i, name in ipairs(names) do
      copy[i] = name
    end
    return copy
  end

  local matched = {}
  for _, name in ipairs(names) do
    if labelOf(name):lower():find(needle, 1, true) then
      matched[#matched + 1] = name
    end
  end
  return matched
end

function M.window(items, scroll, limit)
  if limit <= 0 then
    return {}, 0
  end

  local maxScroll = #items - limit
  if maxScroll < 0 then maxScroll = 0 end
  if scroll < 0 then scroll = 0 end
  if scroll > maxScroll then scroll = maxScroll end

  local slice = {}
  for i = 1, limit do
    local item = items[scroll + i]
    if item == nil then break end
    slice[i] = item
  end
  return slice, scroll
end

-- direction is the mouse_scroll value: -1 up, 1 down.
function M.scrollBy(scroll, direction, count, limit)
  local dummy = {}
  for i = 1, count do dummy[i] = i end
  return select(2, M.window(dummy, scroll + direction, limit))
end

function M.hit(x, y, view)
  local layout = M.layout(view.height)
  if layout.buttonY and y == layout.buttonY then
    local button = layout.button
    if x >= button.x and x < button.x + #button.label then
      return { kind = "button", id = button.id }
    end
    return nil
  end

  if y >= layout.listY and y < layout.listY + layout.listHeight then
    local index = view.scroll + (y - layout.listY) + 1
    if index >= 1 and index <= view.rowCount then
      return { kind = "row", index = index }
    end
  end

  return nil
end

local function pad(text, width)
  if #text >= width then
    return text:sub(1, width)
  end
  return text .. string.rep(" ", width - #text)
end

local function rowLine(row, width)
  local mark = row.selected and ">" or " "
  local count = tostring(row.total)
  local room = width - #mark - #count
  if room < 1 then
    return pad(mark, width)
  end

  local label = row.label
  local labelRoom = room - 1
  if labelRoom < 0 then labelRoom = 0 end
  if #label > labelRoom then
    label = label:sub(1, labelRoom)
  end

  local gap = width - #mark - #label - #count
  if gap < 1 then gap = 1 end
  return pad(mark .. label .. string.rep(" ", gap) .. count, width)
end

function M.lines(state)
  local width = state.width
  local height = state.height
  local layout = M.layout(height)
  local blank = string.rep(" ", width)
  local lines = {}
  for y = 1, height do
    lines[y] = blank
  end

  lines[layout.searchY] = pad("> " .. (state.query or ""), width)

  local visible = state.visible or {}
  for i, row in ipairs(visible) do
    if i > layout.listHeight then break end
    lines[layout.listY + i - 1] = rowLine(row, width)
  end

  if layout.statusY then
    lines[layout.statusY] = pad(state.status or "", width)
  end
  if layout.buttonY then
    lines[layout.buttonY] = pad(layout.button.label, width)
  end

  return lines
end

function M.type(query, text)
  local flat = text:gsub("\r\n", " "):gsub("[\r\n]", " ")
  return query .. flat
end

function M.erase(query)
  if query == "" then return "" end
  return query:sub(1, -2)
end

return M
