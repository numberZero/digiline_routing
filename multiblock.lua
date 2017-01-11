-- © 2017 numberZero
-- License: GNU Lesser General Public License, version 2 (or any later version)

digiline_routing.multiblock = {}

digiline_routing.multiblock.build2 = function(node1, node2, itemstack, placer, pointed_thing)
	local under = pointed_thing.under
	local pos
	if minetest.registered_items[minetest.get_node(under).name].buildable_to then
		pos = under
	else
		pos = pointed_thing.above
	end

	if minetest.is_protected(pos, placer:get_player_name()) and not minetest.check_player_privs(placer, "protection_bypass") then
		minetest.record_protection_violation(pos, placer:get_player_name())
		return itemstack, false
	end

	local dir = minetest.dir_to_facedir(placer:get_look_dir())
	local botpos = vector.add(pos, minetest.facedir_to_dir(dir))

	if minetest.is_protected(botpos, placer:get_player_name()) and not minetest.check_player_privs(placer, "protection_bypass") then
		minetest.record_protection_violation(botpos, placer:get_player_name())
		return itemstack, false
	end

	if not minetest.registered_nodes[minetest.get_node(botpos).name].buildable_to then
		return itemstack, false
	end

	minetest.set_node(pos, {name = node1, param2 = dir})
	minetest.set_node(botpos, {name = node2, param2 = dir})

	digiline:update_autoconnect(pos)
	digiline:update_autoconnect(botpos)

	if not minetest.setting_getbool("creative_mode") then
		itemstack:take_item()
	end
	return itemstack, true
end

local removing_head = false

digiline_routing.multiblock.dig2 = function(pos, node)
	if removing_head then
		error("Infinite recursion detected")
	end
	removing_head = true
	local dir = minetest.facedir_to_dir(node.param2)
	local tail = vector.add(pos, dir)
	minetest.dig_node(tail)
	removing_head = false
end

digiline_routing.multiblock.dig2b = function(pos, node)
	local dir = minetest.facedir_to_dir(node.param2)
	local head = vector.subtract(pos, dir)
	if not removing_head then
		minetest.dig_node(head)
	end
end
