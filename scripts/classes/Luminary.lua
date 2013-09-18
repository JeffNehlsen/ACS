echo("Luminary file loaded. Fire it up!")

shieldType = shieldType or "buckler"

Luminary = {}
--------------------
-- ANGEL TRACKING --
--------------------
angel = {
  power = 5000,
  max = 5000,
  skills = {
    aura = {
      cost = function() return 100 end,
      used = {"You bid your guardian angel to raise an aura to shield you.", "You bid your angel to put a protective shield around %w+."}
    },
    sear = {
      cost = function() return 150 end,
      used = {"Your guardian angel's eyes glow like embers as .* is seared and bursts into flame."}
    },
    fortify = {
      --  5% of max health. Two points restored per point of health drained. Multiplied negatively so it adds to the angel's power
      cost = function() return atcp.max_health / 20 * -2 end,
      used = {"The colour drains out of your face as your guardian angel is suffused with power."}
    },
    power = {
      cost = function() return atcp.max_mana / 20 * -2 end,
      used = {"With a thought you project your power into the heart of your angel guardian."}
    },
    drain = {
      cost = function() return 500 end,
      used = {"You beseech your spirit guardian to heal you."}
    },
    seek = {
      cost = function() return 5 end,
    },
    beckon = {
      cost = function() return 35 end,
      used = {
        "You bid your guardian angel to draw your enemies closer.",
        "You bid your guardian angel to draw %w+ in close."
      }
    },
    strip = {
      cost = function() return 20 end,
      used = {"You bid your angel strip a defence from %w+."}
    },
    ripples = {
      cost = function() return 15 end,
      used = {"%*+%[ Chaos Entities %]%*+"}
    },
    ward = {
      cost = function() return 15 end,
      used = {"You bid your angel guardian to summon a magic of warding."}
    },
    presences = {
      cost = function() return 50 end,
      used = {"You bid your guardian to seek out life presences nearby."}
    },
    sap = {
      cost = function() return 30 end,
      used = {"Your angel casts a piercing glance at %w+."}
    },
    empathy = {
      cost = function() return 10 end,
      used = {"Your wounds close up before your eyes."}
    },
    sacrifice = {
      cost = function() return 5000 end,
      used = {"You turn to your eternal companion and plead for the ultimate sacrifice."}
    },
    corporality = {
      cost = function() return 200 end,
    },
    corporalityTick = {
      cost = function() return 50 end,
    },
    absolve = {
      cost = function() return 500 end,
      used = {
        "You bid your Angel to rip the soul from the living body of %w+. She reaches out and attempts it, but is foiled.",
        "You nod gravely at your Guardian Angel, whose wings flare suddenly as an alien and frightening"
      }
    },
    spiritwrack = {
      cost = function() return 10 end,
      tickTimer = 15,
      used = {
        "Your angel restores %w+'s hearing.",
        "Your angel afflicts %w+ with .*."
      }
    }
  },

  -- function that is used to add and create angel triggers
  buildTriggers = function()
    for _, skill in pairs(angel.skills) do
      if type(skill) == "table" and skill.used then
        for _, v in ipairs(skill.used) do
          addTrigger("attackTriggers", v, function()
            angel.power = angel.power - skill.cost()
            if angel.power > angel.max then angel.power = angel.max end
            if angel.power < 0 then angel.power = 0 end
          end)
        end
      end
    end

    addTrigger("attackTriggers", "Your guardian burns with a power of (%d+) of a maximum 5000.", function(p)
      local amt = mb.line:match(p)
      angel.power = amt
    end)

    addTrigger("attackTriggers", "Your Guardian Angel is already at full power.", function() angel.power = angel.max end)
  end
}

class = {
  bashAttack = function()
    send("stand")
    send("wield mace")
    send("smite " .. selectedTarget)
    if tonumber(prompt.health) < 4000 then
      send("angel drain")
    elseif not hasDefense("inspiration") then
      send("perform inspiration")
    elseif tonumber(angel.power) < 4200 then
      send("angel power")
    end
  end,
  setup = function()
    angel.buildTriggers()
  end
}

--You ask your angel to afflict yourself with sensitivity and it glares at him, tormenting his soul.
--You have recovered spiritwrack balance.
-- Your wounds close up before your eyes. <-- empathy tick. 10 angel cost
-- Corporality - 50 power/20 seconds

aliases.classAliases = {
  {pattern = "^inspirs$", handler = function(i,p) send("perform inspiration strength") end},
  {pattern = "^inspird$", handler = function(i,p) send("perform inspiration dexterity") end},
  {pattern = "^inspirc$", handler = function(i,p) send("perform inspiration constitution") end},
  {pattern = "^inspiri$", handler = function(i,p) send("perform inspiration intelligence") end},

  {pattern = "^bliss (%w+)$", handler = function(i,p) doBliss(i,p) end},
  {pattern = "^pfocus$", handler = function(i,p) send("perform focus") end},
  {pattern = "^lform$", handler = function(i,p) send("evoke lightform") end},
  {pattern = "^inf$", handler = function(i,p) send("evoke infusion") end},

  {pattern = "^touch$", handler = function(i,p) send("angel touch") end},
  {pattern = "^summ$", handler = function(i,p) send("angel summon") end},
  {pattern = "^fade$", handler = function(i,p) send("angel fade") end},

  {pattern = "^seek (%w+)$", handler = function(i,p) seekHandler(i,p) end},
}

aliases.attackAliases = {
  --{pattern = "^$", handler = function(i,p)  end},
  {pattern = "^lig$", handler = function(i,p) iLightning() end},
  {pattern = "^beck (.*)", handler = function(i,p) beckonHandler(i,p) end},
  {pattern = "^aura (%w+)", handler = function(i,p) auraHandler(i,p) end},

  {pattern = "^ar$", handler = function(i,p) Luminary:smite() end},
}


triggers.attackTriggers = {
  --{pattern = "^$", handler = function(p)  end},

  {pattern = "^You strengthen your ties to the light and close your eyes briefly in concentration, only to realize", handler = function(p) stopHeal() end},
  {pattern = "^You will yourself to become corporeal once more.$", handler = function(p) startHeal() end},
  
  -- Slam. Gives asthma/haemophilia
  {pattern = "^You slam .+ into %w+'s chest, winding %w+ with the brutal attack.$", handler = function ()
    etrack:addAff("asthma")
    etrack:addAff("haemophilia")
  end},

  -- Strike. Gives paralysis
  {pattern = "^With a swift movement, you strike %w+ with .*, the symbol of the Gods flaring as you attack.$", handler = function ()
    etrack:addAff("paralysis")
  end},

  -- You ask your angel to afflict Daingean with self-pity and it glares at him, tormenting his soul.
  {pattern = {"^You direct a dark bolt of energy through your mace towards %w+. The curse of (.+) is brought down on to your victim.$",
              "^You ask your angel to afflict %w+ with (.+) and it glares at %w+, tormenting %w+ soul.$",
              "^Your angel afflicts %w+ with (.+).$"}, handler = function (p)
    chastenHandler(p)
  end},

  -- Smash/Smite
  {pattern = "^You raise up your mace to smash %w+'s (.+).$", handler = function(p) Luminary:smashSmiteHandler(p) end},

  -- Shatter
  {pattern = "^You slowly pull back a spiritual mace, readying yourself for a devastating strike.$", handler = function(p)
    Luminary.shattering = true
    stopHeal()
  end},

  {pattern = "^You cease concentrating on shattering your opponent's limbs.$", handler = function(p)
    Luminary.shattering = false
    startHeal()
  end},

  {pattern = "You deal %w+'s (.+) a mighty blow.", handler = function(p) Luminary:shatterSuccess(p) end},

  {pattern = {"^With careful aim you smash your mace into %w+'s (.+).$",
              "^You swiftly follow up by slamming a .+ into %w+ (.+).$"}, handler = function(p) Luminary:handleCrushing(p) end},
  {pattern = "^You connect to the (.*)!$", handler = function(p) Luminary:handleCrushed(p) end},
}
----------------------
-- Helper Functions --
----------------------
function Luminary:getCurrentShieldType()
  if (leftHand and leftHand:find("buckler")) or
     (rightHand and rightHand:find("buckler")) then
    return "buckler"
  end

  if (leftHand and leftHand:find("tower")) or
     (rightHand and rightHand:find("tower")) then
    return "tower"
  end

  ACSEcho("No shield found!")
end

-----------------------------
-- Attack Trigger Handlers --
-----------------------------
function Luminary:smashSmiteHandler(p)
  local limb = mb.line:match(p)
  local attack

  if Luminary.lastAttack == "smite" then
    attack = limbAttacks.smite
  elseif Luminary.lastAttack == "smash" then
    attack = limbAttacks.smash
  else
    ACSEcho("How the hell did you get this trigger with the wrong attack?")
  end

  addEnemyLimbDamage(limb, attack)
end

function Luminary:shatterSuccess(p)
  local limb = mb.line:match(p)

  wounds.enemy[limb].damage = 33.33
  Luminary.shattering = false
  startHeal()
end

function Luminary:handleCrushing(p)
  local limb = mb.line:match(p)
  Luminary.crushing = limb
end

function Luminary:handleCrushed(p)
  local limb = mb.line:match(p)
  local attack

  if limb == Luminary.crushing then
    if Luminary:getCurrentShieldType() == "tower" then
      attack = limbAttacks.crushTower
    elseif Luminary:getCurrentShieldType() == "buckler" then
      attack = limbAttacks.crushBuckler
    else
      ACSEcho("Incorrect shield used... ")
      return
    end

    addEnemyLimbDamage(limb, attack)
  end
end

function chastenHandler(p)
  local aff = mb.line:match(p)
  etrack:addAff(aff)
end


----------------------
-- Attack Functions --
----------------------
function Luminary:smite(limb)
  Luminary.lastAttack = "smite"
  if limb then
    send("target " .. limb)
  end
  send("smite " .. target)
end

function Luminary:smash(limb)
  Luminary.lastAttack = "smash"
  send("smash " .. limb .. " " .. target)
end

function Luminary:shatter(limb)
  Luminary.lastAttack = "shatter"
  send("shatter " .. limb .. " " .. target)
end

function Luminary:crush(limb1, limb2, shield)
  shield = shield or "tower"
  Luminary.lastAttack = "crush"
  doWield("mace", shield)
  send("shield crush " .. target .. " ".. limb1 .. " " .. limb2)
end

function Luminary:strike()
  doWield("mace", "buckler")
  send("shield strike " .. target)
end

-- Smite: 6.36 damage, 2.66 seconds

-- With careful aim you smash your mace into Daingean's left leg.
-- You connect to the left leg!
-- You swiftly follow up by slamming a tower shield into his right leg.
-- You connect to the right leg!
-- Crush (Tower): 14.99 damage, 3.22 seconds




function seekHandler(i,p)
  local person = i:match(p)
  send("angel seek " .. person)
end

function doBliss(i,p)
  local tar = i:match(p)
  send("perform bliss " .. tar)
end

function iLightning()
  send("evoke lightning " .. target)
end

function beckonHandler(i,p)
  local person = i:match(p)
  send("angel beckon" .. person)
end

function auraHandler(i,p)
  local person = i:match(p)
  send("angel aura " .. person)
end