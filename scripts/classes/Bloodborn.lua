echo("Bloodborn loaded.  Let the Rivers Run Red!")
--Attack system aliases, etc.
target = "target"

-- TODO: Add in soul gathering system

aliases.classAliases = {
--  {pattern = "^fol$", handler = function(i,p) houndsFollow() end},
--  {pattern = "^recall$", handler = function(i,p) kennelRecall() end},
--  {pattern = "^whistle$", handler = function(i,p) houndWhistle(i,p) end},
--  {pattern = "^whistle (%w+)$", handler = function(i,p) houndWhistle(i,p) end},
--  {pattern = "^hinfo$", handler = function(i,p) houndInfo() end},
  {pattern = "^coll$", handler = function(i,p) hCollect() end},
  {pattern = "^ps$", handler = function(i,p) PaintScythe() end},
  {pattern = "^clcol$", handler = function(i,p) BloodCollect() end},
}

aliases.attackAliases = {
  {pattern = "^ar$", handler = function(i,p) cFrenzy() end},
  {pattern = "^fl$", handler = function(i,p) cFling() end},

  {pattern = "^eld$", handler = function(i,p) hInvoke("eldritch") end},
  {pattern = "^shso$", handler = function(i,p) hInvoke("shiftsoul") end},
  {pattern = "^lr$", handler = function(i,p) hInvoke("resonance") end},
  {pattern = "^ashso$", handler = function(i,p) send("activate shiftsoul") end},

  {pattern = "^kis$", handler = function(i,p) hKiss() end}, 
  {pattern = "^bath$", handler = function(i,p) hBath() end}, 

--  {pattern = "^rr$", handler = function(i,p) mDWhisper("epilepsy", "impatience") end},
  {pattern = "^ee$", handler = function(i,p) mDWhisper("seduction", "temptation") end},
  {pattern = "^ww$", handler = function(i,p) mDWhisper("stupidity", "confusion") end},
  {pattern = "^aa$", handler = function(i,p) mDWhisper("indifference", "impatience") end},
  {pattern = "^ss$", handler = function(i,p) mDWhisper("anorexia", "belonephobia") end},
  {pattern = "^dd$", handler = function(i,p) mDWhisper("paranoia", "agoraphobia") end},
  {pattern = "^ff$", handler = function(i,p) mDWhisper("masochism", "recklessness") end},
  {pattern = "^zz$", handler = function(i,p) mDWhisper("loneliness", "peace") end},
  {pattern = "^xx$", handler = function(i,p) mDWhisper("epilepsy", "dementia") end},
  {pattern = "^cc$", handler = function(i,p) mDWhisper("berserk", "vertigo") end},
  {pattern = "^vv$", handler = function(i,p) mDWhisper("amnesia", "stupidity") end},

  {pattern = "^ann$", handler = function(i,p) mAnnihilate() end},
}

triggers.attackTriggers = {
  --{pattern = "^$", handler = function(p)  end},
  {pattern = "You attempt to flee to your coffin.", handler = function(p) stopHeal() end},
--  {pattern = "The ominous silence lifts as your concentration is broken.$", handler = function(p) startHeal() end},
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

--Class
--Attack
function wScythe()
  doWield(scythe)
end

function wAthame()
  doWield(athame)
end

function PaintScythe() 
  send("paint runes on scythe with blood of " .. target)
end

function BloodCollect()
  cClaw()
  hCollect()
end

-- Corpus
function cFrenzy() 
  send("frenzy " .. target)
end

function cClaw() 
  send("claw " .. target)
end

function cFeed() 
  send("feed " .. target)
end

function cChill() 
  send("chill " .. target)
end

function cBreath() 
  send("breathe " .. target)
end

function cFling() 
  send("fling " .. target)
end

-- Hematurgy

function hEyeBleed() 
  send("wisp eyebleed " .. target)
end

function hCollect() 
  send("collect blood from " .. target)
end

function hKiss() 
  send("wisp kiss " .. target)
end

function hBath() 
  send("wisp bloodbath")
end

function hInvoke(ritual)
  send("wisp invoke " .. ritual .. " " .. target)
end

-- Mentis

function mWhisper(whisper)
  send("whisper " .. whisper .. " " .. target)
end

function mDWhisper(whisper1, whisper2)
--  send("contemplate " .. target)
--  send("slash " .. target)
  send("dwhisper " .. whisper1 .. " " .. whisper2 .. " " .. target)
end

function mAnnihilate()
  send("annihilate " .. target)
end

--function soulTorture()
--  send("soul torture")
--end

--function soulRust(side)
--  send("soul rust " .. target .. " " .. side)
--end

--function soulTaint()
--  send("soul taint " .. target)
--end

--function soulWither(limb)
--  send("soul wither " .. target .. " " .. limb)
--end

--function soulPoison()
--  send("soul poison " .. target)
--end

--function soulDrain()
--  send("soul drain " .. target)
--end

--function soulOrder(command)
--  send("order " .. target .. " " .. command)
--end

--function soulReave()
--  healer = false
--  send("soul reave " .. target)
  -- TODO: ADD ECHO/REPLACE IN HERE
--end

--function soulReaveFailed()
--  healer = true
  -- TODO: ADD ECHO/REPLACE IN HERE
--end

--function soulReaveDone()
--  healer = true
  -- TODO: ADD ECHO/REPLACE IN HERE
--end

-- Savagery: Attacks
-- TODO: Add in equips for each weapon
-- TODO: Add in enemy soul tracking
-- TODO: Find out if you can check current amount of soul on weapon

--function takedown()
--  send("takedown " .. target)
--end

--function block(direction)
--  send("block " .. direction)
--end

--function hSwap(dir)
--  send("hammer swat " .. target .. " " .. dir)
--end

--function hCrush(tar)
--  send("hammer crush " .. target .. " " .. tar)
--end

--function hBatter()
--  wHammer()
--  send("hammer batter " .. target)
  -- TODO: Hammer batter trigger gives afflictions based on soul amount
--end

--function pWhirlwind()
--  send("pole whirlwind")
--end

--function pHook()
--  send("pole hook " .. target)
--end

--function pDismember(limb)
--  send("pole dismember " .. limb .. " " .. target)
--end