turtleminer = {}
turtleminer.modpath = minetest.get_modpath("turtleminer")

-- load turtle resources
dofile(turtleminer.modpath.."/t_api.lua") -- load turtle api
dofile(turtleminer.modpath.."/turtles.lua") -- turtle register


minetest.register_craftitem("turtleminer:remotecontrol", {
	description = "A remote control for Miner-Turtles",
	inventory_image = "turtleminer_remotecontrol.png",
})


