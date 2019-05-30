# PowerInfusion
Priest's addon to cast Power Infusion on your favorite caster.

Will do the following checks before casting -
* Check if PI was learnt by talent
* Make sure there's no cooldown
* Make sure target is in range
* Check if target already has PI (from other priest?!)
* Confirm that target has received PI 

If enabled, will whisper the target if PI was OK or if there was an issue, like being too far.

# Usage

* `/pi PLAYERNAME` - set your favorite caster, replace `PLAYERNAME` with the actual name, like `/pi polz`.
* `/pi h` - print help and current configuration.
* `/pi y` - enable/disable yelling after a successful PI.
* `/pi w` - enable/disable whispering the target in case of an issue, or if PI has been casted.
