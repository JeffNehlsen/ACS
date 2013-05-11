aliases.pathRecording = {
  {pattern = "^startrecording$", handler = function(i,p) recordingStartHandler() end},
  {pattern = "^stoprecording$",  handler = function(i,p) recordingStopHandler() end},
  {pattern = "^resetrecording$", handler = function(i,p) resetRecording() end},
  {pattern = "^printrecording$", handler = function(i,p) printRecording() end},
  {pattern = "^nw$",  handler = function(i,p) handleDirection("nw") end},
  {pattern = "^n$",   handler = function(i,p) handleDirection("n") end},
  {pattern = "^ne$",  handler = function(i,p) handleDirection("ne") end},
  {pattern = "^w$",   handler = function(i,p) handleDirection("w") end},
  {pattern = "^e$",   handler = function(i,p) handleDirection("e") end},
  {pattern = "^sw$",  handler = function(i,p) handleDirection("sw") end},
  {pattern = "^s$",   handler = function(i,p) handleDirection("s") end},
  {pattern = "^se$",  handler = function(i,p) handleDirection("se") end},
  {pattern = "^u$",   handler = function(i,p) handleDirection("u") end},
  {pattern = "^d$",   handler = function(i,p) handleDirection("d") end},
  {pattern = "^up$",   handler = function(i,p) handleDirection("u") end},
  {pattern = "^down$",   handler = function(i,p) handleDirection("d") end},
  {pattern = "^in$",  handler = function(i,p) handleDirection("in") end},
  {pattern = "^out$", handler = function(i,p) handleDirection("out") end},
}


recording = {active = false}
recording.path = recording.path or {}

function handleDirection(dir)
  if recording.active then
    table.insert(recording.path, dir)
  end
  send(dir)
end

function recordingStartHandler() 
  recording.active = true
  ACSEcho("Starting recording...")
end

function recordingStopHandler()
  recording.active = false
  ACSEcho("Stoping recording")
end

function printRecording()
  if #recording.path > 0 then
    ACSEcho("Recording results:")
    local str = "{"
    for i,v in ipairs(recording.path) do
      str = str .. "\"" .. v .. "\", "
    end
    str = str .. "},"
    echo(str)
  else
    ACSEcho("No recording to print!")
  end
end

function resetRecording()
  recoring.path = {}
  ACSEcho("Reset recording!")
end