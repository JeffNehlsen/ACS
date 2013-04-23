echo("New bashing system loaded")

-- 12885 = khauskin entrance
-- 15067 = mamashi
-- 12159 = lich gardens entrance

aliases.pathRecording = {
  {pattern = "^startrecording$", handler = function(i,p) recordingStartHandler() end},
  {pattern = "^stoprecording$",  handler = function(i,p) recordingStopHandler() end},
  {pattern = "^resetrecording$", handler = function(i,p) resetRecording() end},
  {pattern = "^printrecording$", handler = function(i,p) printRecording() end},
  {pattern = "^nw$",  handler = function(i,p) handleDirection("nw") end},
  {pattern = "^n$",   handler = function(i,p) handleDirection("n") end},
  {pattern = "^ne$",  handler = function(i,p) handleDirection("ne") end},
  {pattern = "^w$",   handler = function(i,p) handleDirection("w") end},
  {pattern = "^e$",   handler = function(i,p) handleDirection("e") end},
  {pattern = "^sw$",  handler = function(i,p) handleDirection("sw") end},
  {pattern = "^s$",   handler = function(i,p) handleDirection("s") end},
  {pattern = "^se$",  handler = function(i,p) handleDirection("se") end},
  {pattern = "^u$",   handler = function(i,p) handleDirection("u") end},
  {pattern = "^d$",   handler = function(i,p) handleDirection("d") end},
  {pattern = "^up$",   handler = function(i,p) handleDirection("u") end},
  {pattern = "^down$",   handler = function(i,p) handleDirection("d") end},
  {pattern = "^in$",  handler = function(i,p) handleDirection("in") end},
  {pattern = "^out$", handler = function(i,p) handleDirection("out") end},
}

aliases.newBashing = {
  {pattern = "^beginbashing (%a+)$", handler = function(i,p) handleBeginBashing(i,p) end},
  {pattern = "^stopbashing$", handler = function() moveQueue = {} ACSEcho("Move Queue is empty.  Feel free to move around!") end},
  {pattern = "^rlbashing$", handler = function() dofile("ACS-NewBashing.lua") show_prompt() end},
}

recording = {active = false}
recording.path = recording.path or {}

function handleDirection(dir)
  if recording.active then
    table.insert(recording.path, dir)
    debug("Insert " .. dir .. " to paths. #paths: " .. #recording.path)
  end
  send(dir)
end

function recordingStartHandler() 
  recording.active = true
  ACSEcho("Starting recording...")
end

function recordingStopHandler()
  recording.active = false
  ACSEcho("Stoping recording")
end

function printRecording()
  if #recording.path > 0 then
    ACSEcho("Recording results:")
    local str = "{"
    for i,v in ipairs(recording.path) do
      str = str .. "\"" .. v .. "\", "
    end
    str = str .. "},"
    echo(str)
  else
    ACSEcho("No recording to print!")
  end
end

function resetRecording()
  recoring.path = {}
  ACSEcho("Reset recording!")
end

targetList = {}
extraPickups = {}
lowHealthThreshold = 2000
selectedTarget = ""
mobTable = {
  mamashi = {
    "a Githani inscriber.",
    "a Githani grappler.",
    "a Githani master.",
    "a Mit'olk axeman.",
    "a Mit'olk illusionist.",
    "a Mit'olk bladesman.",
    "a greater nalas.",
    "a young nalas.",
    "a mature nalas.",
    "Garthun, the Maw.",
  },
  khauskin = {
    "a stout Dwarven man",
    "a stocky Dwarven woman",
    "a powerful Dwarven warrior",
    "a statuesque Dwarven guard",
    "Gordak, Leader of Khauskin",
    "a vampiric blood sentry",
    "a vampiric blood guard",
    "a burly Dwarven miner",
    "Gordak, Leader of Khauskin.",
  },
  mor = {
    "a ravenous, shadowy ghast.",
    "a robed, skeletal lich.",
    "a stench%-ridden ghoul.",
    "a vampiric warrior.",
    "a vampiric sentry.",
    "Aclyr, the vampiric general.",
  },
  lich = {
    "a monstrous Infernal guard.",
    "a mindless experiment.",
    "a student of the lich.",
    "a dark Cabalist scholar.",
    "a guardian wraith.",
    "a tattered Bahkatu experiment.",
    "a studious lich scientist.",
    "a commanding lich scientist.",
  },
  xoral = {
    "a Xorali man.",
    "a Xorali sentry.",
    "a curious Xorali woman.",
    "Lasotha, the sentry mother.",
    "a Xorali woman.",
    "an elite lizardfolk bodyguard.",
    "Thorasa, the lizardfolk matron."
  },
  ayhesa = {
    "a Spellshaper Master.",
    "a Spellshaper Adept.",
    "a Spellshaper Archon.",
  },
  extras = {
    "a durable pickaxe.",
    "a beaten Dwarven corpse.",
    "a worker's corpse.",
    "a vivisected Troll corpse.",
  },
}


moveQueue = {}
moveQueues = {
  khauskin  = {"s", "w", "e", "e", "w", "s", "w", "w", "e", "e", 
              "s", "sw", "w", "e", "ne", "n", "n", "n", "s", "s", 
              "s", "s", "d", "s", "e", "d", "n", "n", "n", "n", "nw", 
              "nw", "w", "sw", "s", "s", "e", "e", "e", "w", "s", 
              "sw", "s", "s", "se", "s", "n", "ne", "n", "n", "nw", 
              "s", "s", "s", "n", "n", "n", "n", "w", "w", "sw"},
  mamashi   = {"d", "e", "n", "se", "s", "w", "n", "w", "n", "w", 
               "n", "ne", "e", "se", "se", "n", "ne", "e", "w", "sw", 
               "s", "sw", "se", "s", "n", "nw", "s", "w", "sw", "e", 
               "se", "nw", "w", "nw", "w", "n", "ne", "n", "d", "nw", 
               "w", "s", "w", "w", "e", "e", "n", "nw", "w", "sw", 
               "ne", "e", "se", "e", "se", "sw", "e", "se", "sw", 
               "w", "e", "ne", "e", "ne", "n", "ne", "s", "se", "s", 
               "s", "sw", "nw", "nw", "se", "sw", "w", "sw", "w", 
               "w", "n", "n", "s", "s", "w", "w", "e", "e", "e", 
               "e", "e", "se", "ne", "e", "w", "ne", "nw", "se", 
               "ne", "n", "s", "sw", "sw", "sw", "nw", "w", "w", 
               "w", "n", "n", "w",},
  mor       = {"d", "n", "w", "nw", "w", "sw", "n", "nw", "sw", 
               "s", "e", "e", "sw", "w", "n", "w", "sw", "e", 
               "e", "n", "e", "e", "ne", "ne", "n", "e", "se", 
               "se", "sw", "w", "nw", "w", "ne", "n", "n", "n", 
               "se", "nw", "w", "nw", "se", "sw", "ne", "e", 
               "n", "n", "e", "se", "nw", "w", "d", "e", "e", 
               "nw", "nw", "nw", "n", "s", "s", "w", 
               "w", "s", "e", "w", "se", "e", "e", "e", "e", 
               "w", "w",},
  lich      = {"ne", "ne", "nw", "w", "nw", "n", "ne", "e", "e", 
               "se", "s", "sw", "w", "n", "n", "n", "n", "e", "ne", 
               "se", "e", "n", "s", "e", "n", "s", "s", "n", "e", 
               "e", "ne", "ne", "e", "se", "sw", "se", "s", "w", 
               "nw", "ne", "e", "w", "nw", "w", "w", "w", "w", 
               "nw", "sw", "w", "n", "nw", "nw", "sw", "w", "w", 
               "sw", "nw", "nw", "nw", "sw", "se", "se", "se", 
               "w", "se", "w", "ne", "nw", "nw", "sw", 
               "se", "e", "e", "ne", "ne", "e", "e", "ne", "se", "se", 
               "s", "s", "s", "s", "s", "se", "sw", "sw",},
   ayhesa = {"s", "sw", "s", "e", "e", "d", "in", "sw", "s", "n", "ne", "nw", "n", "s", "e", "n", "s", "n", "s", "d", "se", "n", 
"s", "s", "n", "in", "w", "e", "out", "e", "ne", "sw", "se", "nw", "e", "e", "e", "e", "ne", "ne", 
"se", "se", "sw", "sw", "nw", "ne", "w", "w", "w", "w", "w", "w", "s", "d", "u", "n", "nw", "u", "n",
 "s", "w", "n", "s", "se", "sw", "s", "n", "ne", "out", "u", "w", "w", "n", "ne", "n", },
  xoral     = {},
}

bashSystemState = {
  state = "needCheck",
  moving = false,
  checkWH = true,
  needPickup = false,
  party = {atcp.name}
}

function handleBeginBashing(i,p)
  local area = i:match(p)
  if not mobTable[area] then 
    ACSEcho("Area " .. area .. " is not a valid bashing zone.") 
    ACSEcho("Valid Areas:")
    for k,v in pairs(mobTable) do
      if k ~= "extras" then ACSEcho(k) end
    end
    show_prompt()
    return 
  end
  beginBashing(area)
end

triggers.newBash = {
  {pattern = "You have slain .*", handler = function(p) mobKilled() end, disabled = true},

  {pattern = "^You have recovered equilibrium.", 
    handler = function(p) onPrompt(function() checkForState() end) end, disabled = true},

  {pattern = "You have recovered balance on your left arm.", 
    handler = function(p) onPrompt(function() checkForState() end) end, disabled = true},

  {pattern = "You have recovered balance on your right arm.", 
    handler = function(p) onPrompt(function() checkForState() end) end, disabled = true},

  {pattern = "You have recovered balance on all limbs.", 
    handler = function(p) onPrompt(function() checkForState() end) end, disabled = true},

  {pattern = "^You have cured (.+)%.$", 
    handler = function(p) onPrompt(function() checkForState() end) end, disabled = true},

  {pattern = "You stand up and stretch your arms out wide.", 
    handler = function(p) onPrompt(function() checkForState() end) end, disabled = true},

  {pattern = "You cannot see that being here.",
    handler = function(p) onPrompt(function() checkIH() end) end, disabled = true},

  {pattern = "I do not recognize anything called that here.", 
    handler = function(p) onPrompt(function() checkIH() end) end, disabled = true},

  {pattern = "Ahh, I am truly sorry, but I do not see anyone by that name here.", 
    handler = function(p) onPrompt(function() checkIH() end) end, disabled = true},

  {pattern = "Nothing can be seen here by that name.", 
    handler = function(p) onPrompt(function() checkIH() end) end, disabled = true},
  {pattern = "You detect nothing here by that name.", 
    handler = function(p) onPrompt(function() checkIH() end) end, disabled = true},
    
}

function beginBashing(area)
  setupBashQueues(area)
  turnOnBash()
  checkForState()
end

function turnOnBash()
  enableTriggers("newBash")
  bashSystemState.state = "needCheck"
  ACSEcho("Bashing on!")
end

function turnOffBash()
  disableTriggers("newBash")
end

function setupBashQueues(area)
  setMoveQueue(area)
  selectMobTable(area)
end

function checkForState()
  debug("checkForState()")
  if allbalance and equilibrium and not hasAffliction("paralysis") and not hasAffliction("left_leg_broken") and not hasAffliction("right_leg_broken")
    and not hasAffliction("left_arm_broken") and not hasAffliction("right_arm_broken") and not prone and not stunned and not isEntangled() then

    debug("Able to do stuff!")

    if bashSystemState.needPickup then
      bashSystemState.needPickup = false
      send("get corpse")
      send("get gold")
    end

    for i,v in ipairs(extraPickups) do
      send("get " .. v)
    end
    extraPickups= {}

    if bashSystemState.state == "needCheck" then
      checkIH()
    elseif bashSystemState.state == "needAttack" then
      if health < lowHealthThreshold and class.onLowHealth then
        class.onLowHealth()
      else
        performBashAttack()
      end
    elseif bashSystemState.state == "needMove" then
      add_timer(1, function() moveNextFromQueue() end)
    end
  end
end

---------------------
--  MOVE QUEUEING  --
---------------------
function setMoveQueue(queue)
  moveQueue = {}
  if moveQueues[queue] then debug("Setting move queue to " .. queue) queue = moveQueues[queue] end
  for i,v in ipairs(queue) do addToMoveQueue(v) end
end

function addToMoveQueue(dir)
  table.insert(moveQueue, dir)
end

function moveNextFromQueue()
  if #moveQueue == 0 then
    ACSEcho(C.R .. "No moves in queue!")
    ACSEcho(C.R .. "Bashing done!")
    turnOffBash()
  else
    if not bashSystemState.moving and not prone and not hasAffliction("paralysis") 
      and not stunned and not unconscious and not asleep then
      dir = moveQueue[1]
      debug("Sending direction: " .. dir)
      if class.onBeforeMove then class.onBeforeMove() end
      send(dir)
      bashSystemState.moving = true
      add_timer(1, function() bashSystemState.moving = false end)
      tempTrigger("You see exits leading .*", function() afterMove() end)
      tempTrigger("You see a single exit .*", function() afterMove() end)
      tempTrigger("A blizzard rages around you, blurring the world into a slate of uniform white.", function() afterMove() end)
    end
  end
end

function afterMove()
  removeTemp("You see exits leading .*")
  removeTemp("You see a single exit .*")
  removeTemp("A blizzard rages around you, blurring the world into a slate of uniform white.")
  table.remove(moveQueue, 1)

  if bashSystemState.checkWH then
    checkWhoHere()
  else
    checkIH()
  end
end


-------------------------
--  WHO HERE CHECKING  --
-------------------------
function checkWhoHere()
  bashSystemState.state = "checkingWH"
  debug("checkWhoHere()")
  send("who here")
  tempTrigger("^You see the following people here:$", function() whoHereChecked() end)
end

function whoHereChecked()
  bashSystemState.state = "checkedWH"
  tempTrigger("^(%w+)", function() examineWhoHere() end)
end

function examineWhoHere()
  local people = {}
  local person, extra = mb.line:match("^(%w+)(.*)$")
  if person then table.insert(people, person) end

  while extra:find(", %w+") do
    person, extra = extra:match(", (%w+)(.*)")
    table.insert(people, person)
  end

  local isParty = true
  for i,v in pairs(people) do
    for j,w in pairs(bashSystemState.party) do
      if v ~= w then isParty = false end
    end
  end

  debug("isParty: " .. tostring(isParty))
  if isParty then 
    checkIH()
  else
    bashSystemState.state = "needMove"
    add_timer(1, function() checkForState() end)
  end
end

-------------------
--  IH CHECKING  --
-------------------
function checkIH()
  debug("checkInfoHere()")
  targetList = {}
  send("ih")
  tempTrigger("You can see the following %d+ objects:", function() handleIHSuccess() end)
  tempTrigger("There is nothing here.", function() removeIHStartTriggers() end)
end 

function handleIHSuccess()
  removeIHStartTriggers()

  targetList = {}
  extraPickups = {}
  triggers.mobTarget = {}
  triggers.extraPickups = {}
  for i,v in ipairs(currentTargetList) do
    local trigger = {pattern = "^\"(.+)\"%s+" .. v, handler = function(p) IHTargetHandler(p) end}
    table.insert(triggers.mobTarget, trigger)
  end

  for i,v in ipairs(mobTable.extras) do
    local trigger = {pattern = "^\"(.+)\"%s+" .. v, handler = function(p) extrasHandler(p) end}
    table.insert(triggers.extraPickups, trigger)
  end
end

function mobKilled()
  lastTarget = selectedTarget
  selectedTarget = ""
  bashSystemState.needPickup = true
  bashSystemState.state = "needCheck"
end

function removeIHStartTriggers()
  removeTemp("You can see the following %d+ objects:")
  removeTemp("There is nothing here.")
  addTemporaryPromptTrigger(function() removeMobTableTriggers() end)
end

function removeMobTableTriggers()
  triggers.mobTarget = {}
  triggers.extraPickups = {}

  if #targetList > 0 then
    selectedTarget = targetList[1]
    debug("selectedTarget: " .. selectedTarget)
    bashSystemState.state = "needAttack"
  else
    debug("No target found... moving...")
    bashSystemState.state = "needMove"
  end

  checkForState()
end

function IHTargetHandler(p)
  local mob = mb.line:match(p)
  table.insert(targetList, mob)
end

function extrasHandler(p)
  local extra = mb.line:match(p)
  table.insert(extraPickups, extra)
end

--------------------------
--  MOB TABLE SELECTION --
--------------------------
function selectMobTable(t)
  if mobTable[t] then
    currentTargetList = mobTable[t]
    debug("Switched target list to " .. t)
  elseif t then
    debug("Switched target list")
    currentTargetList = t
  end
end

class = {}
if isClass("syssin") then
  class.bashAttack = function()
    --send("wield whip")
    --send("wield shield")
    send("secrete camus")
    send("bite " .. selectedTarget)
    --send("garrote " .. selectedTarget)
  end
elseif isClass("carnifex") then
  class.bashAttack = function()
    send("wield bardiche")
    send("pole spinslash " .. selectedTarget)
  end
  class.onBeforeMove = function()
    send("order hounds follow me")
  end
  class.onLowHealth = function()
    send("soul consume for health")
  end
elseif isClass("teradrim") then
  class.bashAttack = function()
    doWield(crozier, tower)
    send("sand shred " .. selectedTarget)
  end
elseif isClass("atabahi") then
  class.bashAttack = function()
    --doWield(crozier, tower)
    send("claw " .. selectedTarget)
    send("claw " .. selectedTarget)
  end
end



function performBashAttack()
  --removeBalanceTemps()

  if not class.bashAttack then
    ACSEcho("No bash attack defined!")
  else 
    class.bashAttack()
  end
end









---------------------------
--  Misc other functions --
---------------------------
function mihail()
  for i=1,50 do send("give dwarf to mihail") end
  for i=1,30 do send("give pickaxe to mihail") end
end

function hecree()
  for i=1,30 do send("give githani to hecree") end
end