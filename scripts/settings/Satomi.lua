-- Settings for the system.

-- These are true or false
canFocus = false
canTree = true
canClot = true
canParry = true
living = false
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
classType = LoadArg or "indorani"

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
--Teradrim
crozier   = "crozier236948"
flail     = "flail215790"
--Bloodborn
athame    = "athame237414"
scythe    = "scythe73214"
--Carnifex
warhammer = "warhammer202470"
bardiche  = "bardiche193743"
halberd   = "halberd"
--Indorani
dagger    = "bonedagger"

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
  tattoos = skillranks.skilled,
  
  -- Lycanthrope
  ferality = skillranks.transcendent,
  lycanthropy = skillranks.transcendent,
  howling = skillranks.transcendent,
  
  -- Teradrim
  terramancy = skillranks.transcendent,
  desiccation = skillranks.transcendent,
  animation = skillranks.transcendent,
  
  -- Syssin
  subterfuge = skillranks.unknown,
  venom = skillranks.unknown,
  hypnosis = skillranks.unknown,
  
  -- Vampire (General)
  mentis = skillranks.novice,
  corpus = skillranks.transcendent,
  
  -- Bloodborn
  hematurgy = skillranks.transcendent,
  
  -- Consanguine
  sanguis = skillranks.unknown,
  
  -- Infernal
  chivalry = skillranks.unknown,
  forging = skillranks.unknown,
  necromancy = skillranks.unknown,
  -- Carnifex
  savagery = skillranks.mythical,
  deathlore = skillranks.virtuoso,
  warhounds = skillranks.virtuoso,

  -- Indorani
  necromancy = skillranks.transcendent,
  tarot = skillranks.transcendent,
  domination = skillranks.transcendent,
}

-- Skills for endgame and racial skills.
extraSkills = {"heatsight", "miasma", "reconstitute", "gripping", "quickassess"}

-- Label color for your prompt (H, M, %, etc)
promptLabelColor = C.x
--promptLabelColor = C.g

hooks.target = function()
send("st tar " .. target)
end