turtleminer = {}
turtleminer.modpath = minetest.get_modpath("turtleminer")

-- logger
function turtleminer.log(content, log_type)
  if log_type == nil then log_type = "action" end
  minetest.log(log_type, "[TurtleMiner] "..content)
end

-- load turtle resources
dofile(turtleminer.modpath.."/t_api.lua") -- load turtle api
dofile(turtleminer.modpath.."/remote.lua") -- load remote control
dofile(turtleminer.modpath.."/turtles.lua") -- turtle register

-- load optional resources
if minetest.setting_get("turtleminer.debug") == true then
  dofile(turtleminer.modpath.."/testing.lua") -- testing
end
