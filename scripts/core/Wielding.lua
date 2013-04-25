
echo("Wielding script loaded.")
leftHand = ""
rightHamd = ""

aliases.wieldingAliases = {
  {pattern = "^unwield$", handler = function(i,p) doUnwield() end},
}

triggers.wieldingTriggers = {
  -- Unequipping
  {pattern = "^You cease to wield (.*) in your (%w+) hand, securing it conveniently on your weaponbelt.", handler = function(p) singleUnequip(p) end},
  {pattern = "^You cease to wield (.*) in your hands, securing it", handler = function(p) doubleUnequip(p) end},

  -- Gagging extra lines
  {pattern = "^You swiftly remove the shield from your back.$", handler = function(p) gagLine() end},
  {pattern = "^I don't see what you want to secure.$", handler = function(p) killLine() end},
  {pattern = "^You need to be wielding that which you want to secure.$", handler = function(p) killLine() end},
  {pattern = "^You are already wielding (.*) in your hands.$", handler = function(p) killLine() end},
  {pattern = "^You are already wielding (.*) in your (%w+) hand.$", handler = function(p) killLine() end},
  {pattern = "^You pull .* from your weaponbelt fluidly.$", handler = function(p) gagLine() end},
  
  -- Wielded
  {pattern = "^You are wielding:$", handler = function(p) leftHand = "" rightHand = "" end},
  {pattern = "^You aren't wielding anything in either hand.$", handler = function(p) leftHand = "" rightHand = "" end},
  {pattern = "^\"(%w+)(%d+)\" (%s+) (.*) %((.*)%)$", handler = function(p) setWielded(p) end},
  
  -- Bow stuff
  -- TODO: Replace this with dynamic triggers and the weapons table.
  {pattern = "^With a single fluid movement, you pull(.*)bow(.*)from your shoulder and wield it.$", handler = function(p) bowWielded() end},
  {pattern = "^You cease to wield(.*)bow(.*).$", handler = function(p) removedBow() end},
}

function constructWieldingTriggers()
  if not weapons then
    ACSEcho("No weapons found. Check your settings")
    return
  end

  triggers.weapons = {}

  for _, weapon in pairs(weapons) do
    if not weapon.twoHanded then

      addTrigger("weapons", "You begin to wield " .. weapon.name .. " in your (%w+) hand.", function(p)
          side = mb.line:match(p)
          if side:match("left") then
            leftHand = weapon.item
          else
            rightHand = weapon.item
          end
          wieldReplace(weapon.item, side)
      end)

    else

      addTrigger("weapons", "You start to wield " .. weapon.name .. " in your hands.", function(p)
          leftHand = weapon.item
          rightHand = weapon.item
          wieldReplace(weapon.item, "both")
      end)

    end

    if weapon.shield then
      addTrigger("weapons", "You deftly flip " .. weapon.name .. " over your back, strapping it in place.", function(p) 
        -- unquippedWeaponByName(weapon.name)
        if weapon.item == leftHand then
          leftHand = ""
          wieldReplace(weapon.item, "left")
        elseif weapon.item == rightHand then
          rightHand = ""
          wieldReplace(weapon.item, "right")
        end
      end)
    end
  end
end

function unquippedWeaponByName(name)
  local weapon = getWeaponByName(name)

  if weapon.name == weaponName then
    if leftHand == weapon.item then 
      leftHand = ""
      unwieldReplace(weapon.item, "left")
      return
    end

    if rightHand == weapon.item then
      rightHand = ""
      unwieldReplace(weapon.item, "right")
      return
    end
  end
end

function getWeaponByName(name)
  for _, weapon in pairs(weapons) do
    -- if weapon.name:find(name) then
    if string.find(weapon.name, name) then
      return weapon
    end
  end
end

function getWeaponByItem(item)
  for _, weapon in pairs(weapons) do
    if string.find(item, weapon.item) then
      return weapon
    end
  end
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
  
  if not weapons[weapon1] then
    ACSEcho("Weapon " .. weapon1 .. " not found. Check your settings!")
    return
  end

  if not weapons[weapon2] then
    ACSEcho("Weapon " .. weapon2 .. " not found. Check your settings!")
    return
  end
  weapon1 = weapons[weapon1].item
  weapon2 = weapons[weapon2].item


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
  if (side:find("left") and getWeaponByItem(leftHand).shield) or 
     (side:find("right") and getWeaponByItem(rightHand).shield) then
    send("wear shield")
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

-- Line prettying functions
function wieldReplace(weapon, hand)
  extra = hand == "both" and "s" or ""
  setACSLabel("Wielded " .. weapon .. " in " .. hand .. " hand" .. extra .. ".")
end

function unwieldReplace(weapon, hand)
  extra = hand == "both" and "s" or ""
  setACSLabel("Removed " .. weapon .. " from " .. hand .. " hand" .. extra .. ".")
end