-- Constants
skillranks = {unknown = 0, inept = 1, novice = 2, apprentice = 3, capable = 4, adept = 5, skilled = 6, gifted = 7, expert = 8, virtuoso = 9, fabled = 10, mythical = 11, transcendent = 12}
baleq = {"balance", "equilibrium"}


-- Printing helpers.
acsLabel = C.r .. "[" .. C.R .. "ACS" .. C.r .. "]: " .. C.x

function setACSLabel(str)
    replace(acsLabel .. str .. C.x)
end

function ACSEcho(str)
    echo("\n" .. acsLabel .. str .. C.x)
    show_prompt()
end


-- Class selection helpers
function isClass(class)
    return class:lower() == classType:lower()
end

function isVampire()
    return isClass("vampire") or isClass("bloodborn") or isClass("praenomin") or isClass("consanguine")
end

function isNecro()
    return isClass("infernal") or isClass("cabalist") or isClass("indorani")
end



-- Other helper functions
function stringInTable(str, tab)
    for i,v in pairs(tab) do
        if v == str then return true end
    end
    return false
end

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
    return string.lower(p):match(string.lower(target))
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


function canUseMana()
  return not restrictManaUsage or tonumber(prompt.mana) > tonumber(prompt.maxMana) * .75
end

function checkTrigger(string, pattern)
    echo(tostring(string:match(pattern)))
end




-- Living/Undead curing conversions
toLiving = {
  pineal                 = "skullcap",
  bone                   = "sileris",
  bladder                = "ash",
  liver                  = "goldenseal",
  eyeball                = "kelp",
  testis                 = "lobelia",
  ovary                  = "ginseng",
  castorite              = "bellwort",
  lung                   = "bloodroot",
  kidney                 = "moss",
  sulphurite             = "kola",
  tongue                 = "cohosh",
  heart                  = "hawthorn",
  stomach                = "bayberry",
  tumor                  = "myrrh",
  spleen                 = "echinacea",

  demulcent              = "elm",
  antispasmadic          = "valerian",
  sudorific              = "skullcap",

  analeptic              = "health",
  stimulant              = "mana",
  euphoric               = "levitation",
  calmative              = "immunity",
  carminative            = "venom",
  nervine                = "speed",
  refrigerative          = "frost",

  oculi                  = "epidermal",
  orbis                  = "mending",
  fumeae                 = "caloric",
  jecis                  = "restoration",
  pueri                  = "mass",
  ["orbis to legs"]      = "mending to legs",
  ["orbis to arms"]      = "mending to arms",
  ["orbis to left leg"]  = "mending to left leg",
  ["orbis to right leg"] = "mending to right leg",
  ["orbis to left arm"]  = "mending to left arm",
  ["orbis to right arm"] = "mending to right arm",
  ["orbis to torso"]     = "mending to torso",
  ["orbis to head"]      = "mending to head",
  
  ["jecis to legs"]      = "restoration to legs",
  ["jecis to arms"]      = "restoration to arms",
  ["jecis to left leg"]  = "restoration to left leg",
  ["jecis to right leg"] = "restoration to right leg",
  ["jecis to left arm"]  = "restoration to left arm",
  ["jecis to right arm"] = "restoration to right arm",
  ["jecis to torso"]     = "restoration to torso",
  ["jecis to head"]      = "restoration to head",
  
  ["oculi to torso"]     = "epidermal to torso",
  ["oculi to head"]      = "epidermal to head",
}

toUndead = {
  skullcap                     = "pineal",
  sileris                      = "bone",
  ash                          = "bladder",
  goldenseal                   = "liver",
  kelp                         = "eyeball",
  lobelia                      = "testis",
  ginseng                      = "ovary",
  bellwort                     = "castorite",
  bloodroot                    = "lung",
  moss                         = "kidney",
  kola                         = "sulphurite",
  cohosh                       = "tongue",
  hawthorn                     = "heart",
  bayberry                     = "stomach",
  myrrh                        = "tumor",
  echinacea                    = "spleen",

  elm                          = "demulcent",
  valerian                     = "antispasmadic",
  skullcap                     = "sudorific",

  health                       = "analeptic",
  mana                         = "stimulant",
  levitation                   = "euphoric",
  immunity                     = "calmative",
  venom                        = "carminative",
  speed                        = "nervine",
  frost                        = "refrigerative",

  epidermal                    = "oculi",
  mending                      = "orbis",
  caloric                      = "fumeae",
  restoration                  = "jecis",
  mass                         = "pueri",
  
  ["mending to legs"]          = "orbis to legs",
  ["mending to arms"]          = "orbis to arms",
  ["mending to left leg"]      = "orbis to left leg",
  ["mending to right leg"]     = "orbis to right leg",
  ["mending to left arm"]      = "orbis to left arm",
  ["mending to right arm"]     = "orbis to right arm",
  ["mending to torso"]         = "orbis to torso",
  ["mending to head"]          = "orbis to head",
  
  ["restoration to legs"]      = "jecis to legs",
  ["restoration to arms"]      = "jecis to arms",
  ["restoration to left leg"]  = "jecis to left leg",
  ["restoration to right leg"] = "jecis to right leg",
  ["restoration to left arm"]  = "jecis to left arm",
  ["restoration to right arm"] = "jecis to right arm",
  ["restoration to torso"]     = "jecis to torso",
  ["restoration to head"]      = "jecis to head",
  
  ["epidermal to torso"]       = "oculi to torso",
  ["epidermal to head"]        = "oculi to head",
}

function convertToLiving(cure)
  return toLiving[cure] or cure
end

function convertToUndead(cure)
  return toUndead[cure] or cure
end

function getTableIndex(t, item)
    for i, v in ipairs(t) do
        if v == item then return i end
    end
end