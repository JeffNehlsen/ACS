
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