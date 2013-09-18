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

    -- Parry/guard
  {pattern = "^zzz$", handler = function(i,p) setParry("left leg") end},
  {pattern = "^ccc$", handler = function(i,p) setParry("right leg") end},
  {pattern = "^aaa$", handler = function(i,p) setParry("left arm") end},
  {pattern = "^ddd$", handler = function(i,p) setParry("right arm") end},
  {pattern = "^sss$", handler = function(i,p) setParry("torso") end},
  {pattern = "^www$", handler = function(i,p) setParry("head") end},

  {pattern = "^def$", handler = function(i,p) doDef() end},
}

triggers.defenseTriggers = {
  {pattern = "^You have gained the ([a-zA-Z_]+) defence%.$", handler = function(p) defAddHandler(p) end},
  {pattern = "^Your ([a-zA-Z_]+) defence has been stripped%.$", handler = function(p) defStripHandler(p) end},

  {pattern = "^You have the following active defences:$", handler = function(p) defReset() end},
  {pattern = "You feel incredibly tired suddenly, and fall asleep immediately.", handler = function(p) send("wake") end},


  --- Lycan Form
  {pattern = "A feral sneer passes your lips as you lapse from concentrating on your (%w+) self, and allow your", handler = function(p) Lycan() end},
  {pattern = "Centering your wild mind, civility floods your thoughts. Gasping in pain, your form contorts and", handler = function(p) noLycan() end},
}

function Lycan()
  lycanthrope = true
end

function noLycan()
  lycanthrope = false
end

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

function unLycaned()
  defenses:take("lycanthrope")
  defenses:take("thickhide")
  defenses:take("thickfur")
  defenses:take("enduranced")
  defenses:take("heatsight")
end


----------------
-- NEW SYSTEM --
----------------
-- Shortcut for a normal balance requirement.
baleq = {"balance", "equilibrium"}

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
        "^You have the miasma of an Azudim.$",
        "^You begin to exude a foul miasma, granting protection upon you and your allies.$",
      },
      down = {
        "^The aura about you fades, leaving you somewhat more vulnerable again.$",
        "^Your miasma defence has been stripped.$",
      },
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
        "^You have the safeguard of an Idreth.$",
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
      down = {
        "^Your temperance defence has been stripped.$",
      },
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
        "^You quickly squeeze the marrow from the bone, applying it to your skin.$",
        "^You apply a sileris berry to yourself.$",
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
        "^An instant feeling of excitement and edginess overcomes you.$",
      },
      down = {},
    },
  },

  venom_resistance = {
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
        "^You take a drink of an elixir of speed from",
      },
      down = {
        "^You feel %w+'s eyes upon you, and feel your sense of time slow to normal.$",
        "^Your speed defence has been stripped.$",
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
        "^You already have the insulation defense!$",
      },
      down = {
        "^Your insulation defence has been stripped.$",
      },
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
        "^You stick yourself with an apocroustic serum.$",
      },
      down = {
        "^You suddenly feel less invigorated.$",
      },
    },
  },

  starburst = {
    requires = baleq,
    takes = {},
    initDef = false,
    redef = false,
    give = function() send() end,
    take = function() send() end,
    able = true,
    triggers = {
      up = {
        "^Touching the Ulgar Atlas, you are momentarily surrounded by a shimmering nimbus of stars.$",
        "^You are already protected by the starburst defense.$",
        "^You walk with the grace of the stars.$",
      },
      down = {
      },
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
      up = {
        "^You are surrounded by a cloak of protection.$",
        "^You caress the tattoo and immediately you feel a cloak of protection surround you.$",
      },
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
        "^You clench your fists, grit your teeth, and banish all possibility of sleep.$",
        "^Your mind is whirling with thoughts - you cannot settle down to sleep.$",
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
    able = skills.vision >= skillranks.virtuoso or isClass("atabahi") or hasSkill("nightsight") or isVampire() or isClass("indorani") or isClass("luminary"),
    triggers = {
      up = {
        "^Your vision is heightened to see in the dark.$",
        "^Your vision sharpens with light as you gain night sight.$",
        },
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

  chameleon = {
    requires = baleq,
    takes = {},
    initDef = false,
    redef = false,
    give = function() send() end,
    able = hasSkill("chameleon"),
    triggers = {
      up = {
        "^You take on the likeness of",
        "^You have assumed the identity of",
      },
      down = {
        "^The effect of your chameleon fades, and you return to your own identity.$",
      },
    },
  },

  clarity = {
    requires = baleq,
    takes = {"equilibrium"},
    initDef = true,
    redef = false,
    give = function() send("clarity") end,
    able = skills.survival >= skillranks.virtuoso,
    triggers = {
      up = {
        "^You listen intently for an instant of silence. Finding it, you focus on it and its clarity,",
        "^You have already filled your mind with clarity.$",
        "^Your mind is filled with clarity.$",
      },
      down = {
        "^Your clarity of mind has been corrupted.$",
      },
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
        "^Flapping your wings gently, you begin to hover above the ground.$",
        "^You are already hovering.$",
      },
      down = {
        "^You cease your levitation as the pit attempts to pull you towards it.$",
        "^Your levitation defence has been stripped.$"
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
    able = isVampire() or isClass("carnifex") or isClass("templar"),
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

  gripping = {
    requires = baleq,
    takes = {},
    initDef = true,
    redef = true,
    give = function() send("grip") end,
    take = function() send("relax grip") end,
    able = isClass("carnifex") or isClass("templar") or hasSkill("gripping"),
    triggers = {
      up = {
        "^You concentrate on gripping tightly with your hands.$",
        "^Your hands are gripping your wielded items tightly.$",
      },
      down = {
        "^You relax your grip.$",
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

  nimbleness = {
    requires = {},
    takes = {},
    initDef = false,
    redef = false,
    give = function()
      if skills.avoidance >= skillranks.mythical then
        send("nimbleness")
      end
    end,
    able = true,
    triggers = {
      up = {
        "^Shifting your weight to the balls of your feet, you begin to feel capable of quicker movements.$",
      },
      down ={
        "^The constant exertion has worn you down, and you cease your nimble maneuvers, panting.$",
        "^Your muscles are too tired to become nimble again so soon.$",
      },
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
        "^Your body grows extremely dense and heavy as the mass salve infuses your skin.$",
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

  disregarding = {
    requires = baleq,
    takes = {},
    initDef = false,
    redef = false,
    give = function() send("config disregarding on") end,
    take = function() send("config disregarding off") end,
    able = true,
    triggers = {
      up = {
        "^You will disregard your own personal safety.$",
        "^You are disregarding your personal safety.$",
      },
      down = {
        "^You have disabled the ability to harm yourself.$",
      },
    },
  },

  divine_speed = {
    requires = baleq,
    takes = {"equilibrium"},
    initDef = false,
    redef = false,
    give = function() send("grace") end,
    able = true,
    triggers = {
      up = {
        "^You call upon the Divine to make you fleet of foot and feel your prayers answered with a rush of ",
        "^You have been granted the speed of the Divine.$",
        "^You are already graced with Divine speed.$",
      },
      down = {
        "granted rush of adrenaline fades.",
--        "^Your divine_speed defence has been stripped.$",
      },
    },
  },

------------
-- Eggnog --
------------
  eggnog = {
    requires = baleq,
    takes = {},
    initDef = false,
    redef = false,
    give = function() send("sip eggnog") end,
    able = true,
    triggers = {
      up = {
        "^Thick and smooth, the eggnog is enough to send minute shivers through you with its immaculate",
        "^The eggnog effect is boosting your critical hits.$",
        "^The eggnog effect is boosting your willpower regeneration.$",
        "^You finish off your eggnog and lick it clean from your lips.$",
      },
      down = {
      },
    },
  },

    eggnog_exp = {
    requires = baleq,
    takes = {},
    initDef = false,
    redef = false,
    give = function() send("sip eggnog") end,
    able = true,
    triggers = {
      up = {
        "^You have gained the eggnog_exp defence.$",
        "^The eggnog effect is boosting your experience gain.$",
      },
      down = {
      },
    },
  },

  eggnog_crits = {
    requires = baleq,
    takes = {},
    initDef = false,
    redef = false,
    give = function() send("sip eggnog") end,
    able = true,
    triggers = {
      up = {
        "^You have gained the eggnog_crits defence.$",
        "^The eggnog effect is boosting your critical hits.$",
      },
      down = {
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

  ----------------
  --  Luminary  --
  ----------------
  toughness = {
    requires = baleq,
    takes = {},
    initDef = false,
    redef = false,
    give = function() send() end,
    able = isClass("luminary"),
    triggers = {
      up = {
        "^Your body grows stronger as the blessings dissolve around you.$",
        "^Your skin is toughened.$",
      },
      down = {
--        "^$",
      },
    },
  },

  resistance = {
    requires = baleq,
    takes = {},
    initDef = false,
    redef = false,
    give = function() send() end,
    able = isClass("luminary"),
    triggers = {
      up = {
        "^Your spirit is strengthened against spiteful magics.$",
        "^You are resisting magical damage.$",
      },
      down = {
--        "^$",
      },
    },
  },

  constitution = {
    requires = baleq,
    takes = {},
    initDef = false,
    redef = false,
    give = function() send() end,
    able = isClass("luminary"),
    triggers = {
      up = {
        "^Your constitution is strengthened by the bliss that surrounds you.$",
        "^You are using your superior constitution to prevent nausea.$",
      },
      down = {
--        "^$",
      },
    },
  },

  bliss = {
    requires = baleq,
    takes = {"equilibrium"},
    initDef = false,
    redef = false,
    give = function() send("perform bliss me") end,
    able = isClass("luminary"),
    triggers = {
      up = {
        "^You pour blessings of bliss over yourself, granting visions of the majesty of the divine.$",
        "^You are experiencing the pleasure of divine bliss.$",
        "^That person is already experiencing bliss.$",
        "^pours blessings over you, and divine choirs begin to sing joyously at the edge of your hearing.$",
      },
      down = {
        "^The heavenly visions fade as the bliss leaves you.$",
      },
    },
  },

  inspiration_strength = {
    requires = "balance",
    takes = {"equilibrium"},
    initDef = false,
    redef = false,
    give = function() send("perform inspiration strength") end,
    able = isClass("luminary"),
    triggers = {
      up = {
        "^You bow your head and pray for the Gods to increase your strength.$",
        "^Your limbs are suffused with divinely",
      },
      down = {
        "^You slump slightly as the divinely",
      },
    },
  },

  inspiration_constitution = {
    requires = "balance",
    takes = {"equilibrium"},
    initDef = false,
    redef = false,
    give = function() send("perform inspiration constitution") end,
    able = isClass("luminary"),
    triggers = {
      up = {
        "^You bow your head and pray for the Gods to increase your constitution.$",
        "^Your body is suffused with divinely",
      },
      down = {
        "^You slump slightly as the divinely",
      },
    },
  },

  focus = {
    requires = baleq,
    takes = {"equilibrium"},
    initDef = false,
    redef = false,
    give = function() send("perform focus") end,
    take = function() send("perform focus") end,
    able = isClass("luminary"),
    triggers = {
      up = {
        "^You bow your head in silent prayer, allowing your devotional energy to anchor you to the ground.$",
        "^Your Devotional energies are anchoring you to the ground.$",
      },
      down = {
        "^Relaxing your legs, you allow the focused devotional energies anchoring you to the ground to",
      },
    },
  },

  fireblock = {
    requires = baleq,
    takes = {"balance"},
    initDef = true,
    redef = false,
    give = function() send("evoke fireblock") end,
    able = isClass("luminary"),
    triggers = {
      up = {
        "^You close your eyes briefly, and evoke a brilliant shield around your body.$",
        "^You are protected from other sources of fire.$",
      },
      down = {
        "^With a wrench, your fire shield is violently snatched from your body.$",
      },
    },
  },

  lightshield = {
    requires = baleq,
    takes = {"equilibrium"},
    initDef = true,
    redef = false,
    give = function() send("evoke lightshield") end,
    able = isClass("luminary"),
    triggers = {
      up = {
        "^You close your eyes briefly, and call forth a protective aura.$",
        "^You are already protected against light",
        "^You are protected from light",
      },
      down = {
      },
    },
  },

  rebirth = {
    requires = baleq,
    takes = {"balance"},
    initDef = false,
    redef = false,
    give = function() send("evoke rebirth") end,
    able = isClass("luminary"),
    triggers = {
      up = {
        "^Your soul burns as you ready a portion of your Inner Fire to return you to life.$",
        "^You have prepared your Inner Spark to bring about your Rebirth.$",
        "^You are already protected from death.$",
      },
      down = {
        "^Your soul has not recovered sufficiently for you to protect it from death.$",
        "^You feel your Inner Spark flare up, quickly moving from your inner core until your skin begins to",
      },
    },
  },

  lightform = {
    requires = baleq,
    takes = {"equilibrium"},
    initDef = false,
    redef = false,
    give = function() send("evoke lightform") end,
    take = function() send("reform") end,
    able = isClass("luminary"),
    triggers = {
      up = {
        "^You strengthen your ties to the light and close your eyes briefly in concentration, only to realize",
        "^You are a mote of light.$",
      },
      down = {
        "^You will yourself to become corporeal once more.$",
      },
    },
  },

  dhar_symbol = {
    requires = baleq,
    takes = {"equilibrium"},
    initDef = false,
    redef = false,
    give = function() send("paint shield dhar") end,
    able = isClass("luminary"),
    triggers = {
      up = {
        "^Holding out a buckler, you deftly paint the symbol of Dhar onto its surface. As you finish, the",
        "^You are aided by the symbol of Dhar.$",
      },
      down = {
      },
    },
  },

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
    initDef = false,
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
        "^Your howls are echoing back upon you.$",
      },
      down = {
        "^You cease to echo your howls.$",
        "^You aren't causing your howls to echo.$",
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
        "^You aren't snarling.$",
      },
    },
  },

  attuning = {
    requires = baleq,
    takes = {"equilibrium"},
    initDef = false,
    redef = false,
    give = function() send("attuning on") end,
    take = function() send("attuning off") end,
    able = isClass("atabahi"),
    triggers = {
      up = {
        "^You focus on attuning your calls against attack, your subconscious mind protects you from ceasing",
        "^Your vocal cords are protected by attuning.$",
        "^You have already attuned your howls.$",
      },
      down = {
        "^Your vocal cords are no longer attuned against attack.$",
        "^You aren't attuning your howl.$",
      },
    },
  },

  boneshaking = {
    requires = baleq,
    takes = {"equilibrium"},
    initDef = false,
    redef = false,
    give = function() send("boneshaking on") end,
    take = function() send("boneshaking off") end,
    able = isClass("atabahi"),
    triggers = {
      up = {
        "^You begin to relax and constrict your throat alternately, letting your howls gain strength as they",
        "^You are already howling strongly enough to shake the bones of those around you.$",
        "^Your howls are shaking the bones of your victims.$",
      },
      down = {
        "^Your howls are no longer strong enough to shake the bones of your victims.$",
      },
    },
  },

  endurance = {
    requires = baleq,
    takes = {"balance"},
    initDef = false,
    redef = false,
    give = function() send("endurance") end,
    able = isClass("atabahi"),
    triggers = {
      up = {
        "^Panting in a peculiar growl, your blood flows with greater intensity in your veins and fills you",
        "^Your movements are supernaturally fast.$",
        "^You are already moving at supernatural speed.$",
      },
      down = {
        "^You are no longer moving so quickly.$",
      },
    },
  },

  ----------------
  --  Carnifex  --
  ----------------

  shroud = {
    requires = baleq,
    takes = {},
    initDef = false,
    redef = false,
    give = function() send("soul shroud") end,
    able = isClass("carnifex"),
    triggers = {
      up = {
        "^You utter a command of power as you lift your soulstone, sending forth an inky-blackness that",
        "^Your actions are cloaked in secrecy.$",
      },
      down = {
        "^Your shroud dissipates and you return to the realm of perception.$",
      },
    },
  },

  soulthirst = {
    requires = baleq,
    takes = {"equilibrium"},
    initDef = true,
    redef = false,
    give = function() send("soul thirst") end,
    able = isClass("carnifex"),
    triggers = {
      up = {
        "^You close your eyes and summon upon a deep, ravenous hunger, a foul aura coursing through your arms",
        "^Your weapons thirst for the souls of your enemies.$",
      },
      down = {
        "^You feel your thirst for soul fade from your body.$"
      },
    },
  },

  soulharvest = {
    requires = baleq,
    takes = {},
    initDef = true,
    redef = false,
    give = function() send("soul harvest on") end,
    take = function() send("soul harvest off") end,
    able = isClass("carnifex"),
    triggers = {
      up = {
        "^You will begin to automatically harvest the souls of your victims.$",
        "^You are harvesting the souls of your victims.$",
      },
      down = {
        "^You will no longer harvest the souls of your victims automatically.$",
      },
    },
  },

  spiritsight = {
    requires = baleq,
    takes = {"equilibrium"},
    initDef = true,
    redef = false,
    give = function() send("soul spiritsight") end,
    able = isClass("carnifex"),
    triggers = {
      up = {
        "^A luminous red haze fills your vision and your awareness heightens greatly.$",
        "^You are seeking the souls of the hidden.$",
      },
      down = {
      },
    },
  },

  soulmask = {
    requires = baleq,
    takes = {"equilibrium"},
    initDef = true,
    redef = false,
    give = function() send("soul mask") end,
    able = isClass("carnifex"),
    triggers = {
      up = {
        "^Dark energy surrounds your soul as you chant harshly to yourself, masking it from prying eyes.$",
        "^Your soul is swathed in secrecy.$",
      },
      down = {
      },
    },
  },

  soul_sacrifice = {
    requires = baleq,
    takes = {"equilibrium"},
    initDef = false,
    redef = false,
    give = function() send("soul sacrifice") end,
    able = isClass("carnifex"),
    triggers = {
      up = {
        "^A deafening roar fills your head and momentarily drowns out all other noise as you harness your",
        "^Your soul has been sacrificed to improve your next strike.$",
        "^You have already sacrificed a portion of your soul to strengthen your next blow.$",
      },
      down = {
        "^Unable to maintain your sacrifice, your soul returns to you.$",
        "^Your attack strikes true with the full force of your sacrificed soul.$",
      },
    },
  },

  soul_substitute = {
    requires = baleq,
    takes = {"equilibrium"},
    initDef = false,
    redef = false,
    give = function() send("soul substitute") end,
    able = isClass("carnifex"),
    triggers = {
      up = {
        "^Taking hold of your soulstone you plunge it into your chest, eliciting a howl of rage as a soul is",
        "^You will substitute your soul with another upon dying.$",
        "^You are already preparing to substitute your soul with another.$",
      },
      down = {
        "^As the last of your life force fades, you reach out to the soul trapped within your chest. A$",
        "^Your soul has not recovered sufficiently for you to protect it from death.$",
      },
    },
  },

  soul_fortify = {
    requires = baleq,
    takes = {"equilibrium"},
    initDef = true,
    redef = false,
    give = function() send("soul fortify") end,
    able = isClass("carnifex"),
    triggers = {
      up = {
        "^You call aloud, willing your soul to strengthen itself, and in turn you positively glow with",
        "^Your soul has already been fortified.$",
        "^Your soul has been fortified.$"
      },
      down = {
        "^You feel weaker as the fortification surrounding your soul fades away.$",
      },
    },
  },

  bruteforce = {
    requires = baleq,
    takes = {"balance"},
    initDef = false,
    redef = false,
    give = function() send("hammer force") end,
    able = isClass("carnifex"),
    triggers = {
      up = {
        "^Your muscles bulge with deadly strength as your tighten your grip upon your hammer.$",
        "^You are striking with great force.$",
      },
      down = {
        "^As your muscles begin to tire, you cease to drive all your force behind your blows.$",
      },
    },
  },

  herculeanrage = {
    requires = baleq,
    takes = {"balance"},
    initDef = false,
    redef = false,
    give = function() send("hammer rage") end,
    able = isClass("carnifex"),
    triggers = {
      up = {
        "^With a herculean bellow of anger, you allow battle lust to over take you as you fly into a rage.$",
        "^You have flown into a battle rage.$",
      },
      down = {
      },
    },
  },

  fetching = {
    requires = baleq,
    takes = {"equilibrium"},
    initDef = false,
    redef = false,
    give = function() send("hound fetching on") end,
    take = function() send("hound fetching off") end,
    able = isClass("carnifex") and skills.warhounds >= skillranks.fabled,
    triggers = {
      up = {
        "^You order your hound to fetch the corpses of those you slay.$",
        "^Your hound is automatically fetching corpses.$",
        "^Your hound is already fetching the corpses of your slain.$",
      },
      down = {
        "^Your hound will no longer fetch the corpses of your slain.$",
      },
    },
  },

  ---------------------------
  --  Indorani / Cabalist  --
  ---------------------------
  soulmask = {
    requires = baleq,
    takes = {"equilibrium"},
    initDef = true,
    redef = false,
    give = function() send("soulmask") end,
    able = isNecro(),
    triggers = {
      up = {
        "^You utter a short charm to mask your soul from prying eyes.$",
        "^Your soul is swathed in secrecy.$",
        "^You have already masked your soul.$",
      },
      down = {
      },
    },
  },

  shroud = {
    requires = baleq,
    takes = {"equilibrium"},
    initDef = false,
    redef = false,
    give = function() send("shroud") end,
    take = function() send("unshroud") end,
    able = isNecro(),
    triggers = {
      up = {
        "^Calling on your dark power, you draw a thick shroud of concealment about yourself to cover your",
        "^Your actions are cloaked in secrecy.$",
      },
      down = {
        "^Your shroud dissipates and you return to the realm of perception.$",
      },
    },
  },

  gravechill = {
    requires = baleq,
    takes = {"equilibrium"},
    initDef = false,
    redef = false,
    give = function() send("gravechill") end,
    take = function() send("gravechill") end,
    able = isNecro(),
    triggers = {
      up = {
        "^The chill of the grave fills your inner core and limbs, waiting to spread through your decays.$",
        "^The cold of the grave has filled your body.$",
      },
      down = {
        "^You release the chill of the grave to your surroundings, letting your inner core and limbs warm.$",
      },
    },
  },

  vengeance = {
    requires = baleq,
    takes = {"equilibrium"},
    initDef = false,
    redef = false,
    give = function() send("vengeance") end,
    able = isNecro(),
    triggers = {
      up = {
        "^You swear to yourself that you will wreak vengeance on your slayer.$",
        "^Don't you think your anger and thirst for revenge is getting out of hand?",
        "^You have sworn vengeance upon those who would slay you.$",
      },
      down = {
      },
    },
  },

  deathaura = {
    requires = baleq,
    takes = {"equilibrium"},
    initDef = false,
    redef = false,
    give = function() send() end,
    able = isNecro(),
    triggers = {
      up = {
        "^You let the blackness of your soul pour forth.$",
        "^You are emanating an aura of death harmful to those around you.$",
        "^You already possess an aura of death.$",
      },
      down = {
        "^You remove the aura of death from around you.$",
      },
    },
  },

  soulcage = {
    requires = baleq,
    takes = {"equilibrium"},
    initDef = false,
    redef = false,
    give = function() send("soulcage") end,
    able = isNecro(),
    triggers = {
      up = {
        "^You begin to spin a web of necromantic power about your soul, drawing on your vast reserves of life",
        "^Your soul is already safe from death.$",
        "^Your being is protected by the soulcage.$",
        "^You are already protected from death.$",
      },
      down = {
        "^As you feel the last remnants of strength ebb from your tormented body, you close your eyes and let",
        "^Your soul has not recovered sufficiently for you to protect it from death.$",
      },
    },
  },

   blackwind = {
    requires = baleq,
    takes = {"equilibrium"},
    initDef = false,
    redef = false,
    give = function() send("blackwind") end,
    take = function() send("human") end,
    able = isNecro,
    triggers = {
      up = {
        "^You call upon your dark power, and instantly a black wind descends upon you. In seconds your body",
        "^As an insubstantial black wind, you are immune to most attacks.$",
        "^Before you can return to human form, you must possess both balance and equilibrium.$",
      },
      down = {
        "^You concentrate and are once again Azudim.$",
        "^You are already in Azudim form.$",
      },
    },
  },

  --------------
  -- Indorani --
  --------------

  devil = {
    requires = baleq,
    takes = {"balance"},
    initDef = false,
    redef = false,
    give = function() send() end,
    take = function() send() end,
    able = isClass("indorani"),
    triggers = {
      up = {
        "^You fling the card at the ground, and a red, horned Devil rises from the bowels of the earth to say,",
        "^You have made a deal with the Devil.$",
      },
      down = {
      },
    },
  },

  putrefaction = {
    requires = baleq,
    takes = {"equilibrium"},
    initDef = false,
    redef = false,
    give = function() send("putrefaction") end,
    take = function() send("solidify") end,
    able = isClass("indorani"),
    triggers = {
      up = {
        "^You concentrate for a moment and your flesh begins to dissolve away, becoming slimy and wet.$",
        "^You are bathed in the glorious protection of decaying flesh.$",
        "^You have already melted your flesh. Why do it again?",
      },
      down = {
        "^You concentrate briefly and your flesh is once again solid.$",
      },
    },
  },

  hierophant = {
    requires = baleq,
    takes = {"balance"},
    initDef = false,
    redef = false,
    give = function() send(tHierophant2()) end,
    take = function() send() end,
    able = isClass("indorani"),
    triggers = {
      up = {
        "^You quickly fling a Hierophant tarot card at yourself and feel somewhat protected.$",
        "^You are protected by the intimidating presence of the Hierophant.$",
        "^They are already protected by the Hierophant.$",
      },
      down = {
        "^The protection of the Hierophant fades.$",
      },
    },
  },

  chariot = {
    requires = baleq,
    takes = {"balance"},
    initDef = false,
    redef = false,
    give = function() send("board chariot") end,
    take = function() send("dismount chariot") end,
    able = isClass("indorani"),
    triggers = {
      up = {
        "^You step aboard the chariot and firmly grasp the reins.$",
        "^You are riding a charred chariot.$",
        "^You are already mounted on a charred chariot.$",
      },
      down = {
        "^You step down off of a charred chariot.$",
        "^Losing your balance, you fall from your steed to the hard ground.$",
      },
    },
  },

  sun = {
    requires = baleq,
    takes = {"balance"},
    initDef = false,
    redef = false,
    give = function() send(tSun()) end,
    able = isClass("indorani"),
    triggers = {
      up = {
        "^You lazily toss the card to the ground, and a thin veil of golden motes rise up to cover your skin.$",
        "^You are protected from chill by the Sun tarot.$",
      },
      down = {
        "^The effects of your Sun tarot have worn away.$",
      },
    },
  },

  ---------------
  --  Vampire  --
  ---------------
  stalking = {
    requires = baleq,
    takes = {"equilibrium"},
    initDef = false,
    redef = false,
    give = function() send("stalk") end,
    able = isVampire() or hasSkill("stalking"),
    triggers = {
      up = {
        "^You silently summon the shadows to soften and conceal your footsteps.$",
        "^You stalk the night as a predator.$",
      },
      down = {
        "^The shadows fade, leaving your footfalls audible once again.$",
        "^Your power to conceal your movement is ineffective during the day.$",
      },
    },
  },

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
        "^You are not currently masquerading.$",
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

  celerity = {
    requires = baleq,
    takes = {"balance"},
    initDef = false,
    redef = false,
    give = function() send("celerity") end,
    able = isVampire(),
    triggers = {
      up = {
        "^You draw upon your blood pool and send the mystical fluid racing through your entire body. You feel",
        "^Your movements are supernaturally fast.$",
        "^You are already moving at supernatural speed.$",
      },
      down = {
        "^You are no longer moving so quickly.$",
      },
    },
  },


  -----------------
  --  Bloodborn  --
  -----------------

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
    initDef = true,
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
    initDef = true,
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
    initDef = true,
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

  concentration = {
    requires = baleq,
    takes = {},
    initDef = false,
    redef = false,
    give = function() send() end,
    able = isClass("bloodborn"),
    triggers = {
      up = {
        "^You cringe, forcing your blood to concentrate.$",
        "^Your blood is concentrated.$",
      },
      down = {
        "^You feel your blood becoming thinner again.$",
      },
    },
  },

  mindsurge = {
    requires = baleq,
    takes = {},
    initDef = false,
    redef = false,
    give = function() send() end,
    able = isClass("bloodborn"),
    triggers = {
      up = {
        "^A pair of glowing runes appears on your tongue and forehead, and they glow with a burst of energy",
        "^Your words bring pain to the mind.$",
      },
      down = {
        "^The runes on your tongue and forehead flare up one last time before disappearing entirely.$",
      },
    },
  },

  bloodsense = {
    requires = baleq,
    takes = {"equilibrium"},
    initDef = true,
    redef = false,
    give = function() send("bloodsense") end,
    able = isClass("bloodborn"),
    triggers = {
      up = {
        "^You broaden your senses to encompass the bleeding of those around you.$",
        "^You are already sensing the bleeding of others.$",
        "^You are sensing the bleeding of others.$",
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
    able = isClass("teradrim") and skills.terramancy == skillranks.transcendant,
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

  stonebind = {
    requires = baleq,
    takes = {"balance"},
    initDef = true,
    redef = false,
    give = function() send("earth stonebind") end,
    able = isClass("teradrim"),
    triggers = {
      up = {
        "^You punch your arms into the earth, casting them within a thin layer of supple stone.$",
        "^Your arms have been bound in stone.$",
        "^Your arms have already been encased within stone.$",
      },
      down = {
      },
    },
  },

  imbue_stonefury = {
    requires = baleq,
    takes = {"equilibrium"},
    initDef = false,
    redef = false,
    give = function() send("earth imbue stonefury") end,
    able = isClass("teradrim"),
    triggers = {
      up = {
        "^The earth around you shudders as you imbue your flail with the fury of the Earthen.$",
        "^You are focusing energy into your sands to swelter them.$",
        "^You have already imbued your flail with that!$",
      },
      down = {
      },
    },
  },

  imbue_will = {
    requires = baleq,
    takes = {"equilibrium"},
    initDef = false,
    redef = false,
    give = function() send("earth imbue will") end,
    able = isClass("teradrim"),
    triggers = {
      up = {
        "^Faint, incoherent whispers touch your ears as you imbue your flail with the will of the Earthen.$",
        "^Your flail is imbued with the will of the Earthen.$",
        "^You have already imbued your flail with that!$",
      },
      down = {
      },
    },
  },

  imbue_erosion = {
    requires = baleq,
    takes = {"equilibrium"},
    initDef = false,
    redef = false,
    give = function() send("earth imbue erosion") end,
    able = isClass("teradrim"),
    triggers = {
      up = {
        "^Sand suddenly swirls its way around your flail, imbuing it with the raw force of the desert.$",
        "^Your flail imbued with the raw force of the desert.$",
        "^You have already imbued your flail with that!$",
      },
      down = {
      },
    },
  },

  ricochet = {
    requires = baleq,
    takes = {"balance"},
    initDef = true,
    redef = false,
    give = function() send("earth ricochet") end,
    able = isClass("teradrim"),
    triggers = {
      up = {
        "^You heft your flail as you familiarize itself with its weight and the momentum needed to bounce it",
        "^You are attempting to bounce your attempts off parried blows.$",
      },
      down = {
      },
    },
  },

  surefooted = {
    requires = baleq,
    takes = {"balance"},
    initDef = false,
    redef = false,
    give = function() send("earth surefooted") end,
    able = isClass("teradrim"),
    triggers = {
      up = {
        "^Drawing on your connection with the elemental earth, you feel your feet drawn downward, steadying",
        "^You are concentrating on maintaining a sure foot.$",
        "^Your footing is already remarkably steady.$",
      },
      down = {
        "^Your feet feel suddenly lighter, no longer drawn downward towards the earth.$",
      },
    },
  },

  twinsoul = {
    requires = baleq,
    takes = {"equilibrium"},
    initDef = false,
    redef = false,
    give = function() send("golem twinsoul on") end,
    take = function() send("golem twinsoul off") end,
    able = isClass("teradrim"),
    triggers = {
      up = {
        "^Spectral energy momentarily envelops both you and your golem as you carefully link a portion of your",
        "^Your soul is entwined around your golem's.$",
        "^Your soul is already linked to your golem.$",
      },
      down = {
        "^You carefully detach your soul from the golem.$",
        "^Your soul isn't linked to your golem in the first place.$",
      },
    },
  },

  earth_resonance = {
    requires = baleq,
    takes = {"equilibrium"},
    initDef = true,
    redef = false,
    give = function() send("earth resonance") end,
    able = isClass("teradrim"),
    triggers = {
      up = {
        "^You close your eyes and focus on the steady thrum of the earth below you as you bring your soul into",
        "^Your soul is resonating with the earth.$",
        "^You are already resonating with the earth.$",
      },
      down = {
      },
    },
  },

  sand_conceal = {
    requires = baleq,
    takes = {"equilibrium"},
    initDef = false,
    redef = false,
    give = function() send("sand conceal on") end,
    take = function() send("sand conceal off") end,
    able = isClass("teradrim"),
    triggers = {
      up = {
        "^Sand wreathes itself around your feet, softening your footsteps.$",
        "^Sand is softening your footsteps.$",
        "^The sand is already concealing your movement.$",
      },
      down = {
        "^The sand will no longer conceal your movement.$",
        "^The sand wasn't concealing your movement in the first place.$",
      },
    },
  },

  sand_swelter = {
    requires = baleq,
    takes = {"equilibrium"},
    initDef = false,
    redef = false,
    give = function() send("sand swelter on") end,
    take = function() send("sand swelter off") end,
    able = isClass("teradrim"),
    triggers = {
      up = {
        "^You focus your energy into the area around you, the sands sweltering rapidly in response.$",
        "^You are focusing your energy into sweltering your sands.$",
        "^You are already sweltering your sands.$",
      },
      down = {
        "^You cease the sweltering of your sands.$",
        "^You weren't sweltering your sands in the first place.$",
      },
    },
  },

  entwine = {
    requires = baleq,
    takes = {},
    initDef = true,
    redef = true,
    give = function() send("earth entwine") end,
    able = isClass("teradrim"),
    triggers = {
      up = {
        "^You reaffirm your familiarity with the flail as you test its weight and prepare to entwine its",
        "^You are already preparing to disarm your opponents.$",
        "^You are preparing to entwine your flail against hostile weapons.$",
      },
      down = {
      },
    },
  },

--  concealment = {
--    requires = baleq,
--    takes = {"balance"},
--    initDef = false,
--    redef = false,
--    give = function() doWield(crozier, tower) send("sand concealment") end,
--    able = isClass("teradrim"),
--    triggers = {
--      up = {
--        "^You draw upon the powers of the earth and conceal your presence from detection.$",
--        "^You are veiled.$",
--        "^You are already concealed by the earth's power.$",
--      },
--      down = {},
--    },
--  },

--  truesight = {
--    requires = baleq,
--    takes = {"equilibrium"},
--    initDef = true,
--    redef = false,
--    give = function() doWield(crozier, tower) send("truesight") end,
--    able = isClass("teradrim"),
--    triggers = {
--      up = {
--        "^You focus and your vision expands, allowing you to see as one of the Earthen.$",
--        "^You are utilising the sight of the Earthen.$",
--      },
--      down = {},
--    },
--  },

--  stonefeet = {
--    requires = baleq,
--    takes = {"balance"},
--    initDef = false,
--    redef = false,
--    give = function() send("stonefeet") end,
--    able = isClass("teradrim"),
--    triggers = {
--      up = {
--        "^You call to the earth and your feet grow heavy as stone.$",
--        "^Your feet are of dense granite.$",
--      },
--      down = {
--        "^Your stone feet revert to normal.$",
--      },
--    },
--  },

--  sandarmour = {
--    requires = baleq,
--    takes = {"balance"},
--    initDef = true,
--    redef = false,
--    give = function() doWield(crozier, tower) send("sand armour") end,
--    take = function()  end, --Todo: Get Sandarmour TAKE COMMAND OR FIND OUT IF THERE ISN'T ONE
--    able = isClass("teradrim"),
--    triggers = {
--      up = {
--        "^You will your sands to coat your body before hardening them into a thick armour.$",
--        "^You are protected by a hardened shell of sand.$",
--        "^You are already protected by sand armour."
--      },
--      down = {},
--    },
--  },

--  earthsense = {
--    requires = baleq,
--    takes = {"equilibrium"},
--    initDef = true,
--    redef = false,
--    give = function() send("earthsense") end,
--    able = isClass("teradrim"),
--    triggers = {
--      up = {"^You are listening for underground movement.$"},
--      down = {},
--    },
--  },


  ------------------
  --  Sciomancer  --
  ------------------
  reflection = {
    requires = baleq,
    takes = {},
    initDef = false,
    redef = false,
    give = function() send() end,
    able = isClass("sciomancer"),
    triggers = {
      up = {
        "^The air around you shimmers as a near-translucent reflection forms before you.$",
        "^You are surrounded by 1 reflections of yourself.$",
      },
      down = {
        "^All your reflections wink out of existence!$",
        "^One of your reflections has been destroyed! You have 0 left.$",
      },
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

  ghosted = {
    requires = {},
    takes = {},
    initDef = true,
    redef = true,
    give = function() send("conjure ghost") end,
    able = isClass("syssin"),
    triggers = {
      up = {
        "^You are shimmering with a ghostly light.$",
        "^You are already ghosting.$",
      },
      down = {},
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

  -------------
  -- TEMPLAR --
  -------------

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
  if not self[name] then ACSEcho("Defense " .. name .. " not found.") return end
  extraLine = extraLine .. C.B .. " (" .. C.G .. name .. C.B .. ") " .. C.x
  self[name].active = true
end

function defenses:take(name)
  if not self[name] then ACSEcho("Defense " .. name .. " not found.") return end
  extraLine = extraLine .. C.B .. " (" .. C.R .. name .. C.B .. ") " .. C.x
  self[name].active = false
end

function defenses:reset()
  for name, _ in pairs(self) do
    if type(defenses[name]) == "table" then
      self[name].active = false
      self[name].redeffing = false
    end
  end
end

defenses:prepare()
doDef()
