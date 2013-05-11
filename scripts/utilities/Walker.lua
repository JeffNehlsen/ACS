
Walker = {}

function Walker:start(data)
    if not (data and type(data) == "table")
        or not (data.queue and type(data.queue) == "table")
        or not (data.onAfterMoveCallback and type(data.onAfterMoveCallback) == "function")
        or not (data.setupFinishedCallback and type(data.setupFinishedCallback) == "function")
        or not (data.walkerFinishedCallback and type(data.walkerFinishedCallback) == "function")
        then
        ACSEcho("Walker: Improper data input.")
    end

    Walker.queue = {}
    Walker.onAfterMoveCallback = data.onAfterMoveCallback
    Walker.setupFinishedCallback = data.setupFinishedCallback
    Walker.walkerFinishedCallback = data.walkerFinishedCallback
    Walker.onBeforeMoveCallback = data.onBeforeMoveCallback or nil
    for _, dir in ipairs(data.queue) do
        table.insert(Walker.queue, dir)
    end

    Walker.setupFinishedCallback()
end

function Walker:walk()
    if #Walker.queue == 0 then
        ACSEcho(C.R .. "No moves in queue!")
        Walker.walkerFinishedCallback()
        return
    end

    if not Walker.moving then
        tempTrigger("You see exits leading .*", function() Walker:afterMove() end)
        tempTrigger("You see a single exit .*", function() Walker:afterMove() end)
        tempTrigger("A blizzard rages around you, blurring the world into a slate of uniform white.", function() Walker:afterMove() end)
        Walker.moving = true
    end

    send(Walker.queue[1])
end

function Walker:afterMove()
    Walker.moving = false
    removeTemp("You see exits leading .*")
    removeTemp("You see a single exit .*")
    removeTemp("A blizzard rages around you, blurring the world into a slate of uniform white.")
    table.remove(Walker.queue, 1)
    Walker.onAfterMoveCallback()
end

function Walker:kill()
    Walker.queue = {}
    ACSEcho("Walker queue cleared!")
end

function Walker:test()
    Walker:start({
        queue = {"w", "w", "sw", "ne", "e", "e"},
        onAfterMoveCallback = function()
            ACSEcho("Move completed!")
        end,
        setupFinishedCallback = function()
            ACSEcho("Setup completed")
        end,
        walkerFinishedCallback = function()
            ACSEcho("Walking completed!")
        end
    })
end