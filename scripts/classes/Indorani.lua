echo("Indorani loaded.  Chaos! Death! DESTRUCTION!.")

-- TODO: Add in soul gathering system

triggers.defenseTriggers = {
  {pattern = "Wisely preparing yourself beforehand, you lay out the quill and various inks you will need to", handler = function(p) stopHeal() end},
  {pattern = "You have successfully inscribed the image of (%w+) on your Tarot card.", handler = function(p) startHeal() end},
  {pattern = "You have successfully inscribed the image of the Wheel of Misfortune on your Tarot card.", handler = function(p) startHeal() end},
  {pattern = "Your concentration ruined, you throw away the half-finished and now worthless tarot.", handler = function(p) startHeal() end},
  {pattern = "You cackle hellishly as you send the Wheel of Misfortune towards", handler = function(p) startHeal() end},

  {pattern = "You compose yourself, knowing that an inner calm is essential for the task ahead.", handler = function(p) stopHeal() end},
  {pattern = "You break your concentration and your transcendence fails.", handler = function(p) startHeal() end},
  {pattern = "Your surroundings burst asunder, a gaping black void opening in front of you. An eerie blue light", handler = function(p) startHeal() end},

  {pattern = "makes a wild catch for the glowing tarot floating before her, and manages to get a", handler = function(p) startHeal() end},

  {pattern = "You call upon your dark power, and instantly a black wind descends upon you. In seconds your body", handler = function(p) stopHeal() end},
  {pattern = "You concentrate and are once again Azudim.$", handler = function(p) startHeal() end},
}

--class.bashAttack = function()
--  send("flick bonedagger at " .. targetList)
--end

aliases.classAliases = {
  {pattern = "^fol$", handler = function(i,p) send("order entities follow me") end},
  {pattern = "^pass$", handler = function(i,p) send("order entities passive") end},
  {pattern = "^att$", handler = function(i,p) entitiesAttack() end},
  {pattern = "^gc$", handler = function(i,p) send("call entities") end},
  {pattern = "^cg$", handler = function(i,p) send("call entities") end},

--  {pattern = "^bash$", handler = function(i,p) class.bashAttack() end},

  {pattern = "^univ$", handler = function(i,p) tUniverse() end},
  {pattern = "^herm$", handler = function(i,p) tHermit() end},
  {pattern = "^sherm$", handler = function(i,p) tHermit2() end},
  {pattern = "^devil$", handler = function(i,p) tDevil() end},
  {pattern = "^hie (%w+)$", handler = function(i,p) tHierophant(i,p) end},
  {pattern = "^hie$", handler = function(i,p) tHierophant2() end},
  {pattern = "^foo (%w+)$", handler = function(i,p) tFool(i,p) end},
  {pattern = "^foo$", handler = function(i,p) tFool2() end},
  {pattern = "^empr (%w+)$", handler = function(i,p) tEmpress(i,p) end},

  {pattern = "^tow$", handler = function(i,p) tTower() end},
  {pattern = "^sun$", handler = function(i,p) tSun() end},

  {pattern = "^empe (%w+)$", handler = function(i,p) tEmperor(i,p) end},
  {pattern = "^mag (%w+)$", handler = function(i,p) tMagician(i,p) end},
  {pattern = "^mag$", handler = function(i,p) tMagician2() end},
  {pattern = "^pri (%w+)$", handler = function(i,p) tPriestess(i,p) end},
  {pattern = "^pri$", handler = function(i,p) tPriestess2() end},


  {pattern = "^sheal$", handler = function(i,p) send("vigour") end},
  {pattern = "^smana$", handler = function(i,p) send("sapience") end},
}

aliases.attackAliases = {

  {pattern = "^ar$", handler = function(i,p) nBoneDagger2() end},
  {pattern = "^ar (%w+)$", handler = function(i,p) nBoneDagger(i,p) end},
  {pattern = "^dec$", handler = function(i,p) nDecay() end},
  {pattern = "^taint$", handler = function(i,p) nTaint() end},

  {pattern = "^star$", handler = function(i,p) tStar() end},
  {pattern = "^lov$", handler = function(i,p) tLovers() end},
  {pattern = "^lust$", handler = function(i,p) tLust() end},
  {pattern = "^desp$", handler = function(i,p) tDespair() end},
  {pattern = "^just$", handler = function(i,p) tJustice() end},

  {pattern = "^ww$", handler = function(i,p) tSandman() end},
  {pattern = "^ss$", handler = function(i,p) tAeon() end},
  {pattern = "^aa$", handler = function(i,p) tWarrior("left arm") end},
  {pattern = "^dd$", handler = function(i,p) tWarrior("right arm") end},
  {pattern = "^zz$", handler = function(i,p) tWarrior("left leg") end},
  {pattern = "^cc$", handler = function(i,p) tWarrior("right leg") end},
  {pattern = "^xx$", handler = function(i,p) tHangedman() end},
  {pattern = "^ee$", handler = function(i,p) tMoon() end},
  {pattern = "^ee (%w+)$", handler = function(i,p) tMoon2(i,p) end},
  {pattern = "^eea$", handler = function(i,p) tMoon1("amnesia") end},
  {pattern = "^eev$", handler = function(i,p) tMoon1("vomiting") end},
  {pattern = "^eeb$", handler = function(i,p) tMoon1("berserking") end},
  {pattern = "^eec$", handler = function(i,p) tMoon1("confusion") end},
  {pattern = "^eee$", handler = function(i,p) tMoon1("epilepsy") end},
  {pattern = "^eeim$", handler = function(i,p) tMoon1("impatience") end},
  {pattern = "^eein$", handler = function(i,p) tMoon1("indifference") end},
  {pattern = "^eer$", handler = function(i,p) tMoon1("recklessness") end},
  {pattern = "^ees$", handler = function(i,p) tMoon1("stupidity") end},

  {pattern = "^dedr$", handler = function(i,p) tDeathDraw() end},
  {pattern = "^der$", handler = function(i,p) tDeathRub() end},
  {pattern = "^det$", handler = function(i,p) tDeathThrow() end},
  {pattern = "^wh$", handler = function(i,p) tWheel() end},

  {pattern = "^viv$", handler = function(i,p) nVivisect() end},
  {pattern = "^bwin$", handler = function(i,p) send("blackwind") end},
  {pattern = "^dis$", handler = function(i,p) nDisfigure() end},
  {pattern = "^grave$", handler = function(i,p) send("summon hands of the grave") end},

  {pattern = "^dsl$", handler = function(i,p) doppleShrivel("legs") end},
  {pattern = "^dsa$", handler = function(i,p) doppleShrivel("arms") end},
  {pattern = "^dst$", handler = function(i,p) doppleShrivel("throat") end},
  {pattern = "^ddec$", handler = function(i,p) doppleDecay() end},
  {pattern = "^dviv$", handler = function(i,p) doppleVivisect() end},
  {pattern = "^ddis$", handler = function(i,p) doppleDisfigure() end},
  {pattern = "^dfe$", handler = function(i,p) doppleFeed() end},
  {pattern = "^dch$", handler = function(i,p) doppleChill() end},

  {pattern = "^dee$", handler = function(i,p) doppleLink2("moon") end},
  {pattern = "^dlust$", handler = function(i,p) doppleLink2("lust") end},

  {pattern = "^dcl$", handler = function(i,p) send("order doppleganger cloak") end},
  {pattern = "^dseek$", handler = function(i,p) doppleSeek() end},
  {pattern = "^dseek (%w+)$", handler = function(i,p) doppleSeek2(i,p) end},
  {pattern = "^dmo (%w+)$", handler = function(i,p) doppleMove(i,p) end},
  {pattern = "^dre$", handler = function(i,p) send("order doppleganger return") end},
  {pattern = "^dlo$", handler = function(i,p) send("ORDER DOPPLEGANGER LOOK") end},

  {pattern = "^pfh$", handler = function(i,p) send("order pathfinder home") end},
  {pattern = "^derv$", handler = function(i,p) send("order dervish act") end},

  {pattern = "wwww", handler = function(i,p) orbParry("head") end},
  {pattern = "aaaa", handler = function(i,p) orbParry("left arm") end},
  {pattern = "dddd", handler = function(i,p) orbParry("right arm") end},
  {pattern = "zzzz", handler = function(i,p) orbParry("left leg") end},
  {pattern = "cccc", handler = function(i,p) orbParry("right leg") end},
  {pattern = "ssss", handler = function(i,p) orbParry("torso") end},
}

triggers.attackTriggers = {
  --{pattern = "^$", handler = function(p)  end},
  {pattern = "You fling the Death tarot card at (%w+) and upon impact, it disappears. An ominous silence overtakes", handler = function(p) stopHeal() end},
  {pattern = "The ominous silence lifts as your concentration is broken.$", handler = function(p) startHeal() end},
  {pattern = "An almost unbearable feeling of emptiness heralds the arrival of a cloaked and hooded figure", handler = function(p) startHeal() end},
  {pattern = "You casually flick a Wheel of Misfortune tarot towards", handler = function(p) stopHeal() end},
  {pattern = "Your action has caused you to lose concentration and the Wheel of Misfortune vanishes.$", handler = function(p) startHeal() end},
}


-- TODO: Weapon swing triggers for afflictions
-- TODO: Soul tracking triggers
-- TODO: Attack/venom selection. Combos.
-- TODO: Add everything for warhounds.
-- TODO: Add in skewer attacks and auto-attack if enemy is skewered.
--triggers.attackTriggers = {
--  {pattern = "^You place your fingers to your mouth and blow a high%-pitched whistle.$", 
--    handler = function(p) addTemporaryTrigger("You have recovered equilibrium.", function(p) houndsFollow() end) end},

 -- {pattern = "Raising your soulstone above the corpse of a Spellshaper Archon, you snarl a guttural chant that causes a smoke-grey glyph to appear within the stone. Moments later, an ethereal",
 --   handler = function(p) setACSLabel("Got a soul!") end},
--}

hounds = hounds or {}

function houndInfo()
  for i,v in ipairs(hounds) do send("hound info " .. v) end
end

function orderHounds(command)
  for i,v in ipairs(hounds) do send("order " .. v .. " " .. command) end
end

function trainHounds(type)
  for i,v in ipairs(hounds) do 
    addAction("send('hound switch " .. v .. "')", true)
    addAction("send('hound train " .. type .. "')", true)
  end
end

function kennelRecall()
  for i,v in ipairs(hounds) do
    addAction("send('hound kennel recall " .. v .. "')", true)
  end
end

function houndWhistle(i,p)
  local hound = i:match(p)
  if not hound or hound == "whistle" then hound = "all" end
  send("hound whistle " .. hound)
end

function houndsFollow()
  orderHounds("follow me")
end

function entitiesAttack()
  send("order entities kill " .. target)
end

function wDagger()
  doWield(dagger)
end

-- Domination Stuff
function doppleSeek()
  send("order doppleganger seek " .. target)
end

function doppleSeek2(i,p)
  dir = i:match(p)
  send("order doppleganger seek " .. dir)
end

function doppleShrivel(limb)
  send("order doppleganger channel shrivel " .. limb .. " " .. target)
end

function doppleLink(card)
  tImprint(card)
  send("give " .. card .. " to doppleganger")
  send("order doppleganger channel charge " .. card)
  send("order doppleganger channel fling " .. card .. " at " .. target)
end

function doppleLink1(card)
  tImprint(card)
  send("give " .. card .. " to doppleganger")
end

function doppleLink2(card)
  send("order doppleganger channel charge " .. card)
  send("order doppleganger channel fling " .. card .. " at " .. target)
end

function doppleDisfigure()
  send("order doppleganger channel disfigure " .. target)
end

function doppleChill()
  send("order doppleganger channel chill " .. target)
end

function doppleFeed()
  send("order doppleganger channel necrofeed " .. target)
end

function doppleVivisect()
  send("order doppleganger channel vivisect " .. target)
end

function doppleDecay()
  send("order doppleganger channel decay " .. target)
end

function doppleMove(i,p)
  dir = i:match(p)
  send("order doppleganger move " .. dir)
end

function orbParry(limb)
  send("order orb defend " .. limb)
end

-- Necromancy: Death Attacks

function nVivisect()
  send("vivisect " .. target)
end

function nChill() 
  send("chill " .. target)
end

function nDecay()
  send("decay " .. target)
end

function nLeech()
  send("leech " .. target)
end

function nNight()
  send("night")
end

function nDisfigure()
  send("disfigure " .. target)
end

function nScreech()
  send("screech")
end

function nBelch()
  send("belch")
end

function nTaint()
  send("taint " .. target)
end

function nFeed()
  send("necrofeed " .. target)
end

function nBoneDagger2(dir)
  send("flick bonedagger at " .. target .. " " .. dir)
end

function nBoneDagger(i,p)
  dir = i:match(p)
  send("flick bonedagger at " .. target .. " " .. dir)
end

function nBoneDagger2()
  send("flick bonedagger at " .. target)
end

function nShrivel(limb)
  send("shrivel " .. limb .. " " .. target)
end

function soulControl()
  send("soul control " .. target)
end

function soulOrder(command)
  send("order " .. target .. " " .. command)
end

function soulErosion()
  send("soul erode " .. target)
end

function soulReave()
  healer = false
  send("soul reave " .. target)
  -- TODO: ADD ECHO/REPLACE IN HERE
end

function soulReaveFailed()
  healer = true
  -- TODO: ADD ECHO/REPLACE IN HERE
end

function soulReaveDone()
  healer = true
  -- TODO: ADD ECHO/REPLACE IN HERE
end

-- Tarot: Card Tricks

function tImprint(card)
  send("outd blank as " .. card)
end

function tHermit()
  send("charge hermit")
  send("fling hermit at ground")
end

function tHermit2()
  tImprint("hermit")
  send("ind hermit")
  send("outd hermit")
  send("activate hermit")
end

function tTower()
  tImprint("tower")
  send("fling tower at ground")
end

function tSun()
  tImprint("sun")
  send("fling sun at ground")
end

function tWarrior(limb)
  tImprint("warrior")
  send("FLING WARRIOR AT " .. target .. " " .. limb)
end

function tUniverse()
--  send("outd universe")
--  send("charge universe")
  tImprint("universe")
  send("fling universe at ground")
end

function tDevil()
  tImprint("devil")
  send("fling devil at ground")
end

function tStar()
  tImprint("star")
  send("fling star at " .. target)
end

function tLovers()
  tImprint("lovers")
  send("fling lovers at " .. target)
end

function tLust()
  tImprint("lust")
  send("fling lust at " .. target)
end

function tJustice()
  tImprint("justice")
  send("fling justice at " .. target)
end

function tAeon()
  tImprint("aeon")
  send("fling aeon at " .. target)
end

function tDespair()
  tImprint("despair")
  send("fling despair at " .. target)
end

function tMoon()
  tImprint("moon")
  send("fling moon at " .. target)
end

function tMoon1(aff)
  tImprint("moon")
  send("fling moon at " .. target .. " " .. aff)
end

function tMoon2(i,p)
  dir = i:match(p)
  tImprint("moon")
  send("FLING moon AT " .. target .. " " .. dir)
end

function tHangedman()
  tImprint("hangedman")
  send("fling hangedman at " .. target)
end

function tWheel()
  tImprint("wheel")
  send("fling wheel at " .. target)
end

function tSandman()
  tImprint("sandman")
  send("fling sandman at " .. target)
end

function tHierophant(i,p)
  dir = i:match(p)
  tImprint("hierophant")
  send("FLING HIEROPHANT AT " .. dir)
end

function tFool(i,p)
  dir = i:match(p)
  tImprint("fool")
  send("FLING fool AT " .. dir)
end

function tEmpress(i,p)
  dir = i:match(p)
  tImprint("empress")
  send("fling empress at " .. dir)
end

function tEmperor(i,p)
  dir = i:match(p)
  tImprint("emperor")
  send("fling emperor at " .. dir)
end

function tPriestess(i,p)
  dir = i:match(p)
  tImprint("priestess")
  send("fling priestess at " .. dir)
end

function tMagician(i,p)
  dir = i:match(p)
  tImprint("magician")
  send("fling magician at " .. dir)
end

function tMagician2()
  tImprint("magician")
  send("fling magician at me")
end

function tPriestess2()
  tImprint("priestess")
  send("fling priestess at me")
end

function tFool2()
  tImprint("fool")
  send("fling fool at me")
end

function tHierophant2()
  tImprint("hierophant")
  send("fling hierophant at me")
end

-- Death Tarot --

function tDeathDraw()
  send("outd death")
  send("rub death on " .. target)
  send("sniff death")
end

function tDeathRub()
  send("rub death on " .. target)
  send("sniff death")
end

function tDeathThrow()
  send("charge death")
  send("fling death at " .. target)
end

-----------------

function grapple()
  send("grapple " .. target)
end

function raze()
  send("raze " .. target)
end

function takedown()
  send("takedown " .. target)
end

function block(direction)
  send("block " .. direction)
end

function gash()
  send("grapple gash " .. target)
end

function dsl()
  send("dsl " .. target)
end

function impale()
  send("impale " .. target)
end

function disfigure()
  send("grapple disfigure " .. target)
end

function lowblow()
  send("grapple lowblow " .. target)
end

function setCharge()
  send("prepare to charge " .. target)
end

function hBash()
  send("hammer bash " .. target)
end

function hSwap(dir)
  send("hammer swat " .. target .. " " .. dir)
end

function hCrush(tar)
  send("hammer crush " .. target .. " " .. tar)
end

function hThrow()
  send("hammer throw " .. target)
end

function bruteforce()
  send("hammer force")
end

function hBatter()
  wHammer()
  send("hammer batter " .. target)
  -- TODO: Hammer batter trigger gives afflictions based on soul amount
end

function hGutcheck()
  send("hammer gutcheck " .. target)
end

function hRage()
  send("hammer rage")
end

function hPulverize()
  send("hammer pulverize")
end

function pHack()
  send("pole hack " .. target)
end

function pCarve()
  send("pole carve " .. target)
end

function pSweep()
  send("pole sweep")
end

function pSpin()
  send("pole spinslash " .. target)
end

function pWhirlwind()
  send("pole whirlwind")
end

function pHook()
  send("pole hook " .. target)
end

function pSkewer()
  send("pole skewer " .. target)
end

function pWrench()
  send("pole wrench")
end

function pDismember(limb)
  send("pole dismember " .. limb .. " " .. target)
end