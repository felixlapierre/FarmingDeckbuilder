class_name Helper

static func get_tile_shape(size, shape):
	return get_tile_shape_rotated(size, shape, 0)

static func get_tile_shape_rotated(size, shape: Enums.CursorShape, rotation):
	var result = []
	if shape == Enums.CursorShape.Line:
		for i in range(size):
			var x = ceil(float(i)/2)
			var sign = 1 if i % 2 == 0 else -1
			result.append(Vector2(x * sign, 0).rotated(PI/2 * rotation).round())
		return result
	
	var skip_center = 0 if shape == Enums.CursorShape.Square else 1
	for i in range(skip_center, size + skip_center):
		var x = 0
		var y = 0
		match i:
			0, 3, 7:
				x = 0
			1, 2, 8:
				x = 1
			4, 5, 6:
				x = -1
			9, 10, 11:
				x = 2
		match i:
			0, 1, 5, 10:
				y = 0
			6, 7, 8, 9:
				y = 1
			2, 3, 4, 11:
				y = -1
		result.append(Vector2(x, y).rotated(PI/2 * rotation).round())
	return result

static func in_bounds(grid_location):
	return grid_location.x < Constants.FARM_DIMENSIONS.x and grid_location.y < Constants.FARM_DIMENSIONS.y \
		and grid_location.x >= 0 and grid_location.y >= 0

static func card_info_matches(info1, info2):
	return info1.type == info2.type \
		and info1.name == info2.name \
		and info1.cost == info2.cost \
		and info1.size == info2.size \
		and info1.text == info2.text \
		and info1.texture == info2.texture

static func get_default_shape(size):
	match size:
		3:
			return Enums.CursorShape.Line
		4:
			return Enums.CursorShape.Square
		5, 7:
			return Enums.CursorShape.Elbow
	return Enums.CursorShape.Square
	
