static func get_all_cards() -> Array[CardData]:
	var cards: Array[CardData] = []
	var paths = get_all_file_paths("res://cards");
	for path in paths:
		var card: CardData = load(path)
		if card == null:
			print(path)
		cards.append(card)
	return cards

static func get_card_by_name(name: String, type: String):
	var path = "res://cards/" + type + "/" + name + ".tres"
	return load(path)

static func get_all_file_paths(path: String) -> Array[String]:  
	var file_paths: Array[String] = []  
	var dir = DirAccess.open(path)  
	dir.list_dir_begin()  
	var file_name = dir.get_next()  
	while file_name != "":  
		var file_path = path + "/" + file_name  
		if dir.current_is_dir():
			file_paths += get_all_file_paths(file_path)  
		else:  
			file_paths.append(file_path)  
		file_name = dir.get_next()  
	return file_paths

static func get_all_enhance() -> Array[Enhance]:
	var enhances: Array[Enhance] = []
	var paths = get_all_file_paths("res://data/enhance");
	for path in paths:
		var enhance: Enhance = load(path)
		if enhance == null:
			print(path)
		enhances.append(enhance)
	return enhances

static func get_all_structure() -> Array[Structure]:
	var structures: Array[Structure] = []
	var paths = get_all_file_paths("res://data/structure");
	for path in paths:
		var structure: Structure = load(path)
		if structure == null:
			print(path)
		structures.append(structure)
	return structures
