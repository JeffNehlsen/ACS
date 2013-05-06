echo("Templar loaded. Forward, unto Dawn!")

Templar = {}

-- TODO: Finish converting the aliases to Templar ones.
Templar.aliases = {
  -- {pattern = "^bat$", handler = function(i,p) hBatter() end},


  -- {pattern = "^bf$", handler = function(i,p) bruteforce() end},
  -- {pattern = "^hr$", handler = function(i,p) hRage() end},
  -- {pattern = "^cha$", handler = function(i,p) setCharge() end},

  -- {pattern = "^dsl$", handler = function(i,p) dsl() end},
}

Templar.triggers = {
  
}

-- TODO: Gather attack lines for the weapons
-- TODO: Figure out how empowerments/releases are going to work


-- Righteousness: Attacks
function Templar:wither() 
  send("aura withering " .. target)
end

-- Bladefire
function Templar:wither() 
  send("aura withering " .. target)
end

-- Battlefury: Attacks

function Templar:strike()
  send("strike " .. target)
end

function Templar:raze()
  send("raze " .. target)
end

function Templar:rsl()
  send("razestrike " .. target)
end

function Templar:block(direction)
  send("block " .. direction)
end

function Templar:dsl()
  if leftHand == rightHand then
    send("dsw " .. target)
  else
    send("dsk " .. target)
  end
end

function Templar:impale()
  send("impale " .. target)
end

function Templar:zeal()
  send("zeal " .. target)
end

function Templar:lunge()
  send("lunge " .. target)
end

function Templar:rupture(limb)
  send("rupture " .. target .. " " .. limb)
end

function Templar:tempest()
  send("tempest")
end

function Templar:disembowel()
  send("disembowel " .. target)

function Templar:charge()
  send("charge " .. target)
end

function Templar:rend()
  send("rend " .. target)
end

function Templar:cleave()
  send ("cleave" .. target)
end

-- Setup the class now that it is defnied
ACS:addModule(Templar, "Templar")