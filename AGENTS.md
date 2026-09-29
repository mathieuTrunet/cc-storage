# Agent instructions

This file provides guidance to agents working with code in this repository.

## Description

This is a Lua codebase that runs on the CC: Tweaked Minecraft mod. It contains an easily reusable, declarative, and deployable storage system.
The goal is to provide a dashboard for the storage system, capable of I/O operations, through an interactive in-game physical interface.

## Development environment

This project uses Nix to load a reproducible Lua environment. It is loaded in the shell via `.envrc`.

## Conventions & coding style

- **Always write in English**: everything that lands in the repo: markdown docs, code comments, test names, and commit messages.
- **no `CC: Tweaked` apis in /lib**: we want to test the functions in this folder, and so, to not depend on an api wwe cannot mock or replicate.
- **favor TDD**: write test first when introducing code that depend on utils/pures functions, then implement those functions to satisfies the test sspecification.
