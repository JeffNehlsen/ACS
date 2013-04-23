-- Constants
skillranks = {unknown = 0, inept = 1, novice = 2, apprentice = 3, capable = 4, adept = 5, skilled = 6, gifted = 7, expert = 8, virtuoso = 9, fabled = 10, mythical = 11, transcendent = 12}


-- Printing helpers.
acsLabel = C.r .. "[" .. C.R .. "ACS" .. C.r .. "]: " .. C.x

function setACSLabel(str)
    replace(acsLabel .. str .. C.x)
end

function ACSEcho(str)
    echo("\n" .. acsLabel .. str .. C.x)
    show_prompt()
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

function debug(message)
    if showDebug then
        echo(C.r .. "  [" .. C.R .. "DEBUG" .. C.r .. "]: " .. C.x .. message)
    end
end


-- Class selection helpers
function isClass(class)
    return class == classType
end

function isVampire()
    return isClass("vampire") or isClass("bloodborn") or isClass("praenomin") or isClass("consanguine")
end

function isNecro()
    return isClass("infernal") or isClass("cabalist") or isClass("indorani")
end



-- Other helper functions
function tableRemove(t, rem)
    for k,v in pairs(t) do
        if v.name == rem then
            table.remove(t, k)
        end
    end
end

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

function testTrigger(pattern, input)
    local res = input:find(pattern)
    ACSEcho("Triggers works? " .. res)
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

-- Function that will sort by priority.  Used by the healer
function sortByPri(a,b)
    return a.priority > b.priority
end