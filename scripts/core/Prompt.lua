echo("Prompt file loaded.")
prompt = {
  pattern = "^H:(%d+)/(%d+) M:(%d+)/(%d+) E:(%d+)/(%d+) W:(%d+)/(%d+) B:(%d+)/(%d+) XP:(%d+)/(%d+) (.*) ?%[([cspdba@]*) ?([e-])([b-]) ?([l-]?[r-]?)%]",
  config = "config prompt custom H:@health/@maxhealth M:@mana/@maxmana E:@end/@maxend W:@will/@maxwill B:@blood/@maxblood XP:@xp/@xpmax Essence:@essence Spark:@spark Soul:@soul Devotion:@devotion Kai:@kai [@stats @eqbal]",
  lastHealth = 0,
  lastMana = 0,
}

function mb.server_prompt()
  if syringegag then
    syringegag = false
    mb.gag_line = true
    mb.gag_ending = true
    return
  end
  prompt:parse(mb.line)
  prompt:setAdjustDisplay()
  prompt:build()
  prompt:checkCureReset()
  prompt:reset()
  prompt:onPrompts()
end

function prompt:parse(line)
  local extra, status, eq, bal, armbal
  local function check(str, char)
    return str:find(char) and true or false
  end

  prompt.health,    prompt.maxHealth, 
  prompt.mana,      prompt.maxMana, 
  prompt.endurance, prompt.maxEndurance, 
  prompt.willpower, prompt.maxWillpower, 
  prompt.blood,     prompt.maxBlood, 
  prompt.xp,        prompt.maxXP, 
  extra, status, eq, bal, armbal = line:match(prompt.pattern)

  prompt.soul         = extra:match("S:(%d+)")
  prompt.devotion     = extra:match("Dev:(%d+)")
  prompt.spark        = extra:match("Spark:(%d+)")
  prompt.kai          = extra:match("Kai:(%d+)")

  prompt.cloak        = check(status, "c")
  prompt.silaris      = check(status, "s")
  prompt.prone        = check(status, "p")
  prompt.deaf         = check(status, "d")
  prompt.blind        = check(status, "b")
  prompt.flying       = check(status, "a")
  prompt.phased       = check(status, "@")

  prompt.balance      = bal == "b"
  prompt.equilibrium  = eq  == "e"
  prompt.leftArmBal   = check(armbal, "l")
  prompt.rightArmBal  = check(armbal, "r")

  health = tonumber(prompt.health)
  mana = tonumber(prompt.mana)
end

function prompt:setAdjustDisplay()
  local manaadjust, healthadjust
  local maxhealth = tonumber(prompt.maxHealth)
  local maxmana = tonumber(prompt.maxMana)
  local lasthealth = prompt.lastHealth
  local lastmana = prompt.lastMana
  prompt.adjustdisp = ""

  if health ~= lasthealth or mana ~= lastmana then
    if (health > lasthealth) then
      healthadjust = health - lasthealth
      prompt.adjustdisp = C.B .. "[" .. C.G .. "+" .. healthadjust .. "h" .. C.B .. "]" .. C.x
    elseif (health < lasthealth) then
      healthadjust = lasthealth - health
      prompt.adjustdisp = C.B .. "[" .. C.R .. "-" .. healthadjust .. "h" .. C.B .. "]" .. C.x
    end

    if (mana > lastmana) then
      manaadjust = atcp.mana - lastmana
      prompt.adjustdisp = prompt.adjustdisp .. C.B .. "[" .. C.C .. "+" .. manaadjust .. "m" .. C.B .. "]" .. C.x
    elseif (mana < lastmana) then
      manaadjust = lastmana - mana
      prompt.adjustdisp = prompt.adjustdisp .. C.B .. "[" .. C.m .. "-" .. manaadjust .. "m" .. C.B .. "]" .. C.x
    end
  end

  if recklesscheck and health == maxhealth and mana == maxmana then
    echo(C.B .. "\n[" .. C.R .. "POSSIBLE RECKLESSNESS! FLAGGING!" .. C.B .. "]" .. C.x)
    afflictionAdd("recklessness")
  end
  recklesscheck = false

  if hasAffliction("recklessness") and (health ~= maxhealth or mana ~= maxmana) then
    afflictionCure("recklessness")
  end

  prompt.lastHealth = health
  prompt.lastMana = mana
end

function prompt:build()
  local promptDisplay = {}
  local sp = " "

  local function add(str, addSp)
    if type(str) == "function" then str = str() end
    table.insert(promptDisplay, str)
    if addSp then table.insert(promptDisplay, " ") end
  end

  local function check(statement, istrue, isfalse)
    return statement and istrue or isfalse
  end

  local function round(num, idp)
    local mult = 10^(idp or 0)
    return math.floor(num * mult + 0.5) / mult
  end

  local function toPercent(curr, max)
    return round(tonumber(curr) / tonumber(max) * 100, 0)  
  end

  local function p_stat(current, max, show_percent)
    local color
    if not current then current = 0 end
    if not max then max = 0 end
    current = tonumber(current)
    max = tonumber(max)
    if hasAffliction("recklessness") and current == atcp.health and max == atcp.max_health then
        color = C.R
    elseif current < max / 3 then
        color = C.R
    elseif current < max * 2 / 3 then
        color = C.Y
    else
        color = C.g
    end

    if show_percent then
        return color .. toPercent(current, max) .. C.x .. "%"
    else
        return color .. current .. C.x
    end
  end

  local healthDisplay = promptLabelColor .. "H:" .. p_stat(prompt.health, prompt.maxHealth, false)
  local manaDisplay = promptLabelColor .. "M:" .. p_stat(prompt.mana, prompt.maxMana, false)
  local enduranceDisplay = promptLabelColor .. "E:" .. p_stat(prompt.endurance, prompt.maxEndurance, true)
  local willpowerDisplay = promptLabelColor .. "W:" .. p_stat(prompt.willpower, prompt.maxWillpower, true)
  local bloodDisplay = C.R .. "B:" .. toPercent(prompt.blood, prompt.maxBlood) .. C.x
  local xpDisplay = function()
    if experienceDisplay == "full" then
      return "XP:" .. prompt.xp .. "/" .. prompt.maxXP
    elseif experienceDisplay == "percent" then
      return "XP:" .. toPercent(prompt.xp, prompt.maxXP)
    end
    return ""
  end
  kaiDisplay = function()
    if prompt.kai and prompt.kai ~= "" then
      return promptLabelColor .. "Kai:" .. C.Y .. prompt.kai .. promptLabelColor .. "%" 
    end
    return ""
  end
  local devotionDisplay = function() 
    if prompt.devotion and prompt.devotion ~= "" then
      return promptLabelColor .. "Dev:" .. C.c .. prompt.devotion .. promptLabelColor .. "%"
    end
    return ""
  end
  local sparkDisplay = function()
    if prompt.spark and prompt.spark ~= "" then
      return promptLabelColor .. "Spark:" .. C.r .. prompt.spark .. promptLabelColor .. "%"
    end
    return ""
  end
  local soulDisplay = function()
    if prompt.soul and prompt.soul ~= "" and isClass("carnifex") then
      return C.c .. "S:" .. prompt.soul .. "%" .. promptLabelColor
    end
    return ""
  end
  local balanceDisplay = check(prompt.equilibrium, C.C .. "e" .. C.x, "-") .. check(prompt.balance, C.C .. "b" .. C.x, "-")
  local armBalDisplay = check(prompt.leftArmBal, C.C .. "l" .. C.x, "-") .. check(prompt.rightArmBal, C.C .. "r" .. C.x, "-")
  local statusDisplay = check(prompt.cloak, "c", "") ..
                        check(prompt.silaris, C.Y .. "s", "") ..
                        check(prompt.prone, C.R .. "P" .. C.x, "") ..
                        check(prompt.deaf, C.m .. "d" .. C.x, "") ..
                        check(prompt.blind, C.m .. "b" .. C.x, "") ..
                        check(prompt.flying, "a", "") ..
                        check(prompt.phased, C.Y .. "@", "")
  local dateDisplay = C.g .. string.sub(os.date(), 14, -1) .. " " .. C.x

  -- Some display flags.
  local showArmBalance = isClass("atabahi") or isClass("monk") or isClass("daru")
  local spaceAfterBalance = showArmBalance or not showArmBalance and statusDisplay ~= ""

  add(healthDisplay,    true)
  add(manaDisplay,      true)
  add(enduranceDisplay, true)
  add(willpowerDisplay, true)
  add(bloodDisplay,     true)
  if kaiDisplay() ~= "" then add(kaiDisplay, true) end
  if soulDisplay() ~= "" then add(soulDisplay, true) end
  if sparkDisplay() ~= "" then add(sparkDisplay, true) end
  if xpDisplay() ~= "" then add(xpDisplay, true) end
  add("[", false)
  add(balanceDisplay,   spaceAfterBalance)
  if showArmBalance then
    add(armBalDisplay, statusDisplay ~= "")
  end
  add(statusDisplay, false)
  add(C.x .. "]", true)
  add(dateDisplay, true)
  add(prompt.adjustdisp, true)

  replace(table.concat(promptDisplay))
end

function prompt:checkCureReset()
  if not (lastEaten or lastApplied or lastInjected or touchedTree or focused) or linenumber > 1 or (lastApplied and (lastApplied:find("jecis") or lastApplied:find("restoration"))) then return end
  cureReset()
end

function prompt:reset()
  linenumber = 0
  eating = nil
  injecting = nil
  clearapplied = false
  clearinjected = false
  cleareat = false
  cleartree = false
  clearfocus = false
  raged = false
  lastattack = nil
end

function prompt:onPrompts()
  prompt_resetLimb()

  if healer and not stunned and not unconscious and not asleep then
    doFlick()
    doHeal()
    doAutosip()
    --fillTinctures()
    doStand()
    doParry()
    defenses:redef()
    actions:check()
  end

  doTemporaryPromptTriggers()
end