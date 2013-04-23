-- Settings for the system.

-- These are true or false
canFocus = true
canTree = true
canClot = true
canParry = true
living = false
artiPipes = false

-- If you want selfishness to be kept up.
keepSelfishUp = false

-- If you have an allsignt enchantment, put it here.
-- If not, leave a blank string.
allsightEnchantment = "earring"

-- Experience display - Fixing the xp display in the prompt
-- Options: none, full, percent
experienceDisplay = "none"

-- Set this to be whatever class you currently are.
classType = LoadArg or "Syssin"

-- Default stick and kidney values.
-- To change values in game, refer to help file
--  ? autosip
siphealth    = atcp.max_health - 300
sipmana      = atcp.max_mana - 300
kidneyhealth = atcp.max_health * 2 / 3
kidneymana   = atcp.max_mana * 2 / 3

-- Default limb to parry
toguard = toguard or "head"

-- Using the Elixlist script, do you want to show venoms?
showVenoms = true

-- Numbers for specific types of weapons for the wielding system.
-- Custom weapons and other weapons need to be added to ACS-Wielding.
-- Examples are in the ACS-Wielding.
tower     = "banded206321"
whip      = "whip233722"
dirk      = "dirk37544"
bow       = "darkbow225604"
crozier   = "crozier115683"
flail     = "flail216061"

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
  
  -- Syssin
  subterfuge = skillranks.transcendent,
  venom = skillranks.transcendent,
  hypnosis = skillranks.transcendent,
}

-- Skills for endgame and racial skills.
extraSkills = {"miasma", "reconstitute", "quickassess"}

-- Label color for your prompt (H, M, %, etc)
promptLabelColor = C.x
--promptLabelColor = C.g