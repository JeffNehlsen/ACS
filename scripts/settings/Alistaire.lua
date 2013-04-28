-- Settings for the system.

-- These are true or false
canFocus = true
canTree = true
canClot = true
canParry = true
living = true
artiPipes = true

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
classType = LoadArg or "Templar"

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
crozier   = "crozier70276"
flail     = "flail140682"
tower     = "kite155106"
sword     = "shortsword187816"
whip      = "whip8025"
dirk      = "dirk28045"
bow       = "bow182633"
dhurive   = "dhurive27968"
axe       = "axe51634"
warhammer = "warhammer236300"
bardiche  = "bardiche159489"

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
  
  -- Lycanthrope
  ferality = skillranks.transcendent,
  lycanthropy = skillranks.transcendent,
  howling = skillranks.transcendent,
  
  -- Teradrim
  sand = skillranks.transcendent,
  earth = skillranks.transcendent,
  animation = skillranks.transcendent,
  
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

  savagery = skillranks.transcendent,
  deathlore = skillranks.transcendent,
  warhounds = skillranks.transcendent,
}

-- Skills for endgame and racial skills.
extraSkills = {"warmth", "renew", "quickassess"}

-- Label color for your prompt (H, M, %, etc)
promptLabelColor = C.x
--promptLabelColor = C.g

if living then str = "Living " else str = "Undead " end
echo("Settings loaded for " .. atcp.name .. ". " .. str .. classType)