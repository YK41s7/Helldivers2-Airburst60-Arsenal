Airburst Launcher 60 Reserve Mod
================================

This mod attempts to detect weapons whose name / ID contains "airburst" and sets their reserve ammo to 60.

Install:
1. Put the `Airburst60` folder into your Arsenal mod directory.
2. Make sure the mod is enabled in Arsenal.
3. Launch Helldivers 2 and check whether the Airburst Launcher now carries 60 reserve ammo.

Notes:
- This is a Lua runtime patch designed for Arsenal-based mod loading.
- It scans common weapon tables and global tables to identify the Airburst entry.
- If your current game build uses slightly different field names (for example `reserveAmmo`, `ammo.reserve`, or another custom schema), the script will still attempt to patch the common variants automatically.
- If the mod does not work, the next step is to send the exact weapon table entry or game ID to match the real structure more precisely.

Compatibility:
- Intended for PC use.
- Best tested in single-player or private sessions before using in multiplayer.

