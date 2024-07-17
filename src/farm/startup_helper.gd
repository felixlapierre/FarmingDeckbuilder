extends Node
class_name StartupHelper

static var card_database = preload("res://src/cards/cards_database.gd")

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
	var deck = []
	for card in data:
		for i in range(card.count):
			deck.append(card_database.get_card_by_name(card.name, card.type))
	return deck

static func setup_farm(farm: Farm, event_manager: EventManager):
	match Global.FARM_TYPE:
		"RIVERLANDS":
			pass
		"WILDERNESS":
			pass
		"MOUNTAINS":
			for tile in farm.get_all_tiles():
				if tile.grid_location.x == 1 or tile.grid_location.x == 6 \
					or tile.grid_location.y == 1 or tile.grid_location.y == 6:
					tile.disable()
			pass

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
		"name": "watermelon",
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
		"name": "propagate",
		"type": "action",
		"count": 3
	},
	{
		"name": "invigorate",
		"type": "action",
		"count": 1,
	},
	{
		"name": "abundance",
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
		"name": "gather",
		"type": "action",
		"count": 3
	}
]
