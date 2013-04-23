echo("Syssin attack system: Never know what hit 'em.")

venomset = {}
syssinAI = {}
toSuggest = {}
suggested = {}
HypnoState = {UNHYP = 1, HYP = 2, SEALED = 3, SNAPPED = 4}

venom1 = ""
venom2 = ""
shadowAttack = ""
secreted = ""
generalTarget = "herb"
currentlyEnvenomed = {}
lastVenom = ""

lastFlay = ""

hState = HypnoState.UNHYP
autoHypno = false
lastSuggestion = ""
lastSuggestion2 = ""
suggesting = false
sealTime = 4
needSeal = false
enemyCanFocus = true

shrugBalance = true
shadowBalance = true

void = false

targetIsUndead = false

stackList = {
  scytherus = {
    venoms = {"curare", "darkshade", "euphorbia", "colocasia", "kalmia", "gecko", "slike"}, 
    suggestions = {"hypochondria", "lethargy", "hypochondria", "impatience"},
  },

  kelp = {
    venoms = {"curare", "xentio", "kalmia", "gecko", "slike"}, 
    suggestions = {"impatience", "hypochondria", "stupidity", "impatience", "clumsiness"},
  },

  disloyaler = {
    venoms = { "curare", "kalmia", "euphorbia", "monkshood", "xentio", "gecko",  "vernalius", "slike", "epteth", "epseth" },
    suggestions = {"bulimia", "hypochondria", "bulimia", "lethargy", "bulimia", "bulimia", "bulimia", "impatience"}
  },
}

aliases.classAliases = {
  {pattern = "^ghost$", handler = function(i,p) send("conjure ghost") end},
  {pattern = "^cloak$", handler = function(i,p) send("conjure cloak") end},
  
  
  {pattern = "^stacks?$", handler = function(i,p) listStacks() end},
  {pattern = "^stack (%w+)$", handler = function(i,p) selectStackHandler(i,p) end},
  {pattern = "^ec?focus$", handler = function(i,p) switchEnemyCanFocus() end},
  {pattern = "^undead$", handler = function(i,p) switchUndead() end},
  {pattern = "^magic$", handler = function(i,p) switchMagicUser() end},
}

aliases.attackAliases = {
  {pattern = "^gl$", handler = function(i,p) garrotelock() end},
  {pattern = "^gr$", handler = function(i,p) garrote() end},
  {pattern = "^hyp$", handler = function(i,p) startHypno() end},
  {pattern = "^ns$", handler = function(i,p) nextSuggestion() end},
  
  {pattern = "^lw (%w+)$", handler = function(i,p) dir = i:match(p) send("conjure lightwall " .. dir) end},
  
  {pattern = "^nexta$", handler = function(i,p) executeAttack() end},
  {pattern = "^attack$", handler = function(i,p) executeAttack() end},
  {pattern = "^scy$", handler = function(i,p) syssinAI:executeBite("scytherus") end},
  {pattern = "^voy$", handler = function(i,p) syssinAI:executeBite("voyria") end},
  {pattern = "^loki$", handler = function(i,p) syssinAI:executeBite("loki") end},
  {pattern = "^op$", handler = function(i,p) syssinAI:delphiniumStab() end},

  {pattern = "^bite (%w+)$", handler = function(i,p) syssinAI:biteAliasHandler(i,p) end},

  {pattern = "^sn$", handler = function(i,p) syssinAI:snipe() end},
}
 
triggers.attackTriggers = {
  {pattern = "^.* is too perceptive for your hypnotic skill, and you hurriedly cease your attempts before being noticed.", handler = function(p) hypnosisFailed() end},
  {pattern = "^Your attempted hypnosis is broken.", handler = function(p) hypnosisFailed() end},
  {pattern = "^%w+ has noticed your attempt at hypnosis!", handler = function(p) hypnosisFailed() end},
  {pattern = "^You fix .* with an entrancing stare, and smile in satisfaction as you realise that (%w+) mind is yours.$", handler = function(p) targetHypnotised() end},
  {pattern = "^You are already hypnotising someone.$", handler = function(p) targetHypnotised() end},
  {pattern = "^You issue the suggestion, concealing it deep within %w+'s mind.", handler = function(p) suggestionGiven() end},
  {pattern = "^You draw (.*) out of (%w+) hypnotic daze, your suggestions indelibly printed on (%w+) mind.", handler = function(p) targetSealed() end},
  {pattern = "^(%w+) appears confused for a moment.$", handler = function(p) hypnosisTick(p) end},
  {pattern = "^You snap your fingers in front of (%w+).$", handler = function(p) fingerSnapped() end},
  
  {pattern = "^You order your shadow to surround (%w+) in a black void.$", handler = function(p) enemyVoided() end},
  {pattern = "^The shadowy void around (%w+) weakens.$", handler = function(p) setWeakvoid(p) end},
  {pattern = "^The shadowy void around (%w+) disappears.$", handler = function(p) enemyUnvoided(p) end},
  {pattern = "^Your target is already surrounded by a void.$", handler = function(p) enemyAlreadyVoided() end},
  {pattern = "^You will the shadows to dissipate (%w+)'s hunger.$", handler = function(p) shadowBalance = false end},
  {pattern = "^You sprinkle some silvery powder over (%w+) and grin widely as (%w+) looks about with a look of slight bafflement on (%w+) face.$", handler = function(p) shadowBalance = false end},
  {pattern = "^Claws of pure shadow spread from your own, raking across (%w+).$", handler = function(p) shadowBalance = false end},
  {pattern = "^Sending your shadows towards (%w+), you will them to coat (%w+) body.$", handler = function(p) shadowBalance = false end},
  {pattern = "^You give (%w+) an utterly blank look.$", handler = function(p) shadowBalance = false end},
  {pattern = "^You have recovered shadow balance.$", handler = function(p) shadowBalance = true end},
  
  {pattern = "^(.*) signs: (.*)$", handler = function(p) signHandler(p) end},
  {pattern = "^You sign out: (.*)$", handler = function(p) mySign(p) end},
  
  {pattern = "^You rub some (%w+) on (.*) in your (%w+) hand.$", handler = function(p) envenomHandler(p) end},
  {pattern = "^You rub some (%w+) on (.*).$", handler = function(p) envenomHandler(p) end},
  {pattern = "^You secrete a layer of (%w+) onto (.*).$", handler = function(p) envenomHandler(p) end},
  {pattern = "^Being careful not to poison yourself, you wipe off all the venoms from (.*).$", handler = function(p) wipedHandler(p) end},
  {pattern = "^There are no venoms on that item at present.$", handler = function(p) alreadyWipedHandler() end},
  
  {pattern = "^Lunging in, you stick .* with .*", handler = function(p) syssinAI:dstabHandler() end},
  {pattern = "^You drive .* into (%w+) with a vicious stab.$", handler = function(p) syssinAI:dstabHandler() end},
  {pattern = "^You jab (%w+) with a .*$", handler = function(p) syssinAI:dstabHandler() end},
  {pattern = "^You prick (%w+) quickly with your dirk.$", handler = function(p) syssinAI:dstabHandler() end},
  {pattern = "^Deftly twirling the weapon in your hand, you jab (%w+) with it once more.$", handler = function(p) syssinAI:dstabHandler() end},
  {pattern = "^Stepping quickly out of the way, (%w+) dodges the attack.$", handler = function(p) syssinAI:dodgeHandler() end},
  {pattern = "^The attack rebounds back onto you!$", handler = function(p) syssinAI:reboundHandler() end},
  {pattern = "^As you pierce through %w+'s rebounding, you send the tip of your whip to scourge %w+ flesh.$", handler = function(p) syssinAI:flayHandler() end},
  
  {pattern = "^You feel the power of the venom (%w+) flowing through your veins.", handler = function(p) syssinAI:secreteHandler(p) end},
  {pattern = "^You sink your fangs into .*, (%w+) flowing into ... veins.", handler = function(p) syssinAI:biteHandler(p) end},
  {pattern = "^You purge every drop of venom from your bloodstream.", handler = function(p) syssinAI:purgeHandler() end},
  
  {pattern = "^You slip behind the prone body of (%w+) and with grim determination wrap your whip around (%w+) neck tightly.$", handler = function(p) garroteLockStart() end},
  {pattern = "^Your muscles straining, you struggle to keep your whip wrapped tightly around the neck of (%w+), as (%w+) thrashes wildly.$", handler = function(p) garroteLockTick() end},
  {pattern = "^(%w+)'s struggles grow weaker and weaker in strength, before (%w+) finally goes limp beneath your grip.$", handler = function(p) garroteLockKill() end},
  {pattern = "^You lose your grip on (%w+), and back away.$", handler = function(p) garroteLockFailed() end},

  {pattern = "^You don't see your target in that direction.$", handler = function(p) killLine() end},
}

function switchMagicUser()
  if not targetUsesMagic then
    targetUsesMagic = true
  else
    targetUsesMagic = false
  end
  ACSEcho("targetUsesMagic = " .. tostring(targetUsesMagic))
  show_prompt()
end

function switchUndead()
  if not targetIsUndead then
    targetIsUndead = true
  else
    targetIsUndead = false
  end
  ACSEcho("targetIsUndead = " .. tostring(targetIsUndead))
  show_prompt()
end

function switchEnemyCanFocus()
  if not enemyCanFocus then
    enemyCanFocus = true
  else
    enemyCanFocus = false
  end
  ACSEcho("enemyCanFocus = " .. tostring(enemyCanFocus))
  show_prompt()
end

function listStacks()
  echo("List of available stacks:")
  for k,v in pairs(stackList) do
    echo(k .. ":")
    str = "Venoms: "
    for i,b in pairs(v.venoms) do
      str = str .. v.venoms[i] .. "  "
    end
    echo("  -- " .. str)
    str = "Suggestions: "
    for i,b in pairs(v.suggestions) do
      str = str .. v.suggestions[i] .. "  "
    end
    echo("  -- " .. str)
    echo("")
  end
  show_prompt()
end

function selectStackHandler(i,p)
  goal = i:match(p)
  selectStack(goal)
end

function selectStack(goal)
  if stackList[goal] ~= nil then
    venomset = stackList[goal].venoms
    suggeststack = stackList[goal].suggestions
    if not enemyCanFocus then table.insert(venomset, 2, "aconite") end
    echo("Set goal to " .. goal)
    show_prompt()
  else
    echo("INVALID STACK")
    listStacks()
  end
end

function syssinAI:biteAliasHandler(i,p)
  local venom = i:match(p)
  syssinAI:executeBite(venom)
end

function syssinAI:delphiniumStab()
  doWield(dirk, tower)
  syssinAI:shadowSelect()
  syssinAI:hypnosisManager()
  envenomDirk("delphinium", "delphinium")
  dstab()
  syssinAI:executeHypnosis()
  doShadowSkill()
end

function garroteLockStart()
  healer = false
  echo("")
  ACSEcho(C.G .. "GARROTELOCK STARTED!!")
  ACSEcho(C.r .. "Healer off")
end

function garroteLockTick()
  setACSLabel(C.G .. "Choking " .. target .. "...")
end

function garroteLockFailed()
  healer = true
  echo("")
  ACSEcho(C.R .. "GARROTELOCK FAILED!")
  ACSEcho(C.R .. "GARROTELOCK FAILED!")
  ACSEcho(C.R .. "GARROTELOCK FAILED!")
end

function garroteLockKill()
  healer = true
end

function garrotelock()
  doWield(whip, tower)
  send("garrotelock " .. target)
end

function syssinAI:secreteHandler(p)
  secreted = mb.line:match(p)
  setACSLabel(C.g .. "Secreted " .. secreted .. ".")
  add_timer(4, function() if secreted ~= "" then send("purge") end end)
end

function syssinAI:biteHandler(p)
  v = mb.line:match(p)
  etrack:addAff(etrack:translate(etrack:venomConvert(v)))
  secreted = ""
end

function syssinAI:purgeHandler()
  secreted = ""
  setACSLabel("Purged venom.")
end

function envenomHandler(p)
  venom, weapon = mb.line:match(p)
  table.insert(currentlyEnvenomed, 1, venom)
  setACSLabel(C.g .. "Envenomed " .. C.r .. venom .. C.g .. " on " .. C.r .. weapon .. C.G .. ".")
end

function wipedHandler(p)
  weapon = mb.line:match(p)
  currentlyEnvenomed = {}
  setACSLabel("Wiped off venoms on " .. weapon)
end

function alreadyWipedHandler()
  currentlyEnvenomed = {}
  setACSLabel("No venoms on weapon.")
end

function executeAttack()
  syssinAI:venomSelect()
  syssinAI:shadowSelect()
  syssinAI:hypnosisManager()
  
  --reportCurrentAttacks()
  
  if needSeal then
    syssinAI:executeHypnosis()
    needSeal = false
  elseif not enemyRebounding and not enemyShielded then
    doWield(dirk, tower)
    envenomDirk(venom1, venom2)
    dstab()
    reportCurrentAttacks()
    syssinAI:executeHypnosis()
  elseif enemyShielded then
    doWield(whip, tower)
    flay("shield")
    syssinAI:executeHypnosis()
  elseif enemyRebounding then
    doWield(whip, tower)
    shadowAttack = "shadow sleight invasion " .. target
    send("envenom " .. whip .. " with " .. venom1)
    flay("rebounding")
    syssinAI:executeHypnosis()
  end
  doShadowSkill()
end

function syssinAI:executeBite(venom)
  syssinAI:shadowSelect()
  syssinAI:hypnosisManager()
  
  if enemyBiteProtected then
    flay("sileris")
  else
    send("purge")
    send("secrete " .. venom)
    send("bite " .. target)
  end
  syssinAI:executeHypnosis()
  doShadowSkill()
end

function garrote()
  syssinAI:shadowSelect()
  doWield(whip, tower)  
  send("garrote " .. target)
  doShadowSkill()
end

function flay(t)
  doWield(whip, tower)
  send("flay " .. target .. " " .. t)
  lastFlay = t
end

function dstab()
  send("dstab " .. target)
end

function syssinAI:hypnosisManager()
  if hState == HypnoState.UNHYP then
    startHypnosis()
    if #toSuggest == 0 then selectHypnosisStack() end
    add_timer(.5, function() syssinAI:executeHypnosis() end)
  end
end

function startHypnosis()
  send("hypnotise " .. target)
end

function syssinAI:executeHypnosis()
  if hState == HypnoState.HYP then
    nextSuggestion()
  end
end

function selectHypnosisStack()
  for i,v in pairs(suggeststack) do
    addSuggestion(v)
  end
end

function reportCurrentAttacks()
  echo("Venom1: " .. venom1)
  echo("Venom2: " .. venom2)
  echo("Shadow: " .. shadowAttack)
  if #toSuggest > 0 then echo("Suggest: " .. toSuggest[1]) end
end

function enemyAlreadyVoided()
  void = true
  syssinAI:shadowSelect()
  doShadowSkill()
end

function doShadowSkill()
  if shadowAttack ~= "" and shadowBalance then send(shadowAttack) end
end

function startHypno()
  send("hypnotise " .. target)
end

function signHandler(p)
  person, message = mb.line:match(p)
  replace(C.r .. person .. " signs: " .. C.x .. message)
end

function mySign(p)
  message = mb.line:match(p)
  replace(C.r .. "You sign: " .. C.x .. message)
end

function enemyVoided()
  void = true
  setACSLabel(C.G .. target .. " +VOID")
end

function setWeakvoid(p)
  person = mb.line:match(p)
  if isTarget(person) then
    if voidCheck() then etrack:addAff(enemyLastCured) end
    setACSLabel(C.r .. person .. " has weakvoid.")
  end
end

function enemyUnvoided(p)
  person = mb.line:match(p)
  if isTarget(person) then
    void = false
    if voidCheck() then etrack:addAff(enemyLastCured) end
    setACSLabel(C.R .. person .. " -VOID.")
  end
end

function voidCheck()
  for k,v in pairs(enemyLastCure) do
    if v == enemyLastCured then return true end
  end
  return false
end

function usedShrug()
  shrugBalance = false
  setACSLabel(C.R .. "Shrug used!")
end

function shrugReturned()
  shrugBalance = true
  setACSLabel(C.G .. "Shrugging available!")
end

function envenomDirk(v1, v2)
  doEnvenom(v1)
  doEnvenom(v2)
end

function doEnvenom(venom)
  if targetIsUndead and venom == "kalmia" then venom = "strophanthus" end
  if targetUsesMagic and venom == "xentio" then venom = "colocasia" end
  send("envenom " .. dirk .. " with " .. venom)
end

function hypnosisFailed()
  hState = HypnoState.UNHYP
  setACSLabel(C.R .. "HYPNOSIS FAILED!")
  suggested = {}
end

function targetHypnotised()
  hState = HypnoState.HYP
  setACSLabel(C.G .. "HYPNOSIS READY!")
end

function doSuggest(suggestion)
  lastSuggestion = suggestion
  send("suggest " .. target .. " " .. lastSuggestion)
  suggesting = true
  add_timer(2, function() suggesting = false end)
end

function suggestionGiven()
  setACSLabel("Suggested " .. lastSuggestion)
  table.insert(suggested, lastSuggestion)
  if #toSuggest > 0 then
    table.remove(toSuggest, 1)
    if #toSuggest == 0 then needSeal = true end
  end
end

function nextSuggestion()
  if #toSuggest > 0 then
    doSuggest(toSuggest[1])
  elseif hState == HypnoState.HYP then
    send("seal " .. target .. " " .. sealTime)
    send("snap " .. target)
  else
    ACSEcho("Not set up for hypnosis!  Add some suggestions.")
    show_prompt()
  end
end

function targetSealed()
  hState = HypnoState.SEALED
end

function hypnosisTick(p)
  person = mb.line:match(p)
  if isTarget(person) and #suggested > 0 then
    aff = suggested[1]
    setACSLabel(C.g .. person .. C.G .. " hypnosis tick of " .. aff)
    if not aff:match("action") and not aff:match("bulimia") then etrack:addAff(etrack:translate(aff)) end
    table.remove(suggested, 1)
    if #suggested == 0 then
      hState = HypnoState.UNHYP
      ACSEcho(C.G .. "Done with hypnosis stack!  Start again!")
    end
  end
end

function addSuggestion(suggestion)
  table.insert(toSuggest, suggestion)
  ACSEcho("Added " .. suggestion .. " to suggestions.")
end

function fingerSnapped()
  hState = HypnoState.SNAPPED
end

function syssinAI:flayHandler()
  if #currentlyEnvenomed > 0 then 
    lastVenom = currentlyEnvenomed[1]
    table.remove(currentlyEnvenomed, 1)
    setACSLabel(C.r .. "FLAYED AND GIVEN: " .. C.G .. lastVenom)
    etrack:addAff(
      etrack:translate(
        etrack:venomConvert(lastVenom)
      )
    )
  end
end

function syssinAI:dstabHandler()
  if #currentlyEnvenomed > 0 then 
    lastVenom = currentlyEnvenomed[1]
    table.remove(currentlyEnvenomed, 1)
    setACSLabel(C.r .. "DSTAB: " .. C.G .. lastVenom)
    etrack:addAff(
      etrack:translate(
        etrack:venomConvert(lastVenom)
      )
    )
  end
end

function syssinAI:dodgeHandler()
  setACSLabel(C.R .. "ATTACK DODGED!")
  etrack:removeAff(
    etrack:translate(
      etrack:venomConvert(lastVenom)
    )
  )
end

function syssinAI:reboundHandler()
  setACSLabel(C.R .. "ATTACK REBOUNDED! ATTACK REBOUNDED! ATTACK REBOUNDED!")
  etrack:removeAff(
    etrack:translate(
      etrack:venomConvert(lastVenom)
    )
  )
  enemyRebounding = true
end

function syssinAI:venomSelect()
  if #venomset == 0 then selectStack("kelp") end
  for _, cur_venom in ipairs (venomset) do
    if not etrack:hasAff(etrack:venomConvert(cur_venom)) then
      venom1 = cur_venom
      break
    end
  end
  for _, cur_venom in ipairs (venomset) do
    if not etrack:hasAff(etrack:venomConvert(cur_venom)) and venom1 ~= cur_venom then
      venom2 = cur_venom
      break
    end
  end
end

function syssinAI:shadowSelect()
  if not shadowBalance then shadowAttack = "" else
    if not void then
      shadowAttack = "shadow sleight void " .. target
    else
      if generalTarget:match("herb") then
        shadowAttack = "shadow sleight dissipate " .. target
      elseif generalTarget:match("salve") then
        shadowAttack = "shadow sleight abrasion " .. target
      end
    end
  end
end

function syssinAI:snipe()
  local directions = {"nw", "n", "ne", "w", "e", "sw", "s", "se", "in", "out", "u", "d"}
  doWield(bow)
  for _, dir in ipairs(directions) do
    send("snipe " .. target .. " " .. dir)
  end
end

-------------------
-- VENOM MILKING --
-------------------
possibleVenoms = {"Aconite","Araceae","Colocasia","Curare","Darkshade","Delphinium","Digitalis","Epseth","Epteth","Euphorbia","Eurypteria","Gecko","Kalmia","Larkspur","Monkshood","Oculus","Prefarar","Selarnia","Slike","Strophanthus","Vernalius","Voyria","Xentio"}

function doMilk(venom)
  send("secrete " .. venom)
  send("milk venom into empty")
end

function addToMilk(venom)
  addAction("doMilk('" .. venom .. "')", true)
  echo("Added " .. venom .. " to be milked.")
end

function fullSetOfVenoms(numToMake)
  for k,v in ipairs(possibleVenoms) do
    for i = 1,numToMake do
      addToMilk(v)
    end
  end
end

