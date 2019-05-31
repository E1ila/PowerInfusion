# PowerInfusion
Priest's addon to cast Power Infusion on your favorite caster.

Will do the following checks before casting -
* Check if PI was learnt by talent
* Make sure there's no cooldown
* Make sure target is in range
• Make sure target has enough mana (useless to PI an OOM caster)
* Check if target already has PI (from other priest?!)
* Confirm that target has received PI 

If enabled, will whisper the target if PI was OK or if there was an issue, like being too far.

# Installation

Download this as a ZIP file, decompress, rename to remove the `-master` postfix and copy it to your `WoW\Interface\AddOns` folder.

# Usage

* `/pi PLAYERNAME` - set your favorite caster, replace `PLAYERNAME` with the actual name, like `/pi polz`.
* `/pi h` - print help and current configuration.
* `/pi y` - enable/disable yelling after a successful PI.
* `/pi w` - enable/disable whispering the target in case of an issue, or if PI has been casted.
* `/pi` - smartly cast Power Infusion
