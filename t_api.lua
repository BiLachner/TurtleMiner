-- turtleminer/t_api.lua

minetest.register_craftitem("turtleminer:remotecontrol", {
	description = "A remote control for Miner-Turtles",
	inventory_image = "turtleminer_remotecontrol.png",
})

-- variable prepared to store the position of the players turtle
local turtle_formspec_positions = {}


--functions needed for rotation left and right ... could be made better?!
local function rotateright(x)
	x = x + 1
	if x > 3 then
		x = 0
	end
	return x
end

local function rotateleft(x)
	x = x - 1
	if x < 0 then
		x = 3
	end
	return x
end


-- [function] register turtle
function turtleminer.register_turtle(turtlestring, number, desc)
	minetest.register_node("turtleminer:"..turtlestring, {
	drawtype = "nodebox",
	description = desc.description,
	tiles = desc.tiles,
	groups={ oddly_breakable_by_hand=1 },
	paramtype = "light",
	paramtype2 = "facedir",
	node_box = {
		type = "fixed",
		fixed = desc.nodeboxes
	},
	on_rightclick = function(pos, node, clicker, itemstack, pointed_thing)
  		local wielditem = clicker:get_wielded_item()
  		local wieldname = wielditem:get_name()
  		if wieldname ~= "turtleminer:remotecontrol" then
  			minetest.chat_send_player(clicker:get_player_name(), "Use the remote control!")
  		else
  			-- When the player does a right click on this node
  			local player_name = clicker:get_player_name()
  			 -- Save the last turtle in a table
  			turtle_formspec_positions[player_name] = pos

  			minetest.show_formspec(player_name, "turtleminer:turtle_formspec",
  				"size[9,4]" ..
  				"label[0,0;Click buttons to move the turtle around!]" ..
  				"button_exit[5,1;2,1;exit;Exit]" ..
  				"image_button[1,1;1,1;turtleminer_remote_arrow_up.png;up;]" ..
  				"image_button[2,1;1,1;turtleminer_remote_arrow_fw.png;forward;]" ..
  				"button[3,1;2,1;digfront;dig front]" ..
  				"button[3,3;2,1;digbottom;dig under]" ..
  				"image_button[1,2;1,1;turtleminer_remote_arrow_left.png;turnleft;]"..
  				"image_button[3,2;1,1;turtleminer_remote_arrow_right.png;turnright;]" ..
  				"image_button[1,3;1,1;turtleminer_remote_arrow_down.png;down;]" ..
  				"image_button[2,3;1,1;turtleminer_remote_arrow_bw.png;backward;]"
  				--.. "button[3,3;1,1;build;build]"
  				)
  			return itemstack
  		end
  	end,
  })
end


--functions needed for rotation left and right ... could be made better?!
local function rotateright(x)
	x = x + 1
	if x > 3 then
		x = 0
	end
	return x
end

local function rotateleft(x)
	x = x - 1
	if x < 0 then
		x = 3
	end
	return x
end

-- Catch user inputs from the formspec
minetest.register_on_player_receive_fields(function(sender, formname, fields)
	if formname ~= "turtleminer:turtle_formspec" then
		return -- Not a turtle formspec
	end
	
	local player_name = sender:get_player_name() --name of the player used the remote control with a turtle
	local pos = turtle_formspec_positions[player_name] -- position of the players turtle
	
	if not pos then
		return -- Something went wrong. No position found for this player
	end

	local node = minetest.get_node(pos) --save old position of the turtle

	-- Is this sreally needed? -> causes problem because I have different turtles!!!
	-- -----------------------------------------------------------------------------
	-- if node.name ~= "minerturtle:turtle" then
	--	turtle_formspec_positions[player_name] = nil
	--	return -- Data invalid. There's no turtle at the given position
	-- end

	-- button to rotate turtle right or left pressed
	if fields.turnright then
		local ndef = minetest.registered_nodes[node.name]
		
		-- Compute param2
		local rotationPart = node.param2 % 32 -- get first 4 bits
		local preservePart = node.param2 - rotationPart
		local axisdir = math.floor(rotationPart / 4)
		local rotation = rotationPart - axisdir * 4
		rotationPart = axisdir * 4 + rotateright(rotation)

		local new_param2 = preservePart + rotationPart

		node.param2 = new_param2
		minetest.swap_node(pos, node)
		move = false
		minetest.sound_play("moveokay", {to_player = player_name,gain = 1.0,})
		return
	end

	if fields.turnleft then
		local ndef = minetest.registered_nodes[node.name]

		-- Compute param2
		local rotationPart = node.param2 % 32 -- get first 4 bits
		local preservePart = node.param2 - rotationPart
		local axisdir = math.floor(rotationPart / 4)
		local rotation = rotationPart - axisdir * 4
		rotationPart = axisdir * 4 + rotateleft(rotation)

		local new_param2 = preservePart + rotationPart

		node.param2 = new_param2
		minetest.swap_node(pos, node)
		move = false
		minetest.sound_play("moveokay",{to_player = player_name,gain = 1.0,})
		return
	end
	
	
	-- prepare variables for movement and digging
	local new_pos = vector.new(pos)
	local dig_pos = vector.new(pos)
	

	local dir = minetest.facedir_to_dir(node.param2)
	local dirx= dir.x
	local dirz= dir.z
	local move = false
	
	-- check out what would be the new position after movement
	if fields.up then
		new_pos.y = new_pos.y + 1
		move = true
	end

	if fields.down then
		new_pos.y = new_pos.y - 1
		move = true
	end

	if fields.forward then
		new_pos.z = new_pos.z - dirz
		new_pos.x = new_pos.x - dirx
		move = true
	end

	if fields.backward then
		new_pos.z = new_pos.z + dirz
		new_pos.x = new_pos.x + dirx
		move = true
	end

	-- Check if new position if empty or not 
	local newposchecktable = minetest.get_node(new_pos)
	local newposcheck = newposchecktable.name
	local walkable = minetest.registered_nodes[newposcheck].walkable -- walkable = true ... there is something
	
	-- make the step if there is nothing that is distrubring and if it is a movement
	if move then
		if (not walkable) then
			-- Move node to new position
			minetest.remove_node(pos)
			minetest.set_node(new_pos, node) --move node to new position
			minetest.get_meta(new_pos):from_table(meta) --set metadata of new node
			-- Update formspec reference position, wait for next instructions
			turtle_formspec_positions[player_name] = new_pos

			minetest.sound_play("moveokay", {to_player = player_name,gain = 1.0,})
			return
		else
			minetest.sound_play("moveerror", {to_player = player_name,gain = 1.0,})
			return
		end
	end	
	
	-- Player pressed "dig front" button
	if fields.digfront then
		-- getposition of block in front of turtle and check for block
		dig_pos.z = dig_pos.z - dirz
		dig_pos.x = dig_pos.x - dirx
		local digposchecktable = minetest.get_node(dig_pos)
		local digposcheck = digposchecktable.name
		local digablefront = minetest.registered_nodes[digposcheck].walkable -- walkable = true ... there is something
		
		-- is there something to dig  then do it!
		if digablefront then
			minetest.set_node(dig_pos, {name="air"})
			minetest.sound_play("moveokay", {to_player = player_name,gain = 1.0,})
			return
		else
			minetest.sound_play("moveerror", {to_player = player_name,gain = 1.0,})
			return
		end
	end
	
	-- Player pressed "dig bottom" button
	if fields.digbottom then
		-- get position of block under the turtle and check if there is block
		dig_pos.y = dig_pos.y-1
		local digposchecktable = minetest.get_node(dig_pos)
		local digposcheck = digposchecktable.name
		local digablebottom = minetest.registered_nodes[digposcheck].walkable -- walkable = true ... there is something
		
		-- is there something to dig then do it!
		if digablebottom then
			minetest.set_node(dig_pos, {name="air"})
			minetest.sound_play("moveokay", {to_player = player_name,gain = 1.0,})
			return
		else
			minetest.sound_play("moveerror", {to_player = player_name,gain = 1.0,})
			return
		end
	end

end)