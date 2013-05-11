echo("Afflictions loaded.")

entangled = false
writhing = false
writhed = false
plodding = false
idiocy = false

afflictedWithSomething = false
afflictedWithSomethingMental = false

-- Affliction tables.
afflictionTable = {
  -- Organ cures
  stupidity            = {name = "stupidity",               cure = "liver",                priority = 245, type = "organ", tree = true, focus = true, diag = "^unnaturally stupid.$"},
  paralysis            = {name = "paralysis",               cure = "lung",                 priority = 240, type = "organ", tree = true, diag = "^paralysed.$"},
  hypochondria         = {name = "hypochondria",            cure = "eyeball",              priority = 235, type = "organ", tree = true, diag = "^a certified hypochondriac.$"},
  confusion            = {name = "confusion",               cure = "bladder",              priority = 230, type = "organ", tree = true, focus = true, diag = "^confused.$"},
  clumsiness           = {name = "clumsiness",              cure = "eyeball",              priority = 225, type = "organ", tree = true, diag = "^afflicted with clumsiness.$"},
  limp_veins           = {name = "limp_veins",              cure = "eyeball",              priority = 220, type = "organ", tree = true, shrug = true, diag = "^full of limp veins.$"},
  epilepsy             = {name = "epilepsy",                cure = "liver",                priority = 215, type = "organ", tree = true, focus = true, diag = "^suffering from epilepsy.$"},
  sunlight_allergy     = {name = "sunlight_allergy",        cure = "ovary",                priority = 210, type = "organ", tree = true, diag = "^allergic to sunlight.$"},
  thin_blood           = {name = "thin_blood",              cure = "ovary",                priority = 205, type = "organ", tree = true, diag = "^afflicted by thin blood.$"},
  mental_disruption    = {name = "mental_disruption",       cure = "ovary",                priority = 205, type = "organ", diag = "^Your equilibrium has been disrupted.$"},
  physical_disruption  = {name = "physical_disruption",     cure = "ovary",                priority = 205, type = "organ", diag = "^Your balance has been disrupted.$"},
  recklessness         = {name = "recklessness",            cure = "testis",               priority = 200, type = "organ", tree = true, focus = true, diag = "^reckless.$"},
  berserking           = {name = "berserking",              cure = "testis",               priority = 199, type = "organ", tree = true, focus = true, diag = "^frothing at the mouth.$"},
  impatience           = {name = "impatience",              cure = "liver",                priority = 196, type = "organ", tree = true, diag = "^impatient.$"},
  sensitivity          = {name = "sensitivity",             cure = "eyeball",              priority = 195, type = "organ", tree = true, diag = "^sensitive to pain.$"},
  dissonance           = {name = "dissonance",              cure = "liver",                priority = 192, type = "organ", tree = true, diag = "^has a dissonant nature.$"},
  shyness              = {name = "shyness",                 cure = "liver",                priority = 190, type = "organ", tree = true, focus = true, diag = "^afflicted by unbearable shyness.$"},
  dizziness            = {name = "dizziness",               cure = "liver",                priority = 185, type = "organ", tree = true, focus = true, diag = "^overcome by dizziness.$"},
  masochism            = {name = "masochism",               cure = "testis",               priority = 180, type = "organ", tree = true, focus = true, diag = "^masochistic.$"},
  pacifism             = {name = "pacifism",                cure = "castorite",            priority = 175, type = "organ", tree = true, rage = true, diag = "^pacified.$"},
  peace                = {name = "peace",                   cure = "castorite",            priority = 170, type = "organ", tree = true, rage = true, diag = "^feeling unnaturally tranquil.$"},
  haemophilia          = {name = "haemophilia",             cure = "ovary",                priority = 165, type = "organ", tree = true, diag = "^afflicted by haemophilia.$"},
  hallucinations       = {name = "hallucinations",          cure = "bladder",              priority = 160, type = "organ", tree = true, focus = true, diag = "^hallucinating.$"},
  lovers_effect        = {name = "lovers_effect",           cure = "castorite",            priority = 155, type = "organ", tree = true, rage = true, diag = "^desperately in love with (%w+).$"},
  justice              = {name = "justice",                 cure = "castorite",            priority = 150, type = "organ", tree = true, rage = true, diag = "^surrounded by the aura of justice.$"},
  generosity           = {name = "generosity",              cure = "castorite",            priority = 145, type = "organ", tree = true, rage = true, diag = "^extremely generous.$"},
  lethargy             = {name = "lethargy",                cure = "ovary",                priority = 140, type = "organ", tree = true, diag = "^feeling rather lethargic.$"},
  vomiting             = {name = "vomiting",                cure = "ovary",                priority = 135, type = "organ", tree = true, diag = "^violently ill.$"},
  rend                 = {name = "rend",                    cure = "ovary",                priority = 135, type = "organ", diag = "^suffering shredded flesh.$"},
  wasting              = {name = "wasting",                 cure = "ovary",                priority = 135, type = "organ", diag = "^Afflicted with wasting.$"},
  mirroring            = {name = "mirroring",               cure = "lung",                 priority = 135, type = "organ", diag = "^cursed with mirrored attacks.$"},
  resonance            = {name = "resonance",               cure = "liver",                priority = 135, type = "organ", diag = "^resonating strangely.$"},
  soulfire             = {name = "soulfire",                cure = "castorite",            priority = 135, type = "organ", diag = "^Afflicted with soulfire.$"},
  superstition         = {name = "superstition",            cure = "castorite",            priority = 135, type = "organ", diag = "^superstitious of the abnormal.$"},
  weariness            = {name = "weariness",               cure = "eyeball",              priority = 130, type = "organ", tree = true, focus = true, diag = "^wearied in body.$"},
  hypersomnia          = {name = "hypersomnia",             cure = "bladder",              priority = 125, type = "organ", tree = true, focus = true, diag = "^hypersomnic.$"},
  paranoia             = {name = "paranoia",                cure = "bladder",              priority = 120, type = "organ", tree = true, diag = "^paranoid.$"},
  agoraphobia          = {name = "agoraphobia",             cure = "testis",               priority = 115, type = "organ", tree = true, focus = true, diag = "^agoraphobic.$"},
  claustrophobia       = {name = "claustrophobia",          cure = "testis",               priority = 110, type = "organ", tree = true, focus = true, diag = "^claustrophobic.$"},
  vertigo              = {name = "vertigo",                 cure = "testis",               priority = 105, type = "organ", tree = true, focus = true, diag = "^afraid of heights.$"},
  loneliness           = {name = "loneliness",              cure = "testis",               priority = 100, type = "organ", tree = true, focus = true, diag = "^very lonely.$"},
  blood_poisoning      = {name = "blood_poisoning",         cure = "eyeball",              priority = 95,  type = "organ", tree = true, diag = "^affected by a circulatory poison.$"},
  hatred               = {name = "hatred",                  cure = "bladder",              priority = 90,  type = "organ", tree = true, focus = true, diag = "^feeling intense hatred toward (%w+).$"},
  blood_curse          = {name = "blood_curse",             cure = "bladder",              priority = 85,  type = "organ", tree = true, diag = "^affected by a circulatory curse.$"},
  sandrot              = {name = "sandrot",                 cure = "lung",                 priority = 80,  type = "organ", tree = true, diag = "^cursed with rotting skin.$"},
  heartflutter         = {name = "heartflutter",            cure = "lung",                 priority = 75,  type = "organ", tree = true, diag = "^suffering an irregular heartbeat.$"},
  plodding             = {name = "plodding",                cure = "kidney",               priority = 70,  type = "organ", tree = true, diag = "^plodding with slow movement.$"},
  idiocy               = {name = "idiocy",                  cure = "kidney",               priority = 65,  type = "organ", tree = true, diag = "^afflicted with the mind power of an idiot.$"},
  dementia             = {name = "dementia",                cure = "bladder",              priority = 55,  type = "organ", tree = true, focus = true, diag = "^demented.$"},
  magic_impaired       = {name = "magic_impaired",          cure = "eyeball",              priority = 54,  type = "organ", tree = true, diag = "^magically impaired.$"},
  addiction            = {name = "addiction",               cure = "ovary",                priority = 50,  type = "organ", tree = true, diag = "^horribly addicted.$"},
  blindness            = {name = "blindness",               cure = "stomach",              priority = 45,  type = "organ", tree = true},
  deafness             = {name = "deafness",                cure = "heart",                priority = 40,  type = "organ", tree = true},
  selfpity             = {name = "self%-pity",              cure = "liver",                priority = 35,  type = "organ", tree = true, diag = "^full of self-pity.$"},
  hubris               = {name = "hubris",                  cure = "castorite",            priority = 30,  type = "organ", tree = true, rage = true, diag = "^full of overwhelming pride.$"},
  commitment_fear      = {name = "commitment_fear",         cure = "testis",               priority = 25,  type = "organ", tree = true, diag = "^fearful of commitment.$"},
  body_odor            = {name = "body_odor",               cure = "ovary",                priority = 20,  type = "organ", tree = true, diag = "^rank.$"},
  sadness              = {name = "sadness",                 cure = "bladder",              priority = 15,  type = "organ", tree = true, diag = "^somewhat unhappy.$"},
  baldness             = {name = "baldness",                cure = "eyeball",              priority = 10,  type = "organ", tree = true, diag = "^unnaturally bald.$"},
  noblind              = {name = "noblind",                 cure = "stomach",              priority = 9,   type = "organ"},
  nodeaf               = {name = "nodeaf",                  cure = "heart",                priority = 8,   type = "organ"},
  crippled_body        = {name = "crippled_body",           cure = "lung",                 priority = 6,   type = "organ", diag = "^crippled.$"},
  crippled             = {name = "crippled",                cure = "lung",                 priority = 6,   type = "organ", diag = "^suffering from crippled legs.$"},
  asthma               = {name = "asthma",                  cure = "eyeball",              priority = 5,   type = "organ", tree = true, shrug = true, diag = "^afflicted by horrible asthma.$"},

  -- Poultice cures.
  head_mangled         = {name = "head_mangled",            cure = "jecis to head",        priority = 81,  type = "poultice", diag = "^has a serious concussion.$"},
  head_damaged         = {name = "head_damaged",            cure = "jecis to head",        priority = 80,  type = "poultice", diag = "^has a partially damaged head.$"},
  indifference         = {name = "indifference",            cure = "oculi to head",        priority = 76,  type = "poultice", tree = true, diag = "^indifferent.$"},
  anorexia             = {name = "anorexia",                cure = "oculi to torso",       priority = 75,  type = "poultice", tree = true, focus = true, shrug = true, diag = "^anorexic.$"},
  mauled_face          = {name = "mauled_face",             cure = "jecis to head",        priority = 70,  type = "poultice", diag = "^unrecognizable due to a mauled face.$"},
  left_leg_amputated   = {name = "left_leg_amputated",      cure = "jecis to left leg",    priority = 75,  type = "poultice", diag = "^missing a left leg.$"},
  right_leg_amputated  = {name = "right_leg_amputated",     cure = "jecis to right leg",   priority = 75,  type = "poultice", diag = "^missing a right leg.$"},
  left_leg_mangled     = {name = "left_leg_mangled",        cure = "jecis to left leg",    priority = 74,  type = "poultice", diag = "^has a mangled left leg.$"},
  right_leg_mangled    = {name = "right_leg_mangled",       cure = "jecis to right leg",   priority = 74,  type = "poultice", diag = "^has a mangled right leg.$"},
  left_leg_damaged     = {name = "left_leg_damaged",        cure = "jecis to left leg",    priority = 73,  type = "poultice", diag = "^has a partially damaged left leg.$"},
  right_leg_damaged    = {name = "right_leg_damaged",       cure = "jecis to right leg",   priority = 73,  type = "poultice", diag = "^has a partially damaged right leg.$"},
  left_leg_broken      = {name = "left_leg_broken",         cure = "orbis to left leg",    priority = 72,  type = "poultice", tree = true, diag = "^afflicted by a crippled left leg.$"},
  right_leg_broken     = {name = "right_leg_broken",        cure = "orbis to right leg",   priority = 72,  type = "poultice", tree = true, diag = "^afflicted by a crippled right leg.$"},
  

  left_leg_bruised_critical  = {name = "left_leg_bruised_critical",  cure = "orbis to left leg",    priority = 72,  type = "poultice"},
  right_leg_bruised_critical = {name = "right_leg_bruised_critical", cure = "orbis to right leg",   priority = 72,  type = "poultice"},
  left_leg_bruised_moderate  = {name = "left_leg_bruised_moderate",  cure = "orbis to left leg",    priority = 72,  type = "poultice"},
  right_leg_bruised_moderate = {name = "right_leg_bruised_moderate", cure = "orbis to right leg",   priority = 72,  type = "poultice"},
  left_leg_bruised     = {name = "left_leg_bruised",        cure = "orbis to left leg",    priority = 72,  type = "poultice", diag = "^affected by a bruised left leg.$"},
  right_leg_bruised    = {name = "right_leg_bruised",       cure = "orbis to right leg",   priority = 72,  type = "poultice", diag = "^affected by a bruised right leg.$"},
  cracked_ribs         = {name = "cracked_ribs",            cure = "orbis to torso",       priority = 72,  type = "poultice", diag = "^suffering from a few cracked ribs.$"},
  crushed_chest        = {name = "crushed_chest",           cure = "jecis to torso",       priority = 73,  type = "poultice", diag = "^finding it hard to breathe due to a crushed chest.$"},
  crushed_kneecaps     = {name = "crushed_kneecaps",        cure = "orbis to legs",        priority = 72,  type = "poultice", diag = "^suffering from crushed kneecaps.$"},
  crushed_elbows       = {name = "crushed_elbows",          cure = "orbis to arms",        priority = 72,  type = "poultice", diag = "^suffering from crushed elbow joints.$"},
  destroyed_throat     = {name = "destroyed_throat",        cure = "orbis to head",        priority = 71,  type = "poultice", diag = "^suffering from a crushed throat.$"},
  
  torso_mangled        = {name = "torso_mangled",           cure = "jecis to torso",       priority = 72,  type = "poultice", diag = "^has serious internal trauma.$"},
  torso_damaged        = {name = "torso_damaged",           cure = "jecis to torso",       priority = 72,  type = "poultice", diag = "^has mild internal trauma.$"},
  torso_bruised_critical = {name = "torso_bruised_critical", cure = "orbis to torso",       priority = 71,  type = "poultice", diag = "^affected by a bruised torso.$"},
  head_bruised_critical  = {name = "head_bruised_critical",  cure = "orbis to head",        priority = 71,  type = "poultice", diag = "^affected by a bruised head.$"},
  torso_bruised_moderate = {name = "torso_bruised_moderate", cure = "orbis to torso",       priority = 71,  type = "poultice", diag = "^affected by a bruised torso.$"},
  head_bruised_moderate  = {name = "head_bruised_moderate",  cure = "orbis to head",        priority = 71,  type = "poultice", diag = "^affected by a bruised head.$"},
  torso_bruised        = {name = "torso_bruised",           cure = "orbis to torso",       priority = 71,  type = "poultice", diag = "^affected by a bruised torso.$"},
  head_bruised         = {name = "head_bruised",            cure = "orbis to head",        priority = 71,  type = "poultice", diag = "^affected by a bruised head.$"},
  right_arm_mangled    = {name = "right_arm_mangled",       cure = "jecis to right arm",   priority = 68,  type = "poultice", diag = "^has a mangled right arm.$"},
  left_arm_mangled     = {name = "left_arm_mangled",        cure = "jecis to left arm",    priority = 68,  type = "poultice", diag = "^has a mangled left arm.$"},
  left_arm_damaged     = {name = "left_arm_damaged",        cure = "jecis to left arm",    priority = 67,  type = "poultice", diag = "^has a partially damaged left arm.$"},
  right_arm_damaged    = {name = "right_arm_damaged",       cure = "jecis to right arm",   priority = 67,  type = "poultice", diag = "^has a partially damaged right arm.$"},
  left_arm_amputated   = {name = "left_arm_amputated",      cure = "jecis to left arm",    priority = 67,  type = "poultice", diag = "^missing a left arm.$"},
  right_arm_amputated  = {name = "right_arm_amputated",     cure = "jecis to right arm",   priority = 67,  type = "poultice", diag = "^missing a right arm.$"},
  right_arm_broken     = {name = "right_arm_broken",        cure = "orbis to right arm",   priority = 66,  type = "poultice", tree = true, diag = "^afflicted by a crippled right arm.$"},
  left_arm_broken      = {name = "left_arm_broken",         cure = "orbis to left arm",    priority = 66,  type = "poultice", tree = true, diag = "^afflicted by a crippled left arm.$"},

  left_arm_bruised_critical  = {name = "left_arm_bruised_critical",  cure = "orbis to left arm",    priority = 66,  type = "poultice"},
  right_arm_bruised_critical = {name = "right_arm_bruised_critical", cure = "orbis to right arm",   priority = 66,  type = "poultice"},
  left_arm_bruised_moderate  = {name = "left_arm_bruised_moderate",  cure = "orbis to left arm",    priority = 66,  type = "poultice"},
  right_arm_bruised_moderate = {name = "right_arm_bruised_moderate", cure = "orbis to right arm",   priority = 66,  type = "poultice"},
  left_arm_bruised     = {name = "left_arm_bruised",        cure = "orbis to left arm",    priority = 66,  type = "poultice", diag = "^affected by a bruised left arm.$"},
  right_arm_bruised    = {name = "right_arm_bruised",       cure = "orbis to right arm",   priority = 66,  type = "poultice", diag = "^affected by a bruised right arm.$"},
  spinal_rip           = {name = "spinal_rip",              cure = "jecis to torso",       priority = 62,  type = "poultice", diag = "^in agony with a ripped spine.$"},
  smashed_throat       = {name = "smashed_throat",          cure = "jecis to head",        priority = 62,  type = "poultice", diag = "^suffering from a damaged throat.$"},
  ablaze               = {name = "ablaze",                  cure = "orbis",                priority = 60,  type = "poultice", tree = true, diag = "^ablaze.$"},
  crippled_throat      = {name = "crippled_throat",         cure = "orbis to head",        priority = 59,  type = "poultice", tree = true, diag = "^afflicted by a crippled throat.$"},
  throatclaw           = {name = "throatclaw",              cure = "orbis to head",        priority = 58,  type = "poultice", tree = true, diag = "^lacking vocal cords.$"},
  frozen               = {name = "frozen",                  cure = "fumeae",               priority = 55,  type = "poultice", tree = true, diag = "^frozen stiff.$"},
  shivering            = {name = "shivering",               cure = "fumeae",               priority = 50,  type = "poultice", tree = true, diag = "^shivering.$"},
  needcaloric          = {name = "needcaloric",             cure = "fumeae",               priority = 49,  type = "poultice"},
  
  collapsed_lung       = {name = "collapsed_lung",          cure = "jecis to torso",       priority = 47,  type = "poultice", diag = "^having trouble breathing.$"},
  effused_blood        = {name = "effused_blood",           cure = "oculi",                priority = 45,  type = "poultice", tree = true, diag = "^being effused of blood.$"},
  effused_phlegm       = {name = "effused_phlegm",          cure = "oculi",                priority = 40,  type = "poultice", tree = true, diag = "^being effused of phlegm.$"},
  effused_yellowbile   = {name = "effused_yellowbile",      cure = "oculi",                priority = 35,  type = "poultice", tree = true, diag = "^being effused of yellow bile.$"},
  effused_blackbile    = {name = "effused_blackbile",       cure = "oculi",                priority = 30,  type = "poultice", tree = true, diag = "^being effused of black bile.$"},
  stuttering           = {name = "stuttering",              cure = "oculi to torso",       priority = 25,  type = "poultice", tree = true, diag = "^a stuttering fool.$"},
  nomass               = {name = "nomass",                  cure = "pueri",                priority = 20,  type = "poultice", tree = true},
  blurry_vision        = {name = "blurry_vision",           cure = "oculi",                priority = 10,  type = "poultice", tree = true, diag = "^confounded with blurry vision.$"},
  selarnia             = {name = "selarnia",                cure = "orbis",                priority = 5,   type = "poultice", tree = true, diag = "^losing the bond with the animal spirits.$"},
  burnt_eyes           = {name = "burnt_eyes",              cure = "oculi to head",        priority = 5,   type = "poultice", diag = "^fire-damaged eyes.$"},
  gorged               = {name = "gorged",                  cure = "oculi to torso",       priority = 5,   type = "poultice", diag = "^gorged.$"},
  
  -- Prerestore
  preresLeftLeg        = {name = "preresLeftLeg",           cure = "jecis to left leg",    priority = 7,   type = "poultice"},
  preresRightLeg       = {name = "preresRightLeg",          cure = "jecis to right leg",   priority = 6,   type = "poultice"},
  preresLeftArm        = {name = "preresLeftArm",           cure = "jecis to left arm",    priority = 5,   type = "poultice"},
  preresRightArm       = {name = "preresRightArm",          cure = "jecis to right arm",   priority = 4,   type = "poultice"},
  preresHead           = {name = "preresHead",              cure = "jecis to head",        priority = 3,   type = "poultice"},
  preresTorso          = {name = "preresTorso",             cure = "jecis to torso",       priority = 2,   type = "poultice"},

  -- Tincture cures.
  aeon                 = {name = "aeon",                    cure = "demulcent",            priority = 25,  type = "tincture", diag = "^afflicted with the curse of the Aeon.$"},
  slickness            = {name = "slickness",               cure = "antispasmadic",        priority = 24,  type = "tincture", tree = true, shrug = true, diag = "^extremely oily.$"},
  hellsight            = {name = "hellsight",               cure = "demulcent",            priority = 20,  type = "tincture", tree = true, diag = "^catching glimpses of Hell.$"},
  withering            = {name = "withering",               cure = "demulcent",            priority = 20,  type = "tincture", tree = true},
  disfigurement        = {name = "disfigurement",           cure = "antispasmadic",        priority = 15,  type = "tincture", tree = true, diag = "^inspiring disloyalty in those nearby.$"},
  disloyalty           = {name = "disloyalty",              cure = "antispasmadic",        priority = 10,  type = "tincture", tree = true},
  deadening            = {name = "deadening",               cure = "demulcent",            priority = 5,   type = "tincture", tree = true, focus = true, diag = "^of a deadened mind.$"},
  norebounding         = {name = "norebounding",            cure = "sudorific",            priority = 1,   type = "tincture"},

  -- Writhe afflictions
  writhe_impaled       = {name = "writhe_impaled",          cure = "writhe impale",        priority = 5,   type = "writhe", diag = "^impaled by (%w+).$"},
  writhe_necklock      = {name = "writhe_necklock",         cure = "writhe necklock",      priority = 5,   type = "writhe", diag = "^jawlocked by the neck.$"},
  writhe_armpitlock    = {name = "writhe_armpitlock",       cure = "writhe armpitlock",    priority = 5,   type = "writhe", diag = "^jawlocked by the armpit.$"},
  writhe_thighlock     = {name = "writhe_thighlock",        cure = "writhe thighlock",     priority = 5,   type = "writhe", diag = "^jawlocked by the thigh.$"},
  grappled             = {name = "grappled",                cure = "writhe grapple",       priority = 5,   type = "writhe", diag = "^grappling with Severn.$"},
  writhe_bind          = {name = "writhe_bind",             cure = "writhe",               priority = 0,   type = "writhe", diag = "^bound and tied.$"},
  writhe_ropes         = {name = "writhe_ropes",            cure = "writhe",               priority = 0,   type = "writhe", diag = "^entangled in ropes.$"},
  writhe_transfix      = {name = "writhe_transfix",         cure = "writhe",               priority = 0,   type = "writhe", diag = "^transfixed.$"},
  writhe_vines         = {name = "writhe_vines",            cure = "writhe",               priority = 0,   type = "writhe", diag = "^entangled by forest vines.$"},
  writhe_web           = {name = "writhe_web",              cure = "writhe",               priority = 0,   type = "writhe", diag = "^entangled.$"},
  writhe_cocoon        = {name = "writhe_cocoon",           cure = "break cocoon",         priority = 5,   type = "cocoon", diag = "^trapped in a sand cocoon.$"}, -- TODO: GET MESSAGES
  writhe_wheel         = {name = "writhe_wheel",            cure = "rip card",             priority = 5,   type = "writhe"}, -- TODO: GET MESSAGES
  writhe_quicksand     = {name = "writhe_quicksand",        cure = "writhe",               priority = 5,   type = "writhe"}, -- TODO: GET MESSAGES
  writhe_feed          = {name = "writhe_feed",             cure = "writhe",               priority = 5,   type = "writhe"},
  writhe_lure          = {name = "writhe_lure",             cure = "writhe",               priority = 5,   type = "writhe"},
  writhe_hangedman     = {name = "writhe_hangedman",        cure = "writhe",               priority = 5,   type = "writhe"},
  writhe_vine          = {name = "writhe_vine",             cure = "writhe",               priority = 5,   type = "writhe"},
  writhe_claws         = {name = "writhe_claws",            cure = "writhe",               priority = 5,   type = "writhe"},
  mob_impaled          = {name = "mob_impaled",             cure = "writhe",               priority = 5,   type = "writhe"},

  -- Misc afflictions that don't have cures or have odd cures
  void                 = {name = "void", type = "void", diag = "^within a shadowy void.$"},
  weakvoid             = {name = "weakvoid", type = "void",  diag = "^within a weakened, shadowy void.$"},
  stonevice            = {name = "stonevice", type = "stonevice", diag = "^suffering from a petrified gut.$"},

  blackout             = {name = "blackout", diag = "^devoid of senses.$"},
  soul_poison          = {name = "soul_poison", diag = "^suffering a poisoned soul.$"},
  soulroot             = {name = "soulroot", diag = "^Afflicted with soulroot.$"},
  disrupted            = {name = "disrupted", diag = "^disrupted.$"},
  voyria               = {name = "voyria", diag = "^suffering from voyria.$"},
  left_leg_numbed      = {name = "left_leg_numbed", diag = "^Your left leg is numb.$"},
  right_leg_numbed     = {name = "right_leg_numbed", diag = "^Your right leg is numb.$"},
  left_arm_numbed      = {name = "left_arm_numbed", diag = "^Your left arm is numb.$"},
  right_arm_numbed     = {name = "right_arm_numbed", diag = "^Your right arm is numb.$"},
  conviction           = {name = "conviction", diag = "^suffering the conviction of (%w+).$"},
  disturb_inhibition   = {name = "disturb_inhibition", diag = "^disturbed of inhibition.$"},
  disturb_sanity       = {name = "disturb_sanity", diag = "^disturbed of sanity.$"},
  disturb_confidence   = {name = "disturb_confidence", diag = "^disturbed of confidence.$"},
  disturb_impulse      = {name = "disturb_impulse", diag = "^disturbed of impulse.$"},
  edict_absorption     = {name = "edict_absorption", diag = "^Afflicted with edict_absorption.$"},
  edict_commandment    = {name = "edict_commandment", diag = "^Afflicted with edict_commandment.$"},
  edict_condemned      = {name = "edict_condemned", diag = "^Afflicted with edict_condemned.$"},
  edict_heretic        = {name = "edict_heretic", diag = "^Afflicted with edict_heretic.$"},
  edict_imprisonment   = {name = "edict_imprisonment", diag = "^Afflicted with edict_imprisonment.$"},
  edict_reckoning      = {name = "edict_reckoning", diag = "^Afflicted with edict_reckoning.$"},
  edict_shadowburn     = {name = "edict_shadowburn", diag = "^Afflicted with edict_shadowburn.$"},
  edict_stasis         = {name = "edict_stasis", diag = "^Afflicted with edict_stasis.$"},
  edict_weakening      = {name = "edict_weakening", diag = "^Afflicted with edict_weakening.$"},
  emberbrand           = {name = "emberbrand", diag = "^marked with the Brand of the Ember.$"},
  forestbrand          = {name = "forestbrand", diag = "^an enemy of the forests.$"},
  mental_fatigue       = {name = "mental_fatigue", diag = "^mentally fatigued.$"},
  mindclamped          = {name = "mindclamped", diag = "^mindclamped.$"},
  mistbrand            = {name = "mistbrand", diag = "^marked with the Brand of the Mist.$"},
  numb_arms            = {name = "numb_arms", diag = "^suffering from numb arms.$"},
  numbed_skin          = {name = "numbed_skin", diag = "^suffering from numbed skin.$"},
  oiled                = {name = "oiled", diag = "^Oiled.$"},
  omen                 = {name = "omen", diag = "^Afflicted with omen.$"},
  one_eye              = {name ="one-eye", diag = "^You have but a single eye.$"},
  penance              = {name = "penance", diag = "^suffering an imposed Penance.$"},
  petrified            = {name = "petrified", diag = "^petrified.$"},
  ripped_groin         = {name = "ripped_groin", diag = "^moving slowly due to a ripped groin.$"},
  ripped_spleen        = {name = "ripped_spleen", diag = "^unable to clot properly with such a spleen.$"},
  ripped_throat        = {name = "ripped_throat", diag = "^unfit due to a torn throat.$"},
  shadow_coat          = {name = "shadow_coat", diag = "^coated with foul shadows.$"},
  shadowbrand          = {name = "shadowbrand", diag = "^marked with the Brand of the Shadow.$"},
  spiritbrand          = {name = "spiritbrand", diag = "^marked with the Brand of the Spirit.$"},
  stonebrand           = {name = "stonebrand", diag = "^marked with the Brand of the Stone.$"},
  thorns               = {name = "thorns", diag = "^invaded by shadowy thorns.$"},
  troubled_breathing   = {name = "troubled_breathing", diag = "^having trouble breathing.$"},
  vinethorns           = {name = "vinethorns", diag = "^pricked by %d+ groups of thorns.$"}, -- TODO: Syntax to cure is PULL THORN FROM BODY.  Look into what this is.
  vitalbane            = {name = "vitalbane", diag = "^Afflicted with vitalbane.$"},

  something            = {name = "something", priority = 1, tree = true},
  someththingMental    = {name = "somethingMental", priority = 1, focus = true, tree = true},
}

diagnoseTriggers = {}
triggers.diagnoseTriggers = {}
function afflictionTablePrepare()
  for k,v in pairs(afflictionTable) do
    if type(v) == "table" and v.diag then
      table.insert(diagnoseTriggers, {pattern = v.diag, handler = function(p) afflictionAdd(v.name) end})
      table.insert(diagnoseTriggers, {pattern = "^afflicted with " .. v.name .. ".$", handler = function (p) afflictionAdd(v.name) end})
    end
  end
end
afflictionTablePrepare()

function addDiagnoseTriggers()
  for _, trigger in ipairs(diagnoseTriggers) do
    table.insert(triggers.diagnoseTriggers, trigger)
  end
end

function removeDiagnoseTriggers()
  triggers.diagnoseTriggers = {}  
end

triggers.afflictionTriggers = {
  {pattern = "You are afflicted with (.+)%.$", handler = function(p) afflictedHandler(p) end},
  {pattern = "You have cured (.+)%.$", handler = function(p) curedHandler(p) end},
  
  -- Diagnose triggers
  {pattern = "^You are:$", handler = function(p) checkForDiagnose() end},

  {pattern = "^You cannot seem to find a line in your limp peripheral veins.$", handler = function(p) afflictionAdd("limp_veins") end},
  {pattern = "^plodding with slow movement.", handler = function(p) if (diagnosed) then plodding = true end end},

  -- Triggers for when a limb QUITE isn't healed, yet.
  {pattern = "^You have restored your left arm as best as you can!$", handler = function(p) afflictionCure("left_arm_mangled") afflictionCure("left_arm_damaged") end},
  {pattern = "^You have restored your right arm as best as you can!$", handler = function(p) afflictionCure("right_arm_mangled") afflictionCure("right_arm_damaged") end},
  {pattern = "^You have restored your left leg as best as you can!$", handler = function(p) afflictionCure("left_leg_mangled") afflictionCure("left_leg_damaged") end},
  {pattern = "^You have restored your right leg as best as you can!$", handler = function(p) afflictionCure("right_leg_mangled") afflictionCure("right_leg_damaged") end},
  {pattern = "^You have restored your head as best as you can!$", handler = function(p) afflictionCure("head_mangled") afflictionCure("head_damaged") end},
  {pattern = "^You have restored your torso as best as you can!$", handler = function(p) afflictionCure("torso_mangled") afflictionCure("torso_damaged") end},
  
  -- Unconscious Triggers
  {pattern = "^Too late, you realize you are losing consciousness. The darkness", handler = function(p) setUncon() end},
  {pattern = "^You are unconscious and thus incapable of action.", handler = function(p) setUncon() end},
  {pattern = "^You regain consciousness with a start.", handler = function(p) removeUncon() end},
  
  -- Triggers for when you already have the affliction.
  -- {pattern = "You move sluggishly into action.", handler = function(p) afflictionAdd("aeon") end},
  {pattern = "The curse of the Aeon wears off and you return to the normal timestream.", handler = function(p) send("stick nervine") end},
  {pattern = "^You are too confused to concentrate properly.", handler = function(p) afflictionAdd("confusion") end},
  {pattern = "^You cannot contain the convulsions in your stomach any longer", handler = function(p) afflictionAdd("vomiting") end},
  {pattern = "^A wave of utter panic washes over you.", handler = function(p) send("compose") send("compose") end},
  {pattern = "^afflicted by fear.$", handler = function(p) send("compose") send("compose") end},
  {pattern = "^You don't feel like doing that right now.$", handler = function(p) afflictionAdd("indifference") end},
  {pattern = "^You cannot press the poultice due to the pangs within your limbs.", handler = function(p) afflictionAdd("sandrot") end},
  {pattern = "You have a particularly intense shiver.", handler = function(p) afflictionAdd("shivering") end},
  {pattern = "^You are paralysed and cannot do that.", handler = function(p) afflictionAdd("paralysis") end},
  {pattern = "^You are paralysed and unable to do that.", handler = function(p) afflictionAdd("paralysis") end},
  {pattern = "^You are paralysed and unable to move.", handler = function(p) afflictionAdd("paralysis") end},
  {pattern = "^Frustratingly, your body won't respond to your call to action.", handler = function(p) afflictionAdd("paralysis") end},
  {pattern = "^You are paralysed and are unable to drop anything.", handler = function(p) afflictionAdd("paralysis") end},
  {pattern = "The poultice slides off your oily skin, having no effect.", handler = function(p) afflictionAdd("slickness") end},
  {pattern = "^The salve just slides off your oily skin.", handler = function(p) afflictionAdd("slickness") end},
  {pattern = "^The bone marrow coating your body sloughs off, unable to stick to your unnaturally slick skin.$", handler = function(p) afflictionAdd("slickness") end},
  --{pattern = "You feel a bout of the shakes coming on.", handler = function(p) afflictionAdd("epilepsy") end},
  {pattern = "Your limbs begin to jerk and shake uncontrollably, and you begin to foam at the", handler = function(p) afflictionAdd("epilepsy") end},
  {pattern = "^Sunlight shines down upon you mercilessly, rippling across your", handler = function(p) afflictionAdd("sunlight_allergy") end},
  {pattern = "^You feel a bit more alert and awake.", handler = function(p) send("insomnia") end},
  {pattern = "You pound maniacally at %w+'s chest.", handler = function(p) afflictionAdd("berserking") end},
  {pattern = "^You lash out clumsily.$", handler = function(p) afflictionAdd("clumsiness") end},
  {pattern = "Screaming and spitting, you lash out with your fingers, trying to scratch", handler = function(p) afflictionAdd("berserking") end},
  {pattern = "^Justice is dealt out and your attack rebounds onto you.", handler = function(p) afflictionAdd("justice") end},
  {pattern = "^That needle will go so deep you will explode for sure!", handler = function(p) afflictionAdd("anorexia") end},
  {pattern = "^No! You cannot pierce yourself that deeply for fear of exploding like an", handler = function(p) afflictionAdd("anorexia") end},
  {pattern = "^Both of your legs are shriveled and thus you cannot carry out that action.$", handler = function(p) afflictionAdd("left_leg_broken") afflictionAdd("right_leg_broken") end},
  {pattern = "(%w+) glares at you, and your innards suddenly clench.", handler = function(p) echo("\n\n" .. C.B .. "[" .. C.R .. "YOU HAVE SOME TYPE OF EFFUSION" .. C.B .. "]\n\n" .. C.x) end},
  {pattern = "^Flames lick around you %- you are on fire!", handler = function(p) afflictionAdd("ablaze") end},
  {pattern = "^You cannot eat that! If you do you will explode!$", handler = function(p) afflictionAdd("anorexia") end},
  {pattern = "^The idea of putting something in your stomach sickens you.$", handler = function(p) afflictionAdd("anorexia") end},
  {pattern = "^You beam at the world as your legs dance a flurried jig.", handler = function(p) afflictionAdd("stupidity") end},
  {pattern = "^You flip the bird.", handler = function(p) afflictionAdd("stupidity") end},
  {pattern = "^Doing your best impression of a cow you go, \"Moooo!\"", handler = function(p) afflictionAdd("stupidity") end},
  {pattern = "^You waggle your eyebrows comically.", handler = function(p) afflictionAdd("stupidity") end},
  {pattern = "^You extend your poking finger.$", handler = function(p) afflictionAdd("stupidity") end},
  {pattern = "^You thump yourself on the forehead and exclaim, \"Duh!\"", handler = function(p) afflictionAdd("stupidity") end},
  {pattern = "^You stick your thumbs in your ears, waggle your fingers and whine,", handler = function(p) afflictionAdd("stupidity") end},
  {pattern = "^\"The voices! The voices! Get them out of my head!!\" you moan, while holding your", handler = function(p) afflictionAdd("stupidity") end},
  {pattern = "^You wobble back and forth unsure of your balance.", handler = function(p) afflictionAdd("stupidity") end},
  {pattern = "^You are too impatient to focus right now!$", handler = function(p) afflictionAdd("impatience") end},
  {pattern = "^Clap, clap, clap.$", handler = function(p) afflictionAdd("stupidity") end},
  {pattern = "^You scrunch up your face in an impish way as you snicker, \"Gnehehe!\"$", handler = function(p) afflictionAdd("stupidity") end},
  {pattern = "^You squint one eye and release a guttural \"Arr!\"$", handler = function(p) afflictionAdd("stupidity") end},
  {pattern = "^You shuffle your feet noisily, suddenly bored.$", handler = function(p) afflictionAdd("impatience") end},
  {pattern = "You improve but do not fully heal your loss of .*.", handler = function(p) curedEffusion() end},

  -- Voyria (Cyanide)
  {pattern = "^You begin feeling slightly flushed.", handler = function(p) addVoyria() end},
  {pattern = "^Blood begins to slowly drip from your nose.", handler = function(p) addVoyria() end},
  {pattern = "^You cough suddenly, expelling black fluid with bits of what looks *", handler = function(p) addVoyria() end},
  {pattern = "^Your legs tremble slightly as a yellow jaundice begins to *", handler = function(p) addVoyria() end},
  {pattern = "^The dark void of terror fills your mind as, horribly, *", handler = function(p) addVoyria() end},
  {pattern = "^suffering from voyria.", handler = function(p) if diagnosed then addVoyria() end end},
  {pattern = "^The venom burns through your veins, destroying the deadly *", handler = function(p) checkVoyriaCure() end},
  {pattern = "^The serum has no effect.", handler = function(p) checkVoyriaCure() end},
  {pattern = "^The burning in your veins ceases.$", handler = function(p) checkVoyriaCure() end},
  
  -- Asleep triggers
  {pattern = "You open your eyes and stretch languidly, feeling deliciously well%-rested.", handler = function(p) asleep = false send("insomnia") end},
  {pattern = "Your exhausted mind can stay awake no longer, and you fall into a deep sleep.", handler = function(p) asleep = true end},
  {pattern = "You close your eyes, curl up in a ball, and fall asleep.", handler = function(p) asleep = true end},
  {pattern = "You already are awake.", handler = function(p) asleep = false send("insomnia") end},
  {pattern = "You feel incredibly tired, and fall asleep immediately.", handler = function(p) asleep = true end},
  {pattern = "You open your eyes and yawn mightily.", handler = function(p) asleep = false send("insomnia") end},
  
  -- Other
  {pattern = "The deep howls of (%w+) cause your body to feel heavy and plodding.", handler = function(p) plodding = true end},
  {pattern = "^Your body feels free of its heaviness and plodding.", handler = function(p) plodding = false end},
  {pattern = "The dumbing howls of (%w+) reduce your mind to idiocy.", handler = function(p) idiocy = true end},
  {pattern = "^Your equilibrium is upset as the horrific gaze of a mummy startles you.", handler = function(p) send("concentrate") end},
  {pattern = "A feeling of comfortable warmth spreads over you.", handler = function(p) afflictionCure("shivering") afflictionCure("frozen") end},
  {pattern = "^The traumatic howls of (%w+) clear your mind.", handler = function(p) send("stand") end},
  {pattern = "^The disturbing howls of (%w+) make your mind wander.$", handler = function(p) send("concentrate") end},
  {pattern = "^You are already concentrating on regaining equilibrium.$", handler = function(p) killLine() end},
  
  {pattern = "^You see a bright light shine on you as all your afflictions are cured.", handler = function(p) afflictionList = {} end},
  
  -- Random afflictions
  {pattern = "^(%w+) strikes you with a dark bolt of energy directed through (%w+) mace.$", handler = function(p) randomAffliction() end},
  {pattern = "^(%w+) points a ring of pestilence at you.$", handler = function(p) randomAffliction() end},
  {pattern = "^%w+'s .* into a whip of sand and .* sends it to scourge you.$", handler = function(p) randomAffliction() end},
  {pattern = "^A filthy bubonis entity chitters at you.$", handler = function(p) randomAffliction() end},
  {pattern = "^Casting a puss-swollen hand towards you, (%w+) utters a gutteral series of chants", handler = function(p) randomAffliction() end},
  {pattern = "^One of (%w+)'s tongues flicks out towards you, a sharp whisper rolling off it", handler = function(p) randomAffliction() end},
  {pattern = "^With (%w+) deadly tail, (%w+) strikes out at you and stings you.$", handler = function(p) randomAffliction() end},
  {pattern = "^You are confused as to the effects of the venom.$", handler = function(p) randomAffliction() end},
  {pattern = "^You are jolted by the snarls of (%w+).$", handler = function(p) randomAffliction() end},
  {pattern = "^You summon spirits of fire to burn off that which afflicts you.$", handler = function(p) randomAffliction() end},
  {pattern = "^Your spirit writhes in torment under the glare of the angel.$", handler = function(p) randomAffliction() end},
  {pattern = "^The essence streaming from the floor heals your wounds.", handler = function(p) resetAfflictions() end},
  {pattern = "^%a+ pulls at your emotional well%-being.$", handler = function(p) randomAffliction() end},
  {pattern = "practiced flick of the wrist, .* sends it to whip your flesh painfully.", handler = function(p) randomAffliction() end},
  {pattern = "practiced flick of the wrist, you send it to whip yourself.$", handler = function(p) randomAffliction() end},
  --{pattern = "You touch the tree of life tattoo.$", handler = function(p) afflictionCure("something") end},
}

triggers.writheTriggers = {
  -- Feed
  {pattern = "reaches out and draws you close", handler = function(p) afflictionAdd("writhe_feed") end},
  {pattern = "you go limp as the pain intermingles with indescribable pleasure", handler = function(p) afflictionAdd("writhe_feed") end},
  {pattern = "Summoning your will, you writhe free of (%w+) agonizingly pleasurable", handler = function(p) afflictionCure("writhe_feed") end},
   
  -- Lure
  {pattern = "Feeling your mind suddenly grow cloudy, you feel inexplicably drawn towards", handler = function(p) afflictionAdd("writhe_lure") end},
  {pattern = "You must writhe free of the bonds that have overtaken your will.", handler = function(p) afflictionAdd("writhe_lure") end},
  {pattern = "You wrest your mind free of its unnatural attraction.", handler = function(p) afflictionCure("writhe_lure") end},
  {pattern = "You shake yourself and clear your head free of the luring effect.", handler = function(p) afflictionCure("writhe_lure") end},
   
  -- Hangedman
  {pattern = "A loop of rope entwines around you", handler = function(p) afflictionAdd("writhe_hangedman") end},
  {pattern = "Your legs are tangled in a mass of rope and you cannot move", handler = function(p) afflictionAdd("writhe_hangedman") end},
  {pattern = "(%w+) hurls a tarot card with the image of the Hanged Man on it at you.", handler = function(p) afflictionAdd("writhe_hangedman") end},
  {pattern = "You gasp and choke as you your entanglement impedes your breathing.", handler = function(p) afflictionAdd("writhe_hangedman") end},
  {pattern = "You have writhed free of your entanglement by ropes.", handler = function(p) afflictionCure("writhe_hangedman") end},
   
  -- Vines
  {pattern = "A choke creeper lashes out at you with a vine and wraps it tightly around you", handler = function(p) afflictionAdd("writhe_vines") end},
  {pattern = "A pair of vines suddenly lashes out from the undergrowth to entangle you!", handler = function(p) afflictionAdd("writhe_vines") end},
  {pattern = "You are too tangled up in vines to do that.", handler = function(p) afflictionAdd("writhe_vines") end},
  {pattern = "You have writhed free of your entanglement by vines", handler = function(p) afflictionCure("writhe_vines") end},
   
  -- Clawsk
  {pattern = "lifted you off your feet and carries you, kicking uselessly, in firm talons *", handler = function(p) afflictionAdd("writhe_claws") end},
  {pattern = "(%w+) suddenly releases his vice%-like grip on you.", handler = function(p) afflictionCure("writhe_claws") end},
  
  -- Quicksand
  {pattern = "With a hissed command from (%w+), the ground beneath your feet loses", handler = function(p) afflictionAdd("writhe_quicksand") end},
  {pattern = "The shifting sands consume their way higher upon your body, and a soft gurgle", handler = function(p) afflictionAdd("writhe_quicksand") end},
  {pattern = "Sucking sounds seep from the shifting sands as they creep precariously higher", handler = function(p) afflictionAdd("writhe_quicksand") end},
  {pattern = "Stuck steadfast in the sands, the watery grains flood your lungs as your head", handler = function(p) afflictionCure("writhe_quicksand") echo(C.B .. "(" .. C.R .. "You died, dumbass" .. C.B .. ")" .. C.x) end},
  {pattern = "You have writhed free of your imprisonment in the sinking sands.", handler = function(p) aflictionCure("writhe_quicksand") end},
  
  -- Cocoon
  {pattern = "^(%w+) waves an elegant crozier towards you and you are swiftly trapped within", handler = function(p) afflictionAdd("writhe_cocoon") end},
  {pattern = "^You must break free of the sand cocoon you are trapped in before", handler = function(p) afflictionAdd("writhe_cocoon") end},
  {pattern = "With a final burst of effort you shatter the cocoon, freeing yourself from", handler = function(p) afflictionCure("writhe_cocoon") breakingCocoon = false end},
  {pattern = "You are not trapped within a cocoon.", handler = function(p) afflictionCure("writhe_cocoon") end},
  
  -- Wheel Tarot
  {pattern = "^What is it you want to rip?$", handler = function(p) afflictionCure("writhe_wheel") end},
  
  -- Misc
  {pattern = "You begin to writhe helplessly, throwing your body off balance.", handler = function(p) resetWrithes() end},
  {pattern = "Sticky strands of webbing cling to you, making that impossible.", handler = function(p) afflictionAdd("writhe_web") end},

  -- Mob Impales
  {pattern = "A sharp limb lashes out from a ball of chitinous legs and pierces straight through your chest.", handler = function(p) afflictionAdd("mob_impaled") end},
  {pattern = "The creature beneath Tiyen Esityi lashes out with its smaller legs, each one tipped with a claw.", handler = function(p) afflictionAdd("mob_impaled") end},
  {pattern = "You have escaped your impalement by a ball of chitinous legs.", handler = function(p) afflictionCure("mob_impaled") end},
  {pattern = "You have escaped your impalement by the creature beneath Tiyen Esityi.", handler = function(p) afflictionCure("mob_impaled") end},
  {pattern = "With perfect form, Tirahl the Necromancer drops into a lunge and impales you through the gut.", handler = function(p) afflictionAdd("mob_impaled") end},
  {pattern = "You have escaped your impalement by Tirahl the Necromancer.", handler = function(p) afflictionCure("mob_impaled") end},
  {pattern = "Taking the weapon in both hands, Lieutenant Gharvoi rams his blade through you with a roar", handler = function(p) afflictionAdd("mob_impaled") end},
  {pattern = "You have escaped your impalement by Lieutenant Gharvoi.", handler = function(p) afflictionCure("mob_impaled") end},

  -- isWrithing()
  {pattern = "You begin to writhe furiously to escape the blade that has impaled you.", handler = function(p) isWrithing() end},
  {pattern = "You begin to trying to wrest your mind free of that which has transfixed it.", handler = function(p) isWrithing() end},
  {pattern = "You exert your will and attempt to writhe free of the vampire's embrace.", handler = function(p) isWrithing() end},
  {pattern = "You begin to writhe free from a stalagmite.", handler = function(p) isWrithing() end},
  {pattern = "You struggle for freedom from the stalagmite impaling you.", handler = function(p) isWrithing() end},
  {pattern = "You begin to wrestle the webs clinging to your limbs.", handler = function(p) isWrithing() end},
  {pattern = "You begin to twist your neck violently, trying to release it from the vicious", handler = function(p) isWrithing() end},
  {pattern = "You continue to work at freeing your neck.", handler = function(p) isWrithing() end},
  {pattern = "You begin to struggle free from your quicksand prison.", handler = function(p) isWrithing() end},
  {pattern = "You slowly wade closer to more stable ground.", handler = function(p) isWrithing() end},
  {pattern = "You concentrate intently, desperately seeking to throw off the unnatural", handler = function(p) isWrithing() end},
  {pattern = "You begin to struggle free of your entanglement.", handler = function(p) isWrithing() end},
  {pattern = "You try to wrest yourself from the strong claws gripping your shoulders.", handler = function(p) isWrithing() end},
  {pattern = "You continue trying to wrest your mind free.", handler = function(p) isWrithing() end},
  {pattern = "You wrestle unsuccessfully with the spike, remaining impaled upon it.", handler = function(p) isWrithing() end},
  {pattern = "You begin to untangle yourself from the forest vines.", handler = function(p) isWrithing() end},
  {pattern = "You begin to work at the knots in the ropes around your wrists and ankles.", handler = function(p) isWrithing() end},
  {pattern = "You begin to shake your leg violently, trying to release it from the vicious", handler = function(p) isWrithing() end},
  {pattern = "You begin to twist your arm violently, trying to release your armpit from the", handler = function(p) isWrithing() end},
  {pattern = "You continue to work at freeing your armpit.", handler = function(p) isWrithing() end},
  {pattern = "You begin trying to wrest your mind free of that which has transfixed it.", handler = function(p) isWrithing() end},
  {pattern = "You continue to work at freeing your leg.", handler = function(p) isWrithing() end},
  {pattern = "You begin struggling to break through the cocoon.", handler = function(p) breakingCocoon = true end},
  --Bashing isWrithing()
  {pattern = "You begin to writhe furiously to escape your impalement from a ball of chitinous legs.", handler = function(p) isWrithing() end},
  {pattern = "You struggle to escape from a ball of chitinous legs's impalement.", handler = function(p) isWrithing() end},
  {pattern = "You begin to writhe furiously to escape your impalement from the creature beneath Tiyen Esityi.", handler = function(p) isWrithing() end},
  {pattern = "You begin to writhe furiously to escape your impalement from Tirahl the Necromancer.", handler = function(p) isWrithing() end},
  {pattern = "You struggle to escape from Tirahl the Necromancer's impalement.", handler = function(p) isWrithing() end},
  {pattern = "You begin to writhe furiously to escape your impalement from Lieutenant Gharvoi.", handler = function(p) isWrithing() end},
  {pattern = "You struggle to escape from Lieutenant Gharvoi's impalement.", handler = function(p) isWrithing() end},
}

function hasAffliction(aff)
  hasaff = false
  if not afflictionList then return false end
  for k,v in pairs(afflictionList) do
    if v.name:match(aff) then hasaff = true end
  end
  return hasaff
end

function curedEffusion()
  afflictionCure("effused_phlegm")
  afflictionCure("effused_yellowbile")
  afflictionCure("effused_blackbile")
  afflictionCure("effused_blood")
end

function resetAfflictions()
  afflictionList = {}
  voyria = false
end

function randomAffliction()
  afflictionAdd("something")
end

function randomMentalAffliction()
  afflictionAdd("somethingMental")
end

function removeRandomAffliction()
  afflictionCure("something")
end

function affCheck()
  for k,v in pairs(afflictionList) do echo(v.name) end
end

function setUncon()
  unconscious = true
  extraLine = C.B .. " (" .. C.R .. "+++unconscious+++" .. C.B .. ")" .. C.x
end

function removeUncon()
  unconscious = false
  resetTimers()
  extraLine = C.B .. " (" .. C.G .. "---no longer unconscious---" .. C.B .. ")" .. C.x
end

function afflictedHandler(pattern)
  local tmp = mb.line:match(pattern)
  
  if tmp == "stun" then
    addStun()
  elseif tmp == "asleep" then
    asleep = true
  elseif tmp == "belonephobia" then
    afflictionAdd("anorexia")
  elseif tmp == "self-pity" then
    afflictionAdd("self%-pity")
  elseif tmp == "fear" then
    send("compose")
    send("compose")
  elseif tmp == "voyria" then
    voyria = true
  elseif tmp == "lover's_effect" then
    afflictionAdd("lovers_effect")
  elseif tmp == "petrified" then
    stunned = true
  elseif tmp == "disrupted" then
    send("concentrate")
    send("concentrate")
  else
    afflictionAdd(tmp)
  end
end

function curedHandler(pattern)
  local tmp = mb.line:match(pattern)
  if tmp == "stun" then
    removeStun()
  elseif tmp == "asleep" then
    alseep = false
  elseif tmp == "self-pity" then
    afflictionCure("self%-pity")
  elseif tmp == "voyria" then
    voyria = false
  elseif tmp == "lover's_effect" then
    afflictionCure("lovers")
  elseif tmp == "petrified" then
    stunned = false
  elseif tmp == "blackout" then
    recklesscheck = true
  else
    afflictionCure(tmp)
  end
  
  if tmp == "confusion" then
    send("concentrate")
    send("concentrate")
  end
end

function diagAfflictionHandler(aff)
  if (diagnosed) then afflictionAdd(aff) end
end

function addStun()
  stunned = true
  add_timer(2, function() if stunned then stunned = false end end)
  extraLine = C.B .. " (" .. C.R .. "+++stunned+++" .. C.B .. ")" .. C.x
end

function removeStun()
  stunned = false
  resetTimers()
  extraLine = C.B .. " (" .. C.G .. "---no longer stunned---" .. C.B .. ")" .. C.x
end

function resetTimers()
  focusing = false
  eaten = false
  eating = nil
  applied = false
  doingInject = false
  writhing = false
  injecting = nil
  stuck = false
  healthbalance = true
  sticking = nil
  atekidney = false
end

function checkForDiagnose()
  if diagnosing == true then
    addDiagnoseTriggers()
    onPrompt(function()
      removeDiagnoseTriggers()
    end)
    local hasHypo = hasAffliction("hypochondria")

    diagnosing = false
    diagnosed = true
    plodding = false
    afflictedWithSomething = false
    replace(C.G .. mb.line .. C.x)
    afflictionList = {}
    if hasHypo then afflictionAdd("hypochondria") end
  end
end

function addVoyria()
  voyria = true
  extraLine = extraLine .. C.B .. " (" .. C.R .. "+voyria" .. C.B .. ") " .. C.x
end

function checkVoyriaCure()
  if stickingCalmative then
    voyria = false
    stickingCalmative = false
    extraLine = extraLine .. C.B .. " (" .. C.G .. "-voyria" .. C.B .. ") " .. C.x
  end
end

 function isWrithing()
   writhing = false
   writhed = true
   suffix(C.B .. " (" .. C.G .. "writhing" .. C.B .. ")" .. C.x)
 end

function resetWrithes()
  afflictionCure("writhe_impaled")
  afflictionCure("writhe_necklock")
  afflictionCure("writhe_armpitlock")
  afflictionCure("writhe_thighlock")
  afflictionCure("grappled")
  afflictionCure("writhe_bind")
  afflictionCure("writhe_ropes")
  afflictionCure("writhe_transfix")
  afflictionCure("writhe_vines")
  afflictionCure("writhe_web")
  afflictionCure("writhe_cocoon")
  afflictionCure("writhe_feed")
  afflictionCure("writhe_quicksand")
  afflictionCure("writhe_lure")
  afflictionCure("writhe_hangedman")
  afflictionCure("writhe_vines")
  afflictionCure("writhe_claws")
  afflictionCure("mob_impaled")
  writhing = false
  writhed = false
end

function isEntangled()
  return hasAffliction("writhe_impaled") or
    hasAffliction("writhe_necklock") or
    hasAffliction("writhe_armpitlock") or
    hasAffliction("writhe_thighlock") or
    hasAffliction("grappled") or
    hasAffliction("writhe_bind") or
    hasAffliction("writhe_ropes") or
    hasAffliction("writhe_transfix") or
    hasAffliction("writhe_vines") or
    hasAffliction("writhe_web") or
    hasAffliction("writhe_cocoon") or
    hasAffliction("writhe_feed") or
    hasAffliction("writhe_quicksor") or
    hasAffliction("writhe_lure") or
    hasAffliction("writhe_hangedman") or
    hasAffliction("writhe_vines") or
    hasAffliction("writhe_claws") or
    hasAffliction("mob_impaled")
end
