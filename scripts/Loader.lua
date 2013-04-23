-- dofile("ACS-Core.lua")
-- if atcp == nil or not pcall(dofile, "ACS-Settings_" .. atcp.name .. ".lua") then dofile("ACS-Settings.lua") end
-- --dofile("ACS-Settings.lua")
-- dofile("ACS-Triggers.lua")
-- dofile("ACS-Balances.lua")
-- dofile("ACS-Aliases.lua")
-- dofile("ACS-ActionQueueing.lua")
-- dofile("ACS-Healing.lua")
-- dofile("ACS-Prompt.lua")
-- dofile("ACS-Defenses.lua")
-- dofile("ACS-LimbTracking.lua")
-- dofile("ACS-Elixlist.lua")
-- dofile("ACS-Bashing.lua")
-- dofile("ACS-Afflictions.lua")
-- dofile("ACS-Wielding.lua")
-- dofile("ACS-EnemyTracking.lua")
-- dofile("ACS-Reanimation.lua")
-- dofile("ACS-Announcer.lua")
-- if isClass("atabahi") then dofile("ACS-AtabahiAttack.lua") end
-- if isClass("teradrim") then dofile("ACS-Teradrim.lua") end
-- if isClass("syssin") then dofile("ACS-Syssin.lua") end
-- if isClass("sentinel") then dofile("ACS-Sentinel.lua") end
-- if isClass("carnifex") then dofile("ACS-Carnifex.lua") end
-- if isClass("luminary") then dofile("ACS-Luminary.lua") end
-- pauseRedef = true
-- add_timer(1, function() pauseRedef = false end)

-- if class.setup then
--   class.setup()
-- end


echo("LOADER INITIALIZED!")

dofile("scripts/core/Core.lua")

-- Load the default settings
dofile("scripts/settings/Defaults.lua")
-- Try to find a matching settings page to override the defaults.
if (atcp and atcp.name) then
	pcall(dofile, "scripts/settings/" .. atcp.name .. ".lua")
end
if living then str = "Living " else str = "Undead " end
echo("Settings loaded for " .. atcp.name .. ". " .. str .. classType)

dofile("scripts/core/Triggers.lua")
dofile("scripts/core/Balances.lua")
dofile("scripts/core/Aliases.lua")
dofile("scripts/core/ActionQueueing.lua")
dofile("scripts/core/Healing.lua")
dofile("scripts/core/Prompt.lua")
dofile("scripts/core/Defenses.lua")
dofile("scripts/core/Wielding.lua")

dofile("scripts/tracker/Afflictions.lua")
dofile("scripts/tracker/LimbTracking.lua")
dofile("scripts/tracker/EnemyTracking.lua")

dofile("scripts/utilities/Reanimation.lua")
dofile("scripts/utilities/Announcer.lua")
dofile("scripts/utilities/Elixlist.lua")

dofile("scripts/bashing/Bashing.lua")
-- dofile("scripts/bashing/NewBashing.lua")

pcall(dofile, "scripts/classes/" .. classType .. ".lua")

-- if isClass("atabahi") then dofile("ACS-AtabahiAttack.lua") end
-- if isClass("teradrim") then dofile("ACS-Teradrim.lua") end
-- if isClass("syssin") then dofile("ACS-Syssin.lua") end
-- if isClass("sentinel") then dofile("ACS-Sentinel.lua") end
-- if isClass("carnifex") then dofile("ACS-Carnifex.lua") end
-- if isClass("luminary") then dofile("ACS-Luminary.lua") end



pauseRedef = true
add_timer(1, function() pauseRedef = false end)

if class.setup then
  class.setup()
end