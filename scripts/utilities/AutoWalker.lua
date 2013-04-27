
Mover = {
	queue = {}
}
function mover:setQueue(queue)
  self[queue] = {}
  for _, dir in ipairs(queue) do addToMoveQueue(v) end
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

