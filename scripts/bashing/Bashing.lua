echo("Bashing file loaded.")
--This is where I'll set up my full bashing system.

autob = false
multib = false
tryingAttack = false
xpTotalToday = 0
needPickup = false
mihailHere = false
hecreeHere = false
targetList = {}
showTotalToMilestone = true

maxExpList = {
  [1]  = 5001,
  [2]  = 5500,
  [3]  = 10050,
  [4]  = 14655,
  [5]  = 15320,
  [6]  = 20052,
  [7]  = 24466,
  [8]  = 26957,
  [9]  = 30000,
  [10]  = 33000,
  [11]  = 40000,
  [12]  = 42000,
  [13]  = 45000,
  [14]  = 47000,
  [15]  = 48000,
  [16]  = 49000,
  [17]  = 50000,
  [18]  = 55000,
  [19]  = 60000,
  [20]  = 70000,
  [21]  = 70000,
  [22]  = 75000,
  [23]  = 80000,
  [24]  = 85000,
  [25]  = 90000,
  [26]  = 95000,
  [27]  = 100000,
  [28]  = 105000,
  [29]  = 110000,
  [30]  = 115000,
  [31]  = 120000,
  [32]  = 125000,
  [33]  = 125000,
  [34]  = 130000,
  [35]  = 135000,
  [36]  = 140000,
  [37]  = 145000,
  [38]  = 150000,
  [39]  = 255000,
  [40]  = 155000,
  [41]  = 160000,
  [42]  = 160000,
  [43]  = 165000,
  [44]  = 165000,
  [45]  = 170000,
  [46]  = 234000,
  [47]  = 203395,
  [48]  = 440987,
  [49]  = 485086,
  [50]  = 533594,
  [51]  = 586954,
  [52]  = 645649,
  [53]  = 710214,
  [54]  = 781236,
  [55]  = 859359,
  [56]  = 945295,
  [57]  = 1039825,
  [58]  = 1143807,
  [59]  = 1258188,
  [60]  = 1384007,
  [61]  = 1522408,
  [62]  = 1674649,
  [63]  = 1842113,
  [64]  = 2026325,
  [65]  = 2228957,
  [66]  = 2451853,
  [67]  = 2697038,
  [68]  = 2966000,
  [69]  = 3263417,
  [70]  = 3589758,
  [71]  = 3948734,
  [72]  = 4343608,
  [73]  = 4777969,
  [74]  = 7499575,
  [75]  = 10000000,
  [76]  = 13000000,
  [77]  = 17000000,
  [78]  = 20000000,
  [79]  = 30000000,
  [80]  = 35000000,
  [81]  = 40000000,
  [82]  = 45000000,
  [83]  = 50000000,
  [84]  = 55000000,
  [85]  = 60000000,
  [86]  = 65000000,
  [87]  = 70000000,
  [88]  = 75000000,
  [89]  = 80000000,
  [90]  = 85000000,
  [91]  = 90000000,
  [92]  = 95000000,
  [93]  = 100000000,
  [94]  = 105000000,
  [95]  = 110000000,
  [96]  = 115000000,
  [97]  = 120000000,
  [98]  = 125000000,
  [99]  = 330000000,
  [100] = 3465000,
  [101] = 3638250,
  [102] = 3820162,
  [103] = 4011170,
  [104] = 4211728,
  [105] = 4422314,
  [106] = 4643429,
  [107] = 4875600,
  [108] = 5119380,
  [109] = 5375349,
  [110] = 5644116,
  [111] = 5926321,
  [112] = 6222637,
  [113] = 6533768,
  [114] = 6860456,
  [115] = 7203478,
  [116] = 7563651,
  [117] = 7941833,
  [118] = 8338924,
  [119] = 8755870,
  [120] = 9193663,
}

function getCurrentLevel()
  local toReturn = 0
  if maxExperience then
    for k,v in pairs(maxExpList) do
      if maxExperience == v then 
        toReturn = k 
        break
      end
    end
  end
  return toReturn
end

function getTotalExperienceLeft()
  local total = "UNKNOWN"
  local level = getCurrentLevel()
  if maxExperience and level then
    total = 0
    local milestone = getNextMilestone(level)
    for i=level+1, milestone-1 do
      total = total + maxExpList[i]
    end
    total = total + prompt.maxXP - prompt.xp
  end
  return total
end

function getNextMilestone(currLevel)
  local milestone = 80
  if currLevel >= 80 and currLevel < 99 then
    milestone = 99
  elseif currLevel >= 99 then
    milestone = currLevel + 1
  end
  return milestone
end

aliases.bashingAliases = {
  {pattern = "^gg$", handler = function(i,p) getCorpses() end},
  {pattern = "^gr$", handler = function(i,p) getCorpses() end},
  {pattern = "^autob", handler = function(i,p) autoBash() end},
  {pattern = "^multib", handler = function(i,p) multiBash() end},
  {pattern = "^dobash", handler = function(i,p) doBash() end},
  {pattern = "^bashattack", handler = function(i,p) bashAttack() end},

  {pattern = "^mamashi$", handler = function(i,p) mamashiTargets() end},
  {pattern = "^azdun$", handler = function(i,p) azdunTargets() end},
  {pattern = "^mor$", handler = function(i,p) resetTargetList() addTarget("undead") end},
  {pattern = "^khauskin$", handler = function(i,p) khauskinTargets() end},
  {pattern = "^rtarget$", handler = function(i,p) resetTargetList() end},
  {pattern = "^arurer$", handler = function(i,p) arurerTargets() end},
  {pattern = "^lich", handler = function(i,p) lichTargets() end},
  {pattern = "^mog", handler = function(i,p) mogheduTargets() end},
  {pattern = "^threerock", handler = function(i,p) threerockTargets() end},

  {pattern = "^mihail$", handler = function(i,p) mihailHere = true echo("MIHAIL IS HERE!") end},
  {pattern = "^hecree$", handler = function(i,p) hecreeHere = true echo("HECREE IS HERE!") end},
}

triggers.bashingTriggers = {
  {pattern = "You cannot see that being here.", handler = function(p) if autob then killLine() end end},
  {pattern = "You detect nothing here by that name.", handler = function(p) if autob then killLine() end end},
  {pattern = "Nothing can be seen here by that name.", handler = function(p) if autob then killLine() end end},
  {pattern = "I do not recognize anything called that here.", handler = function(p) if autob then killLine() end end},
  {pattern = "Ahh, I am truly sorry, but I do not see anyone by that name here.", handler = function(p) if autob then killLine() end end},
  --{pattern = "You have recovered balance on your left arm.", handler = function(p) if autob then send("combo " .. target .. " claw claw") end end },
  --{pattern = "You have recovered balance on your right arm.", handler = function(p) if autob then send("combo " .. target .. " claw claw") end end },
  {pattern = "You have recovered balance on all limbs.", handler = function(p) if autob then newBash(true) end end},
  {pattern = "You do not have a free arm to do that.", handler = function(p) if autob then killLine() end end},
  {pattern = "You must stand up before you can do that.", handler = function(p) if autob then killLine() end end},
  {pattern = "^You bare your teeth and your claws lash out at (.*)%.$", handler = function(p) genericClaw(p) end},
  {pattern = "^You must regain balance first.", handler = function(p) if autob then killLine() end end},
  {pattern = "^You see no '(%w+)' to take.", handler = function(p) if autob then killLine() end end},
  {pattern = "^You have slain (.*).", handler = function(p) if autob then needPickup = true end end},
  {pattern = "^You cannot pick up (.*).", handler = function(p) if autob then killLine() end end},

  {pattern = "^Experience Gained: (%d+) %((%w+)%) %[total: (%d+)%]", handler = function(p) calcExperience(p) end},
  --{pattern = "^Damage done: (%d+)", handler = function(p) mobDamageHandler(p) end},
  --{pattern = "^Damage done: (%d+) %((%d+) overkill%)", handler = function(p) mobDamageHandler(p) end},
  --{pattern = "^Time to recover: (.+) seconds.$", handler = function(p) balUsedHandler(p) end},

}

function mobDamageHandler(p)
  dmg, overkill = mb.line:match(p)
  if not overkill then overkill = 0 end
  if not totalDamage then totalDamage = 0 end
  totalDamage = totalDamage + tonumber(dmg) + tonumber(overkill)
end

function balUsedHandler(p)
  local time = mb.line:match(p)
  time = tonumber(time)
  local dps = totalDamage / time
  if totalDamage > 0 then ACSEcho("DPS: " .. dps) totalDamage = 0 end
end

function resetTargetList()
  targetList = {}
  ACSEcho(C.R .. "Reset target list.")
end

function lichTargets()
  resetTargetList()
  addTarget("infernal")
  addTarget("cabalist")
  addTarget("lich")
  addTarget("experiment")
  addTarget("undead")
  show_prompt()
end

function addTarget(tar)
  table.insert(targetList, tar)
  ACSEcho(C.G .. "Added " .. tar .. " to targets.")
end

function khauskinTargets()
  resetTargetList()
  addTarget("dwarf")
  addTarget("sentry")
  addTarget("guard")
  addTarget("fangtooth")
  addTarget("klikkin")
  show_prompt()
end

function arurerTargets()
  resetTargetList()
  addTarget("priestess")
  addTarget("angel")
  addTarget("priest")
  addTarget("atavian")
end

function azdunTargets()
  resetTargetList()
  addTarget("goblin")
  addTarget("hobgoblin")
  addTarget("bat")
  addTarget("undead")
  addTarget("spider")
  show_prompt()
end

function mogheduTargets()
  resetTargetList()
  addTarget("mhun")
  addTarget("goblin")
  show_prompt()
end

function mamashiTargets()
  resetTargetList()
  addTarget("garthun")
  addTarget("nalas")
  addTarget("githani")
  addTarget("mit'olk")
  show_prompt()
end

function threerockTargets()
  resetTargetList()
  addTarget("bandit")
  addTarget("horse")
  addTarget("wildcat")
  addTarget("buffalo")
  show_prompt()
end

function newBash(override)
  if override or (autob and allbalance and equilibrium and not prone and not tryingAttack and not stunned and not unconscious and
    not asleep and not hasAffliction("paralysis")) then
    if needPickup == true then
      getCorpses()
      send("ih")
      send("maps")
    end
    if mihailHere == true then
      for i=1, 45 do send("give dwarf to mihail") end
      for i=1, 20 do send("give pickaxe to mihail") end
    end

    if hecreeHere == true then
      for i=1, 35 do send("give githani to hecree") end
    end

    needPickup = false
    mihailHere = false
    hecreeHere = false

    if #targetList > 0 then
      if health < 300 then
        doShield()
      else
        for _,v in ipairs(targetList) do
          newBashAttack(v)
        end
      end
      tryingAttack = true
      add_timer(1, tryingAttackTimer)
    else
      doBash()
    end
  end
end

function newBashAttack(tar)
  if isClass("atabahi") then
    send("combo " .. tar .. " claw claw")
  elseif isClass("carnifex") then
    send("pole spinslash " .. tar)
  elseif isClass("sentinel") then
    doWield(dhurive)
    send("dhuriv combo " .. tar .. " slash stab")
  elseif isClass("teradrim") then
    newTeradrimBash(tar)
  elseif classType == "bloodborn" or classType == "vampire" or classType == "praenomin" then
    send("frenzy " .. tar)
  elseif isClass("syssin") then
    doWield(whip, tower)
    send("garrote " .. tar)
    --send("secrete camus")
    --send("bite " .. tar)
  end
end

function newTeradrimBash(tar)
  if multib then
    doWield(flail, tower)
    send("swipe " .. tar .. " " .. tar .. " " .. tar)
  else
    doWield(crozier, tower)
    send("sand shred " .. tar)
  end
end

function calcExperience(p)
  if not prompt.blackout then
    gained, xpType, total = mb.line:match(p)
    left = prompt.maxXP - total
    xpTotalToday = xpTotalToday + gained
    --%format( "&10.0n",
    if currentExperience and maxExperience then
      if showTotalToMilestone then
        local level = getCurrentLevel()
        local milestone = getNextMilestone(level)
        left = getTotalExperienceLeft()
        setACSLabel(C.r .. xpType .. ": " .. comma_value(gained) .. " gained, " .. C.R .. comma_value(left) .. " left until " .. milestone .. "!")
      else
        setACSLabel(C.r .. xpType .. ": " .. comma_value(gained) .. " gained, " .. C.R .. comma_value(left) .. " remaining!")
      end
    end
  end
end

function comma_value(n)
  local left,num,right = string.match(n,'^([^%d]*%d)(%d*)(.-)$')
  return left..(num:reverse():gsub('(%d%d%d)','%1,'):reverse())..right
end

function getCorpses()
  if #targetList > 0 then
    for _,v in ipairs(targetList) do for i=1, 5 do
      send("get " .. v)
      if v == "dwarf" or v == "sentry" or v == "guard" then
        send("get pickaxe")
        send("get pickaxe")
      end
    end end
  else
    for i=1, 5 do send("get " .. target) end
  end
  send("get gold")

  -- Khauskin stuff
  -- if target == "vampire" or target == "dwarf" then
    -- send("get pickaxe")
    -- send("get pickaxe")
    -- send("get gem")
    -- send("get gem")
  -- end
end

function doBash()
  if autob and allbalance and equilibrium and not prone and not tryingAttack and not stunned and not unconscious and
    not asleep and not hasAffliction("paralysis") then
    if health < 1000 then
      doShield()
    else
      --send("flick syringes")
      newBashAttack(target)
    end
    tryingAttack = true
    add_timer(1, tryingAttackTimer)
  end
end

function bashAttack()
  --send("flick syringes")
  if classType == "atabahi" then
    send("combo " .. target .. " claw claw")
  elseif isClass("syssin") then
    send("garrote " .. target)
  elseif isClass("carnifex") then
    send("pole spinslash " .. target)  
  elseif classType == "teradrim" then
    teradrimBash()
  end
end

function teradrimBash()
  if multib then
    doWield(flail, tower)
    send("swipe " .. target .. " " .. target .. " " .. target)
  else
    doWield(crozier, tower)
    send("sand shred " .. target)
  end
end

function tryingAttackTimer()
  tryingAttack = false
end

function genericClaw(pattern)
  tmp = mb.line:match(pattern)
  replace(acsLabel .. C.g .. "Claw on " .. C.G .. tmp .. C.g .. "." .. C.x)
end

function multiBash()
  if not multib then
    multib = true
    tryingAttack = false
    echo(C.B .. "[" .. C.G .. "Multi-bash is turned on!" .. C.B .. "]")
  else
    multib = false
    echo(C.B .. "[" .. C.R .. "Multi-bash is turned off!" .. C.B .. "]")
  end
  show_prompt()
end

function autoBash()
  if not autob then
    autob = true
    tryingAttack = false
    echo(C.B .. "[" .. C.G .. "Auto-bash is turned on!" .. C.B .. "]")
  else
    autob = false
    echo(C.B .. "[" .. C.R .. "Auto-bash is turned off!" .. C.B .. "]")
  end
  show_prompt()
end

function ACSEcho(str)
  echo(acsLabel .. str .. C.x)
end
