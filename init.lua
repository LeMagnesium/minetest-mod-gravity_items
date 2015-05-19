-- Gravity items
-- Little mod ßý Mg
-- License : WTFPL

gravity_items = {}
gravity_items.datas = {}

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

gravity_items.register_node = function(name, number, radius)
    if not number or not name or not tonumber(number)
            or not type(name) == "string" then
        minetest.log("error", "[gravity_items] Cannot register node without " ..
            "valid number nor valid name")
        return false
    end
    minetest.register_node("gravity_items:"..name.."_"..radius.."_node", {
        description = number.." gravity node (radius " .. radius .. ")",
        tiles = {"gravity_items_" .. name .. ".png"},
        groups = {oddly_breakable_by_hand = 2},
        on_construct = function(pos)
            local nodetimer = minetest.get_node_timer(pos)
            nodetimer:start(0.1)
            minetest.get_meta(pos):set_string("players", minetest.serialize({}))
        end,
        on_timer = function(pos, elapsed)
            local entities_around = minetest.get_objects_inside_radius(pos, radius)
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
                    if player then
                        player:set_physics_override({gravity = 1})
                    end
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
            for name, _ in pairs(players) do
                local player = minetest.get_player_by_name(name)
                player:set_physics_override({gravity = 1})
            end
        end
    })
end

gravity_items.datas.items = {
    ["null"] = {value = 0, radiuses = {5, 10, 15, 30}},
    ["dot_one"] = {value = 0.1, radiuses = {10,20,30}},
    ["dot_five"] = {value = 0.5, radiuses = {10,15,20}},
    ["one"] = {value = 1, radiuses = {10,20}},
    ["ten"] = {value = 10, radiuses = {10}},
}

for name, datas in pairs(gravity_items.datas.items) do
    gravity_items.register_item(name, datas.value)
    for _, radius in pairs(datas.radiuses) do
        gravity_items.register_node(name, datas.value, radius)
    end
    minetest.register_alias("gravity_items:"..name.."_"..datas.radiuses[1].."_node", "gravity_items:"..name.."_node")
end
