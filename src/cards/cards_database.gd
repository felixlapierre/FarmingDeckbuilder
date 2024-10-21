class_name DataFetcher

static func get_all_cards() -> Array[CardData]:
	return get_all_cards_rarity(null)

static func get_all_cards_rarity(rarity) -> Array[CardData]:
	var cards: Array[CardData] = []
	var paths = get_all_file_paths("res://src/cards/data");
	for path in paths:
		var card: CardData = load(path)
		if card == null:
			print(path)
		if rarity == null or rarity == card.rarity:
			cards.append(card)
	return cards

static func get_card_by_name(name: String, type: String):
	var path = "res://src/cards/data/" + type + "/" + name + ".tres"
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
			if file_path.ends_with(".remap"):
				file_path = file_path.trim_suffix(".remap")
			file_paths.append(file_path)  
		file_name = dir.get_next()  
	return file_paths

static func get_all_enhance() -> Array[Enhance]:
	var enhances: Array[Enhance] = []
	var paths = get_all_file_paths("res://src/enhance/data");
	for path in paths:
		var enhance: Enhance = load(path)
		if enhance == null:
			print(path)
		enhances.append(enhance)
	return enhances

static func get_all_structure() -> Array[Structure]:
	var structures: Array[Structure] = []
	var paths = get_all_file_paths("res://src/structure/data");
	for path in paths:
		var structure: Structure = load(path)
		if structure == null:
			print(path)
		structures.append(structure)
	return structures

static func get_all_event() -> Array[GameEvent]:
	var events: Array[GameEvent] = []
	var paths = get_all_file_paths("res://src/event/data");
	for path in paths:
		var event: GameEvent = load(path)
		if event == null:
			print(path)
		events.append(event)
	return events

static func get_all_fortunes() -> Array[Fortune]:
	var fortunes: Array[Fortune] = []
	var paths =  get_all_file_paths("res://src/fortune/data");
	for path in paths:
		# Can be script or resource
		var fortune = load(path)
		if fortune is Fortune:
			fortunes.append(fortune)
		elif fortune is GDScript:
			fortunes.append(fortune.new())
	return fortunes

# pass null rarity for random card
static func get_random_cards(rarity: String, count: int):
	var result = []
	var cards = get_all_cards_rarity(rarity)
	cards.shuffle()
	for n_card in cards:
		if result.size() >= count:
			return result
		if n_card.type != "STRUCTURE":
			result.append(n_card)
	return result

static func get_random_action_cards(rarity: String, count: int):
	var result = []
	var cards = get_all_cards_rarity(rarity)
	cards.shuffle()
	for n_card in cards:
		if result.size() >= count:
			return result
		if n_card.type == "ACTION":
			result.append(n_card)
	return result

static func get_random_enhance(rarity: String, count: int, no_discount: bool):
	var result = []
	var enhances = get_all_enhance()
	enhances.shuffle()
	for enh in enhances:
		if result.size() >= count:
			return result
		if !no_discount or enh.name != "Discount":
			result.append(enh)
	return result

static func get_random_structures(count: int):
	var result = []
	var structures = get_all_structure()
	structures.shuffle()
	for str in structures:
		if result.size() >= count:
			return result
		result.append(str)
	return result

static func get_element_cards(text: String):
	if text.contains("Blight"):
		return [
			load("res://src/event/unique/blight_rose.tres"),
			load("res://src/cards/data/unique/bloodrite.tres"),
			load("res://src/cards/data/unique/dark_visions.tres")
		]
