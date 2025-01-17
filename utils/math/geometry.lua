local Math = require('utils.math.math')

local Public = {}

function Public.snap_to_grid(point)
	return { x = Math.ceil(point.x), y = Math.ceil(point.y) }
end

-- Given an area marked by integer coordinates, returns an array of all the half-integer positions bounded by that area. Useful for constructing tiles.
function Public.all_central_positions_within_area(area, offset)
	local offsetx = offset.x or 0
	local offsety = offset.y or 0
	local xr1, xr2, yr1, yr2 =
		offsetx + Math.ceil(area[1][1] - 0.5),
		offsetx + Math.floor(area[2][1] + 0.5),
		offsety + Math.ceil(area[1][2] - 0.5),
		offsety + Math.floor(area[2][2] + 0.5)

	local positions = {}
	for y = yr1 + 0.5, yr2 - 0.5, 1 do
		for x = xr1 + 0.5, xr2 - 0.5, 1 do
			positions[#positions + 1] = { x = x, y = y }
		end
	end
	return positions
end

-- *** *** --
--*** VECTORS ***--
-- *** *** --

function Public.vector_length(vec)
	return Math.sqrt(vec.x * vec.x + vec.y * vec.y)
end

function Public.vector_sum(...)
	local result = { x = 0, y = 0 }
	for _, vec in ipairs({ ... }) do
		result.x = result.x + vec.x
		result.y = result.y + vec.y
	end
	return result
end

function Public.vector_scaled(vec, scalar)
	return { x = vec.x * scalar, y = vec.y * scalar }
end

function Public.vector_distance(vec1, vec2)
	local vecx = vec2.x - vec1.x
	local vecy = vec2.y - vec1.y
	return Math.sqrt(vecx * vecx + vecy * vecy)
end

-- normalises vector to unit vector (length 1)
-- if vector length is 0, returns {x = 0, y = 1} vector
function Public.vector_norm(vec)
	local vec_copy = { x = vec.x, y = vec.y }
	local vec_length = Public.vector_length(vec_copy)
	if vec_length == 0 then
		vec_copy.x = 0
		vec_copy.y = 1
	else
		vec_copy.x = vec_copy.x / vec_length
		vec_copy.y = vec_copy.y / vec_length
	end
	return { x = vec_copy.x, y = vec_copy.y }
end

--- Returns true if position is closer to pos1 than to pos2
function Public.is_closer(position, pos1, pos2)
	return Public.vector_distance(pos1, position) < Public.vector_distance(pos2, position)
end

return Public
