--Adds debugging functionality 
echo("Loading Debug.lua")

aliases.debug = {
   {pattern = "^debug$", handler = function(i,p) debugger:toggleDebug() show_prompt() end},
   {pattern = "^debug list$", handler = function(i,p) debugger:listCategories() show_prompt() end},
   {pattern = "^debugc (.*)$", handler = function(i,p) debugger:handleDebugCategories(i,p) end},
   {pattern = "^debugc$", handler = function(i,p) debugger:listCategories() show_prompt() end},
}

debug = {}
function debug:print(category, debugData)
   debugger:printDebug(category, debugData)
end

debugger = debugger or {}
debugger.debug = debugger.debug or {}
debugger.debug.active = debugger.debug.active or nil
debugger.debug.categories = debugger.debug.categories or { }

function debugger:echo(str)
   echo(str)
end

function handleDebug(i,p)
   local tmp = i:match(p)
   if tmp then
      debugger:toggleDebug()
   else
      debugger:listCategories()
   end
   show_prompt()
end

function debugger:handleDebugCategories(i,p)
   local tmp = i:match(p)
   if tmp then
       debugger:watchCategory( tmp )
   else
       debugger:listCategories()
   end
   show_prompt()
end


function debugger:Debug(category,debugData)
   if category then
      if stringInTable(category, debugger.debug.categories) then
         if type(debugData) == "table" then
            debugger:echo("DEBUG " .. category .. ":" .. C.W)
            echo(printtable(debugData))
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
   -- echo("debugger.debug.categories: " .. printtable(debugger.debug.categories))
   if stringInTable(category, debugger.debug.categories) then
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