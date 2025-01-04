class_name DataFetcher

static var all_cards: Array[CardData] = []

static func load_cards():
	if all_cards.size() > 0:
		return
	var paths = get_all_file_paths("res://src/cards/data");
	for path in paths:
		var card: CardData = load(path)
		if card == null:
			print(path)
		all_cards.append(card)
	if Global.MAGE == "Blight Druid":
		all_cards.append(get_element_cards("Blight"))
	
static func get_all_cards() -> Array[CardData]:
	return get_all_cards_rarity(null)

static func get_all_cards_rarity(rarity) -> Array[CardData]:
	load_cards()
	var cards: Array[CardData] = []
	for card in all_cards:
		if (rarity == null or rarity == card.rarity)\
			and card.rarity != "unique" and card.rarity != "blight" and card.rarity != "basic":
			cards.append(card)
		if Global.MAGE == BlightMageFortune.MAGE_NAME and rarity == "common" and card.rarity == "blight":
			cards.append(card)
	return cards

static func get_card_by_name(name: String, type: String):
	load_cards()
	for card in all_cards:
		if card.name == name:
			return card

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

static func get_all_structure(rarity: Variant) -> Array[Structure]:
	var structures: Array[Structure] = []
	var paths = get_all_file_paths("res://src/structure/data");
	for path in paths:
		var structure: Structure = load(path)
		if structure == null:
			print(path)
		if rarity == null or structure.rarity == rarity:
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

static func get_custom_events() -> Array[CustomEvent]:
	var events: Array[CustomEvent] = []
	var paths = get_all_file_paths("res://src/event/script");
	for path in paths:
		var event: CustomEvent = load(path).new()
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

static func get_all_blessings() -> Array[Fortune]:
	var fortunes: Array[Fortune] = []
	var paths = get_all_file_paths("res://src/fortune/blessings")
	for path in paths:
		var fortune = load(path)
		fortunes.append(fortune.new())
	return fortunes

static func get_all_curses() -> Array[Fortune]:
	var fortunes: Array[Fortune] = []
	var paths = get_all_file_paths("res://src/fortune/curses")
	for path in paths:
		var fortune = load(path)
		fortunes.append(fortune.new())
	return fortunes

# pass null rarity for random card
static func get_random_cards(rarity, count: int):
	var result = []
	var cards = get_all_cards_rarity(rarity)
	cards.shuffle()
	for n_card in cards:
		if result.size() >= count:
			return result
		if n_card.type != "STRUCTURE":
			result.append(n_card)
	return result

static func get_random_action_cards(rarity, count: int):
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
		if enh.rarity == rarity:
			result.append(enh)
	return result

static func get_random_enhance_noseed(rarity, count):
	var result = []
	var enhances = get_all_enhance()
	enhances.shuffle()
	for enh in enhances:
		if result.size() >= count:
			return result
		if enh.rarity == rarity and ["Discount", "Echo", "Burn", "Frozen", "Size", "Springbound", "Strength"]\
					.has(enh.name):
			result.append(enh)
	return result

static func get_random_structures(count: int, rarity: String):
	var result = []
	var structures = get_all_structure(rarity)
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
	elif text.contains("Water"):
		return [
			load("res://src/cards/data/action/channeling.tres"),
			load("res://src/cards/data/action/flow.tres"),
			load("res://src/cards/data/action/raincloud.tres"),
			load("res://src/cards/data/action/water_rite.tres"),
			load("res://src/cards/data/action/water_ward.tres"),
			load("res://src/cards/data/seed/watermelon.tres")
		]
	elif text.contains("Earth"):
		return [
			load("res://src/cards/data/action/catalyze.tres"),
			load("res://src/cards/data/action/earth_ward.tres"),
			load("res://src/cards/data/seed/dark_rose.tres"),
			load("res://src/cards/data/action/earthrite.tres")
		]
	elif text.contains("Nature"):
		return [
			load("res://src/cards/data/action/abundance.tres"),
			load("res://src/cards/data/action/leaf_ward.tres"),
			load("res://src/cards/data/action/propagation.tres"),
			load("res://src/cards/data/action/infuse.tres"),
			load("res://src/cards/data/action/invigorate.tres"),
			load("res://src/cards/data/action/ingrain.tres")
		]
	elif text.contains("Knowledge"):
		return [
			load("res://src/cards/data/action/inscribe.tres"),
			load("res://src/cards/data/action/synthesize.tres"),
			load("res://src/cards/data/action/inspiration.tres"),
			load("res://src/cards/data/seed/papyrus.tres"),
			load("res://src/cards/data/action/focus.tres"),
			load("res://src/cards/data/action/gather.tres"),
			load("res://src/cards/data/seed/marigold.tres")
		]
	elif text.contains("Wind"):
		return [
			load("res://src/cards/data/action/rite_of_air.tres"),
			load("res://src/cards/data/action/cycle.tres"),
			load("res://src/cards/data/action/echo_scythe.tres"),
			load("res://src/cards/data/action/little_friend.tres"),
			load("res://src/cards/data/action/warding.tres"),
			load("res://src/cards/data/action/dear_future.tres"),
			load("res://src/cards/data/action/frostcut.tres"),
			load("res://src/cards/data/action/gather.tres")
		]
	elif text.contains("Time"):
		return [
			load("res://src/cards/data/action/time_hop.tres"),
			load("res://src/cards/data/action/chronoweave.tres"),
			load("res://src/cards/data/action/time_bubble.tres"),
			load("res://src/cards/data/action/flow.tres"),
			load("res://src/cards/data/action/focus.tres")
		]
	elif text.contains("Fire"):
		return [
			load("res://src/cards/data/action/flamerite.tres"),
			load("res://src/cards/data/action/flame_ward.tres"),
			load("res://src/cards/data/seed/cranberry.tres"),
			load("res://src/cards/data/seed/corn.tres")
		]
	elif text.contains("Lightning"):
		return [
			load("res://src/cards/data/seed/coffee.tres"),
			load("res://src/cards/data/action/catalyze.tres"),
			load("res://src/cards/data/action/infuse.tres"),
			load("res://src/cards/data/seed/monstera.tres")
		]
