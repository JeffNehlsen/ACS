-- Settings for the system.

-- These are true or false
canFocus = false
canTree = true
canClot = true
canParry = true
living = true
artiPipes = false

-- Your preferred pagelength
defaultPagelength = 0

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
classType = LoadArg or "luminary"

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
tower     = "buckler188219"
--Luminary
mace      = "mace"

-- Enter what skill levels you have in all your classes.  If an impoortant one is missing, 
-- let Kaed know and he'll add it to the master file.
-- These will be used to help set up your defenses automatically.
-- Work in progress...
skills = {
  -- General
  vision = skillranks.gifted,
  avoidance = skillranks.skilled,
  survival = skillranks.fabled,
  weaponry = skillranks.gifted,
  tattoos = skillranks.novice,
  
  -- Lycanthrope
  ferality = skillranks.unknown,
  lycanthropy = skillranks.unknown,
  howling = skillranks.unknown,
  
  -- Luminary
  spirituality = skillranks.transcendent,
  devotion = skillranks.transcendent,
  illumination = skillranks.transcendent,
  
  -- Syssin
  subterfuge = skillranks.unknown,
  venom = skillranks.unknown,
  hypnosis = skillranks.unknown,
  
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
  -- Carnifex
  savagery = skillranks.unknown,
  deathlore = skillranks.unknown,
  warhounds = skillranks.unknown,

  -- Indorani
  necromancy = skillranks.unknown,
  tarot = skillranks.unknown,
  domination = skillranks.unknown,
}

-- Skills for endgame and racial skills.
extraSkills = {"hover"}

-- Label color for your prompt (H, M, %, etc)
promptLabelColor = C.x
--promptLabelColor = C.g

hooks.target = function()
send("st tar " .. target)
end