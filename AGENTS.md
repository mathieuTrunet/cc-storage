# Agent instructions

This file provides guidance to agents working with code in this repository.

## Description

This is a Lua codebase that runs on the CC: Tweaked Minecraft mod. It contains an easily reusable, declarative, and deployable storage system.
The goal is to provide a dashboard for the storage system, capable of I/O operations, through an interactive in-game physical interface.

## CC: Tweaked reference

Official docs: [tweaked.cc](https://tweaked.cc/). Before calling a CC: Tweaked API, fetch the matching page and do not invent signatures. URL scheme: `module/<name>.html`, `peripheral/<name>.html`, `generic_peripheral/<name>.html`, `event/<name>.html`, `guide/…`, `reference/…`. For this project, start from [peripheral](https://tweaked.cc/module/peripheral.html), [inventory](https://tweaked.cc/generic_peripheral/inventory.html), and [item details](https://tweaked.cc/reference/item_details.html). Ignore the old ComputerCraft wiki.

## Development environment

This project uses Nix to load a reproducible Lua environment. It is loaded in the shell via `.envrc`.

## Conventions & coding style

- **Always write in English**: everything that lands in the repo: markdown docs, code comments, test names, and commit messages.
- **no `CC: Tweaked` apis in /lib**: we want to test the functions in this folder, and so, to not depend on an api wwe cannot mock or replicate.
- **favor TDD**: write test first when introducing code that depend on utils/pures functions, then implement those functions to satisfies the test sspecification.
- **justfile**: declare reusable commands in the `Justfile`.
- **ensure clean code and reusabilite**: make utils functions for reusability, order code through folders 
