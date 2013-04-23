echo("Elixlist script loaded.")

elixlistCheck = false

aliases.elixlist = {
  {pattern = "^els$", handler = function(i,p) doElixlistCheck() end},
}

empties = {}
cleans = {}
decaySoon = {}
elsSep = C.b .. "------------------------------------------------------------------" .. C.x

triggers.elixlistTriggers = {
  {pattern = "^(%w-)(%d+)%s+([%w ]-)%s%s%s*(%d+)%s+(%d+)$", handler = function(p) addAsElixir(p) end},
  {pattern = "^Vial%s+Elixir%s+Sips%s+Months Left", handler = function(p) if elixlistCheck then killLine() end end},
  {pattern = "^Bandage%s+Poultice%s+Presses%s+Months Left", handler = function(p) if elixlistCheck then killLine() end end},
  {pattern = "^(%-+)", handler = function(p) if elixlistCheck then killLine() end end},
  {pattern = "^Your current pagelength: (%d+)", handler = function(p) if elixlistCheck then killLine() end end},

  {pattern = "^%s*%[%s*(%d+)%] ([%w ]+)$", handler = function(p) cacheHandler(p) end},
  {pattern = "^%s*%[%s*(%d+)%] ([%w ]-)%s%s%s*%[%s*(%d+)%] ([%w ]+)$", handler = function(p) cacheHandler(p) end},
  {pattern = "^%s*%[%s*(%d+)%] ([%w ]-)%s%s%s*%[%s*(%d+)%] ([%w ]-)%s%s%s*%[%s*(%d+)%] ([%w ]+)$", handler = function(p) cacheHandler(p) end},
  {pattern = "^Glancing into the cache, you see:$", handler = function(p) curatives.cache = {} end},
}

function addAsElixir(pattern)
  if elixlistCheck then
    holderType, number, name, apps, decayTime = mb.line:match(pattern)
    if holderType == "bandage" then
      if name == "clean" then 
        curatives.undead.cleans = curatives.undead.cleans + 1
      else
        curativesAdd("undead", "bandages", name, apps)
      end
    else
      if name == "empty" then
        curatives.empties = curatives.empties + 1
      else
        if name:find("venom") then
          addVenomToCuratives(name, apps)
        elseif name:find("serum") then
          name = name:match("(%w+) serum")
          curativesAdd("undead", "serums", name, apps)
        elseif name:find("tincture") then
          name = name:match("(%w+) tincture")
          curativesAdd("undead", "tinctures", name, apps)
        elseif name:find("elixir") then
          name = name:match("elixir of (%w+)")
          curativesAdd("living", "elixirs", name, apps)
        elseif name:find("salve") then
          name = name:match("salve of (%w+)")
          curativesAdd("living", "salves", name, apps)
        end
      end
    end

    if tonumber(decayTime) < 30 then
      table.insert(curatives.decaySoon, {vial = vialNum, time = decayTime})
    end
    killLine()
  end
end

function addVenomToCuratives(name, apps)
  name = name:match("the venom (%w+)")
  if not curatives.venoms[name] then curatives.venoms[name] = {applications = 0, vials = 0} end
  curatives.venoms[name].applications = curatives.venoms[name].applications + apps
  curatives.venoms[name].vials = curatives.venoms[name].vials + 1
end

function curativesAdd(liveState, type, name, apps)
  if not curatives[liveState][type][name] then curatives[liveState][type][name] = {applications = 0, vials = 0} end
  curatives[liveState][type][name].applications = curatives[liveState][type][name].applications + apps
  curatives[liveState][type][name].vials = curatives[liveState][type][name].vials + 1
end

function cacheHandler(p)
  num1, type1, num2, type2, num3, type3 = mb.line:match(p)

  if not curatives.cache[type1] then curatives.cache[type1] = 0 end
  if type2 and not curatives.cache[type2] then curatives.cache[type2] = 0 end
  if type3 and not curatives.cache[type3] then curatives.cache[type3] = 0 end

  curatives.cache[type1] = curatives.cache[type1] + num1
  if type2 then curatives.cache[type2] = curatives.cache[type2] + num2 end
  if type3 then curatives.cache[type3] = curatives.cache[type3] + num3 end
end

function doElixlistCheck()
  elixlistCheck = true
  resetCuratives()
  send("config pagelength 250")
  send("elixlist")
  send("bandagelist")
  send("config pagelength " .. defaultPagelength)
  add_timer(3, function() printElixlist() elixlistCheck = false end)
  show_prompt()
end

function resetCuratives()
  curatives = {
    undead = {
      set = {"serums", "bandages", "tinctures"},
      bandages = {set = {"oculi", "orbis", "fumeae", "pueri", "jecis"}},
      serums = {set = {"analeptic", "stimulant", "euphoric", "calmative", "carminative", "nervine", "refrigerative", "apocroustic"}},
      tinctures = {set = {"demulcent", "antispasmadic", "sudorific"}},
      cleans = 0,
    },
    living = {
      set = {"elixirs", "salves"},
      elixirs = {set = {"health", "mana", "levitation",  "immunity", "venom", "speed", "frost"}},
      salves = {set = {"mending", "restoration", "epidermal", "caloric", "mass"}},
    },
    empties = 0,
    decaySoon = {},
    venoms = {set = {"xentio", "oleander", "eurypteria", "kalmia", "strophanthus", "digitalis", "digitalis", 
                     "darkshade", "curare", "epteth", "epseth", "prefarar", "monkshood", "euphoria", "colocasia", 
                     "oculus", "hepafarin", "jalk", "vernalius", "epseth", "larkspur", "slike", "araceae", 
                     "voyria", "delphinium", "vardrax", "loki", "aconite", "selarnia", "gecko", "scytherus"}
    },
  }
end

function setupels()
  send("elixlist")
  send("more")
  send("more")
  send("more")
  send("more")
  send("more")
  send("more")
  send("more")
  send("bandagelist")
  send("pipelist")
  send("more")
  send("more")
end

function firstToUpper(str)
    return (str:gsub("^%l", string.upper))
end

function printElixlist()
  if living then printElixlistGeneric("living") else printElixlistGeneric("undead") end
  if showVenoms then printVenoms() end
  -- TODO: Print empty count, clean count, almost decayed
end

-- TODO: Add function that will warn about low amounts on use?

function printElixlistGeneric(type)
  curatives.printout = {}
  for k,v in pairs(curatives[type].set) do curatives.printout[v] = {} end

  for i,v in ipairs(curatives[type].set) do
    for i2,v2 in pairs(curatives[type][v].set) do
      if not curatives[type][v][v2] then curatives[type][v][v2] = {applications = 0, vials = 0} end
      curatives.printout[v][v2] = generatePrintout(v2, curatives[type][v][v2].applications)
    end
  end

  echo("\n\nElixlist Results")
  echo(elsSep)
  for k,v in pairs(curatives[type].set) do
    printoutSet(firstToUpper(v), curatives[type][v].set, curatives.printout[v])
  end
end

function printVenoms()
  curatives.printout.venoms = {}
  for i,v in ipairs(curatives.venoms.set) do
    if not curatives.venoms[v] then curatives.venoms[v] = {applications = 0, vials = 0} end
    curatives.printout.venoms[v] = generatePrintout(v, curatives.venoms[v].applications)
  end

  printoutSet("Venoms", curatives.venoms.set, curatives.printout.venoms)
end

function printoutSet(setName, set, printoutTable)
  local str = "  "
  local count = 0

  echo("")
  echo(setName)
  for i,v in ipairs(set) do
    str = str .. printoutTable[v]
    count = count + 1
    if count == 3 then echo(str) str = "  " count = 0 end
  end
  if str ~= "" then echo(str) end
  echo("")
  echo(elsSep)
end

function generatePrintout(name, apps)
  local numColor = C.G
  if apps < 100 then 
    numColor = C.R 
  elseif 
    apps < 500 then numColor = C.Y 
  end

  local syntax = C.b .. "[" .. numColor .. "%4d" .. C.b .. "]" .. C.x .. " %-15s"

  return syntax:format(apps, name)
end

function sortByApplicastions(a,b)
  return a.applications > b.applications
end