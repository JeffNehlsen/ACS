echo("Zealot system loaded. Unbelievers beware!")
--Attack system aliases, etc.
target = "target"
autobbt = false 
}

--Hunting Combo
aliases.classAliases = {
   {pattern = "^Bcom$", handler = function(i, p) doCombo("sidekick", "uppercut", "uppercut") end},
}

aliases.attackAliases = {
  -- Head Combos
  {pattern = "^ahea$", handler = function(i, p) doCombo("axekick", "uppercut", "uppercut") end},
  {pattern = "^whea$", handler = function(i, p) doCombo("whirlwind", "uppercut", "uppercut") end},
  {pattern = "^fhea$", handler = function(i, p) doCombo("feintt", "uppercut", "uppercut") end},
  {pattern = "^jhea$", handler = function(i, p) doCombo("jumpkick", "uppercut", "uppercut") end},

  -- Torso Combos
  {pattern = "^torc$", handler = function(i,p) doCombo("comet", "hook", "hook") end},
  {pattern = "^tors$", handler = function(i,p) doCombo("sidekick", "hook", "hook") end},
  {pattern = "^ftor$", handler = function(i,p) doCombo("feinth", "hook", "hook") end},
  {pattern = "^jtor$", handler = function(i,p) doCombo("jumpkick", "hook", "hook") end},
  
  -- Leg Combos
  {pattern = "^legl$", handler = function(i,p) doCombo("snapl", "hammerl", "hammerl") end},
  {pattern = "^legr$", handler = function(i,p) doCombo("snapr", "hammerr", "hammerr") end},
  {pattern = "^legb$", handler = function(i,p) doCombo("snapr", "hammerl", "hammerl") end},
  {pattern = "^frl$", handler = function(i,p) doCombo("feinth", "hammerr", "hammerr") end},
  {pattern = "^fll$", handler = function(i,p) doCombo("feinth", "hammerl", "hammerl") end},
  {pattern = "^swb$", handler = function(i,p) doCombo("sweep", "hammerl", "hammerr") end},
  {pattern = "^jkl$", handler = function(i,p) doCombo("jumpkick", "hammerl", "hammerr") end},
  
  -- Arm Combos
  {pattern = "^arml$", handler = function(i,p) doCombo("moonkickl", "spearl", "spearl") end},
  {pattern = "^armr$", handler = function(i,p) doCombo("moonkickr", "spearr", "spearr") end},
  {pattern = "^armb$", handler = function(i,p) doCombo("moonkickr", "spearl", "spearl") end},
  {pattern = "^fra$", handler = function(i,p) doCombo("feinth", "spearr", "spearr") end},
  {pattern = "^fla$", handler = function(i,p) doCombo("feinth", "spearl", "spearl") end},

  -- Throws and throw combos
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
  
  -- Stancing Combos - ADD THIS STUFF IN -

  -- Misc Combos

  -- Illumination - ADD THIS STUFF IN -

  -- Telepathy - ADD THIS STUFF IN -
}

triggers.attackTriggers = {
   --
  -- Mind command balance track.
  {pattern = "^You feel ready to howl once again.", handler = function(p) howlBalanceBack() end},

function howlBalanceBack()
  replace(C.g .. "+++" .. C.G .. "HOWLING BALANCE BACK" .. C.g .. "+++" .. C.x)
  howlingBalance = true
  doHowl()
end
}

-- This is Tekura --
--------------------

-- Combo functions
function doCombo(attack1, attack2, attack3)

  -- Kicks - All of these are attack1. You don't kick second or third.
  if (attack1 == "sidekick") then
    send("sdk " .. target)
  end
  if (attack1 == "comet") then
    send("cmk " .. target)
  end
  if (attack1 == "whirlwind") then
    send("wwk " .. target)
  end
  if (attack1 == "axekick") then
    send("axk " .. target)
  end
  if (attack1 == "roundhouse") then
    send("rhk " .. target)
  end
  if (attack1 == "sweep") then
    send("swk " .. target)
  end
  if (attack1 == "jumpkick") then
    send("jpk " .. target)
  end
  if (attack1 == "moonkickl") then
    send("mnk " .. target .. " left")
  end
  if (attack1 == "moonkickr") then
    send("mnk " .. target .. " right")
  end
  if (attack1 == "snapl") then
    send("snk " .. target .. " left")
  end
  if (attack1 == "snapr") then
    send("snk " .. target .. " right")
  end
  
  -- Punches - All of these are two and three. If you're trying to open with a punch, you're doing it wrong.
  if (attack2 == "uppercut") then
    send("ucp " .. target)
  end
  if (attack3 == "uppercut") then
    send ("ucp " .. target)
  end
  if (attack2 == "palmstrike") then
    send("pmp " .. target)
  end
  if (attack3 == "palmstrike") then
    send ("pmp " .. target)
  end
  if (attack2 == "bladehand") then
    send("blp " .. target)
  end
  if (attack3 == "uppercut") then
    send ("ucp " .. target)
  end
  if (attack2 == "spearl") then
    send("spp " .. target .. " left")
  end
  if (attack3 == "spearl") then
    send ("spp " .. target .. " left")
  end
  if (attack2 == "spearr") then
    send("spp " .. target .. " right")
  end
  if (attack3 == "spearr") then
    send ("spp " .. target .. " right")
  end
  if (attack2 == "hammerl") then
    send("hfp " .. target .. " left")
  end
  if (attack3 == "hammerl") then
    send("hfp " .. target .. " left")
  end
  if (attack2 == "hammerr") then
    send("hfp " .. target .. " right")
  end
  if (attack3 == "hammerr") then
    send("hfp " .. target .. " right")
  end
  if (attack2 == "hook") then
    send("hkp " .. target)
  end
  if (attack3 == "hook") then
    send("hkp " .. target)
  end
  
  -- Throws - All attack one. Throw, then, if possible, punch.
  if (attack1 == "backbreaker") then
    send("bbt " .. target)
  end
  if (attack1 == "slam") then
    send("slt " .. target)
  end
  if (attack1 == "wrench") then
    send("wrt " .. target)
  end

  -- Feint - You feint, then punch.
  if (attack1 == "feinth") then
    send("feint " .. target .. "head")
  end
  if (attack1 == "feintt") then
    send("feint " .. target .. "torso")
  end
  if (attack1 == "feintll") then
    send("feint " .. target .. "left leg")
  end
  if (attack1 == "feintrl") then
    send("feint " .. target .. "right leg")
  end
  if (attack1 == "feintla") then
    send("feint " .. target .. "left arm")
  end
  if (attack1 == "feintra") then
    send("feint " .. target .. "right arm")
  end
  
  -- Stances
  if (attack1 == "horse") then
    send("hrs ")
  end
  if (attack1 == "eagle") then
    send("egs ")
  end
  if (attack1 == "cat") then
    send("cts ")
  end
  if (attack1 == "bear") then
    send("brs ")
  end
  if (attack1 == "panda") then
    send("pds ")
  end
  if (attack1 == "rat") then
    send("rts ")
  end
  if (attack1 == "scorpion") then
    send("scs ")
  end
  if (attack1 == "cobra") then
    send("cbs ")
  end
  if (attack1 == "pheonix") then
    send("phs ")
  end
  if (attack1 == "tiger") then
    send("tgs ")
  end
  if (attack1 == "wolf") then
    send("wfs ")
  end
  if (attack1 == "dragon") then
    send("drs ")
  end