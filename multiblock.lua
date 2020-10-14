-- © 2017 numberZero
-- License: GNU Lesser General Public License, version 2 (or any later version)

digiline_routing.multiblock = {}

digiline_routing.multiblock.build2 = function(node1, node2, itemstack, placer, pointed_thing)
	local under = pointed_thing.under
	local above = pointed_thing.above
	local pos
	if minetest.registered_items[minetest.get_node(under).name].buildable_to then
		pos = under
	elseif minetest.registered_items[minetest.get_node(above).name].buildable_to then
		pos = above
	else
		return itemstack, false
	end

	if digiline_routing.is_protected(pos, placer) then
		return itemstack, false
	end

	local dir = minetest.dir_to_facedir(placer:get_look_dir())
	local botpos = vector.add(pos, minetest.facedir_to_dir(dir))

	if digiline_routing.is_protected(botpos, placer) then
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

-- only ever called when using screwdriver:screwdriver
digiline_routing.multiblock.rotate2 = function(pos, node, user, mode, new_param2)
	local dir = minetest.facedir_to_dir(node.param2)
	local p = vector.add(pos, dir)
	local node2 = minetest.get_node_or_nil(p)
	if not node2 or node.param2 ~= node2.param2 then
		return false
	end
	-- protection at `pos` is checked by the screwdriver
	if digiline_routing.is_protected(p, user) then
		return false
	end
	if mode ~= screwdriver.ROTATE_FACE then
		return false
	end
	local newp = vector.add(pos, minetest.facedir_to_dir(new_param2))
	local node3 = minetest.get_node_or_nil(newp)
	local node_def = node3 and minetest.registered_nodes[node3.name]
	if not node_def or not node_def.buildable_to then
		return false
	end
	if digiline_routing.is_protected(newp, user) then
		return false
	end
	node.param2 = new_param2
	minetest.set_node(p, {name = "air"})
	minetest.set_node(pos, node)
	minetest.set_node(newp, {name = node2.name, param2 = new_param2})
	digiline:update_autoconnect(p)
	digiline:update_autoconnect(pos)
	digiline:update_autoconnect(newp)
	return true
end

digiline_routing.multiblock.rotate2b = function(pos, node, user, mode, new_param2)
	minetest.log("action", ("%s tries to rotate invisible node at %s"):format(user:get_player_name(), minetest.pos_to_string(pos)))
	return false
end

digiline_routing.tail_pos_or_nil = function(pos, node)
	local dirs = {
		{ x = -1,z = 0},
		{ x = 1, z = 0},
		{ x = 0, z = -1},
		{ x = 0, z = 1}
	}
	local tail_pos
	local tail_node
	for _, dir in ipairs(dirs) do
		dir.y = 0
		tail_pos = vector.add(pos, dir)
		tail_node = minetest.get_node_or_nil(tail_pos)
		if tail_node and tail_node.name == node.name .. "_b" then
			-- possible match, according to name
			-- can't be a match if no param2
			if nil ~= tail_node.param2 then
				if minetest.dir_to_facedir(dir) == tail_node.param2 then
					-- match found, return it's position
					return tail_pos
				end
			end
		end
	end
	-- nothing found
	return nil
end

digiline_routing.multiblock.dig2 = function(pos, node)
	local tail_pos = digiline_routing.tail_pos_or_nil(pos, node)

	-- nothing we can do if partner was not found
	if not tail_pos then return end

	minetest.remove_node(tail_pos)
	digiline:update_autoconnect(tail_pos)
end

digiline_routing.multiblock.dig2b = function(pos, node, digger)
	local dir = minetest.facedir_to_dir(node.param2)
	local head = vector.subtract(pos, dir)
	local node2 = minetest.get_node_or_nil(head)
	if not node2 then -- master unloaded, let’s not break the structure
		return
	end
	if node2.param2 == node.param2 then
		minetest.node_dig(head, node2, digger)
	else -- broken multinode structure, just remove it
		minetest.remove_node(pos)
	end
end

