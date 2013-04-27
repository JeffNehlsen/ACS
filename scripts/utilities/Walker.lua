
Walker = {
    queue = {},
    moving = false,
    onAfterMoveCallback = nil,
    setupFinishedCallback = nil,
    walkerFinishedCallback = nil,
    onBeforeMoveCallback = nil,
}

function Walker:startWalker(data)
    if not (data and type(data) == "table")
        or not (data.queue and type(data.queue) == "table")
        or not (data.onAfterMoveCallback and type(data.onAfterMoveCallback) == "function")
        or not (data.setupFinishedCallback and type(data.setupFinishedCallback) == "function")
        or not (data.walkerFinishedCallback and type(data.walkerFinishedCallback) == "function")
        then
        ACSEcho("Walker: Improper data input.")
    end

    self[queue] = {}
    self[onAfterMoveCallback] = data.onAfterMoveCallback
    self[setupFinishedCallback] = data.setupFinishedCallback
    self[walkerFinishedCallback] = data.walkerFinishedCallback
    for _, dir in ipairs(data.queue) do
        self[queue]:insert(dir)
    end

    self[setupFinishedCallback]()
end

function Walker:walk()
    if #self[queue] == 0 then
        ACSEcho(C.R .. "No moves in queue!")
        self.walkerFinishedCallback()
        return
    end

    if not self.moving then
        tempTrigger("You see exits leading .*", function() afterMove() end)
        tempTrigger("You see a single exit .*", function() afterMove() end)
        tempTrigger("A blizzard rages around you, blurring the world into a slate of uniform white.", function() afterMove() end)
        self.moving = true
    end

    local dir = moveQueue[1]
    send("dir")
end

function Walker:afterMove()
    self.moving = false
    removeTemp("You see exits leading .*")
    removeTemp("You see a single exit .*")
    removeTemp("A blizzard rages around you, blurring the world into a slate of uniform white.")
    table.remove(moveQueue, 1)
    self.onAfterMoveCallback()
end





-- function addToMoveQueue(dir)
--   table.insert(moveQueue, dir)
-- end

-- function moveNextFromQueue()
--   if #moveQueue == 0 then
--     ACSEcho(C.R .. "No moves in queue!")
--     ACSEcho(C.R .. "Bashing done!")
--     turnOffBash()
--   else
--     if not bashSystemState.moving and not prone and not hasAffliction("paralysis") 
--       and not stunned and not unconscious and not asleep then
--       dir = moveQueue[1]
--       if class.onBeforeMove then class.onBeforeMove() end
--       send(dir)
--       bashSystemState.moving = true
--       add_timer(1, function() bashSystemState.moving = false end)
--       tempTrigger("You see exits leading .*", function() afterMove() end)
--       tempTrigger("You see a single exit .*", function() afterMove() end)
--       tempTrigger("A blizzard rages around you, blurring the world into a slate of uniform white.", function() afterMove() end)
--     end
--   end
-- end

-- function afterMove()
--   removeTemp("You see exits leading .*")
--   removeTemp("You see a single exit .*")
--   removeTemp("A blizzard rages around you, blurring the world into a slate of uniform white.")
--   table.remove(moveQueue, 1)

--   if bashSystemState.checkWH then
--     checkWhoHere()
--   else
--     checkIH()
--   end
-- end

