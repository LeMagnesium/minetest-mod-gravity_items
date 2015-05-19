Minetest mod gravity_items
##########################

A mod inspired by space travels
Version : 0.1

# Authors
 - LeMagnesium / Mg / ElectronLibre : Source code writer

# Purpose
This mod provides multiple nodes and items allowing you to change the value of your gravity property
by multiplying it by a given number (carved into the item/node)

# Media
"gravity_items_null.png" by Mg (CC-BY-SA)
"gravity_items_dot_one.png" by Mg (CC-BY-SA)
"gravity_items_dot_five.png" by Mg (CC-BY-SA)
"gravity_items_one.png" by Mg (CC-BY-SA)
"gravity_items_ten.png" by Mg (CC-BY-SA)

# Special thanks
 - technomancy, how accepted beta of gravity_items as part of his modpack [Calandria](https://github.com/technomancy/calandria.git)
 - kahrl, how reminded me that `set_physics_overrides` doesn't take gravity as an absolute value, but as a multiplier

# API
 - `gravity_items.register_item(name, number)`
  * Registers a gravity item : `gravity_items:name`
  * `name` is the written equivalent of `number` (eg. null = 0, dot_one = 0.1)
  * `number` is the multiplier applied to

 - `gravity_items.register_node(name, number, radius)`
  * Register a gravity node : `gravity_items:name_radius_node`
  * `name`, see above
  * `number`, see above
  * `radius`, radius in which the node will change gravity multiplier
