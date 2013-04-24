echo("Teradrim file loaded. Lets rock!")
--Attack system aliases, etc.

enemyImpaled = false
enemyProne = false
Infuse = {state = 0, DOWN = 0, READY = 1, UP = 2}

class.bashAttack = function()
  send("sand shred " .. selectedTarget)
end

class.setup = function()
  if not balances.whip then balances.whip = {able = true, trying = false} end
end

class.tLocked = function()
  if balances:check({"balance", "equilibrium"}) then
    send("absorb")
    balances:take("equilibrium")
  end
end

aliases.classAliases = {
  {pattern = "^ef$", handler = function(i, p) eform() end},
  {pattern = "^noef$", handler = function(i, p) noeform() end},
  {pattern = "^rockcrush (%d+)$", handler = function(i,p) doRockCrush(i,p) end},
}

aliases.attackAliases = {
  -- {pattern = "^$", handler = function(i,p)  end},
  {pattern = "^ham$", handler = function(i,p) eHammer() end}, 
  {pattern = "^sb$", handler = function(i,p) eSkullBash() end},
  {pattern = "^ar$", handler = function(i,p) eBatter() end},
  {pattern = "^guts$", handler = function(i,p) eGutsmash() end},
  {pattern = "^pulp$", handler = function(i,p) ePulp() end},
  {pattern = "^over$", handler = function(i,p) eOverhand() end},
  {pattern = "^ep (%w+)$", handler = function(i,p) ePass(i,p) end},

  {pattern = "^aa$", handler = function(i,p) shred("left arm") end},
  {pattern = "^dd$", handler = function(i,p) shred("right arm") end},
  {pattern = "^zz$", handler = function(i,p) shred("left leg") end},
  {pattern = "^cc$", handler = function(i,p) shred("right leg") end},
  {pattern = "^ss$", handler = function(i,p) shred("torso") end},
  {pattern = "^ww$", handler = function(i,p) shred("head") end},
  
  {pattern = "^aa?2$", handler = function(i,p) shred2("left arm") end},
  {pattern = "^dd?2$", handler = function(i,p) shred2("right arm") end},
  {pattern = "^zz?2$", handler = function(i,p) shred2("left leg") end},
  {pattern = "^cc?2$", handler = function(i,p) shred2("right leg") end},
  {pattern = "^ss?2$", handler = function(i,p) shred2("torso") end},
  {pattern = "^ww?2$", handler = function(i,p) shred2("head") end},
  
--  {pattern = "^ad$", handler = function(i,p) elemental("left arm", "right arm") end},
--  {pattern = "^zc$", handler = function(i,p) elemental("left leg", "right leg") end},
--  {pattern = "^az$", handler = function(i,p) elemental("left arm", "left leg") end},
--  {pattern = "^dc$", handler = function(i,p) elemental("right leg", "right arm") end},
--  {pattern = "^dz$", handler = function(i,p) elemental("right arm", "left leg") end},
--  {pattern = "^ac$", handler = function(i,p) elemental("left arm", "right leg") end},
--  {pattern = "^ws$", handler = function(i,p) elemental("head", "torso") end},
--  {pattern = "^wa$", handler = function(i,p) elemental("left arm", "head") end},
--  {pattern = "^wd$", handler = function(i,p) elemental("right arm", "head") end},
--  {pattern = "^wz$", handler = function(i,p) elemental("left leg", "head") end},
--  {pattern = "^wc$", handler = function(i,p) elemental("right leg", "head") end},
--  {pattern = "^sa$", handler = function(i,p) elemental("left arm", "torso") end},
--  {pattern = "^sd$", handler = function(i,p) elemental("right arm", "torso") end},
--  {pattern = "^sz$", handler = function(i,p) elemental("left leg", "torso") end},
--  {pattern = "^cs$", handler = function(i,p) elemental("right leg", "torso") end},
  
  {pattern = "^imp?$", handler = function(i,p) impale() end},
  {pattern = "^sh$", handler = function(i,p) stShatter() end},
  {pattern = "^flo?o?d?$", handler = function(i,p) flood() end},
  {pattern = "^sl$", handler = function(i,p) slice() end},
  {pattern = "^coc?$", handler = function(i,p) cocoon() end},
  {pattern = "^coc?2$", handler = function(i,p) cocoon2() end},
  {pattern = "^qu$", handler = function(i,p) quake() end},
--  {pattern = "^inf$", handler = function(i,p) send("infuse") end},
  {pattern = "^xx$", handler = function(i,p) doTrip() end},

  {pattern = "^storm$", handler = function(i,p) sand("storm") end},
  {pattern = "^spike$", handler = function(i,p) sand("spikes") end},
  {pattern = "^dist$", handler = function(i,p) sand("distort") end},
  {pattern = "^surge (%w+)$", handler = function(i,p) sSurge(i,p) end},
  {pattern = "^meld$", handler = function(i,p) sand("meld") end},
  {pattern = "^pillar$", handler = function(i,p) sand("pillar") end},
  {pattern = "^conf$", handler = function(i,p) sand("confound") end},
  {pattern = "^sash (%w+)$", handler = function(i,p) sShield(i,p) end},
  {pattern = "^sash$", handler = function(i,p) sand("shield") end},
  {pattern = "^dess$", handler = function(i,p) sand("desiccate") end},
  {pattern = "^blast$", handler = function(i,p) sand("blast") end},

  {pattern = "^imbs$", handler = function(i,p) send("earth imbue stonefury") end},
  {pattern = "^imbe$", handler = function(i,p) send("earth imbue erosion") end},
  {pattern = "^imbw$", handler = function(i,p) send("earth imbue will") end},

  {pattern = "^trap$", handler = function(i,p) sTrap() end},
  {pattern = "^sm (%w+)$", handler = function(i,p) eSmash(i,p) end},
  {pattern = "^gra$", handler = function(i,p) eGrasp() end},
  {pattern = "^sli$", handler = function(i,p) doSlice() end},
  {pattern = "^scu$", handler = function(i,p) sCurse() end},
  
  {pattern = "^ch$", handler = function(i,p) send("earth chasm " .. target) end},
  
  {pattern = "^gpm (%w+)$", handler = function(i,p) gpush(i,p) end},
  {pattern = "^gsm (%w+)$", handler = function(i,p) gsmash(i,p) end},
  {pattern = "^gsm$", handler = function(i,p) send("golem smash") end},
  {pattern = "^gmo$", handler = function(i,p) golemMoan() end},
  {pattern = "^gre$", handler = function(i,p) gRecover() end},

  {pattern = "^gc$", handler = function(i,p) send("golem call") end},
  {pattern = "^cg$", handler = function(i,p) send("golem call") end},
  {pattern = "^att$", handler = function(i,p) golAttack() end},
  {pattern = "^pass$", handler = function(i,p) golPassive() end},
  {pattern = "^fol$", handler = function(i,p) send("order golem follow me") end},
}


triggers.attackTriggers = {
  --{pattern = "^$", handler = function(p)  end},
  {pattern = "^Your elegant crozier shifts into a whip of sand and you send it to scourge (%w+).$", handler = function(p) whipUsed() end},
  {pattern = "^You are able to form a whip of sand once again.$", handler = function(p) whipBalanceBack() end},
  
  {pattern = "The stalagmite spears through (%w+), impaling (%w+) upon it.$", handler = function(p) impaleHandler(p) end},
  {pattern = "^(%w+) has writhed free from the stalagmite that impaled (%w+).$", handler = function(p) unimpaleHandler(p) end},
  {pattern = "^You focus your mind on the stalagmite impaling (%w+) and, harnessing the power of the earth, cause it to shatter and then explode. (%w+) screams out in agony as countless shards of stone tear through .* body.$", handler = function() stalShatterHandler(p) end},
  {pattern = "^(%w+) is knocked to the ground by the force of the golem's blow.$", handler = function(p) gpoundHandler(p) end},
  {pattern = "^You gesture with an elegant crozier and a thin rope of sand leaps out and pulls (%w+) to the ground.$", handler = function(p) tripHandler() end},
  
  {pattern = "^The Earth enveloping your crozier cracks and falls off.$", handler = function(p) unInfused() end},
  {pattern = "^You may once again infuse your crozier with the strength of Earth.$", handler = function(p) infuseReady() end},
  {pattern = "^You summon forth the Earth to empower your crozier, covering it in a coat", handler = function(p) infused() end},
  {pattern = "^Your crozier is already infused with the Strength of Earth.$", handler = function(p) infused() end},
  
  {pattern = "^You call upon the earth and summon a mighty stalagmite to impale (%w+).$", handler = function(p) impaling = true onPrompt(function() impaling = false end) end},
  
  -- Sand curse
  {pattern = "^Evoking the power of the earth through an elegant crozier, your eyes roll back within your skull " .. 
             "as a whispered mantra escapes from your lips. Feeling your powers well within the trance, you open " ..
             "your eyes to (%w+), streams of sand issues forth from the ground, merging with his every limb and " .. 
             "infusing them with your will.$", handler = function(p) sandcurseHandler(p) end},

  -- Earth Pass
  {pattern = "You place a hand upon the ground, directing your senses into the earth as you search for a path", handler = function(p) stopHeal() end},
  {pattern = "As your concentration wavers, your senses quickly flee the earth.$", handler = function(p) startHeal() end},
  {pattern = "Letting your form meld and become one with the earth, you transport yourself through rock and soil", handler = function(p) startHeal() end},
}

function doRockCrush(i,p)
  local amt = i:match(p)
  for i=1,amt do 
    actions:add(function() send("rockcrush rock") end, baleq, {"balance"}) 
  end
end

function sandcurseHandler(p)
  local person = mb.line:match(p)
  setACSLabel(C.g .. person .. " sandcursed!")
  etrack:addAff("sandrot")
end

function unInfused()
  Infuse.state = Infuse.DOWN
  setACSLabel(C.R .. "UNINFUSED!")
end

function infuseReady()
  Infuse.state = Infuse.READY
  setACSLabel(C.Y .. "INFUSE READY!")
end

function infused()
  Infuse.state = Infuse.UP
  setACSLabel(C.G .. "INFUSED!")
end

function whipUsed()
  balances:complete("whip")
end

function whipBalanceBack()
  balances:give("whip")
end

function eform()
  send("earthenform embrace")
end

function noeform()
  send("earthenform release")
end

function ePass(i,p)
  dir = i:match(p)
  send("earth pass " .. dir)
end


-------------
-- Handler --
-------------

function impaleHandler(p)
  tmp = mb.line:match(p)
  if tmp == target and impaling then
    enemyImpaled = true
    actions:add(function() stShatter2() end, baleq, {"balance"})
    replace(C.r .. target .. " impaled!" .. C.x)
  end
end

function unimpaleHandler(p)
  tmp = mb.line:match(p)
  if tmp == target then
    enemyImpaled = false
    replace(C.R .. target .. " writhed free!" .. C.x)
  end
end

function stalShatterHandler(p)
  enemyImpaled = false
  replace(C.R .. string.upper(target) .. " EXPLOOOODED!" .. C.x)
  actions:add(function() impaleCheck() end, baleq, {"balance"});
end

function tripHandler()
  enemyProne = true
  actions:add(function() impaleCheck() end, baleq, {"balance"});
end

function impaleCheck()
  if enemyProne then
    impale()
  end
end


------------------
-- Combo Skills --
------------------

function doTrip()
  sScourge()
  sand("trip " .. target)
end

function doSlice()
  slice()
  sWhip()
end

function shred(limb)
  sWhip()
  sand("shred " .. target .. " " .. limb)
end

function shred2(limb)
  sWhip()
  sand("shred " .. target .. " " .. limb)
end

function elemental(limb1, limb2)
  sandwhip("mind")
  sand("elemental " .. target .. " " .. limb1 .. " " .. limb2)
  ghp()
end

function cocoon()
  sWhip()
  sQuicksand()
end

function cocoon2()
  sWhip()
  sQuicksand()
end

-----------------
-- Desiccation --
-----------------

function flood()
  sand("flood")
end

function sTrap()
  send("sand trap " .. target)
end

function sCurse()
  send("sand curse " .. target)
end

function sandwhip(tar)
  if tar == nil or tar ~= "mind" then tar = "body" end
  if balances:check("whip") then
    balances:take("whip")
    sand("whip " .. target .. " " .. tar)
  end
end

function sQuicksand()
  send("sand quicksand " .. target)
end

function sWhip()
  send("sand whip " .. target)
end

function sScourge()
  send("sand scourge " .. target)
end

function doInfuse()
  if Infuse.state == Infuse.READY then send("infuse") end
end

function sand(skill)
  send("sand " .. skill)
end

function slice()
  sand("sand slice " .. target)
end

function sWave()
  sand("sand wave " .. target)
end

function sShield(i,p)
  dir = i:match(p)
  send("sand shield " .. dir)
end

function sSurge(i,p)
  dir = i:match(p)
  send("sand surge " .. dir)
end

function eSmash(i,p)
  dir = i:match(p)
  send("smash " .. target .. " " .. dir)
end



----------------
-- Terramancy --
----------------

function eGrasp()
  send("earth grasp " .. target)
end

function eHammer()
  send("earth hammer " .. target)
end

function eBatter()
  send("earth batter " .. target)
end

function eOverhand()
  send("earth overhand " .. target)
end

function ePulp()
  send("earth pulp " .. target)
end

function eGutsmash()
  send("earth gutsmash " .. target)
end

function eSkullBash()
  send("earth skullbash " .. target)
end

function impale()
  sScourge()
  send("earth impale " .. target)
end

function stShatter()
  sScourge()
  send("earth stonevice " .. target)
end

function stShatter2()
  if enemyImpaled then
    sScourge()
    send("earth stonevice " .. target)
  elseif enemyProne then
    impale()
  else
    --cocoon2()
  end
end

function quake()
  send("earth quake")
end


--------------------------------
--  GOLEM ANIMATION COMMANDS  --
--------------------------------
function golAttack()
  send("order golem attack " .. target)
end

function golPassive()
  send("order golem passive")
end

function gpoundHandler(p)
  local tmp = mb.line:match(p)
  if tmp == target then
    enemyProne = true
    actions:add(function() impaleCheck() end, baleq, {"balance"});
    replace(C.R .. target .. " knocked down!" .. C.x)
  end
end

function gpush(i,p)
  dir = i:match(p)
  send("golem push " .. target .. " " .. dir)
end

function gbarge(i,p)
  dir = i:match(p)
  send("golem barge " .. dir)
end

function gsmash(i,p)
  dir = i:match(p)
  send("golem smash " .. dir)
end

function golemRip()
  balances:take("equilibrium")
  send("golem rip " .. target)
end

function gRecover()
  balances:take("equilibrium")
  send("golem recover")
end

function golemMoan()
  balances:take("equilibrium")
  send("golem moan " .. target)
end

function golemRoar()
  balances:take("equilibrium")
  send("golem roar " .. target)
end

function gslice()
  balances:take("equilibrium")
  send("golem slice " .. target)
end

function ghp()
  balances:take("equilibrium")
  send("golem heartpunch " .. target)
end

function gpound()
  balances:take("equilibrium")
  send("golem pound")
end