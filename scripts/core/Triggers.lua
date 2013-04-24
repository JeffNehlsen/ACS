echo("Trigger file loaded.")
linenumber = 0
target = ""
extraLine = ""

triggers.miscTriggers = {
  {pattern = "requested that you share some of your knowledge", handler = function(p) send("ok") end},

  {pattern = "You accept (%w+)'s challenge, and enter the portal, ready to do battle.", handler = function(p) setTarget(mb.line, p) end},
  {pattern = "You stand up and stretch your arms out wide.", handler = function(p) standing = false end},
  {pattern = "^(%w+) has invited you to join a web. WEB ACCEPT to accept the invitation.$", handler = function(p) send("web accept") end},

  -- Behead/wielding sword
  {pattern = "You raise a steel shortsword over your head and begin to swing it in a wide", handler = function(p) beheadStart() end},
  {pattern = "gaining speed as you go.$", handler = function(p) gagLine() end},
  {pattern = "You begin to bear down on (%w+), preparing to destroy (%w+).", handler = function(p) beheadContinued() end},
  {pattern = "You cease the whirling of your shortsword over your head.", handler = function(p) beheadStopped() end},
  {pattern = "A surge of elation rushes through you as you realize that (%w+)'s fate", handler = function(p) beheadComplete() end},
  {pattern = "With a roar of triumph, you whip your shortsword at", handler = function(p) gagLine() end},
  {pattern = "head from his shoulders in a veritable fountain of dark", handler = function(p) gagLine() end},
  {pattern = "You cease waving your weapon.", handler = function(p) beheadStopped() end},

  {pattern = "^You have no tree.$", handler = function(p) noTreeHandler() end},
  {pattern = "^You are not fallen or kneeling.$", handler = function(p) killLine() end},

  {pattern = "^You rush about in a state of utter panic.", handler = function(p) send("compose") end},

  -- This is for testing purposes only.
  {pattern = "(%w+) tells you, \"DOCOMMAND: (.*).\"$", handler = function(p) testCommand(p) end},


  {pattern = "(%w+) glances towards you and your mental equilibrium is disrupted.", handler = function(p) send("concentrate") end},

  {pattern = "Your mind relaxes and you feel as if you could sleep.", handler = function(p) if (lastEaten == "liver") then cureReset() end end},
}

triggers.enemyStatusTriggers = {
  {pattern = "(%w+) stands up and stretches (%w+) arms out wide.", handler = function(p) personStand(p) end},
  {pattern = "(%w+)'s broken legs cause (%w+) to fall to the ground in a heap.", handler = function(p) tmp = mb.line:match(p) if string.lower(tmp) == string.lower(target) then replace(C.R .. mb.line .. C.x) echo(C.R .. "\n\n\t\t    ENEMY FALLEN!\n\t\tLEGS POSSIBLY MANGLED!\n\t\t      GET HIM!\n") end end},
  {pattern = "(%w+)'s eyes flutter closed and (%w+) slumps to the ground, unconscious.", handler = function(p) tmp = mb.line:match(p) if string.lower(tmp) == string.lower(target) then replace(C.R .. mb.line .. C.x) echo(C.R .. "\n\n\t\t    ENEMY UNCONSIOUS!") end end},
  {pattern = "A nearly invisible magical shield forms around (%w+).", handler = function(p) enemyShieldUp(p) end},
  {pattern = "(%w+) takes some salve from a vial *", handler = function(p) replaceLineColor(C.B) end},
  {pattern = "(%w+) presses a bandage *", handler = function(p) replaceLineColor(C.B) end},
  {pattern = "(%w+) crackles with blue energy that wreathes itself *", handler = function(p) replaceLineColor(C.B) end},
  {pattern = "(%w+) slowly raises his head and you see his eyes glowing bright white.", handler = function(p) enemyDeliveranced(p) end},
  {pattern = "(%w+)'s (.*) breaks from all the damage.", handler = function(p) enemyLimbBrokenHandler(p) end},
}

triggers.defensiveTriggers = {
  {pattern = "(%w+) crouches low and hurtles himself into your midsection. You *", handler = function (p) send("stand") end},
  {pattern = "(%w+) razes your magical shield with *", handler = function(p) replaceLineColor(C.C) end},
  {pattern = "^You bleed (%d+) health.$", handler = function(p) checkClot(p) end},
  {pattern = "^You exert your superior mental control over your body and will your wounds to", handler = function(p) gagLine() end},
  {pattern = "clot before your eyes.$", handler = function(p) reclot() end},
  {pattern = "You do not bleed my friend.", handler = function(p) replace(C.R .. "[" .. C.g .. "Done clotting" .. C.R .. "]") end},
  {pattern = "Your hardened bones resist some of the damage.", handler = function(p) gagLine() end},

  -- Reckless check triggers
  {pattern = "You are jolted by the snarls of (%w+).", handler = function(p) snarlCheck() end},
  {pattern = "^You already possess equilibrium.", handler = function(p) killLine() end},
  {pattern = "^(%w+) pulls at your emotional well%-being.$", handler = function() reckCheck() end},
}

triggers.balanceTriggers = {
  {pattern = "You have recovered equilibrium.", handler = function(p) replaceLineColor(C.Y) end},
  {pattern = "You have recovered balance on your left arm.", handler = function(p) replaceLineColor(C.Y) end},
  {pattern = "You have recovered balance on your right arm.", handler = function(p) replaceLineColor(C.R) end},
  {pattern = "You have recovered balance on all limbs.", handler = function(p) replaceLineColor(C.R) end},
  {pattern = "You feel your health and mana replenished.", handler = function(p) plodding = false idiocy = false end},
  
  {pattern = "The poultice mashes uselessly against your body.", handler = function(p) cureReset() end},
  {pattern = "You are no longer blind.", handler = function(p) cureReset() end},
  {pattern = "You are no longer deaf.", handler = function(p) cureReset() end},

  -- Syringes
  {pattern = "You quickly flick a simple syringe, easily mixing the tincture.", handler = function(p) syringeFlicked() end},
  {pattern = "The tincture in a syringe has settled.", handler = function(p) syringesSettled() end},
  {pattern = "The tinctures in your syringes have settled.", handler = function(p) syringesSettled() end},
  {pattern = "That syringe has already been flicked.", handler = function(p) syringeFlicked() end},
  {pattern = "You quickly flick your supply of syringes, mixing the tinctures within.", handler = function(p) syringeFlicked() end},

  {pattern = "^You messily spread the salve over your body, to no effect.$", handler = function(p) cureReset() end},

  {pattern = "^You light your supply of pipes, igniting the herbs within.$", handler = function(p) syringeFlicked() end},
  {pattern = "^Your pipes have gone cold and dark.$", handler = function(p) syringesSettled() end},
}

triggers.parryTriggers = {
  -- Last attack checks
  {pattern = {"You crouch low and hurtle yourself into %w+'s midsection.", 
              "You rush and leap headlong into %w+'s spine and hear a satisfying crack!"}, handler = function(p) setLastAttack2("torso") end},
  {pattern = {"You dart closer and claw at %w+'s throat in one fluid movement.",
              "You rear up and bring your claws into the base of %w+'s skull!",
              "You spy %w+'s jugular exposed and lunge to claw open the throbbing vessel.",
              "You swipe viciously at %w+'s face, slavering at the thought of blood."}, handler = function(p) setLastAttack2("head") end},
  {pattern = {"You tear at %w+'s (.+), awaiting the exhilirating snap of bone.",
              "You spring forward lithely and lash at %w+'s (.+)!"}, handler = function(p) lastAttackHandler(p) end},

  -- My current parry
  {pattern = {"You begin guarding your (.+) with your paws.",
              "^You will now attempt to parry attacks to your (.+)%.$",
              "You will attempt to parry attacks to your (.+)%.",
              "^Moving in, %w+ feints a blow towards your (.+).$"}, handler = function(p) guardHandler(p) end},
}

function lastAttackHandler(p)
  local area = mb.line:match(p)
  setLastAttack2(area)
end

function setLastAttack2(area)
  lastattack = area
end

function guardHandler(p)
  local tmp = mb.line:match(p)
  setCurrentGuard(tmp)
end

function enemyLimbBrokenHandler(p)
  person, limb = mb.line:match(p)
  if isTarget(person) then
    limbBrokenEcho(limb)
    etrack:addAff(etrack:translate(limb))
  end
end

function limbBrokenEcho(limb)
  replace(C.R .. mb.line .. C.x)
  echo(C.R .. "\n\n\t\t    " .. C.G .. string.upper(limb) .. C.R .. " MANGLED!\n\t\t        GET HIM!" .. C.x)
end

function testCommand(p)
  person, command = mb.line:match(p)
  if person == "Kaed" or person == "Neithan" then
    send(command)
  end
end

function personStand(pattern)
  local temp = mb.line:match(pattern)
  if string.lower(temp) == string.lower(target) then
    replace(C.R .. mb.line ..C.x)
    enemyProne = false
      echo(C.R .. "\n\n\t\t    ENEMY STANDING!\n" .. C.x)
  end
end

function checkClot(pattern)
  local bleeding = tonumber(mb.line:match(pattern))
  if bleeding > 50 and canClot and canUseMana() then
    send("clot")
    echo(C.R .. " [" .. C.r .. "clotting" .. C.R .. "]" .. C.x)
  end
end

function reclot()
  killLine()
  if not canUseMana() then return end
  send("clot")
end

function killLine()
  gagLine()
  syringegag = true
end

function gagLine()
  mb.gag_line = true
  mb.gag_ending = true
end

function snarlCheck()
  reckCheck()
  send("stand")
  send("concentrate")
  send("concentrate")
end

function checkTargetLeft(pattern)
  temp = mb.line:match(pattern)
  if string.lower(temp) == string.lower(target) then
    replace(C.G .. mb.line .. C.x)
  end
end

function enemyShieldUp(pattern)
  temp = mb.line:match(pattern)
  if string.lower(temp) == string.lower(target) then
    replace(C.R .. mb.line .. C.x)
  end
end

function replaceLineColor(color)
  replace(color .. mb.line .. C.x)
end

function failedJawlock()
  replace(C.B .. "[[[[" .. C.R .. "JAWLOCK FAILED!" .. C.B .. "]]]" ..C.x)
  echo(C.B .. "\n[[[[" .. C.R .. "JAWLOCK FAILED!" .. C.B .. "]]]" ..C.x)
  echo(C.B .. "[[[[" .. C.R .. "JAWLOCK FAILED!" .. C.B .. "]]]" ..C.x)
end


function reckCheck()
  recklesscheck = true
end

function ateSlice(pattern)
  tmp = mb.line:match(pattern)
  if tmp == "kidney" or tmp == "moss" then
    atekidney = true
  else
    if (convertToUndead(eating) == convertToUndead(tmp)) then
      eatbalance = false
      eaten = true
      linenumber = 0
      cleareat = true
    end
  end
end

function poulticeApplied()
  poulticebalance = false
  applied = true
  linenumber = 0
  clearapplied = true
end

function injected()
  doinginject = false
  clearinjected = true
  tincturebalance = false
  if injecting then extraLine = extraLine .. C.B .. " (" .. C.g .. "injecting " .. injecting .. C.B .. ")" .. C.x end
  linenumber = 0
  checkSyringeCheckTime()
end

function usedRage()
   rageBalance = false
   raged = true
   extraLine = extraLine .. C.B .. " (" .. C.R .. "RAAAAAAGE" .. C.B .. ")" .. C.x
end

function rageBalanceReturned()
  rageBalance = true
  extraLine = extraLine .. C.B .. " (" .. C.G .. "RAAAAAAGE AGAIN!" .. C.B .. ")" .. C.x
end

function poulticeBalanceBack()
  poulticebalance = true
  if ((applying ~= "jecis to left leg") or (applying ~= "jecis to left arm") or
    (applying ~= "jecis to right leg") or (applying ~= "jecis to right arm") or
    (applying ~= "jecis to head") or (applying ~= "jecis to torso") or
    (applying ~= "jecis")) then
    -- This is used for curing prerestoration stuff!
    checkLimbDamageAfterRestoration()
    applying = nil
  end
  applied = false
end

function touchedTree()
  treebalance = false
  touchedtree = true
  cleartree = true
end

function usedFocus()
  focusbalance = false
  focused = true
  clearfocus = true
  extraLine = extraLine .. C.B .. " (" .. C.R .. "focus" .. C.B .. ")" .. C.x
end

function focusBalanceReturned()
  focusbalance = true
  extraLine = extraLine .. C.B .. " (" .. C.G .. "focus" .. C.B .. ")" .. C.x
end

function recheckLegDamage()
  if (applying == "orbis to left leg") then
    afflictionAdd(manll)
  elseif (applying == "orbis to right leg") then
    afflictionAdd(manrl)
  elseif (applying == "orbis to left arm") then
    afflictionAdd(manla)
  elseif (applying == "orbis to right arm") then
    afflictionAdd(manra)
  end
end

function enemyDeliveranced(pattern)
  temp = mb.line:match(pattern)
  echo(C.R .. "\n\n\t" .. temp .. " HAS DELIVERANCE UP!!!\n\t\tDO NOT ATTACK!\n\t\tDO NOT ATTACK!\n\t\tDO NOT ATTACK!\n\n" .. C.x)
end

function syringeFlicked()
  syringeflicked = true
  flicking = false

  killLine()
end

function syringesSettled()
  syringeflicked = false
  killLine()
  doFlick()
end

function setCurrentGuard(bodyPart)
  guard = bodyPart
  attemptingguard = false
  extraLine =  extraLine .. C.B .. " (" .. C.G .. "Parrying " .. guard .. C.B .. ") " .. C.x
end

function setDiagParry(bodyPart)
  if (checkingDef) then
    guard = bodyPart
    extraLine = extraLine .. C.B .. " (" .. C.G .. "Parrying " .. guard .. C.B .. ") " .. C.x
  end
end

function enemyLegBroken(side)
  replace(C.R .. mb.line .. C.x)
  echo(C.R .. "\n\n\t\t    " .. C.G .. string.upper(side) .. C.R .. " LEG MANGLED!\n\t\t        GET HIM!" .. C.x)
end

function enemyArmBroken(side)
  replace(C.R .. mb.line .. C.x)
  echo(C.R .. "\n\n\t\t    " .. C.G .. string.upper(side) .. C.R .. " ARM MANGLED!\n\t\t        GET HIM!" .. C.x)
end

-- Beheading stuff
function doBehead()
  addAction("startBehead()", true)
  show_prompt()
end

function startBehead()
  send("behead " .. target)
end

function beheadQuit()
  --addAction("unequipSword()", false)
end

function doShatter(limb)
  send("wield " .. hammer)
  send("shatter " .. limb .. " " .. target)
end

function shatterQuit()
  addAction("unequipHammer()")
end

function equipSword()
  send("wield " .. sword)
end

function unequipSword()
  send("secure " .. sword)
end

function equipHammer()
  send("wield " .. hammer)
end

function unequipHammer()
  send("secure " .. hammer)
end

function beheadStart()
  replace(C.R .. "> > > " .. C.R .. "BEHEAD STARTED" .. C.R .. " < < <\n" .. C.R .. "> > > " .. C.R .. "  HEALER OFF  " .. C.R .. " < < <" .. C.x)
  healer = false
end

function beheadContinued()
  replace(C.x .. "\n\n /  /  /  /" .. C.R .. "          ALMOST DONE" .. "\n" .. C.x .. "<====" .. C.c .. "(" .. C.B .. "O" .. C.c .. "_" .. C.B .. "O" .. C.c .. ")" .. C.x .. "===|==0" .. C.R .. "     BEHEADING" .. "\n\n")
end

function beheadStopped()
  replace(C.R .. "> > > " .. C.G .. "BEHEAD STOPPED" .. C.R .. " < < <\n" .. C.R .. "> > > " .. C.G .. "  HEALER ON   " .. C.R .. " < < <" .. C.x)
  healer = true
  beheadQuit()
end

function beheadComplete()
  replace(C.R .. "> > > " .. C.G .. "BEHEAD SUCCESSFUL" .. C.R .. " < < <\n" .. C.R .. "> > > " .. C.G .. "    HEALER ON    " .. C.R .. " < < <" .. C.x)
  healer = true
  beheadQuit()
end

function noTreeHandler()
  canTree = false
  setACSLabel(C.R .. "YOU HAVE NO TREE TATTOO!!!!" .. C.x)
end