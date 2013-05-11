echo("Carnifex loaded.  Heads will roll.")

-- TODO: Add in soul gathering system

aliases.classAliases = {
  --{pattern = "^fol$", handler = function(i,p) houndsFollow() end},
  {pattern = "^fol$", handler = function(i,p) send("order hounds follow me") end},
  {pattern = "^recall$", handler = function(i,p) kennelRecall() end},
  {pattern = "^hw$", handler = function(i,p) houndWhistle(i,p) end},
  {pattern = "^hw (%w+)$", handler = function(i,p) houndWhistle(i,p) end},
  {pattern = "^hinfo$", handler = function(i,p) houndInfo() end},

  {pattern = "^att$", handler = function(i,p) hAttack() end},
  {pattern = "^pass$", handler = function(i,p) hPassive() end},

  {pattern = "^embeda$", handler = function(i,p) embedArmour() end},
  {pattern = "^embedb$", handler = function(i,p) embedBody() end},
  {pattern = "^embedw$", handler = function(i,p) embedWeapon() end},
  {pattern = "^ssum$", handler = function(i,p) send("soul summon") end},
}

aliases.attackAliases = {
  {pattern = "^bat$", handler = function(i,p) hBatter() end},


  {pattern = "^bf$", handler = function(i,p) bruteforce() end},
  {pattern = "^hr$", handler = function(i,p) hRage() end},
  {pattern = "^cha$", handler = function(i,p) setCharge() end},

  {pattern = "^dsl$", handler = function(i,p) dsl() end},

  {pattern = "^spin$", handler = function(i,p) pSpin() end},
  {pattern = "^hack$", handler = function(i,p) pHack() end},
  {pattern = "^ar$", handler = function(i,p) pSpin() end},
  {pattern = "^skew$", handler = function(i,p) pSkewer() end},
  {pattern = "^wre$", handler = function(i,p) pWrench() end},
  {pattern = "^xx$", handler = function(i,p) pHook() end},

  {pattern = "^barr$", handler = function(i,p) soulBarrage() end},
  {pattern = "^sto$", handler = function(i,p) soulTorture() end},
  {pattern = "^rul$", handler = function(i,p) soulRust(left) end},
  {pattern = "^rur$", handler = function(i,p) soulRust(right) end},
  {pattern = "^sta$", handler = function(i,p) soulTaint() end},
  {pattern = "^spo$", handler = function(i,p) soulPoison() end},
  {pattern = "^root$", handler = function(i,p) soulRoot() end},
  {pattern = "^chain$", handler = function(i,p) soulChains() end},
  {pattern = "^ero$", handler = function(i,p) soulErosion() end},
}

triggers.defenseTriggers = {
  {pattern = "A powerful mastiff settles down in a corner to sleep.", handler = function(p) hSleepFollow() end},
  {pattern = "A powerful mastiff slowly wakens, looking fit and refreshed.", handler = function(p) hSleepFollow() end},
  {pattern = "A powerful mastiff bounds into the room, its delivery complete.", handler = function(p) send("order asimov follow me") end},
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

function hAttack() 
  send("hound initiative " .. target)
end

function hPassive() 
  send("hound initiative cease")
end

function hSleepFollow()
  send("order asimov follow me")
  send("queue bal order asimov follow me")
  send("queue eq order asimov follow me")
end

function wHammer()
  doWield(warhammer)
end

function wBardiche()
  doWield(bardiche)
end

-- Deathlore: Soul Attacks
function embedArmour() 
  send("soul embed in armor")
end
function embedBody() 
  send("soul embed in body")
end
function embedWeapon() 
  send("soul embed in weapon")
end

function soulBarrage() 
  send("soul barrage " .. target)
end

function soulTorture()
  send("soul torture")
end

function soulRust(side)
  send("soul rust " .. target .. " " .. side)
end

function soulTaint()
  send("soul taint " .. target)
end

function soulWither(limb)
  send("soul wither " .. target .. " " .. limb)
end

function soulPoison()
  send("soul poison " .. target)
end

function soulDrain()
  send("soul drain " .. target)
end

function soulSacrifice()
  send("soul sacrifice")
end

function soulStorm()
  send("soul storm " .. target)
end

function soulRoot()
  send("soul root " .. target)
end

function soulChains()
  send("soul summon chains")
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

-- Savagery: Attacks
-- TODO: Add in equips for each weapon
-- TODO: Add in enemy soul tracking
-- TODO: Find out if you can check current amount of soul on weapon
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