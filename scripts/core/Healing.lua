echo("Healing file loaded.")

autosipper = true
attemptingAction = false
healer = true
sticking = ""
asleep = false
stunned = false
unconscious = false
syringeflicked = false

writhed = false
writhing = false
afflictionList = {}

aliases.healing = {
  {pattern = "^24$", handler = function(i,p) doStick("stimulant") end},
  {pattern = "^23$", handler = function(i,p) doStick("analeptic") end},
  {pattern = "^diag$", handler = function(i,p) doDiag() end},
}

triggers.healing = {
  {pattern = "The poultice mashes uselessly against your body.", handler = function(p) cureReset() end},
  {pattern = "You are no longer blind.", handler = function(p) cureReset() end},
  {pattern = "You are no longer deaf.", handler = function(p) cureReset() end},
  {pattern = "^You messily spread the salve over your body, to no effect.$", handler = function(p) cureReset() end},
}


function doStick(serum)
  balances:take("serum")
  if living then
    send("sip " .. convertToLiving(serum))
  else
    send("stick " .. convertToUndead(serum))
  end
  sticking = serum
end

function doKidney()
  balances:take("kidney")
  if living then
    send("outc moss")
    send("eat moss")
  else
    send("outc kidney slice")
    send("eat kidney slice")
  end
end

function doEat(organ)
  balances:take("organ")
  if living then
    send("outc " .. convertToLiving(organ))
    send("eat " .. convertToLiving(organ))
    if hasAffliction("stupidity") then
      send("outc " .. convertToLiving(organ))
      send("eat " .. convertToLiving(organ))
    end
  else
    send("outc " .. convertToUndead(organ) .. " slice")
    send("eat " .. convertToUndead(organ) .. " slice")
    if hasAffliction("stupidity") then
      send("outc " .. convertToUndead(organ) .. " slice")
      send("eat " .. convertToUndead(organ) .. " slice")
    end
  end
  eating = organ
  add_timer(1, function() eating = "" end)
end

function doInject(tincture)
  balances:take("tincture")
  if living then
    send("smoke " .. convertToLiving(tincture))
  else
    send("inject " .. convertToUndead(tincture))
  end
  injecting = tincture
end

function doApply(poultice)
  balances:take("poultice")
  if living then
    send("apply " .. convertToLiving(poultice))
  else
    send("press " .. convertToUndead(poultice))
  end
  applying = poultice
end

function doDiag()
  diagnosing = true
  send("diagnose me")
  add_timer(2, function() diagnosing = false end)
end

function doStickCalmative()
  stickingCalmative = true
  if living then 
    send("sip immunity")
  else
    send("stick calmative")
  end
  add_timer(1, function() stickingCalmative = false end)
end

function doRage()
  balances:take("rage")
  send("rage")
end

function doShrug(s)
  if s.name ~= "limp_veins" then send("shrug " .. s.name) else send("shrug limpveins") end
  balances:take("shrugging")
end

function doTree()
  balances:take("tree")
  send("touch tree")
end

function doFocus()
  balances:take("focus")
  send("focus")
  if hasAffliction("stupidity") then send("focus") end
end

function doRecon()
  balances:take("reconstitute")
  if hasSkill("reconstitute") then send("reconstitute")
  elseif hasSkill("erase") then send("erase")
  elseif hasSkill("renew") then send("renew")
  end
end

function doAutosip()
  if (autosipper) then
    if not siphealth then
      echo("Error! Make sure to set siphealth!")
    elseif not sipmana then
      echo("Error! Make sure to set sipmana!")
    elseif not kidneyhealth then
      echo("Error! Make sure to set kidneyhealth!")
    elseif not kidneymana then
      echo("Error! Make sure to set kidneymana!")
    else
      if balances:check("serum") and not hasAffliction("anorexia") then
        if health < siphealth or (hasAffliction("recklessness") and recktarget == "health") then
          doStick("analeptic")
        elseif mana < sipmana or (hasAffliction("recklessness") and recktarget == "mana") then
          doStick("stimulant")
        end
      end

      if balances:check("kidney") and not hasAffliction("anorexia") and (health < kidneyhealth or mana < kidneymana or hasAffliction("recklessness") or plodding or idiocy) then
        doKidney()
      end
    end
  end
end

function doStand()
  if hasAffliction("left_leg_broken") or hasAffliction("right_leg_broken") then brokenleg = true else brokenleg = false end 
  
  if prompt.prone and balances:check("equilibrium") and not brokenleg and not hasAffliction("paralysis") and
    not asleep and not stunned and not unconscious and not standing and
    not entangled then
    if not canKipup then
      if balances:check("balance") then
        send("stand")
      end
    else
      send("kipup")
    end
    standing = true
    add_timer(1, function() standing = false end)
  end
end

function doHeal()
  local organ_target, tincture_target, poultice_target
  local rage_target, tree_target, focus_target, shrug_target, recon_target
  writhe_target = nil
  
  local treeaffs = {}
  local focusaffs = {}
  local organaffs = {}
  local poulticeaffs = {}
  local tinctureaffs = {}
  local rageaffs = {}
  local shrugaffs = {}
  writheaffs = {}

  local function removeFromAll(n)
    tableRemove(organaffs, n)
    tableRemove(poulticeaffs, n)
    tableRemove(tinctureaffs, n)
    tableRemove(focusaffs, n)
    tableRemove(treeaffs, n)
  end

  for i, v in ipairs(afflictionList) do
    if not isCuring(v.name) then
      if v.type == "organ" then
        table.insert(organaffs, v)
      elseif v.type == "tincture" then
        table.insert(tinctureaffs, v)
      elseif (v.type == "poultice") then
        table.insert(poulticeaffs, v)
      elseif v.type == "writhe" then
        table.insert(writheaffs, v)
      end
      
      if v.rage and isClass("atabahi") then
        table.insert(rageaffs, v)
      end
      
      if v.tree and canTree then
        table.insert(treeaffs, v)
      end
      
      if v.focus and canFocus then
        table.insert(focusaffs, v)
      end
      
      if v.shrug and isClass("syssin") then
        table.insert(shrugaffs, v)
      end
    end
  end -- End checking loop.
  
  -- Sort the tables
  if #organaffs > 0 then 
    table.sort(organaffs, function(a,b) return sortByPri(a,b) end) 
  end
  
  if #poulticeaffs > 0 then 
    table.sort(poulticeaffs, function(a,b) return sortByPri(a,b) end)
  end
  
  if #tinctureaffs > 0 then 
    table.sort(tinctureaffs, function(a,b) return sortByPri(a,b) end)
  end
  
  if #rageaffs > 0 then 
    table.sort(rageaffs, function(a,b) return sortByPri(a,b) end) 
  end
  
  if #treeaffs > 0 then 
    table.sort(treeaffs, function(a,b) return sortByPri(a,b) end)
  end
  
  if #focusaffs > 0 then 
    table.sort(focusaffs, function(a,b) return sortByPri(a,b) end)
  end
  
  if #shrugaffs > 0 then
    table.sort(shrugaffs, function(a,b) return sortByPri(a,b) end)
  end

  if #writheaffs > 0 then
    table.sort(writheaffs, function(a,b) return sortByPri(a,b) end)
  end

  -- If you have both stupidity and paralysis, get rid of stupidity in organs so it can
  -- be cured by focus.
  if hasAffliction("stupidity") and hasAffliction("paralysis") and canFocus then
    table.remove(organaffs, 1)
  end
  
    -- Filter focus afflictions
  for y=1,#focusaffs do
    for i,v in ipairs(focusaffs) do
      if #organaffs > 0 and balances:check("organ") and organaffs[1].name == focusaffs[i].name or
        #poulticeaffs > 0 and balances:check("poultice") and poulticeaffs[1].name == focusaffs[i].name or
        #tinctureaffs > 0 and balances:check("tincture") and tinctureaffs[1].name == focusaffs[i].name or
        #rageaffs > 0 and balances:check("rage") and rageaffs[1].name == focusaffs[i].name then
        table.remove(focusaffs, i)
      end
    end
  end
  
  -- Filter tree afflictions
  for z=1,#treeaffs do
    for i,v in pairs(treeaffs) do
      if #organaffs > 0 and balances:check("organ") and  organaffs[1].name == treeaffs[i].name or
        #poulticeaffs > 0 and balances:check("poultice") and poulticeaffs[1].name == treeaffs[i].name or
        #tinctureaffs > 0 and balances:check("tincture") and tinctureaffs[1].name == treeaffs[i].name or
        #rageaffs > 0 and balances:check("rage") and rageaffs[1].name == treeaffs[i].name  or
        treeaffs[i].name == "head_mangled" or
        treeaffs[i].name == "head_damaged" or
        treeaffs[i].name == "spinal_rip" or 
        treeaffs[i].name == "torso_mangled" or 
        treeaffs[i].name == "torso_damaged" or 
        (treeaffs[i].name == "left_leg_broken" and (hasAffliction("left_leg_damaged") or hasAffliction("left_leg_mangled"))) or
        (treeaffs[i].name == "right_leg_broken" and (hasAffliction("right_leg_damaged") or hasAffliction("right_leg_mangled"))) or
        (treeaffs[i].name == "left_arm_broken" and (hasAffliction("left_arm_damaged") or hasAffliction("left_arm_mangled"))) or
        (treeaffs[i].name == "right_arm_broken" and (hasAffliction("right_arm_damaged") or hasAffliction("right_arm_mangled"))) then
        table.remove(treeaffs, i)
      elseif canFocus then
        for j,b in ipairs(focusaffs) do
          if v.name == b.name and balances:check("focus") then
            table.remove(treeaffs, i)
          end
        end
      end
    end
  end
  
  if #rageaffs > 0 then
    for i in ipairs(rageaffs) do
      if rageaffs[i].name == organaffs[1].name and balances:check("rage") then
        table.remove(organaffs, 1)
      end
    end
  end
  
  if #shrugaffs > 0 and balances:check("shrugging") then
    if hasAffliction("anorexia") then
      shrug_target = afflictionTable.anorexia
    elseif hasAffliction("limp_veins") or hasAffliction("asthma") then
      if living and hasAffliction("asthma") then
        shrug_target = afflictionTable.asthma
      elseif not living and hasAffliction("limp_veins") then
        shrug_target = afflictionTable.limp_veins
      end
    elseif hasAffliction("slickness") then
      shrug_target = afflictionTable.slickness
    end
  end
  
  if isClass("syssin") then
    if #organaffs > 0 and shrug_target and organaffs[1].name == shrug_target.name then table.remove(organaffs, 1) end
    if #tinctureaffs > 0 and shrug_target and tinctureaffs[1].name == shrug_target.name then table.remove(tinctureaffs, 1) end
    if #poulticeaffs > 0 and shrug_target and poulticeaffs[1].name == shrug_target.name then table.remove(poulticeaffs, 1) end
  end

  -- Select targets
  if #organaffs > 0 then organ_target = organaffs[1] end
  if #poulticeaffs > 0 then poultice_target = poulticeaffs[1] end
  if #tinctureaffs > 0 then tincture_target = tinctureaffs[1] end
  if #rageaffs > 0 then rage_target = rageaffs[1] end
  if #treeaffs > 0 then 
    tree_target = treeaffs[1] 
  -- elseif afflictedWithSomething then 
  --   tree_target = {name="something"} 
  end
  
  if hasSkill("reconstitute") or hasSkill("erase") or hasSkill("renew") then
    if #treeaffs > 1 then
      recon_target = treeaffs[2]
    elseif tree_target and hasAffliction("paralysis") then  
      recon_target = treeaffs[1] 
    end
  end


  if #focusaffs > 0 then focus_target = focusaffs[1] end
  if #writheaffs > 0 then writhe_target = writheaffs[1] end

  -- Start healing.
  if voyria and not stickingCalmative and not hasAffliction("anorexia") then
    doStickCalmative()
  end
  
  if shrug_target and balances:check("shrugging") and not shrugging then
    tryingToCure(shrug_target)
    doShrug(shrug_target)
  end
  
  if rage_target and not raging and balances:check("rage") then
    tryingToCure(rage_target)
    doRage()
  end
  
  if organ_target and not hasAffliction("anorexia") and balances:check("organ") then
    if not isCuring(organ_target.name) then 
      doEat(organ_target.cure) 
      tryingToCure(organ_target)
    end
  end
  
  if poultice_target and not hasAffliction("slickness") and balances:check("poultice") then
    if not isCuring(poultice_target.name) then 
      doApply(poultice_target.cure)
      tryingToCure(poultice_target)
    end
  end
  
  if tincture_target and balances:check("tincture") and (not (hasAffliction("asthma") and living) or (hasAffliction("limp_veins") and not living)) then
    if balance and equilibrium then
      doFlick()
    end
    if not isCuring(tincture_target.name) then 
      doInject(tincture_target.cure)
      tryingToCure(tincture_target)
    end  
  end
  
  if focus_target and not hasAffliction("impatience") and balances:check("focus") and not tryingFocus and canUseMana() then
    if not isCuring(focus_target.name) then 
      doFocus()
      tryingToCure(focus_target)
    end
  end
  
  if tree_target and not hasAffliction("paralysis") and balances:check("tree") and not touchingTree then
    if not isCuring(tree_target.name) then 
      doTree()
      tryingToCure(tree_target)
    end
  end

  if recon_target and balances:check({"reconstitute", "balance", "equilibrium"}) and canUseMana() then
    doRecon()
    tryingToCure(recon_target)
  end

  if writhe_target and not writhing and not writhed then
    send(writhe_target.cure)
    writhing = true
    add_timer(1, function() writhing = false end)
  end

  if hasAffliction("writhe_cocoon") and not startBreakingCocoon and not breakingCocoon then
    send("break cocoon")
    startBreakingCocoon = true
    add_timer(1, function() startBreakingCocoon = false end)
  end

  if hasAffliction("void") or hasAffliction("weakvoid") and not tryingVoid then
    if not poultice_target and balances:check("poultice") then
      tryingVoid = true
      add_timer(1, function() tryingVoid = false end)
      doApply("orbis")
    elseif not tincture_target and balances:check("tincture") then
      tryingVoid = true
      add_timer(1, function() tryingVoid = false end)
      doInject("antispasmadic")
    elseif not organ_target and balances:check("organ") then
      tryingVoid = true
      add_timer(1, function() tryingVoid = false end)
      doEat("lung")
    end
  end

  if hasAffliction("anorexia") and hasAffliction("slickness") and ((living and hasAffliction("asthma")) or (not living and hasAffliction("limp_veins"))) then
    -- Toxin locked!!
    if class and class.tLocked then
      class.tLocked()
    end
  end
end

tableCuring = {}
function tryingToCure(aff)
  if not isCuring(aff.name) then
    table.insert(tableCuring, aff)
    add_timer(1, function() doneTryingToCure(aff) end)
  end
end

function doneTryingToCure(aff)
  local lines = 0
  for k,v in pairs(tableCuring) do
    lines = lines + 1
    if v.name == aff.name then table.remove(tableCuring, lines) end
  end
end

function isCuring(aff)
  for k,v in pairs(tableCuring) do
    if v.name:match(aff) then return true end
  end
  return false
end



function cureReset()
  if lastEaten then
    for k,v in pairs(afflictionList) do
      if v.cure and v.cure:find(convertToUndead(lastEaten)) then
        afflictionCure(v.name)
      end
    end
    echo (C.B .. "\nReset cures for " .. C.G .. lastEaten .. C.B .. "." .. C.x )
    show_prompt()
    return
  end

  if lastApplied then
    for k,v in pairs(afflictionList) do
      if v.cure and v.cure and v.cure:find(convertToUndead(lastApplied)) then
        afflictionCure(v.name)
      end
    end
    echo (C.B .. "\nReset cures for " .. C.G .. lastApplied .. C.B .. "." .. C.x )
    show_prompt()
    return
  end

  if lastInjected then
    if lastInjected == "sudorific" then return end

    for k,v in pairs(afflictionList) do
      if v.cure and v.cure:find(convertToUndead(lastInjected)) then
        afflictionCure(v.name)
      end
    end
    echo (C.B .. "\nReset cures for " .. C.G .. lastInjected .. C.B .. "." .. C.x )
    show_prompt()
    return
  end

  if focused then
    for k,v in pairs(afflictionList) do
      if v.focus then
        afflictionCure(v.name)
      end
    end
    echo (C.B .. "\nReset cures for " .. C.G .. "focus" .. C.B .. "." .. C.x )
    show_prompt()
    return
  end

  if touchedTree then
    for k,v in pairs(afflictionList) do
      if v.tree then
        afflictionCure(v.name)
      end
    end
    echo (C.B .. "\nReset cures for " .. C.G .. "tree" .. C.B .. "." .. C.x )
    show_prompt()
    return
  end

  if raged then
    for k,v in pairs(afflictionList) do
      if v.rage then
        afflictionCure(v.name)
      end
    end
    echo (C.B .. "\nReset cures for " .. C.G .. "rage" .. C.B .. "." .. C.x )
    show_prompt()
    return
  end
end

function afflictionCure(input)
  local tableCount = 0 -- Sets a counter to 0.

  for k, v in pairs(afflictionList) do
    tableCount = tableCount + 1 -- For each step in afflictionList, add 1.
    if (v.name == input) then -- Search for "affliction" in the names in afflictionList
      table.remove(afflictionList,tableCount) -- Remove that part of the afflictionList, detected by tableCounter
      extraLine = extraLine .. C.B .. " (" .. C.G .. "-" .. input .. C.B .. ") " .. C.x
      Announcer:announce("Cured " .. input)
      if input == "confusion" then send("concentrate") end
    end
  end -- End loop


  -- Reset writhe variables if curing a writhing affliction.
  if input:find("writhe") or input:find("grapple") then writhed = false writhing = false end
end -- End function afflictionCure( affliction)

function afflictionAdd(input)
  local alreadyAfflicted
  local affliction
  
  -- Find the affliction in the table...
  for k, v in pairs(afflictionTable) do
    if (v.name == input) then
      affliction = v
    end
  end
  
  -- If the affliction exists, add it to afflictionList
  if affliction ~= nil then
    if (not hasAffliction(input)) then
      table.insert(afflictionList, affliction)
      Announcer:announce("Afflicted with ".. affliction.name)
      if (affliction.name == "recklessness") then
        local healthper, manaper
        healthper = prompt.lastHealth / atcp.max_health
        manaper = prompt.lastMana / atcp.max_mana
        if (healthper >= manaper) then reckTarget = "health" else reckTarget = "mana" end
      end
    end
    extraLine = extraLine .. C.B .. " (" .. C.R .. "+" .. affliction.name .. C.B .. ") " .. C.x
  else
    echo("\nAFFLICTION " .. input .. " NOT FOUND")
  end
end

function doFlick()
  if syringeflicked or flicking or not prompt.balance or not prompt.equilibrium then return end

  if not artiPipes then
    if living then
      send("light pipes")
    else
      send("flick syringes")
    end
    flicking = true
    add_timer( 1, function() flicking = false end)
  end
end

function startHeal()
  healer = true
end

function stopHeal()
  healer = false
end