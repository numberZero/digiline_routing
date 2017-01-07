-- © 2017 numberZero
-- License: GNU Lesser General Public License, version 2 (or any later version)

local rules_in = {
	[0] = {{x = -1, y = 0, z = 0}},
	[1] = {{x = 0, y = 0, z = 1}},
	[2] = {{x = 1, y = 0, z = 0}},
	[3] = {{x = 0, y = 0, z = -1}},
}

local rules_out = {
	[0] = {{x = 1, y = 0, z = 0}},
	[1] = {{x = 0, y = 0, z = -1}},
	[2] = {{x = -1, y = 0, z = 0}},
	[3] = {{x = 0, y = 0, z = 1}},
}

local function diode_rules_in(node)
	return rules_in[node.param2]
end

local function diode_rules_out(node)
	return rules_out[node.param2]
end

local function diode_action(pos, node, channel, msg)
	digiline:receptor_send(pos, diode_rules_out(node), channel, msg)
end

minetest.register_node("digiline_routing:diode", {
	description = "Digiline Diode",
	drawtype = "nodebox",
	tiles = {
		"digiline_routing_metal.png"
	},
	paramtype = "light",
	paramtype2 = "facedir",
	groups = {dig_immediate=2},
	node_box = {
		type = "fixed",
		fixed = {
			{ -8/16, -8/16, -1/16, 8/16, -7/16, 1/16 },
			{ 1/16, -8/16, -2/16, 3/16, -6/16, 2/16 },
			{ -3/16, -8/16, -4/16, -1/16, -6/16, 4/16 },
			{ -1/16, -8/16, -3/16, 1/16, -6/16, 3/16 },
		},
	},
	digiline = {
		effector = {
                        action = diode_action,
			rules = diode_rules_in,
		},
		receptor = {
			rules = diode_rules_out,
		},
	},
})
