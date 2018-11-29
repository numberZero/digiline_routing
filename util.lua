-- © 2017 numberZero
-- License: GNU Lesser General Public License, version 2 (or any later version)

local BASE_RULES = {
	[0] = {x = -1, y = 0, z = 0},
	[1] = {x = 0, y = 0, z = 1},
	[2] = {x = 1, y = 0, z = 0},
	[3] = {x = 0, y = 0, z = -1},
}

digiline_routing.get_base_rule = function(rule, param2)
	if param2 >= 4 then
		return nil
	end
	return BASE_RULES[(rule + param2) % 4]
end

digiline_routing.is_protected = function(pos, player)
	local name = player:get_player_name()
	if not minetest.is_protected(pos, name) then
		return false
	end
	-- FIXME: is this necessary?
	if minetest.check_player_privs(name, "protection_bypass") then
		return false
	end
	minetest.record_protection_violation(pos, name)
	return true
end
