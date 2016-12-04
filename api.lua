-- turtleminer/t_api.lua

turtleminer.positions = {}
local positions = turtleminer.positions -- form positions

---------------
-- FUNCTIONS --
---------------

function turtleminer.show_naming_formspec(name, pos)
	local meta = minetest.get_meta(pos) -- get meta
	if not meta then
		return false
	end

	positions[name] = pos

	local formspec =
		"size[6,1.7]"..
		default.gui_bg_img..
		"field[.25,0.50;6,1;name;Name Your Turtle:;]"..
		"button_exit[4.95,1;1,1;submit_name;Set]"

	minetest.show_formspec(name, "turtleminer:set_name", formspec)
end

-- on player fields received
minetest.register_on_player_receive_fields(function(sender, formname, fields)
	if formname ~= "turtleminer:set_name" then
		return
	end

	local name = sender:get_player_name()
	local meta = minetest.get_meta(positions[name])
	local tname = fields.name
	if (fields.submit_name or fields.key_enter_field == "name")
			and tname and tname ~= "" then
		meta:set_string("name", tname)
		meta:set_string("infotext", tname .. "\n(owned by "..name..")")
	end
end)

function turtleminer.run_command(owner, pos, command, ...)
	local result = turtleminer[command](owner, pos, ...)
	if result then
		minetest.sound_play("moveokay", { to_player = owner })
		return result
	else
		minetest.sound_play("moveerror", { to_player = owner })
	end
end

-- [function] check if breakable
function turtleminer.is_breakable(pos)
	local def = minetest.registered_nodes[minetest.get_node(pos).name]
	return def and def.groups.unbreakable ~= 1
end

-- [function] rotate
function turtleminer.rotate(player, pos, direction)
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
		return pos
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
		return pos
	end
end

-- [function] move
function turtleminer.move(owner, pos, direction)
	local oldmeta = minetest.get_meta(pos):to_table()
	local node = minetest.get_node(pos)
	local dir = minetest.facedir_to_dir(node.param2)
	local new_pos = vector.new(pos)
	local entity_pos = vector.new(pos)

	if direction == "forward" or direction == "f" then
		new_pos.z = new_pos.z - dir.z
		new_pos.x = new_pos.x - dir.x
		entity_pos.z = entity_pos.z - dir.z * 2
		entity_pos.x = entity_pos.x - dir.x * 2
	elseif direction == "backward" or direction == "b" then
		new_pos.z = new_pos.z + dir.z
		new_pos.x = new_pos.x + dir.x
		entity_pos.z = entity_pos.z + dir.z * 2
		entity_pos.x = entity_pos.x + dir.x * 2
	elseif direction == "up" or direction == "u" then
		new_pos.y = new_pos.y + 1
		entity_pos.y = entity_pos.y + 2
	elseif direction == "down" or direction == "d" then
		new_pos.y = new_pos.y - 1
		entity_pos.y = entity_pos.y - 2
	end

	local def = minetest.registered_nodes[minetest.get_node(new_pos).name]
	if not def.walkable then
		minetest.remove_node(pos) -- remote old node
		minetest.set_node(new_pos, node) -- create new node
		positions[owner] = new_pos -- update position
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

		return new_pos
	else
		return
	end
end

-- [function] dig
function turtleminer.dig(owner, pos, where)
	local node = minetest.get_node(pos)
	local dir = minetest.facedir_to_dir(node.param2)
	local dig_pos = vector.new(pos)

	if where == "front" then
		dig_pos.z = dig_pos.z - dir.z
		dig_pos.x = dig_pos.x - dir.x
	elseif where == "below" then
		dig_pos.y = dig_pos.y - 1
	end

	if minetest.get_node_or_nil(dig_pos) and turtleminer.is_breakable(dig_pos) then
		minetest.set_node(dig_pos, { name = "air" })
		nodeupdate(dig_pos)
		return dig_pos
	end
end

-- [function] build
function turtleminer.build(owner, pos, where)
	local node = minetest.get_node(pos)
	local dir = minetest.facedir_to_dir(node.param2)
	local build_pos = vector.new(pos)

	if where == "front" then
		build_pos.z = build_pos.z - dir.z
		build_pos.x = build_pos.x - dir.x
	elseif where == "below" then
		build_pos.y = build_pos.y - 1
	end

	local def = minetest.registered_nodes[minetest.get_node(pos).name]
	if not def or def.buildable_to then
		minetest.set_node(dig_pos, { name = "dirt" })
		nodeupdate(dig_pos)
		return dig_pos
	end
end



--------------
-- NODE DEF --
--------------

-- [function] register turtle
function turtleminer.register_turtle(turtlestring, def)
	turtleminer._def["turtleminer:"..turtlestring] = def
	minetest.register_node("turtleminer:"..turtlestring, {
		drawtype = "nodebox",
		description = def.description,
		tiles = def.tiles,
		groups={ oddly_breakable_by_hand=1 },
		paramtype = "light",
		paramtype2 = "facedir",
		node_box = {
			type = "fixed",
			fixed = def.nodebox
		},
		after_place_node = function(pos, placer)
			local meta = minetest.get_meta(pos)
			local name = placer:get_player_name()
			meta:set_string("owner", name)
			meta:set_string("infotext", "Unnamed turtle\n(owned by "..name..")")
			turtleminer.show_naming_formspec(name, pos)
		end,
		on_rightclick = function(pos, node, clicker)
			if not turtleminer.on_rightclick(pos, node, clicker)
						and minetest.registered_items["turtleminer:remote"] then
				minetest.chat_send_player(clicker:get_player_name(), "Use a remote controller to access the turtle.")
			end
		end,
	})
end

function turtleminer.on_rightclick(pos, node, clicker)
	local name = clicker:get_player_name()
	local meta = minetest.get_meta(pos)
	local def  = turtleminer._def[minetest.get_node(pos).name]
	if not def then
		return
	end

	-- If name not set, show name form
	if not meta:get_string("name") or meta:get_string("name") == "" then
		turtleminer.show_naming_formspec(name, pos)
		return true
	elseif def.on_rightclick then
		def.on_rightclick(pos, node, clicker)
		return true
	end
end
