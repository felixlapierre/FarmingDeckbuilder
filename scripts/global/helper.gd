class_name Helper

static func get_tile_shape(size):
	match size:
		1:
			return [Vector2(0, 0)]
		2:
			return [Vector2(0, 0), Vector2(1, 0)]
		3:
			return [Vector2(0, 0), Vector2(1, 0), Vector2(-1, 0)]
		4:
			return [Vector2(0, 0), Vector2(1, 0), Vector2(1, 1), Vector2(0, 1)]
		6:
			return [Vector2(0, 0), Vector2(1, 0), Vector2(-1, 0),
				Vector2(0, 1), Vector2(1, 1), Vector2(-1, 1)]
		9:
			return [Vector2(0, 0), Vector2(1, 0), Vector2(-1, 0),
				Vector2(0, 1), Vector2(1, 1), Vector2(-1, 1),
				Vector2(0, -1), Vector2(1, -1), Vector2(-1, -1)]
	return []

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
