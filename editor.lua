local bot_editor = editor.editor:new("editor:editor")

local player_attachments = {}
local running_vms = {}

minetest.register_craftitem("turtleminer:programmer", {
	description = "Turtle Programmer",
	inventory_image = "turtleminer_programmer.png",
	on_place = function(itemstack, placer, pointed_thing)
		local nodename = minetest.get_node(pointed_thing.under).name
		local def = minetest.registered_nodes[nodename]
		if def.groups.turtle then
			local name = placer:get_player_name()
			local meta = minetest.get_meta(pointed_thing.under)
			local t_id = meta:get_string("t_id")
			if t_id then
				player_attachments[name] = t_id
				bot_editor:show(name)
				return
			end
		end
		minetest.chat_send_player(placer:get_player_name(), "Right-click a turtle")
	end,
})

local function step()
	for _, vm in pairs(running_vms) do
		vm:step()
	end
	minetest.after(1, step)
end
minetest.after(1, step)

bot_editor:register_button("Run", function(self, name, context)
	local t_id = player_attachments[name]
	if not t_id then
		minetest.chat_send_player("Right-click on the turtle you want to use")
		return
	end

	local code = context.buffer[context.open]
	if code then
		local vm = turtleminer.build_script("singleplayer", t_id, code)
		if type(vm) == "table" then
			running_vms[t_id] = vm
			minetest.chat_send_player(name, "Started program")
		elseif vm then
			minetest.chat_send_player(name, vm)
		else
			minetest.chat_send_player(name, "An unknown error occured")
		end
	else
		minetest.chat_send_player(name, "Could not execute, unable to get code from buffer")
	end
end)

minetest.register_chatcommand("editor", {
	func = function(name, param)
		bot_editor:show(name)
	end
})

minetest.register_on_player_receive_fields(function(player, formname, fields)
	if formname == "editor:editor" then
		local name = player:get_player_name()
		bot_editor:on_event(name, fields)
	elseif formname == "editor:editor_new" then
		local name = player:get_player_name()
		bot_editor:on_new_dialog_event(name, fields)
	end
end)

--
-- Save and load player filesystems from "editor_files" directory
--

local datapath = minetest.get_worldpath() .. "/turtlebot/"
assert(minetest.mkdir(datapath), "[editor] failed to create directory!")

minetest.register_on_joinplayer(function(player)
	local name = player:get_player_name()
	bot_editor:create_player(name)

	local file = io.open(datapath .. "/" .. name .. ".lua", "r")
	if file then
		print("[editor] loading " .. datapath .. "/" .. name .. ".lua")
		file:close()
		bot_editor._context[name].filesystem:load(datapath .. "/" .. name .. ".lua")
	end
end)

local function save_and_delete_player_editor(name)
	local context = bot_editor._context[name]
	assert(context and context.filesystem,
			"Count not save!" .. datapath .. "/" .. name .. ".lua")

	print("[editor] Saved to " .. datapath .. "/" .. name .. ".lua")
	context.filesystem:save(datapath .. "/" .. name .. ".lua")
	bot_editor:delete_player(name)
end

minetest.register_on_leaveplayer(function(player)
	save_and_delete_player_editor(player:get_player_name())
end)

minetest.register_on_shutdown(function()
	for key, value in pairs(bot_editor._context) do
		save_and_delete_player_editor(key)
	end
end)
