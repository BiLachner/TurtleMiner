-- turtleminer/remote.lua
local BASENAME = "turtleminer"

-- register item
minetest.register_craftitem(BASENAME..":remote", {
  description = "Remote Control",
  inventory_image = "turtleminer_remote.png",
  stack_max = 1,
  on_place = function(itemstack, placer, pointed_thing)
    local pos = pointed_thing.under
    local name = placer:get_player_name() -- get player name

    -- if pointed at turtle, then bind
    if minetest.registered_nodes[minetest.get_node(pos).name].groups.turtle == 1 then
      local itemdata = {} -- define
      local nodemeta = minetest.get_meta(pos)
      local res = minetest.deserialize(itemstack:get_metadata()) -- get meta
      if type(res) == "table" then itemdata = res end

      local t_id = nodemeta:get_string("t_id")
      local tname = nodemeta:get_string("name")

      -- if already bound to turtle, send chat message
      if itemdata and itemdata.id == t_id and itemdata.name == tname then
        return minetest.chat_send_player(name, "Already bound to "..tname.." ("..t_id..").")
      elseif itemdata and itemdata.id == t_id and itemdata.name ~= tname then -- elseif name changed, send msg
        minetest.chat_send_player(name, "Updated "..t_id.."'s name to "..tname.." ("..t_id..").")
      else -- else, send msg
        minetest.chat_send_player(name, "Bound to "..tname.." ("..t_id..").")
      end

      itemdata = { id = t_id, name = tname, bound_by = name } -- update table
      itemstack:set_metadata(minetest.serialize(itemdata)) -- set metadata
      return itemstack
    else -- else, send msg
      local meta = minetest.deserialize(itemstack:get_metadata()) -- get meta

      if not meta then
        minetest.chat_send_player(name, "Right-click a turtle to bind to it.")
      else
        minetest.chat_send_player(name, "Already bound to a turtle ("..meta.name.."). Right-click another to bind to it instead.")
      end
    end
  end,
  on_use = function(itemstack, player, pointed_thing)
    local name = player:get_player_name() -- get player name
    local meta = minetest.deserialize(itemstack:get_metadata()) -- get meta
    if not meta then -- if no data, return msg
      return minetest.chat_send_player(name, "Bind to a turtle (right-click) before using the remote.")
    elseif meta.id then -- elseif id is available, check id
      local turtle = turtleminer.turtles[meta.id]
      if turtle then -- if pos, show form
        turtleminer.open(turtle.pos, player)
      else -- else, return error
        return minetest.chat_send_player(name, "Unable to find "..meta.name.." (id="..meta.id..").")
      end
    end
  end,
})
