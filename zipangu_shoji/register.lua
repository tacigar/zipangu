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

zipangu_shoji.register_shoji("shoji_typeA", {
	tiles = {
		[1] = {{ name = "zipangu_shoji_shoji_typeA_1.png" }},
		[2] = {{ name = "zipangu_shoji_shoji_typeA_2.png" }},
	},
	description = "Shoji Type A",
	inventory_image = "zipangu_shoji_shoji_typeA_inv.png",
	groups = { choppy = 2, oddly_breakable_by_hand = 2, flammable = 2 },
})

zipangu_shoji.register_tsuitate("tsuitate_typeA", {
	tiles = {{ name = "zipangu_shoji_tsuitate_typeA.png", backface_culling = true }},
	description = "Tsuitate Type A",
	groups = { choppy = 2, oddly_breakable_by_hand = 2, flammable = 2 },
})
