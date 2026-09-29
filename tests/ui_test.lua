local harness, root = ...
local ui = dofile(root .. "/src/lib/ui.lua")
local format = dofile(root .. "/src/lib/format.lua")

local names = {
  "minecraft:stone",
  "minecraft:iron_ingot",
  "minecraft:dirt",
}

harness.same(ui.filter(names, "", format.itemName), names, "empty query keeps every name in order")
harness.same(ui.filter(names, "ING", format.itemName), {
  "minecraft:iron_ingot",
}, "query matches the formatted name, ignoring case")
harness.same(ui.filter(names, "i", format.itemName), {
  "minecraft:iron_ingot",
  "minecraft:dirt",
}, "filter keeps source order")
harness.same(ui.filter(names, "oak", format.itemName), {}, "unknown query matches nothing")
harness.same(ui.filter({}, "iron", format.itemName), {}, "empty name list stays empty")

local items = { "a", "b", "c", "d" }

harness.same({ ui.window(items, 0, 2) }, { { "a", "b" }, 0 }, "window starts at the first rows")
harness.same({ ui.window(items, 1, 2) }, { { "b", "c" }, 1 }, "window shifts by the scroll offset")
harness.same({ ui.window(items, 99, 2) }, { { "c", "d" }, 2 }, "window clamps a scroll past the end")
harness.same({ ui.window(items, -4, 2) }, { { "a", "b" }, 0 }, "window clamps a negative scroll")
harness.same({ ui.window(items, 3, 0) }, { {}, 0 }, "zero row limit shows nothing")
harness.same({ ui.window({ "a", "b" }, 4, 5) }, { { "a", "b" }, 0 }, "short list cannot scroll")

harness.eq(ui.scrollBy(0, 1, 4, 2), 1, "scrolling down moves one row later")
harness.eq(ui.scrollBy(0, -1, 4, 2), 0, "scrolling up at the top stays put")
harness.eq(ui.scrollBy(2, 1, 4, 2), 2, "scrolling down at the end stays put")

-- height 6: search, three list rows, status, button
local view = { height = 6, scroll = 0, rowCount = 2 }

harness.same(ui.hit(1, 2, view), { kind = "row", index = 1 }, "first list row is the first item")
harness.same(ui.hit(10, 3, view), { kind = "row", index = 2 }, "second list row is the second item")
harness.eq(ui.hit(1, 4, view), nil, "empty list space is not a row")
harness.same(ui.hit(1, 2, { height = 6, scroll = 2, rowCount = 5 }), {
  kind = "row",
  index = 3,
}, "scroll shifts which item a row click selects")
harness.same(ui.hit(1, 6, view), { kind = "button", id = "take" }, "button click")
harness.same(ui.hit(6, 6, view), { kind = "button", id = "take" }, "click on the last button character")
harness.eq(ui.hit(7, 6, view), nil, "click past the button misses")
harness.eq(ui.hit(1, 1, view), nil, "search line is not a row or a button")
harness.eq(ui.hit(1, 5, view), nil, "status line is not a row or a button")

local lines = ui.lines({
  width = 20,
  height = 6,
  query = "ir",
  visible = {
    { label = "iron ingot", total = 13, selected = false },
    { label = "stone", total = 5, selected = true },
  },
  status = "moved 4",
})

harness.eq(lines[1], "> ir                ", "search line shows the query")
harness.eq(lines[2], " iron ingot       13", "row shows the label and the total")
harness.eq(lines[3], ">stone             5", "selected row uses a marker")
harness.eq(lines[4], "                    ", "unused list row is blank")
harness.eq(lines[5], "moved 4             ", "status line reports the move")
harness.eq(lines[6], "[Take]              ", "button sits on the last line")

harness.eq(
  ui.lines({
    width = 12,
    height = 4,
    query = "",
    visible = { { label = "iron ingot", total = 13, selected = false } },
    status = "",
  })[2],
  " iron ing 13",
  "a long label keeps the count on screen"
)

harness.eq(ui.type("ir", "on"), "iron", "typing appends")
harness.eq(ui.type("ir", "on\ningot"), "iron ingot", "paste turns a line break into a space")
harness.eq(ui.erase("iron"), "iro", "erase drops the last character")
harness.eq(ui.erase(""), "", "erase on an empty query stays empty")
