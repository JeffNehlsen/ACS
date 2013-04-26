-- Settings for the system.

-- These are true or false
canFocus = true
canTree = true
canClot = true
canParry = true
living = true
artiPipes = true

-- Your preferred pagelength
defaultPagelength = 30

-- If you want selfishness to be kept up.
keepSelfishUp = false

-- If you have an allsignt enchantment, put it here.
-- If not, leave a blank string.
allsightEnchantment = "earring"

-- Experience display - Fixing the xp display in the prompt
-- Options: none, full, percent
experienceDisplay = "percent"

-- Set this to be whatever class you currently are.
-- This can be changed while in game by using the following alias:
--  classType (class)
-- As of now, current classes that have 'extra' stuff (aliases/triggers, defenses) added in are:
--  teradrim
--  atabahi
--  syssin
--  carnifex
-- Defenses added in/being added in for:
--  vampire
--  bloodborn
--  infernal
classType = LoadArg or "Zealot"

-- Default stick and kidney values.
-- To change values in game, refer to help file
--  ? autosip
siphealth = atcp.max_health - 300
sipmana = atcp.max_mana - 300
kidneyhealth = atcp.max_health * 2 / 3
kidneymana = atcp.max_mana * 2 / 3

-- Default limb to parry
toguard = "head"

-- Using the Elixlist script, do you want to show venoms?
showVenoms = true

-- Numbers for specific types of weapons for the wielding system.
weapons = {
  buckler = {
    item = "buckler58251",
    name = "a lantern crested buckler",
    shield = true
  },
  mace = {
    item = "mace",
    name = "a spiritual mace"
  },
  bow = {
    item = "bow178345",
    name = "a bow of the Hunt"
  },
  tower = {
    item = "shield58774",
    name = "a red and white bisected tower shield",
    shield = true
  }
}


-- Enter what skill levels you have in all your classes.  If an impoortant one is missing, 
-- let Kaed know and he'll add it to the master file.
-- These will be used to help set up your defenses automatically.
-- Work in progress...
skills = {
  -- General
  vision = skillranks.transcendent,
  avoidance = skillranks.transcendent,
  survival = skillranks.transcendent,
  weaponry = skillranks.transcendent,
  tattoos = skillranks.transcendent,

  -- Zealot
  illumination = skillranks.transcendent,
  telepathy = skillranks.transcendent,
  tekura = skillranks.transcendent,

  -- Luminary
  illumination = skillranks.transcendent,
  devotion = skillranks.transcendent,
  spirituality = skillranks.transcendent,
}

-- Skills for endgame and racial skills.
extraSkills = {"warmth", "renew", "quickassess", "heatsight", "gripping"}

-- Label color for your prompt (H, M, %, etc)
promptLabelColor = C.x
--promptLabelColor = C.g