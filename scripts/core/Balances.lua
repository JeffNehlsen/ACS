echo("Balances file loaded.")

touchedTree = false
focused = false

triggers.balances = {
  -- Balance/Equilibrium
  {pattern = "^Balance Used: .* seconds$", handler = function() balances:complete("balance") end},
  {pattern = "^Equilibrium Used: .* seconds$", handler = function() balances:complete("equilibrium") end},
  {pattern = "^You have recovered balance on all limbs.$", handler = function() balances:give("balance") end},
  {pattern = "^You have recovered equilibrium.$", handler = function(p) balances:give("equilibrium") end},

  -- Organs/Herbs
  {pattern = "^You eat an? (%w+) slice.$", handler = function(p) balances:sliceHandler(p) end},
  {pattern = "^You eat a castorite gland slice.$", handler = function(p) balances:sliceHandler("castorite") end},
  {pattern = "^You eat a slice of a heart.$", handler = function(p) balances:sliceHandler("heart") end},
  {pattern = "^You eat a piece of kelp.$", handler = function(p) balances:sliceHandler("kelp") end},
  {pattern = "^You eat a bloodroot leaf.$", handler = function(p) balances:sliceHandler("bloodroot") end},
  {pattern = "^You eat some bayberry bark.$", handler = function(p) balances:sliceHandler("bayberry") end},
  {pattern = "^You eat a hawthorn berry.$", handler = function(p) balances:sliceHandler("hawthorn") end},
  {pattern = "^You eat a bellwort flower.$", handler = function(p) balances:sliceHandler("bellwort") end},
  {pattern = "^You eat some prickly ash bark.$", handler = function(p) balances:sliceHandler("ash") end},
  {pattern = "^You eat a goldenseal root.$", handler = function(p) balances:sliceHandler("goldenseal") end},
  {pattern = "^You eat a lobelia seed.$", handler = function(p) balances:sliceHandler("lobelia") end},
  {pattern = "^You may eat another plant.$", handler = function(p) balances:give("organ") end},
  {pattern = "You may consume another curative.", handler = function(p) balances:give("organ") end},
  {pattern = "You quickly eat .* but instantly vomit it back up.", handler = function(p) balances:give("organ") end},

  -- Kidney/moss
  {pattern = "^You eat some irid moss.$", handler = function(p) balances:complete("kidney") end},
  {pattern = "^You may eat another bit of irid moss.$", handler = function(p) balances:give("kidney") end},
  {pattern = "The kidney slice has cleared your system.", handler = function(p) balances:give("kidney") end},

  -- Poultice/salve
  {pattern = "^You press an? (%w+) poultice against your (.+), rubbing it into your flesh.$", handler = function(p) balances:poulticeHandler(p) end},
  {pattern = "^You press the last of an? (%w+) poultice against your (.+), rubbing it into your flesh.$", handler = function(p) balances:poulticeHandler(p) end},
  {pattern = "^You take out (.*) salve and quickly rub it on your (.+).$", handler = function(p) balances:poulticeHandler(p) end},
  {pattern = "^You take out a salve of (.*) and quickly rub it on your (.+).$", handler = function(p) balances:poulticeHandler(p) end},
  {pattern = "^The salve dissolves and quickly disappears after you apply it.$", handler = function(p) balances:poulticeHandler(p) end},
  {pattern = "^You may apply another salve to yourself.$", handler = function(p) balances:give("poultice") end},
  {pattern = "You are again able to absorb a poultice.", handler = function(p) balances:give("poultice") end},

  -- Serum/elixir
  {pattern = "^The serum heals your wounds.$", handler = function(p) balances:complete("serum") end},
  {pattern = "^The serum makes you feel more lucid and aware.$", handler = function(p) balances:complete("serum") end},
  {pattern = "^The serum has no effect on your body.$", handler = function(p) balances:complete("serum") end},
  {pattern = "^The elixir heals and soothes you.$", handler = function(p) balances:complete("serum") end},
  {pattern = "^Your mind feels stronger and more alert.$", handler = function(p) balances:complete("serum") end},
  {pattern = "^The elixir flows down your throat without effect.$", handler = function(p) balances:complete("serum") end},
  {pattern = "^You may drink another health or mana elixir.$", handler = function(p) balances:give("serum") end},
  {pattern = "You are again able to use a healing serum.", handler = function(p) balances:give("serum") end},

  -- Tincture/pipe
  {pattern = "^You quickly inject yourself with a syringe filled with (%w+).$", handler = function(p) balances:tinctureHandler(p) end},
  {pattern = "^You take a long drag off your pipe filled with (%w+).$", handler = function(p) balances:tinctureHandler(p) end},
  {pattern = "^You may smoke another herb.$", handler = function(p) balances:give("tincture") end},
  {pattern = "^You may inject another tincture.", handler = function(p) balances:give("tincture") end},

  -- Healing Serums/elixirs
  {pattern = "^Your body begins to feel lighter and you feel that you are floating slightly.$", handler = function(p) balances:complete("healingSerum") end},
  {pattern = "^You feel a momentary dizziness as your resistance to damage by poison increases.$", handler = function(p) balances:complete("healingSerum") end},
  {pattern = "^You are already benefitting from increased venom resistance.$", handler = function(p) balances:complete("healingSerum") end},
  {pattern = "^You are already levitating.$", handler = function(p) balances:complete("healingSerum") end},
  {pattern = "You may use another affliction%-healing serum.", handler = function(p) balances:give("healingSerum") end},
  {pattern = "You may drink another affliction%-healing elixir.", handler = function(p) balances:give("healingSerum") end},

  -- Tree
  {pattern = "You touch the tree of life tattoo.", handler = function(p) 
    balances:complete("tree") 
    touchedTree = true
    onPrompt(function()
      touchedTree = false
    end)
  end},
  {pattern = "Your tree tattoo tingles slightly.", handler = function(p) balances:give("tree") end},

  -- Focus
  {pattern = "You focus your mind intently on curing your mental maladies.", handler = function(p) 
    balances:complete("focus")
    focused = true 
    onPrompt(function()
      focused = false
    end)
  end},
  {pattern = "Your mind is able to focus once again.", handler = function(p) balances:give("focus") end},

  -- Recon/Erase/Purge
  {pattern = "^With a sinister grin, you will your body to repair itself of afflictions.$", handler = function(p) balances:reconHandler() end},
  {pattern = "^With a faint but confident smile, you invoke the healing power of Life to purge afflictions from your body.$", handler = function(p) balances:reconHandler() end},
  {pattern = "^Marshalling your will, you bear down on one of your maladies and brutally wipe it from existence.$", handler = function(p) balances:reconHandler() end},
  {pattern = "^You feel able to reconstitute your body once more.$", handler = function(p) balances:give("reconstitute") end},
  {pattern = "^You feel able to renew your body once more.$", handler = function(p) balances:give("reconstitute") end},
  {pattern = "^You feel capable of erasing your maladies once more.$", handler = function(p) balances:give("reconstitute") end},

  -- Rage (Atabahi)
  {pattern = "^You allow your pent%-up rage to vent and your eyes flash dangerously.", handler = function(p) balances:complete("rage") end},
  {pattern = "^You may rage once more.", handler = function(p) balances:give("rage") end},

  -- Shrugging (Syssin)
  {pattern = "^You shrug off the effects of %w+.", handler = function(p) balances:complete("shrugging") end},
  {pattern = "^You are unable to shrug off another affliction so soon.", handler = function(p) balances:complete("shrugging") end},
  {pattern = "^You are able to shrug off another affliction.", handler = function(p) balances:give("shrugging") end},

  -- Arm Balance (Not sure if I want this in here)
  -- {pattern = "You have recovered balance on your left arm.", handler = function(p) balances:give("leftarm") end},
  -- {pattern = "You have recovered balance on your right arm.", handler = function(p) balances:give("rightarm") end},
}

balances =  {
  balance      = {able = true, trying = false},
  equilibrium  = {able = true, trying = false},
  organ        = {able = true, trying = false},
  poultice     = {able = true, trying = false},
  tincture     = {able = true, trying = false},
  serum        = {able = true, trying = false},
  kidney       = {able = true, trying = false},
  healingSerum = {able = true, trying = false},
  focus        = {able = true, trying = false},
  tree         = {able = true, trying = false},
  reconstitute = {able = true, trying = false},
  rage         = {able = true, trying = false},
  shrugging    = {able = true, trying = false},

  -- Special balance. Whip/shadow?
  special      = {able = true, trying = false},
}

function balances:sliceHandler(p)
  local slice = mb.line:match(p)

  if stringInTable(slice, {"pineal", "sulphurite", "tongue", "spleen", "tumor",  "bone", "skullcap", "kola", "cohesh", "echinacea", "myrrh", "pear", "sileris"}) then
    return
  elseif stringInTable(slice, {"moss", "kidney"}) then
    self:complete("kidney")
    return
  end

  self:complete("organ")
  lastEaten = slice
  onPrompt(function()
    lastEaten = nil
  end)
end

function balances:poulticeHandler(p)
  local poultice, area
  poultice, area = mb.line:match(p)
  local nilLastApplied = function()
    onPrompt(function() lastApplied = nil end)
  end

  balances:complete("poultice")

  if area == "skin" then
    lastApplied = poultice
  else 
    lastApplied = poultice .. " to " .. area
  end

  if poultice:find("restoration") then 
    addTemp("^You may apply another salve to yourself.$", function(p) nilLastApplied() end)
    return 
  end

  if poultice:find("jecis") then
    addTemp("^You are again able to absorb a poultice.$", function(p) nilLastApplied() end)
    return
  end

  nilLastApplied()
end

function balances:tinctureHandler(p)
  local tincture = mb.line:match(p)
  balances:complete("tincture")

  if injected == "sudorific" or injected == "skullcap" then return end

  lastInjected = tincture
  onPrompt(function()
    lastInjected = nil
  end)
end

function balances:reconHandler()
  balances:complete("reconstitute")
  touchedTree = true
  onPrompt(function()
    touchedTree = false
  end)
end
  
function balances:take(bal)
  if type(bal) == "table" then
    for _, v in ipairs(bal) do
      balances:take(v)
    end
    return
  end

  self[bal].able = false
  self[bal].trying = true
  add_timer(1, function()
    balances:reset(bal)
  end)
end

function balances:complete(bal)
  self[bal].trying = false
  self[bal].able = false
end

function balances:reset(bal)
  if balances[bal].trying then
    balances[bal].trying = false
    balances[bal].able = true
  end
end

function balances:give(bal)
  self[bal].able = true
  self[bal].trying = false
end

function balances:check(bal)
  if type(bal) == "string" then
    return self[bal].able
  end

  for _, v in ipairs(bal) do
    if not self[v].able then return false end
  end
  return true
end