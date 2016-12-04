local bot_editor = editor.editor:new("editor:editor")

bot_editor:register_button("Run", function(self, name, context)
	local code = context.buffer[context.open]
	if code then
		-- TODO: run code
		minetest.chat_send_player(name, "Running of code not yet supported")
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
