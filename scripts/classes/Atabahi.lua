echo("Atabahi attack system ready to kill.")
--Attack system aliases, etc.
target = "target"
autorip = true
cycleHowls = true
howlingBalance = true
currentHowls = 0
howls = {}


aliases.classAliases = {
  {pattern = "^lyc$", handler = function(i, p) mutateLycan() end},
  {pattern = "^nolyc$", handler = function(i, p) mutateNormal() end},
  
  -- Getting into the den
  
}

--Hunting Claw
aliases.classAliases = {
   {pattern = "^ar$", handler = function(i, p) doAttack("bclaw", "bclaw") end},
}

aliases.attackAliases = {
  -- Hamstring/Rend
  {pattern = "^hm$", handler = function(i, p) doAttack("hamstringl", "hamstringr") end},
  {pattern = "^re$", handler = function(i, p) doAttack("rendl", "rendr") end},
  {pattern = "^hl$", handler = function(i, p) doAttack("hamstringl", "rendl") end},
  {pattern = "^rl$", handler = function(i, p) doAttack("hamstringl", "rendl") end},
  {pattern = "^hr$", handler = function(i, p) doAttack("hamstringr", "rendr") end},
  {pattern = "^rr$", handler = function(i, p) doAttack("hamstringr", "rendr") end},
  
  -- Mangling limbs
  {pattern = "^mll$", handler = function(i,p) doAttack("manglell", "none") end},
  {pattern = "^manll$", handler = function(i,p) doAttack("manglell", "none") end},
  {pattern = "^mrl$", handler = function(i,p) doAttack("manglerl", "none") end},
  {pattern = "^manrl$", handler = function(i,p) doAttack("manglerl", "none") end},
  {pattern = "^mla$", handler = function(i,p) doAttack("manglela", "none") end},
  {pattern = "^manla$", handler = function(i,p) doAttack("manglela", "none") end},
  {pattern = "^mra$", handler = function(i,p) doAttack("manglera", "none") end},
  {pattern = "^manra$", handler = function(i,p) doAttack("manglera", "none") end},
  
  -- Destroying limbs
  {pattern = "^dll$", handler = function(i,p) doAttack("destroyll", "none") end},
  {pattern = "^desll$", handler = function(i,p) doAttack("destroyll", "none") end},
  {pattern = "^drl$", handler = function(i,p) doAttack("destroyrl", "none") end},
  {pattern = "^desrl$", handler = function(i,p) doAttack("destroyrl", "none") end},
  {pattern = "^dla$", handler = function(i,p) doAttack("destroyla", "none") end},
  {pattern = "^desla$", handler = function(i,p) doAttack("destroyla", "none") end},
  {pattern = "^dra$", handler = function(i,p) doAttack("destroyra", "none") end},
  {pattern = "^desra$", handler = function(i,p) doAttack("destroyra", "none") end},
  
  -- Misc combos
  {pattern = "^spc$", handler = function(i,p) combo("spinalcrack", "skullwhack") end},
  {pattern = "^bdp$", handler = function(i,p) combo("bodypunch", "bodypunch") end},
  {pattern = "^jug$", handler = function(i,p) combo("jugularclaw", "jugularclaw") end},
  {pattern = "^skw$", handler = function(i,p) combo("skullwhack", "skullwhack") end},
  {pattern = "^bpsw$", handler = function(i,p) combo("bodypunch", "skullwhack") end},
  {pattern = "^bpsc$", handler = function(i,p) combo("bodypunch", "spinalcrack") end},
  {pattern = "^jb$", handler = function(i,p) combo("jugular", "bodypunch") end},
  {pattern = "^jug2$", handler = function(i,p) combo("jugular", "bodypunch") end},

  -- Targeting w/ claw
  {pattern = "^aa$", handler = function(i,p) doAttack("clawla", "clawla") end},
  {pattern = "^dd$", handler = function(i,p) doAttack("clawra", "clawra") end},
  {pattern = "^zz$", handler = function(i,p) doAttack("clawll", "clawll") end},
  {pattern = "^cc$", handler = function(i,p) doAttack("clawrl", "clawrl") end},
  {pattern = "^zc$", handler = function(i,p) doAttack("clawll", "clawrl") end},
  {pattern = "^cz$", handler = function(i,p) doAttack("clawll", "clawrl") end},
  {pattern = "^ad$", handler = function(i,p) doAttack("clawla", "clawra") end},
  {pattern = "^da$", handler = function(i,p) doAttack("clawla", "clawra") end},
  {pattern = "^az$", handler = function(i,p) doAttack("clawla", "clawll") end},
  {pattern = "^za$", handler = function(i,p) doAttack("clawla", "clawll") end},
  {pattern = "^dc$", handler = function(i,p) doAttack("clawra", "clawrl") end},
  {pattern = "^cd$", handler = function(i,p) doAttack("clawra", "clawrl") end},
  {pattern = "^ac$", handler = function(i,p) doAttack("clawla", "clawrl") end},
  {pattern = "^ca$", handler = function(i,p) doAttack("clawla", "clawrl") end},
  {pattern = "^dz$", handler = function(i,p) doAttack("clawra", "clawll") end},
  {pattern = "^zd$", handler = function(i,p) doAttack("clawra", "clawll") end},
  {pattern = "^fl$", handler = function(i,p) send("flurry " .. target) end},
  
  {pattern = "^ww$", handler = function(i,p) combo("skullwhack", "skullwhack") end},
  {pattern = "^skw$", handler = function(i,p) combo("bodypunch", "skullwhack") end},
  {pattern = "^ws$", handler = function(i,p) combo("bodypunch", "skullwhack") end},
  {pattern = "^w2$", handler = function(i,p) combo("jugularclaw", "jugularclaw") end},
  {pattern = "^ww2$", handler = function(i,p) combo("jugularclaw", "jugularclaw") end},
  {pattern = "^sw2$", handler = function(i,p) doAttack("skullwhack", "none") end},
  {pattern = "^ss$", handler = function(i,p) doAttack("spinalcrack", "spinalcrack") end},
  {pattern = "^ss2$", handler = function(i,p) doAttack("bodypunch", "spinalcrack") end},
  {pattern = "^s2$", handler = function(i,p) doAttack("bodypunch", "spinalcrack") end},
  {pattern = "^cs$", handler = function(i,p) doAttack("bodypunch", "hamstringr") end},
  {pattern = "^zs$", handler = function(i,p) doAttack("bodypunch", "hamstringl") end},
  {pattern = "^as$", handler = function(i,p) doAttack("bodypunch", "rendl") end},
  {pattern = "^ds$", handler = function(i,p) doAttack("bodypunch", "rendr") end},
  {pattern = "^sz$", handler = function(i,p) doAttack("bodypunch", "hamstringl") end},
  {pattern = "^sa$", handler = function(i,p) doAttack("bodypunch", "rendl") end},
  {pattern = "^sd$", handler = function(i,p) doAttack("bodypunch", "rendr") end},
  
  -- Locks/rips/bites
  {pattern = "^apl$", handler = function(i,p) doAttack("armpitjl", "none") end},
  {pattern = "^armpit$", handler = function(i,p) doAttack("armpitjl", "none") end},
  {pattern = "^tl$", handler = function(i,p) doAttack("thighjl", "none") end},
  {pattern = "^thigh$", handler = function(i,p) doAttack("thighjl", "none") end},
  {pattern = "^nl$", handler = function(i,p) doAttack("neckjl", "none") end},
  {pattern = "^neck$", handler = function(i,p) doAttack("neckjl", "none") end},
  {pattern = "^spr$", handler = function(i,p) doAttack("spinalrip", "none") end},
  {pattern = "^gut$", handler = function(i,p) doAttack("gut", "none") end},
  {pattern = "^lac$", handler = function(i,p) doAttack("lacerate", "none") end},
  {pattern = "^spr$", handler = function(i,p) doAttack("spinalrip", "none") end},

  {pattern = "^tr$", handler = function(i,p) doAttack("groinrip", "none") end},
  {pattern = "^sr$", handler = function(i,p) doAttack("spleenrip", "none") end},
  {pattern = "^nr$", handler = function(i,p) doAttack("throatrip", "none") end},
  
  -- Howling
  {pattern = "^nohowl$", handler = function(i,p) stopHowling() end},
  {pattern = "^h1$", handler = function(i,p) howlingStack("conf") end},
  {pattern = "^howl1$", handler = function(i,p) howlingStack("conf") end},
  {pattern = "^h2$", handler = function(i,p) howlingStack("salve") end},
  {pattern = "^howl2$", handler = function(i,p) howlingStack("salve") end},
  {pattern = "^htest$", handler = function(i,p) testHowling() end},
  {pattern = "^h3$", handler = function(i,p) setHowl("howl to traumatize", "howl in a deep voice", "howl in mourning") end},
  {pattern = "^howl3$", handler = function(i,p) setHowl("howl to traumatize", "howl in a deep voice", "howl in mourning") end},
  {pattern = "^sn$", handler = function(i,p) send("snarling on") end},
  {pattern = "^sn on$", handler = function(i,p) send("snarling on") end},
  {pattern = "^sn off$", handler = function(i,p) send("snarling off") end},
  {pattern = "^bs$", handler = function(i,p) send("boneshaking on") end},
  {pattern = "^bs on$", handler = function(i,p) send("boneshaking on") end},
  {pattern = "^bs off$", handler = function(i,p) send("boneshaking off") end},
  {pattern = "^att$", handler = function(i,p) send("attuning on") end},
  {pattern = "^att on$", handler = function(i,p) send("attuning on") end},
  {pattern = "^att off$", handler = function(i,p) send("attuning off") end},
  {pattern = "^howlingtest$", handler = function(i,p) testHowling() end},
  
  {pattern = "^qu$", handler = function(i,p) send("quarter " .. target) end},
  {pattern = "^dev$", handler = function(i,p) send("devour " .. target) end},
}

triggers.attackTriggers = {
   -- Jawlocks
  {pattern = "^Seeing your prey helpless, you latch onto (%w+)'s inner thigh with your", handler = function(p) thighlocked() end},
  {pattern = "and pin it to the ground.$", handler = function(p) gagLine() end},
  {pattern = "^Victory thrilling in your veins, you pin (%w+) to the ground by (%w+) neck", handler = function(p) necklocked() end},
  {pattern = "powerful jaws.$", handler = function(p) gagLine() end},
  {pattern = "^Smelling weakness, you snap at the crook of (%w+)'s arm with your mighty", handler = function(p) armpitlocked() end},
  
  -- Rips
  {pattern = "^Your teeth part the flesh of (%w+)'s tender groin easily, releasing your", handler = function(p) groinripped() end},
 -- {pattern = "thigh.$", handler = function(p) gagLine() end},
  {pattern = "^You cease pinning (%w+), only to sink your teeth satisfyingly into the flesh", handler = function(p) throatripped() end},
--  {pattern = "neck.$", handler = function(p) gagLine() end},
  {pattern = "^You release your pin and instead thrust your jaws under (%w+)'s ribcage", handler = function(p) spleenripped() end},
  {pattern = "the sweet meat of (%w+) spleen.", handler = function(p) gagLine() end},
  
  -- Behead/wielding sword
  {pattern = "You raise a steel shortsword over your head and begin to swing it in a wide", handler = function(p) beheadStart() end},
  {pattern = "gaining speed as you go.$", handler = function(p) gagLine() end},
  {pattern = "You begin to bear down on (%w+), preparing to destroy (%w+).", handler = function(p) beheadContinued() end},
  {pattern = "You cease the whirling of your shortsword over your head.", handler = function(p) beheadStopped() end},
  {pattern = "A surge of elation rushes through you as you realize that (%w+)'s fate", handler = function(p) beheadComplete() end},
  {pattern = "With a roar of triumph, you whip your shortsword at", handler = function(p) gagLine() end},
  {pattern = "head from his shoulders in a veritable fountain of dark", handler = function(p) gagLine() end},
  {pattern = "You cease waving your weapon.", handler = function(p) beheadStopped() end},
  
  -- Howls
  {pattern = "^You feel ready to howl once again.", handler = function(p) howlBalanceBack() end},
  {pattern = "^Your (%w+) howls continue to pour from your throat, hitting (%w+).", handler = function(p) showHowl(p) end},
  {pattern = "^Your (%w+) howl continues to pour from your throat, hitting (%w+).", handler = function(p) showHowl(p) end},
  {pattern = "^Your (%w+) (%w+) howl continues to pour from your throat, hitting (%w+).", handler = function(p) showHowl2(p) end},
  {pattern = "^Your howls of (%w+) continue to pour from your throat, hitting (%w+).", handler = function(p) showHowl(p) end},
  {pattern = "^The howl echoes back to hit you.", handler = function(p) howlEcho(p) end},
  {pattern = "^The howl of (%w+) shake your very bones.", handler = function(p) howlBoneshaking(p) end},
  {pattern = "You have not recovered enough strength in your voice to howl again.", handler = function(p) killLine() end},
  {pattern = "You are already howling that.", handler = function(p) killLine() end},
  {pattern = "You already have three active howls.", handler = function(p) killLine() end},
  {pattern = "You have not recovered enough strength in your throat to howl again.", handler = function(p) killLine() end},
  {pattern = "Your (%w+) howls die down in your throat.", handler = function(p) stoppedHowl(p) end},
  {pattern = "Your (%w+) (%w+) howls die down in your throat.", handler = function(p) stoppedHowl2(p) end},
  {pattern = "^You bellow out a deep howl, weighing down those around you.", handler = function(p) howlBalanceTaken(p) end},
  {pattern = "^You let out a vacuous howl, draining the minds of those around you.", handler = function(p) howlBalanceTaken(p) end},
  {pattern = "^You croon a rejuvenating howl, refreshing the will of those around you.", handler = function(p) howlBalanceTaken(p) end},
  {pattern = "^You begin to howl a deep, throaty howl that gradually increases in volume,", handler = function(p) howlBalanceTaken(p) end},
  {pattern = "^filling the bodies of your enemies with imaginary inflation.", handler = function(p) gagLine() end},
  {pattern = "^You let out a stimulating howl, invigorating those around you.", handler = function(p) howlBalanceTaken(p) end},
  {pattern = "^You let out a discordant howl, numbing the minds of those around you.", handler = function(p) howlBalanceTaken(p) end},
  {pattern = "^You croon a soothing howl, mollifying the wounds of those around you.", handler = function(p) howlBalanceTaken(p) end},
  {pattern = "^You let out a debilitating howl, attempting to weaken those around you.", handler = function(p) howlBalanceTaken(p) end},
  {pattern = "^You croon a melodic howl, lulling those around you toward a deep slumber.", handler = function(p) howlBalanceTaken(p) end},
  {pattern = "^You let out an unsavory howl, turning the stomachs of those around you.", handler = function(p) howlBalanceTaken(p) end},
  {pattern = "^You begin to bellow an alluring tune, the sound of which is irresistible to", handler = function(p) howlBalanceTaken(p) end},
  {pattern = "^those around.$", handler = function(p) gagLine() end},
  {pattern = "^You let out an erratic howl, confusing the minds of those around you.", handler = function(p) howlBalanceTaken(p) end},
  {pattern = "^You bay a jarring howl, disrupting the flow of portals towards you.", handler = function(p) howlBalanceTaken(p) end},
  {pattern = "^You yelp a vengeful howl, infuriating those around you.", handler = function(p) howlBalanceTaken(p) end},
  {pattern = "^Your howl mounts to a painful roar, harming all those around you.", handler = function(p) howlBalanceTaken(p) end},
  {pattern = "^You bellow a maniacal howl, conjuring derangement in those around you.", handler = function(p) howlBalanceTaken(p) end},
  {pattern = "^You let out a massive howl in an attempt to terrorize those around you.", handler = function(p) howlBalanceTaken(p) end},
  {pattern = "^You begin to weave a confining howl, filling the minds of your enemies with", handler = function(p) howlBalanceTaken(p) end},
  {pattern = "^claustrophobia.$", handler = function(p) gagLine() end},
  {pattern = "^You begin to howl an enfeebling tone at all present.", handler = function(p) howlBalanceTaken(p) end},
  {pattern = "^You bellow a forceful howl, knocking those around you to the ground.", handler = function(p) howlBalanceTaken(p) end},
  {pattern = "^You bay a pealing howl in an attempt to traumatize those around you.", handler = function(p) howlBalanceTaken(p) end},
  {pattern = "^You let out an animating howl, rousing those around you into a headlong state.", handler = function(p) howlBalanceTaken(p) end},
  {pattern = "^You let out a piercing howl, forcing hearing into the ears of those around you.", handler = function(p) howlBalanceTaken(p) end},
  {pattern = "^You croon a dumbing howl, slowing the minds of those around you.", handler = function(p) howlBalanceTaken(p) end},
  {pattern = "^You croon a comforting howl, nourishing the minds of those around you.", handler = function(p) howlBalanceTaken(p) end},
  {pattern = "^You cry a baleful howl, irritating those around you.", handler = function(p) howlBalanceTaken(p) end},
  {pattern = "^You roar an angry howl, inciting hatred towards you in all who surround you.", handler = function(p) howlBalanceTaken(p) end},
  {pattern = "^You let out a disturbing howl, shattering the concentration of those around you.", handler = function(p) howlBalanceTaken(p) end},
  {pattern = "^You let out a high-pitched, vibrating howl, blurring the eyesight of those around you.", handler = function(p) howlBalanceTaken(p) end},
  {pattern = "^around you.", handler = function(p) gagLine() end},
  
  {pattern = "^Seeing (%w+) prey helpless, (%w+) grabs the inner thigh of (%w+) within", handler = function(p) enemyJawlocked(p) end},
  {pattern = "pinning (%w+) to the ground.$", handler = function(p) killLine() end},

}

-- Howling
function testHowling()
  addHowl("soothing")
  addHowl("invigorating")
  addHowl("comforting")
  
  doHowl()
end

function howlingStack(stack)
  if stack:match("conf") then
    addHowl("mind-numbing")
    addHowl("confusion")
    addHowl("disturbing")
  elseif stack:match("salve") then
    addHowl("blurring")
    addHowl("inflating")
    addHowl("mind-numbing")
  end
  
  if howlingBalance then doHowl() end
end

function doHowl()
  if cycleHowls and #howls > 3 and currentHowls == 3 then removeHowl() end

  for i=1,3 do
    if howls[i] ~= nil then send("howl " .. howls[i]) end
  end
end

function nextHowl(howl)
  removeHowl(howl)
  
  doHowl()
end

function removeHowl(howl)
  echo(C.b .. "[" .. C.r .."Removed " .. C.R .. howl .. C.r .." leaving " .. C.G .. (#howls - 1) .. C.r .. " howls in queue" .. C.b .. "]" .. C.x)
  send("cease " .. howl)
  table.remove(howls, toRemove)
end

function addHowl(howl)
  table.insert(howls, howl)
  echo(C.b .. "[" .. C.g .."Added " .. C.G .. howl .. C.g .." to howls at position " .. C.R .. #howls .. C.b .. "]" .. C.x)
end

function howlBalanceTaken(pattern)
  replace(C.r .. "---" .. C.R .. "HOWLING BALANCE TAKEN" .. C.r .. "---" .. C.x)
  howlingBalance = false
  currentHowls = currentHowls + 1
end

function howlBalanceBack()
  replace(C.g .. "+++" .. C.G .. "HOWLING BALANCE BACK" .. C.g .. "+++" .. C.x)
  howlingBalance = true
  doHowl()
end

function stoppedHowl(pattern)
  tmp = mb.line:match(pattern)
  stoppedHowlEcho(tmp)
end

function stoppedHowl2(pattern)
  tmp, tmp2 = mb.line:match(pattern)
  stoppedHowlEcho(tmp .. " " .. tmp2)
end

function stoppedHowlEcho(howl)
  replace(C.b .. "[" .. C.r .."Stopped howling " .. C.R .. howl .. C.b .. "]" .. C.x)
  currentHowls = currentHowls - 1
end

function clearHowls()
  howls = {}
end

function stopHowling()
  clearHowls()
  send("cease howling")
end

function showHowl(pattern)
  howl, person = mb.line:match(pattern)
  if person:match("no") then person = "NO ONE" end
  replace(C.b .. "[" .. C.g .."Howl: " .. C.G .. howl .. " on " .. person .. C.b .. "]" .. C.x)
end

function showHowl2(pattern)
  howl1, howl2, person = mb.line:match(pattern)
  howl = howl1 .. " " .. howl2
  if person:match("no") then person = "NO ONE" end
  replace(C.b .. "[" .. C.g .."Howl: " .. C.G .. howl .. " on " .. person .. C.b .. "]" .. C.x)
end

function howlBoneshaking(pattern)
  person = mb.line:match(pattern)
  replace(C.b .. "[" .. C.r .."BONESHAKING FROM " .. C.R .. person .. C.b .. "]" .. C.x)
end

function howlEcho(pattern)
  howl = mb.line:match(pattern)
  replace(C.b .. "[" .. C.g .."Howl Echo" .. C.b .. "]" .. C.x)
end

function groinripped()
  gagLine()
  echo("\nvv" .. C.R .. "vv" .. C.x .. "vvv" .. C.R .. "v" .. C.x .. "vv" .. C.R .. "vv" .. C.x .. "vvv" .. C.R .. "vv" .. C.x .. "v")
  echo(C.G .. "   GROIN RIPPED   " .. C.x)
  echo("^^" .. C.R .. "^^" .. C.x .. "^^" .. C.R .. "^^" .. C.x .. "^^" .. C.R .. "^^" .. C.x .. "^^" .. C.R .. "^^" .. C.x .. "^^\n" .. C.x)
end

function throatripped()
  gagLine()
  echo("\nvv" .. C.R .. "vv" .. C.x .. "vv" .. C.R .. "v" .. C.x .. "vv" .. C.R .. "vv" .. C.x .. "vvvvv" .. C.R .. "vv" .. C.x .. "v")
  echo(C.G .. "   THROAT RIPPED   " .. C.x)
  echo("^^" .. C.R .. "^^" .. C.x .. "^^" .. C.R .. "^^" .. C.x .. "^^" .. C.R .. "^^^" .. C.x .. "^^" .. C.R .. "^^" .. C.x .. "^^\n" .. C.x)
end

function spleenripped()
  gagLine()
  echo("\nvvv" .. C.R .. "vv" .. C.x .. "vvv" .. C.R .. "v" .. C.x .. "vv" .. C.R .. "vv" .. C.x .. "vvvv" .. C.R .. "v" .. C.x .. "v")
  echo(C.G .. "   SPLEEN RIPPED   " .. C.x)
  echo("^^" .. C.R .. "^^" .. C.x .. "^^" .. C.R .. "^^^" .. C.x .. "^^" .. C.R .. "^^" .. C.x .. "^^" .. C.R .. "^^" .. C.x .. "^^\n" .. C.x)
end

function thighlocked()
  gagLine()
  echo("\nvvv" .. C.R .. "vv" .. C.x .. "vvv" .. C.R .. "v" .. C.x .. "vv" .. C.R .. "vv" .. C.x .. "vvvvv" .. C.R .. "vv" .. C.x .. "v")
  echo(C.R .. "   THIGH JAWLOCKED   " .. C.x)
  echo("^^" .. C.R .. "^^" .. C.x .. "^^" .. C.R .. "^^^" .. C.x .. "^^" .. C.R .. "^^^" .. C.x .. "^^" .. C.R .. "^^^" .. C.x .. "^^\n" .. C.x)

  if autorip then
    addAction("doAttack('groinrip', 'none')", true)
  end
end

function necklocked()
  gagLine()
  echo("\nvv" .. C.R .. "vv" .. C.x .. "vvv" .. C.R .. "v" .. C.x .. "vv" .. C.R .. "vv" .. C.x .. "vvvvv" .. C.R .. "vv" .. C.x .. "v")
  echo(C.R .. "   NECK JAWLOCKED   " .. C.x)
  echo("^^" .. C.R .. "^^" .. C.x .. "^^" .. C.R .. "^^" .. C.x .. "^^" .. C.R .. "^^^" .. C.x .. "^^" .. C.R .. "^^^" .. C.x .. "^^\n" .. C.x)
  
  if autorip then
    addAction("doAttack('throatrip', 'none')", true)
  end
end

function enemyJawlocked(pattern)
  --"^Seeing (%w+) prey helpless, (%w+) grabs the inner thigh of (%w+) within"
  _, locking, locked = mb.line:match(pattern)
  
  setACSLabel(C.R .. "+++++++++++ " .. locking .. " " .. C.r .. " locked " .. C.G .. locked .. C.r .. ". QUARTER!!!!!")
end

function armpitlocked()
  gagLine()
  echo("\nvvvv" .. C.R .. "vv" .. C.x .. "vvv" .. C.R .. "v" .. C.x .. "vv" .. C.R .. "vv" .. C.x .. "vvvvv" .. C.R .. "vv" .. C.x .. "v")
  echo(C.R .. "   ARMPIT JAWLOCKED   " .. C.x)
  echo("^^" .. C.R .. "^^" .. C.x .. "^^" .. C.R .. "^^^" .. C.x .. "^^" .. C.R .. "^^^" .. C.x .. "^^" .. C.R .. "^^^^" .. C.x .. "^^\n" .. C.x)
  
  if autorip then
    addAction("doAttack('spleenrip', 'none')", true)
  end
end


-- Attack functions
function doAttack(attack1, attack2)
  -- Basic claw attacks
  if (attack1 == "bclaw") then
    send ("claw " .. target)
  end
  if (attack2 == "bclaw") then
    send ("claw " .. target)
  end
  -- Hamstring
  if (attack1 == "hamstringl") then
    send("hamstring " .. target .. " left")
  end
  if (attack2 == "hamstringl") then
    send("hamstring " .. target .. " left")
  end
  if (attack1 == "hamstringr") then
    send("hamstring " .. target .. " right")
  end
  if (attack2 == "hamstringr") then
    send("hamstring " .. target .. " right")
  end
  
  -- Rend
  if (attack1 == "rendl") then
    send("rend " .. target .. " left")
  end
  if (attack2 == "rendl") then
    send("rend " .. target .. " left")
  end
  if (attack1 == "rendr") then
    send("rend " .. target .. " right")
  end
  if (attack2 == "rendr") then
    send("rend " .. target .. " right")
  end
  
  -- Targetted clawing
  if (attack1 == "clawll") then
    send("claw left leg of " .. target)
  end
  if (attack2 == "clawll") then
    send("claw left leg of " .. target)
  end
  if (attack1 == "clawrl") then
    send("claw right leg of " .. target)
  end
  if (attack2 == "clawrl") then
    send("claw right leg of " .. target)
  end
  if (attack1 == "clawla") then
    send("claw left arm of " .. target)
  end
  if (attack2 == "clawla") then
    send("claw left arm of " .. target)
  end
  if (attack1 == "clawra") then
    send("claw right arm of " ..target)
  end
  if (attack2 == "clawra") then
    send("claw right arm of " ..target)
  end
  
  -- Targetting slashing
  if (attack1 == "slashll") then
    send("slash left leg of " .. target)
  end     
  if (attack2 == "slashll") then
    send("slash left leg of " .. target)
  end                                    
  if (attack1 == "slashrl")then
    send("slash right leg of " .. target)
  end
  if (attack2 == "slashrl")then
    send("slash right leg of " .. target)
  end
  if (attack1 == "slashla") then
    send("slash left arm of " .. target)
  end
  if (attack2 == "slashla") then
    send("slash left arm of " .. target)
  end
  if(attack1 == "slashra") then
    send("slash right arm of " ..target)
  end
  if(attack2 == "slashra") then
    send("slash torso of " ..target)
  end
  if(attack1 == "slasht") then
    send("slash torso of " ..target)
  end
  if(attack2 == "slasht") then
    send("slash torso of " ..target)
  end
  
  -- Other
  if (attack1 == "spinalcrack") then
    send("spinalcrack " .. target)
  end
  if (attack2 == "spinalcrack") then
    send("spinalcrack " .. target)
  end
  if (attack1 == "faceslash") then
    send("faceslash " .. target)
  end
  if (attack2 == "faceslash") then
    send("faceslash " .. target)
  end
  if (attack1 == "bodypunch") then
    send("bodypunch " .. target) 
  end
  if (attack2 == "bodypunch") then
    send("bodypunch " .. target) 
  end
  if (attack1 == "throatclaw") then
    send("throatclaw " .. target)
  end
  if (attack2 == "throatclaw") then
    send("throatclaw " .. target)
  end
  if (attack1 == "skullwhack") then
    send("skullwhack " .. target)
  end
  if (attack2 == "skullwhack") then
    send("skullwhack " .. target)
  end
  if (attack1 == "jugular") then
    send("jugularclaw " .. target)
  end
  if (attack2 == "jugular") then
    send("jugularclaw " .. target)
  end
  
  -- Jawlocks
  if (attack1 == "armpitjl") then
    send("jawlock armpit of " .. target)
  end
  if (attack1 == "neckjl") then
    send("jawlock neck of " .. target)
  end
  if (attack1 == "thighjl") then
    send("jawlock thigh of " .. target)
  end
  
  -- Rips
  if (attack1 == "groinrip") then
    send("groinrip " .. target)
  end
  if (attack1 == "throatrip") then
    send("throatrip " .. target)
  end
  if (attack1 == "spleenrip") then
    send("spleenrip " .. target)
  end
  if (attack1 == "spinalrip") then
    send("spinalrip " .. target)
  end
  
  -- Mangle and Destroy bites
  if (attack1 == "manglell") then
    send("mangle left leg of " .. target)
  end
  if (attack1 == "manglerl") then
    send("mangle right leg of " .. target)
  end
  if (attack1 == "manglela") then
    send("mangle left arm of " .. target)
  end
  if (attack1 == "manglera") then
    send("mangle right arm of " .. target)
  end
  if (attack1 == "destroyll") then
    send("destroy left leg of " .. target)
  end         
  if (attack1 == "destroyrl") then
    send("destroy right leg of " .. target)
  end
  if (attack1 == "destroyla") then
    send("destroy left arm of " .. target)
  end
  if (attack1 == "destroyra") then
    send("destroy right arm of " .. target)
  end
            
  -- Other bites
  if (attack1 == "skullcrush") then
    send("skullcrush " .. target)
  end
  if (attack1 == "bite") then
    send("bite " .. target)
  end
  if (attack1 == "lacerate") then
    send("lacerate " .. target)
  end
  if (attack1 == "facemaul") then
    send("facemaul " .. target)
  end
  if (attack1 == "gut") then
      send("gut " .. target)
  end
  if (attack1 == "lacerate") then
      send("lacerate " .. target)
  end
  
  if (attack2 == "none") then
    echo(C.B.. "Attacking with " .. C.R .. attack1 .. C.B .. "." .. C.x)
  else
    echo(C.B.. "Attacking with " .. C.R .. attack1 .. C.B .. " and " .. C.R .. attack2 .. C.B .. "." .. C.x)
  end
end

function combo(attack1, attack2)
  send("combo " .. target .. " " .. attack1 .. " " .. attack2)
  echo(C.B.. "Attacking with " .. C.R .. attack1 .. C.B .. " and " .. C.R .. attack2 .. C.B .. "." .. C.x)
end

function mutateLycan()
  send("mutate into lycanthrope")
end

function mutateNormal()
  send("mutate into azudim")
end