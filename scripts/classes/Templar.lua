echo("Templar loaded. Forward, unto Dawn!")


-- TODO: Finish converting the aliases to Templar ones.
aliases.classAliases = {
  --{pattern = "^fol$", handler = function(i,p) houndsFollow() end},

}

aliases.attackAliases = {
  {pattern = "^bat$", handler = function(i,p) hBatter() end},


  {pattern = "^bf$", handler = function(i,p) bruteforce() end},
  {pattern = "^hr$", handler = function(i,p) hRage() end},
  {pattern = "^cha$", handler = function(i,p) setCharge() end},

  {pattern = "^dsl$", handler = function(i,p) dsl() end},
}

-- TODO: Gather attack lines for the weapons
-- TODO: Figure out how empowerments/releases are going to work


-- Righteousness: Attacks
function wither() 
  send("aura withering " .. target)
end

-- Bladefire
function wither() 
  send("aura withering " .. target)
end

-- Battlefury: Attacks

function stk()
  send("strike " .. target)
end

function raze()
  send("raze " .. target)
end

function rsl()
  send("razestrike " .. target)
end

function block(direction)
  send("block " .. direction)
end

function dsl()
  send("dsk " .. target)
end

function dsw()
  send("dsw " .. target)
end

function impale()
  send("impale " .. target)
end

function zeal()
  send("zeal " .. target)
end

function lunge()
  send("lunge " .. target)
end

function rpt(limb)
  send("rupture " .. target .. " " .. limb)
end

function tmp()
  send("tempest " .. target)
end

function dsb()
  send("disembowel " .. target)

function charge()
  send("charge " .. target)
end

function rnd()
  send("rend " .. target)
end

function clv()
  send ("cleave" .. target)
end