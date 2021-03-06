-- turtleminer/turtles.lua

turtleminer.register_turtle("wild", {
	description = "Wild Turtle",
	tiles = {
		"turtleminer_turtle1_top.png",
		"turtleminer_turtle1_bottom.png",
		"turtleminer_turtle1_right.png",
		"turtleminer_turtle1_left.png",
		"turtleminer_turtle1_back.png",
		"turtleminer_turtle1_front.png"
	},
	nodebox = {
		{-0.375, -0.34375, -0.3125, 0.375, 0.28125, 0.4375}, -- main body
		{-0.125, -0.34375, -0.46875, 0.125, -0.09375, -0.3125}, -- head
		{-0.40625, -0.40625, -0.34375, 0.40625, -0.34375, 0.46875}, -- bottom plate
		{-0.03125, -0.46875, 0.375, 0.03125, -0.40625, 0.5}, -- tail
		{-0.40625, -0.5, -0.28125, -0.28125, -0.40625, -0.15625}, -- foot front left
		{0.28125, -0.5, -0.28125, 0.40625, -0.40625, -0.15625}, -- foot front right
		{-0.40625, -0.5, 0.28125, -0.28125, -0.40625, 0.40625 }, -- foot back left
		{0.28125, -0.5, 0.28125, 0.40625, -0.40625, 0.40625}, -- foot back right
	},
})

turtleminer.register_turtle("wlan_turtle", {
	description = "Turtle with WLAN",
	tiles = {
		"turtleminer_turtle2_top.png",
		"turtleminer_turtle2_bottom.png",
		"turtleminer_turtle2_right.png",
		"turtleminer_turtle2_left.png",
		"turtleminer_turtle2_back.png",
		"turtleminer_turtle2_front.png"
	},
	nodebox = {
		{-0.375, -0.34375, -0.3125, 0.375, 0.28125, 0.4375}, -- main body
		{-0.125, -0.34375, -0.46875, 0.125, -0.09375, -0.3125}, -- head
		{-0.40625, -0.40625, -0.34375, 0.40625, -0.34375, 0.46875}, -- bottom plate
		{-0.03125, -0.46875, 0.375, 0.03125, -0.40625, 0.5}, -- tail
		{-0.03125, -0.40625, 0.4375, 0.03125, -0.03125, 0.5}, -- WLAN tail
		{-0.40625, -0.5, -0.28125, -0.28125, -0.40625, -0.15625}, -- foot front left
		{0.28125, -0.5, -0.28125, 0.40625, -0.40625, -0.15625}, -- foot front right
		{-0.40625, -0.5, 0.28125, -0.28125, -0.40625, 0.40625 }, -- foot back left
		{0.28125, -0.5, 0.28125, 0.40625, -0.40625, 0.40625}, -- foot back right
	},
})

turtleminer.register_turtle("digging_turtle", {
	description = "Turtle that can dig",
	tiles = {
		"turtleminer_turtle3_top.png",
		"turtleminer_turtle3_bottom.png",
		"turtleminer_turtle3_right.png",
		"turtleminer_turtle3_left.png",
		"turtleminer_turtle3_back.png",
		"turtleminer_turtle3_front.png"
	},
	nodebox = {
		{-0.375, -0.34375, -0.3125, 0.375, 0.28125, 0.4375}, -- main body
		{-0.125, -0.34375, -0.46875, 0.125, -0.09375, -0.3125}, --head
		{-0.40625, -0.40625, -0.34375, 0.40625, -0.34375, 0.46875}, -- bottom plate
		{-0.03125, -0.46875, 0.375, 0.03125, -0.40625, 0.5}, --tail
		{-0.03125, -0.40625, 0.4375, 0.03125, -0.03125, 0.5}, -- WLAN tail
		{-0.40625, -0.5, -0.28125, -0.28125, -0.40625, -0.15625}, -- foot front left
		{0.28125, -0.5, -0.28125, 0.40625, -0.40625, -0.15625}, -- foot front right
		{-0.40625, -0.5, 0.28125, -0.28125, -0.40625, 0.40625 }, -- foot back left
		{0.28125, -0.5, 0.28125, 0.40625, -0.40625, 0.40625}, -- foot back right
		{-0.15625, -0.125, -0.5, 0.15625, -0.09375, -0.3125},-- hat part shield
		{-0.125, -0.09375, -0.4375, 0.125, -0.03125, -0.3125},-- hat part for head
	},
})

turtleminer.register_turtle("inv_turtle", {
	description = "Turtle with inventory",
	tiles = {
		"turtleminer_turtle4_top.png",
		"turtleminer_turtle4_bottom.png",
		"turtleminer_turtle4_right.png",
		"turtleminer_turtle4_left.png",
		"turtleminer_turtle4_back.png",
		"turtleminer_turtle4_front.png"
	},
	nodebox = {
		{-0.375, -0.34375, -0.3125, 0.375, 0.28125, 0.4375}, -- main body
		{-0.125, -0.34375, -0.46875, 0.125, -0.09375, -0.3125}, -- head
		{-0.40625, -0.40625, -0.34375, 0.40625, -0.34375, 0.46875}, -- bottom plate
		{-0.03125, -0.46875, 0.375, 0.03125, -0.40625, 0.5}, -- tail
		{-0.03125, -0.40625, 0.4375, 0.03125, -0.03125, 0.5}, -- WLAN tail
		{-0.40625, -0.5, -0.28125, -0.28125, -0.40625, -0.15625}, -- foot front left
		{0.28125, -0.5, -0.28125, 0.40625, -0.40625, -0.15625}, -- foot front right
		{-0.40625, -0.5, 0.28125, -0.28125, -0.40625, 0.40625 }, -- foot back left
		{0.28125, -0.5, 0.28125, 0.40625, -0.40625, 0.40625}, -- foot back right
		{-0.15625, -0.125, -0.5, 0.15625, -0.09375, -0.3125},-- hat part shield
		{-0.125, -0.09375, -0.4375, 0.125, -0.03125, -0.3125},-- hat part for head
		{-0.21875, 0.28125, -0.09375, 0.21875, 0.40625, 0.21875} -- backpack
	},
})

-- tech turtle
turtleminer.register_turtle("tech_turtle", {
	description = "Techy Turtle",
	tiles = {
		"turtleminer_tech_turtle_top.png",
		"turtleminer_tech_turtle_bottom.png",
		"turtleminer_tech_turtle_right.png",
		"turtleminer_tech_turtle_left.png",
		"turtleminer_tech_turtle_back.png",
		"turtleminer_tech_turtle_front.png"
	},
	nodebox = {
		{-0.43, -0.37, -0.43, 0.43, 0.4375, 0.43}, -- Turtle
		{-0.3125, -0.42, -0.3125, 0.3125, -0.3, 0.3125}, -- Engine
		{-0.3125, 0.0625, 0.375, 0.3125, 0.375, 0.5}, -- Inventory
	},
})
