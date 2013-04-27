--Adds debugging functionality 
echo("Loading Debug.lua")
debug = {}

aliases.debug = {
   {pattern = "^debug(?: (list))?$", handler = function(i,p) debug:handleDebug(i,p) end},
   {pattern = "^debugc(?: (.*))?$", handler = function(i,p) debug:handleDebugCategories(i,p) end}
}

function debug:handleDebug(i,p)
   local tmp = i:match(p)
   if tmp then
       debug:listCategories()
   else
       debug:toggleDebug()
   end
end

function debug:handleDebugCategories(i,p)
   local tmp = i:match(p)
   if tmp then
       debug:watchCategory( tmp )
   else
       debug:listCategories()
   end
end

debugger = debugger or {}
debugger.debug = debugger.debug or {}
debugger.debug.active = debugger.debug.active or nil
debugger.debug.categories = debugger.debug.categories or { }
function debugger:Debug(category,debugData)
   if category then
      if table.contains(debugger.debug.categories, category) then
         if type(debugData) == "table" then
            debugger:echo("DEBUG " .. category .. ":" .. C.W)
            display(debugData)
         elseif type(debugData) == "string" or type(debugData) == "number" then
            debugger:echo(C.R .. "DEBUG " .. category .. ":" .. C.W .. " " .. debugData .. "\n" )
         else
            debugger:echo(C.R .. "DEBUG " .. category .. ":" .. C.W .. " " .. tostring(debugData) .. "\n" )
         end
      end
   else
      if type(debugData) == "table" then
         debugger:echo(C.R .. "DEBUG: " .. C.W)
         display(debugData)
      elseif type(debugData) == "string" or type(debugData) == "number" then
         debugger:echo(C.R .. "DEBUG:" .. C.W .." " .. debugData)
      else
         debugger:echo(C.R .. "DEBUG:" .. C.W .. " " .. tostring(debugData))
      end
   end
end

function debugger:printDebug(category, debugData)
   if not debugger.debug.active then return end
   debugger:Debug(category, debugData)
end

function debugger:toggleDebug()
   if debugger.debug.active then 
		debugger.debug.active = nil
   else 
		debugger.debug.active = true
   end
   debugger:echo("Debugging is currently " .. (( debugger.debug.active and C.G .. "ON" .. C.W) or C.R .. "OFF" .. C.W))
end

function debugger:watchCategory( category )
   if table.contains(debugger.debug.categories, category) then
      for i,v in ipairs(debugger.debug.categories) do
         if v == category then
            table.remove(debugger.debug.categories, i)
         end
      end
      debugger:echo("No longer watching the '" .. C.R .. category .. C.W .. "' category.") 
   else
      table.insert(debugger.debug.categories, category)
      debugger:echo("Now watching the '" .. C.R .. category .. C.W .."' category.")
   end
   debugger:echo("Debugging is currently " .. (( debugger.debug.active and C.G .. "ON" .. C.W) or C.R .. "OFF" .. C.W))
end

function debugger:listCategories()
   if #debugger.debug.categories > 0 then
      debugger:echo("You are currently watching the following categories:\n" .. table.concat(debugger.debug.categories,", ") )
   else
      debugger:echo("You are not watching any debugs.")
   end
end
echo("Finsihed Loading Debug.lua")