---------------------------------------------------------------------
-- zipangu
-- Copyright (C) 2017 tacigar
--
-- This program is free software: you can redistribute it and/or modify
-- it under the terms of the GNU General Public License as published by
-- the Free Software Foundation, either version 3 of the License, or
-- (at your option) any later version.
--
-- This program is distributed in the hope that it will be useful,
-- but WITHOUT ANY WARRANTY; without even the implied warranty of
-- MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
-- GNU General Public License for more details.
--
-- You should have received a copy of the GNU General Public License
-- along with this program.  If not, see <http://www.gnu.org/licenses/>.
---------------------------------------------------------------------

minetest.register_node("zipangu_shoji:hidden", {
	description = "Hidden Shoji Segment",
	drawtype = "airlike",
	paramtype = "light",
	paramtype2 = "facedir",
	sunlight_propagates = true,
	walkable = false,
	pointable = false,
	diggable = false,
	buildable_to = false,
	floodable = false,
	drop = "",
	groups = { not_in_creative_inventory = 1 },
	on_blast = function() end,
})

local function on_place_node(place_to, newnode,	placer, oldnode, itemstack, pointed_thing)
	for _, callback in ipairs(minetest.registered_on_placenodes) do
		local place_to_copy = { x = place_to.x, y = place_to.y, z = place_to.z }
		local newnode_copy = { name = newnode.name, param1 = newnode.param1, param2 = newnode.param2 }
		local oldnode_copy = { name = oldnode.name, param1 = oldnode.param1, param2 = oldnode.param2 }
		local pointed_thing_copy = {
			type  = pointed_thing.type,
			above = vector.new(pointed_thing.above),
			under = vector.new(pointed_thing.under),
			ref   = pointed_thing.ref,
		}
		callback(place_to_copy, newnode_copy, placer, oldnode_copy, itemstack, pointed_thing_copy)
	end
end

function zipangu_shoji.register_shoji(name, def)
	if not name:find(":") then
		name = "zipangu_shouji:" .. name
	end

	local function get_around_poss(pos, dir, position)
		local ref = {
			[0] = { x = -1, z = 0 },
			[1] = { x = 0, z = 1 },
			[2] = { x = 1, z = 0 },
			[3] = { x = 0, z = -1 }
		}
		local uop = (position == nil or position == "left") and -1 or 1
		return {
			pos,
			{ x = pos.x, y = pos.y + 1, z = pos.z },
			{ x = pos.x + uop * ref[dir].x, y = pos.y, z = pos.z + uop * ref[dir].z },
			{ x = pos.x + uop * ref[dir].x, y = pos.y + 1, z = pos.z + uop * ref[dir].z },
		}
	end

	minetest.register_craftitem(":" .. name, {
		description = def.description,
		inventory_image = def.inventory_image,
		groups = table.copy(def.groups),

		on_place = function(itemstack, placer, pointed_thing)
			if not pointed_thing.type == "node" then
				return itemstack
			end

			local pnode = minetest.get_node(pointed_thing.under)
			local pdef = minetest.registered_nodes[pnode.name]
			if pdef and pdef.on_rightclick and not placer:get_player_control().sneak then
				return pdef.on_rightclick(pointed_thing.under, pnode, placer, itemstack, pointed_thing)
			end

			local pos
			if pdef and pdef.buildable_to then
				pos = pointed_thing.under
			else
				pos = pointed_thing.above
				pnode = minetest.get_node(pos)
				pdef = minetest.registered_nodes[pnode.name]
				if not pdef or not pdef.buildable_to then
					return itemstack
				end
			end

			local dir = minetest.dir_to_facedir(placer:get_look_dir())
			local poss = get_around_poss(pos, dir)
			local pn = placer:get_player_name()

			for _, pos in ipairs(poss) do
				local node = minetest.get_node_or_nil(pos)
				local def = minetest.registered_nodes[node.name]
				if not def or not def.buildable_to or minetest.is_protected(pos, pn) then
					return itemstack
				end
			end

			minetest.set_node(poss[1], { name = name .. "_1", param2 = dir })
			minetest.set_node(poss[2], { name = "zipangu_shoji:hidden" })
			minetest.set_node(poss[3], { name = name .. "_1", param2 = (dir + 2) % 4})
			minetest.set_node(poss[4], { name = "zipangu_shoji:hidden" })
			minetest.sound_play(default.node_sound_wood_defaults().place, { pos = pos })
			
			local meta
			meta = minetest.get_meta(poss[1])
			meta:set_string("position", "left")
			meta:set_string("state", "closed")
			meta:set_int("facedir", dir)
			meta = minetest.get_meta(poss[3])
			meta:set_string("position", "right")
			meta:set_string("state", "closed")
			meta:set_int("facedir", dir)

			if not (creative and creative.is_enabled_for and creative.is_enabled_for(pn)) then
				itemstack:take_item()
			end
			on_place_node(pos, minetest.get_node(pos), placer, pnode, itemstack, pointed_thing)

			return itemstack
		end,
	})

	do
		local function shoji_toggle(pos, node, clicker)
			local meta = minetest.get_meta(pos)
			local position = meta:get_string("position")
			local state = meta:get_string("state")

			if position ~= "right" and position ~= "left" or state ~= "opened" and state ~= "closed" then
				return false
			end

			local facedir = meta:get_int("facedir")
			local poss = get_around_poss(pos, facedir, position)
			if clicker and (not default.can_interact_with_node(clicker, poss[1]) or not default.can_interact_with_node(clicker, poss[3])) then
				return false
			end

			minetest.sound_play("zipangu_shoji_shoji_slide", { pos = poss[1], gain = 0.25, max_hear_distance = 10 })

			if state == "opened" then
				minetest.swap_node(poss[1], { name = name .. "_1", param2 = facedir }) -- node.param2 })
				minetest.swap_node(poss[3], { name = name .. "_1", param2 = (facedir + 2) % 4 }) -- (node.param2 + 2) % 4 })
				meta:set_string("state", "closed")
				minetest.get_meta(poss[3]):set_string("state", "closed")

			elseif state == "closed" then
				minetest.swap_node(poss[1], { name = "zipangu_shoji:hidden" })
				minetest.swap_node(poss[3], { name = name .. "_2", param2 = (facedir + 2) % 4 }) -- (node.param2 + 2) % 4 })
				meta:set_string("state", "opened")
				minetest.get_meta(poss[3]):set_string("state", "opened")
			end

			return true
		end

		local common_def = {
			tiles = def.tiles,
			description = def.description,
			groups = def.groups,
			drawtype = "mesh",
			paramtype = "light",
			paramtype2 = "facedir",
			sunlight_propagates = true,
			walkable = true,
			is_ground_content = false,
			buildable_to = false,
			sounds = default.node_sound_wood_defaults(),

			after_dig_node = function(pos, node, meta, digger)
				local poss = get_around_poss(pos, tonumber(meta.fields.facedir), meta.fields.position)
				for i = 2, 4 do
					minetest.remove_node(poss[i])
				end
				minetest.check_for_falling(poss[2])
				minetest.check_for_falling(poss[4])
			end,

			on_rightclick = function(pos, node, clicker, itemstack, pointed_thing)
				shoji_toggle(pos, node, clicker)
				return itemstack
			end,

			on_rotate = function(pos, node, user, mode, new_param2)
				return false
			end,

			on_destruct = function(pos)
				minetest.remove_node { x = pos.x, y = pos.y + 1, z = pos.z }
			end,

			on_blast = function(pos, intensity)
				local node = minetest.get_node(pos)
				local meta = minetest.get_meta(pos)
				for _, p in ipairs(get_around_poss(pos, meta:get_int("facedir"), meta:get_string("position"))) do
					minetest.remove_node(p)
				end
				return { name }
			end,
		}
		common_def.groups.not_in_creative_inventory = 1
		common_def.mesh = "zipangu_shoji_shoji_1.obj"
		common_def.tiles = def.tiles[1]
		minetest.register_node(":" .. name .. "_1", common_def)
		common_def.mesh = "zipangu_shoji_shoji_2.obj"
		common_def.tiles = def.tiles[2]
		minetest.register_node(":" .. name .. "_2", common_def)
	end
end

zipangu_shoji.register_fusuma = zipangu_shoji.register_shoji

function zipangu_shoji.register_tsuitate(name, def)
end

function zipangu_shoji.register_byobu(name, def)
end
