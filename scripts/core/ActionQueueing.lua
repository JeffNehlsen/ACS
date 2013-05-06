echo("Action Queuer loaded")

aliases.queue = {
  {pattern = "^reseta$", handler = function(i,p) resetActions() end},
  {pattern = "^adda (%w+) (.*)", handler = function(i,p) addNextActionHandler(i,p) end},
}

freeActions = {}
balancedActions = {}
function resetActions()
  freeActions = {}
  balancedActions = {}
end

function addNextActionHandler(input, pattern)
  needBal, action = input:match(pattern)
  echo("CAUGHT: " .. needBal .. " " .. action)
  addAction(action)
end

function addAction(action, needsBalance)
  if action ~= nil then
    if needsBalance then
      table.insert(balancedActions, action)
    else
      table.insert(freeActions, action)
    end
  end
end

function doFreeActions()
  for i in ipairs(freeActions) do
    performAction(freeActions[i])
  end
  freeActions = {}
end

function doBalancedAction()
  if balancedActions[1] ~= nil then
    action = balancedActions[1]
    table.remove(balancedActions, 1)
    performAction(action)
  end
end

function doActions()
  if #freeActions > 0 then
    doFreeActions()
  end
  
  if #balancedActions > 0 and allbalance and equilibrium and not prompt.prone and not attemptingAction then
    attemptingAction = true
    add_timer(2, function() attemptingAction = false end)
    doBalancedAction()
  end
end

function performAction(action)
  loadstring(action)()
end






----------------
-- NEW SYSTEM --
----------------
actions = {queue = {}}
function actions:add(action, requires, takes)
  if not action then ACSEcho("No action given in actions:add") return end
  if not requires then requires = {} end
  if not takes then takes = {} end

  table.insert(actions.queue, {action = action, requires = requires, takes = takes})
end

function actions:check()
  local stillNeeded = {}
  table.sort(actions.queue, function(a,b)
    local aTakesBal = false
    local bTakesBal = false
    for _,v in ipairs(a.takes) do
      if v == "balance" or v == "equilibrium" then aTakesBal = true break end
    end
    for _,v in ipairs(b.takes) do
      if v == "balance" or v == "equilibrium" then bTakesBal = true break end
    end
    if aTakesBal then return false end
    if bTakesBal then return true end
    return false
  end)

  for _, action in ipairs(self.queue) do
    if balances:check(action.requires) then
      balances:take(action.takes)
      if type(action.action) == "string" then
        loadstring(action.action)()
      else
        action.action()
      end
    else
      table.insert(stillNeeded, action)
    end
  end
  actions.queue = stillNeeded
end