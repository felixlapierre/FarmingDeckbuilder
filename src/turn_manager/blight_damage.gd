class_name BlightDamage

static func get_blight_pattern(year: int) -> Array[int]:
	match year:
		1, 2, 3, 4:
			return get_phase_one().shuffle()[0]
		5, 6, 7:
			return get_phase_two().shuffle()[0]
		8, 9, 10:
			return get_phase_three().shuffle()[0]
		11, 12, 13:
			return get_phase_four().shuffle()[0]
		_:
			return get_phase_five().shuffle()[0]

static func get_phase_one():
	var options = []
	options.append([0, 0, 0, 10, 0, 20, 0, 30, 0, 10, 0, 30])
	options.append([0, 0, 0, 20, 10, 0, 0, 30, 0, 10, 30, 0])
	options.append([0, 0, 0, 0, 10, 0, 20, 10, 0, 30, 0, 30])
	options.append([0, 0, 0, 10, 10, 0, 20, 10, 0, 30, 0, 20])
	return options

static func get_phase_two():
	var options = []
	options.append([0, 0, 0, 15, 0, 25, 0, 30, 0, 20, 0, 30])
	options.append([0, 0, 5, 20, 10, 0, 10, 30, 0, 15, 30, 0])
	options.append([0, 0, 0, 0, 20, 0, 20, 10, 0, 40, 0, 30])
	return options

static func get_phase_three():
	var options = []
	options.append([0, 0, 0, 35, 0, 25, 0, 30, 0, 20, 0, 30])
	options.append([0, 0, 10, 25, 15, 0, 15, 30, 0, 15, 30, 0])
	options.append([0, 0, 0, 0, 25, 5, 25, 10, 0, 40, 0, 35])
	return options

static func get_phase_four():
	var options = []
	options.append([0, 0, 0, 40, 0, 25, 0, 35, 0, 20, 0, 30])
	options.append([0, 0, 10, 25, 15, 0, 20, 35, 0, 15, 30, 0])
	options.append([0, 0, 0, 0, 30, 10, 30, 10, 0, 40, 0, 35])
	return options

static func get_phase_five():
	var options = []
	options.append([0, 0, 0, 40, 0, 25, 0, 35, 0, 20, 0, 30])
	options.append([0, 0, 10, 25, 15, 0, 20, 35, 0, 15, 30, 0])
	options.append([0, 0, 0, 0, 30, 10, 30, 10, 0, 40, 0, 35])
	return options
