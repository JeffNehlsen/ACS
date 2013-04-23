
echo("Wielding script loaded.")
leftHand = ""
rightHamd = ""

aliases.wieldingAliases = {
  {pattern = "^unwield$", handler = function(i,p) doUnwield() end},
}

triggers.wieldingTriggers = {
  {pattern = "^You begin to wield(.*)flail(.*)in your (%w+) hand.$", handler = function(p) flailHandler(p) end},
  {pattern = "^You begin to wield(.*)crozier(.*)in your (%w+) hand.$", handler = function(p) crozierHandler(p) end},
  {pattern = "^You begin to wield(.*)shield(.*)in your (%w+) hand.$", handler = function(p) towerHandler(p) end},
  {pattern = "^You begin to wield(.*)sword(.*)in your (%w+) hand.$", handler = function(p) swordHandler(p) end},
  {pattern = "^You pull (.*) from your weaponbelt fluidly.$", handler = function(p) gagLine() end},
  {pattern = "^You begin to wield(.*)dirk(.*)in your (%w+) hand.$", handler = function(p) dirkHandler(p) end},
  {pattern = "^You begin to wield(.*)whip(.*)in your (%w+) hand.$", handler = function(p) whipHandler(p) end},
  {pattern = "^You begin to wield(.*)axe(.*)in your (%w+) hand.$", handler = function(p) axeHandler(p) end},

  -- Unequipping
  {pattern = "^You deftly flip(.*)shield(.*)over your back, strapping it in place.$", handler = function(p) towerUnequipped() end},
  {pattern = "^You cease to wield (.*) in your (%w+) hand, securing it", handler = function(p) singleUnequip(p) end},
  {pattern = "^You cease to wield (.*) in your hands, securing it", handler = function(p) doubleUnequip(p) end},
  {pattern = "^on your weaponbelt.$", handler = function(p) gagLine() end},
  {pattern = "^your weaponbelt.$", handler = function(p) gagLine() end},
  {pattern = "^conveniently on your weaponbelt.$", handler = function(p) gagLine() end},
  {pattern = "^You swiftly remove the shield from your back.$", handler = function(p) gagLine() end},
  {pattern = "^I don't see what you want to secure.$", handler = function(p) killLine() end},
  {pattern = "^You need to be wielding that which you want to secure.$", handler = function(p) killLine() end},
  {pattern = "^You are already wielding (.*) in your hands.$", handler = function(p) killLine() end},
  {pattern = "^You are already wielding (.*) in your (%w+) hand.$", handler = function(p) killLine() end},
  
  -- Wielded
  {pattern = "^You are wielding:$", handler = function(p) leftHand = "" rightHand = "" end},
  {pattern = "^You aren't wielding anything in either hand.$", handler = function(p) leftHand = "" rightHand = "" end},
  {pattern = "^\"(%w+)(%d+)\" (%s+) (.*) %((.*)%)$", handler = function(p) setWielded(p) end},
  
  -- Bow stuff
  {pattern = "^With a single fluid movement, you pull(.*)bow(.*)from your shoulder and wield it.$", handler = function(p) bowWielded() end},
  {pattern = "^You cease to wield(.*)bow(.*).$", handler = function(p) removedBow() end},
  
  {pattern = "^You start to wield(.*)dhurive(.*)in your hands.$", handler = function(p) wieldedDhurive() end},
  
  {pattern = "You start to wield(.*)warhammer(.*)in your hands.", handler = function(p) wieldedWarhammer() end},
  {pattern = "You start to wield(.*)battlehammer(.*)in your hands.", handler = function(p) wieldedWarhammer() end},
  {pattern = "You start to wield(.*)bardiche(.*)in your hands.", handler = function(p) wieldedBardiche() end},
  {pattern = "You start to wield(.*)halberd(.*)in your hands.", handler = function(p) wieldedHalberd() end},
  {pattern = "You start to wield(.*)bastard sword in your hands.", handler = function(p) wieldedBastard() end},
}

function wieldedBardiche()
  leftHand = bardiche
  rightHand = bardiche
  wieldReplace(bardiche, "both")
end

function wieldedBastard()
  leftHand = bastard
  rightHand = bastard
  wieldReplace(bastard, "both")
end

function wieldedHalberd()
  leftHand = halberd
  rightHand = halberd
  wieldReplace(halberd, "both")
end

function wieldedWarhammer()
  leftHand = warhammer
  rightHand = warhammer
  wieldReplace(warhammer, "both")
end

function removedBow()
  leftHand = ""
  rightHand = ""
end

function bowWielded()
  leftHand = bow
  rightHand = bow
  wieldReplace(bow, "both")
end

function wieldedDhurive()
  leftHand = dhurive
  rightHand = dhurive
  wieldReplace(dhurive, "both")
end

function wieldBow()
  doUnwield("both")
  send("bowstance")
end

function unwieldBow()
  send("unwield bow")
  send("wear bow")
end

function setWielded(pattern)
  wepType, wepNumber, _, _, side = mb.line:match(pattern)
  weapon = wepType .. wepNumber
  if side:match("two") then
    leftHand = weapon
    rightHand = weapon
  elseif side:match("left") then
    leftHand = weapon 
  else
    rightHand = weapon
  end
  wieldReplace(weapon, side)
end

function doWield(weapon1, weapon2)
  local w1WieldedLeft, w1WieldedRight, w1WieldedLeft, w2WieldedRight, w1Wielded, w2Wielded
  w1WieldedLeft = false w1WieldedRight = false w2WieldedLeft = false w2WieldedRight = false w1Wielded = false w2Wielded = false
  
  -- If you are trying to wield a 2h weapon, weapon2 will normally be nil
  if weapon2 == nil then weapon2 = weapon1 end
  
  -- Check to see if weapon1 is wielded
  if weapon1 == leftHand then w1WieldedLeft = true end
  if weapon1 == rightHand then w1WieldedRight = true end
  if w1WieldedLeft or w1WieldedRight then w1Wielded = true end
  
  -- Check to see if weapon2 is wielded
  if weapon2 == leftHand then w2WieldedLeft = true end
  if weapon2 == rightHand then w2WieldedRight = true end
  if w2WieldedLeft or w2WieldedRight then w2Wielded = true end
  
  -- echo("Equipped:: Left:    " .. leftHand .. ", Right:  " .. rightHand)
  -- echo("Asking  :: weapon1: " .. weapon1 .. ", weapon2: " .. weapon2)
  -- echo('w1WieldedLeft:  ' .. tostring(w1WieldedLeft))
  -- echo('w1WieldedRight: ' .. tostring(w1WieldedRight))
  -- echo('w2WieldedLeft:  ' .. tostring(w2WieldedLeft))
  -- echo('w2WieldedRight: ' .. tostring(w2WieldedRight))
  -- echo("w1Wielded: " .. tostring(w1Wielded))
  -- echo("w2Wielded: " .. tostring(w2Wielded))
  
  if weapon1 == bow then
    if not w1Wielded then wieldBow() end
  elseif not w1Wielded and not w2Wielded then
    doUnwield("both")
    wieldWeapon(weapon1)
    wieldWeapon(weapon2)
  elseif leftHand == bow then
    doUnwield()
    wieldWeapon(weapon1)
    wieldWeapon(weapon2)
  else
    if not w1Wielded then
      if not w2WieldedLeft then
        doUnwield("left")
      else
        doUnwield("right")
      end
      wieldWeapon(weapon1)
    end
    
    if not w2Wielded then
      if not w1WieldedLeft then
        doUnwield("left")
      else
        doUnwield("right")
      end
      wieldWeapon(weapon2)
    end
  end
end

function doUnwield(side)
  if leftHand == bow or rightHand == bow then
    unwieldBow()
  elseif side == "both" or side == nil then
    unwieldSide("left")
    unwieldSide("right")
  else
    unwieldSide(side)
  end
end

function unwieldSide(side)
  if (side:find("left") and leftHand == tower) or (side:find("right") and rightHand == tower) then
    unwieldTower() 
  else
    send("secure " .. side)
  end
end

function wieldWeapon(weapon)
  if weapon ~= nil then
    if weapon == bow then send("remove " .. bow) end
    send("wield " .. weapon)
  end
end

function unwieldWeapon(weapon)
  send("secure " .. weapon)
end

function unwieldTower()
  send("wear " .. tower)
end

function singleUnequip(pattern)
  weapon, side = mb.line:match(pattern)
  if side:match("left") then
    leftHand = ""
  else
    rightHand = ""
  end
  unwieldReplace(weapon, side)
end

function doubleUnequip(pattern)
  weapon = mb.line:match(pattern)
  leftHand = ""
  rightHand = ""
  unwieldReplace(weapon, "both")
end

function towerUnequipped()
  if leftHand == tower then
    leftHand = ""
    unwieldReplace(tower, "left")
  else
    rightHand = ""
    unwieldReplace(tower, "right")
  end
end

function whipHandler(pattern)
  _, _, side = mb.line:match(pattern)
  if side:match("left") then
    leftHand = whip
  else
    rightHand = whip
  end
  wieldReplace(whip, side)
end

function dirkHandler(pattern)
  _, _, side = mb.line:match(pattern)
  if side:match("left") then
    leftHand = dirk
  else
    rightHand = dirk
  end
  wieldReplace(dirk, side)
end

function axeHandler(p)
  _, _, side = mb.line:match(p)
  if side:match("left") then leftHand = axe else rightHand = axe end
  wieldReplace(axe, side)
end

function swordHandler(pattern)
  _, _, side = mb.line:match(pattern)
  if side:match("left") then
    leftHand = sword
  else
    rightHand = sword
  end
  wieldReplace(sword, side)
end

function towerHandler(pattern)
  _, _, side = mb.line:match(pattern)
  if side:match("left") then
    leftHand = tower
  else
    rightHand = tower
  end
  wieldReplace(tower, side)
end

function warhammerHandler()
  leftHand = hammer
  rightHand = hammer
  wieldReplace(hammer, "both")
end

function flailHandler(pattern)
  _, _, side = mb.line:match(pattern)
  if side:match("left") then
    leftHand = flail
  else
    rightHand = flail
  end
  
  wieldReplace(flail, side)
end

function crozierHandler(pattern)
  _, _, side = mb.line:match(pattern)
  if side:match("left") then
    leftHand = crozier
  else
    rightHand = crozier
  end
  
  wieldReplace(crozier, side)
end

function wieldReplace(weapon, hand)
  extra = hand == "both" and "s" or ""
  setACSLabel("Wielded " .. weapon .. " in " .. hand .. " hand" .. extra .. ".")
end

function unwieldReplace(weapon, hand)
  extra = hand == "both" and "s" or ""
  setACSLabel("Removed " .. weapon .. " from " .. hand .. " hand" .. extra .. ".")
end