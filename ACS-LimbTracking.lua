echo("Limb tracker loaded")
lastTarget = ""
lastAttack = ""
limbChecking = ""
needPreres = ""
attack_parried = false
attack_diverted = false
attack_dodged = false

preres_left_leg = false
preres_right_leg = false
preres_left_arm = false
preres_right_arm = false
preres_torso = false
preres_head = false

enemyRestorationApplied = false

enemyIsLycan = false

-- Damage constants.  Change these if you find more accurate numbers
CLAW_DAMAGE = 6
CLAW_DAMAGE_DIVERT = 5
CLAW_DAMAGE_HARDEN = 4.5
CLAW_DAMAGE_HARDEN_DIVERT = 3

REND_DAMAGE = 3
REND_DAMAGE_DIVERT = 2
REND_DAMAGE_HARDEN = 2
REND_DAMAGE_HARDEN_DIVERT = 1

HEAD_DAMAGE = 11
HEAD_DAMAGE_DIVERT = 6
HEAD_DAMAGE_HARDEN = 6
HEAD_DAMAGE_HARDEN_DIVERT = 5

BODYPUNCH_DAMAGE = 5.5
BODYPUNCH_DAMAGE_DIVERT = 5
BODYPUNCH_DAMAGE_HARDEN = 4.3
BODYPUNCH_DAMAGE_HARDEN_DIVERT = 3.7

SPINALCRACK_DAMAGE = 8
SPINALCRACK_DAMAGE_DIVERT = 7
SPINALCRACK_DAMAGE_HARDEN = 6
SPINALCRACK_DAMAGE_HARDEN_DIVERT = 5

SHRED_DAMAGE = 15
SHRED_DAMAGE_DIVERT = 15
SHRED_DAMAGE_HARDEN = 11.5
SHRED_DAMAGE_HARDEN_DIVERT = 15

ELEMENTAL_DAMAGE = 5.5
ELEMENTAL_DAMAGE_DIVERT = 4
ELEMENTAL_DAMAGE_HARDEN = 3.75
ELEMENTAL_DAMAGE_HARDEN_DIVERT = 3

AXESLASH_DAMAGE = 5.5
AXESLASH_DAMAGE_DIVERT = 4
AXESLASH_DAMAGE_HARDEN = 3.75
AXESLASH_DAMAGE_HARDEN_DIVERT = 3

PRERESTORE_THRESHOLD = 15

enemyLimbs = {
  head = {name = "head", damage = 0, status = "unbroken"},
  torso = {name = "torso", damage = 0, status = "unbroken"},
  left_arm = {name = "left arm", damage = 0, status = "unbroken"},
  right_arm = {name = "right arm", damage = 0, status = "unbroken"},
  left_leg = {name = "left leg", damage = 0, status = "unbroken"},
  right_leg = {name = "right leg", damage = 0, status = "unbroken"},
}

myLimbs = {
  head = {name = "head", damage = 0, status = "unbroken", aff="preresHead"},
  torso = {name = "torso", damage = 0, status = "unbroken", aff="preresTorso"},
  left_arm = {name = "left arm", damage = 0, status = "unbroken", aff="preresLeftArm"},
  right_arm = {name = "right arm", damage = 0, status = "unbroken", aff="preresRightArm"},
  left_leg = {name = "left leg", damage = 0, status = "unbroken", aff="preresLeftLeg"},
  right_leg = {name = "right leg", damage = 0, status = "unbroken", aff="preresRightLeg"},
}

attacks = {
  shred = {name = "shred", hit = SHRED_DAMAGE, divert = SHRED_DAMAGE_DIVERT, harden = SHRED_DAMAGE_HARDEN, hardenDivert = SHRED_DAMAGE_HARDEN_DIVERT},
  elemental = {name = "elemental", hit = ELEMENTAL_DAMAGE, divert = ELEMENTAL_DAMAGE_DIVERT, harden = ELEMENTAL_DAMAGE_HARDEN, hardenDivert = ELEMENTAL_DAMAGE_HARDEN_DIVERT},
  claw = {name = "claw", hit = CLAW_DAMAGE, divert = CLAW_DAMAGE_DIVERT, harden = CLAW_DAMAGE_HARDEN, hardenDivert = CLAW_DAMAGE_HARDEN_DIVERT},
  rend = {name = "rend", hit = REND_DAMAGE, divert = REND_DAMAGE_DIVERT, harden = REND_DAMAGE_HARDEN, hardenDivert = REND_DAMAGE_HARDEN_DIVERT},
  hamstring = {name = "hamstring", hit = REND_DAMAGE, divert = REND_DAMAGE_DIVERT, harden = REND_DAMAGE_HARDEN, hardenDivert = REND_DAMAGE_HARDEN_DIVERT},
  skullwhack = {name = "skullwhack", hit = HEAD_DAMAGE, divert = HEAD_DAMAGE_DIVERT, harden = HEAD_DAMAGE_HARDEN, hardenDivert = HEAD_DAMAGE_HARDEN_DIVERT},
  jugularclaw = {name = "jugularclaw", hit = HEAD_DAMAGE, divert = HEAD_DAMAGE_DIVERT, harden = HEAD_DAMAGE_HARDEN, hardenDivert = HEAD_DAMAGE_HARDEN_DIVERT},
  bodypunch = {name = "bodypunch", hit = BODYPUNCH_DAMAGE, divert = BODYPUNCH_DAMAGE_DIVERT, harden = BODYPUNCH_DAMAGE_HARDEN, hardenDivert = BODYPUNCH_DAMAGE_HARDEN_DIVERT},
  spinalcrack = {name = "spinalcrack", hit = SPINALCRACK_DAMAGE, divert = SPINALCRACK_DAMAGE_DIVERT, harden = SPINALCRACK_DAMAGE_HARDEN, hardenDivert = SPINALCRACK_DAMAGE_HARDEN_DIVERT},
  destroy = {name = "destroy", hit = 10, divert = 10, harden = 8, hardenDivert = 8},
  mangle = {name = "mangle", hit = 0, divert = 0, harden = 0, hardenDivert = 0},
  axeslash = {name = "axeslash", hit = 5.5, divert = 4, harden = 3.75, hardenDivert = 3},
  macehit = {name = "macehit", hit = 6, divert = 5, harden = 5, hardenDivert = 3},
  slash = {name = "slash", hit = 7, divert = 5, harden = 5, harenDivert = 3},
}

triggers.limbTrackingTriggers = {
  -- Attacks
  {pattern = "^You spring forward lithely and lash at (%w+)'s left leg!$", handler = function(p) setLastAttack(p, "left leg", attacks.hamstring) end},
  {pattern = "^You spring forward lithely and lash at (%w+)'s right leg!$", handler = function(p) setLastAttack(p,"right leg", attacks.hamstring) end},
  {pattern = "^You tear at (%w+)'s left arm, awaiting the exhilirating snap of bone.$", handler = function(p) setLastAttack(p,"left arm", attacks.rend) end},
  {pattern = "^You tear at (%w+)'s right arm, awaiting the exhilirating snap of bone.$", handler = function(p) setLastAttack(p,"right arm", attacks.rend) end},
  {pattern = "^You crouch low and hurtle yourself into (%w+)'s midsection. (%w+) blinks groggily,$", handler = function(p) setLastAttack(p,"torso", attacks.bodypunch) end},
  {pattern = "^stunned.$", handler = function(p) gagLine() end},
  {pattern = "^You rear up and bring your claws into the base of (%w+)'s skull!$", handler = function(p) setLastAttack(p,"head", attacks.skullwhack) end},
  {pattern = "^You spy (%w+)'s jugular exposed and lunge to claw open the throbbing vessel.$", handler = function(p) setLastAttack(p,"head", attacks.jugularclaw) end},
  {pattern = "^You rush and leap headlong into (%w+)'s spine and hear a satisfying crack!$", handler = function(p) setLastAttack(p,"torso", attacks.spinalcrack) end},
  {pattern = "^A snarl twists your lips as you claw at (%w+)'s left leg.$", handler = function(p) setLastAttack(p,"left leg", attacks.claw) end},
  {pattern = "^A snarl twists your lips as you claw at (%w+)'s right leg.$", handler = function(p) setLastAttack(p,"right leg", attacks.claw) end},
  {pattern = "^A snarl twists your lips as you claw at (%w+)'s left arm.$", handler = function(p) setLastAttack(p,"left arm", attacks.claw) end},
  {pattern = "^A snarl twists your lips as you claw at (%w+)'s right arm.$", handler = function(p) setLastAttack(p,"right arm", attacks.claw) end},
  {pattern = "^You claw and bite at (%w+)'s left leg until it is merely a lump of bone", handler = function(p) setLastAttack(p,"left leg", attacks.mangle) end},
  {pattern = "^You claw and bite at (%w+)'s right leg until it is merely a lump of bone", handler = function(p) setLastAttack(p,"right leg", attacks.mangle) end},
  {pattern = "^You claw and bite at (%w+)'s left arm until it is merely a lump of bone", handler = function(p) setLastAttack(p,"left arm", attacks.mangle) end},
  {pattern = "^You claw and bite at (%w+)'s right arm until it is merely a lump of bone", handler = function(p) setLastAttack(p, "right leg", attacks.mangle) end},
  {pattern = "meat.$", handler = function(p) gagLine() end},
  {pattern = "^You sever (%w+)'s left leg and chew it beyond recognition.", handler = function(p) setLastAttack(p, "left leg", attacks.destroy) end},
  {pattern = "^You sever (%w+)'s right leg and chew it beyond recognition.", handler = function(p) setLastAttack(p, "right leg", attacks.destroy) end},
  {pattern = "^You sever (%w+)'s left arm and chew it beyond recognition.", handler = function(p) setLastAttack(p, "left arm", attacks.destroy) end},
  {pattern = "^You sever (%w+)'s right arm and chew it beyond recognition.", handler = function(p) setLastAttack(p, "right arm", attacks.destroy) end},
  
  -- Shred
  {pattern = "^You focus the sands on (%w+)'s right leg.", handler = function(p) setLastAttack(p, "right leg", attacks.shred) end},
  {pattern = "^You focus the sands on (%w+)'s left leg.", handler = function(p) setLastAttack(p, "left leg", attacks.shred) end},
  {pattern = "^You focus the sands on (%w+)'s right arm.", handler = function(p) setLastAttack(p, "right arm", attacks.shred) end},
  {pattern = "^You focus the sands on (%w+)'s left arm.", handler = function(p) setLastAttack(p, "left arm", attacks.shred) end},
  {pattern = "^You focus the sands on (%w+)'s head.", handler = function(p) setLastAttack(p, "head", attacks.shred) end},
  {pattern = "^You focus the sands on (%w+)'s torso.", handler = function(p) setLastAttack(p, "torso", attacks.shred) end},
  
  -- Elemental
  --With a powerful strike, an earthen elemental slams a fist into your left leg.
  --striking your right leg painfully before the elemental disperses
  
  -- Miss/hit messages
  {pattern = "^You rake (%w+), delighting in (%w+) whimper of pain.$", handler = function(p) attackHit() end},
  {pattern = "^You nimbly smack into (%w+) with your paw, cuffing (%w+).$", handler = function(p) attackHit() end},
  {pattern = "^You tear open long lacerations with your wicked claws.$", handler = function(p) attackHit() end},
  {pattern = "^(%w+) jerks to the side, the attack barely grazing (%w+).$", handler = function(p) attackDiverted() end},
  {pattern = "^Stepping quickly out of the way, (%w+) dodges the attack.$", handler = function(p) attackDodged() end},
  {pattern = "^(%w+) parries the attack on (%w+) (%w+) with a deft maneuver.", handler = function(p) attackParried(p) end},
  {pattern = "^(%w+) parries the attack on (%w+) (%w+) (%w+) with a deft maneuver.", handler = function(p) attackParried(p) end},
  
  -- Bandage applications
  {pattern = "^(%w+) presses (%w+) (%w+) poultice against (%w+) (%w+) (%w+), rubbing the poultice", handler = function(p) enemyPoulticeDirectlyApplied(p) end},
  --{pattern = "^flesh%.$", handler = function(p) gagLine() end},
  --{pattern = "^(%w+) flesh%.$", handler = function(p) gagLine() end},
  --{pattern = "^into (%w+) flesh%.$", handler = function(p) gagLine() end},
  {pattern = "^(%w+) presses (%w+) (%w+) poultice against (%w+) (%w+), rubbing the poultice", handler = function(p) enemyPoulticeGenerallyApplied(p) end},
  
  -- Salve applications
  {pattern = "^(%w+) takes a salve of (%w+) and rubs it on (%w+) (%w+) (%w+).$", handler = function(p) enemySalveDirectlyApplied(p) end},
  {pattern = "^(%w+) takes a salve of (%w+) and rubs it on (%w+) (%w+).$", handler = function(p) enemySalveGenerallyApplied(p) end},
  
  -- Wound checking
  {pattern = "^You take a moment to assess how damaged (%w+)'s limbs are.$", handler = function(p) enemyWoundCheck = "target" end},
  {pattern = "^You take a moment to assess how damaged your limbs are.$", handler = function(p) selfWoundCheck = "me" end},
  {pattern = "^(%w+):(%s+)(%d+)%% %((%w+) bruising%)$", handler = function(p) woundCheck(p) end},
  {pattern = "^(%w+) (%w+):(%s+)(%d+)%% %((%w+) bruising%)$", handler = function(p) woundCheck2(p) end},
  
  -- Prerestore stuff
  {pattern = "^You have restored your left leg as best as you can!$", handler = function(p) preresComplete("left leg") end},
  {pattern = "^You have restored your left arm as best as you can!$", handler = function(p) preresComplete("left arm") end},
  {pattern = "^You have restored your right leg as best as you can!$", handler = function(p) preresComplete("right leg") end},
  {pattern = "^You have restored your right arm as best as you can!$", handler = function(p) preresComplete("right arm") end},
  {pattern = "^You have restored your torso as best as you can!$", handler = function(p) preresComplete("torso") end},
  {pattern = "^You have restored your head as best as you can!$", handler = function(p) preresComplete("head") end},
  
  -- Attacks on you.
  --- Shred.
  {pattern = "^The sands seem to be focused upon your (.*).$", handler = function(p) enemyShredHandler(p) end},
  
  {pattern = "^(%w+) slashes at you, eyeing your (.*) hungrily.$", handler = function(p) enemySlashHandler(p) end},
  
  {pattern = "^(%w+) crouches low and hurtles (%w+) into your midsection. You blink groggily, stunned.$", handler = function(p) addLimbDamageToMe("torso", attacks.bodypunch) end},
  {pattern = "^(%w+) leaps headlong into your spine! You hear a sickening crack and a", handler = function(p) addLimbDamageToMe("torso", attacks.spinalcrack) end},
  {pattern = "^(%w+) pants with exhilaration and tears at your (.*).$", handler = function(p) enemyRendHandler(p) end},
  {pattern = "^(%w+) raises up (%w+) mace to smash your (.*)\.$", handler = function(p) enemyMaceSmashHandler(p) end},
  {pattern = "^(%w+) rears up behind you and there is a sharp pain at the base of your skull!$", handler = function(p) addLimbDamageToMe("head", attacks.skullwhack) end},
  {pattern = "^(%w+) spies an opening and lunges to claw open your jugular!$", handler = function(p) addLimbDamageToMe("head", attacks.jugularclaw) end},
  {pattern = "^(%w+) springs forward lithely and lashes at your (.*)!$", handler = function(p) enemyHamstringHandler(p) end},
  {pattern = "^A snarl twists (%w+)'s lips as (%w+) claws at your (.*).$", handler = function(p) enemyClawHandler(p) end},
  {pattern = "^With careful aim (%w+) smashes (%w+) mace into your (*) before swiftly slamming a buckler into your (*).$", handler = function(p) enemyLuminaryHitsHandler(p) end},
  
  --- Axe slash
  {pattern = "^(%w+) slashes into your (.*) with (.*).$", handler = function(p) enemyAxeSlashHandler(p) end},
  {pattern = "^Lightning%-quick, (%w+) jabs your (.*) with (.*).$", handler = function(p) enemyAxeSlashHandler(p) end},
  {pattern = "^(%w+) swings (.*) at your (.*) with all his might.$", handler = function(p) enemyAxeSlashHandler2(p) end},
  
  -- Sand Elementals
  {pattern = "^With a powerful strike, an earthen elemental slams a fist into (%w+)'s (.*).", handler = function(p) elementalHandler1(p) end},
  {pattern = "^An earthen elemental raises a fist toward (%w+) and a large rock erupts from its hand, striking (%w+) (.*) with", handler = function(p) elementalHandler2(p) end},
  {pattern = "^With a powerful strike, an earthen elemental slams a fist into your (.*)", handler = function(p) enemyElementalHandler(p) end},
  {pattern = "^An earthen elemental raises a fist toward you and a large rock erupts from its hand, striking your (.*) painfully", handler = function(p) enemyElementalHandler(p) end},
}

aliases.limbTrackingAliases = {
  {pattern = "^limbs$", handler = function(i,p) showEnemyLimbs() end},
  {pattern = "^rlimbs$", handler = function(i,p) resetEnemyLimbs() end},
}

function enemyElementalHandler(p)
  limb = mb.line:match(p)
  addLimbDamageToMe(limb, attacks.elemental)
  gagLine()
  for k,v in pairs(myLimbs) do if myLimbs[k].name == limb then tmp = myLimbs[k].damage end end
  ACSEcho(C.r .. "Elemental hit your " .. C.R .. limb .. C.r .. " <-- " .. C.g .. tmp)
end

function elementalHandler1(p)
  person, limb = mb.line:match(p)
  elementalHandler(p, person, limb)
end

function elementalHandler2(p)
  person, _, limb = mb.line:match(p)
  elementalHandler(p, person, limb)
end

function elementalHandler(p, person, limb)
  if isTarget(person) then
    setLastAttack(p, limb, attacks.elemental)
    calculateLimbDamage()
  end
end

function enemyPoulticeDirectlyApplied(pattern)
  person, _, poultice, _, side, appendage = mb.line:match(pattern)
  limb = side .. " " .. appendage
  
  if string.lower(person) == string.lower(target) then
    enemyLimbCure(person, poultice, limb)
  end
end

function enemyPoulticeGenerallyApplied(pattern)
  person, _, poultice, _, area = mb.line:match(pattern)
  
  if string.lower(person) == string.lower(target) then
    enemyLimbCure(person, poultice, area)
  end
end

function enemySalveDirectlyApplied(pattern)
  person, salve, _, side, appendage = mb.line:match(pattern)
  limb = side .. " " .. appendage
  
  if string.lower(person) == string.lower(target) then
    enemyLimbCure(person, salve, limb)
  end
end

function enemySalveGenerallyApplied(pattern)
  person, salve, _, area = mb.line:match(pattern)
  
  if string.lower(person) == string.lower(target) then
    enemyLimbCure(person, salve, area)
  end
end

function enemySlashHandler(p)
  _, limb = mb.line:match(p)
  addLimbDamageToMe(limb, attacks.slash)
end

function enemyAxeSlashHandler(p)
  _, limb = mb.line:match(p)
  addLimbDamageToMe(limb, attacks.axeslash)
end

function enemyAxeSlashHandler2(p)
  _, _, limb = mb.line:match(p)
  addLimbDamageToMe(limb, attacks.axeslash)
end

function enemyLuminaryHitsHandler(p)
  _, _, limb1, limb2 = mb.line:match(p)
  addLimbDamageToMe(limb1, attacks.macehit)
  addLimbDamageToMe(limb2, attacks.macehit)
end

function enemyClawHandler(p)
  _, _, limb = mb.line:match(p)
  addLimbDamageToMe(limb, attacks.claw)
end

function enemyMaceSmashHandler(p)
  _, _, limb = mb.line:match(p)
  addLimbDamageToMe(limb, attacks.maceshit)
end

function enemyShredHandler(p)
  limb = mb.line:match(p)
  addLimbDamageToMe(limb, attacks.shred)
end

function enemyRendHandler(p)
  _, limb = mb.line:match(p)
  addLimbDamageToMe(limb, attacks.rend)
end

function enemyHamstringHandler(p)
  _, limb = mb.line:match(p)
  addLimbDamageToMe(limb, attacks.rend)
end

function addLimbDamageToMe(limb, attack)
  damage = checkMyDamage(attack)
  for k,v in pairs(myLimbs) do
    if myLimbs[k].name == limb then
      myLimbs[k].damage = myLimbs[k].damage + damage
      replace(mb.line .. " <-- " .. myLimbs[k].damage)
    end
  end
  checkForPreres()
end

function checkMyDamage(a)
  if hasDefense("harden") then
    return a.harden
  else
    return a.hit
  end
end

function checkForPreres()
  resetPreres()
  
  if checkPre(myLimbs.left_leg.damage) then
    preres_left_leg = true
  end
  if checkPre(myLimbs.right_leg.damage) then
    preres_right_leg = true
  end
  if checkPre(myLimbs.left_arm.damage) then
    preres_left_arm = true
  end
  if checkPre(myLimbs.right_arm.damage) then
    preres_right_arm = true
  end
  if checkPre(myLimbs.head.damage) then
    preres_head = true
  end
  if checkPre(myLimbs.torso.damage) then
    preres_torso = true
  end
  
  if preres_left_leg and not hasAffliction("preresLeftLeg") then afflictionAdd("preresLeftLeg") end
  if preres_right_leg and not hasAffliction("preresRightLeg") then afflictionAdd("preresRightLeg") end
  if preres_left_arm and not hasAffliction("preresLeftArm") then afflictionAdd("preresLeftArm") end
  if preres_right_arm and not hasAffliction("preresRightArm") then afflictionAdd("preresRightArm") end
  if preres_torso and not hasAffliction("preresTorso") then afflictionAdd("preresTorso") end
  if preres_head and not hasAffliction("preresHead") then afflictionAdd("preresHead") end
end

function checkLimbDamageAfterRestoration()
  if applying ~= nil and applying:match("jecis") then 
    if applying:match("^jecis to (%w+) (%w+)$") then 
      limb1, limb2 = applying:match("^jecis to (%w+) (%w+)$")
      limb = limb1 .. " " .. limb2 
    elseif applying:match("^jecis to (%w+)$") then 
      limb = applying:match("^restoration to (%w+)$") 
    end
    
    preresComplete(limb)
  end
end

function checkPre(limbAmt)
  return limbAmt >= PRERESTORE_THRESHOLD
end

function resetPreres()
  preres_left_leg = false
  preres_right_leg = false
  preres_left_arm = false
  preres_right_arm = false
  preres_torso = false
  preres_head = false
end

function preresComplete(limb)
  for k,v in pairs(myLimbs) do
    if myLimbs[k].name == limb then
      myLimbs[k].damage = myLimbs[k].damage - 33
      if myLimbs[k].damage < 0 then myLimbs[k].damage = 0 end
      afflictionCure(myLimbs[k].aff)
    end
  end
end

function showEnemyLimbs()
  echo("\nHead:\t" .. tostring(enemyLimbs.head.damage) .. "\tTorso:\t" .. tostring(enemyLimbs.torso.damage))
  echo("L. Arm:\t" .. tostring(enemyLimbs.left_arm.damage) .. "\tR. Arm:\t" .. tostring(enemyLimbs.right_arm.damage))
  echo("L. Leg:\t" .. tostring(enemyLimbs.left_leg.damage) .. "\tR. Leg:\t" .. tostring(enemyLimbs.right_leg.damage))
end

function showMyLimbs()
  echo("\nHead:\t" .. tostring(myLimbs.head.damage) .. "\tTorso:\t" .. tostring(myLimbs.torso.damage))
  echo("L. Arm:\t" .. tostring(myLimbs.left_arm.damage) .. "\tR. Arm:\t" .. tostring(myLimbs.right_arm.damage))
  echo("L. Leg:\t" .. tostring(myLimbs.left_leg.damage) .. "\tR. Leg:\t" .. tostring(myLimbs.right_leg.damage))
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

function enemyRestorationTick(limb)
  enemyRestorationApplied = false
  
  for k,v in pairs(enemyLimbs) do 
    if limb:match(v.name) then 
      enemyLimbs[k].damage = enemyLimbs[k].damage - 33
      if enemyLimbs[k].damage < 0 then enemyLimbs[k].damage = 0 end
    end 
  end
  
  if not isClass("syssin") then
    echo(C.g .. "[[" .. C.R .. "ENEMY RESTORATION COMPLETE" .. C.g .. "]]" .. C.x)
    showEnemyLimbs()
  end
end

function checkForPreRestore(limb)
  for k,v in pairs(enemyLimbs) do 
    if limb:match(v.name) then 
      if enemyLimbs[k].damage < 32 and not isClass("syssin") then
        echo("\n" .. acsLabel .. C.r .. "POSSIBLE PRERESTORE ON " .. C.G .. string.upper(limb) .. C.r .. "!!!" .. C.x)
        echo(acsLabel .. C.r .. "POSSIBLE PRERESTORE ON " .. C.G .. string.upper(limb) .. C.r .. "!!!" .. C.x)
        echo(acsLabel .. C.r .. "POSSIBLE PRERESTORE ON " .. C.G .. string.upper(limb) .. C.r .. "!!!" .. C.x)
      end
    end 
  end
end

function attackDiverted()
  if lastAttack ~= "" then
    replace(acsLabel .. C.Y .. "ATTACK DIVERTED!" .. C.x)
    attack_diverted = true
  end
end

function attackDodged()
  if lastAttack ~= "" then
    replace(acsLabel .. C.R .. "ATTACK MISSED!" .. C.x)
  end
end

function attackParried(p)
  if lastAttack ~= "" then
    replace(acsLabel .. C.R .. lastTarget .. C.r .. " PARRIED! ".. C.R .. lastTarget .. C.r .. " PARRIED! ".. C.R .. lastTarget .. C.r .. " PARRIED! ".. C.R .. lastTarget .. C.r .. " PARRIED! ".. C.x)
    echo("\n" .. acsLabel .. C.R .. lastTarget .. C.r .. " PARRIED! ".. C.R .. lastTarget .. C.r .. " PARRIED! ".. C.R .. lastTarget .. C.r .. " PARRIED! ".. C.R .. lastTarget .. C.r .. " PARRIED! ".. C.x)
    echo(acsLabel .. C.R .. lastTarget .. C.r .. " PARRIED! ".. C.R .. lastTarget .. C.r .. " PARRIED! ".. C.R .. lastTarget .. C.r .. " PARRIED! ".. C.R .. lastTarget .. C.r .. " PARRIED! ".. C.x)
    echo(acsLabel .. C.R .. lastTarget .. C.r .. " PARRIED! ".. C.R .. lastTarget .. C.r .. " PARRIED! ".. C.R .. lastTarget .. C.r .. " PARRIED! ".. C.R .. lastTarget .. C.r .. " PARRIED! ".. C.x)
    echo(acsLabel .. C.R .. lastTarget .. C.r .. " PARRIED! ".. C.R .. lastTarget .. C.r .. " PARRIED! ".. C.R .. lastTarget .. C.r .. " PARRIED! ".. C.R .. lastTarget .. C.r .. " PARRIED! ".. C.x)
    echo(acsLabel .. C.R .. lastTarget .. C.r .. " PARRIED! ".. C.R .. lastTarget .. C.r .. " PARRIED! ".. C.R .. lastTarget .. C.r .. " PARRIED! ".. C.R .. lastTarget .. C.r .. " PARRIED! ".. C.x)
    attack_parried = true
    
    if lastAttack.name == "elemental" then
      reduceLimbDamage(lastTarget, lastAttack)
    end
  end
end

function reduceLimbDamage()
  for k,v in pairs(enemyLimbs) do
    if v.name == lastTarget then
      damage = getDamageAmount()
      enemyLimbs[k].damage = enemyLimbs[k].damage - damage
    end
  end
  
  showEnemyLimbs()
end

function attackHit()
  replace(acsLabel .. C.G .. "HIT!" .. C.x)
  if lastAttack ~= "" then  
    if not autob then calculateLimbDamage() end
  end
end

function calculateLimbDamage()
  for k,v in pairs(enemyLimbs) do
    if v.name == lastTarget then
      damage = getDamageAmount()
      enemyLimbs[k].damage = enemyLimbs[k].damage + damage
    end
  end
  
  showEnemyLimbs()
end

function setLimbAttackDamage(limb, damage)
  for k,v in pairs(enemyLimbs) do
    if v.name == limb then
      enemyLimbs[k].damage = damage
    end
  end
  
  showEnemyLimbs()
end

function getDamageAmount()
  tmp = 0
  
  if not enemyIsLycan then
    if not attack_diverted then
      tmp = lastAttack.hit
    else
      tmp = lastAttack.divert
    end
  else
    if not attack_diverted then
      tmp = lastAttack.harden
    else
      tmp = lastAttack.hardenDivert
    end
  end
  
  return tmp
end

function setLastAttack(pattern, limb, attack)
  person = mb.line:match(pattern)
  
  attack_parried = false
  attack_diverted = false
  attack_dodged = false
  
  lastTarget = limb
  lastAttack = attack
  
  if lastAttack.name == "mangle" then
    setLimbAttackDamage(lastTarget, 32)
  elseif lastAttack.name == "destroy" then
    setLimbAttackDamage(lastTarget, 65)
  end
  
  replace(acsLabel .. C.G .. lastAttack.name .. C.G .. " (" .. C.Y .. limb .. C.G .. ") - " .. C.R .. person .. C.x) 
end

function setDestroyDamage(limb)
  l = getLimb(limb)
  if l.damage < 32 then setLimbAttackDamage(lastTarget, 65) else calculateLimbDamage() end
end

function getLimb(limb)
  for k,v in pairs(enemyLimbs) do
    if v.name:match(limb) then return v end
  end
end

-- Wound Checking
function woundCheck(pattern)
  limb, _, damage = mb.line:match(pattern)
  limb = string.lower(limb)
  setLimbDamage(limb, damage)
end

function woundCheck2(pattern)
  side, appendage, _, damage = mb.line:match(pattern)
  limb = side .. " " .. appendage
  limb = string.lower(limb)
  setLimbDamage(limb, damage)
end

function setLimbDamage(limb, damage)
  if enemyWoundCheck then
    setEnemyLimbDamage(limb, damage)
  elseif selfWoundCheck then
    setMyLimbDamage(limb, damage)
    checkForPreres()
  end
end

function setMyLimbDamage(limb, damage)
  for k,v in pairs(myLimbs) do
    if limb:match(v.name) then
      v.damage = tonumber(damage)
    end
  end
end

function setEnemyLimbDamage(limb, damage)
  for k,v in pairs(enemyLimbs) do
    if limb:match(v.name) then
      v.damage = tonumber(damage)
    end
  end
end

function resetEnemyLimbs()
  enemyLimbs = {
    head = {name = "head", damage = 0, status = "unbroken"},
    torso = {name = "torso", damage = 0, status = "unbroken"},
    left_arm = {name = "left arm", damage = 0, status = "unbroken"},
    right_arm = {name = "right arm", damage = 0, status = "unbroken"},
    left_leg = {name = "left leg", damage = 0, status = "unbroken"},
    right_leg = {name = "right leg", damage = 0, status = "unbroken"},
  }
  
  echo("Reset enemy limbs!")
  show_prompt()
end

function resetMyLimbs()
  enemyLimbs = {
    head = {name = "head", damage = 0, status = "unbroken"},
    torso = {name = "torso", damage = 0, status = "unbroken"},
    left_arm = {name = "left arm", damage = 0, status = "unbroken"},
    right_arm = {name = "right arm", damage = 0, status = "unbroken"},
    left_leg = {name = "left leg", damage = 0, status = "unbroken"},
    right_leg = {name = "right leg", damage = 0, status = "unbroken"},
  }
end

function prompt_resetLimb()
  if lastAttack.name == "shred" then
    if not attack_parried and not attack_dodged then
      calculateLimbDamage()
    end
  end
  
  lastTarget = ""
  lastAttack = ""
  limbChecking = ""
  attack_parried = false
  attack_diverted = false
  attack_dodged = false
end