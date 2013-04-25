
function alias_handler(input)
  if input:match("load (%w+)") then
    LoadArg = input:match("load (%w+)")
    init_setup()
    dofile("scripts/Loader.lua")
    return true
  elseif input:match("load") then
    init_setup()
    dofile("scripts/Loader.lua")
    return true
  elseif input:match("^setup$") or input:match("^setupprompt$") then 
  init_setup()
  end
end

function init_setup()
  send("config affliction_view on")
  send("config experience_change on")
  send("config prompt custom H:@health/@maxhealth M:@mana/@maxmana E:@end/@maxend W:@will/@maxwill B:@blood/@maxblood XP:@xp/@xpmax Essence:@essence Spark:@spark Soul:@soul Devotion:@devotion Kai:@kai [@stats @eqbal]")
end

mb.client_aliases = alias_handler