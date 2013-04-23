echo("Luminary file loaded. Fire it up!")
--Attack system aliases, etc.

whipBalance = true
whipping = false
enemyImpaled = false
enemyProne = false
infuse = 0

if classType == "luminary" then
aliases.classAliases = {
  {pattern = "^ef$", handler = function(i, p) eform() end},
  {pattern = "^noef$", handler = function(i, p) noeform() end},
}

aliases.attackAliases = {
  --{pattern = "^$", handler = function(i,p)  end},
  {pattern = "^ar$", handler = function(i,p) shred("") end}, 
  {pattern = "^aa$", handler = function(i,p) shred("left arm") end},
  {pattern = "^dd$", handler = function(i,p) shred("right arm") end},
  {pattern = "^zz$", handler = function(i,p) shred("left leg") end},
  {pattern = "^cc$", handler = function(i,p) shred("right leg") end},
  {pattern = "^ss$", handler = function(i,p) shred("torso") end},
  {pattern = "^ww$", handler = function(i,p) shred("head") end},
  
 {pattern = "^aa2$", handler = function(i,p) shred2("left arm") end},
  {pattern = "^dd2$", handler = function(i,p) shred2("right arm") end},
  {pattern = "^zz2$", handler = function(i,p) shred2("left leg") end},
  {pattern = "^cc2$", handler = function(i,p) shred2("right leg") end},
  {pattern = "^ss2$", handler = function(i,p) shred2("torso") end},
  {pattern = "^ww2$", handler = function(i,p) shred2("head") end},
  {pattern = "^a2$", handler = function(i,p) shred2("left arm") end},
  {pattern = "^d2$", handler = function(i,p) shred2("right arm") end},
  {pattern = "^z2$", handler = function(i,p) shred2("left leg") end},
  {pattern = "^c2$", handler = function(i,p) shred2("right leg") end},
  {pattern = "^s2$", handler = function(i,p) shred2("torso") end},
  {pattern = "^w2$", handler = function(i,p) shred2("head") end},
  
  {pattern = "^ad$", handler = function(i,p) elemental("left arm", "right arm") end},
  {pattern = "^zc$", handler = function(i,p) elemental("left leg", "right leg") end},
  {pattern = "^az$", handler = function(i,p) elemental("left arm", "left leg") end},
  {pattern = "^dc$", handler = function(i,p) elemental("right leg", "right arm") end},
  {pattern = "^dz$", handler = function(i,p) elemental("right arm", "left leg") end},
  {pattern = "^ac$", handler = function(i,p) elemental("left arm", "right leg") end},
  {pattern = "^ws$", handler = function(i,p) elemental("head", "torso") end},
  {pattern = "^wa$", handler = function(i,p) elemental("left arm", "head") end},
  {pattern = "^wd$", handler = function(i,p) elemental("right arm", "head") end},
  {pattern = "^wz$", handler = function(i,p) elemental("left leg", "head") end},
  {pattern = "^wc$", handler = function(i,p) elemental("right leg", "head") end},
  {pattern = "^sa$", handler = function(i,p) elemental("left arm", "torso") end},
  {pattern = "^sd$", handler = function(i,p) elemental("right arm", "torso") end},
  {pattern = "^sz$", handler = function(i,p) elemental("left leg", "torso") end},
  {pattern = "^cs$", handler = function(i,p) elemental("right leg", "torso") end},
  
  {pattern = "^im$", handler = function(i,p) impale() end},
  {pattern = "^imp$", handler = function(i,p) impale() end},
  {pattern = "^sh$", handler = function(i,p) stShatter() end},
  {pattern = "^fl$", handler = function(i,p) flood() end},
  {pattern = "^sl$", handler = function(i,p) slice() end},
  {pattern = "^coc$", handler = function(i,p) cocoon() end},
  {pattern = "^co$", handler = function(i,p) cocoon() end},
  {pattern = "^coc2$", handler = function(i,p) cocoon2() end},
  {pattern = "^co2$", handler = function(i,p) cocoon2() end},
  {pattern = "^aco2$", handler = function(i,p) addAction("cocoon2()", true) end},
  {pattern = "^qu$", handler = function(i,p) quake() end},
  {pattern = "^inf$", handler = function(i,p) send("infuse") end},
  {pattern = "^xx$", handler = function(i,p) doTrip() end},
  
  {pattern = "^ch$", handler = function(i,p) send("chasm " .. target) end},
  
  {pattern = "^gpm (%w+)$", handler = function(i,p) gpush(i,p) end},
  {pattern = "^gc$", handler = function(i,p) send("golem call") end},
  {pattern = "^cg$", handler = function(i,p) send("golem call") end},
  {pattern = "^att$", handler = function(i,p) golAttack() end},
  {pattern = "^pass$", handler = function(i,p) golPassive() end},
  {pattern = "^fol$", handler = function(i,p) send("order golem follow me") end},
}


triggers.attackTriggers = {
  --{pattern = "^$", handler = function(p)  end},
  {pattern = "Your elegant crozier shifts into a whip of sand and you send it to scourge", handler = function(p) whipUsed() end},
  {pattern = "^(%w+)\.$", handler = function(p) gagWhipSecond(p) end},
  {pattern = "You are able to form a whip of sand once again.", handler = function(p) whipBalance = true end},
  
  {pattern = "The stalagmite spears through (%w+), impaling (%w+) upon it.$", handler = function(p) impaleHandler(p) end},
  {pattern = "^(%w+) has writhed free from the stalagmite that impaled (%w+).$", handler = function(p) unimpaleHandler(p) end},
  {pattern = "^You focus your mind on the stalagmite impaling (%w+) and, harnessing", handler = function(p) stalShatterHandler(p) end},
  
  {pattern = "^(%w+) is knocked to the ground by the force of the golem's blow.$", handler = function(p) gpoundHandler(p) end},
  {pattern = "the earth, cause it to shatter and then explode. (%w+) screams out in", handler = function(p) gagLine() end},
  {pattern = "shards of stone tear through (%w+) body.$", handler = function(p) gagLine() end},
  {pattern = "You gesture with an elegant crozier and a thin rope of sand leaps out and", handler = function(p) tripHandler() end},
  {pattern = "^(%w+) to the ground.$", handler = function(p) gagLine() end},
  
  {pattern = "^The Earth enveloping your crozier cracks and falls off.$", handler = function(p) unInfused() end},
  {pattern = "^You may once again infuse your crozier with the strength of Earth.$", handler = function(p) infuseReady() end},
  {pattern = "^You summon forth the Earth to empower your crozier, covering it in a coat", handler = function(p) infused() end},
  {pattern = "^Your crozier is already infused with the Strength of Earth.$", handler = function(p) infused() end},
  {pattern = "^rock.$", handler = function(p) gagLine() end},
  
  {pattern = "You call upon the earth and summon a mighty stalagmite to impale (%w+).", handler = function(p) impaling = true add_timer(1, function() impaling = false end) end},
  
  -- Sand curse
  {pattern = "Evoking the power of the earth through an elegant crozier, your eyes roll back within your skull as a whispered mantra escapes from your lips. Feeling your powers well within the trance, you open your eyes to (%w+)", handler = function(p) sandcurseHandler(p) end},
}
end

function sandcurseHandler(p)
  person = mb.line:match(p)
  setACSLabel(C.g .. person .. " sandcursed!")
  etrack:addAff("sandrot")
end

function unInfused()
  infuse = 0
  setACSLabel(C.R .. "UNINFUSED!")
end

function infuseReady()
  infuse = 1
  setACSLabel(C.Y .. "INFUSE READY!")
end

function infused()
  infuse = 2
  setACSLabel(C.G .. "INFUSED!")
end

function gagWhipSecond(p)
  tmp = mb.line:match(p)
  if whipping and tmp == target then
    gagLine()
  end
end

function whipUsed()
  whipping = true
  whipBalance = false
end

function whipBalanceBack()
  whipBalance = true
end

function eform()
  send("earthenform embrace")
end

function noeform()
  send("earthenform release")
end

function flood()
  sand("flood")
end

function cocoon()
  sandwhip("mind")
  sand("cocoon " .. target)
  ghp()
end

function cocoon2()
  sandwhip("mind")
  sand("cocoon " .. target)
  gpound()
end

function sandwhip(tar)
  if tar == nil or tar ~= "mind" then tar = "body" end
  if whipBalance then
    sand("whip " .. target .. " " .. tar)
  end
end

function shred(limb)
  sandwhip("mind")
  doInfuse()
  sand("shred " .. target .. " " .. limb)
  ghp()
end

function shred2(limb)
  sandwhip()
  doInfuse()
  sand("shred " .. target .. " " .. limb)
  gpound()
end

function doInfuse()
  if infuse == 1 then send("infuse") end
end

function elemental(limb1, limb2)
  sandwhip("mind")
  sand("elemental " .. target .. " " .. limb1 .. " " .. limb2)
  ghp()
end

function sand(skill)
  doWield(crozier, tower)
  send("sand " .. skill)
end

function slice()
  sand("slice " .. target)
end

function impale()
  doWield(flail, crozier)
  if whipBalance then send("sand whip " .. target .. " mind") end
  send("impale " .. target)
  ghp()
end

function stShatter()
  sandwhip("mind")
  doWield(flail, crozier)
  send("shatter stalagmite in " .. target)
  ghp()
end

function stShatter2()
  if enemyImpaled then
    sandwhip("mind")
    doWield(flail, crozier)
    send("shatter stalagmite in " .. target)
    ghp()
  elseif enemyProne then
    impale()
  else
    --cocoon2()
  end
end

function impaleHandler(p)
  tmp = mb.line:match(p)
  if tmp == target and impaling then
    enemyImpaled = true
    addAction("stShatter2()", true)
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
  addAction("impaleCheck()", true)
end

function gpoundHandler(p)
  tmp = mb.line:match(p)
  if tmp == target then
    enemyProne = true
    addAction("impaleCheck()", true)
    replace(C.R .. target .. " knocked down!" .. C.x)
  end
end

function tripHandler()
  enemyProne = true
  addAction("impaleCheck()", true)
  replace(C.R .. target .. " knocked down!" .. C.x)
end

function impaleCheck()
  if enemyProne then
    impale()
  end
end

function quake()
  doWield(flail, tower)
  send("quake")
end

function doTrip()
  sandwhip()
  sand("trip " .. target)
  golemRip()
end

-- Golem stuff
function golAttack()
  send("order golem attack " .. target)
end

function golPassive()
  send("order golem passive")
end

function gpush(i,p)
  dir = i:match(p)
  send("golem push " .. target .. " " .. dir)
end

function gbarge(i,p)
  dir = i:match(p)
  send("golem barge " .. dir)
end

function golemRip()
  send("golem rip " .. target)
end

function gslice()
  send("golem slice " .. target)
end

function ghp()
  send("golem heartpunch " .. target)
end

function gpound()
  send("golem pound")
end

