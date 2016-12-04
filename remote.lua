-- turtleminer/t_api.lua

local turtles = turtleminer.turtles

--------------
-- FORMSPEC --
--------------

-- [function] show formspec
local remote_formspec_contexts = {}
function turtleminer.show_remote_formspec(name, pos)
	local meta = minetest.get_meta(pos) -- get meta
	if not meta then
		return false
	end

	local t_id = meta:get_string("t_id")
	remote_formspec_contexts[name] = t_id


	local formspec =
			"size[6,4]" ..
			"label[0,0;" .. turtles[t_id].name .. "]"..
			"button_exit[4.5,0;1.7,1;pos;"..minetest.pos_to_string(pos).."]" ..
		[[
			tooltip[pos;Refresh Position;#35454D;#FFFFFF]
			label[0,0.3;Use the buttons to interact with your turtle.]
			button_exit[4,1;1,1;exit;Exit]
			image_button[0,1;1,1;turtleminer_remote_arrow_up.png;up;]
			tooltip[up;Up;#35454D;#FFFFFF]
			image_button[1,1;1,1;turtleminer_remote_arrow_fw.png;forward;]
			tooltip[forward;Move Forward;#35454D;#FFFFFF]
			image_button[2,1;1,1;turtleminer_remote_dig_front.png;digfront;]
			tooltip[digfront;Dig in Front;#35454D;#FFFFFF]
			image_button[2,3;1,1;turtleminer_remote_dig_down.png;digbottom;]
			tooltip[digbottom;Dig Beneath;#35454D;#FFFFFF]
			image_button[3,1;1,1;turtleminer_remote_build_front.png;buildfront;]
			tooltip[buildfront;Build in Front;#35454D;#FFFFFF]
			image_button[3,3;1,1;turtleminer_remote_build_down.png;buildbottom;]
			tooltip[buildbottom;Build Beneath;#35454D;#FFFFFF]
			image_button[0,2;1,1;turtleminer_remote_arrow_left.png;turnleft;]
			tooltip[turnleft;Turn Left;#35454D;#FFFFFF]
			image_button[2,2;1,1;turtleminer_remote_arrow_right.png;turnright;]
			tooltip[turnright;Turn Right;#35454D;#FFFFFF]
			image_button[0,3;1,1;turtleminer_remote_arrow_down.png;down;]
			tooltip[down;Down;#35454D;#FFFFFF]
			image_button[1,3;1,1;turtleminer_remote_arrow_bw.png;backward;]
			tooltip[backward;Move Backward;#35454D;#FFFFFF]
		]]

	meta:set_string("formname", "turtleminer:remote")
	minetest.show_formspec(name, "turtleminer:remote", formspec)
end


-- on player fields received
minetest.register_on_player_receive_fields(function(sender, formname, fields)
	if formname ~= "turtleminer:remote" then
		return
	end

	local name = sender:get_player_name()
	local t_id = remote_formspec_contexts[name]
	local turtle = turtles[t_id]
	local pos = turtle.pos

	local run = turtleminer.run_command

	-- Do Action
	    if fields.turnright   then run(name, pos, "rotate", "right")
	elseif fields.turnleft    then run(name, pos, "rotate", "left")
	elseif fields.forward     then run(name, pos, "move",   "forward")
	elseif fields.backward    then run(name, pos, "move",   "backward")
	elseif fields.up          then run(name, pos, "move",   "up")
	elseif fields.down        then run(name, pos, "move",   "down")
	elseif fields.digfront    then run(name, pos, "dig",    "front")
	elseif fields.digbottom   then run(name, pos, "dig",    "below")
	elseif fields.buildfront  then run(name, pos, "build",  "front")
	elseif fields.buildbottom then run(name, pos, "build",  "below")
	end
end)



-- remote
minetest.register_craftitem("turtleminer:remotecontrol", {
	description = "Turtle Remote Control",
	inventory_image = "turtleminer_remotecontrol.png",
	on_place = function(itemstack, placer, pointed_thing)
		local nodename = minetest.get_node(pointed_thing.under).name
		local def = minetest.registered_nodes[nodename]
		if def.groups.turtle then
			turtleminer.show_remote_formspec(placer:get_player_name(), pointed_thing.under)
		end
	end,
})
