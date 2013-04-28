echo("Limb tracker loaded")
lastTarget = ""
lastAttack = ""
limbChecking = ""
needPreres = ""
attack_parried = false
attack_diverted = false
attack_dodged = false

enemyRestorationApplied = false

enemyLimbs = {
  head = {name = "head", damage = 0, status = "unbroken"},
  torso = {name = "torso", damage = 0, status = "unbroken"},
  left_arm = {name = "left arm", damage = 0, status = "unbroken"},
  right_arm = {name = "right arm", damage = 0, status = "unbroken"},
  left_leg = {name = "left leg", damage = 0, status = "unbroken"},
  right_leg = {name = "right leg", damage = 0, status = "unbroken"},
}

wounds = {
  checking = nil,
  my = {
    head = {damage = 0, status = "unbroken", aff="preresHead"},
    torso = {damage = 0, status = "unbroken", aff="preresTorso"},
    ["left arm"] = {damage = 0, status = "unbroken", aff="preresLeftArm"},
    ["right arm"] = {damage = 0, status = "unbroken", aff="preresRightArm"},
    ["left leg"] = {damage = 0, status = "unbroken", aff="preresLeftLeg"},
    ["right leg"] = {damage = 0, status = "unbroken", aff="preresRightLeg"},
  },
  enemy = {
    head = {damage = 0, status = "unbroken"},
    torso = {damage = 0, status = "unbroken"},
    ["left arm"] = {damage = 0, status = "unbroken"},
    ["right arm"] = {damage = 0, status = "unbroken"},
    ["left leg"] = {damage = 0, status = "unbroken"},
    ["right leg"] = {damage = 0, status = "unbroken"},
  }
}

limbAttacks = {
  smite = {damage = 7.48, divert = 6.36},
  smash = {damage = 29.99, divert = 29.99},
  crushTower = {damage = 14.99, divert = 14.99},
  crushBuckler = {damage = 2.99, divert = 2.99},
}

-- attacks = {
--   shred = {name = "shred", hit = SHRED_DAMAGE, divert = SHRED_DAMAGE_DIVERT, harden = SHRED_DAMAGE_HARDEN, hardenDivert = SHRED_DAMAGE_HARDEN_DIVERT},
--   elemental = {name = "elemental", hit = ELEMENTAL_DAMAGE, divert = ELEMENTAL_DAMAGE_DIVERT, harden = ELEMENTAL_DAMAGE_HARDEN, hardenDivert = ELEMENTAL_DAMAGE_HARDEN_DIVERT},
--   claw = {name = "claw", hit = CLAW_DAMAGE, divert = CLAW_DAMAGE_DIVERT, harden = CLAW_DAMAGE_HARDEN, hardenDivert = CLAW_DAMAGE_HARDEN_DIVERT},
--   rend = {name = "rend", hit = REND_DAMAGE, divert = REND_DAMAGE_DIVERT, harden = REND_DAMAGE_HARDEN, hardenDivert = REND_DAMAGE_HARDEN_DIVERT},
--   hamstring = {name = "hamstring", hit = REND_DAMAGE, divert = REND_DAMAGE_DIVERT, harden = REND_DAMAGE_HARDEN, hardenDivert = REND_DAMAGE_HARDEN_DIVERT},
--   skullwhack = {name = "skullwhack", hit = HEAD_DAMAGE, divert = HEAD_DAMAGE_DIVERT, harden = HEAD_DAMAGE_HARDEN, hardenDivert = HEAD_DAMAGE_HARDEN_DIVERT},
--   jugularclaw = {name = "jugularclaw", hit = HEAD_DAMAGE, divert = HEAD_DAMAGE_DIVERT, harden = HEAD_DAMAGE_HARDEN, hardenDivert = HEAD_DAMAGE_HARDEN_DIVERT},
--   bodypunch = {name = "bodypunch", hit = BODYPUNCH_DAMAGE, divert = BODYPUNCH_DAMAGE_DIVERT, harden = BODYPUNCH_DAMAGE_HARDEN, hardenDivert = BODYPUNCH_DAMAGE_HARDEN_DIVERT},
--   spinalcrack = {name = "spinalcrack", hit = SPINALCRACK_DAMAGE, divert = SPINALCRACK_DAMAGE_DIVERT, harden = SPINALCRACK_DAMAGE_HARDEN, hardenDivert = SPINALCRACK_DAMAGE_HARDEN_DIVERT},
--   destroy = {name = "destroy", hit = 10, divert = 10, harden = 8, hardenDivert = 8},
--   mangle = {name = "mangle", hit = 0, divert = 0, harden = 0, hardenDivert = 0},
--   axeslash = {name = "axeslash", hit = 5.5, divert = 4, harden = 3.75, hardenDivert = 3},
--   macehit = {name = "macehit", hit = 6, divert = 5, harden = 5, hardenDivert = 3},
--   slash = {name = "slash", hit = 7, divert = 5, harden = 5, harenDivert = 3},
-- }

triggers.limbTrackingTriggers = {
  -- Attacks
  -- {pattern = "^You spring forward lithely and lash at (%w+)'s left leg!$", handler = function(p) setLastAttack(p, "left leg", attacks.hamstring) end},
  -- {pattern = "^You spring forward lithely and lash at (%w+)'s right leg!$", handler = function(p) setLastAttack(p,"right leg", attacks.hamstring) end},
  -- {pattern = "^You tear at (%w+)'s left arm, awaiting the exhilirating snap of bone.$", handler = function(p) setLastAttack(p,"left arm", attacks.rend) end},
  -- {pattern = "^You tear at (%w+)'s right arm, awaiting the exhilirating snap of bone.$", handler = function(p) setLastAttack(p,"right arm", attacks.rend) end},
  -- {pattern = "^You crouch low and hurtle yourself into (%w+)'s midsection. (%w+) blinks groggily,$", handler = function(p) setLastAttack(p,"torso", attacks.bodypunch) end},
  -- {pattern = "^stunned.$", handler = function(p) gagLine() end},
  -- {pattern = "^You rear up and bring your claws into the base of (%w+)'s skull!$", handler = function(p) setLastAttack(p,"head", attacks.skullwhack) end},
  -- {pattern = "^You spy (%w+)'s jugular exposed and lunge to claw open the throbbing vessel.$", handler = function(p) setLastAttack(p,"head", attacks.jugularclaw) end},
  -- {pattern = "^You rush and leap headlong into (%w+)'s spine and hear a satisfying crack!$", handler = function(p) setLastAttack(p,"torso", attacks.spinalcrack) end},
  -- {pattern = "^A snarl twists your lips as you claw at (%w+)'s left leg.$", handler = function(p) setLastAttack(p,"left leg", attacks.claw) end},
  -- {pattern = "^A snarl twists your lips as you claw at (%w+)'s right leg.$", handler = function(p) setLastAttack(p,"right leg", attacks.claw) end},
  -- {pattern = "^A snarl twists your lips as you claw at (%w+)'s left arm.$", handler = function(p) setLastAttack(p,"left arm", attacks.claw) end},
  -- {pattern = "^A snarl twists your lips as you claw at (%w+)'s right arm.$", handler = function(p) setLastAttack(p,"right arm", attacks.claw) end},
  -- {pattern = "^You claw and bite at (%w+)'s left leg until it is merely a lump of bone", handler = function(p) setLastAttack(p,"left leg", attacks.mangle) end},
  -- {pattern = "^You claw and bite at (%w+)'s right leg until it is merely a lump of bone", handler = function(p) setLastAttack(p,"right leg", attacks.mangle) end},
  -- {pattern = "^You claw and bite at (%w+)'s left arm until it is merely a lump of bone", handler = function(p) setLastAttack(p,"left arm", attacks.mangle) end},
  -- {pattern = "^You claw and bite at (%w+)'s right arm until it is merely a lump of bone", handler = function(p) setLastAttack(p, "right leg", attacks.mangle) end},
  -- {pattern = "meat.$", handler = function(p) gagLine() end},
  -- {pattern = "^You sever (%w+)'s left leg and chew it beyond recognition.", handler = function(p) setLastAttack(p, "left leg", attacks.destroy) end},
  -- {pattern = "^You sever (%w+)'s right leg and chew it beyond recognition.", handler = function(p) setLastAttack(p, "right leg", attacks.destroy) end},
  -- {pattern = "^You sever (%w+)'s left arm and chew it beyond recognition.", handler = function(p) setLastAttack(p, "left arm", attacks.destroy) end},
  -- {pattern = "^You sever (%w+)'s right arm and chew it beyond recognition.", handler = function(p) setLastAttack(p, "right arm", attacks.destroy) end},
  
  -- Shred
  -- {pattern = "^You focus the sands on (%w+)'s right leg.", handler = function(p) setLastAttack(p, "right leg", attacks.shred) end},
  -- {pattern = "^You focus the sands on (%w+)'s left leg.", handler = function(p) setLastAttack(p, "left leg", attacks.shred) end},
  -- {pattern = "^You focus the sands on (%w+)'s right arm.", handler = function(p) setLastAttack(p, "right arm", attacks.shred) end},
  -- {pattern = "^You focus the sands on (%w+)'s left arm.", handler = function(p) setLastAttack(p, "left arm", attacks.shred) end},
  -- {pattern = "^You focus the sands on (%w+)'s head.", handler = function(p) setLastAttack(p, "head", attacks.shred) end},
  -- {pattern = "^You focus the sands on (%w+)'s torso.", handler = function(p) setLastAttack(p, "torso", attacks.shred) end},
  
  -- Elemental
  --With a powerful strike, an earthen elemental slams a fist into your left leg.
  --striking your right leg painfully before the elemental disperses
  
  -- Miss/hit messages
  -- {pattern = "^You rake (%w+), delighting in (%w+) whimper of pain.$", handler = function(p) attackHit() end},
  -- {pattern = "^You nimbly smack into (%w+) with your paw, cuffing (%w+).$", handler = function(p) attackHit() end},
  -- {pattern = "^You tear open long lacerations with your wicked claws.$", handler = function(p) attackHit() end},
  -- {pattern = "^(%w+) jerks to the side, the attack barely grazing (%w+).$", handler = function(p) attackDiverted() end},
  -- {pattern = "^Stepping quickly out of the way, (%w+) dodges the attack.$", handler = function(p) attackDodged() end},
  -- {pattern = "^(%w+) parries the attack on (%w+) (%w+) with a deft maneuver.", handler = function(p) attackParried(p) end},
  -- {pattern = "^(%w+) parries the attack on (%w+) (%w+) (%w+) with a deft maneuver.", handler = function(p) attackParried(p) end},
  
  -- Bandage applications
  -- {pattern = "^(%w+) presses (%w+) (%w+) poultice against (%w+) (%w+) (%w+), rubbing the poultice", handler = function(p) enemyPoulticeDirectlyApplied(p) end},
  -- {pattern = "^flesh%.$", handler = function(p) gagLine() end},
  --{pattern = "^(%w+) flesh%.$", handler = function(p) gagLine() end},
  --{pattern = "^into (%w+) flesh%.$", handler = function(p) gagLine() end},
  -- {pattern = "^(%w+) presses (%w+) (%w+) poultice against (%w+) (%w+), rubbing the poultice", handler = function(p) enemyPoulticeGenerallyApplied(p) end},
  
  -- Salve applications
  -- {pattern = "^(%w+) takes a salve of (%w+) and rubs it on (%w+) (%w+) (%w+).$", handler = function(p) enemySalveDirectlyApplied(p) end},
  -- {pattern = "^(%w+) takes a salve of (%w+) and rubs it on (%w+) (%w+).$", handler = function(p) enemySalveGenerallyApplied(p) end},
  
  
  -- Prerestore complete stuff
  {pattern = "^You have restored your (.*) as best as you can!$", handler = function(p) preresComplete(p) end},
  
  -- Attacks on you.
  {pattern = "Your (.+) has taken (.+)%% damage.", handler = function(p) parseLimbDamage(p) end},
  {pattern = "Your (.+) has recovered (.+)%% damage.", handler = function(p) parseLimbDamageCure(p) end},

  -- Wounds
  {pattern = "^You take a moment to assess how damaged your limbs are.$", handler = function (p) wounds.checking = "my" end},
  {pattern = "^You take a moment to assess how damaged (%w+)'s limbs are.$", handler = function (p) wounds.checking = "enemy" end},
  {pattern = "^(.+):%s+(.+)%% %(no bruising%)$", handler = function (p) woundsCheckHandler(p) end},

  -- Enemy salve healing
  {pattern = "^(%w+) takes a salve of (%w+) and rubs it on %w+ (.*).$", handler = function(p) wounds:enemySalveHandler(p) end},
  {pattern = "^(%w+) takes %w+ (%w+) salve and rubs it on %w+ (.*).$", handler = function(p) wounds:enemySalveHandler(p) end},
  {pattern = "^(%w+) presses %w+ (%w+) poultice against %w+ (.*), rubbing the poultice into %w+ flesh.$", handler = function(p) wounds:enemySalveHandler(p) end},
}

aliases.limbTrackingAliases = {
  {pattern = "^limbs$", handler = function(i,p) showEnemyLimbs() end},
  {pattern = "^rlimbs$", handler = function(i,p) resetEnemyLimbs() end},
}

-------------------------
-- Prerestore handling --
-------------------------
function woundsCheckHandler(p)
  local limb, damage = mb.line:match(p)
  lowerLimb = limb:lower()

  wounds[wounds.checking][lowerLimb].damage = tonumber(damage)
  local syntax ="%10s" .. " %5s%%"
end

function parseLimbDamage(p)
  local limb, damage = mb.line:match(p)

  wounds.my[limb].damage = wounds.my[limb].damage + damage
end

function parseLimbDamageCure(p)
  local limb, damage = mb.line:match(p)

  wounds.my[limb].damage = wounds.my[limb].damage - damage
end

function checkLimbsForPrerestore()
  local checkPre = function(limb)
    return wounds.my[limb].damage >= PRERESTORE_THRESHOLD
  end
  
  if checkPre("left leg") and not hasAffliction("preresLeftLeg") then afflictionAdd("preresLeftLeg") end
  if checkPre("right leg") and not hasAffliction("preresRightLeg") then afflictionAdd("preresRightLeg") end
  if checkPre("left arm") and not hasAffliction("preresLeftArm") then afflictionAdd("preresLeftArm") end
  if checkPre("right arm") and not hasAffliction("preresRightArm") then afflictionAdd("preresRightArm") end
  if checkPre("torso") and not hasAffliction("preresTorso") then afflictionAdd("preresTorso") end
  if checkPre("head") and not hasAffliction("preresHead") then afflictionAdd("preresHead") end
end

function preresComplete(p)
  local limb = mb.line:match(p)

  afflictionCure(wounds.my[limb].aff)
end

-------------------------
-- Enemy Limb Tracking --
-------------------------

function addEnemyLimbDamage(limb, attack)
  wounds.enemy[limb].damage = wounds.enemy[limb].damage + attack.damage
  ACSEcho("Enemy " .. limb .. " at " .. wounds.enemy[limb].damage)
end

function enemyLimbDamageReset()
  for _, limb in pairs(wounds.enemy) do
    limb.damage = 0
  end
end

function wounds:enemySalveHandler(p)
  
  local person, salve, limb = mb.line:match(p)
  if isTarget(person) and (salve == "restoration" or salve == "jecis") and not enemyRestorationApplied then
    enemyRestorationApplied = true
    add_timer(4, function()
      enemyRestorationApplied = false
      wounds.enemy[limb].damage = wounds.enemy[limb].damage - 33.33
      if wounds.enemy[limb].damage < 0 then
        wounds.enemy[limb].damage = 0
      end
      ACSEcho("Enemy " .. limb .. ": " .. wounds.enemy[limb].damage)
    end)
  end
end





















function showEnemyLimbs()
  -- echo("\nHead:\t" .. tostring(enemyLimbs.head.damage) .. "\tTorso:\t" .. tostring(enemyLimbs.torso.damage))
  -- echo("L. Arm:\t" .. tostring(enemyLimbs.left_arm.damage) .. "\tR. Arm:\t" .. tostring(enemyLimbs.right_arm.damage))
  -- echo("L. Leg:\t" .. tostring(enemyLimbs.left_leg.damage) .. "\tR. Leg:\t" .. tostring(enemyLimbs.right_leg.damage))
end

function showMyLimbs()
  -- echo("\nHead:\t" .. tostring(myLimbs.head.damage) .. "\tTorso:\t" .. tostring(myLimbs.torso.damage))
  -- echo("L. Arm:\t" .. tostring(myLimbs.left_arm.damage) .. "\tR. Arm:\t" .. tostring(myLimbs.right_arm.damage))
  -- echo("L. Leg:\t" .. tostring(myLimbs.left_leg.damage) .. "\tR. Leg:\t" .. tostring(myLimbs.right_leg.damage))
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
  -- enemyLimbs = {
  --   head = {name = "head", damage = 0, status = "unbroken"},
  --   torso = {name = "torso", damage = 0, status = "unbroken"},
  --   left_arm = {name = "left arm", damage = 0, status = "unbroken"},
  --   right_arm = {name = "right arm", damage = 0, status = "unbroken"},
  --   left_leg = {name = "left leg", damage = 0, status = "unbroken"},
  --   right_leg = {name = "right leg", damage = 0, status = "unbroken"},
  -- }
  
  -- echo("Reset enemy limbs!")
  -- show_prompt()
end

function prompt_resetLimb()
  -- if lastAttack.name == "shred" then
  --   if not attack_parried and not attack_dodged then
  --     calculateLimbDamage()
  --   end
  -- end
  
  -- lastTarget = ""
  -- lastAttack = ""
  -- limbChecking = ""
  -- attack_parried = false
  -- attack_diverted = false
  -- attack_dodged = false
end