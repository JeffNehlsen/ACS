echo("Sentinel file loaded. Move like water, cut like steel.")

-- Sentinel Overlay Combos
------------------------------------------------------
-- ataractis - Vernalius/Gecko      - indifference
-- bensol    - Larkspur/Xentio      - addiction
-- cinchona  - Euphorbia/Larkspur   - vertigo
-- domoin    - Euphorbia/Xentio     - amnesia
-- emisis    - Darkshade/Aconite    - paranoia
-- fpinine   - Digitalis/Colocasia  - agoraphobia
-- fathyrus  - Vernalius/Delphinium - lethargy
-- hystidine - Kalmia/Curare        - claustrophobia
-- ionaziac  - Curare/Xentio        - epilepsy
-- lithium   - Delphinium/Monkshood - pacifism
-- mesqaline - Oleander/Larkspur    - hallucinations
-- muscaria  - Monkshood/Eurypteria - berserking
-- nyoclosia - Xentio/Eurypteria    - impatience
-- peirates  - Eurypteria/Prefarar  - masochism
-- quinidia  - Slike/Darkshade      - haemophilia
-- sepofan   - Voyria/Loki          - hypochondria
-- sicari    - Colocasia/Oleander   - loneliness
-- thallium  - Aconite/Xentio       - dementia
-- uranict   - Prefarar/Eurypteria  - generosity
-- zepedic   - Delphinium/Prefarar  - peace
------------------------------------------------------

targetIsUndead = false
targetCanFocus = true

sentinel = {}
venomStack = {}

venom1 = ""
venom2 = ""

overlays = {
  ataractis = {venom1 = "vernalius", venom2 = "gecko"}, -- indifference
  bensol    = {venom1 = "karkspur", venom2 = "xentio"}, -- addiction
  cinchona  = {venom1 = "euphorbia", venom2 = "larkspur"}, -- vertigo
  domoin    = {venom1 = "euphorbia", venom2 = "xentio"}, -- amnesia
  emisis    = {venom1 = "darkshade", venom2 = "aconite"}, -- paranoia
  fpinine   = {venom1 = "digitalis", venom2 = "colocasia"}, -- agoraphobia
  fathyrus  = {venom1 = "vernalius", venom2 = "delphinium"}, -- lethargy
  hystidine = {venom1 = "kalmia", venom2 = "curare"}, -- claustrophobia
  ionaziac  = {venom1 = "curare", venom2 = "xentio"}, -- epilepsy
  lithium   = {venom1 = "delphinium", venom2 = "monkshood"}, -- pacifism
  mesqaline = {venom1 = "oleander", venom2 = "larkspur"}, -- hallucinations
  muscaria  = {venom1 = "monkshood", venom2 = "eurypteria"}, -- berserking
  nyoclosia = {venom1 = "xentio", venom2 = "eurypteria"}, -- impatience
  peirates  = {venom1 = "eurypteria", venom2 = "prefarar"}, -- masochism
  quinidia  = {venom1 = "slike", venom2 = "darkshade"}, -- haemophilia
  sepofan   = {venom1 = "voyria", venom2 = "loki"}, -- hypochondria
  sicari    = {venom1 = "colocasia", venom2 = "oleander"}, -- loneliness
  thallium  = {venom1 = "aconite", venom2 = "xentio"}, -- dementia
  uranict   = {venom1 = "prefarar", venom2 = "eurypteria"}, -- generosity
  zepedic   = {venom1 = "delphinium", venom2 = "prefarar"} -- peace
}

currentlyEnvenomed = {}

ents = {"fox", "lemming", "raven", "badger", "butterfly", "wolf"}

triggers.sentinel = {
  {pattern = "^The forests have already blessed you with the companionship", handler = function(p) doBalancedAction() end},
  {pattern = "^Only when you are within the forest will they respond to your call.", handler = function(p) doBalancedAction() end},
  {pattern = "^Your animals are all camouflaged already!$", handler = function(p) killLine() end},
  
  {pattern = "^You quickly add a thin layer of (%w+) to (.*).$", handler = function(p) envenomHandler(p) end},
  {pattern = "^You quickly add a trace of the venom (%w+) to (.*), mixing it with a small amount of (%w+) for added effect.$", handler = function(p) overlayHandler(p) end},
  {pattern = "^Being careful not to poison yourself, you wipe off the venoms from both blades of", handler = function(p) wipeHandler() end},
  {pattern = "^There are no venoms on that item at present.", handler = function(p) wipeHandler() end},
  
  {pattern = "^You step in to strike (%w+) with your dhurive.$", handler = function(p) sentinel:stabHandler() end},
  {pattern = "^As soon as you're in the right position, you quickly stab your blade into (%w+).$", handler = function(p) sentinel:stabHandler() end},
}

aliases.sentinel = {
  -- Pet stuff
  {pattern = "^summ$", handler = function(i,p) summonAnimals() end},
  {pattern = "^fol$", handler = function(i,p) orderFollowMe() end},
  {pattern = "^att$", handler = function(i,p) orderKill() end},
  {pattern = "^pass$", handler = function(i,p) orderPassive() end},
  {pattern = "^ret$", handler = function(i,p) send("call animals") end},
  
  {pattern = "^stack$", handler = function(i,p) stack = i:match(p) listStacks() end},
  {pattern = "^stack (%w+)$", handler = function(i,p) stack = i:match(p) sentinel:selectStack(stack) end},
}

stackList = {
  ginseng = {"curare", "darkshade", "hepafarin", "euphorbia", "xentio", "colocasia", "nyoclosia", "kalmia", "gecko", "slike"}, 
  kelp = {"curare", "xentio", "colocasia", "nyoclosia", "kalmia", "gecko", "slike"}, 
}

function sentinel:stabHandler()
  if #currentlyEnvenomed > 0 then 
    lastVenom = currentlyEnvenomed[1]
    table.remove(currentlyEnvenomed, 1)
    setACSLabel(C.r .. "Attack: " .. C.G .. lastVenom)
    etrack:addAff(etrack:translate(etrack:venomConvert(lastVenom)))
  end
end

function listStacks()
  echo("List of available stacks:")
  for k,v in pairs(stackList) do
    echo(k .. ":")
    str = "Venoms: "
    for i,b in pairs(v) do
      str = str .. b .. "  "
    end
    echo("  -- " .. str)
    echo("")
  end
  show_prompt()
end

function sentinel:attack()
  sentinel:venomSelect()
  
  doWield(dhurive)
  if enemyShielded and enemyRebounding then
    send("dhuriv dualraze " .. target)
  elseif enemyShielded or enemyRebounding then
    sentinel:envenom(venom1)
    sentinel:combo("splice", "stab")
  else
    sentinel:envenom(venom1)
    sentinel:envenom(venom2)
    sentinel:combo("slash", "stab")
  end
end

function sentinel:selectStack(goal)
  if goal == nil or goal == "" or stackList[goal] == nil then
    listStacks()
  else
    venomStack = {}
    for i,v in ipairs(stackList[goal]) do table.insert(venomStack, stackList[goal][i]) end
    venomStack = stackList[goal]
    ACSEcho("Stack set to " .. goal)
  end
  
  for i,v in ipairs(venomStack) do
    if v == "kalmia" and targetIsUndead then venomStack[i] = "strophanthus" end
    if v == "nyoclosia" and not targetCanFocus then table.remove(venomStack, i) end
  end
end

function overlayHandler(pattern)
  v1, _, v2 = mb.line:match(pattern)
  for k,v in pairs(overlays) do
    if v1:match(v.venom1) and v2:match(v.venom2) then
      table.insert(currentlyEnvenomed, 1, k)
      setACSLabel(C.g .. "Envenomed " .. C.r .. k .. C.g .. " on " .. C.r .. dhurive .. C.G .. ".")
    end
  end
end

function envenomHandler(pattern)
  venom = mb.line:match(pattern)
  table.insert(currentlyEnvenomed, 1, venom)
  setACSLabel(C.g .. "Envenomed " .. C.r .. venom .. C.g .. " on " .. C.r .. dhurive .. C.G .. ".")
end

function wipeHandler()
  currentlyEnvenomed = {}
  setACSLabel("Wiped off venoms on dhurive.")
end

function sentinel:envenom(venom)
  for k,v in pairs(overlays) do
    if k:match(venom) then
      send("envenom " .. dhurive .. " overlay " .. v.venom1 .. " with " .. v.venom2) 
      return
    end
  end
  send("envenom " .. dhurive .. " with " .. venom)
end

function sentinel:combo(a1, a2)
  --doWield(dhurive)
  send("dhuriv combo " .. target.. " " .. a1 .. " " .. a2)
end

function sentinel:venomSelect()
  if #venomStack == 0 then sentinel:selectStack("kelp") end
  for _, cur_venom in ipairs (venomStack) do
    if not etrack:hasAff(etrack:venomConvert(cur_venom)) then
      --if (not enemyaffs[enemyinfo:convert(cur_venom)]) then
      venom1 = cur_venom
      break
    end
  end
  for _, cur_venom in ipairs (venomStack) do
    if not etrack:hasAff(etrack:venomConvert(cur_venom)) and venom1 ~= cur_venom then
      venom2 = cur_venom
      break
    end
  end
 --echo("Left: " .. venom1 .. " -- " .. etrack:venomConvert(venom1) .. "\nRight: " .. venom2 .. " -- " .. etrack:venomConvert(venom2))
end

-- ANIMAL MANAGEMENT
function summonAnimals()
  for i,v in ipairs(ents) do addAction("send('summon " .. v .. "')", true) end
  addAction("send('camouflage')", true)
  ACSEcho("Summoning animals!")
  show_prompt()
end

function orderFollowMe()
  for i,v in ipairs(ents) do send("order " .. v .. " follow me") end
end

function orderFollowTarget()
  for i,v in ipairs(ents) do send("order " .. v .. " follow " .. target) end
end

function orderKill()
  for i,v in ipairs(ents) do send("order " .. v .. " kill " .. target) end
  orderFollowTarget()
end

function orderPassive()
  orderFollowMe()
  send("order entourage passive")
end