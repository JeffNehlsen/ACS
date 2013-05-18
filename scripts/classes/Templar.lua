echo("Templar loaded. Forward, unto Dawn!")

Templar = {
    canPenance = true,
    enemyImpaled = false,
    offense = {
        type = "MACE",
        types = {MACE = "MACE", AFFLICTION = "AFFLICTION"}
    }
}

-- TODO: Finish converting the aliases to Templar ones.
Templar.aliases = {
  -- {pattern = "^bat$", handler = function(i,p) hBatter() end},


  -- {pattern = "^bf$", handler = function(i,p) bruteforce() end},
  -- {pattern = "^hr$", handler = function(i,p) hRage() end},
  -- {pattern = "^cha$", handler = function(i,p) setCharge() end},

  -- {pattern = "^dsl$", handler = function(i,p) dsl() end},
    {pattern = "^attack$", handler = function(i,p) Templar:toggleAutoattack() end},

    {pattern = "^blessings (%w+)$", handler = function(i,p) Templar:blessingHandler(i,p) end}
}

Templar.triggers = {
    -- Auras
    {pattern = "You focus momentarily as you envelop yourself in the righteous aura of (%w+).", handler = function(p) Templar:setAura(p) end},
    {pattern = "You focus and the aura of %w+ flickers and fades away.", handler = function(p) currentAura = "" end},
    {pattern = "Your aura flickers and fades as you lack the mana to maintain it.", handler = function(p) currentAura = "" end},
    {pattern = "You are protected by an aura of (%w+).", handler = function(p) Templar:auraDefHandler(p) end},
    {pattern = "You are already benefiting from an aura of (%w+).", handler = function(p) Templar:setAura(p) end},

    -- Blessings
    {pattern = "You focus on your (%w+) aura and draw its power into you, focusing it onto your body.", handler = function(p) Templar:addedBlessing(p) end},
    {pattern = "You focus and cleanse yourself of the (%w+) blessing.", handler = function(p) Templar:removedBlessing(p) end},
    {pattern = "You cleanse yourself of any active blessings.", handler = function(p) Templar.currentBlessings = {} end},
    {pattern = "You are already benefiting from the (%w+) blessing.", handler = function(p) Templar:addedBlessing(p) end},
    {pattern = {"You are benefiting from the blessings of (%w+) and (%w+) and (%w+).",
                "You are benefiting from the blessings of (%w+) and (%w+).",
                "You are benefiting from the blessings of (%w+)."}, handler = function(p) Templar:blessingDefHandler(p) end},

    {pattern = "Focusing your mind, you utter a quiet prayer and imbue (.*) with (%w+).", handler = function(p) Templar:empowerHandler(p) end},

    -- Impale/Lunge to Disembowel
    {pattern = "You draw your .* back and plunge it deep into the body of (%w+) impaling %w+.", handler = function(p) Templar:impaleHandler(p) end},
    {pattern = "With a cry of delight you skewer (%w+) on your .*, who writhes and screams as the weapon is driven deep into %w+ flesh.", handler = function(p) Templar:impaleHandler(p) end},
    
    -- Unimpaled/disemboweled
    {pattern = "With a look of agony on his face, (%w+) manages to writhe %w+ free of the weapon which impaled %w+.", handler = function(p) Templar:unimpaledHandler(p) end},
    {pattern = "(%w+) has writhed free of %w+ impalement.", handler = function(p) Templar:unimpaledHandler(p) end},
    {pattern = "With a vicious snarl you carve a merciless swathe through the steaming guts of %w+, who oyagurgles and chokes as you withdraw your dripping .*, its blade glistening with gore.", handler = function(p) Templar:disemboweledHandler(p) end},


    -- Maingauche
    {pattern = "^With a swift movement you dart in toward (%w+) and stab %w+ with .*%.$", handler = function(p) Templar:maingaucheHandler(p) end},
    -- Cripple: crippled/crippled_body
    -- As a Basilican mace strikes, a surge of energy cascades along it, striking yourself's legs.
    -- Gives crippled_body, cures crippled
    -- As a Basilican mace strikes, a surge of energy cascades along it, striking yourself's body.

    -- Disrupt: mental_disruption/physical_disruption
    -- A flash of energy cascades down a Basilican mace, disrupting yourself's equilibrium.
    -- A flash of energy cascades down a Basilican mace, disrupting yourself's balance.

    -- Trauma: Extra 4.99% limb damage
    -- As a Basilican mace strikes yourself's left leg, it sends a pulse of destructive power into it.

    -- Burst: Hit once to do delayed damage (second message). Second attack in a row will do AoE, but deal no damage to the target.
    -- As a Basilican mace strikes Kaed, you feel its stored power dissipating into him.
    -- You feel a faint tingling feeling behind your eyes as the energy planted by a Basilican mace shatters yourself's mind.


    -- Blaze + rebounding.  Blaze blocked the hit on the left leg.  Going to have to capture the reobunding strip and reduce the enemy leg damage.
    -- You brutally batter Alistaire's left leg with a Basilican mace.
    -- White flames suddenly encase a Basilican mace as your attack strikes Alistaire's rebounding aura, 
    -- burning the aura away.
    -- Numbing force behind the blow, you pound Alistaire's right leg with a Basilican mace.
    -- As a Basilican mace strikes Alistaire, you feel its stored power dissipating into him.
    -- Balance Used: 2.36 seconds


    {pattern = "Your strikes cause (%w+) bruising on (%w+)'s (.*).", handler = function(p) Templar:enemyBruisedHandler(p) end},
    {pattern = "Your strike ruptures %w+ bruises and blood begins to flow freely from the wound.", handler = function(p) Templar:enemyRuptured(p) end},
    


    {pattern = "^You spy an opening in (%w+)'s defenses and quickly assume a steady", handler = function(p) Templar:penanceHandler(p) end},
    {pattern = "You are once again able to impose Penance upon other people.", handler = function(p) Templar:penanceReturnedHandler() end},
    {pattern = "You are not yet able to impose a Penance on another person.", handler = function(p) Templar:unableToPenanceHandler() end},

    {pattern = {"You will now target attacks with your %w+ arm wherever you see an opening.",
                "You will now target the .* of your opponent with your %w+ arm."}, handler = function(p) Templar:targetHandler() end},
}

-- TODO: Gather attack lines for the weapons
-- TODO: Figure out how empowerments/releases are going to work
-- Double Raze: empower blaze/razeslash

function Templar:toggleAutoattack()
    if class.autoattack == nil then class.autoattack = false end

    class.autoattack = not class.autoattack

    if class.autoattack then
        echo(C.b .. "[" .. C.g .. "AUTO ATTACK ON" .. C.b .. "]" .. C.x)
    else
        echo(C.b .. "[" .. C.r .. "AUTO ATTACK OFF" .. C.b .. "]" .. C.x)
    end

    show_prompt()
end

function Templar:targetHandler()
    if class.autoattack then
        killLine()
    end
end

function Templar:enemyBruisedHandler(p)
    local bruise, person, limb = mb.line:match(p)
    limb = limb:gsub(" ", "_")
    if bruise == "light" then
        etrack:addAff(limb .. "_bruised")
    else
        etrack:addAff(limb .. "_bruised_" .. bruise)
    end
end

function Templar:enemyRuptured(p)
    etrack:addAff("ruptured")
end

function Templar:empower(left, right)
    debug:print("Templar", "empowering with " .. left .. " and " .. right)
    send("cleanse left")
    send("cleanse right")

    -- Set up for maingauche
    send("empower right with combustion")
    send("empower right with burst")

    -- Empower the weapons with the target
    send("empower left with " .. left)
    send("empower right with " .. right)
end

function Templar:getCharges()
    local lcharge = prompt.leftCharge or 0
    local rcharge = prompt.rightCharge or 0
    return {left = lcharge, right = rcharge}
end

function Templar:iceblast()
    local charges = self:getCharges()
    if charges.left > 100 then
        Templar:release("left", "iceblast")
    end

    if charges.right > 100 then
        Templar:release("right", "iceblast")
    end
end

function Templar:release(side, attack)
    send("blade release " .. side .. " " .. attack .. " " .. target)
end

function Templar:canAttack()
    return balances:check({"balance", "equilibrium"}) and not hasAffliction("paralysis") and 
           not hasAffliction("left_arm_broken") and not hasAffliction("right_arm_broken") and
           not prompt.prone and not stunned and not unconscious
end

function Templar:attack()
    if not self:canAttack() then
        debug:print("Templar", "Cannot attack. Returning")
        return
    end

    if self.wantedAura == "" or #self.wantedBlessings == 0 then
        self:setWantedBlessings(self.offense.type)
    end

    if self:checkAura() then
        return
    end

    if self:checkBlessings() then
        return
    end

    if enemyShielded and enemyRebounding then
        -- Double raze
        Templar:doubleRaze()
        balances:take("balance")
        return
    end

    if enemyShielded or enemyRebounding then
        -- Single raze
        send("raze " .. target)
        balances:take("balance")
        return
    end

    if self.offense.type == self.offense.types.MACE then
        self:maceAttack()
    end
end

function Templar:maceAttack()
    local limb_priority = {"torso", "head", "left leg", "right leg", "left arm", "right arm"}
    local _limb_priority = {"torso", "head", "left_leg", "right_leg", "left_arm", "right_arm"}
    local non_critical_bruises = {"_bruised_moderate", "_bruised"}

    -- If the enemy is ruptured, then hit them with hemo!
    if etrack:hasAff("ruptured") then
        self:penance()
        self:iceblast()
        self:afterRuptureAttack()
        return
    end

    -- Attempt to rupture critically bruised areas
    for i, limb in ipairs(_limb_priority) do
        if etrack:hasAff(limb .. "_bruised_critical") then
            self:penance()
            self:rupture(limb_priority[i])
            return
        end
    end

    -- Attempt to get a critical bruise by hitting non-critically bruised areas
    for _, aff in ipairs(non_critical_bruises) do
        for i, limb in ipairs(_limb_priority) do
            if etrack:hasAff(limb .. aff) then
                self:attackLimbOrArmsWithMaces(limb_priority[i])
                return
            end
        end
    end

    for i, limb in ipairs(limb_priority) do
        if etrack:getParry() ~= limb then
            doWield("mace1", "mace2")
            self:empower("trauma", "trauma")
            self:target(limb, limb)
            self:dsk()
            balances:take("balance")
            return
        end
    end

    debug:print("Templar", "After loops")
end

function Templar:afterRuptureAttack()
    local charges = self:getCharges()
    if hasSkill("ice_breath") and charges.left > 100 and charges.right > 100 then
        doWield("scimitar", "mace2")
        self:empower("hemorrhage", "hemorrhage")
        send("freeze " .. target)
        send("rend " .. target)
    else
        self:empower("hemorrhage", "hemorrhage")
        self:target("nothing", "nothing")
        self:dsk()
    end
    etrack:removeAff("ruptured")
end

function Templar:attackLimbOrArmsWithMaces(limb)
    debug:print("Templar", "Attempting to attack " .. limb)
    doWield("mace1", "mace2")
    if etrack:getParry() == limb then
        self:target("left arm", "right arm")
    else
        self:target(limb, limb)
    end

    self:empower("trauma", "trauma")
    self:dsk()
    balances:take("balance")
end

function Templar:target(limb1, limb2)
    send("target " .. limb1 .. " with left")
    send("target " .. limb2 .. " with right")
end

function Templar:doubleRaze()
    send("empower right with blaze")
    send("razestrike " .. target)
end

function Templar:penance()
    if self.canPenance then
        send("penance " .. target)
    end
end

function Templar:penanceHandler(p)
    local person = mb.line:match(p)
    Templar.canPenance = false
    ACSLabel(C.R .. "Penanced " .. person)
end

function Templar:penanceReturnedHandler()
    Templar.canPenance = true
    ACSLabel(C.G .. "Penance balance returned!");
end

function Templar:unableToPenanceHandler()
    Templar.canPenance = false
    ACSLabel(C.R .. "Unable to penance!")
end

function Templar:maingaucheHandler(p)
    local person = mb.line:match(p)

    ACSLabel(C.R .. "MainGauche'd " .. person)
end

function Templar:impaleHandler(p)
    local person = mb.line:match(p)
    Templar.enemyImpaled = true
    addTemp("You have recovered balance on all limbs.", function() send("disembowel " .. person) end)
end

function Templar:unimpaledHandler(p)
    local person = mb.line:match(p)
    if isTarget(person) then
        Templar.enemyImpaled = false
    end
end

function Templar:disemboweledHandler(p)
    Templar.enemyImpaled(false);
    -- Trigger a double hemorrhage hit?
end

function Templar:empowerHandler(p)
    local weapon, empowerment = mb.line:match(p)
    ACSLabel(C.r .. "Empowered " .. weapon .. " with " .. C.G .. empowerment)
end

-- Righteousness: Attacks
function Templar:wither() 
    send("aura withering " .. target)
    balances:take("equilibrium")
end

-- Bladefire

-- Battlefury: Attacks

function Templar:strike()
    send("strike " .. target)
    balances:take("balance")
end

function Templar:raze()
    send("raze " .. target)
    balances:take("balance")
end

function Templar:rsl()
    send("razestrike " .. target)
    balances:take("balance")
end

function Templar:block(direction)
    send("block " .. direction)
end

function Templar:dsk(tar)
    if leftHand == rightHand then
        send("dsw " .. target)
    else
        send("dsk " .. target)
    end
    balances:take("balance")
end

function Templar:impale()
    send("impale " .. target)
    balances:take("balance")
end

function Templar:zeal()
    send("zeal " .. target)
    balances:take("balance")
end

function Templar:lunge()
    send("lunge " .. target)
    balances:take("balance")
end

function Templar:rupture(limb)
    debug:print("Templar", "Sending: Rupture: " .. limb)
    send("rupture " .. target .. " " .. limb)
    balances:take("balance")
end

function Templar:tempest()
    send("tempest")
    balances:take("balance")
end

function Templar:disembowel()
    send("disembowel " .. target)
    balances:take("balance")
end

function Templar:charge()
    send("charge " .. target)
    balances:take("balance")
end

function Templar:rend()
    send("rend " .. target)
    balances:take("balance")
end

function Templar:cleave()
    send ("cleave" .. target)
    balances:take("balance")
end

--------------------
-- AURA/BLESSINGS --
--------------------
Templar.currentAura = ""
Templar.currentBlessings = {}
Templar.wantedAura = ""
Templar.wantedBlessings = {}

Templar.blessings = {
    bashing = {
        aura = "protection",
        blessings = {"healing", "meditation", "redemption"}
    },
    steamroller = {
        aura = "purity",
        blessings = {"protection", "meditation", "redemption"}
    },


--for damage I do purity aura, pestilence blessing, healing blessing, and either protection or meditation

-- [5/10/2013 6:15:57 PM] Saybre: the idea for scimitar was to have spellbane as the AURA, and purity/pestilence/cleansing blessings
-- [5/10/2013 6:16:59 PM] Saybre: heck, I think I might add spellbane to my offense blessings anyway
    MACE = {
        aura = "purity",
        blessings = {"spellbane", "healing", "meditation"}
    }
}

function Templar:auraDefHandler(p)
    local aura = mb.line:match(p)
    self.currentAura = string.lower(aura)
end

function Templar:blessingDefHandler(p)
    local b1, b2, b3 = mb.line:match(p)

    self.currentBlessings = {}
    table.insert(self.currentBlessings, b1)

    if b2 then
        table.insert(self.currentBlessings, b2)
    end

    if b3 then
        table.insert(self.currentBlessings, b3)
    end
end

function Templar:blessingHandler(i,p)
    local set = i:match(p)
    self:setBlessings(set)
end

function Templar:checkAura()
    if self.wantedAura ~= self.currentAura then 
        send("aura off")
        send("aura " .. self.wantedAura)
        balances:take("equilibrium")
        return true
    end

    return false
end

function Templar:checkBlessings()
    debug:print("Blessings", "checkBlessings()");
    for _, blessing in ipairs(Templar.currentBlessings) do
        debug:print("Blessings", "checking " .. blessing);
        if not stringInTable(blessing, Templar.wantedBlessings) then
            send("aura off blessing " .. blessing)
        end
    end

    for _, blessing in ipairs(Templar.wantedBlessings) do
        debug:print("Blessings", "wantedBlessing check: "  .. blessing)
        if not stringInTable(blessing, Templar.currentBlessings) then
            send("aura blessing " .. blessing)
            balances:take("equilibrium")
            return true
        end
    end

    return false
end

function Templar:setWantedBlessings(type)
    debug:print("Templar", "setWantedBlessings(" .. type .. ")");
    self.wantedAura = self.blessings[type].aura
    self.wantedBlessings = self.blessings[type].blessings
end

function Templar:setBlessings(type)
    if not Templar.blessings[type] then
        ACSEcho("Blessing set " .. type .. " not found.")
        return
    end

    self.wantedAura = self.blessings[type].aura
    self.wantedBlessings = self.blessings[type].blessings

    if self.currentAura ~= "" then
        actions:add(function() send("aura off " .. self.currentAura) end)
    end

    if #self.currentBlessings > 0 then
        actions:add(function() send("aura off blessing") end)
    end

    actions:add(function() send("aura " .. self.blessings[type].aura) end, baleq, {"equilibrium"})

    for _, blessing in ipairs(self.blessings[type].blessings) do
        actions:add(function() send("aura blessing " .. blessing) end, baleq, {"equilibrium"})
    end
end

function Templar:setAura(p)
    Templar.currentAura = mb.line:match(p)
    Templar.currentAura = string.lower(Templar.currentAura)
    ACSLabel("AURA: " .. Templar.currentAura)
end

function Templar:addedBlessing(p)
    local blessing = mb.line:match(p)
    ACSLabel("Added Blessing: " .. blessing)
    table.insert(Templar.currentBlessings, blessing)
end

function Templar:removedBlessing(p)
    local blessing = mb.line:match(p)
    for i, cBlessing in ipairs(self.currentBlessings) do
        if blessing == cBlessing then
            ACSLabel("Removed Blessing: " .. blessing)
            table.remove(self.currentBlessings, i)
        end
    end
end

-- Setup the class now that it is defnied
ACS:addModule(Templar, "Templar")

class = {
    bashAttack = function()
        send("wield mace")
        send("wield mace")
        send("cleanse left")
        send("cleanse right")
        send("empower left with sacrifice")
        send("empower right with sacrifice")
        send("dsk " .. selectedTarget)
    end,

    autoattack = false,
    attack = function()
        if class.autoattack then
            Templar:attack()
        end
    end
}