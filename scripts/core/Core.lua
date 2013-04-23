echo("Core loaded")

acsLabel = C.r .. "[" .. C.R .. "ACS" .. C.r .. "]: " .. C.x

aliases = {}
triggers = {}
triggers.temporary = {}
triggersToAdd = {}
hooks = {}
extraLine = ""
class= {}
showDebug = showDebug or false
linenumber = 0
-- Skillranks to be used in the skills table and other comparisons.
skillranks = {unknown = 0, inept = 1, novice = 2, apprentice = 3, capable = 4, adept = 5, skilled = 6, gifted = 7, expert = 8, virtuoso = 9, fabled = 10, mythical = 11, transcendent = 12}

function printtable(input)
  for k,v in pairs(input) do
    if type(v) == "table" then
      printtable(v)
    else
      if type(v) == "string" then echo("--" .. tostring(k) .. " = " .. v) end
      if type(v) == "number" then echo("--" .. tostring(k) .. " = " .. tostring(v)) end
    end
  end
end


function alias_handler(input)
  for k,v in pairs(aliases) do
    for j in ipairs(v) do
      if input:match(v[j].pattern) then
        v[j].handler(input, v[j].pattern)
        return true
      end
    end
  end
end

function trigger_handler()
  addTemporaryTriggers()
  
  for tableName, triggersTable in pairs(triggers) do
    for i, trigger in ipairs(triggersTable) do
      if not trigger.disabled then
        if type(trigger.pattern) == "string" then
          if mb.line:find(trigger.pattern) then
            trigger.handler(trigger.pattern)
            if trigger and trigger.temporary then
              table.remove(triggersTable, i)
            end
          end
        elseif type(trigger.pattern) == "table" then
          for j, subPattern in ipairs(trigger.pattern) do
            if mb.line:find(subPattern) then
              trigger.handler(subPattern)
              if trigger.temporary then
                table.remove(triggersTable, i)
              end
              break
            end
          end
        end
      end
    end 
  end

  linenumber = linenumber + 1

  if (extraLine ~= "") then suffix(extraLine .. C.x) extraLine = "" end

  
end


mb.server_line = trigger_handler
mb.client_aliases = alias_handler
mb.server_prompt = prompt_handler

function setACSLabel(str)
  replace(acsLabel .. str .. C.x)
end

function ACSEcho(str)
  echo("\n" .. acsLabel .. str .. C.x)
  show_prompt()
end

function isTarget(p)
  return string.lower(p) == string.lower(target)
end

function hasSkill(skill)
  for i,v in ipairs(extraSkills) do
    if v == skill then return true end
  end
  
  return false
end

function isClass(class)
  return class == classType
end

function isVampire()
  return isClass("vampire") or isClass("bloodborn") or isClass("praenomin") or isClass("consanguine")
end

function isNecro()
  return isClass("infernal") or isClass("cabalist") or isClass("indorani")
end

function tableRemove(t, rem)
  for k,v in pairs(t) do
    if v.name == rem then
      table.remove(t, k)
    end
  end
end

function debug(message)
  if showDebug then
    echo(C.r .. "  [" .. C.R .. "DEBUG" .. C.r .. "]: " .. C.x .. message)
  end
end

function switchDebug()
  if showDebug then
    showDebug = false
  else
    showDebug = true
  end
  ACSEcho("Debug is now " .. tostring(showDebug))
  show_prompt()
end

function addTemporaryTrigger(p, h)
  local trig = {pattern = p, handler = h, temporary = true}
  table.insert(triggersToAdd, trig)
end

function addTemporaryTriggers()
  for i,v in ipairs(triggersToAdd) do
    table.insert(triggers.temporary, v)
  end
  triggersToAdd = {}
end

function tempTrigger(p, h)
  addTemporaryTrigger(p, h)
end

function addTemp(p, h)
  addTemporaryTrigger(p, h)
end

function removeTemp(p)
  local count = 0
  for i,v in pairs(triggers.temporary) do
    if p == v.pattern then
      table.remove(triggers.temporary, i)
    end
  end
end

temporaryPromptTriggers = {}
function addTemporaryPromptTrigger(h)
  table.insert(temporaryPromptTriggers, h)
end

function atPrompt(h)
  addTemporaryPromptTrigger(h)
end

function onPrompt(h)
  addTemporaryPromptTrigger(h)
end

function doTemporaryPromptTriggers()
  if #temporaryPromptTriggers > 0 then
    for i,v in ipairs(temporaryPromptTriggers) do
      v()
    end
    temporaryPromptTriggers = {}
  end
end

function switchTriggers(triggerTable, enable)
  for i,v in ipairs(triggerTable) do
    triggerTable[i].disabled = enable
  end
end

function enableTriggers(input)
  if triggers[input] then
    ACSEcho("Enabling " .. input .. " triggers!")
    switchTriggers(triggers[input], false)
  else
    ACSEcho("Error: " .. input .. " not found in triggers table.")
  end
end

function disableTriggers(input)
  if triggers[input] then
    ACSEcho("Disabling " .. input .. " triggers!")
    switchTriggers(triggers[input], true)
  else
    ACSEcho("Error: " .. input .. " not found in triggers table.")
  end
end

function testTrigger(pattern, input)
  local res = input:find(pattern)
  ACSEcho("Triggers works? " .. res)
end

function addTrigger(sub, pattern, handler)
  local trigger = {pattern = pattern, handler = handler}
  if not triggers[sub] then triggers[sub] = {} end
  table.insert(triggers[sub], trigger)
  debug("Added trigger for: " .. pattern)
end

function sortByPri(a,b)
  return a.priority > b.priority
end