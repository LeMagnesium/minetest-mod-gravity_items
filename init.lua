-- Gravity items
-- Little mod ßý Mg
-- License : WTFPL

gravity_items = {}
gravity_items.data = {}
gravity_items.p_override = {}


function movement_loop(player)
	local ctrls = player:get_player_control()
	if ctrls.jump then
		local v = (player:getvelocity() or {x = 0, z = 0})
		player:setvelocity({x = v.x, y = 10, z = v.z})
	elseif ctrls.down then
		local v = (player:getvelocity() or {x = 0, z = 0})
		player:setvelocity({x = v.x, y = -10, z = v.z})
	end

	if not gravity_items.p_override[player:get_player_name()] or gravity_items.p_override[player:get_player_name()] ~= 0 then
		return
	end
	minetest.after(0.1, movement_loop, player)
end

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
            gravity_items.p_override[user:get_player_name()] = number
            user:set_physics_override({gravity = number})
            minetest.chat_send_player(user:get_player_name(), "Gravity set to "
                .. number)
            if number == 0 then
                movement_loop(user)
            end
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
                    gravity_items.p_override[ref:get_player_name()] = number
                    ref:set_physics_override({gravity = number})
                    registered_players[playername] = 1
                end
            end
            for name, presence in pairs(registered_players) do
                if presence == 0 then
                    local player = minetest.get_player_by_name(name)
                    if player then
                        player:set_physics_override({gravity = 1})
                        gravity_items.p_override[player:get_player_name()] = nil
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
                gravity_items.p_override[player:get_player_name()] = nil
            end
        end
    })
end

gravity_items.data.items = {
    ["negative_point_one"] = {value = -0.1, radiuses = {5,10,15,20,25}},
    ["null"] = {value = 0, radiuses = {5, 10, 15, 30}},
    ["point_one"] = {value = 0.1, radiuses = {10,20,30}},
    ["point_five"] = {value = 0.5, radiuses = {10,15,20}},
    ["one"] = {value = 1, radiuses = {10,20}},
    ["ten"] = {value = 10, radiuses = {10}},
}

for name, data in pairs(gravity_items.data.items) do
    gravity_items.register_item(name, data.value)
    for _, radius in pairs(data.radiuses) do
        gravity_items.register_node(name, data.value, radius)
    end
   -- minetest.register_alias("gravity_items:"..name.."_"..data.radiuses[1].."_node", "gravity_items:"..name.."_node")
end
