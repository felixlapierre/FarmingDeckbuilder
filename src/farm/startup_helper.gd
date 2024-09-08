extends Node
class_name StartupHelper

static var card_database = preload("res://src/cards/cards_database.gd")

static var Blueberry = preload("res://src/cards/data/seed/blueberry.tres")
static var Carrot = preload("res://src/cards/data/seed/carrot.tres")
static var Wildflower = preload("res://src/fortune/unique/wildflower.tres")
static var Potato = preload("res://src/cards/data/seed/potato.tres")
static var Water = preload("res://src/structure/unique/river.tres")

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
	return load_deck(data)

static func load_deck(data):
	var deck = []
	for card in data:
		for i in range(card.count):
			deck.append(card_database.get_card_by_name(card.name, card.type))
	return deck

static func setup_farm(farm: Farm, event_manager: EventManager):
	match Global.FARM_TYPE:
		"RIVERLANDS":
			for i in range(0, 5):
				farm.tiles[3][i].build_structure(Water, 0)
			for i in range(3, 8):
				farm.tiles[4][i].build_structure(Water, 0)
		"WILDERNESS":
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
	event_args.farm.use_card_random_tile(Carrot, 2)
	event_args.farm.use_card_random_tile(Blueberry, 2)
	event_args.farm.use_card_random_tile(Potato, 2)
	event_args.farm.use_card_random_tile(Wildflower, 2)
	
static var forest_deck = [
	{
		"name": "carrot",
		"type": "seed",
		"count": 3
	},
	{
		"name": "blueberry",
		"type": "seed",
		"count": 3
	},
	{
		"name": "scythe",
		"type": "action",
		"count": 3
	},
	{
		"name": "pumpkin",
		"type": "seed",
		"count": 1
	}
]

static var riverlands_deck = [
	{
		"name": "potato",
		"type": "seed",
		"count": 3
	},
	{
		"name": "pumpkin",
		"type": "seed",
		"count": 3
	},
	{
		"name": "radish",
		"type": "seed",
		"count": 1
	},
	{
		"name": "scythe",
		"type": "action",
		"count": 3
	}
]

static var wilderness_deck = [
	{
		"name": "propagation",
		"type": "action",
		"count": 3
	},
	{
		"name": "ingrain",
		"type": "action",
		"count": 1,
	},
	{
		"name": "fertilize",
		"type": "action",
		"count": 3
	},
	{
		"name": "scythe",
		"type": "action",
		"count": 3
	}
]

static var mountains_deck = [
		{
		"name": "pumpkin",
		"type": "seed",
		"count": 3
	},
	{
		"name": "radish",
		"type": "seed",
		"count": 3,
	},
	{
		"name": "leek",
		"type": "seed",
		"count": 1
	},
	{
		"name": "scythe",
		"type": "action",
		"count": 3
	}
]

static var tutorial_deck = [
	{
		"name": "radish",
		"type": "seed",
		"count": 3
	},
	{
		"name": "scythe",
		"type": "action",
		"count": 3
	},
	{
		"name": "potato",
		"type": "seed",
		"count": 3
	},
	{
		"name": "pumpkin",
		"type": "seed",
		"count": 1
	}
]
