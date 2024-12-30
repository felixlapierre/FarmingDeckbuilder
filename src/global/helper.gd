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
			16, 17, 18, 19, 20:
				x = -2
			4, 5, 6, 15, 21:
				x = -1
			0, 3, 7, 14, 22:
				x = 0
			1, 2, 8, 13, 23:
				x = 1
			9, 10, 11, 12, 24:
				x = 2

		match i:
			12, 13, 14, 15, 16:
				y = -2
			2, 3, 4, 11, 17:
				y = -1
			0, 1, 5, 10, 18:
				y = 0
			6, 7, 8, 9, 19:
				y = 1
			20, 21, 22, 23, 24:
				y = 2

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

static func is_adjacent(loc1: Vector2, loc2: Vector2):
	return abs(loc1.x - loc2.x) <= 1\
		and abs(loc1.y - loc2.y) <= 1

static func is_nearby(loc1: Vector2, loc2: Vector2):
	return abs(loc1.x - loc2.x) <= 2\
		and abs(loc1.y - loc2.y) <= 2

static func mana_icon():
	return "[img]res://assets/custom/YellowManaSmall.png[/img]"

static func blue_mana():
	return "[img]res://assets/custom/PurpleManaText.png[/img]"

static func mana_icon_small():
	return "[img]res://assets/custom/YellowMana16.png[/img]"

static func blight_icon():
	return "[img]res://assets/custom/Blight.png[/img]"

static func time_icon():
	return "[img]res://assets/custom/Time32.png[/img]"

static func get_smart_select_shape(grid_position: Vector2, tiles, card: CardData, mouse_pos: Vector2):
	var returned = []
	# First, try the default shape
	var default = get_tile_shape_rotated(card.size, get_default_shape(card.size), 0)
	# If all tiles are eligible, use this
	var default_valid = true
	for pos in default:
		var target = pos + grid_position
		if !in_bounds(target) or !(tiles[target.x][target.y].card_can_target(card)):
				default_valid = false
	if default_valid:
		for pos in default:
			returned.append(pos + grid_position)
		return returned
	# if not valid, do smart shape
	# Get all adjacent tiles
	var all_position = []
	for i in range(-1, 2):
		for j in range(-1, 2):
			var new_position = Vector2(grid_position.x + i, grid_position.y + j)
			if in_bounds(new_position):
				all_position.append(new_position)
	
	# Filter based on whether tile is eligible to be targeted
	var eligible = []
	var ineligible = []
	for pos in all_position:
		var tile = tiles[pos.x][pos.y]
		if tile.card_can_target(card):
			eligible.append(pos)
		else:
			ineligible.append(pos)

	# Sort by distance to mouse
	var sorting_func = func(a, b):
		#return true if b is after a
		var bdist = mouse_pos.distance_to(tiles[b.x][b.y].position + Constants.TILE_SIZE / 2)
		var adist = mouse_pos.distance_to(tiles[a.x][a.y].position + Constants.TILE_SIZE / 2)
		return adist < bdist
	eligible.sort_custom(sorting_func)
	ineligible.sort_custom(sorting_func)
	
	# Return the first SIZE elements

	for i in range(card.size):
		if eligible.size() > 0:
			returned.append(eligible.pop_front())
		elif ineligible.size() > 0:
			returned.append(ineligible.pop_front())
	return returned

static func can_expand_farm():
	return Global.FARM_TOPLEFT.y > 0\
	or Global.FARM_TOPLEFT.x > 0\
	or Global.FARM_BOTRIGHT.x <= Constants.FARM_DIMENSIONS.x\
	or Global.FARM_BOTRIGHT.y <= Constants.FARM_DIMENSIONS.y

static func pick_random(array):
	var index = randi_range(0, array.size() - 1)
	return array[index]
