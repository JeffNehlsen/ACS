echo("Templar loaded. Forward, unto Dawn!")

Templar = {}

-- TODO: Finish converting the aliases to Templar ones.
Templar.aliases = {
  -- {pattern = "^bat$", handler = function(i,p) hBatter() end},


  -- {pattern = "^bf$", handler = function(i,p) bruteforce() end},
  -- {pattern = "^hr$", handler = function(i,p) hRage() end},
  -- {pattern = "^cha$", handler = function(i,p) setCharge() end},

  -- {pattern = "^dsl$", handler = function(i,p) dsl() end},

    {pattern = "^blessings (%w+)$", handler = function(i,p) Templar:blessingHandler(i,p) end}
}

Templar.triggers = {
    {pattern = "You focus momentarily as you envelop yourself in the righteous aura of (%w+).", handler = function(p) Templar:setAura(p) end},
    {pattern = "You focus and the aura of %w+ flickers and fades away.", handler = function(p) currentAura = "" end},
    {pattern = "Your aura flickers and fades as you lack the mana to maintain it.", handler = function(p) currentAura = "" end},

    {pattern = "You focus on your (%w+) aura and draw its power into you, focusing it onto your body.", handler = function(p) Templar:addedBlessing(p) end},
    {pattern = "You focus and cleanse yourself of the (%w+) blessing.", handler = function(p) Templar:removedBlessing(p) end},
    {pattern = "You cleanse yourself of any active blessings.", handler = function(p) Templar.currentBlessings = {} end},

    {pattern = "You are already benefiting from an aura of (%w+).", handler = function(p) Templar:setAura(p) end},
    {pattern = "You are already benefiting from the (%w+) blessing.", handler = function(p) Templar:addedBlessing(p) end},
}

-- TODO: Gather attack lines for the weapons
-- TODO: Figure out how empowerments/releases are going to work
-- Double Raze: empower blaze/razeslash



function Templar:setAura(p)
    Templar.currentAura = mb.line:match(p)
    Templar.currentAura = string.lower(Templar.currentAura)
    ACSLabel("AURA: " .. Templar.currentAura)
end

function Templar:addedBlessing(p)
    local blessing = mb.line:match(p)
    ACSLabel("Added Blessing: " .. blessing)
    table.insert(Templar.currentBlessings, blessing)
end

function Templar:removedBlessing(p)
    local blessing = mb.line:match(p)
    for i, cBlessing in ipairs(self.currentBlessings) do
        if blessing == cBlessing then
            ACSLabel("Removed Blessing: " .. blessing)
            table.remove(self.currentBlessings, i)
        end
    end
end


-- Righteousness: Attacks
function Templar:wither() 
  send("aura withering " .. target)
end

-- Bladefire

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
end

function Templar:charge()
  send("charge " .. target)
end

function Templar:rend()
  send("rend " .. target)
end

function Templar:cleave()
  send ("cleave" .. target)
end

--------------------
-- AURA/BLESSINGS --
--------------------
Templar.currentAura = ""
Templar.currentBlessings = {}

Templar.blessings = {
  bashing = {
    aura = "protection",
    blessings = {"healing", "meditation", "redemption"}
  },
  steamroller = {
    aura = "purity",
    blessings = {"protection", "meditation", "redemption"}
  }
}

function Templar:blessingHandler(i,p)
    local set = i:match(p)
    self:setBlessings(set)
end

function Templar:setBlessings(type)
    if not Templar.blessings[type] then
        ACSEcho("Blessing set " .. type .. " not found.")
        return
    end

    if self.currentAura ~= "" then
        actions:add(function() send("aura off " .. self.currentAura) end)
    end

    if #self.currentBlessings > 0 then
        actions:add(function() send("aura off blessing") end)
    end

    actions:add(function() send("aura " .. self.blessings[type].aura) end, baleq, {"equilibrium"})


    for _, blessing in ipairs(self.blessings[type].blessings) do
        actions:add(function() send("aura blessing " .. blessing) end, baleq, {"equilibrium"})
    end
end

-- Setup the class now that it is defnied
ACS:addModule(Templar, "Templar")

