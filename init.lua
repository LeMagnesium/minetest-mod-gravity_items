-- Gravity items
-- Little mod ßý Mg
-- License : WTFPL

gravity_items = {}

gravity_items.register_item = function(name, number)
    if not number or not name or not type(number) == "number"
            or not type(name) == "string" then
        minetest.log("error", "[gravity_items] Cannot register item without " ..
            "valid number nor valid name")
        return false
    end
    minetest.register_craftitem("gravity_items:"..name.."_item", {
        description = number.." gravity item",
        inventory_image = "gravity_items_" .. name .. ".png",
        on_use = function(itemstack, user, pointed_thing)
            user:set_physics_override({gravity = number})
            minetest.chat_send_player(user:get_player_name(), "Gravity set to "
                .. number)
        end
    })
end

gravity_items.register_node = function(name, number)
    if not number or not name or not tonumber(number)
            or not type(name) == "string" then
        minetest.log("error", "[gravity_items] Cannot register node without " ..
            "valid number nor valid name")
        return false
    end
    minetest.register_node("gravity_items:"..name.."_node", {
        description = number.." gravity node",
        tiles = {"gravity_items_" .. name .. ".png"},
        groups = {oddly_breakable_by_hand = 2},
        on_construct = function(pos)
            local nodetimer = minetest.get_node_timer(pos)
            nodetimer:start(0.1)
            minetest.get_meta(pos):set_string("players", minetest.serialize({}))
        end,
        on_timer = function(pos, elapsed)
            local entities_around = minetest.get_objects_inside_radius(pos, 10)
            local meta = minetest.get_meta(pos)
            local registered_players = meta:get_string("players")
            registered_players = minetest.deserialize(registered_players)

            for _, ref in pairs(entities_around) do
                if ref:is_player() then
                    local playername = ref:get_player_name()
                    ref:set_physics_override({gravity = number})
                    registered_players[playername] = 1
                end
            end
            for name, presence in pairs(registered_players) do
                if presence == 0 then
                    local player = minetest.get_player_by_name(name)
                    player:set_physics_override({gravity = 1})
                    registered_players[name] = nil
                else
                    registered_players[name] = 0
                end
            end
            meta:set_string("players", minetest.serialize(registered_players))
            minetest.get_node_timer(pos):start(0.1)
        end,
        on_destruct = function(pos)
            local meta = minetest.get_meta(pos)
            local players = minetest.deserialize(meta:get_string("players"))
            for name, _ in ipairs(players) do
                local player = minetest.get_player_by_name(name)
                player:set_physics_override({gravity = 1})
            end
        end
    })
end

gravity_items.items = {
    ["null"] = 0,
    ["dot_one"] = 0.1,
    ["dot_five"] = 0.5,
    ["one"] = 1,
    ["ten"] = 10
}

for name, number in pairs(gravity_items.items) do
    gravity_items.register_item(name, number)
    gravity_items.register_node(name, number)
end
