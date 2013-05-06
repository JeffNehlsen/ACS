echo("New bashing system loaded")

-- 12885 = khauskin entrance
-- 15067 = mamashi
-- 12159 = lich gardens entrance

-- simpleBashing = false
-- triggers.simpleBashing = {
--     {pattern = {
--         "^You have recovered equilibrium.",
--         "You have recovered balance on your left arm.",
--         "You have recovered balance on your right arm.",
--         "You have recovered balance on all limbs.",
--         "You stand up and stretch your arms out wide.",
--         "^You have cured (.+)%.$"
--     }, handler = function(p) onPrompt(function() if simpleBashing then class.bashAttack() end end) end},
-- }
-- aliases.simpleBashing = {
--     {pattern = "^autobash$", handler = function()
--         simpleBashing = not simpleBashing
--         ACSEcho("Simple Bashing " .. tostring(simpleBashing))
--     end},
--     {pattern = "^bash$", handler = function()
--         class.bashAttack()
--     end}
-- }


-- --- Area 404: Xaanhal ------------ v36740 ---                                
--      [^]
--       | 
--      [ ] [ ]-[ ]         [ ]
--       | /       \       /   \
--      [ ]         [ ]-[ ]     [ ]
--         \           /         | 
--          [ ]-[ ]-[ ]         [ ]-[ ]
--           | /       \       /       \
--          [ ]         [+]-[ ]         [ ]
--             \       /       \         | 
--              [ ]-[ ]         [ ]-[ ] [ ]
--               |     \       /       \ | 
--              [ ]     [ ]-[ ]         [ ]
--               |       |   |         /
--              [ ]     [ ]-[ ]     [ ]
--                 \   /       \   /   \
--                  [ ]         [ ]     [ ]
--                                         \
--                                          [ ]-[ ]-[_]
                                             
-- ------------------ -3:0:-2 ------------------


-- --- Area 404: Xaanhal ------------ v36781 ---                                             
--                                      [^]
--                                     /
--                      [ ]-[ ]-[ ]-[ ]
--                     /       \   /   \
--                  [ ]         [ ]     [ ]
--                 /           /   \       \
--              [ ]         [ ]     [ ]     [ ]
--             /   \         |         \       \
--          [ ]     [ ]-[+]-[ ]         [ ]     [ ]
--         /       /         |         /   \   /
--      [ ]     [ ]         [ ]     [ ]     [ ]
--       |       |         /   \     |     /
--      [ ]-[ ]-[ ]     [ ]     [ ]-[ ]-[ ]
--         \ |   |     /
--          [ ]-[ ]-[ ]
                                             
                                             
                                             
                                             


Bashing = {}
Bashing.state = ""
Bashing.extraPickups = {}
Bashing.states = {
    NEED_CHECK = "NEED_CHECK",
    NEED_ATTACK = "NEED_ATTACK",
    NEED_MOVE = "NEED_MOVE",
    WHO_HERE = "WHO_HERE",
    INFO_HERE = "INFO_HERE",
}
Bashing.party = {atcp.name}
Bashing.triggers = {
    {pattern = "You have slain .*", handler = function(p) Bashing:mobKilled() end},

    {pattern = {
        "^You have recovered equilibrium.",
        "You have recovered balance on your left arm.",
        "You have recovered balance on your right arm.",
        "You have recovered balance on all limbs.",
        "You stand up and stretch your arms out wide.",
        "^You have cured (.+)%.$"
    }, handler = function(p) onPrompt(function() Bashing:checkForState() end) end},

    {pattern = {
        "You cannot see that being here.",
        "I do not recognize anything called that here.",
        "Ahh, I am truly sorry, but I do not see anyone by that name here.",
        "Nothing can be seen here by that name.",
        "You detect nothing here by that name."
    }, handler = function(p) onPrompt(function() Bashing:checkIH() end) end},
}

Bashing.aliases = {
    {pattern = "^beginbashing (%a+)$", handler = function(i,p) 
        local area = i:match(p) 
        reloadBashing:begin(area) 
    end},
    -- {pattern = "^stopbashing$", handler = function() moveQueue = {} ACSEcho("Move Queue is empty.  Feel free to move around!") end},
    -- {pattern = "^rlbashing$", handler = function() dofile("scripts/bashing/NewBashing.lua") show_prompt() end},
}

Bashing.loop = { "xaanhal", "ayhesa", "lich", "mamashi"} --, "khauskin", "mor" }

function Bashing:begin(area)
    if not Bashing.areas[area] then
        ACSEcho("Area not found. Try again!")
        ACSEcho("Valid Areas:")
        for k, _ in pairs(Bashing.areas) do
            ACSEcho(k)
        end
        show_prompt()
        return 
    end

    Bashing.currentArea = area

    Walker:start({
        queue = Bashing.areas[area].path,
        onAfterMoveCallback = function()
            Bashing:afterMove()
        end,
        setupFinishedCallback = function()
            Bashing:ready()
        end,
        walkerFinishedCallback = function()
            Bashing:walkingFinished()
        end
    })
    Bashing:setTargets(Bashing.areas[area].mobs)
    enableTriggers("Bashing")
end

function Bashing:setTargets(targets)
    Bashing.currentTargets = {}
    for _, target in ipairs(targets) do
        table.insert(Bashing.currentTargets, target)
    end
end

function Bashing:ready()
    debug:print("Bashing", "ready()")
    Bashing.state = Bashing.states.NEED_CHECK
    Bashing:checkForState()
end

function Bashing:afterMove()
    debug:print("Bashing", "afterMove()")
    Bashing:checkWhoHere()
end

function Bashing:walkingFinished()
    ACSEcho("Bashing finished!")
    -- disableTriggers("Bashing")
    Bashing:checkForNextArea()
end

function Bashing:checkForNextArea()
    local index = getTableIndex(Bashing.loop, Bashing.currentArea) + 1
    local nextArea
    if not index or not Bashing.loop[index] then
        index = 1
    end
    nextArea = Bashing.areas[Bashing.loop[index]]
    Bashing:gotoNextArea(Bashing.loop[index])
end

function Bashing:gotoNextArea(area)
    local vnum = Bashing.areas[area].vnum
    send("path find " .. vnum)
    send("path go")
    tempTrigger("You have reached your destination.", function()
        Bashing:begin(area)
        Bashing:cleanupMoveTriggers()
    end)
    tempTrigger("You are already there.", function()
        Bashing:begin(area)
        Bashing:cleanupMoveTriggers()
    end)
end

function Bashing:cleanupMoveTriggers()
    removeTemp("You are already there.")
    removeTemp("You have reached your destination.")
end

-------------------------
--  WHO HERE CHECKING  --
-------------------------
function Bashing:checkWhoHere()
    debug:print("Bashing", "checkWhoHere()")
  Bashing.state = Bashing.states.WHO_HERE
  send("who here")
  tempTrigger("^You see the following people here:$", function() Bashing:whoHereChecked() end)
end

function Bashing:whoHereChecked()
    debug:print("Bashing", "whoHereChecked()")
  tempTrigger("^(%w+)", function() Bashing:examineWhoHere() end)
end

function Bashing:examineWhoHere()
    debug:print("Bashing", "examineWhoHere()")
  local people = {}
  local person, extra = mb.line:match("^(%w+)(.*)$")
  if person then table.insert(people, person) end

  while extra:find(", %w+") do
    person, extra = extra:match(", (%w+)(.*)")
    table.insert(people, person)
  end

  local isParty = true
  for i,v in pairs(people) do
    for j,w in pairs(Bashing.party) do
      if v ~= w then isParty = false end
    end
  end

  if isParty then 
    Bashing:checkIH()
  else
    Bashing.state = Bashing.states.NEED_MOVE
    add_timer(.5, function() Bashing:checkForState() end)
  end
end



-------------------
--  IH CHECKING  --
-------------------
function Bashing:checkIH()
    debug:print("Bashing", "checkIH()")
  Bashing.targetList = {}
  send("ih")
  tempTrigger("You can see the following %d+ objects:", function() Bashing:handleIHSuccess() end)
  tempTrigger("There is nothing here.", function() Bashing:removeIHStartTriggers() end)
end 

function Bashing:handleIHSuccess()
    debug:print("Bashing", "handleIHSuccess()")
  Bashing:removeIHStartTriggers()

  Bashing.targetList = {}
  Bashing.extraPickups = {}

  triggers.Bashing_Mobs = {}
  triggers.Bashing_Pickups = {}

  for _, target in ipairs(Bashing.currentTargets) do
    local trigger = {pattern = "^\"(.+)\"%s+" .. target, handler = function(p) Bashing:IHTargetHandler(p) end}
    table.insert(triggers.Bashing_Mobs, trigger)
  end

  for _, extra in ipairs(Bashing.extraStuff) do
    local trigger = {pattern = "^\"(.+)\"%s+" .. extra, handler = function(p) Bashing:extrasHandler(p) end}
    table.insert(triggers.Bashing_Pickups, trigger)
  end
end

function Bashing:mobKilled()
    debug:print("Bashing", "mobKilled()")
  Bashing.lastTarget = Bashing.selectedTarget
  Bashing.selectedTarget = ""
  Bashing.needPickup = true
  Bashing.state = Bashing.states.NEED_CHECK
end

function Bashing:removeIHStartTriggers()
    debug:print("Bashing", "removeIHStartTriggers()")
    removeTemp("You can see the following %d+ objects:")
    removeTemp("There is nothing here.")
    addTemporaryPromptTrigger(function() 
        Bashing:removeMobTableTriggers() 
    end)
end

function Bashing:removeMobTableTriggers()
    debug:print("Bashing", "removeMobTableTriggers()")
  triggers.Bashing_Mobs = {}
  triggers.Bashing_Pickups = {}

  if #Bashing.targetList > 0 then
    selectedTarget = Bashing.targetList[1]
    debug:print("Bashing", "Setting state to Bashing.states.NEED_ATTACK")
    Bashing.state = Bashing.states.NEED_ATTACK
  else
    debug:print("Bashing", "Setting state to Bashing.states.NEED_MOVE")
    Bashing.state = Bashing.states.NEED_MOVE
  end

  Bashing:checkForState()
end

function Bashing:IHTargetHandler(p)
    debug:print("Bashing", "IHTargetHandler: " .. p)
  local mob = mb.line:match(p)
  table.insert(Bashing.targetList, mob)
end

function Bashing:extrasHandler(p)
  local extra = mb.line:match(p)
  table.insert(Bashing.extraPickups, extra)
end


-----------------
-- CHECK STATE --
-----------------
function Bashing:checkForState()
    -- debug:print("Bashing", "checkForState: " .. Bashing.state)
  if balances:check(baleq) and not hasAffliction("paralysis") and not hasAffliction("left_leg_broken") and not hasAffliction("right_leg_broken")
    and not hasAffliction("left_arm_broken") and not hasAffliction("right_arm_broken") and not prone and not stunned and not isEntangled() then

    if Bashing.needPickup then
      Bashing.needPickup = false
      send("get corpse")
      send("get gold")
    end

    for _, extra in ipairs(Bashing.extraPickups) do
      send("get " .. extra)
    end
    Bashing.extraPickups = {}

    if Bashing.state == Bashing.states.NEED_CHECK then
        debug:print("Bashing", "NEED_CHECK")
      Bashing:checkWhoHere()
    elseif Bashing.state == Bashing.states.NEED_ATTACK then
        debug:print("Bashing", "NEED_ATTACK")
        Bashing:performBashAttack()
    elseif Bashing.state == Bashing.states.NEED_MOVE then
        debug:print("Bashing", "NEED_MOVE")
      add_timer(.5, function() Walker:walk() end)
    end
  end
end


function Bashing:performBashAttack()
  if not class.bashAttack then
    ACSEcho("No bash attack defined!")
  else 
    class.bashAttack()
  end
end


Bashing.areas = {
    xaanhal = {
        vnum = "36688",
        path = {
            "d", "s", "s", "ne", "e", "se", "e", "ne", "se", "s", 
            "e", "se", "s", "s", "sw", "sw", "nw", "w", "sw", "nw", 
            "n", "n", "nw", "n", "nw", "se", "e", "sw", "ne", "e", 
            "se", "e", "ne", "sw", "se", "e", "w", "sw", "w", "nw", 
            "ne", "e", "se", "e", "se", "sw", "se", "se", "e", "e", 
            "d", "sw", "w", "w", "w", "sw", "sw", "sw", "sw", "s", 
            "se", "n", "e", "s", "e", "ne", "ne", "n", "w", "w", 
            "sw", "ne", "e", "e", "n", "ne", "se", "se", "sw", "s",
            "w", "nw", "se", "e", "e", "ne", "ne", "nw", "nw", "nw"
        },
        mobs = {
            "a cautious Xorani guard.",
            "a merciless Xorani warrior.",
            "a wiry Xorani guard.",
            "a willowy nest guardian.",
            "a suspicious Xorani patrol.",
            "an arrogant Xorani master at arms.",
        }
    },
    mamashi = {
        vnum = "20855",
        mobs = {
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
        path = {
            "d", "e", "n", "se", "s", "w", "n", "w", "n", "w", 
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
            "w", "n", "n", "w",
        },
    },
    khauskin = {
        vnum = "25408",
        mobs = {
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
        path = {
            "s", "w", "e", "e", "w", "s", "w", "w", "e", "e", 
            "s", "sw", "w", "e", "ne", "n", "n", "n", "s", "s", 
            "s", "s", "d", "s", "e", "d", "n", "n", "n", "n", "nw", 
            "nw", "w", "sw", "s", "s", "e", "e", "e", "w", "s", 
            "sw", "s", "s", "se", "s", "n", "ne", "n", "n", "nw", 
            "s", "s", "s", "n", "n", "n", "n", "w", "w", "sw"
        },
    },
    mor = {
        vnum = "19344",
        mobs = {
            "a ravenous, shadowy ghast.",
            "a robed, skeletal lich.",
            "a stench%-ridden ghoul.",
            "a vampiric warrior.",
            "a vampiric sentry.",
            "Aclyr, the vampiric general.",
        },
        path = {
            "d", "n", "w", "nw", "w", "sw", "n", "nw", "sw", 
            "s", "e", "e", "sw", "w", "n", "w", "sw", "e", 
            "e", "n", "e", "e", "ne", "ne", "n", "e", "se", 
            "se", "sw", "w", "nw", "w", "ne", "n", "n", "n", 
            "se", "nw", "w", "nw", "se", "sw", "ne", "e", 
            "n", "n", "e", "se", "nw", "w", "d", "e", "e", 
            "nw", "nw", "nw", "n", "s", "s", "w", 
            "w", "s", "e", "w", "se", "e", "e", "e", "e", 
            "w", "w", 'u', 's', 's', 's', 's', 's', 'sw', 'e', 'se', 'e', 's', 'u'
        },
    },
    lich = {
        vnum = "22868",
        mobs = {
            "a monstrous Infernal guard.",
            "a mindless experiment.",
            "a student of the lich.",
            "a dark Cabalist scholar.",
            "a guardian wraith.",
            "a tattered Bahkatu experiment.",
            "a studious lich scientist.",
            "a commanding lich scientist.",
        },
        path = {
            "ne", "ne", "nw", "w", "nw", "n", "ne", "e", "e", 
            "se", "s", "sw", "w", "n", "n", "n", "n", "e", "ne", 
            "se", "e", "n", "s", "e", "n", "s", "s", "n", "e", 
            "e", "ne", "ne", "e", "se", "sw", "se", "s", "w", 
            "nw", "ne", "e", "w", "nw", "w", "w", "w", "w", 
            "nw", "sw", "w", "n", "nw", "nw", "sw", "w", "w", 
            "sw", "nw", "nw", "nw", "sw", "se", "se", "se", 
            "w", "se", "w", "ne", "nw", "nw", "sw", 
            "se", "e", "e", "ne", "ne", "e", "e", "ne", "se", "se", 
            "s", "s", "s", "s", "s", "se", "sw", "sw",
        },
    },
    ayhesa = {
        vnum = "19987",
        mobs = {
            "a Spellshaper Master.",
            "a Spellshaper Adept.",
            "a Spellshaper Archon.",
        },
        path = {
            "s", "sw", "s", "e", "e", "d", "in", "sw", "s", "n", "ne", 
            "nw", "n", "s", "e", "n", "s", "n", "s", "d", "se", "n", 
            "s", "s", "n", "in", "w", "e", "out", "e", "ne", "sw", "se", 
            "nw", "e", "e", "e", "e", "ne", "ne", "se", "se", "sw", "sw", 
            "nw", "ne", "w", "w", "w", "w", "w", "w", "s", "d", "u", "n", 
            "nw", "u", "n", "s", "w", "n", "s", "se", "sw", "s", "n", 
            "ne", "out", "u", "w", "w", "n", "ne", "n"
        },
    },
}

Bashing.extraStuff = {
    "a durable pickaxe.",
    "a beaten Dwarven corpse.",
    "a worker's corpse.",
    "a vivisected Troll corpse.",
}


function Bashing:setup()
  ACS:addModule(Bashing, "Bashing")
end
Bashing:setup()


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