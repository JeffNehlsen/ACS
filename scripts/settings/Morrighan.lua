-- Settings for the system.

-- These are true or false
canFocus = true
canTree = true
canClot = true
canParry = true
living = true
artiPipes = false
PRERESTORE_THRESHOLD = 15

-- Numbers for specific types of weapons for the wielding system.
weapons = {
  dirk = {
    item = "dirk120499",
    name = "a needle%-pointed dirk"
  },
  whip = {
    item = "whip172589",
    name = "an iron%-tipped whip"
  },
  tower = {
    item = "buckler53491",
    name = "a buckler",
    shield = true
  },
  bow = {
    item = "darkbow233849",
    name = "a pale, twisting darkbow of ash and bone.",
    bow = true
  },
}

-- Your preferred pagelength
defaultPagelength = 40

-- If you want selfishness to be kept up.
keepSelfishUp = false

-- If you have an allsignt enchantment, put it here.
-- If not, leave a blank string.
allsightEnchantment = "earring"

-- Experience display - Fixing the xp display in the prompt
-- Options: none, full, percent
experienceDisplay = "none"

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
classType = LoadArg or "Syssin"

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
-- Example:
-- weaponVar = "weapon12345"

-- Enter what skill levels you have in all your classes.  If an impoortant one is missing, 
-- let Kaed know and he'll add it to the master file.
-- These will be used to help set up your defenses automatically.
-- Work in progress...
skills = {
  -- General
  vision = skillranks.transcendent,
  avoidance = skillranks.transcendent,
  survival = skillranks.transcendent,
  weaponry = skillranks.fabled,
  tattoos = skillranks.expert,
  
  -- Lycanthrope
  ferality = skillranks.transcendent,
  lycanthropy = skillranks.transcendent,
  howling = skillranks.virtuoso,
  
  -- Teradrim
  sand = skillranks.unknown,
  earth = skillranks.unknown,
  animation = skillranks.unknown,
  
  -- Syssin
  subterfuge = skillranks.transcendent,
  venom = skillranks.transcendent,
  hypnosis = skillranks.transcendent,
  
  -- Vampire (General)
  mentis = skillranks.unknown,
  corpus = skillranks.unknown,
  
  -- Bloodborn
  hematurgy = skillranks.unknown,
  
  -- Consanguine
  sanguis = skillranks.unknown,
  
  -- Infernal
  chivalry = skillranks.unknown,
  forging = skillranks.unknown,
  necromancy = skillranks.unknown,

  savagery = skillranks.unknown,
  deathlore = skillranks.unknown,
  warhounds = skillranks.unknown,
}

-- Skills for endgame and racial skills.
extraSkills = {}

-- Label color for your prompt (H, M, %, etc)
promptLabelColor = C.x
--promptLabelColor = C.g