echo("Zealot system loaded. Unbelievers beware!")
--Attack system aliases, etc.

dofile("scripts/classes/BaseMonk.lua")

Zealot = {}
Zealot.triggers = {
  {pattern = "^This is an example trigger.", handler = function(p) ACSEcho("Example trigger fired") end}
}

Zealot.aliases = {
  {pattern = "^example$", handler = function(i,p) ACSEcho("Example alais fired") end}
}

BaseMonk:setup(Zealot.triggers, Zealot.aliases)