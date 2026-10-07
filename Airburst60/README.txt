Airburst Launcher 60 Reserve Mod
================================

This mod attempts to set the Airburst Launcher reserve ammo to 60.

How to install:
1. Download the ZIP from the repository (main branch) or clone the repo.
2. Unzip the folder so you have a directory named `Airburst60` containing the files.
3. Place the `Airburst60` folder into your Arsenal mods directory (where you usually put mods).
4. Launch Arsenal, enable the mod, then start Helldivers 2.

Notes:
- This is a Lua runtime patch. It tries to locate weapon definitions and patch ammo fields automatically.
- Depending on the game data structure, some weapons may use different field names such as reserveAmmo, totalAmmo, or ammo.reserve. If the launcher is not detected, edit `airburst_60_reserve.lua` and adjust target name or field names to match your game build.
- Use this in single-player or private matches. Modding online/multiplayer can cause anti-cheat or server issues.

