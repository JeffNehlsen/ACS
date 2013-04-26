echo("Loading concoctions...")


-------------------------
-- Brewing Concoctions --
-------------------------
concoctions = {
    immunity = {sac = 1, ash = 1, echinacea = 2},
    epidermal = {kuzu = 2, bloodroot = 2, hawthorn = 1, ginseng = 1},
    mana = {slipper = 1, bellwort = 1, hawthorn = 1, bloodroot = 1},
    health = {valerian = 2, gobldenseal = 1, ginseng = 1, myrrh = 1},
    venom = {sac = 1, cohosh = 1, kelp = 1, skullcap = 1},
    frost = {kelp = 1, pear = 1, ginseng = 1},
    caloric = {kuzu = 2, valerian = 1, kelp = 2, bellwort = 1},
    levitation = {kelp = 2, pear = 1, feather = 1},
    mending = {dust = 1, kelp = 1, kuzu = 1, ginger = 2},
    mass = {moss = 1, bloodroot = 1, kuzu = 1, dust = 1},
    speed = {skin = 2, kuzu = 1, goldenseal = 1, ginger = 1},
    restoration = {gold = 200, kuzu = 2, valerian = 1, bellwort = 1}
}

aliases.concoctions = {
    {pattern = "^make (%d+) (%w+)$", handler = function(i,p) handleConcoctionsFill(i,p) end},
}

function handleConcoctionsFill(i,p)
    num, recipe = i:match(p)
    tmp = tonumber(num)
    if not concoctions[recipe] then
        ACSEcho("Recipe " .. recipe .. " not found.")
        return
    end

    for plant, amount in pairs(concoctions[recipe]) do
        if plant == "gold" then
            send("take " .. (200*num) .. " gold from pack")
            send("inpot " .. (200*num) .. " gold to pot")
        else    
            send("outc " .. (amount*num) .. " " .. plant)
            send("inpot " .. (amount*num) .. " " .. plant .. " to pot")
        end
    end

    send("drop pot")
    send("boil pot for " .. recipe)

    tempTrigger("With a sudden slow pulsing of white light", function() 
        send("get pot")
        for i = 1, tmp do
            send("fill empty from pot")
        end
    end)
end