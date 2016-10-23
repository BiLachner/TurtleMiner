-- turtleminer/api.lua

local modpath = turtleminer.modpath -- modpath pointer

---------------
-- FUNCTIONS --
---------------

turtleminer.positions = {} -- form positions
local positions = turtleminer.positions -- form positions pointer

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

	local function turtle_move(pos, new_pos)
		-- if not walkable, proceed
		if not minetest.registered_nodes[minetest.get_node(new_pos).name].walkable then
			minetest.remove_node(pos) -- remote old node
			minetest.set_node(new_pos, node) -- create new node
			positions[name] = new_pos -- update position
			minetest.get_meta(new_pos):from_table(oldmeta) -- set new meta

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
		turtle_move(pos, new_pos) -- call local function
	elseif direction == "backward" or direction == "b" then
		new_pos.z = new_pos.z + dir.z
		new_pos.x = new_pos.x + dir.x
		turtle_move(pos, new_pos) -- call local function
	elseif direction == "up" or direction == "u" then
		new_pos.y = new_pos.y + 1
		turtle_move(pos, new_pos) -- call local function
	elseif direction == "down" or direction == "d" then
		new_pos.y = new_pos.y - 1
		turtle_move(pos, new_pos) -- call local function
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

-------------
-- DOFILES --
-------------

dofile(modpath.."/env.lua") -- environment
dofile(modpath.."/t_api.lua") -- register api
