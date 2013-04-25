-- Settings for the system.

canFocus = true
canTree = true
canClot = true
canParry = true
living = true
artiPipes = false

-- Set this to be whatever class you currently are.
classType = LoadArg or "Syssin"

-- Numbers for specific types of weapons for the wielding system.
bolas = "bola"
weapons = {
  bola = {
    item = "bola281238",
    name = "a three%-weight bola"
  },
  shield = {
    item = "cavalry204920",
    name = "a cavalry shield"
  }
  -- warhammer = {
  --   item = "warhammer12345",
  --   name = "a bigass warhammer",
  --   twoHanded = true
  -- }
}


living = false
useBolas = true

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