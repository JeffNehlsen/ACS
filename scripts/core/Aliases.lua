echo("Alias file loaded.")

aliases.coreAliases = {
  -- Useful for testing stuff
  {pattern = "^> (.*)$", handler = function(input, pattern) doInLua(input, pattern) end},
  {pattern = "^reload$", handler = function(input, pattern) reloadLua() end},
  {pattern = "^reload (%w+)", handler = function(i, p) reloadLua(i, p) end},
  {pattern = "^docomm (%w+) (.*)", handler = function(i,p) sendTestCommand(i,p) end}, 
  {pattern = "^debug$", handler = function(i,p) switchDebug() end},
  
  {pattern = "^tar (.*)", handler = function(input, pattern) setTarget(input, pattern) end},
  
  -- showPaths can be updated to include useful map paths.
  {pattern = "^paths$", handler = function(i,p) showPaths() end},
  
  -- General
  {pattern = "^th$", handler = function(i,p) doHammer() end},
  {pattern = "^ts$", handler = function(i,p) doShield() end},
  {pattern = "^tw$", handler = function(i,p) doWeb() end},
  {pattern = "^flick$", handler = function(i,p) flickAll() end},
  {pattern = "^dosleep$", handler = function(i,p) send("relax insomnia") send("sleep") end},
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

function doShield()
  if classType == "teradrim" then
    doWield(crozier, tower)
    send("sand shield")
  else
    send("touch shield")
  end
end

function doWeb()
  if weapons and weapon.bola then
    -- TODO: Set this to properly use wielding
    doWield("bola")
    send("throw bolas at " .. target)
  else
    send("touch web " .. target)
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

function flickAll()
  echo("Flicking everything")
  show_prompt()
  send("flick syringes")
end

function doBehead()
  addAction("startBehead()", true)
  show_prompt()
end

function startBehead()
  send("behead " .. target)
end

function beheadQuit()
  --addAction("unequipSword()", false)
end

function doShatter(limb)
  send("wield " .. hammer)
  send("shatter " .. limb .. " " .. target)
end

function shatterQuit()
  addAction("unequipHammer()")
end

function equipSword()
  send("wield " .. sword)
end

function unequipSword()
  send("secure " .. sword)
end

function equipHammer()
  send("wield " .. hammer)
end

function unequipHammer()
  send("secure " .. hammer)
end