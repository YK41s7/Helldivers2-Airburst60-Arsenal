-- Airburst Launcher reserve ammo = 60
-- Arsenal-compatible Lua patch
-- Goal: detect weapon entries whose ID/name contains "airburst" and set reserve ammo to 60

local MOD_NAME = "Airburst60"
local TARGET = "airburst"
local RESERVE = 60

local modState = {
  backups = {},
  patched = 0,
  scanned = 0,
}

local function log(msg)
  print("[" .. MOD_NAME .. "] " .. tostring(msg))
end

local function lowerString(value)
  if type(value) == "string" then
    return value:lower()
  end
  return ""
end

local function backupValue(owner, key, value)
  if owner == nil or key == nil then
    return
  end

  if owner.__airburst60_backup == nil then
    owner.__airburst60_backup = {}
  end

  if owner.__airburst60_backup[key] == nil then
    owner.__airburst60_backup[key] = value
  end
end

local function setAmmoFields(obj, label)
  if type(obj) ~= "table" then
    return false
  end

  local changed = false

  local numericFields = {
    "reserve_ammo",
    "total_ammo",
    "carried_ammo",
    "ammoReserve",
    "reserveAmmo",
    "totalAmmo",
    "carriedAmmo",
    "ammo_capacity",
    "ammoCapacity",
    "max_ammo",
    "ammo_max"
  }

  for _, field in ipairs(numericFields) do
    if obj[field] ~= nil then
      if type(obj[field]) == "number" then
        backupValue(obj, field, obj[field])
        obj[field] = RESERVE
        changed = true
        log("Patched " .. tostring(label) .. "." .. field .. " -> " .. tostring(RESERVE))
      elseif type(obj[field]) == "table" then
        for _, sub in ipairs({"reserve", "total", "carried", "max", "capacity"}) do
          if obj[field][sub] ~= nil then
            backupValue(obj[field], sub, obj[field][sub])
            obj[field][sub] = RESERVE
            changed = true
            log("Patched " .. tostring(label) .. "." .. field .. "." .. sub .. " -> " .. tostring(RESERVE))
          end
        end
      end
    end
  end

  if type(obj.ammo) == "table" then
    local ammo = obj.ammo
    for _, sub in ipairs({"reserve", "total", "carried", "max", "capacity"}) do
      if ammo[sub] ~= nil then
        backupValue(ammo, sub, ammo[sub])
        ammo[sub] = RESERVE
        changed = true
        log("Patched " .. tostring(label) .. ".ammo." .. sub .. " -> " .. tostring(RESERVE))
      end
    end
  end

  return changed
end

local function isAirburstCandidate(label, entry)
  if type(entry) ~= "table" then
    return false
  end

  local labelText = lowerString(label)
  local nameText = lowerString(entry.name)
  local weaponText = lowerString(entry.weapon_name)
  local classText = lowerString(entry.class_name)
  local class = lowerString(entry.class)

  return labelText:find(TARGET, 1, true) ~= nil
    or nameText:find(TARGET, 1, true) ~= nil
    or weaponText:find(TARGET, 1, true) ~= nil
    or classText:find(TARGET, 1, true) ~= nil
    or class:find(TARGET, 1, true) ~= nil
end

local function tryPatchEntry(label, entry)
  if type(entry) ~= "table" then
    return false
  end

  if isAirburstCandidate(label, entry) then
    if setAmmoFields(entry, tostring(label)) then
      modState.patched = modState.patched + 1
      return true
    end
  end

  for k, v in pairs(entry) do
    if type(v) == "table" then
      if isAirburstCandidate(k, v) then
        if setAmmoFields(v, tostring(k)) then
          modState.patched = modState.patched + 1
          return true
        end
      end
    end
  end

  return false
end

local function walkTable(tab)
  if type(tab) ~= "table" then
    return
  end

  local seen = {}
  local function inner(t)
    if type(t) ~= "table" or seen[t] then
      return
    end
    seen[t] = true

    for k, v in pairs(t) do
      modState.scanned = modState.scanned + 1
      if type(v) == "table" then
        tryPatchEntry(k, v)
        inner(v)
      end
    end
  end

  inner(tab)
end

local function findCandidateTables()
  local list = {}

  local push = function(value)
    if value and type(value) == "table" then
      table.insert(list, value)
    end
  end

  push(_G.Weapons)
  push(_G.WeaponDatabase)
  push(_G.WeaponDefs)
  push(_G.WeaponTable)
  push(_G.ItemDB)
  push(_G.ItemTable)
  push(_G.GameData and _G.GameData.Weapons)
  push(_G.GameData and _G.GameData.WeaponDefs)
  push(_G.GameData and _G.GameData.WeaponTable)
  push(_G.GameData and _G.GameData.ItemDB)

  return list
end

local function runPatch()
  modState.patched = 0
  modState.scanned = 0

  for _, tbl in ipairs(findCandidateTables()) do
    if type(tbl) == "table" then
      for k, v in pairs(tbl) do
        if type(v) == "table" then
          tryPatchEntry(k, v)
        end
      end
    end
  end

  walkTable(_G)

  log("Scan complete. patched=" .. tostring(modState.patched) .. ", scanned=" .. tostring(modState.scanned))
end

if type(RegisterForEvent) == "function" then
  RegisterForEvent("OnGameInit", function()
    runPatch()
  end)
end

if type(AddCallback) == "function" then
  AddCallback("OnGameLoaded", function()
    runPatch()
  end)
end

if type(on_init) == "function" then
  on_init(function()
    runPatch()
  end)
end

runPatch()
