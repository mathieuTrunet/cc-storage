local harness, root = ...
local format = dofile(root .. "/src/lib/format.lua")

harness.eq(format.itemName("minecraft:iron_ingot"), "iron ingot", "strips namespace and underscores")
harness.eq(
  format.itemName("sophisticatedstorage:limited_barrel_1"),
  "limited barrel 1",
  "strips a longer namespace"
)
harness.eq(format.itemName("no_namespace"), "no namespace", "underscores without a namespace")
