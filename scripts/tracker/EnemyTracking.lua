echo("Enemy tracking loaded.")

etrack = {}
enemyAfflictions = {}
enemyLastCure = {}
eBalances = {
  herb = {name = "herb", balance = true, btime = 1.5}, 
  salve = {name = "salve", balance = true, btime = 1.0, restoreTime = 3.8},  
  smoke = {name = "smoke", balance = true, btime = 1.3}, 
  tree = {name = "tree", balance = true, btime = 9.5}, 
  focus = {name = "focus", balance = true, btime = 4.7}, 
}

ash_afflictions = { "sadness", "dementia", "hallucinations", "confusion", "paranoia", "hypersomnia", "hatred", "blood_curse", "blighted" }
goldenseal_afflictions = { "self-pity", "stupidity", "dizziness", "shyness", "epilepsy", "impatience", "resonance", "dissonance", "infested" }
kelp_afflictions = { "baldness", "clumsiness", "magic_impaired", "hypochondria", "weariness", "asthma", "sensitivity", "blood_poison" }
lobelia_afflictions = { "commitment_fear", "recklessness", "masochism", "agoraphobia", "loneliness", "vertigo", "claustrophobia", "berserking" }
ginseng_afflictions = { "body_odor", "haemophilia", "sunlight_allergy", "mental_disruption", "physical_disruption", "vomiting", "thin_blood", "lethargy", "addiction" }
bellwort_afflictions = { "hubris", "pacifism", "peace", "lover's_effect", "superstition", "generosity", "justice" }
bloodroot_afflictions = { "paralysis", "mirroring", "crippled_body", "crippled", "slickness", "heartflutter", "sandrot" }

epidermal_afflictions = { "anorexia", "gorge", "blood_effusion", "phlegm_effusion", "yellow_bile_effusion", "black_bile_effusion", "indifference", "stuttering", "blurry_vision" }
epidermal_torso_afflictions = {"anorexia", "stuttering"}

mending_affliction = {"right_leg_bruised_critical", "left_leg_bruised_critical", "right_arm_bruised_critical", "left_arm_bruised_critical", "torso_bruised_critical", "head_bruised_critical", "right_leg_broken", "left_leg_broken", "right_arm_broken", "left_arm_broken", "right_leg_bruised_moderate", "right_leg_bruised", "left_leg_bruised_moderate", "left_leg_bruised", "right_arm_bruised_moderate", "right_arm_bruised", "left_arm_bruised_moderate", "left_arm_bruised", "torso_bruised_moderate", "torso_bruised", "head_bruised_moderate", "head_bruised" ,"selarnia", "ablaze", "crippled_throat"}
mending_arms_afflictions = { "right_arm_bruised_critical", "left_arm_bruised_critical", "right_arm_broken", "left_arm_broken", "right_arm_bruised_moderate", "right_arm_bruised", "left_arm_bruised_moderate", "left_arm_bruised" }
mending_legs_afflictions = { "right_leg_bruised_critical", "left_leg_bruised_critical", "right_leg_broken", "left_leg_broken", "right_leg_bruised_moderate", "right_leg_bruised", "left_leg_bruised_moderate", "left_leg_bruised" }
mending_leftarm_afflictions = { "left_arm_bruised_critical", "left_arm_broken", "left_arm_bruised_moderate", "left_arm_bruised" }
mending_rightarm_afflictions = { "right_arm_bruised_critical", "right_arm_broken", "right_arm_bruised_moderate", "right_arm_bruised" }
mending_leftleg_afflictions = { "right_leg_bruised_critical", "right_leg_broken", "right_leg_bruised_moderate",  "right_leg_bruised" }
mending_rightleg_afflictions = { "left_leg_bruised_critical", "left_leg_broken", "left_leg_bruised_moderate", "left_leg_bruised" }
mending_head_afflictions = { "head_bruised_critical", "crippled_throat", "throatclaw", "head_bruised_moderate", "head_bruised" }
mending_torso_afflictions = {"torso_bruised_critical", "torso_bruised_moderate", "torso_bruised"}

caloric_afflictions = {"frozen", "shivering"}

elm_afflictions = { "aeon", "hellsight", "deadening" }
valerian_afflictions = {"slickness", "disfigurement"}
smoke_afflictions = { "aeon", "hellsight", "slickness", "disfigurement" }

focus_afflictions = {"stupidity", "anorexia", "epilepsy", "paranoia", "hallucinations", "shyness", "stuttering", "dizziness", "indifference", "berserking", "pacifism", "lover's_effect", "hatred", "generosity", "claustrophobia", "vertigo", "loneliness", "agoraphobia", "masochism", "recklessness", "weariness", "confusion", "dementia" }

enemyRebounding = false
enemyShielded = false
enemyBiteProtected = true


--Kaedin inhales deeply, filling his lungs with air.
triggers.etrackTriggers = {
  -- Eating
  {pattern = "^(%w+) eats (.*).$", handler = function(p) etrack:eatHandler(p) end},
  
  {pattern = "^(%w+) stiffens suddenly, (%w+) features frozen in a visage of agony.$", handler = function(p) etrack:darkshadeParalysisHandler(p) end},
  {pattern = "^(%w+) lets out a piercing scream, as if wounded by the very sunlight.$", handler = function(p) etrack:darkshadeTickHandler(p) end},
  {pattern = "^(%w+) doubles over, vomiting violently.$", handler = function(p) etrack:vomitHandler(p) end},
  {pattern = "^(%w+) shuffles %w+ feet in boredom.$", handler = function(p) etrack:impatienceHandler(p) end},
  
  -- Salve Applications
  {pattern = "^(%w+) takes a salve of (%w+) and rubs it on %w+ (.*).$", handler = function(p) etrack:enemySalveHandler(p) wounds:enemySalveHandler(p) end},
  {pattern = "^(%w+) takes %w+ (%w+) salve and rubs it on %w+ (.*).$", handler = function(p) etrack:enemySalveHandler(p) wounds:enemySalveHandler(p) end},
  {pattern = "^(%w+) presses %w+ (%w+) poultice against %w+ (.*), rubbing the poultice into %w+ flesh.$", handler = function(p) etrack:enemySalveHandler(p) wounds:enemySalveHandler(p) end},
  
  -- Inject/Smoke
  {pattern = "^(%w+) quickly injects (%w+) with a syringe filled with (%w+).$", handler = function(p) etrack:enemySmoked(p) end},
  {pattern = "^(%w+) takes a long drag off (%w+) pipe filled with (%w+).$", handler = function(p) etrack:enemySmoked(p) end},
  
  -- Focus
  {pattern = "^A look of extreme focus crosses the face of (%w+).$", handler = function(p) etrack:enemyFocusHandler(p) end},
  
  -- Discernment
  {pattern = "^You discern that (%w+) has cured the effects of (.*).$", handler = function(p) etrack:discernmentHandler(p) end},
  
  -- Fitness
  {pattern = "^(%w+) inhales deeply, filling (%w+) lungs with air.$", handler = function(p) etrack:fitnessHandler(p) end},
  
  -- Skills that afflict
  {pattern = "^Your whip afflicts (%w+) with (.*).$", handler = function(p) etrack:sandWhipHandler(p) end},
  {pattern = "^Your whip breaks (%w+)'s (%w+) (%w+).$", handler = function(p) etrack:sandWhipBodyHandler(p) end},
  {pattern = "^(%w+) gasps and staggers as a clay golem punches (%w+) hard in the chest.$", handler = function(p) etrack:heartpunchHandler(p) end},
  {pattern = "^A clay golem reaches out and seizes (%w+)'s (%w+) (%w+) in its powerful grip, pulling and twisting until the bone snaps.$", handler = function(p) etrack:sandWhipBodyHandler(p) end},
  {pattern = "^Horror overcomes (%w+)'s face as (%w+) body stiffens into paralysis.$", handler = function(p) etrack:enemyParalysedHandler(p) end},
  
  
  {pattern = "^You suddenly perceive the vague outline of an aura of rebounding around (%w+).$", handler = function(p) etrack:enemyReboundingUp(p) end},
  {pattern = "^(%w+)'s aura of weapons rebounding disappears.$", handler = function(p) etrack:enemyReboundingDown(p) end},
  {pattern = "^With a flick of your whip, you flay the aura of rebounding from (%w+).$", handler = function(p) etrack:enemyReboundingFlayed() end},
  {pattern = "^You raze %w+'s magical shield with .*%.", handler = function(p) etrack:shieldFlayed() end},
  {pattern = "^You raze %w+'s aura of rebounding with .*.$", handler = function(p) etrack:enemyReboundingFlayed() end},
  {pattern = "^You raze %w+'s speed defence with .*.$", handler = function(p) etrack:enemyReboundingFlayed() etrack:shieldFlayed() end},
  {pattern = "^White flames suddenly encase .* as your attack strikes %w+'s rebounding aura, burning the aura away.$", handler = function(p) etrack:enemyReboundingFlayed() end},
  
  {pattern = "^You flay the hard waxy coating from (%w+).$", handler = function(p) etrack:biteProtectionFlayed() end},
  {pattern = "^The bone marrow coating (%w+)'s body sloughs off, unable to stick to .* unnaturally slick skin.$", handler = function(p) etrack:biteProtectionSlickedOff(p) end},
  {pattern = "^A supple purple shell of berry juice has formed around (%w+).$", handler = function(p) etrack:enemyBiteProtected(p) end},
  {pattern = "^A thick, hardened shell of bone marrow has formed around (%w+).$", handler = function(p) etrack:enemyBiteProtected(p) end},
  {pattern = "^You send the tip of your whip to flay (%w+), but you find nothing to strip.$", handler = function(p) etrack:allFlayed() end},
  {pattern = "^You try to bite (%w+), but your fangs are stopped by an odd waxy coating.$", handler = function(p) etrack:enemyBiteProtected(p) end},
  
  {pattern = "^A nearly invisible magical shield forms around (%w+).$", handler = function(p) etrack:enemyIsShielded(p) end},
  {pattern = "^Several tormented souls swirl forth to encircle (%w+)'s form, protecting .* from harm.$", handler = function(p) etrack:enemyIsShielded(p) end},
  {pattern = "^With a flick of your whip, you flay the shield from (%w+).$", handler = function(p) etrack:shieldFlayed(p) end},
  {pattern = "^The protective shield around (%w+) dissipates.$", handler = function(p) etrack:enemyUnshielded(p) end},
  {pattern = "^A dizzying beam of energy strikes you as your attack rebounds off of (%w+)'s shield.$", handler = function(p) etrack:enemyIsShielded(p) end},
  {pattern = "^With a swift motion, you splice away (%w+)'s shield defence, and turn to strike with your other blade.$", handler = function(p) etrack:enemyUnshielded(p) end},
  {pattern = "^With a swift motion, you splice away (%w+)'s rebounding defence, and turn to strike with your other blade.$", handler = function(p) etrack:enemyReboundingFlayed() end},

    {pattern = "(%w+) steps into the attack on his (%w+), grabs your arm, and throws you violently to the ground.", handler = function(p) etrack:parriedHandler(p) end},
    {pattern = "(%w+) parries the attack on his (%w+) with a deft maneuver.", handler = function(p) etrack:parriedHandler(p) end},

    {pattern = "(Web): %w+ says, \"Afflicted (%w+): (%w+).\"", handler = function(p) etrack:webAfflictionAnnounceHandler(p) end},

    {pattern = "You whip .* through the air in front of (%w+), to no effect.", handler = function(p) etrack:allFlayed() end},
}

function etrack:webAfflictionAnnounceHandler(p)
    local person, affliction = mb.line:match(p)
    if isTarget(person) then
        etrack:addAff(string.lower(etrack:translate(affliction)))
    end
end



function etrack:darkshadeParalysisHandler(p)
  person = mb.line:match(p)
  if isTarget(person) then
    etrack:addAff("paralysis")
    etrack:addAff("sunlight_allergy")
  end
end

function etrack:darkshadeTickHandler(p)
  person = mb.line:match(p)
  if isTarget(person) then
    etrack:addAff("sunlight_allergy")
  end
end

function etrack:impatienceHandler(p)
  person = mb.line:match(p)
  if isTarget(person) then
    etrack:addAff("impatience")
  end
end

function etrack:vomitHandler(p)
  person = mb.line:match(p)
  if isTarget(person) then
    etrack:addAff("vomiting")
  end
end

function resetTargetVariables()
  toSuggest = {}
  suggested = {}
  if isClass("syssin") then hState = HypnoState.UNHYP end
  void = false
  enemyAfflictions = {}
end

function etrack:enemyParalysedHandler(p)
  person = mb.line:match(p)
  if isTarget(person) then
    etrack:addAff("paralysis")
  end
end

function etrack:discernmentHandler(p)
  person, aff = mb.line:match(p)
  if isTarget(person) then
    etrack:removeAff(etrack:translate(aff))
  end
end

function etrack:fitnessHandler(p)
  person = mb.line:match(p)
  if isTarget(person) then
    add_timer(1, function() etrack:removeAff("asthma") end)
  end
end

function etrack:heartpunchHandler(p)
  person, aff = mb.line:match(p)
  if isTarget(person) then
    etrack:addAff("heartflutter")
  end
end

function etrack:sandWhipHandler(p)
  person, aff = mb.line:match(p)
  etrack:addAff(etrack:translate(aff))
end

function etrack:sandWhipBodyHandler(p)
  person, side, limb = mb.line:match(p)
  tmp = side .. "_" .. limb .. "_broken"
  if isTarget(person) then etrack:addAff(etrack:translate(tmp)) end  
end






-- Aff tracking
function etrack:enemyCure(cure)
  for i,v in ipairs(cure) do
    if etrack:hasAff(cure[i]) then 
      etrack:removeAff(cure[i]) 
      enemyLastCured = cure[i] 
      break 
    end 
  end
end

function etrack:addAff(aff)
  if not etrack:hasAff(etrack:translate(aff)) and aff ~= "" then 
    table.insert(enemyAfflictions, aff) 
    ACSLabel(C.g .. "Enemy afflict with " .. C.G .. aff) 
  end
end

function etrack:hasAff(aff)
  for i,v in ipairs(enemyAfflictions) do
    if enemyAfflictions[i] == aff then return true end
  end
  return false
end

function etrack:removeAff(aff)
  for i,v in ipairs(enemyAfflictions) do
    if enemyAfflictions[i] == aff then table.remove(enemyAfflictions, i) ACSEcho(C.r .. "Enemy cured " .. C.R .. aff) break end
  end
end

function etrack:reset()
  enemyAfflictions = {}
end

function etrack:manualReset()
  etrack:reset()
  ACSEcho("Reset enemy afflictions")
end

-- Handlers
function etrack:enemySalveHandler(p)
  person, salve, area = mb.line:match(p)
  if isTarget(person) then
    etrack:enemySalveApplication(person, salve, area)
  end
end

function etrack:enemyPoulticeHandler(p)
  person, poultice, area = mb.line:match(p)
  if isTarget(person) then
    etrack:enemySalveApplication(person, poultice, area)
  end
end

function etrack:enemySalveApplication(person, salve, area)
  if isTarget(person) then
    gagLine()
    tmp = salve .. " to " .. area
    ACSEcho(C.r .. person .. " applied " .. C.R .. tmp .. C.r .. ".")
    --etrack:enemyCure(etrack:getCure(tmp))
    enemyLastCure = etrack:getCure(tmp)
    etrack:enemyCure(enemyLastCure)
    etrack:takeBal("salve", salve)
  end
end

function etrack:eatHandler(p)
  person, cure = mb.line:match(p)
  enemyLastCure = cure
  if person:match(target) then
    if etrack:hasAff("anorexia") then etrack:removeAff("anorexia") end 
    if cure:match("kidney") or cure:match("moss") then return end
    if eBalances.herb.balance then
      gagLine()
      ACSEcho(C.r .. person .. " ate " .. C.R .. cure .. C.r .. ".")
      enemyLastCure = etrack:getCure(cure)
      etrack:enemyCure(enemyLastCure)
      etrack:takeBal("herb")
    end
  end
end

function etrack:enemySmoked(p)
  person, _, cure = mb.line:match(p)
  if isTarget(person) then
    enemyLastCure = cure
    if eBalances.smoke.balance then
      gagLine()
      ACSEcho(C.R .. person .. " smoked/injected " .. C.R .. cure .. C.r .. ".")
      if etrack:hasAff("asthma") then etrack:removeAff("asthma") end 
      if cure:match("sudorific") or cure:match("skullcap") then 
        etrack:enemyReboundingStart() 
      else
        enemyLastCure = etrack:getCure(cure)
        etrack:enemyCure(enemyLastCure)
      end
      etrack:takeBal("smoke")
    end
  end
end

function etrack:enemyFocusHandler(p)
  person = mb.line:match(p)
  if isTarget(person) then
    gagLine()
    ACSEcho(C.R .. person .. " focused!")
    etrack:enemyCure(focus_afflictions)
    etrack:takeBal("focus")
  end
end

function enemyLimbCure(person, poultice, limb)
  curDamage = 0
  
  replace(acsLabel .. C.G .. person .. C.g .. " applied " .. C.G .. poultice .. C.g .. " to " .. C.G .. limb .. C.x)
  
  if poultice == "restoration" or poultice == "jecis" and not enemyRestorationApplied then
    enemyRestorationApplied = true
    checkForPreRestore(limb)
    add_timer(4, enemyRestorationTick, enemyRestoreationTickTimer, limb)
  end
end







-- Enemy Balance tracking
function etrack:takeBal(bal, extra)
  if extra == nil then extra = "" end
  
  for k,v in pairs(eBalances) do
    if v.name == bal then
      --ACSEcho("Enemy balance taken: " .. bal)
      eBalances[k].balance = false
      if extra:match("jecis") or extra:match("restoration") then
        add_timer(eBalances[k].restoreTime, function() etrack:giveBal(bal) end)
      else
        add_timer(eBalances[k].btime, function() etrack:giveBal(bal) end)
      end
    end
  end
end

function etrack:giveBal(bal)
  for k,v in pairs(eBalances) do
    if v.name == bal then
      ACSEcho(C.Y .. "Enemy balance back: " .. C.G .. bal)
      show_prompt()
      eBalances[k].balance = true
    end
  end
end







-- Helpers
function etrack:translate(aff)
  if aff:find("belonephobia") then return "anorexia"
  elseif aff:find("colocasia") then return "magic_impaired"
  elseif aff:find("magic impaired") then return "magic_impaired"
  elseif aff:find("limp_veins") or aff:find("limp veins") then return "asthma"
  elseif aff:find("shriveled throat") then return "crippled_throat"
  elseif aff:find("left leg") then return "left_leg_broken"
  elseif aff:find("right leg") then return "right_leg_broken"
  elseif aff:find("left arm") then return "left_arm_broken"
  elseif aff:find("right arm") then return "right_arm_broken"
  elseif aff:find("darkshade") then return "sunlight_allergy"
  elseif aff:find("sunlight allergy") then return "sunlight_allergy"
  elseif aff:find("heart flutter") then return "heartflutter"
  else return aff
  end
end

function etrack:getCure(cure)
  if cure:match("kelp") or cure:match("eyeball") then return kelp_afflictions 
  elseif cure:match("testis") or cure:match("lobelia") then return lobelia_afflictions
  elseif cure:match("bladder") or cure:match("ash") then return ash_afflictions
  elseif cure:match("liver") or cure:match("goldenseal") then return goldenseal_afflictions
  elseif cure:match("ovary") or cure:match("ginseng") then return ginseng_afflictions
  elseif cure:match("castorite") or cure:match("bellwort") then return bellwort_afflictions
  elseif cure:match("lung") or cure:match("bloodroot") then return bloodroot_afflictions
  
  elseif cure:match("demulcent") or cure:match("elm") then return elm_afflictions
  elseif cure:match("antispasmadic") or cure:match("valerian") then return valerian_afflictions
  
  elseif cure:match("oculi to torso") or cure:match("epidermal to torso") then return oculitorso_afflictions
  elseif cure:match("orbis to legs") or cure:match("mending to legs") then return mending_legs_afflictions
  elseif cure:match("orbis to arms") or cure:match("mending to arms") then return mending_arms_afflictions
  elseif cure:match("orbis to head") or cure:match("mending to head") then return mending_head_afflictions
  elseif cure:match("orbis to torso") or cure:match("mending to torso") then return mending_torso_afflictions
  elseif cure:match("orbis to left arm") or cure:match("mending to left arm") then return mending_leftarm_afflictions
  elseif cure:match("orbis to right arm") or cure:match("mending to right arm") then return mending_rightarm_afflictions
  elseif cure:match("orbis to left leg") or cure:match("mending to left leg") then return mending_leftleg_afflictions
  elseif cure:match("orbis to right arm") or cure:match("mending to right leg") then return mending_rightleg_afflictions
  elseif cure:match("oculi") or cure:match("epidermal") then return epidermal_afflictions
  elseif cure:match("orbis") or cure:match("mending") then return mending_afflictions
  elseif cure:match("orbis to body") or cure:match("mending to body") or cure:match("orbis to skin") or cure:match("mending to skin") then return mending_afflictions
  elseif cure:match("fumeae") or cure:match("caloric") then return caloric_afflictions
  else return {}
  end
end

function etrack:toxinConvert(toxin) return etrack:venomConvert(toxin) end
function etrack:venomConvert(venom)
  if venom == "aconite" then return "stupidity"
  elseif venom == "hepafarin" then return "haemophilia"
  elseif venom == "curare" then return "paralysis"
  elseif venom == "xentio" then return "clumsiness"
  elseif venom == "eurypteria" then return "recklessness"
  elseif venom == "kalmia" or venom == "strophanthus" then return "asthma"
  elseif venom == "digitalis" then return "shyness"
  elseif venom == "prefarar" and not enemyinfo:check("undeaf") then return "undeaf"
  elseif venom == "prefarar" and enemyinfo:check("undeaf") then return "sensitivity"
  elseif venom == "monkshood" then return "disfigurement"
  elseif venom == "euphorbia" then return "vomiting"
  elseif venom == "darkshade" then return "sunlight_allergy"
  elseif venom == "epseth" then
    if not etrack:hasAff("right_leg_broken") then
      return "right_leg_broken"
    elseif not etrack:hasAff("right_leg_broken") then
      return "left_leg_broken"
    end
  elseif venom == "epteth" then
    if not etrack:hasAff("left_arm_broken") then
      return "left_arm_broken"
    elseif not etrack:hasAff("right_arm_broken") then
      return "right_arm_broken"
    end
  elseif venom == "vernalius" then return "weariness"
  elseif venom == "larkspur" then return "dizziness"
  elseif venom == "voyria" then return "voyria"
  elseif venom == "araceae" or venom == "slike" then return "anorexia"
  elseif venom == "selarnia" then return "selarnia"
  elseif venom == "gecko" then return "slickness"
  elseif venom == "oculus" then return "unblind"
  elseif venom == "colocasia" then return "magic_impaired"
  elseif venom == "scytherus" then return "thin_blood"
  
  -- Overlay venoms
  elseif venom == "ataractis" then return "indifference"
  elseif venom == "bensol" then return "addiction"
  elseif venom == "cinchona" then return "vertigo"
  elseif venom == "emisis" then return "paranoia"
  elseif venom == "epinine" then return "agoraphobia"
  elseif venom == "fathyrus" then return "lethargy"
  elseif venom == "hystidine" then return "claustrophobia"
  elseif venom == "ionaziac" then return "epilepsy"
  elseif venom == "lithium" then return "pacifism"
  elseif venom == "mesqaline" then return "hallucinations"
  elseif venom == "muscaria" then return "berserking"
  elseif venom == "nyoclosia" then return "impatience"
  elseif venom == "peirates" then return "masochism"
  elseif venom == "quinidia" then return "haemophilia"
  elseif venom == "sepofan" then return "hypochondria"
  elseif venom == "sicari" then return "loneliness"
  elseif venom == "thallium" then return "dementia"
  elseif venom == "uranict" then return "generosity"
  elseif venom == "zepedic" then return "peace"
  
  -- Venoms that don't give a real affliction. Amnesia, random, damage, sleep, etc.
  elseif venom == "camus" or venom == "sumac" or venom == "loki" or venom == "delphinium" or venom == "domoin" then return ""
  end
end










-- Parry Stuff
function etrack:getParry()
  if self:hasAff("left_arm_broken") and self:hasAff("right_arm_broken") then return "" end

  if not self.parry then self.parry = "head" end

  return self.parry
end

function etrack:setParry(limb)
    self.parry = limb
end

function etrack:parriedHandler(p)
    local person, limb = mb.line:match(p)
    if isTarget(person) then
        self:setParry(limb)
    end
end



-- Shield, rebounding and Sileris
function etrack:enemyIsShielded(p)
  person = mb.line:match(p)
  if isTarget(person) then
    enemyShielded = true
    setACSLabel(C.R .. person .. C.r .." shielded!")
  end
end

function etrack:enemyBiteProtected(p)
  person = mb.line:match(p)
  if isTarget(person) then
    enemyBiteProtected = true
    setACSLabel(C.R .. person .. C.r .." protected from bites!")
  end
end

function etrack:allFlayed()
  if lastFlay == "rebounding" then
    enemyRebounding = false
    setACSLabel("FLAYED REBOUNDING!")
  elseif lastFlay == "shield" then
    enemyShielded = false
    setACSLabel("FLAYED SHIELD!")
  elseif lastFlay == "sileris" then
    enemyBiteProtected = false
    setACSLabel("FLAYED BITE PROTECT!")
  end
end

function etrack:biteProtectionSlickedOff(p)
  local person = mb.line:match(p)
  if person == target then
    etrack:biteProtectionFlayed()
  end
end

function etrack:biteProtectionFlayed()
  enemyBiteProtected = false
  setACSLabel(C.G .. target .. C.g .. " bite protection flayed!")
end

function etrack:biteProtectionFlayed()
  enemyBiteProtected = false
  enemySheidled = false
  enemyRebounding = false
  setACSLabel(C.G .. target .. C.g .. " flayed!")
end

function etrack:shieldFlayed()
  enemyShielded = false
  setACSLabel(C.G .. person .. C.g .." shield flayed!")
end

function etrack:enemyUnshielded(p)
  person = mb.line:match(p)
  if isTarget(person) then
    enemyShielded = true
    setACSLabel(C.G .. person .. C.g .." sheild disappeared!")
  end
end

function etrack:enemyReboundingUp(p)
  person = mb.line:match(p)
  if isTarget(person) then
    enemyRebounding = true
    setACSLabel(C.R .. person .. C.r .." rebounded!")
  end
end

function etrack:enemyReboundingDown(p)
  person = mb.line:match(p)
  if isTarget(person) then
    enemyRebounding = false
    setACSLabel(C.G .. person .. C.g .." not rebounded!")
  end
end

function etrack:enemyReboundingFlayed()
    enemyRebounding = false
    setACSLabel(C.G .. person .. C.g .." rebounding gone!")
end

function etrack:enemyReboundingStart()
  add_timer(5.75, function() enemyRebounding = true ACSEcho("Possible rebounding... Flagging.") end)
end