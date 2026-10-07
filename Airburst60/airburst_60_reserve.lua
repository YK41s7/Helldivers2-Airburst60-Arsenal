-- Airburst Launcher reserve ammo = 60
-- Arsenal-compatible Lua mod
-- Tries to locate weapon definitions and patch ammo values to 60.

local TARGET = "airburst"
local RESERVE = 60

local function lowerString(value)
  if type(value) == "string" then
    return value:lower()
  end
  return ""
end

local function setAmmoFields(obj)
  if type(obj) ~= "table" then
    return false
  end

  local patched = false

  local commonKeys = {
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
    "ammo_max",
    "ammo"
  }

  for _, key in ipairs(commonKeys) do
    local value = obj[key]
    if value ~= nil then
      if type(value) == "number" then
        obj[key] = RESERVE
        patched = true
      elseif type(value) == "table" then
        for _, subKey in ipairs({"reserve", "total", "carried", "max", "capacity"}) do
          if value[subKey] ~= nil then
            value[subKey] = RESERVE
            patched = true
          end
        end
      end
    end
  end

  if type(obj.ammo) == "table" then
    if obj.ammo.reserve ~= nil then obj.ammo.reserve = RESERVE; patched = true end
    if obj.ammo.total ~= nil then obj.ammo.total = RESERVE; patched = true end
    if obj.ammo.carried ~= nil then obj.ammo.carried = RESERVE; patched = true end
    if obj.ammo.max ~= nil then obj.ammo.max = RESERVE; patched = true end
    if obj.ammo.capacity ~= nil then obj.ammo.capacity = RESERVE; patched = true end
  end

  return patched
end

local function isAirburstMatch(label, entry)
  if type(entry) ~= "table" then
    return false
  end

  local labelText = lowerString(label)
  local nameText = lowerString(entry.name)
  local weaponText = lowerString(entry.weapon_name)
  local classText = lowerString(entry.class_name)
  local class = lowerString(entry.class)

  if labelText:find(TARGET, 1, true) ~= nil then
    return true
  end
  if nameText:find(TARGET, 1, true) ~= nil then
    return true
  end
  if weaponText:find(TARGET, 1, true) ~= nil then
    return true
  end
  if classText:find(TARGET, 1, true) ~= nil then
    return true
  end
  if class:find(TARGET, 1, true) ~= nil then
    return true
  end

  return false
end

local function patchWeaponEntry(label, entry)
  if type(entry) ~= "table" then
    return false
  end

  if isAirburstMatch(label, entry) then
    if setAmmoFields(entry) then
      print("[Airburst60] Patched weapon: " .. tostring(label))
      return true
    end
  end

  for k, v in pairs(entry) do
    if type(v) == "table" then
      if isAirburstMatch(k, v) then
        if setAmmoFields(v) then
          print("[Airburst60] Patched nested weapon: " .. tostring(k))
          return true
        end
      end
    end
  end

  return false
end

local function scanAndPatch()
  local patched = 0
  local seen = {}

  local function walk(tab)
    if type(tab) ~= "table" or seen[tab] then
      return
    end
    seen[tab] = true

    for k, v in pairs(tab) do
      if type(v) == "table" then
        if patchWeaponEntry(k, v) then
          patched = patched + 1
        end
        walk(v)
      end
    end
  end

  local candidateTables = {
    _G.Weapons,
    _G.WeaponDatabase,
    _G.WeaponDefs,
    _G.WeaponTable,
    _G.ItemDB,
    _G.ItemTable,
    _G.GameData and _G.GameData.Weapons,
    _G.GameData and _G.GameData.WeaponDefs,
    _G.GameData and _G.GameData.WeaponTable,
    _G.GameData and _G.GameData.ItemDB
  }

  for _, tbl in ipairs(candidateTables) do
    if type(tbl) == "table" then
      for k, v in pairs(tbl) do
        if type(v) == "table" then
          if patchWeaponEntry(k, v) then
            patched = patched + 1
          end
        end
      end
    end
  end

  walk(_G)
  print("[Airburst60] Scan complete. Patched count: " .. tostring(patched))
end

if type(RegisterForEvent) == "function" then
  RegisterForEvent("OnGameInit", function()
    scanAndPatch()
  end)
end

if type(AddCallback) == "function" then
  AddCallback("OnGameLoaded", function()
    scanAndPatch()
  end)
end

if type(on_init) == "function" then
  on_init(function()
    scanAndPatch()
  end)
end

scanAndPatch()
