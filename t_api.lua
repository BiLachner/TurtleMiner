-- turtleminer/t_api.lua

local positions = turtleminer.positions -- form positions pointer

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
			meta:set_string("owner", placer:get_player_name()) -- set owner
			meta:set_string("infotext", "Turtle owned by "..placer:get_player_name()) -- set infotext
			meta:set_string("editor", "") -- set editor to blank
		end,
		on_rightclick = function(pos, node, clicker)
			local name = clicker:get_player_name() -- get clicker name
			local meta = minetest.get_meta(pos) -- get meta
			-- if wielding remote control, show formspec
			if clicker:get_wielded_item():get_name() == "turtleminer:remotecontrol" then
				positions[name] = pos -- store turtle position
				minetest.show_formspec(name, "turtleminer:form_editor", turtleminer.form_editor(meta:get_string("editor"), ""))
			else
				minetest.chat_send_player(name, "Use a remote controller to access the turtle.")
			end
		end,
	})
end

-- [function] process main form
local function p_main(sender, fields)
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
	elseif fields.digbottom then turtleminer.dig(pos, "below", name) end -- elseif dig bottom button, dig below
end

-- [function] process editor form
local function p_editor(sender, fields)
	local name = sender:get_player_name()
	local pos = positions[name]

	if not pos then return end -- if not position, return - something is wrong

	local meta = minetest.get_meta(pos) -- node info

	if fields.run then
		meta:set_string("editor", fields.editor)
		local res = turtleminer.run_string(pos, name, fields.editor) -- result (error msg)
		if res then -- if res (error msg), set debug
			minetest.log("action", res)
			minetest.show_formspec(name, "turtleminer:form_editor", turtleminer.form_editor(fields.editor, res))
		end
	elseif fields.save then meta:set_string("editor", fields.editor)
	elseif fields.reload then
		minetest.show_formspec(name, "turtleminer:form_editor", turtleminer.form_editor(meta:get_string("editor"), ""))
	elseif fields.clear then
		meta:set_string("editor", "")
		minetest.show_formspec(name, "turtleminer:form_editor", turtleminer.form_editor("", ""))
	end
end

-- on player fields received
minetest.register_on_player_receive_fields(function(sender, formname, fields)
	-- process form(s)
	if formname == "turtleminer:form_main" then p_main(sender, fields)
	elseif formname == "turtleminer:form_editor" then p_editor(sender, fields) end
end)
