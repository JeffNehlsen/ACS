echo("Luminary file loaded. Fire it up!")


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
  bashAttack = function(target)
    send("smite " .. target)
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
  {pattern = "^inspire$", handler = function(i,p) send("perform inspiration") end},
  {pattern = "^bliss (%w+)$", handler = function(i,p) doBliss(i,p) end},
  {pattern = "^pfocus$", handler = function(i,p) send("perform focus") end},
  {pattern = "^lform$", handler = function(i,p) send("evoke lightform") end},
  {pattern = "^inf$", handler = function(i,p) send("evoke infusion") end},
  {pattern = "^touch$", handler = function(i,p) send("angel touch") end},

  {pattern = "^seek (%w+)$", handler = function(i,p) seekHandler(i,p) end},
}

aliases.attackAliases = {
  --{pattern = "^$", handler = function(i,p)  end},
  {pattern = "^ar$", handler = function(i,p) sSmite() end},
  {pattern = "^lig$", handler = function(i,p) iLightning() end},
  {pattern = "^beck(.*)", handler = function(i,p) beckonHandler(i,p) end},
  {pattern = "^aura (%w+)", handler = function(i,p) auraHandler(i,p) end},
}


triggers.attackTriggers = {
  --{pattern = "^$", handler = function(p)  end},

  {pattern = "^You strengthen your ties to the light and close your eyes briefly in concentration, only to realize", handler = function(p) stopHeal() end},
  {pattern = "^You will yourself to become corporeal once more.$", handler = function(p) startHeal() end},
}

function seekHandler(i,p)
  local person = i:match(p)
  send("angel seek " .. person)
end

function doBliss(i,p)
  local tar = i:match(p)
  send("perform bliss " .. tar)
end

function smite()
  send("smite " .. target)
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