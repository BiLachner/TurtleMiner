-- turtleminer/t_api.lua

------------------
-- LOAD TURTLES --
------------------

turtleminer.turtles = {}
local turtles = turtleminer.turtles

function turtleminer.load()
	local file = io.open(minetest.get_worldpath() .. "/turtles.list", "r")
	if file then
		local from_file = minetest.deserialize(file:read("*all"))
		file:close()
		if type(from_file) == "table" and type(from_file.turtles) == "table" then
			turtleminer.turtles = from_file.turtles
			turtles = turtleminer.turtles
		end
	end
end

function turtleminer.save()
	local file = io.open(minetest.get_worldpath().."/turtles.list", "w")
	if file then
		file:write(minetest.serialize({
			version = 1,
			turtles = turtleminer.turtles
		}))
		file:close()
	else
		assert(false)
	end
end

minetest.register_on_shutdown(turtleminer.save)

turtleminer.load()

----------------------
-- HELPER FUNCTIONS --
----------------------

-- [function] update position
function turtleminer.update_pos(t_id, new_pos)
	if not turtles[t_id] then return false end -- something's wrong
	turtles[t_id].pos = new_pos -- update position
end

-- [function] run command
function turtleminer.run(name, pos, cmd, ...)
	local t_id = minetest.get_meta(pos):get_string("t_id") -- get t_id
	local result = turtleminer[cmd](pos, ...) -- run command
	if not result then return end -- no result

	-- play sound
	if result.sound == true and name then
		minetest.sound_play("moveokay", { to_player = name })
	elseif result.sound == false and name then
		minetest.sound_play("moveerror", { to_player = name })
	end

	-- update position
	if type(result.pos) == "table" then
		turtleminer.update_pos(t_id, result.pos)
	end

	-- send message
	if result.msg then
		minetest.chat_send_player(name, result.msg)
	end
end

--------------
-- FORMSPEC --
--------------

local form_contexts = {}

-- formspec pages
turtleminer.forms = {
	naming = {
		get = function(pos)
			local meta = minetest.get_meta(pos)
			local t_id = meta:get_string("t_id")

			return
				"size[6,1.7]"..
				default.gui_bg_img..
				"field[.25,0.50;6,1;name;Name Your Turtle:;]"..
				"button_exit[4.95,1;1,1;submit_name;Set]"
		end,
		on_receive_fields = function(player, fields)
			local name = player:get_player_name()
			local turtle = turtles[form_contexts[name].t_id]

			if not turtle then
				minetest.chat_send_player(name, "Unable to find the turtle (id="..minetest.pos_to_string(t_id)..")")
				return
			end

			local pos = turtle.pos
			local meta = minetest.get_meta(pos)
			local tname = fields.name
			if (fields.submit_name or fields.key_enter_field == "name") and tname and tname ~= "" then
				meta:set_string("name", tname) -- set turtle name
				meta:set_string("setup", "true") -- set setup boolean string
				meta:set_string("infotext", tname .. "\n(owned by "..name..")") -- set infotext
				turtle.name = tname
			end
		end,
	},
	main = {
		get = function(pos)
			local meta = minetest.get_meta(pos)
			local tname, t_id = meta:get_string("name"), meta:get_string("t_id")
			return
				"size[6,4]" ..
				"tabheader[0,0;tabs;Main,Inventory;1]" ..
				"label[0,0;"..tname.." - id: "..t_id.."]" ..
				"button_exit[4.3,-0.3;1.9,1;pos;"..minetest.pos_to_string(pos).."]" ..
				"tooltip[pos;Refresh Position;#35454D;#FFFFFF]" ..
				"label[0,0.5;Use the buttons to interact with your turtle.]" ..
				"button_exit[4,1;1,1;exit;Exit]" ..
				"image_button[0,1;1,1;turtleminer_remote_arrow_up.png;up;]" ..
				"tooltip[up;Up;#35454D;#FFFFFF]" ..
				"image_button[1,1;1,1;turtleminer_remote_arrow_fw.png;forward;]" ..
				"tooltip[forward;Move Forward;#35454D;#FFFFFF]" ..
				"image_button[2,1;1,1;turtleminer_remote_dig_front.png;digfront;]" ..
				"tooltip[digfront;Dig in Front;#35454D;#FFFFFF]" ..
				"image_button[2,3;1,1;turtleminer_remote_dig_down.png;digbottom;]" ..
				"tooltip[digbottom;Dig Beneath;#35454D;#FFFFFF]" ..
				"image_button[3,1;1,1;turtleminer_remote_build_front.png;buildfront;]" ..
				"tooltip[buildfront;Build in Front;#35454D;#FFFFFF]" ..
				"image_button[3,3;1,1;turtleminer_remote_build_down.png;buildbottom;]" ..
				"tooltip[buildbottom;Build Beneath;#35454D;#FFFFFF]" ..
				"image_button[0,2;1,1;turtleminer_remote_arrow_left.png;turnleft;]"..
				"tooltip[turnleft;Turn Left;#35454D;#FFFFFF]" ..
				"image_button[2,2;1,1;turtleminer_remote_arrow_right.png;turnright;]" ..
				"tooltip[turnright;Turn Right;#35454D;#FFFFFF]" ..
				"image_button[0,3;1,1;turtleminer_remote_arrow_down.png;down;]" ..
				"tooltip[down;Down;#35454D;#FFFFFF]" ..
				"image_button[1,3;1,1;turtleminer_remote_arrow_bw.png;backward;]" ..
				"tooltip[backward;Move Backward;#35454D;#FFFFFF]"
		end,
		on_receive_fields = function(player, fields)
			local name = player:get_player_name()
			local turtle = turtles[form_contexts[name].t_id]

			local pos = turtle.pos

			if fields.tabs == "2" then
        turtleminer.open(pos, player, "inventory")
        return
      end

			local run = turtleminer.run
			if 		 fields.turnright   then run(name, pos, "rotate", "right")
			elseif fields.turnleft    then run(name, pos, "rotate", "left")
			elseif fields.forward     then run(name, pos, "move",   "forward")
			elseif fields.backward    then run(name, pos, "move",   "backward")
			elseif fields.up          then run(name, pos, "move",   "up")
			elseif fields.down        then run(name, pos, "move",   "down")
			elseif fields.digfront    then run(name, pos, "dig",    "front")
			elseif fields.digbottom   then run(name, pos, "dig",    "below")
			elseif fields.buildfront  then run(name, pos, "build",  "front")
			elseif fields.buildbottom then run(name, pos, "build",  "below")
			elseif fields.pos					then turtleminer.open(pos, player) -- update formspec
			end
		end,
	},
	inventory = {
		get = function(pos)
			local spos = pos.x .. "," .. pos.y .. "," .. pos.z

			return
				"size[9,9]" ..
				"tabheader[0,0;tabs;Main,Inventory;2]" ..
				default.gui_bg ..
				default.gui_bg_img ..
				default.gui_slots ..
				"list[nodemeta:" .. spos .. ";main;0,0.3;8,4;]" ..
				"list[nodemeta:" .. spos .. ";place_node;8.07,1.8;8,4;]" ..
				"label[8.07,2.7;Node\nto\nplace]" ..
				"list[current_player;main;0,4.85;8,1;]" ..
				"list[current_player;main;0,6.08;8,3;8]" ..
				"listring[nodemeta:" .. spos .. ";main]" ..
				"listring[current_player;main]" ..
				default.get_hotbar_bg(0,4.85)
		end,
		on_receive_fields = function(player, fields)
			local name = player:get_player_name()
			local turtle = turtles[form_contexts[name].t_id]
			local pos = turtle.pos

			if fields.tabs == "1" then
        turtleminer.open(pos, player, "main")
        return
      end
		end,
	}
}

-- [function] open formspec (on_rightclick)
function turtleminer.open(pos, player, formname)
	assert(pos, "turtleminer.open missing position")

  local meta = minetest.get_meta(pos)
  local name = player:get_player_name()

  if meta:get_string("setup") == "false" then
    form_contexts[name] = { t_id = meta:get_string("t_id"), form = "naming", } -- set context
    minetest.show_formspec(name, "turtleminer:naming", turtleminer.forms["naming"].get(pos))
  else
		local form
		if not formname then
			if meta:get_string("formname") == "" then
				form = "main"
			else
				form = meta:get_string("formname")
			end
		else
			form = formname
		end

		meta:set_string("formname", form)
    form_contexts[name] = { t_id = meta:get_string("t_id"), form = form, } -- set context
    minetest.show_formspec(name, "turtleminer:"..form, turtleminer.forms[form].get(pos))
  end
end

-- [event] on receive fields
minetest.register_on_player_receive_fields(function(player, formname, fields)
  local formname = formname:split(":")[2]
  if turtleminer.forms[formname] then
    turtleminer.forms[formname].on_receive_fields(player, fields)
  end
end)

---------------
-- FUNCTIONS --
---------------

-- [local function] get table length
local function getTableLength(t)
	if not t then return nil end
  local count = 0
  for _ in pairs(t) do count = count + 1 end
  return count
end

-- [local function] check itemstack validity
local function check_itemstack(stack)
	if not stack:is_empty() and stack:is_known() then
		return true
	end
end

-- [function] check if breakable
function turtleminer.is_breakable(pos)
	if minetest.registered_nodes[minetest.get_node(pos).name].groups.unbreakable ~= 1 then return true end
end

-- [function] check for room in turtle inventory
function turtleminer.check_for_room(pos, stackstring, listname)
	if not listname then
		listname = "main"
	end

	local meta = minetest.get_meta(pos)
	assert(meta, "turtleminer.check_for_room missing meta")

	local inv = meta:get_inventory()
	local stack = ItemStack(stackstring)
	if check_itemstack(stack) then
		if not inv:room_for_item(listname, stack) then
			return nil, "Not enough room"
		end
		return true
	end
end

-- [function] check if inventory contains item
function turtleminer.has_item(pos, stackstring, listname)
	if not listname then
		listname = "main"
	end

	local meta = minetest.get_meta(pos)
	assert(meta, "turtleminer.check_for_room missing meta")

	local inv = meta:get_inventory()
	local stack = ItemStack(stackstring)

	if check_itemstack(stack) then
		if inv:contains_item(listname, stack) then
			return true
		end
	end
end

-- [function] add item to turtle inventory
function turtleminer.add_item(pos, stackstring, listname)
	if not listname then
		listname = "main"
	end

	local meta = minetest.get_meta(pos)
	assert(meta, "turtleminer.check_for_room missing meta")

	local inv = meta:get_inventory()
	local stack = ItemStack(stackstring)

	if check_itemstack(stack) then
		local leftover = inv:add_item(listname, stack)
		if leftover:get_count() > 0 then
			return false, leftover, "Inventory is full! " .. leftover:get_count() .. " items weren't added"
		else
			return true
		end
	end
end

-- [function] take item from turtle inventory
function turtleminer.take_item(pos, stackstring, listname)
	if not listname then
		listname = "main"
	end

	local meta = minetest.get_meta(pos)
	assert(meta, "turtleminer.check_for_room missing meta")

	local inv = meta:get_inventory()
	local stack = ItemStack(stackstring)

	if check_itemstack(stack) then
		local taken = inv:remove_item(listname, stack)
		return true, taken:get_count()
	end
end

-- [function] rotate
function turtleminer.rotate(pos, direction)
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
	end
	return { sound = true } -- return sound
end

-- [function] move
function turtleminer.move(pos, direction)
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
			minetest.get_meta(new_pos):from_table(oldmeta) -- set new meta

			-- if not walkable, move entity
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

			return { sound = true, pos = new_pos, }
		else -- else, return false
			return { sound = false }
		end
	end

	-- if direction is forward, move forward
	if direction == "forward" or direction == "f" then
		-- calculate new coords
		new_pos.z = new_pos.z - dir.z
		new_pos.x = new_pos.x - dir.x
		entity_pos.z = entity_pos.z - dir.z * 2
		entity_pos.x = entity_pos.x - dir.x * 2
		return turtle_move(pos, new_pos, entity_pos) -- call local function
	elseif direction == "backward" or direction == "b" then
		new_pos.z = new_pos.z + dir.z
		new_pos.x = new_pos.x + dir.x
		entity_pos.z = entity_pos.z + dir.z * 2
		entity_pos.x = entity_pos.x + dir.x * 2
		return turtle_move(pos, new_pos, entity_pos) -- call local function
	elseif direction == "up" or direction == "u" then
		new_pos.y = new_pos.y + 1
		entity_pos.y = entity_pos.y + 2
		return turtle_move(pos, new_pos, entity_pos) -- call local function
	elseif direction == "down" or direction == "d" then
		new_pos.y = new_pos.y - 1
		entity_pos.y = entity_pos.y - 2
		return turtle_move(pos, new_pos, entity_pos) -- call local function
	end
end

-- [function] dig
function turtleminer.dig(pos, where)
	-- [function] dig
	local function dig(dig_pos)
		if minetest.get_node_or_nil(dig_pos) and turtleminer.is_breakable(dig_pos) then -- if node & breakable, dig
			local dig_node = minetest.get_node(dig_pos)
			local itemstacks = minetest.get_node_drops(dig_node.name)

			for _, itemname in ipairs(itemstacks) do
				local ok, leftover, msg = turtleminer.add_item(pos, itemname)

				if ok == false then
						minetest.add_item(dig_pos, itemname)
				end
			end

			minetest.set_node(dig_pos, { name = "air" })
			nodeupdate(dig_pos)
			return { sound = true } -- return sound
		else return { sound = false } end -- else, return error sound
	end

	local node = minetest.get_node(pos) -- get node ref
	local dir = minetest.facedir_to_dir(node.param2) -- get facedir
	local dig_pos = vector.new(pos) -- dig position

	if where == "front" then -- if where is front, dig in front
		-- adjust position considering facedir
		dig_pos.z = dig_pos.z - dir.z
		dig_pos.x = dig_pos.x - dir.x
		return dig(dig_pos) -- dig node in front if not unbreakable
	elseif where == "below" then -- elseif where is below, dig below
		dig_pos.y = dig_pos.y - 1 -- remove 1 from dig_pos y axis
		return dig(dig_pos) -- dig node below if not unbreakable
	end
end

-- [function] build
function turtleminer.build(pos, where)
	local inv = minetest.get_meta(pos):get_inventory()

	-- [function] build
	local function build(pos)
		if minetest.registered_nodes[minetest.get_node(pos).name].buildable_to then -- if is buildable_to, build
			if inv:is_empty("place_node") then
				return { sound = false }
			else
				local place_stack = inv:get_list("place_node")[1]
				local place_name = place_stack:get_name()

				if minetest.registered_nodes[place_name] then
					inv:remove_item("place_node", place_name.." 1")
					minetest.set_node(pos, { name = place_name })
					nodeupdate(pos)
					return { sound = true } -- return sound
				else
					return { sound = false }
				end
			end
		else return { sound = false } end -- else, return error sound
	end

	local node = minetest.get_node(pos) -- get node ref
	local dir = minetest.facedir_to_dir(node.param2) -- get facedir
	local build_pos = vector.new(pos) -- dig position

	if where == "front" then -- if where is front, dig in front
		-- adjust position considering facedir
		build_pos.z = build_pos.z - dir.z
		build_pos.x = build_pos.x - dir.x
		return build(build_pos) -- dig node in front
	elseif where == "below" then -- elseif where is below, dig below
		build_pos.y = build_pos.y - 1 -- remove 1 from dig_pos y axis
		return build(build_pos) -- dig node below
	end
end

--------------
-- NODE DEF --
--------------

local turtle_id_counter = getTableLength(turtles) or 0 -- get id of last turtle

-- [function] register turtle
function turtleminer.register_turtle(turtlestring, desc)
	minetest.register_node("turtleminer:"..turtlestring, {
		drawtype = "nodebox",
		description = desc.description,
		tiles = desc.tiles,
		groups={ oddly_breakable_by_hand = 1, turtle = 1 },
		light_source = desc.light_source or 7,
		paramtype = "light",
		paramtype2 = "facedir",
		node_box = {
			type = "fixed",
			fixed = desc.nodebox
		},
		after_place_node = function(pos, placer)
			local meta = minetest.get_meta(pos)
			local name = placer:get_player_name()

			turtle_id_counter = turtle_id_counter + 1
			local t_id = "t_" .. turtle_id_counter
			turtles[t_id] = {
				pos = pos,
				owner = name,
				name = nil,
			}
			turtleminer.save()

			meta:set_string("owner", name) -- set owner
			meta:set_string("t_id", t_id) -- set turtle id
			meta:set_string("setup", "false") -- set setup boolean string
			meta:set_string("infotext", "Unnamed turtle\n(owned by "..name..")") -- set name

			local inv = minetest.get_inventory({type="node", pos={x=pos.x, y=pos.y, z=pos.z}})
			inv:set_size("main", 8*4)
			inv:set_size("place_node", 1*1)
		end,
		on_dig = function(pos, node, player)
			turtles[minetest.get_meta(pos):get_string("t_id")] = nil -- clear entry
			turtleminer.save() -- save
			minetest.node_dig(pos, node, player)
		end,
		on_rightclick = function(pos, node, player)
			turtleminer.open(pos, player)
		end,
		can_dig = function(pos,player)
			local meta = minetest.get_meta(pos);
			local inv = meta:get_inventory()
			return inv:is_empty("main")
		end,

		on_metadata_inventory_move = function(pos, from_list, from_index,
				to_list, to_index, count, player)
			turtleminer.log(player:get_player_name() ..
				" moves stuff in turtle inventory at " .. minetest.pos_to_string(pos))
		end,
	  on_metadata_inventory_put = function(pos, listname, index, stack, player)
			turtleminer.log(player:get_player_name() ..
				" moves " .. stack:get_name() ..
				" to turtle inventory at " .. minetest.pos_to_string(pos))
		end,
	  on_metadata_inventory_take = function(pos, listname, index, stack, player)
			turtleminer.log(player:get_player_name() ..
				" takes " .. stack:get_name() ..
				" from turtle inventory at " .. minetest.pos_to_string(pos))
		end,
		on_blast = function(pos)
			local drops = {}
			default.get_inventory_drops(pos, "main", drops)
			drops[#drops+1] = "turtleminer:"..turtlestring
			minetest.remove_node(pos)
			return drops
		end,
	})
end
