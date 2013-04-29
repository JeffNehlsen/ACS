echo("Core loaded")

aliases = {}
triggers = {}
triggers.temporary = {}
triggersToAdd = {}
temporaryPromptTriggers = {}
hooks = {}
extraLine = ""
class= {}
linenumber = 0


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


-- Function for adding a trigger
function addTrigger(sub, pattern, handler)
    local trigger = {pattern = pattern, handler = handler}
    if not triggers[sub] then triggers[sub] = {} end
    table.insert(triggers[sub], trigger)
end

-- Function for adding an alias
function addAlias(pattern, handler)
    -- TODO: Write addAlais(pattern, handler)
end




-- Temporary triggers
-- Create a temporary trigger to be added at the next prompt
function addTemporaryTrigger(p, h)
    local trig = {pattern = p, handler = h, temporary = true}
    table.insert(triggersToAdd, trig)
end

-- Alais functions for adding a temporary trigger
function tempTrigger(p, h)
    addTemporaryTrigger(p, h)
end

function addTemp(p, h)
    addTemporaryTrigger(p, h)
end

-- addTemporaryTriggers is fired on the prompt.  If there are triggers to add,
-- loop through the stored triggers and add them.
function addTemporaryTriggers()
    for i,v in ipairs(triggersToAdd) do
        table.insert(triggers.temporary, v)
    end
    triggersToAdd = {}
end

-- Removes a temporary trigger
function removeTemp(p)
    local count = 0
    for i,v in pairs(triggers.temporary) do
        if p == v.pattern then
            table.remove(triggers.temporary, i)
        end
    end
end

-- "On Prompt" triggers.
-- These will fire on the next seen prompt
function addTemporaryPromptTrigger(h)
    table.insert(temporaryPromptTriggers, h)
end

function atPrompt(h)
    addTemporaryPromptTrigger(h)
end

function onPrompt(h)
    addTemporaryPromptTrigger(h)
end

-- Executes all prompt triggers, then cleans the table
function doTemporaryPromptTriggers()
    if #temporaryPromptTriggers > 0 then
        for i,v in ipairs(temporaryPromptTriggers) do
            v()
        end
        temporaryPromptTriggers = {}
    end
end


-- Trigger sub-table enabling/disabling.
function switchTriggers(triggerTable, enable)
    for i,v in ipairs(triggerTable) do
        triggerTable[i].disabled = enable
    end
end

function enableTriggers(input)
    if triggers[input] then
        -- ACSEcho("Enabling " .. input .. " triggers!")
        switchTriggers(triggers[input], false)
    else
        ACSEcho("Error: " .. input .. " not found in triggers table.")
    end
end

function disableTriggers(input)
    if triggers[input] then
        -- ACSEcho("Disabling " .. input .. " triggers!")
        switchTriggers(triggers[input], true)
    else
        ACSEcho("Error: " .. input .. " not found in triggers table.")
    end
end


-- Rig the handler functions to mudbot to parse
mb.server_line = trigger_handler
mb.client_aliases = alias_handler
mb.server_prompt = prompt_handler