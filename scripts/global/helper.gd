class_name Helper

static func get_tile_shape(size):
	match size:
		1:
			return [Vector2(0, 0)]
		2:
			return [Vector2(0, 0), Vector2(1, 0)]
		3:
			return [Vector2(0, 0), Vector2(1, 0), Vector2(-1, 0)]
		9:
			return [Vector2(0, 0), Vector2(1, 0), Vector2(-1, 0),
				Vector2(0, 1), Vector2(1, 1), Vector2(-1, 1),
				Vector2(0, -1), Vector2(1, -1), Vector2(-1, -1)]
	return []

static func in_bounds(grid_location):
	return grid_location.x < Constants.FARM_DIMENSIONS.x and grid_location.y < Constants.FARM_DIMENSIONS.y \
		and grid_location.x >= 0 and grid_location.y >= 0
