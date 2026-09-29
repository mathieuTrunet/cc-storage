-- Install src/ from this GitHub repo onto the computer.
-- Run once:
--   wget https://raw.githubusercontent.com/mathieuTrunet/cc-storage/main/install.lua
--   install
-- Needs a public repo and HTTP access to api.github.com and raw.githubusercontent.com.
-- Files land next to this program, with the src/ prefix removed, so scan.lua can
-- dofile its siblings.

local REPO_URL = "https://github.com/mathieuTrunet/cc-storage"
local BRANCH = "main"
local SOURCE = "src"

local HEADERS = {
  ["User-Agent"] = "cc-storage-install",
  ["Accept"] = "application/vnd.github+json",
}

local function fail(message)
  error(message, 0)
end

local function ownerAndRepo(url)
  local owner, name = url:match("github%.com[:/]([^/]+)/([^/]+)")
  if not owner then
    fail("Cannot parse GitHub repo URL: " .. url)
  end
  return owner, (name:gsub("%.git$", ""))
end

local function encodePath(path)
  local parts = {}
  for part in path:gmatch("[^/]+") do
    parts[#parts + 1] = textutils.urlEncode(part)
  end
  return table.concat(parts, "/")
end

local function readUrl(url)
  local response, err, failed = http.get(url, HEADERS)
  if not response then
    local detail = err or "request failed"
    if failed then
      local body = failed.readAll()
      failed.close()
      if body and body ~= "" then
        detail = detail .. "\n" .. body
      end
    end
    fail(detail .. "\n" .. url)
  end

  local body = response.readAll()
  response.close()
  return body
end

local function sourceFiles(owner, name)
  local url = string.format(
    "https://api.github.com/repos/%s/%s/git/trees/%s?recursive=1",
    owner,
    name,
    textutils.urlEncode(BRANCH)
  )
  local data = textutils.unserializeJSON(readUrl(url))
  if type(data) ~= "table" or type(data.tree) ~= "table" then
    local message = type(data) == "table" and data.message or "invalid tree response"
    fail("GitHub tree: " .. tostring(message))
  end
  if data.truncated then
    fail("GitHub tree was truncated")
  end

  local prefix = SOURCE .. "/"
  local files = {}
  for _, entry in ipairs(data.tree) do
    if entry.type == "blob" and type(entry.path) == "string" and entry.path:sub(1, #prefix) == prefix then
      files[#files + 1] = entry.path
    end
  end
  table.sort(files)
  return files
end

local function localPath(remotePath)
  local relative = remotePath:sub(#SOURCE + 2)
  local base = fs.getDir(shell.getRunningProgram())
  if base == "" then
    return relative
  end
  return fs.combine(base, relative)
end

local function writeFile(path, contents)
  local parent = fs.getDir(path)
  if parent ~= "" and not fs.exists(parent) then
    fs.makeDir(parent)
  end

  local handle = fs.open(path, "w")
  if not handle then
    fail("Cannot write " .. path)
  end
  handle.write(contents)
  handle.close()
end

local function main()
  if not http then
    fail("HTTP API is disabled on this computer")
  end

  local owner, name = ownerAndRepo(REPO_URL)
  print("Fetching " .. owner .. "/" .. name .. "@" .. BRANCH .. " " .. SOURCE .. "/")

  local files = sourceFiles(owner, name)
  if #files == 0 then
    fail("No files under " .. SOURCE .. "/")
  end

  for _, remotePath in ipairs(files) do
    local path = localPath(remotePath)
    local raw = string.format(
      "https://raw.githubusercontent.com/%s/%s/%s/%s",
      owner,
      name,
      textutils.urlEncode(BRANCH),
      encodePath(remotePath)
    )
    writeFile(path, readUrl(raw))
    print(remotePath .. " -> " .. path)
  end

  print("Installed " .. #files .. " files.")
end

main()
