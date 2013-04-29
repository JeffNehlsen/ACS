
ACS = {}

function ACS:addModule(module, name)
    if module.triggers then
        for _, trigger in ipairs(module.triggers) do
            table.insert(triggers[name], trigger)
        end
    end

    if module.aliases then
        for _, alias in ipairs(module.aliases) do
            table.insert(aliases[name], trigger)
        end
    end

    if module.extraTriggers then
        for _, trigger in ipairs(module.extraTriggers) do
            table.insert(triggers[name .. "_Extra"], trigger)
        end
    end
end


-- function PipeFiller:setup()
--   triggers.PipeFiller = {}
  
--   aliases.PipeFiller = {}
--   for _, trigger in ipairs(self.triggers) do
--     table.insert(triggers.PipeFiller, trigger)
--   end

--   for _, alias in ipairs(self.aliases) do
--     table.insert(aliases.PipeFiller, alias)
--   end

--   disableTriggers("PipeFiller")

--   -- Set up the triggers that will actually enable this module.
--   triggers.PipeFillerExtra = {
--     {pattern = {
--       "^You are not holding a syringe with that type of tincture in it.$",
--       "^The syringe is now empty.$",
--       "^You squirt out the remaining %w+ from the syringe.$",
--       "^Your pipe is now empty.$",
--       "^What is it you wish to smoke?$",
--       "^You tap out the contents of your pipe.$"
--     }, handler = function() PipeFiller:performCheck() end},
--   }
-- end