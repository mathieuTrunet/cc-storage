local harness, root = ...
local config = dofile(root .. "/src/lib/config.lua")

local parsed, err = config.fromTable({})
harness.eq(err, nil, "empty object is valid")
harness.eq(parsed.outputChest, nil, "outputChest defaults to nil")
harness.same(parsed.excluded, {}, "excluded defaults to an empty array")

parsed = config.fromTable({
  syntax = { outputChest = "string | null" },
  outputChest = "minecraft:chest_3",
  excluded = { "minecraft:chest_0", "top" },
})
harness.eq(parsed.outputChest, "minecraft:chest_3", "keeps a peripheral name")
harness.same(parsed.excluded, { "minecraft:chest_0", "top" }, "keeps excluded names in order")

harness.eq(config.fromTable("nope"), nil, "rejects a non-object")
harness.eq(select(2, config.fromTable({ outputChest = 1 })), "outputChest must be a string or null", "rejects a non-string outputChest")
harness.eq(select(2, config.fromTable({ outputChest = "" })), "outputChest must be a string or null", "rejects an empty outputChest")
harness.eq(select(2, config.fromTable({ excluded = "top" })), "excluded must be an array of strings", "rejects a string excluded")
harness.eq(select(2, config.fromTable({ excluded = { top = true } })), "excluded must be an array of strings", "rejects an object excluded")
harness.eq(select(2, config.fromTable({ excluded = { "top", "" } })), "excluded must be an array of strings", "rejects an empty excluded name")
harness.eq(select(2, config.fromTable({ excluded = { [1] = "top", [3] = "left" } })), "excluded must be an array of strings", "rejects holes in excluded")
