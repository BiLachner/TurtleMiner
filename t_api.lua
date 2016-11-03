-- turtleminer/t_api.lua

---------------
-- FUNCTIONS --
---------------

local positions = {} -- form positions

--------------
-- FORMSPEC --
--------------

-- [function] show formspec
function turtleminer.show_formspec(name, pos, formname, params)
	local meta = minetest.get_meta(pos) -- get meta
  if not meta then return false end -- if not meta, something is wrong
  positions[name] = pos -- set position (for receive fields)

	local function show(formspec)
		meta:set_string("formname", formname) -- set meta
		minetest.show_formspec(name, "turtleminer:"..formname, formspec) -- show formspec
	end

  -- if form name is main, show main
  if formname == "main" then
		local formspec =
			"size[6,4]" ..
			"label[0,0;Click buttons to move the turtle around!]" ..
			"button_exit[4,1;1,1;exit;Exit]" ..
			"image_button[0,1;1,1;turtleminer_remote_arrow_up.png;up;]" ..
			"image_button[1,1;1,1;turtleminer_remote_arrow_fw.png;forward;]" ..
			"image_button[2,1;1,1;turtleminer_remote_dig_front.png;digfront;]" ..
			"image_button[2,3;1,1;turtleminer_remote_dig_down.png;digbottom;]" ..
			"image_button[3,1;1,1;turtleminer_remote_build_front.png;buildfront;]" ..
			"image_button[3,3;1,1;turtleminer_remote_build_down.png;buildbottom;]" ..
			"image_button[0,2;1,1;turtleminer_remote_arrow_left.png;turnleft;]"..
			"image_button[2,2;1,1;turtleminer_remote_arrow_right.png;turnright;]" ..
			"image_button[0,3;1,1;turtleminer_remote_arrow_down.png;down;]" ..
			"image_button[1,3;1,1;turtleminer_remote_arrow_bw.png;backward;]"
		show(formspec) -- show
	elseif formname == "set_name" then -- elseif form name is set_name, show set name formspec
		if not params then local params = "" end -- use blank name is none specified
	  local formspec =
	    "size[6,1.7]"..
	    default.gui_bg_img..
	    "field[.25,0.50;6,1;name;Name Your Turtle:;"..params.."]"..
	    "button[4.95,1;1,1;submit_name;Set]"
		show(formspec) -- show
	end
end

-- [function] rotate
function turtleminer.rotate(pos, direction, player)
	-- [function] calculate dir
	local function calculate_dir(x, turn)
		if turn == "right" then
			x = x + 1
			if x > 3 then x = 0 end
			return x
		elseif turn == "left" then
			x = x - 1
			if x < 0 then x = 3 end
			return x
		end
	end

	local node = minetest.get_node(pos) -- get node
	local ndef = minetest.registered_nodes[node.name] -- get node def

	-- if direction is right, rotate right
	if direction == "right" then
		-- calculate param2
		local rotationPart = node.param2 % 32 -- get first 4 bits
		local preservePart = node.param2 - rotationPart
		local axisdir = math.floor(rotationPart / 4)
		local rotation = rotationPart - axisdir * 4
		local x = rotation + 1
		if x > 3 then x = 0 end -- calculate x
		rotationPart = axisdir * 4 + x
		local new_param2 = preservePart + rotationPart

		node.param2 = new_param2 -- set new param2
		minetest.swap_node(pos, node) -- swap node
		minetest.sound_play("moveokay", { to_player = player, gain = 1.0 }) -- play sound
	elseif direction == "left" then -- elseif direction is left, rotate left
		-- calculate param2
		local rotationPart = node.param2 % 32 -- get first 4 bits
		local preservePart = node.param2 - rotationPart
		local axisdir = math.floor(rotationPart / 4)
		local rotation = rotationPart - axisdir * 4
		local x = rotation - 1
		if x < 0 then x = 3 end -- calculate x
		rotationPart = axisdir * 4 + x
		local new_param2 = preservePart + rotationPart

		node.param2 = new_param2 -- set new param2
		minetest.swap_node(pos, node) -- swap node
		minetest.sound_play("moveokay", { to_player = player, gain = 1.0 }) -- play sound
	end
end

-- [function] move
function turtleminer.move(pos, direction, name)
	local oldmeta = minetest.get_meta(pos):to_table() -- get meta
	local node = minetest.get_node(pos) -- get node ref
	local dir = minetest.facedir_to_dir(node.param2) -- get facedir
	local new_pos = vector.new(pos) -- new pos vector
	local entity_pos = vector.new(pos) -- entity position vector

	local function turtle_move(pos, new_pos, entity_pos)
		-- if not walkable, proceed
		if not minetest.registered_nodes[minetest.get_node(new_pos).name].walkable then
			minetest.remove_node(pos) -- remote old node
			minetest.set_node(new_pos, node) -- create new node
			positions[name] = new_pos -- update position
			minetest.get_meta(new_pos):from_table(oldmeta) -- set new meta

			-- if not walkable, move player
			if not minetest.registered_nodes[minetest.get_node(entity_pos).name].walkable then
				local objects_to_move = {}

				local objects = minetest.get_objects_inside_radius(new_pos, 1) -- get objects
				for _, obj in ipairs(objects) do -- for every object, add to table
					table.insert(objects_to_move, obj) -- add to table
				end

				for _, obj in ipairs(objects_to_move) do
					local entity = obj:get_luaentity()
					if not entity then
							obj:setpos(entity_pos)
					end
				end
			end

			minetest.sound_play("moveokay", { player = name, gain = 1.0 }) -- play sound
		else -- else, return false
			minetest.sound_play("moveerror", { player = name, gain = 1.0 }) -- play sound
			return false
		end
	end

	-- if direction is forward, move forward
	if direction == "forward" or direction == "f" then
		-- calculate new coords
		new_pos.z = new_pos.z - dir.z
		new_pos.x = new_pos.x - dir.x
		entity_pos.z = entity_pos.z - dir.z * 2
		entity_pos.x = entity_pos.x - dir.x * 2
		turtle_move(pos, new_pos, entity_pos) -- call local function
	elseif direction == "backward" or direction == "b" then
		new_pos.z = new_pos.z + dir.z
		new_pos.x = new_pos.x + dir.x
		entity_pos.z = entity_pos.z + dir.z * 2
		entity_pos.x = entity_pos.x + dir.x * 2
		turtle_move(pos, new_pos, entity_pos) -- call local function
	elseif direction == "up" or direction == "u" then
		new_pos.y = new_pos.y + 1
		entity_pos.y = entity_pos.y + 2
		turtle_move(pos, new_pos, entity_pos) -- call local function
	elseif direction == "down" or direction == "d" then
		new_pos.y = new_pos.y - 1
		entity_pos.y = entity_pos.y - 2
		turtle_move(pos, new_pos, entity_pos) -- call local function
	end
end

-- [function] dig
function turtleminer.dig(pos, where, name)
	-- [function] dig
	local function dig(pos)
		if minetest.get_node_or_nil(pos) then -- if node, dig
			minetest.set_node(pos, { name = "air" })
			nodeupdate(pos)
			minetest.sound_play("moveokay", {to_player = name, gain = 1.0,}) -- play sound
		else minetest.sound_play("moveerror", {to_player = name, gain = 1.0,}) end -- else, play error sound
	end

	local node = minetest.get_node(pos) -- get node ref
	local dir = minetest.facedir_to_dir(node.param2) -- get facedir
	local dig_pos = vector.new(pos) -- dig position

	if where == "front" then -- if where is front, dig in front
		-- adjust position considering facedir
		dig_pos.z = dig_pos.z - dir.z
		dig_pos.x = dig_pos.x - dir.x
		dig(dig_pos) -- dig node in front
	elseif where == "below" then -- elseif where is below, dig below
		dig_pos.y = dig_pos.y - 1 -- remove 1 from dig_pos y axis
		dig(dig_pos) -- dig node below
	end
end

-- [function] build
function turtleminer.build(pos, where, name)
	-- [function] build
	local function build(pos)
		if minetest.get_node_or_nil(pos) then -- if node, dig
			minetest.set_node(pos, { name = "dirt" })
			nodeupdate(pos)
			minetest.sound_play("moveokay", {to_player = name, gain = 1.0,}) -- play sound
		else minetest.sound_play("moveerror", {to_player = name, gain = 1.0,}) end -- else, play error sound
	end

	local node = minetest.get_node(pos) -- get node ref
	local dir = minetest.facedir_to_dir(node.param2) -- get facedir
	local build_pos = vector.new(pos) -- dig position

	if where == "front" then -- if where is front, dig in front
		-- adjust position considering facedir
		build_pos.z = build_pos.z - dir.z
		build_pos.x = build_pos.x - dir.x
		build(build_pos) -- dig node in front
	elseif where == "below" then -- elseif where is below, dig below
		build_pos.y = build_pos.y - 1 -- remove 1 from dig_pos y axis
		build(build_pos) -- dig node below
	end
end



--------------
-- NODE DEF --
--------------

-- remote
minetest.register_craftitem("turtleminer:remotecontrol", {
	description = "Turtle Remote Control",
	inventory_image = "turtleminer_remotecontrol.png",
})

-- [function] register turtle
function turtleminer.register_turtle(turtlestring, desc)
	minetest.register_node("turtleminer:"..turtlestring, {
		drawtype = "nodebox",
		description = desc.description,
		tiles = desc.tiles,
		groups={ oddly_breakable_by_hand=1 },
		paramtype = "light",
		paramtype2 = "facedir",
		node_box = {
			type = "fixed",
			fixed = desc.nodebox
		},
		after_place_node = function(pos, placer)
			local meta = minetest.get_meta(pos) -- get meta
			--meta:set_string("formspec", turtleminer.formspec()) -- set formspec
			meta:set_string("owner", placer:get_player_name()) -- set owner
			meta:set_string("infotext", "Unnamed turtle\n(owned by "..placer:get_player_name()..")") -- set infotext
		end,
		on_rightclick = function(pos, node, clicker)
			local name = clicker:get_player_name() -- get clicker name
			local meta = minetest.get_meta(pos)
			-- if name not set, show name form
			if not meta:get_string("name") or meta:get_string("name") == "" then
				turtleminer.show_formspec(name, pos, "set_name", "") -- show set name formspec
			elseif meta:get_string("formname") ~= "" then -- elseif formname is set, show specific form
				-- if wielding remote control, show formspec
				if clicker:get_wielded_item():get_name() == "turtleminer:remotecontrol" then
					turtleminer.show_formspec(name, pos, meta:get_string("formname")) -- show formspec (note: no params)
				else
					minetest.chat_send_player(name, "Use a remote controller to access the turtle.")
				end
			else -- else, show normal formspec
				-- if wielding remote control, show formspec
				if clicker:get_wielded_item():get_name() == "turtleminer:remotecontrol" then
					turtleminer.show_formspec(name, pos, "main") -- show main formspec
				else
					minetest.chat_send_player(name, "Use a remote controller to access the turtle.")
				end
			end
		end,
	})
end

-- on player fields received
minetest.register_on_player_receive_fields(function(sender, formname, fields)
	if formname ~= "turtleminer:main" then return end -- if not right formspec, return

	local name = sender:get_player_name()
	local pos = positions[name]

	if not pos then return end -- if not position, return - something is wrong

	local node = minetest.get_node(pos) -- node info

	-- check fields
	if fields.turnright then turtleminer.rotate(pos, "right", name) -- elseif turn right button, rotate right
	elseif fields.turnleft then turtleminer.rotate(pos, "left", name) -- elseif turn left button, rotate left
	elseif fields.forward then turtleminer.move(pos, "forward", name) -- elseif move forward button, move forward
	elseif fields.backward then turtleminer.move(pos, "backward", name) -- elseif move backward button, move backward
	elseif fields.up then turtleminer.move(pos, "up", name) -- elseif move up button, move up
	elseif fields.down then turtleminer.move(pos, "down", name) -- elseif move down button, move down
	elseif fields.digfront then turtleminer.dig(pos, "front", name) -- elseif dig in front button, dig in front
	elseif fields.digbottom then turtleminer.dig(pos, "below", name) -- elseif dig bottom button, dig below
	elseif fields.buildfront then turtleminer.build(pos, "front", name) -- elseif build in front button, build in front
	elseif fields.buildbottom then turtleminer.build(pos, "below", name) end -- elseif build bottom button, build below
end)

-- on player fields received
minetest.register_on_player_receive_fields(function(sender, formname, fields)
	if formname ~= "turtleminer:set_name" then return end -- if not right formspec, return

	local name = sender:get_player_name()
	local meta = minetest.get_meta(positions[name])

	meta:set_string("name", fields.name) -- set name
	meta:set_string("infotext", fields.name .. "\n(owned by "..name..")") -- set infotext
	turtleminer.show_formspec(name, positions[name], "main") -- show main formspec
end)
