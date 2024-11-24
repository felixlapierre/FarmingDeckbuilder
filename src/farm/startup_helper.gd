extends Node
class_name StartupHelper

static var card_database = preload("res://src/cards/cards_database.gd")

static var Blueberry = preload("res://src/cards/data/seed/blueberry.tres")
static var Carrot = preload("res://src/cards/data/seed/carrot.tres")
static var Wildflower = preload("res://src/fortune/unique/wildflower.tres")
static var Potato = preload("res://src/cards/data/seed/potato.tres")
static var Water = preload("res://src/structure/unique/river.tres")

static var manipulate_deck_callback: Callable = func(_deck): pass

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
	
static func get_starter_deck():
	var data;
	match Global.FARM_TYPE:
		"FOREST":
			data = forest_deck
		"RIVERLANDS":
			data = riverlands_deck
		"WILDERNESS":
			data = wilderness_deck
		"MOUNTAINS":
			data = mountains_deck
	var deck = load_deck(data)
	manipulate_deck_callback.call(deck)
	return deck

static func register_manipulate_deck_callback(callback):
	manipulate_deck_callback = callback

static func load_deck(data):
	var deck = []
	for card in data:
		for i in range(card.count):
			deck.append(card_database.get_card_by_name(card.name, card.type))
	return deck

static func setup_farm(farm: Farm, event_manager: EventManager):
	match Global.FARM_TYPE:
		"RIVERLANDS":
			for i in range(1, 3):
				farm.tiles[1][i].build_structure(Water, 0)
				farm.tiles[2][i].build_structure(Water, 0)
			for i in range(5, 7):
				farm.tiles[5][i].build_structure(Water, 0)
				farm.tiles[6][i].build_structure(Water, 0)
		"WILDERNESS":
			if Global.WILDERNESS_PLANT == null:
				# select random
				var options = [
					load("res://src/cards/data/seed/inky_cap.tres"),
					load("res://src/fortune/unique/wildflower.tres"),
					load("res://src/cards/data/seed/dark_rose.tres"),
					load("res://src/cards/data/seed/gilded_rose.tres"),
					load("res://src/cards/data/seed/corn.tres"),
					load("res://src/cards/data/seed/watermelon.tres"),
					load("res://src/cards/data/seed/mint.tres"),
					load("res://src/cards/data/unique/puffshroom.tres")
				]
				var selection = options[randi_range(0, options.size() - 1)]
				Global.WILDERNESS_PLANT = selection
			setup_wilderness_farm_callback(farm, event_manager)
		"MOUNTAINS":
			Global.FARM_TOPLEFT = Vector2(2, 2)
			Global.FARM_BOTRIGHT = Vector2(5, 5)
			for tile in farm.get_all_tiles():
				tile.do_active_check()
			pass

static func load_farm(farm: Farm, event_manager: EventManager):
	if Global.FARM_TYPE == "WILDERNESS":
		setup_wilderness_farm_callback(farm, event_manager)
	for tile in farm.get_all_tiles():
		tile.do_active_check()

static func setup_wilderness_farm_callback(farm: Farm, event_manager: EventManager):
	event_manager.register_listener(EventManager.EventType.BeforeYearStart, wilderness_callable)

static func teardown_wilderness_farm_callback(event_manager: EventManager):
	event_manager.unregister_listener(EventManager.EventType.BeforeYearStart, wilderness_callable)

static var wilderness_callable = func(event_args: EventArgs):
	event_args.farm.use_card_random_tile(Global.WILDERNESS_PLANT.copy(), Global.WILDERNESS_PLANT.size)
	
static var forest_deck = [
	{
		"name": "Carrot",
		"type": "seed",
		"count": 2
	},
	{
		"name": "Blueberry",
		"type": "seed",
		"count": 3
	},
	{
		"name": "Scythe",
		"type": "action",
		"count": 4
	},
	{
		"name": "Pumpkin",
		"type": "seed",
		"count": 1
	}
]

static var riverlands_deck = [
	{
		"name": "Potato",
		"type": "seed",
		"count": 2
	},
	{
		"name": "Pumpkin",
		"type": "seed",
		"count": 3
	},
	{
		"name": "Radish",
		"type": "seed",
		"count": 1
	},
	{
		"name": "Scythe",
		"type": "action",
		"count": 4
	}
]

static var wilderness_deck = [
	{
		"name": "Spread",
		"type": "action",
		"count": 3
	},
	{
		"name": "Graft",
		"type": "action",
		"count": 1,
	},
	{
		"name": "Fertilize",
		"type": "action",
		"count": 2
	},
	{
		"name": "Scythe",
		"type": "action",
		"count": 4
	}
]

static var mountains_deck = [
		{
		"name": "Pumpkin",
		"type": "seed",
		"count": 3
	},
	{
		"name": "Radish",
		"type": "seed",
		"count": 2,
	},
	{
		"name": "Leek",
		"type": "seed",
		"count": 1
	},
	{
		"name": "Scythe",
		"type": "action",
		"count": 4
	}
]

static var tutorial_deck = [
	{
		"name": "Radish",
		"type": "seed",
		"count": 3
	},
	{
		"name": "Scythe",
		"type": "action",
		"count": 4
	},
	{
		"name": "Potato",
		"type": "seed",
		"count": 2
	},
	{
		"name": "Pumpkin",
		"type": "seed",
		"count": 1
	}
]
