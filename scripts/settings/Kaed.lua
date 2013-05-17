-- Settings for the system.
canFocus = true
canTree = true
canClot = true
canParry = true
living = true
artiPipes = false

-- Set this to be whatever class you currently are.
classType = LoadArg or "Syssin"

artiring = "ring281250"

-- Numbers for specific types of weapons for the wielding system.
weapons = {
  dirk = {
    item = "dirk282342",
    name = "a needle%-pointed dirk"
  },
  whip = {
    item = "whip231265",
    name = "an iron%-tipped whip"
  },
  bola = {
    item = "bola281238",
    name = "a three%-weight bola"
  },
  cavalry = {
    item = "cavalry204920",
    name = "a cavalry shield",
    shield = true
  },
  buckler = {
    item = "buckler204052",
    name = "a buckler",
    shield = true
  },
  mace = {
    item = "mace",
    name = "a spiritual mace"
  },
  tower = {
    item = "tower169295",
    name = "a tower shield",
    shield = true
  },
  bow = {
    item = "darkbow63726",
    name = "an elegant, bladed darkbow.",
    bow = true
  },
  mace1 = {
    item = "mace90597",
    name = "a mace of scorched ivory",
  },
  mace2 = {
    item = "mace88881",
    name = "an ebon serpent mace",
  },
  bastard = {
    item = "bastardsword255261",
    name = "a Delosian bastard sword",
    twoHanded = true,
  },
  scimitar = {
    item = "scimitar93129",
    name = "a gleaming scimitar",
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
  
  -- Syssin
  subterfuge = skillranks.transcendent,
  venom = skillranks.transcendent,
  hypnosis = skillranks.transcendent,

  concoctions = skillranks.transcendent,
}

-- Skills for endgame and racial skills.
extraSkills = {"miasma", "reconstitute", "quickassess", "ice_breath"}