turtleminer = {}
turtleminer.modpath = minetest.get_modpath("turtleminer")

-- [function] formspec
function turtleminer.formspec()
  local formspec =
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
  return formspec -- return formspec text
end

-- [function] editor formspec
function turtleminer.form_editor(contents, debug)
  if not contents then local contents = "" end
  if not debug then local debug = "" end
  -- formspec
  local formspec =
    "size[10,11.25]"..
    default.gui_bg_img..
    "textarea[.25,.25;10.1,9.8;editor;Editor;"..contents.."]"..
    "textarea[.25,9.1;10.1,2;debug;Debug Log;"..debug.."]"..
    "button[0,10.8;1,1;run;Run]"..
    "button[1,10.8;2,1;save;Save]"..
    "button[3,10.8;2,1;reload;Reload]"..
    "button[5,10.8;2,1;clear;Clear]"
  return formspec -- return formspec text
end

-- load turtle resources
dofile(turtleminer.modpath.."/api.lua") -- load api
dofile(turtleminer.modpath.."/turtles.lua") -- turtle registery
