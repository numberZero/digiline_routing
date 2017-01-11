-- © 2017 numberZero
-- License: GNU Lesser General Public License, version 2 (or any later version)

local OVERLOAD_THRESHOLD = 20.0

local BASE_RULES = {
	[0] = {x = -1, y = 0, z = 0},
	[1] = {x = 0, y = 0, z = 1},
	[2] = {x = 1, y = 0, z = 0},
	[3] = {x = 0, y = 0, z = -1},
}

local rules_in = {}
local rules_out = {}

for k = 0,3 do
	rules_in[k] = {}
	rules_out[k] = {}
-- 	for m = 0,2 do
-- 		table.insert(rules_in[k], BASE_RULES[(k + m + 3) % 4])
-- 		table.insert(rules_out[k], BASE_RULES[(k + m + 1) % 4])
-- 	end
	table.insert(rules_in[k], BASE_RULES[(k) % 4])
	table.insert(rules_in[k], BASE_RULES[(k + 2) % 4])
	table.insert(rules_out[k], BASE_RULES[(k + 1) % 4])
end

local function splitter_rules_in(node)
	return rules_in[node.param2]
end

local function splitter_rules_out(node)
	return rules_out[node.param2]
end

local function splitter_place(...)
	return (digiline_routing.multiblock.build2("digiline_routing:splitter", "digiline_routing:splitter_b", ...)) -- adjust to 1 value
end

local function splitter_cleanup(pos, node)
	digiline_routing.overheat.forget(pos)
	digiline_routing.multiblock.dig2(pos, node)
end

local function splitter_in_action(pos, node, channel, msg)
	if digiline_routing.overheat.heat(pos) > OVERLOAD_THRESHOLD then
		minetest.dig_node(pos)
		minetest.add_item(pos, node.name)
		return
	end
	local off = minetest.facedir_to_dir(node.param2)
	local slave = vector.add(pos, off)
	digiline:receptor_send(slave, splitter_rules_out(node), channel, msg)
end

local function splitter_out_action(pos, node, channel, msg)
	local off = minetest.facedir_to_dir(node.param2)
	local master = vector.subtract(pos, off)
	if digiline_routing.overheat.heat(master) > OVERLOAD_THRESHOLD then
		minetest.dig_node(master)
		minetest.add_item(master, node.name)
		return
	end
	digiline:receptor_send(master, splitter_rules_in(node), channel, msg)
end

minetest.register_node("digiline_routing:splitter", {
	description = "Digiline Splitter",
	drawtype = "nodebox",
	tiles = {
		"digiline_routing_metal.png"
	},
	paramtype = "light",
	paramtype2 = "facedir",
	is_ground_content = false,
	groups = {dig_immediate=2},
	node_box = {
		type = "fixed",
		fixed = {
			{ -1/16, -8/16, 4/16, 1/16, -7/16, 24/16 },
			{ -8/16, -8/16, -1/16, 8/16, -7/16, 1/16 },
			{ -6/16, -8/16, -2/16, 6/16, -6/16, 2/16 },
			{ -5/16, -8/16, 2/16, 5/16, -6/16, 3/16 },
			{ -4/16, -8/16, 3/16, 4/16, -6/16, 4/16 },
			{ -3/16, -8/16, 4/16, 3/16, -6/16, 5/16 },
			{ -2/16, -8/16, 5/16, 2/16, -6/16, 16/16 },
			{ -4/16, -8/16, 16/16, 4/16, -6/16, 20/16 },
			{ -3/16, -8/16, 20/16, 3/16, -6/16, 21/16 },
		},
	},
	on_place = splitter_place,
	after_destruct = splitter_cleanup,
	digiline = {
		effector = {
                        action = splitter_in_action,
			rules = splitter_rules_in,
		},
		receptor = {
			rules = splitter_rules_in,
		},
	},
})

minetest.register_node("digiline_routing:splitter_b", {
	description = "<<INTERNAL>> Digiline Splitter (Part B)",
	drawtype = "nodebox",
	tiles = {
		"digiline_routing_metal.png"
	},
	paramtype = "light",
	paramtype2 = "facedir",
	is_ground_content = false,
	pointable = false,
	groups = {dig_immediate=2, not_in_creative_inventory=1},
	node_box = {
		type = "fixed",
		fixed = {},
	},
	drop = "",
	after_destruct = digiline_routing.multiblock.dig2b,
	digiline = {
		effector = {
                        action = splitter_out_action,
			rules = splitter_rules_out,
		},
		receptor = {
			rules = splitter_rules_out,
		},
	},
})
