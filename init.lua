turtleminer = { _def = {} }
turtleminer.modpath = minetest.get_modpath("turtleminer")

-- logger
function turtleminer.log(content, log_type)
  if log_type == nil then log_type = "action" end
  minetest.log(log_type, "[TurtleMiner] "..content)
end

-- load turtle resources
dofile(turtleminer.modpath.."/api.lua") -- load turtle api
dofile(turtleminer.modpath.."/turtles.lua") -- turtle register
dofile(turtleminer.modpath.."/remote.lua") -- remote control
dofile(turtleminer.modpath.."/scriptvm.lua") -- remote control

if minetest.global_exists("editor") then
    dofile(turtleminer.modpath.."/editor.lua") -- turtles
end
