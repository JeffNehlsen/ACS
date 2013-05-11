echo("Templar loaded. Forward, unto Dawn!")

Templar = {
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

    {pattern = "^blessings (%w+)$", handler = function(i,p) Templar:blessingHandler(i,p) end}
}

Templar.triggers = {
    {pattern = "You focus momentarily as you envelop yourself in the righteous aura of (%w+).", handler = function(p) Templar:setAura(p) end},
    {pattern = "You focus and the aura of %w+ flickers and fades away.", handler = function(p) currentAura = "" end},
    {pattern = "Your aura flickers and fades as you lack the mana to maintain it.", handler = function(p) currentAura = "" end},

    {pattern = "You focus on your (%w+) aura and draw its power into you, focusing it onto your body.", handler = function(p) Templar:addedBlessing(p) end},
    {pattern = "You focus and cleanse yourself of the (%w+) blessing.", handler = function(p) Templar:removedBlessing(p) end},
    {pattern = "You cleanse yourself of any active blessings.", handler = function(p) Templar.currentBlessings = {} end},

    {pattern = "You are already benefiting from an aura of (%w+).", handler = function(p) Templar:setAura(p) end},
    {pattern = "You are already benefiting from the (%w+) blessing.", handler = function(p) Templar:addedBlessing(p) end},

    {pattern = "Focusing your mind, you utter a quiet prayer and imbue (.*) with (%w+).", handler = function(p) Templar:empowerHandler(p) end},

    -- Impale/Lunge to Disembowel
    {pattern = "You draw your .* back and plunge it deep into the body of (%w+) impaling %w+.", handler = function(p) Templar:impaleHandler(p) end},
    {pattern = "With a cry of delight you skewer (%w+) on your .*, who writhes and screams as the weapon is driven deep into %w+ flesh.", handler = function(p) Templar:impaleHandler(p) end},
    
    -- Unimpaled/disemboweled
    {pattern = "With a look of agony on his face, (%w+) manages to writhe %w+ free of the weapon which impaled %w+.", handler = function(p) Templar:unimpaledHandler(p) end},
    {pattern = "(%w+) has writhed free of %w+ impalement.", handler = function(p) Templar:unimpaledHandler(p) end},
    {pattern = "With a vicious snarl you carve a merciless swathe through the steaming guts of %w+, who oyagurgles and chokes as you withdraw your dripping .*, its blade glistening with gore.", handler = function(p) Templar:disemboweledHandler(p) end},

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
    -- Your strikes cause light bruising on Daingean's torso.
    -- Your strikes cause moderate bruising on Daingean's torso.
    -- Your strikes cause critical bruising on Daingean's torso.
}

-- TODO: Gather attack lines for the weapons
-- TODO: Figure out how empowerments/releases are going to work
-- Double Raze: empower blaze/razeslash


function Templar:enemyBruisedHandler(p)
    local bruise, person, limb = mb.line:match(p)
    if bruise == "light" then
        etrack:addAff(limb .. "_bruised")
    else
        etrack:addAff(limb .. "_bruised_" .. bruise)
    end
end

function Templar:empower(left, right)
    send("cleanse left")
    send("cleanse right")
    send("empower right with burst")
    send("empower left with " .. left)
    send("empower right with " .. right)
end

function Templar:attack()
    -- Perform raze/aura checks here.


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
        self:empower("hemorrhage", "hemorrhage")
        self:target("nothing", "nothing")
        self:dsk()
        etrack:removeAff("ruptured")
        return
    end

    -- Attempt to rupture critically bruised areas
    for i, limb in ipairs(_limb_priority) do
        if etrack:hasAff(limb .. "_bruised_critical") then
            self:rupture(limb_priority[i])
            return
        end
    end

    -- Attempt to get a critical bruise by hitting non-critically bruised areas
    for _, aff in ipairs(non_critical_bruises) do
        for i, limb in ipairs(_limb_priority) do
            if etrack:hasAff(limb .. aff) then
                self:attackLimbOrArms(limb_priority[i])
                return
            end
        end
    end

    for i, limb in ipairs(limb_priority) do
        if etrack:getParry() ~= limb then
            self:target(limb, limb)
            self:dsk()
            return
        end
    end

    debug:print("Templar", "After loops")
end

function Templar:attackLimbOrArms(limb)
    debug:print("Templar", "Attempting to attack " .. limb)
    if etrack:getParry() == limb then
        self:target("left arm", "right arm")
    else
        self:target(limb, limb)
    end

    self:dsk()
end

function Templar:target(limb1, limb2)
    send("target " .. limb1 .. " with left")
    send("target " .. limb2 .. " with right")
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
    local weapon, empower = mb.line:match(p);
end

-- Righteousness: Attacks
function Templar:wither() 
    send("aura withering " .. target)
end

-- Bladefire

-- Battlefury: Attacks

function Templar:strike()
    send("strike " .. target)
end

function Templar:raze()
    send("raze " .. target)
end

function Templar:rsl()
    send("razestrike " .. target)
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
end

function Templar:impale()
    send("impale " .. target)
end

function Templar:zeal()
    send("zeal " .. target)
end

function Templar:lunge()
    send("lunge " .. target)
end

function Templar:rupture(limb)
    debug:print("Templar", "Sending: Rupture: " .. limb)
    send("rupture " .. target .. " " .. limb)
end

function Templar:tempest()
    send("tempest")
end

function Templar:disembowel()
    send("disembowel " .. target)
end

function Templar:charge()
    send("charge " .. target)
end

function Templar:rend()
    send("rend " .. target)
end

function Templar:cleave()
    send ("cleave" .. target)
end

--------------------
-- AURA/BLESSINGS --
--------------------
Templar.currentAura = ""
Templar.currentBlessings = {}

Templar.blessings = {
    bashing = {
        aura = "protection",
        blessings = {"healing", "meditation", "redemption"}
    },
    steamroller = {
        aura = "purity",
        blessings = {"protection", "meditation", "redemption"}
    }
}

function Templar:blessingHandler(i,p)
    local set = i:match(p)
    self:setBlessings(set)
end

function Templar:setBlessings(type)
    if not Templar.blessings[type] then
        ACSEcho("Blessing set " .. type .. " not found.")
        return
    end

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
        send("wield warhammer")
        send("cleanse left")
        send("cleanse right")
        send("empower left with sacrifice")
        send("empower right with sacrifice")
        send("dsw " .. selectedTarget)
    end
}