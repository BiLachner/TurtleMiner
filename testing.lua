-- turtleminer/testing.lua

minetest.register_node("turtleminer:unbreakable", {
  description = "Unbreakable",
  groups = {unbreakable = 1},
})

minetest.register_node("turtleminer:multiple_drops", {
  description = "Drop Multiple Items",
  groups = {cracky=2},
  drop = {
    max_items = 2,
    items = {
      {
        items = {
          "default:dirt",
        },
      },
      {
        items = {
          "default:sand",
        },
      }
    }
  }
})
