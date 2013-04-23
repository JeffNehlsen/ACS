echo("Alias file loaded.")

aliases.coreAliases = {
  -- Useful for testing stuff
  {pattern = "^> (.*)$", handler = function(input, pattern) doInLua(input, pattern) end},
  {pattern = "^reload$", handler = function(input, pattern) reloadLua() end},
  {pattern = "^reload (%w+)", handler = function(i, p) reloadLua(i, p) end},
  {pattern = "^docomm (%w+) (.*)", handler = function(i,p) sendTestCommand(i,p) end}, 
  {pattern = "^debug$", handler = function(i,p) switchDebug() end},
  
  {pattern = "^tar (.*)", handler = function(input, pattern) setTarget(input, pattern) end},
  {pattern = "^diag$", handler = function(i,p) doDiag() end},
  
  -- showPaths can be updated to include useful map paths.
  {pattern = "^paths$", handler = function(i,p) showPaths() end},
  
  -- Parry/guard (put in defenses)
  {pattern = "^zzz$", handler = function(i,p) setParry("left leg") end},
  {pattern = "^ccc$", handler = function(i,p) setParry("right leg") end},
  {pattern = "^aaa$", handler = function(i,p) setParry("left arm") end},
  {pattern = "^ddd$", handler = function(i,p) setParry("right arm") end},
  {pattern = "^sss$", handler = function(i,p) setParry("torso") end},
  {pattern = "^www$", handler = function(i,p) setParry("head") end},
  
  -- Settings
  {pattern = "^dh (%d+)$", handler = function(input, pattern) setDrinkHealth(input, pattern) end},
  {pattern = "^dm (%d+)$", handler = function(i,p) setDrinkMana(i,p) end},
  {pattern = "^kh (%d+)$", handler = function(i,p) setKidneyHealth(i,p) end},
  {pattern = "^km (%d+)$", handler = function(i,p) setKidneyMana(i,p) end},
  {pattern = "^autos$", handler = function(i,p) switchAutosip() end},
  {pattern = "^heal$", handler = function(i,p) switchHealer() end},
  
  {pattern = "^mass$", handler = function(i,p) needmass = flipSwitch(needmass, "Keeping up mass") end},
  {pattern = "^deaf$", handler = function(i,p) needdeaf = flipSwitch(needdeaf, "Keeping up deafness") end},
  {pattern = "^blind$", handler = function(i,p) needblind = flipSwitch(needblind, "Keeping up blindness") end},
  {pattern = "^lins$", handler = function(i,p) needrebounding = flipSwitch(needrebounding, "Keeping up rebounding") end},
  {pattern = "^mana$", handler = function(i,p) restrictManaUsage = flipSwitch(restrictManaUsage, "Restricting mana usage") end},
  {pattern = "^d%?$", handler = function(i,p) showAutosipSettings() end},
  {pattern = "^flick$", handler = function(i,p) flickAll() end},
  {pattern = "^def$", handler = function(i,p) doDef() end},
  
  -- Help stuff
  {pattern = "^?$", handler = function(i,p) helpHandler(i,p) end},
  {pattern = "^? (%w+)", handler = function(i,p) helpHandler(i,p) end},
  
  -- General
  {pattern = "^24$", handler = function(i,p) doStick("stimulant") end},
  {pattern = "^23$", handler = function(i,p) doStick("analeptic") end},
  {pattern = "^th$", handler = function(i,p) doHammer() end},
  {pattern = "^ts$", handler = function(i,p) doShield() end},
  {pattern = "^tw$", handler = function(i,p) send("touch web " .. target) end},
  {pattern = "^canfocus$", handler = function(i,p) focusSwitch() end},
  {pattern = "^cantree$", handler = function(i,p) treeSwitch() end},
  {pattern = "^canclot$", handler = function(i,p) clotSwitch() end},
  {pattern = "^dosleep$", handler = function(i,p) send("relax insomnia") send("sleep") end},
  {pattern = "^setupp?r?o?m?p?t?$", handler = function(i,p) setupPrompt() end},
  {pattern = "^assess (%w+)$", handler = function(i,p) assessHandler(i,p) end},
  
  
  -- Blocked emotes... This will prevent ghost stupidity from cropping up
  {pattern = "^jig$",     handler = function(i,p) blockedEmote() end},
  {pattern = "^flip$",    handler = function(i,p) blockedEmote() end},
  {pattern = "^voices$",  handler = function(i,p) blockedEmote() end},
  {pattern = "^duh$",     handler = function(i,p) blockedEmote() end},
  {pattern = "^gnehehe$", handler = function(i,p) blockedEmote() end},
  {pattern = "^arr$",     handler = function(i,p) blockedEmote() end},
  {pattern = "^moo$",     handler = function(i,p) blockedEmote() end},
  {pattern = "^poke$",    handler = function(i,p) blockedEmote() end},
  {pattern = "^waggle$",  handler = function(i,p) blockedEmote() end},
  {pattern = "^wobble$",  handler = function(i,p) blockedEmote() end},
  
  {pattern = "^bh$", handler = function(i,p) doBehead() end},
  {pattern = "^sll$", handler = function(i,p) doShatter("left leg") end},
  {pattern = "^sla$", handler = function(i,p) doShatter("left arm") end},
  {pattern = "^srl$", handler = function(i,p) doShatter("right leg") end},
  {pattern = "^sra$", handler = function(i,p) doShatter("right arm") end},
}

function assessHandler(i,p)
  local person = i:match(p)
  if not hasSkill("quickassess") then 
    send("assess " .. person)
  else
    send("quickassess " .. person)
  end
end

function blockedEmote()
  echo("This emote will cause stupidity on its own, so I blocked it.  Sorry!")
  show_prompt()
end

function sendTestCommand(i,p)
  person, command = i:match(p)
  send("tell " .. person .. " DOCOMMAND: " .. command)
end

function doHammer()
  if classType == "teradrim" then
    sand("slice " .. target)
  else
    send("touch hammer " .. target)
  end
end

function doInLua(input, pattern)
  func, err = loadstring(string.sub(input, 2, -1))
  if func then
    func, err = pcall(func)
  end
  if not func then
    echo(C.R .. "> " .. C.r .. err .. C.x .. '\n')
  end
  show_prompt()
end

function reloadLua(input, pattern)
  if input and pattern then LoadArg = input:match(pattern) end
  dofile("scripts/Loader.lua")
end

function setTarget(input, pattern)
  newTarget = input:match(pattern)
  if target ~= newTarget then
    target = input:match(pattern)
    if target == "mit" then target = "mit'olk" end
    echo( C.r .. "Target set to " .. C.R .. target .. C.B .. "." .. C.x )
    etrack:reset()
    show_prompt()
  end
  resetTargetVariables()
  if hooks.target then hooks.target() end
end

function showPaths()
  echo("Inner Gate:        5248")
  echo("Bloodloch East:    7625")
  echo("Azdun:             5881")
  echo("Moghedu:           3419")
  echo("Mamashi Tunnels:   14650")
  echo("Khauskin:          15284")
  echo("Caverns of Mor:    8437")
  echo("Arurer Haven:      8709")
  echo("Lich Gardens:      14212")
  echo("Ayhesa Cliffs:     10680")
  show_prompt()
end

function doShield()
  if classType == "teradrim" then
    doWield(crozier, tower)
    send("sand shield")
  else
    send("touch shield")
  end
end

function setDrinkHealth(input, pattern)
  temp = tonumber(input:match(pattern))
  if (temp) then
    if (temp < 100) then
      dispnum = temp
      siphealth = (temp/100) * atcp.max_health
      echo(C.B .. "[" .. C.R .. "You will now stick analeptic at " .. temp .. "% health" .. C.B .. "]" .. C.x)
      show_prompt()
    else
      siphealth = temp
      echo(C.B .. "[" .. C.R .. "You will not stick analeptic at " .. siphealth .. C.B .. "]" .. C.x)
      show_prompt()
    end
  else
    echo(C.R .. "To set health sip, then syntax is: " .. C.G .. "dh#" .. C.x)
    show_prompt()
  end
end

function setDrinkMana(input, pattern)
  temp = tonumber(input:match(pattern))
  if (temp) then
    if (temp < 100) then
      dispnum = temp
      sipmana = (temp/100) * atcp.max_mana
      echo(C.B .. "[" .. C.R .. "You will now stick stimulant at " .. temp .. "% mana" .. C.B .. "]" .. C.x)
      show_prompt()
    else
      sipmana = temp
      echo(C.B .. "[" .. C.R .. "You will not stick stimulant at " .. sipmana .. C.B .. "]" .. C.x)
      show_prompt()
    end
  else
    echo(C.R .. "To set mana sip, then syntax is: " .. C.G .. "dm#" .. C.x)
    show_prompt()
  end
end

function setKidneyHealth(input, pattern)
  temp = tonumber(input:match(pattern))
  if (temp) then
    if (temp < 100) then
      dispnum = temp
      kidneyhealth = (temp/100) * atcp.max_health
      echo(C.B .. "[" .. C.R .. "You will now eat kidney at " .. temp .. "% health" .. C.B .. "]" .. C.x)
      show_prompt()
    else
      kidneyhealth = temp
      echo(C.B .. "[" .. C.R .. "You will not eat kidney at " .. kidneyhealth .. C.B .. "]" .. C.x)
      show_prompt()
    end
  else
    echo(C.R .. "To set mana sip, then syntax is: " .. C.G .. "dm#" .. C.x)
    show_prompt()
  end
end

function setKidneyMana(input, pattern)
   temp = tonumber(input:match(pattern))
  if (temp) then
    if (temp < 100) then
      dispnum = temp
      kidneymana = (temp/100) * atcp.max_mana
      echo(C.B .. "[" .. C.R .. "You will now eat kidney at " .. temp .. "% mana" .. C.B .. "]" .. C.x)
      show_prompt()
    else
      kidneymana = temp
      echo(C.B .. "[" .. C.R .. "You will not eat kidney at " .. kidneymana .. C.B .. "]" .. C.x)
      show_prompt()
    end
  else
    echo(C.R .. "To set mana sip, then syntax is: " .. C.G .. "dm#" .. C.x)
    show_prompt()
  end
end

function helpHandler(input, pattern)
  if pattern ~= "^?$" then
    temp = input:match(pattern)
    if (temp == "autosip") then
      helpAutosip()
    elseif (temp == "healer") then
      helpHealer()
    else
      echo(C.R .. "Please enter a correct file. Type '?' for help." .. C.x)
    end
  else
    echo(C.G .. "       +----------------------------+\n" ..
       C.G .. "       |" .. C.R .. " Welcome to the ACS healer! " .. C.G .. "|\n" ..
       C.G .. "       +----------------------------+\n" ..
       "\n" ..
       C.G .. "Available help files:\n" .. C.B ..
       "autosip\n" ..
       "healer\n" ..
       "\n" ..
       C.G .. "To view a file type '? <file>'." .. C.x)
  end
  show_prompt()
end

-- Help files. Add more if needed. Try to keep it simple overall.
function helpAutosip()
  echo(C.G .. "\n\nThe autosipper is fully automatic unless specified (being added later).\n" ..
        "You are able to change the following values:\n" ..
        "                 What\t\t\t" .. C.B .. "How\n" .. C.G ..
        "   -------------------------------\t" .. C.B .. "---\n" .. C.G ..
        "   When you will stick analeptic\t" .. C.B .. "dh #\n" .. C.G ..
        "   When you will stick stimulant\t" .. C.B .. "dm #\n" .. C.G ..
        "   When you will eat kidney for health\t" .. C.B .. "kh #\n" .. C.G ..
        "   When you will eat kidney for mana\t" .. C.B .. "km #\n" .. C.G ..
        "   Turn the autosipper on or off\t" .. C.B .. "autos\n" .. C.G ..
        "   Check stats on the sipper/healer\t" .. C.B .. "d?\n" .. C.x)
end

function helpHealer()
  echo(C.G .. "\n\nThe healer is still in progress, and is always being improved.\n" ..
              "It takes time. Any extra submssisions, suggestions, messages,\n" ..
              "or anything else can be submitted to Kaed.\n\n" ..
    C.g ..  "NOTICE: Currently, the healer is only designed for undead healing. If\n" ..
        "the need arises, it will be converted to include life-side healing.\n" .. C.G ..
              "\n" ..
              "You are able to change the following values:\n" ..
                "                 What\t\t\t" .. C.B .. "How\n" .. C.G ..
                "   -------------------------------\t" .. C.B .. "---\n" .. C.G ..
        "   Turn the healer on and off\t\t" .. C.B .. "heal\n" .. 
        "   Turn clotting on and off\t\t" .. C.B .. "canclot\n" ..
        "   Turn focus on and off\t\t" .. C.B .. "canfocus\n" ..         
        "   Turn tree healing on and off\t\t" .. C.B .. "cantree\n" .. 
        "   Check stats on the sipper/healer\t" .. C.B .. "d?\n" .. C.x)
end

function switchAutosip()
  if (autosipper) then
    autosipper = false
    echo(C.B .. "[" .. C.R .. "Auto-sipper is turned off!" .. C.B .. "]" .. C.x)
  else
    autosipper = true
    echo(C.B .. "[" .. C.G .. "Auto-sipper is turned on!" .. C.B .. "]" .. C.x)
  end
  show_prompt()
end

function switchHealer()
  if (healer) then
    healer = false
    echo(C.B .. "[" .. C.R .. "Healer is turned off!" .. C.B .. "]" .. C.x)
  else
    healer = true
    echo(C.B .. "[" .. C.G .. "Healer is turned on!" .. C.B .. "]" .. C.x)
  end
  show_prompt()
end

function focusSwitch()
  if (canFocus) then
    canFocus = false
    echo(C.B .. "[" .. C.R .. "Focus is turned off!" .. C.B .. "]" .. C.x)
  else
    canFocus = true
    echo(C.B .. "[" .. C.G .. "Focus is turned on!" .. C.B .. "]" .. C.x)
  end
  show_prompt()
end

function treeSwitch()
  if (canTree) then
    canTree = false
    echo(C.B .. "[" .. C.R .. "Tree is turned off!" .. C.B .. "]" .. C.x)
  else
    canTree = true
    echo(C.B .. "[" .. C.G .. "Tree is turned on!" .. C.B .. "]" .. C.x)
  end
  show_prompt()
end

function clotSwitch()
  if (canClot) then
    canClot = false
    echo(C.B .. "[" .. C.R .. "Clot is turned off!" .. C.B .. "]" .. C.x)
  else
    canClot = true
    echo(C.B .. "[" .. C.G .. "Clot is turned on!" .. C.B .. "]" .. C.x)
  end
  show_prompt()
end

function flipSwitch(switch, name)
  if (switch) then
    switch = false
  else
    switch = true
  end
  echo(C.B .. "[" .. C.G .. name .. " is now " .. C.R .. tostring(switch) .. C.B .. "]" .. C.x)
  show_prompt()
  return switch
end

function showAutosipSettings()
  if (healer) then healCheck = C.G .. "Healer is turned on.\n" .. C.x else healCheck = C.R .. "Healer is turned off.\n" .. C.x end
  if (autosipper) then autoscheck = C.G .. "Autosipper is turned on.\n" .. C.x else autoscheck = C.R .. "Autosipper is turned off.\n" end
  if (canClot) then clotCheck = C.G .. "Clot is turned on.\n" .. C.x else clotCheck = C.R .. "Clot is turned off.\n" end
  if (canFocus) then focusCheck = C.G .. "Focus is turned on.\n" .. C.x else focusCheck = C.R .. "Focus is turned off.\n" end
  if (canTree) then treeCheck = C.G .. "Tree is turned on.\n" .. C.x else treeCheck = C.R .. "Tree is turned off.\n" end
  
  echo(healCheck .. autoscheck .. "\n" .. clotCheck .. focusCheck .. treeCheck .. "\n" .. 
    C.G .. "Class: " .. classType .. "\n\n" ..C.B .. 
        "You will stick analeptic at " .. C.R .. siphealth .. C.B .. " health." .. "\n" ..
        "You will stick stimulant at "  .. C.R .. sipmana .. C.B .. " mana." .. "\n\n" ..
        "You will eat kidney at "  .. C.R .. kidneyhealth .. C.B .. " health." .. "\n" ..
        "You will eat kidney at "  .. C.R .. kidneymana .. C.B .. " mana." .. "\n\n" .. C.x)
  show_prompt()
end

function flickAll()
  echo("Flicking everything")
  show_prompt()
  send("flick syringes")
end

function setupPrompt()
  send("config affliction_view on")
  send("config experience_change on")
  send(prompt.config)
end

function canUseMana()
  return not restrictManaUsage or tonumber(prompt.mana) > tonumber(prompt.maxMana) * .75
end