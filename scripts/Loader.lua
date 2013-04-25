-- Loader.lua
-- Performs dofiles on all the ACS files needed to run
-- This script is run on 'load' and 'reload'

dofile("scripts/core/Core.lua")
dofile("scripts/core/Helpers.lua")

-- Load the default settings
dofile("scripts/settings/Defaults.lua")
-- Try to find a matching settings page to override the defaults.
if (atcp and atcp.name) then
	pcall(dofile, "scripts/settings/" .. atcp.name .. ".lua")
end
if living then str = "Living " else str = "Undead " end
echo("Settings loaded for " .. atcp.name .. ". " .. str .. classType)

-- Load the standard files
dofile("scripts/core/Triggers.lua")
dofile("scripts/core/Balances.lua")
dofile("scripts/core/Aliases.lua")
dofile("scripts/core/ActionQueueing.lua")
dofile("scripts/core/Healing.lua")
dofile("scripts/core/Prompt.lua")
dofile("scripts/core/Defenses.lua")
dofile("scripts/core/Wielding.lua")
dofile("scripts/core/Afflictions.lua")

dofile("scripts/settings/Setup.lua")

dofile("scripts/tracker/LimbTracking.lua")
dofile("scripts/tracker/EnemyTracking.lua")

dofile("scripts/utilities/Reanimation.lua")
dofile("scripts/utilities/Announcer.lua")
dofile("scripts/utilities/Elixlist.lua")

dofile("scripts/bashing/Bashing.lua")
-- dofile("scripts/bashing/NewBashing.lua")

-- Attempt to load the current classType's stuff
pcall(dofile, "scripts/classes/" .. classType .. ".lua")


-- Finalize the loading process, and if the class has a predetermined setup method, run it.
pauseRedef = true
add_timer(1, function() pauseRedef = false end)

resetTimers()
send("wielded")
show_prompt()

if class.setup then
  class.setup()
end

if weapons then
	constructWieldingTriggers()
end