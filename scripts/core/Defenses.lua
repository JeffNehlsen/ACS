echo("Defense system loaded.")

checkingDef = true
checkedDef = false
lycanthrope = false
rebounded = false
guard = ""
defList = {}
autoRedefPause = false

aliases.defenses = {
  {pattern = "^defup$", handler = function(i,p) defenses:defup() end},
}

triggers.defenseTriggers = {
  {pattern = "^You have gained the ([a-zA-Z_]+) defence%.$", handler = function(p) defAddHandler(p) end},
  {pattern = "^Your ([a-zA-Z_]+) defence has been stripped%.$", handler = function(p) defStripHandler(p) end},

  {pattern = "^You have the following active defences:$", handler = function(p) defReset() end},
  {pattern = "You feel incredibly tired suddenly, and fall asleep immediately.", handler = function(p) send("wake") end},


}

function defAddHandler(p)
  local def = mb.line:match(p)
  if def == "rebounding" or def == "deafness" or def == "blindness" then return end
  defenses:give(def)
end

function defStripHandler(p)
  local def = mb.line:match(p)
  defenses:take(def)
end

function defReset()
-- Resets defenses when the DEF screen is shown
  defenses:reset()
  massed = false
  rebounded = false
end

function doDef()
  send("def")
  defReset()
end

function hasDefense(def)
  return defenses[def] and defenses[def].active
end

-- Guarding system. It will differ based on if you're Atabahi or not.
-- It will also have a switch to turn it on and off. Add that ASAP.
attemptingguard = false
function doParry()
  if guard ~= toguard and canParry and not attemptingguard and balances:check({"balance", "equilibrium"}) and not stunned and
    not unconscious and not asleep and not hasAffliction("paralysis") and not entangled then
    attemptingguard = true
    add_timer( 1, function() attemptingguard = false end)
    if isClass("atabahi") then
      if lycanthrope then send("pawguard " .. toguard) end
    elseif isClass("daru") or isClass("monk") then
      send("guard " .. toguard)
    else
      send("parry " .. toguard)
    end
  end
end

function setParry(parry)
  toguard = parry
  echo(C.B .. "[" .. C.R .. "Setting parry to " .. C.G .. parry .. C.B .. "]" .. C.x)
  show_prompt()
end

-- Defenses table.
-- Syntax can be drawn from examples below.
-- Required elements:
--   requires: table of balances it takes.
--   takes: table of taken balances.
--   initDef: Should this defense be put up with DEFUP?
--   redef: Should this defense automatically be put up if it is lost?
--   give: Function to put up the defense
--   take: (OPTIONAL) Function for taking the defense down.
--   able: Boolean for if the defense is able to be put up
--   triggers: Has two subtables, up and down.  Triggers for giving and taking the defense.
defenses = {
  --------------
  --  GENERAL --
  --------------
  miasma = {
    requires = baleq,
    takes = {},
    initDef = true,
    redef = true,
    give = function() send("miasma") end,
    able = hasSkill("miasma"),
    triggers = {
      up = {
        "^You have the miasma of an Azudim.$"
      },
      down = {},
    },
  },

    safeguard = {
    requires = baleq,
    takes = {},
    initDef = true,
    redef = true,
    give = function() send("safeguard") end,
    able = hasSkill("safeguard"),
    triggers = {
      up = {
        "^You have the safeguard of an Idreth.$"
      },
      down = {},
    },
  },

  temperance = {
    requires = {},
    takes = {},
    initDef = true,
    redef = true,
    give = function()  
      if living then
        send("sip frost")
      else
        send("stick refrigerative")
      end
    end,
    able = true,
    triggers = {
      up = {
        "^A chill runs over your icy skin.$",
        "^You are tempered against fire damage.$",
      },
      down = {},
    },
  },

  fangbarrier = {
    requires = {},
    takes = {},
    initDef = true,
    redef = true,
    give = function()  
      if living then
        send("outc sileris")
        send("apply sileris")
      else
        send("outc bone slice")
        send("squeeze bone slice")
      end
    end,
    able = function() return not hasAffliction("slickness") end,
    triggers = {
      up = {
        "^The bone marrow solidifies into a thick, hardened shell.$",
        "^The sileris berry juice hardens into a supple purple shell.$",
        "^You are protected from the fangs of serpents.$",
        "^You quickly squeeze the marrow from the bone, applying it to your skin.$"
      },
      down = {},
    },
  },

  instawake = {
    requires = {},
    takes = {},
    initDef = true,
    redef = true,
    give = function() 
      if living then
        send("outc kola")
        send("eat kola")
      else
        send("outc sulphurite slice")
        send("eat sulphurite slice")
      end
    end,
    able = true,
    triggers = {
      up = {
        "^You are feeling extremely energetic.$",
      },
      down = {},
    },
  },

  venom = {
    requires = {"healingSerum"},
    takes = {"healingSerum"},
    initDef = true,
    redef = true,
    give = function() 
      if living then
        send("sip venom")
      else
        send("stick carminative")
      end
    end,
    able = true,
    triggers = {
      up = {
        "^Your resistance to damage by poison has been increased.$",
        "^You feel a momentary dizziness as your resistance to damage by poison increases.$",
        "^You are already benefitting from increased venom resistance.$",
      },
      down = {},
    },
  },

  speed = {
    requires = {},
    takes = {},
    initDef = true,
    redef = true,
    give = function() 
      if living then
        send("sip speed")
      else
        send("stick nervine")
      end
    end,
    able = true,
    triggers = {
      up = {
        "^Your sense of time is heightened, and your reactions are speeded.$",
        "^Your sense of time is already heightened.$",
        "^Tiny tremours spread through your body as the world seems to slow down.$",
        "^You stick yourself with a nervine serum.$",
      },
      down = {
        "^You feel %w+'s eyes upon you, and feel your sense of time slow to normal.$",
      },
    },
  },

  insulation = {
    requires = {"poultice"},
    takes = {"poultice"},
    initDef = true,
    redef = true,
    give = function()  
      if living then
        send("apply caloric")
      else
        send("press fumeae")
      end
    end,
    able = true,
    triggers = {
      up = {
        "^You are coated in an insulating caloric salve.$",
        "^You are insulated against the harsh cold.$",
        "^A feeling of comfortable warmth spreads over you.$",
      },
      down = {},
    },
  },

  vigor = {
    requires = {},
    takes = {},
    initDef = false,
    redef = false,
    give = function() 
      if living then
        send("sip vigor")
      else
        send("stick apocroustic")
      end
    end,
    able = true,
    triggers = {
      up = {
        "^You have been invigorated with strength.$",
      },
      down = {},
    },
  },

  mindseye = {
    requires = allsightEnchantment ~= "" and {} or baleq,
    takes = allsightEnchantment ~= "" and {} or {"equilibrium"},
    initDef = true,
    redef = allsightEnchantment ~= "",
    give = function() 
      if allsightEnchantment ~= "" then
        send("touch " .. allsightEnchantment)
      else
        send("touch mindseye")
      end
    end,
    able = true,
    triggers = {
      up = {
        "^Touching .* your senses are suddenly heightened.$",
        "^Touching the mindseye tattoo, your senses are suddenly heightened.$",
        "^You are already using the mindseye defense.$",
        "^Your senses are magically heightened.$",
      },
      down = {},
    },
  },

  cloak = {
    requires = baleq,
    takes = {"equilibrium"},
    initDef = true,
    redef = false,
    give = function() send("touch cloak") end,
    able = true,
    triggers = {
      up = {"^You are surrounded by a cloak of protection.$"},
      down = {},
    },
  },

  insomnia = {
    requires = {},
    takes = {},
    initDef = true,
    redef = true,
    give = function()  
      if skills.survival >= skillranks.fabled then
        send("insomnia")
      else
        if living then
          send("outc cohosh")
          send("eat cohosh")
        else
          send("outc tongue slice")
          send("eat tongue slice")
        end
      end
    end,
    take = function() send("relax insomnia") end,
    able = true,
    triggers = {
      up = {
        "^You are already an insomniac.$",
        "^You suddenly feel incapable of falling asleep.$",
        "^You have insomnia, and cannot easily go to sleep.$",
      },
      down = {
        "^Your mind relaxes and you feel as if you could sleep.$",
        "^Your insomnia seems to have gone.$",
        "^You feel incredibly tired suddenly, and fall asleep immediately.$",
      },
    },
  },

  nightsight = {
    requires = {},
    takes = {},
    initDef = true,
    redef = true,
    give = function() send("nightsight") end,
    able = skills.vision >= skillranks.virtuoso or isClass("atabahi") or hasSkill("nightsight") or isVampire(),
    triggers = {
      up = {"^Your vision is heightened to see in the dark.$"},
      down = {},
    },
  },

  deathsight = {
    requires = baleq,
    takes = {"equilibrium"},
    initDef = true,
    redef = false,
    give = function()  
      if skills.vision >= skillranks.skilled or isNecro() or isVampire() or isClass("carnifex") then
        send("deathsight")
      else
        if living then
          send("outc skullcap")
          send("eat skullcap")
        else
          send("outc pineal slice")
          send("eat pineal slice")
        end
      end
    end,
    take = function() send("deathsight off") end,
    able = true,
    triggers = {
      up = {
        "^You shut your eyes and concentrate on the wise Underking. A moment later, you feel inextricably linked with the underworld and its passengers.$",
        "^Your mind has been touched by the essence of the Underking.$",
        "^A miasma of darkness passes over your eyes and you feel a link to the Underking form in your mind.$",
        "^You already possess the deathsight.$",
        "^Your mind is already touched by the Underking.$"
      },
      down = {
        "^You shut your eyes and concentrate on breaking the link with the Underking. A moment later, the link has dissolved.$",
      },
    },
  },

  thirdeye = {
    requires = {},
    takes = {},
    initDef = true,
    redef = true,
    give = function()  
      if skills.vision >= skillranks.fabled then
        send("thirdeye")
      elseif living then
        send("outc echinacea")
        send("eat echinacea")
      else
        send("outc spleen slice")
        send("eat spleen slice")
      end
    end,
    able = true,
    triggers = {
      up = {
        "^You already possess the third eye.$",
        "^You now possess the gift of the third eye.$",
        "^You already possess the gift of the third eye.$",
        "^You possess the sight of the third eye.$",
      },
      down = {},
    },
  },    

  levitation = {
    requires = {"healingSerum"},
    takes = {"healingSerum"},
    initDef = true,
    redef = true,
    give = function()  
      if hasSkill("hover") then
        send("hover")
      elseif living then
        send("sip levitation")
      else
        send("stick euphoric")
      end
    end,
    able = true,
    triggers = {
      up = {
        "^Your body begins to feel lighter and you feel that you are floating slightly.$",
        "^You walk on a small cushion of air.$",
        "^You are already levitating.$",
      },
      down = {
        "^You cease your levitation as the pit attempts to pull you towards it.$",
      },
    },
  },

  lifevision = {
    requires = baleq,
    takes = {"equilibrium"},
    initDef = true,
    redef = false,
    give = function() send("lifevision") end,
    able = isNecro() or isVampire(),
    triggers = {
      up = {
        "^You narrow your eyes and blink rapidly, enhancing your vision to seek out", -- TODO: Get full Lifevision message.
        "^You have enhanced your vision to be able to see traces of lifeforce.$",
      },
      down = {},
    },
  },

   heatsight = {
    requires = baleq,
    takes = {"equilibrium"},
    initDef = true,
    redef = false,
    give = function() send("heatsight") end,
    able = isClass("atabahi") or hasSkill("heatsight"),
    triggers = {
      up = {
        "^As you close your eyes, the lids are backlit with a faint red glow. Opening them once more, heated", -- TODO: Get full Heatsight message.
        "^You are already searching for the heat of other people.$",
        "^You are sensing the heat of others.$",
      },
      down = {},
    },
  },

  fitness = {
    requires = baleq,
    takes = {"balance"},
    initDef = true,
    redef = false,
    give = function() send("fitness") end,
    take = function()  end,
    able = isVampire() or isClass("carnifex"),
    triggers = {
      up = {
        "You breathe inward, hissing and steeling your body.",
        "You are utilising your bodily control to make yourself more fit.",
      },
      down = {
        -- TODO: Get the fitness removal trigger
      },
    },
  },

  dodging = {
    requires = {},
    takes = {},
    initDef = true,
    redef = true,
    give = function() 
      if skills.avoidance >= skillranks.skilled then 
        send("dodge melee") 
      else
        send("divert melee")
      end
    end,
    able = true,
    triggers = {
      up = {
        "^You are already (%w+) melee attacks.$",
        "^You begin to focus your efforts on (%w+) melee attacks.$",
        "^You are (%w+) melee attacks.$",
        "^You begin to focus your efforts on (%w+) damage from melee attacks.$",
      },
      down = {},
    },
  },

  blindness = {
    requires = {"organ"},
    takes = {"organ"},
    initDef = function() return needblind end,
    redef = function() return needblind end,
    give = function()  
      if living then
        send("outc bayberry")
        send("eat bayberry")
      else
        send("outc stomach slice")
        send("eat stomach slice")
      end
    end,
    take = function()  
      if living then
        send("apply epidermal")
      else
        send("press oculi")
      end
    end,
    able = true,
    triggers = {
      up = {
        "^Your eyes dim as you lose your sight.$",
        "^You are blind.$",
      },
      down = {
        "^You are no longer blind.$",
      },
    },
  },

  deafness = {
    requires = {"organ"},
    takes = {"organ"},
    initDef = function() return needdeaf end,
    redef = function() return needdeaf end,
    give = function()  
      if living then
        send("outc hawthorn")
        send("eat hawthorn")
      else
        send("outc heart slice")
        send("eat heart slice")
      end
    end,
    take = function()  
      if living then
        send("apply epidermal")
      else
        send("press oculi")
      end
    end,
    able = true,
    triggers = {
      up = {
        "^It has no effect. You are already deaf.$",
        "^You are deaf.$",
        "^The world around fades to silence as you lose your hearing.$",
      },
      down = {

      },
    },
  },

  mass = {
    requires = {"poultice"},
    takes = {"poultice"},
    initDef = function() return needmass end,
    redef = function() return needmass end,
    give = function()  
      if living then
        send("apply mass")
      else
        send("press pueri")
      end
    end,
    able = true,
    triggers = {
      up = {
        "^You press a pueri poultice against your skin, rubbing it into your flesh.$",
        "^You press the pueri poultice to your skin and suddenly feel far more dense and heavy than usual.$",
        "^You are extremely heavy and difficult to move.$",
      },
      down = {
        "^You feel your density return to normal.$",
      },
    },
  },

  rebounding = {
    requires = {"tincture"},
    takes = {"tincture"},
    initDef = function() return needrebounding end,
    redef = function() return needrebounding end,
    give = function()  
      if living then
        send("smoke skullcap")
      else
        send("inject sudorific")
      end
    end,
    take = function()  end,
    able = true,
    triggers = {
      up = {
        "^You quickly inject yourself with a syringe filled with sudorific.$",
        "^You feel an aura of rebounding surround you.$",
        "^You are protected from hand%-held weapons with an aura of rebounding.$",
        "^You take a long drag off your pipe filled with skullcap.$",
        "^You are already benefitting from an aura of weapons rebounding.$",
      },
      down = {
        "Your aura of weapons rebounding disappears.",
      },
    },
  },

  shielded = {
    requires = baleq,
    takes = {"equilibrium"},
    initDef = false,
    redef = false,
    give = function() send("wisp shield") end,
    able = isVampire(),
    triggers = {
      up = {
        "^Your wisp glows dark red momentarily before creating a hardened shield around you, protecting you",
        "^You are surrounded by a nearly invisible magical shield.$",
      },
      down = {
        "^Your aggressive action causes the nearly invisible magical shield around you to fade away.$",
      },
    },
  },

  -- template = {
  --   requires = {},
  --   takes = {},
  --   initDef = true,
  --   redef = true,
  --   give = function()  end,
  --   take = function()  end,
  --   able = true,
  --   triggers = {
  --     up = {

  --     },
  --     down = {

  --     },
  --   },
  -- },

  ---------------
  --  Atabahi  --
  ---------------
  weathering = {
    requires = {},
    takes = {},
    initDef = true,
    redef = false,
    give = function() send("weathering") end,
    able = isClass("atabahi"),
    triggers = {
      up = {
        "^A brief shiver runs through your body.$",
        "^You are immune to normal weather.$",
      },
      down = {
      },
    },
  },

  thickfur = {
    requires = baleq,
    takes = {"equilibrium"},
    initDef = true,
    redef = false,
    give = function() send("thicken fur") end,
    able = isClass("atabahi"),
    triggers = {
      up = {
        "^You close your eyes in concentration, willing your fur to thicken.$",
        "^You feel your fur grow dramatically thicker, and you end your concentration.$",
        "^Your coat of fur has been thickened.$",
        "^Your fur is already as thick as you can make it.$",
      },
      down = {
      },
    },
  },

  thickhide = {
    requires = baleq,
    takes = {"balance"},
    initDef = true,
    redef = false,
    give = function() send("thickhide") end,
    able = isClass("atabahi"),
    triggers = {
      up = {
        "^Your hide grows thicker in an attempt to protect yourself.$",
        "^You can not grow a thicker hide.$",
        "^Your hide is thickened.$",
      },
      down = {
      },
    },
  },

  cornering = {
    requires = baleq,
    takes = {"balance"},
    initDef = true,
    redef = false,
    give = function() send("corner on") end,
    take = function() send("corner off") end,
    able = isClass("atabahi"),
    triggers = {
      up = {
        "^You will now begin to corner your enemies.$",
        "^You will corner your enemies.$",
      },
      down = {
        "^You cease to corner your enemies.$",
      },
    },
  },

  hardening = {
    requires = baleq,
    takes = {"equilibrium"},
    initDef = true,
    redef = false,
    give = function() send("harden bones") end,
    able = isClass("atabahi"),
    triggers = {
      up = {
        "^You will your bones to harden to protect yourself from damage.$",
        "^Your bones are as hard as you can make them.$",
        "^Your bones have been hardened greatly.$",
      },
      down = {
      },
    },
  },

  stealth = {
    requires = baleq,
    takes = {"balance"},
    initDef = true,
    redef = false,
    give = function() send("stealth on") end,
    take = function() send("stealth off") end,
    able = isClass("atabahi"),
    triggers = {
      up = {
        "^You will now move in total silence.$",
        "^You are already concealing your movement in a stealthy manner.$",
        "^Your movements are incredibly stealthy.$",
      },
      down = {
        "^You cease concentrating on stealth.$",
      },
    },
  },

  metabolize = {
    requires = baleq,
    takes = {"balance"},
    initDef = true,
    redef = false,
    give = function() send("metabolize on") end,
    take = function() send("metabolize off") end,
    able = isClass("atabahi"),
    triggers = {
      up = {
        "^Your limbs grow strong as you force your food to metabolize faster.$",
        "^You cannot metabolize food any faster than you are now.$",
        "^You are metabolizing your food more quickly.$",
      },
      down = {
        "^You relax your metabolic processes, returning to a state of normalcy.$",
      },
    },
  },

  echoing = {
    requires = baleq,
    takes = {"equilibrium"},
    initDef = false,
    redef = false,
    give = function() send("echoing on") end,
    take = function() send("echoing off") end,
    able = isClass("atabahi"),
    triggers = {
      up = {
        "^You change your vocals slightly, curving the sound in an effort to echo your howls.$",
        "^You are already causing your howls to echo.$",
        "^You have the echoing defence.$",
      },
      down = {
        "^You cease to echo your howls.$",
      },
    },
  },

  snarling = {
    requires = baleq,
    takes = {"equilibrium"},
    initDef = false,
    redef = false,
    give = function() send("snarling on") end,
    take = function() send("snarling off") end,
    able = isClass("atabahi"),
    triggers = {
      up = {
        "^You begin a low snarl, concealing the true sound of your howls.$",
        "^You are already snarling.$",
        "^You are snarling to hide your howls.$",
      },
      down = {
        "^Your snarls stop, revealing the full sound of your howls.$",
      },
    },
  },


  ---------------
  --  Vampire  --
  ---------------
  elusion = {
    requires = baleq,
    takes = {"balance"},
    initDef = false,
    redef = false,
    give = function() send("elusion on") end,
    take = function() send("elusion off") end,
    able = isVampire(),
    triggers = {
      up = {
        "^You will elude physical blows directed at you.$",
        "^You are already eluding physical blows.$",
        "^You are eluding your opponents' blows.$",
      },
      down = {
        "^You cease eluding.$",
      },
    },
  },

  masquerade = {
    requires = baleq,
    takes = {"equilibrium"},
    initDef = false,
    redef = false,
    give = function() send("masquerade on") end,
    take = function() send("masquerade off") end,
    able = isVampire(),
    triggers = {
      up = {
        "^You focus your blood reserves, directing a small amount into the hollow, lifeless capillaries of",
        "^You already emulate the outward signs of mortality.$",
        "^You have made your body appear mortal.$",
      },
      down = {
        "^You cease masquerading.$",
      },
    },
  },

  arrow_catching = {
    requires = baleq,
    takes = {"balance"},
    initDef = false,
    redef = false,
    give = function() send("catching on") end,
    take = function() send("catching off") end,
    able = isVampire(),
    triggers = {
      up = {
        "^You will attempt to catch projectiles directed at you.$",
        "^You are already attempting to catch projectiles.$",
        "^You are focusing on catching arrows.$",
      },
      down = {
        "^You cease attempting to catch projectiles.$",
      },
    },
  },

  fortify = {
    requires = baleq,
    takes = {"balance"},
    initDef = true,
    redef = false,
    give = function() send("fortify") end,
    able = isVampire(),
    triggers = {
      up = {
        "^Focusing on the pale, lifeless skin enveloping your corpse, you feel it become tough, resiliant, and",
        "^Your skin is already hardened against trauma.$",
        "^Your flesh is fortified against damage.$",
      },
      down = {
      },
    },
  },

  lifescent = {
    requires = baleq,
    takes = {"equilibrium"},
    initDef = false,
    redef = false,
    give = function() send("lifescent") end,
    able = isVampire(),
    triggers = {
      up = {
        "^You attune your olfactory senses to the delicate traces of nearby mortal life.$",
        "^Your senses are attuned to traces of blood already.$",
        "^You detect the movements of nearby mortals.$",
      },
      down = {
        "^Your concentration on the scents of nearby life fades.$",
      },
    },
  },

  ward = {
    requires = baleq,
    takes = {"equilibrium"},
    initDef = true,
    redef = false,
    give = function() send("ward") end,
    able = isVampire(),
    triggers = {
      up = {
        "^You concentrate intensely, erecting an internal shield of warding against magical energies that",
        "^Your corpse is already steeled against magical attack.$",
        "^Your body is steeled against magical energies.$",
      },
      down = {
      },
    },
  },

  potence = {
    requires = baleq,
    takes = {"balance"},
    initDef = true,
    redef = false,
    give = function() send("potence") end,
    able = isVampire(),
    triggers = {
      up = {
        "^Summoning forth the surging energy of blood, you imbue your muscles with extraordinary strength.$",
        "^Your strength is already supernaturally buffered.$",
        "^You are unnaturally strong.$",
      },
      down = {
      },
    },
  },

  deathlink = {
    requires = baleq,
    takes = {"equilibrium"},
    initDef = false,
    redef = false,
    give = function() send("deathlink") end,
    able = isVampire(),
    triggers = {
      up = {
        "^You allow your blood to seep into the earth beneath your feet, strengthening the ties you feel to",
        "^There is no need for you to link with your coffin again.$",
        "^Your blood is strengthening the ties to your coffin.$",
      },
      down = {
      },
    },
  },

  scythestance = {
    requires = baleq,
    takes = {"balance"},
    initDef = true,
    redef = false,
    give = function() send("scythe stance") end,
    able = isClass("bloodborn"),
    triggers = {
      up = {
        "^You hold your scythe in front of you, taking on a defensive position.$",
        "^You are already in your defensive stance.$",
        "^You are in a defensive stance.$",
      },
      down = {
      },
    },
  },

  bloodwisp = {
    requires = baleq,
    takes = {"equilibrium"},
    initDef = true,
    redef = false,
    give = function() send("wisp form") end,
    take = function() send("wisp disperse") end,
    able = isClass("bloodborn"),
    triggers = {
      up = {
        "^With deliberate gestures, you cup the air around you and push it gently across your cold heart,",
        "^Your wisp is already floating about you.$",
        "^Your blood wisp floats about your head.$",
      },
      down = {
        "^Your wisp fades from dark red into nothingness.$",
      },
    },
  },

  wisp_stigmata = {
    requires = baleq,
    takes = {"equilibrium"},
    initDef = false,
    redef = false,
    give = function() send("wisp stigmata on") end,
    take = function() send("wisp stigmata off") end,
    able = isClass("bloodborn"),
    triggers = {
      up = {
        "^You nod to your wisp to begin to entice the blood from the pores of your enemies.$",
        "^Your wisp is enticing the blood from your enemies.$",
      },
      down = {
        "^You nod to your wisp to stop enticing the blood out of your enemies.$",
      },
    },
  },

  bloodshield = {
    requires = baleq,
    takes = {"equilibrium"},
    initDef = false,
    redef = false,
    give = function() send("wisp bloodshield on") end,
    take = function() send("wisp bloodshield off") end,
    able = isClass("bloodborn"),
    triggers = {
      up = {
        "^You chant a guttural sound, and the wisp begins to spin wildly about your body.$",
        "^Your wisp is spinning wildly around you.$",
      },
      down = {
        "^You chant a guttural sound, and the wisp ceases to spin about your body.$",
      },
    },
  },

  wisp_anxiety = {
    requires = baleq,
    takes = {"equilibrium"},
    initDef = false,
    redef = false,
    give = function() send("wisp anxiety on") end,
    take = function() send("wisp anxiety off") end,
    able = isClass("bloodborn"),
    triggers = {
      up = {
        "^You nod to your wisp to start filling the head of your enemies with anxieties.$",
        "^Your wisp is causing anxiety to your enemies.$",
      },
      down = {
        "^You nod to your wisp to stop filling the head of your enemies with anxieties.$",
      },
    },
  },

  ---------------
  --  Rituals  --
  ---------------
  sanguispect = {
    requires = baleq,
    takes = {},
    initDef = false,
    redef = false,
    give = function() send() end,
    able = isClass("bloodborn"),
    triggers = {
      up = {
        "^Smoke from your pipe surrounds your tablet, absorbing the blood from within the incised runes. The",
        "^Your body is shielded by blood.$",
      },
      down = { --Get the 'Down' msg
        "^The rune on your skin flares with light and disappears, dispersing the blood within your chest to",
      },
    },
  },

  shadowblow = {
    requires = baleq,
    takes = {},
    initDef = false,
    redef = false,
    give = function() send() end,
    able = isClass("bloodborn"),
    triggers = {
      up = {
        "^Chilling shadows begin gathering around the runes inscribed on the tablet. You place your palm upon",
        "^Shadows are gathered around your arm, waiting to defend you.$",
      },
      down = { --Get the 'Down' msg
      },
    },
  },

  stillmind = {
    requires = baleq,
    takes = {},
    initDef = false,
    redef = false,
    give = function() send() end,
    able = isClass("bloodborn"),
    triggers = {
      up = {
        "^You scream out as your mind feels as though it were gripped within a clamp, but as the pain fades",
        "^You are benefiting from a stillmind.$",
      },
      down = {
      },
    },
  },


  ----------------
  --  TERADRIM  --
  ----------------
  earthenform = {
    requires = baleq,
    takes = {"balance"},
    initDef = true,
    redef = false,
    give = function() send("earthenform embrace") end,
    take = function() send("earthenform release") end, -- TODO: GET EARTHENFORM TAKE COMMAND
    able = isClass("teradrim") and skills.earth == skillranks.transcendant,
    triggers = {
      up = {
        "^You have embraced your earthen form.$",
        "^You have already undergone the transformation into an earthen.$",
      },
      down = {
        "^Within moments the last of the earth has seperated from your body, leaving you", -- TODO: GET EARTHENFORM COMPLETE MESSAGES
      },
    },
  },

  concealment = {
    requires = baleq,
    takes = {"balance"},
    initDef = false,
    redef = false,
    give = function() doWield(crozier, tower) send("sand concealment") end,
    able = isClass("teradrim"),
    triggers = {
      up = {
        "^You draw upon the powers of the earth and conceal your presence from detection.$",
        "^You are veiled.$",
        "^You are already concealed by the earth's power.$",
      },
      down = {},
    },
  },

  truesight = {
    requires = baleq,
    takes = {"equilibrium"},
    initDef = true,
    redef = false,
    give = function() doWield(crozier, tower) send("truesight") end,
    able = isClass("teradrim"),
    triggers = {
      up = {
        "^You focus and your vision expands, allowing you to see as one of the Earthen.$",
        "^You are utilising the sight of the Earthen.$",
      },
      down = {},
    },
  },

  stonefeet = {
    requires = baleq,
    takes = {"balance"},
    initDef = false,
    redef = false,
    give = function() send("stonefeet") end,
    able = isClass("teradrim"),
    triggers = {
      up = {
        "^You call to the earth and your feet grow heavy as stone.$",
        "^Your feet are of dense granite.$",
      },
      down = {
        "^Your stone feet revert to normal.$",
      },
    },
  },

  sandarmour = {
    requires = baleq,
    takes = {"balance"},
    initDef = true,
    redef = false,
    give = function() doWield(crozier, tower) send("sand armour") end,
    take = function()  end, --Todo: Get Sandarmour TAKE COMMAND OR FIND OUT IF THERE ISN'T ONE
    able = isClass("teradrim"),
    triggers = {
      up = {
        "^You will your sands to coat your body before hardening them into a thick armour.$",
        "^You are protected by a hardened shell of sand.$",
        "^You are already protected by sand armour."
      },
      down = {},
    },
  },

  earthsense = {
    requires = baleq,
    takes = {"equilibrium"},
    initDef = true,
    redef = false,
    give = function() send("earthsense") end,
    able = isClass("teradrim"),
    triggers = {
      up = {"^You are listening for underground movement.$"},
      down = {},
    },
  },


  --------------
  --  SYSSIN  --
  --------------
  warding = {
    requires = baleq,
    takes = {"balance"},
    initDef = true,
    redef = false,
    give = function() send("warding") end,
    able = isClass("syssin"),
    triggers = {
      up = {
        "^You utter a prayer to your fallen brethren that they might soften blows that fall upon you%.$",
        "^You have already brought the ward of the Syssin upon yourself%.$",
        "^The ward of the Syssin protects your body%.$",
      },
      down = {},
    },
  },

  cloaking = {
    requires = {},
    takes = {},
    initDef = true,
    redef = true,
    give = function() send("conjure cloak") end,
    able = isClass("syssin"),
    triggers = {
      up = {
        "^You toss a sparkling cloud of dust over yourself and as it settles you shimmer into invisibility.$",
        "^Your actions are cloaked in secrecy.$",
      },
      down = {
        "^Your shroud dissipates and you return to the realm of perception.$",
      },
    },
  },

  ghost = {
    requires = {},
    takes = {},
    initDef = true,
    redef = true,
    give = function() send("conjure ghost") end,
    able = isClass("syssin"),
    triggers = {
      up = {
        "^You project a net of light about yourself until your image becomes faded and ghostly.$",
        "^You are shimmering with a ghostly light.$",
        "^You are already ghosting.$",
      },
      down = {
        "^Your ghostly image slowly intensifies until you appear flesh and blood again.$",
      },
    },
  },

  lipreading = {
    requires = baleq,
    takes = {"equilibrium"},
    initDef = true,
    redef = false,
    give = function() send("lipread") end,
    able = isClass("syssin"),
    triggers = {
      up = {
        "^You will now lip read to overcome the effects of deafness%.$",
        "^You are lipreading to overcome deafness%.$",
        "^You are already lipreading%.$"
      },
      down = {},
    },
  },

  pacing = {
    requires = baleq,
    takes = {"balance"},
    initDef = true,
    redef = false,
    give = function() send("pacing on") end,
    take = function() send("pacing off") end,
    able = isClass("syssin") or hasSkill("pacing") or isClass("atabahi"),
    triggers = {
      up = {
        "^You begin to pace yourself and prepare for sudden bursts of exertion.$",
        "^You are paced for bursts of exertion.$",
        "^You are already pacing.$",
      },
      down = {
        "^You are no longer pacing yourself.$",
      },
    },
  },

  shadowsight = {
    requires = baleq,
    takes = {"equilibrium"},
    initDef = true,
    redef = false,
    give = function() send("shadowsight") end,
    able = isClass("syssin"),
    triggers = {
      up = {
        "^You close your eyes for a moment, allowing your vision to focus on the shadows.$",
        "^You are watching the shadows.$",
      },
      down = {},
    },
  },

  hide = {
    requires = baleq,
    takes = {"balance"},
    initDef = false,
    redef = false,
    give = function() send("hide") end,
    take = function() send("emerge") end,
    able = isClass("syssin") or isClass("atabahi") or isVampire(), -- This needs to be extended
    triggers = {
      up = {
        "^You conceal yourself using all the guile you possess.$",
        "^You have used great guile to conceal yourself.$",
        "^You are already hidden.$",
        "^You beckon to the nearby shadows which eerily come alive, slithering toward you and up over your",
      },
      down = {
        "^You emerge from your hiding place.$",
      },
    },
  },
}

-- Adds the triggers for give/take.
function defenses:prepare()
  triggers.defenses = {}
  for name, defense in pairs(self) do
    if type(defense) == "table" then
      self[name].redeffing = false

      for _, trigger in ipairs(defense.triggers.up) do
        addTrigger("defenses", trigger, function() self:give(name) end)
      end

      for _, trigger in ipairs(defense.triggers.down) do
        addTrigger("defenses", trigger, function() self:take(name) end)
      end
    end
  end
end

function defenses:defup()
  for name, defense in pairs(self) do
    if type(defense) == "table" then
      local init
      if type(defense.initDef) == "function" then init = defense.initDef() else init = defense.initDef end
      if defense.able and init and not defense.active then
        debug("Setting up " .. name)
        actions:add(function() defense.give() end, defense.requires, defense.takes)
      end
    end
  end
  show_prompt()
end

function defenses:redef()
  if pauseRedef then return end
  for name, defense in pairs(self) do
    if type(defense) == "table" then
      local redef
      if type(defense.redef) == "function" then redef = defense.redef() else redef = defense.redef end
      if defense.able and redef and not defense.active and not defense.redeffing then
        self[name].redeffing = true
        actions:add(function()
          defense.give()
          add_timer(1, function() self[name].redeffing = false end)
        end, defense.requires, defense.takes)
      end
    end
  end
end

function defenses:give(name)
  debug("Giving defense: " .. name)
  if not self[name] then ACSEcho("Defense " .. name .. " not found.") return end
  extraLine = extraLine .. C.B .. " (" .. C.G .. name .. C.B .. ") " .. C.x
  self[name].active = true
end

function defenses:take(name)
  debug("Taking defense: " .. name)
  if not self[name] then ACSEcho("Defense " .. name .. " not found.") return end
  extraLine = extraLine .. C.B .. " (" .. C.R .. name .. C.B .. ") " .. C.x
  self[name].active = false
end

function defenses:reset()
  debug("Resetting defenses.")
  for name, _ in pairs(self) do
    if type(defenses[name]) == "table" then
      self[name].active = false
      self[name].redeffing = false
    end
  end
end

defenses:prepare()
doDef()