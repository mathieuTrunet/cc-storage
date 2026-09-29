# Multi-usage

Several terminals share one central storage so two players can search and withdraw at the same time. Each terminal is its own computer. This comes after the single interface in [interface.md](interface.md) works.

## One computer is one session

A computer has one Lua machine and one terminal. Two players who open it see the same screen, including the search text and the scroll position. `key`, `char`, `mouse_click`, and `mouse_scroll` do not say which player sent them, so their keystrokes and clicks mix. Ctrl+T from one player stops the program for both.

A separate computer is a separate session. That is why each player gets their own terminal.

## Terminals

Each terminal runs the same interface. Search text, scroll position, and the in-memory index stay on that computer. Disks are not shared. There is no second program that owns the index, and no shared file.

## Wiring

Chests and every terminal sit on one wired modem network (wired modems and networking cable). `peripheral.getNames()` and `peripheral.wrap()` then see the same inventories under the same network names, so the existing scan works on each terminal.

A wireless modem carries messages only. It does not expose the chests. A terminal that is not on the cable cannot wrap the storage.

## Config

Each terminal has its own `outputChest`. That name is excluded from the scan, as [src/scan.lua](../src/scan.lua) already does when `outputChest` is set, so the output chest is not indexed as storage. One output chest used by two terminals mixes both players' withdrawals.

## Refresh

After a move, other terminals still show the previous totals until they scan again, or until they receive a modem message that the storage changed. The message is only a signal to rescan. It can wait until a later step needs it. A wireless modem can carry that signal, and it still does not attach the chests.

## Concurrent moves

The server handles one `pushItems` call at a time, so items are not duplicated. A withdrawal that takes several calls can interleave with another terminal. The count on screen may already be gone. The interface trusts the number of items the transfer actually moved, then refreshes.

## Not in the first interface

The first build is one terminal, as described in [interface.md](interface.md). This network is the shape around that terminal, not part of that first program.
