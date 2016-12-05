local bot_editor = editor.editor:new("editor:editor")
local filesys = editor.filesystem:new()
filesys:write("main.turtle", "forward\nforward\nleft\nforward\nforward\n")
bot_editor.default_filesystem = filesys

local player_attachments = {}
local running_vms = {}

local old_on_rightclick = turtleminer.on_rightclick
function turtleminer.on_rightclick(pos, node, clicker)
	if old_on_rightclick(pos, node, clicker) then
		return true
	end

	local name = clicker:get_player_name()
	local meta = minetest.get_meta(pos)
	local def  = turtleminer._def[minetest.get_node(pos).name]
	if not def then
		return
	end

	local t_id = meta:get_string("t_id")
	if t_id then
		player_attachments[name] = t_id
		bot_editor:show(name)
		return
	end
end



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
			bot_editor:show(name)
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

bot_editor:register_button("Stop", function(self, name, context)
	local t_id = player_attachments[name]
	if not t_id then
		minetest.chat_send_player("Right-click on the turtle you want to use")
		return
	end

	running_vms[t_id] = nil
	bot_editor:show(name)
end, function(self, name, context)
	return running_vms[player_attachments[name]]
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
