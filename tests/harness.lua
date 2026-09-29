local M = { passed = 0, failed = 0 }

function M.check(cond, message)
  if cond then
    M.passed = M.passed + 1
    return
  end
  M.failed = M.failed + 1
  io.stderr:write("FAIL " .. message .. "\n")
end

function M.eq(actual, expected, message)
  if actual == expected then
    M.passed = M.passed + 1
    return
  end
  M.failed = M.failed + 1
  io.stderr:write(string.format(
    "FAIL %s\n  expected: %s\n  actual:   %s\n",
    message, tostring(expected), tostring(actual)
  ))
end

local function deepEqual(a, b)
  if type(a) ~= type(b) then return false end
  if type(a) ~= "table" then return a == b end
  local seen = {}
  for k, v in pairs(a) do
    if not deepEqual(v, b[k]) then return false end
    seen[k] = true
  end
  for k in pairs(b) do
    if not seen[k] then return false end
  end
  return true
end

function M.same(actual, expected, message)
  if deepEqual(actual, expected) then
    M.passed = M.passed + 1
    return
  end
  M.failed = M.failed + 1
  io.stderr:write("FAIL " .. message .. "\n")
end

function M.finish()
  if M.failed > 0 then
    io.stderr:write(string.format("%d failed, %d passed\n", M.failed, M.passed))
    os.exit(1)
  end
  print(string.format("%d passed", M.passed))
end

return M
