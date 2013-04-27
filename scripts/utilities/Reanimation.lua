echo("Reanimation system loaded")

aliases.reanimation = {
  {pattern = "^make (%d+) (%w+)$", handler = function(i,p) handleReanimationFillRequest(i,p) end},

  -- Dissecting
  {pattern = "^dodis$", handler = function(i,p) dissectAllCorpses() end},
  {pattern = "^slicereport$", handler = function(i,p) sliceReport() end},
  {pattern = "^recheckslices$", handler = function(i,p) recheckSlices() end},

  {pattern = "^slicepriority (%w+) (%d+)$", handler = function(i,p) slicePriorityHandler(i,p) end},
  {pattern = "^removepriority (%w+)$", handler = function(i,p) sliceRemovePriorityHandler(i,p) end},
}

triggers.reanimation = {
  {pattern = "^\"(.+)\"%s+the corpse of .*$", handler = function(p) corpseHandler(p) end, disabled = true},
  
  {pattern = "^You look over the corpse and...$", handler = function(p) autopsyHandler() end, disabled = true},
  {pattern = "^You detect a pair of viable (%w+) to extract.", handler = function(p) autopsyResultHandler(p) end, disabled = true},
  {pattern = "^You detect a viable (%w+) to extract.", handler = function(p) autopsyResultHandler(p) end, disabled = true},
  {pattern = "^You realise that the corpse has now been dissected too often to retrieve anything else.", 
    handler = function(p) corpseEmptyHandler() end, disabled = true},
  {pattern = "You cannot find any organs of worth in that.", 
    handler = function(p) corpseEmptyHandler() performDissect() end, disabled = true},
  {pattern = "^You are dismayed to find nothing to extract!$", 
    handler = function(p) corpseEmptyHandler() performDissect() end, disabled = true},
  {pattern = "^I don't see what you want to autopsy.", 
    handler = function(p) corpseEmptyHandler() end, disabled = true},
  {pattern = "Cutting open the corpse of .*, you begin to rummage around the innards to find an appropriate place to remove the (.*)%. Your sharp eye immediately sees a spot and you excise the lovely organ, slicing it into (%d+) pieces.", 
    handler = function(p) dissectedHandler(p) end, disabled = true},
}

dissection = {state = "needAutopsy"}

reanimation = {
  analeptic     = {type = "serum",    parts = {redink = 1, liver_slice = 3, ovary_slice = 3}},
  stimulant     = {type = "serum",    parts = {yellowink = 1, castorite_slice = 3, lung_slice = 3}},
  demulcent     = {type = "serum",    parts = {tumour_slice = 3}},
  nervine       = {type = "serum",    parts = {purpleink = 2, blueink = 2, bone_slice = 3}},
  euphoric      = {type = "serum",    parts = {yellowink = 1, greenink = 1, kidney_slice = 6}},
  refrigerative = {type = "serum",    parts = {yellowink = 1, stomach_slice = 3}},
  carminative   = {type = "serum",    parts = {redink = 1, eyeball_slice = 3, tongue_slice = 3}},
  antispasmadic = {type = "serum",    parts = {eyeball_slice = 3, heart_slice = 3}},
  calmative     = {type = "serum",    parts = {redink = 1, bladder_slice = 3}},
  sudorific     = {type = "serum",    parts = {pineal_slice = 3}},

  oculi         = {type = "poultice", anoint = "eyeball",     inks = {blue = 2, red = 1}},
  jecis         = {type = "poultice", anoint = "liver",       inks = {gold = 1, green = 1, purple = 1}},
  pueri         = {type = "poultice", anoint = "ovary",       inks = {yellow = 1, green = 1, purple = 1}},
  orbis         = {type = "poultice", anoint = "testis",      inks = {blue = 2, green = 1}},
  fumeae        = {type = "poultice", anoint = "sulphurite",  inks = {red = 1, blue = 1, yellow = 1}},
}

function recheckSlices()
  for i=1,15 do send("inc all slice") end
  sliceReport()
end

prioritySlices = {}
function slicePriorityHandler(i,p)
  local slice, amt = i:match(p)
  if not slice or not amt then
    ACSEcho("Syntax: slicepriority SLICE NUMBER")
  else
    local alreadyInList = false
    for i,v in ipairs(prioritySlices) do
      if slice == v.slice then
        alreadyInList = true
        prioritySlices[i].priority = amt
        ACSEcho("Reset priority of " .. slice .. " to " .. amt)
      end
    end

    if not alreadyInList then
      local newPri = {priority = amt}
      newPri.slice = slice
      table.insert(prioritySlices, newPri)
      ACSEcho("Set priority of " .. slice .. " to " .. amt)
    end
  end
end

function sliceRemovePriorityHandler(i,p)
  local slice = i:match(p)
  if not slice then
    ACSEcho("Syntax: removepriority SLICE")
  else
    for i,v in ipairs(prioritySlices) do
      if slice == v then 
        table.remove(prioritySlices, i) 
        break 
      end
    end
  end
end

function handleReanimationFillRequest(i,p)
  num, recipe = i:match(p)
  if reanimation[recipe].type == "serum" then
    reanimationFill(num, recipe)
  elseif reanimation[recipe].type == "poultice" then
    poulticeFill(num, recipe)
  end
end

function poulticeFill(num, recipe)
  local anoint = reanimation[recipe].anoint
  local inks = reanimation[recipe].inks

  send("outc " .. num .. " " .. anoint)
  for k,v in pairs(inks) do
    local amt = v * num
    send("outc " .. amt .. " " .. k .. "ink")
    for i = 1,v do 
      local anointCommand = "anoint " .. num .. " " .. anoint .. " with " .. k
      actions:add(function() send(anointCommand) end, baleq, {"balance"})
    end
  end
  local prepCommand = "prepare " .. num .. " " .. recipe .. " poultice"
  actions:add(function() send(prepCommand) end, baleq, {"balance"})
end

function reanimationFill(num, recipe)
  numFilled = num
  for k,v in pairs(reanimation[recipe].parts) do
    i = v*num
    send("outc " .. i .. " " .. k)
    send("incauldron " .. i .. " " .. k)
  end
  send("ferment cauldron")
  --add_timer(4, function() for i=1,num do send("fill empty from cauldron") end end)
  addTemporaryTrigger("You have recovered balance on all limbs.", function() for i=1,numFilled do send("fill empty from cauldron") end end)
end

function doDisect()
  dissect("ovary")
  dissect("lung")
  dissect("bladder")
  dissect("kidney")

  dissect("heart")
  
  
  dissect("liver")
  dissect("eyeball")
  dissect("stomach")
  
  
  dissect("tongue")
  dissect("testis")
  dissect("spleen")
  send("drop corpse")
  send("get corpse")
end



corpses = {}
canDissect = {}
checkingCorpses = false
dissectedCount = 0

function dissectAllCorpses()
  enableTriggers("reanimation")
  dissectedCount = 0
  checkCorpses()
end

function checkCorpses()
  corpses = {}
  send("config pagelength 250")
  send("ii corpse")
  send("config pagelength 30")
  send("ic")

  checkingCorpses = true
  addTemporaryTrigger("You are holding:", function()
    checkingCorpses = true
    onPrompt(function()
      checkingCorpses = false
    end)
  end)

  addTemporaryTrigger("Glancing into the cache, you see:", function() 
    addTemporaryPromptTrigger(function() 
      replace(C.r .. "\nCorpse count: " .. #corpses .. C.x) 
      performDissect()
    end) 
  end)
  
end

function compareSlices(a,b)
  return a[2] < b[2]
end

function getSortedSlicesList()
  local slices = {}
  for k,v in pairs(curatives.cache) do
    if k:find("slice") then 
      local tmp = k:match("(%w+) slice")
      table.insert(slices, {tmp, v})
    end
  end

  table.sort(slices, compareSlices)
  return slices
end


function performDissect()
  if dissectedCount > 15 then
    recheckSlices()
    dissectedCount = 0
  end

  if dissection.state == "needAutopsy" then
    performAutopsy()
  elseif dissection.state == "canDissect" then
    local organ = selectDissection()
    local corpse = corpses[1]
    send("dissect " .. organ .. " from " .. corpse)
    dissectedCount = dissectedCount + 1
  end
end

function dissectedHandler(p)
  local organ, num = mb.line:match(p)
  
  if organ == "testes" then organ = "testis" end
  organ = organ:match("(%w+).*")
  if organ == "ovaries" then organ = "ovary" end
  for i,v in ipairs(canDissect) do
    if v == organ then 
      table.remove(canDissect, i) 
      break
    end
  end

  setACSLabel("Dissected " .. num .. " " .. organ .. " slices.")

  addTemporaryTrigger("You have recovered equilibrium", function()
    performDissect()
  end)
end

function corpseHandler(p)
  if checkingCorpses then
    local corpse = mb.line:match(p)
    table.insert(corpses, corpse)
    killLine()
  end
end

function performAutopsy()
  if #corpses > 0 then
    send("autopsy " .. corpses[1])
  else
    ACSEcho("No more corpses to dissect!")
    disableTriggers("reanimation")
  end
end

function autopsyHandler()
  canDissect = {}
  dissection.state = "canDissect"
  addTemporaryTrigger("You have recovered balance on all limbs.", function()
     performDissect()
  end)
end

function autopsyResultHandler(p)
  local organ = mb.line:match(p)
  if organ == "ovaries" then organ = "ovary" end
  if organ == "testes" then organ = "testis" end
  table.insert(canDissect, organ)
end

function corpseEmptyHandler()
  table.remove(corpses, 1)
  dissection.state = "needAutopsy"
  local str = "Corpse empty!"
  if corpses and #corpses > 0 then str = str .. " " .. #corpses .. " remaining!" end 
  setACSLabel(str)
end

function selectDissection()
  local toReturn

  if #prioritySlices > 0 then 
    table.sort(prioritySlices, function(a,b) return sortByPri(a,b) end)
    for i,v in ipairs(prioritySlices) do
      if canIDissect(v.slice) then toReturn = v.slice end
    end
  end

  if not toReturn then
    for i,v in ipairs(getSortedSlicesList()) do
      if canIDissect(v[1]) then 
        toReturn = v[1]
        break
      end
    end 
  end
  
  return toReturn
end

function canIDissect(organ)
  local can = false
  for i,v in ipairs(canDissect) do
    if v:find(organ) then 
      can = true 
      break
    end
  end
  return can
end

-- Quick function for easy visibility of slice counts.
function sliceReport()
  send("ic")
  addTemporaryTrigger("Glancing into the cache, you see:", function() 
    addTemporaryPromptTrigger(function() 
      echo("")
      for k,v in pairs(getSortedSlicesList()) do echo(v[1] .. ": " .. v[2]) end
      show_prompt()
    end) 
  end)
 end