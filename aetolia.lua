dofile("ACS-Core.lua")
if atcp == nil or not pcall(dofile, "ACS-Settings_" .. atcp.name .. ".lua") then dofile("ACS-Settings.lua") end
--dofile("ACS-Settings.lua")
dofile("ACS-Triggers.lua")
dofile("ACS-Balances.lua")
dofile("ACS-Aliases.lua")
dofile("ACS-ActionQueueing.lua")
dofile("ACS-Healing.lua")
dofile("ACS-Prompt.lua")
dofile("ACS-Defenses.lua")
dofile("ACS-LimbTracking.lua")
dofile("ACS-Elixlist.lua")
dofile("ACS-Bashing.lua")
dofile("ACS-Afflictions.lua")
dofile("ACS-Wielding.lua")
dofile("ACS-EnemyTracking.lua")
dofile("ACS-Reanimation.lua")
dofile("ACS-Announcer.lua")
if isClass("atabahi") then dofile("ACS-AtabahiAttack.lua") end
if isClass("teradrim") then dofile("ACS-Teradrim.lua") end
if isClass("syssin") then dofile("ACS-Syssin.lua") end
if isClass("sentinel") then dofile("ACS-Sentinel.lua") end
if isClass("carnifex") then dofile("ACS-Carnifex.lua") end
if isClass("luminary") then dofile("ACS-Luminary.lua") end
pauseRedef = true
add_timer(1, function() pauseRedef = false end)

if class.setup then
  class.setup()
end