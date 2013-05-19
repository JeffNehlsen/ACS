echo("Base monk system loaded.")

class = {
  bashAttack = function()
    if Tekura.stance == "" then
      send("combo " .. selectedTarget .. " brs ucp ucp")
      return
    elseif Tekura.stance == "bear" then
      send("scs")
    end

    send("combo " .. selectedTarget .. " sdk ucp ucp")
  end
}
Tekura = {}
Tekura.autobbt = nil
Tekura.stance = ""
Tekura.moves = {
  -- Punches
  hfpl = {command = "hfp", side = "left"},
  hfpr = {command = "hfp", side = "right"},
  ucp =  {command = "ucp", side = "none"},

  -- Stances
  brs =  {command = "brs", side = "none"},

  -- Kicks
  snkl = {command = "snk", side = "left"},
  snkl = {command = "snk", side = "right"},
}

Telepathy = {
  
}

-- Cannot combo in aeon/retardation
Tekura.combo = function(att1, att2, att3)
    if not Tekura.moves[att1] then
      ACSEcho("Tekura move " .. att1 .. " not found.")
      return
    end

    if not Tekura.moves[att2] then
      ACSEcho("Tekura move " .. att2 .. " not found.")
      return
    end

    if not Tekura.moves[att3] then
      ACSEcho("Tekura move " .. att3 .. " not found.")
      return
    end

    local canUseCombo
    local attacks = {Tekura.moves[att1], Tekura.moves[att2], Tekura.moves[att3]}

    canUseCombo = Tekura.checkForOneSide(attacks) and not (hasAffliction("aeon") or isInRetardationVibe)

    local cmd
    local side
    if canUseCombo then

      cmd = "combo " .. target
      for _, attack in pairs(attacks) do
        cmd = cmd .. " " .. attack.command
        if attack.side ~= "none" then
          side = attack.side
        end
      end
      if side then
        cmd = cmd .. " " .. side
      end
      send(cmd)
    else
      for _, attack in pairs(attacks) do
        cmd = attack.command .. " " .. target
        if attack.side ~= "none" then
          cmd = cmd .. " " .. attack.side
        end
        send(cmd)
      end
    end
end

function Tekura.checkForOneSide(attacks)
  local foundSide = nil

  for _, attack in pairs(attacks) do
    if attack.side ~= "none" then
      if foundSide == nil then
        foundSide = attack.side
      elseif foundSide ~= attack.side then
        return false
      end
    end
  end

  return true
end

function Tekura:setStance(stance)
  self.stance = stance
  setACSLabel("Stance changed to " .. C.R .. stance)
end

function Tekura:unstanced()
  self.stance = ""
end


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

triggers.classTriggers = {
  {pattern = "^You drop your legs into a sturdy Horse stance.$", handler = function(p) Tekura:setStance("horse") end},
  {pattern = "^You draw back and balance into the Eagle stance.$", handler = function(p) Tekura:setStance("eagle") end},
  {pattern = "^You tense your muscles and look about sharply as you take the stance of the Cat.$", handler = function(p) Tekura:setStance("cat") end},
  {pattern = "^You draw yourself up to full height and roar aloud, adopting the Bear stance.$", handler = function(p) Tekura:setStance("bear") end},
  {pattern = "^You take the Rat stance.$", handler = function(p) Tekura:setStance("rat") end},
  {pattern = "^You sink back into the menacing stance of the Scorpion.$", handler = function(p) Tekura:setStance("scorpion") end},
  {pattern = "^You sink into a sturdy crouch, reaching out before you as you assume the Cobra stance.$", handler = function(p) Tekura:setStance("cobra") end},
  {pattern = "^Lifting one leg up off the ground, you reach into the air, balancing in the Phoenix stance.$", handler = function(p) Tekura:setStance("phoenix") end},
  {pattern = "^Bringing your torso closer to the ground, you adopt the pose of a Tiger.$", handler = function(p) Tekura:setStance("tiger") end},
  {pattern = "^Baring your teeth, you let out a mental snarl as you adopt the Wolf stance.$", handler = function(p) Tekura:setStance("wolf") end},
  {pattern = "^You allow the form of the Dragon to fill your mind and govern your actions.$", handler = function(p) Tekura:setStance("dragon") end},

  {pattern = "^You ease yourself out of the %w+ stance.$", handler = function(p) Tekura:unstanced() end},
}


---------------
-- Base Monk --
---------------
BaseMonk = {}
function BaseMonk:setup(trig, alia)
  for _, trigger in ipairs(trig) do
    debug:print("BaseMonk", "Adding trigger: " .. trigger.pattern)
    table.insert(triggers.classTriggers, trigger)
  end

  for _, alias in ipairs(alia) do
    debug:print("BaseMonk", "Adding alias: " .. alias.pattern)
    table.insert(aliases.classAliases, alias)
  end
end