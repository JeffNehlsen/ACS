echo("Announcer loaded")

Announcer = {
  enabled = false,
}

aliases.announcer = {
  {pattern = "^annon$", handler = function(i,p) Announcer:enable() end},
  {pattern = "^annoff$", handler = function(i,p) Announcer:disable() end},
}

function Announcer:enable()
  Announcer.enabled = true
  ACSEcho("Announcer enabled")
  Announcer:announce(atcp.name .. "'s will be announcing to you!")
end

function Announcer:disable()
  if not Announcer.enabled then return end
  Announcer:announce(atcp.name .. "'s Announcer is turning off!")
  Announcer.enabled = false
  ACSEcho("Disabling Announcer")
end

function Announcer:announce(message)
  if Announcer.enabled then
    send("wt ACS-Announcer: " .. message)
  end
end