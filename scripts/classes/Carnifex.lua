echo("Carnifex loaded.  Heads will roll.")

-- TODO: Add in soul gathering system

aliases.classAliases = {
  {pattern = "^fol$", handler = function(i,p) houndsFollow() end},
  {pattern = "^recall$", handler = function(i,p) kennelRecall() end},
  {pattern = "^whistle$", handler = function(i,p) houndWhistle(i,p) end},
  {pattern = "^whistle (%w+)$", handler = function(i,p) houndWhistle(i,p) end},
  {pattern = "^hinfo$", handler = function(i,p) houndInfo() end},
}

aliases.attackAliases = {
  {pattern = "^bat$", handler = function(i,p) hBatter() end},
}

-- TODO: Weapon swing triggers for afflictions
-- TODO: Soul tracking triggers
-- TODO: Attack/venom selection. Combos.
-- TODO: Add everything for warhounds.
-- TODO: Add in skewer attacks and auto-attack if enemy is skewered.
triggers.attackTriggers = {
  {pattern = "^You place your fingers to your mouth and blow a high%-pitched whistle.$", 
    handler = function(p) addTemporaryTrigger("You have recovered equilibrium.", function(p) houndsFollow() end) end},

  {pattern = "Raising your soulstone above the corpse of a Spellshaper Archon, you snarl a guttural chant that causes a smoke-grey glyph to appear within the stone. Moments later, an ethereal",
    handler = function(p) setACSLabel("Got a soul!") end},
}

hounds = hounds or {"Valstivar", "Dakash", "Mordekai"}

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

function wHammer()
  doWield(warhammer)
end

function wBardiche()
  doWield(bardiche)
end

-- Deathlore: Soul Attacks
function soulBarrage() 
  send("sould barrage " .. target)
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

function pWhirlwind()
  send("pole whirlwind")
end

function pHook()
  send("pole hook " .. target)
end

function pDismember(limb)
  send("pole dismember " .. limb .. " " .. target)
end