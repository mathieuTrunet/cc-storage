# Interface

The first milestone is one computer terminal. Text search is the main action, and the computer terminal is where typing, paste, mouse clicks, and the mouse wheel are available. An in-world monitor only receives a right-click, which is not enough for search.

The terminal is one session. This plan is a single player at that computer. Several terminals on one storage network are described in [multi-usage.md](multi-usage.md) and are not part of this milestone.

## What the player can do

- Type a search query.
- Scroll the filtered list of items.
- Click a row to select it.
- Use a button to send the selected item to this terminal's `outputChest`.

That transfer is the only button action. The interface reports how many items actually moved.

## Screen

The terminal shows three regions:

1. A search line with the current query.
2. The visible slice of the filtered list. Each row shows the formatted item name and the total count.
3. Buttons for the transfer of the selected item.

There is no monitor and no on-screen keyboard.

Names on screen use [src/lib/format.lua](../src/lib/format.lua): `minecraft:iron_ingot` is shown as `iron ingot`.

## Input

These events exist only while the computer terminal is open:

- `char`, `key`, and `paste` edit the search query.
- `mouse_scroll` moves the list.
- `mouse_click` selects a row or a button.

The events do not say which player sent them. Two players opening this same computer share the screen. That case is left to [multi-usage.md](multi-usage.md), which uses a separate computer per player.

## Functions the UI needs

These functions are pure. They live under `src/lib`, take plain tables, and do not call CC: Tweaked APIs, so they can be tested the same way as the index and format helpers.

- Filter item names by the query.
- Take the visible window from a scroll offset and the number of rows that fit.
- Map a click coordinate to a row or a button.

## Data

The list is the index built from a scan. Inventories do not report insertions. The terminal scans again after each withdrawal, then shows how many items moved.

- [src/peripherals.lua](../src/peripherals.lua) lists inventories and scans them, skipping names in `config.excluded` and `config.outputChest`.
- [src/lib/index.lua](../src/lib/index.lua) groups that scan by item id. Each item has a total and a list of locations (`inventory`, `slot`, `count`).
- [src/lib/format.lua](../src/lib/format.lua) produces the name shown on a row.

[config.json](../config.json) only has `outputChest` and `excluded`.

## Transfer

Sending the selected item uses those index locations and this terminal's `outputChest`. This plan does not define how the move walks slots. The interface must show the number of items that actually moved.

## Out of scope

- A second player on the same computer.
- Monitors and on-screen keyboards.
- Depositing items into storage.
- Categories.
- Refreshing other terminals.
