
PipeFiller = {}
PipeFiller.triggers = {
  {pattern = {
    "Your current pagelength: %d+",
    "^%*+%[ Syringes %]%*+$",
    "^%*+%[ Pipes %]%*+$",
    "Syringe%s+Tincture%s+Injects%s+Decay%s+Mixed",
    "^%-+$",
    "^%*+$",
    "^Pipe%s+Herb%s+Puffs Decay%s+Lit",
  }, handler = function(p)
    killLine()
    if not PipeFiller.addedPromptTrigger then
      PipeFiller.addedPromptTrigger = true
      onPrompt(function()
        disableTriggers("PipeFiller")
        PipeFiller.addedPromptTrigger = nil
        PipeFiller:process()
      end)
    end
  end},

  -- {pattern = "^(%d+).-(%w+)%s+(%d+)%s+(%d+)%s+(%w+)", handler = function(p) PipeFiller:parseSyringe(p) end},

  {pattern = "(%d+).+slippery elm%s+(%d+)%s+(%d+)%s+(%w+)", handler = function(p) PipeFiller:parsePipe("elm", p) end},
  {pattern = "(%d+).+a valerian leaf%s+(%d+)%s+(%d+)%s+(%w+)", handler = function(p) PipeFiller:parsePipe("valerian", p) end},
  {pattern = "(%d+).+a skullcap flow%s+(%d+)%s+(%d+)%s+(%w+)", handler = function(p) PipeFiller:parsePipe("skullcap", p) end},
  {pattern = "(%d+).+empty%s+%d+%s+(%d+)%s+%w+", handler = function(p) PipeFiller:parseEmpty(p) end},
}

PipeFiller.aliases = {
  
}

function PipeFiller:parsePipe(type, p)
  local num, amount, decay, lit = mb.line:match(p)
  killLine()
  debug:print("PipeFiller", "type: " .. type .. ", num: " .. num .. ", amount: " .. amount .. ", decay: " .. decay .. ", lit: " .. lit)
  self:add(type, num, amount, decay)
end

function PipeFiller:parseEmpty(p)
  local num, decay = mb.line:match(p)
  killLine()
  debug:print("PipeFiller", "num: " .. num .. ", decay: " .. decay)
  table.insert(PipeFiller.empty, {number = num, decay = decay})
end

function PipeFiller:parseSyringe(p)
  local num, type, injects, decay, mixed = mb.line:match(p)
  if itype == "antispasma" then itype = "antispasmadic" end
  killLine()
  debug:print("PipeFiller", "num: " .. num .. ", itype: " .. itype .. ", injects: " .. injects .. ", decay: " .. decay .. ", mixed: " .. mixed)
  self:add(type, num, amount, decay)
end

function PipeFiller:add(type, pipeNumber, amount, decay)
  debug:print("PipeFiller", "Adding! type: " .. type .. ", num: " .. pipeNumber .. ", amount: " .. amount .. ", decay: " .. decay)
  local pipe = {}
  pipe.number = number
  pipe.amount = amount
  pipe.decay = decay
  table.insert(PipeFiller[type], pipe)
end

function PipeFiller:process()
  -- local elm = living and self:sum(self.elm) or self:sum(self.demulcent)
  -- local valerian = living and self:sum(self.valerian) or self:sum(self.antispasmadic)
  -- local skullcap = living and self:sum(self.skullcap) or self:sum(self.sudorific)
  local toFill

  debug:print("PipeFiller", "PipeFiller:processPipes()")
  -- debug:print("PipeFiller", "living: "  .. tostring(living) .. ", elm: " .. elm .. ", valerian: " .. valerian .. ", skullcap: " .. skullcap)

  local type1, type2, type3 
  if living then
    type1, type2, type3 = "valerian", "elm", "skullcap"
  else
    type1, type2, type3 = "antispasmadic", "demulcent", "sudorific"
  end

  for _, empty in ipairs(PipeFiller.empty) do
    valerian, elm, skullcap = self:getSums(type1, type2, type3)
    debug:print("PipeFiller", "elm: " .. elm .. ", valerian: " .. valerian .. ", skullcap: " .. skullcap)  
    toFill = self:getLowest(valerian, elm, skullcap, {type1, type2, type3})
    debug:print("PipeFiller", "toFill: " .. toFill)
    table.insert(self[toFill], {amount = 10})
    empty.fillTarget = toFill
  end
  debug:print("PipeFiller", printtable(self.empty))
  actions:add(function() PipeFiller:fill() end, baleq, {})
end

function PipeFiller:getLowest(type1, type2, type3, names)
  debug:print("PipeFiller", "getLowest! type1: " .. type1 .. ", type2: " .. type2 .. ", type3: " .. type3)
  debug:print("PipeFiller", "getLowest! names[1]: " .. names[1] .. ", names[2]: " .. names[2] .. ", names[3]: " .. names[3])
  if type1 == 0 then return names[1] end
  if type2 == 0 then return names[2] end
  if type3 == 0 then return names[3] end
  

  if type1 <= type2 or type1 <= type3 then return names[1] end
  if type2 <= type3 then return names[2] end
  return names[3]
end

function PipeFiller:getSums(type1, type2, type3)
  local sum1, sum2, sum3 = self:getSum(type1), self:getSum(type2), self:getSum(type3)
  debug:print("PipeFiller", sum1 .. " " .. sum2 .. " " .. sum3)
  return sum1, sum2, sum3
end

function PipeFiller:getSum(type)
  local total = 0
  for _, pipe in ipairs(self[type]) do
    total = total + pipe.amount
  end
  return total
end

function PipeFiller:fill()
  for _, pipe in ipairs(PipeFiller.empty) do
    if living then
      send("outc " .. pipe.fillTarget)
      send("put " .. pipe.fillTarget .. " in " .. pipe.number)
    else
      send("siphon " .. pipe.fillTarget .. " into " .. pipe.number)
    end
  end

  if living then
    send("light pipes")
  else
    send("flick syringes")
  end
end

function PipeFiller:checkTime()
  if not self.lastChecked or os.time() - self.lastChecked > 20 then 
    PipeFiller:performCheck() 
  end
end

function PipeFiller:performCheck()
  enableTriggers("PipeFiller")
  PipeFiller:reset()
  self.lastChecked = os.time()
  send("config pagelength 200")
  if living then
    send("pipelist")
  else
    send("syringelist")
  end
  send("config pagelength 30")
end

function PipeFiller:reset()
  PipeFiller.filling       = false
  PipeFiller.demulcent     = {}
  PipeFiller.antispasmadic = {}
  PipeFiller.sudorific     = {}
  PipeFiller.elm           = {}
  PipeFiller.valerian      = {}
  PipeFiller.skullcap      = {}
  PipeFiller.empty         = {}
end

function PipeFiller:setup()
  triggers.PipeFiller = {}
  
  aliases.PipeFiller = {}
  for _, trigger in ipairs(self.triggers) do
    table.insert(triggers.PipeFiller, trigger)
  end

  for _, alias in ipairs(self.aliases) do
    table.insert(aliases.PipeFiller, alias)
  end

  disableTriggers("PipeFiller")

  -- Set up the triggers that will actually enable this module.
  triggers.PipeFillerExtra = {
    {pattern = {
      "^You are not holding a syringe with that type of tincture in it.$",
      "^The syringe is now empty.$",
      "^You squirt out the remaining %w+ from the syringe.$",
      "^Your pipe is now empty.$",
      "^What is it you wish to smoke?$",
      "^You tap out the contents of your pipe.$"
    }, handler = function() PipeFiller:performCheck() end},
  }
end

PipeFiller:setup()