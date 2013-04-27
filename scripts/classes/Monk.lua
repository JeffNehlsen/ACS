echo("Monk loaded.")

dofile("scripts/classes/BaseMonk.lua")

Monk = {}
Monk.triggers = {
  {pattern = "^This is an example trigger.", handler = function(p) ACSEcho("Example trigger fired") end}
}

Monk.aliases = {
  {pattern = "^example$", handler = function(i,p) ACSEcho("Example alais fired") end}
}

BaseMonk:setup(Monk.triggers, Monk.aliases)