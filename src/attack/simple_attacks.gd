extends Node

var data_fetcher = preload("res://src/cards/cards_database.gd")

# Plants
var StartWithWeeds = preload("res://src/fortune/data/weeds_on_farm.gd")
var BlightrootOnce = preload("res://src/fortune/data/blightroot_once.gd")
var BlightrootTurnStart = preload("res://src/fortune/data/blightroot_turn_start.gd")
var DeathcapTurnStart = preload("res://src/fortune/data/deathcap_turnstart.gd")
var WeedsEntireFarm = preload("res://src/fortune/data/weeds_entire_farm.gd")

# Cards
var ObliviateRightmost = preload("res://src/fortune/data/end_turn_obliviate.gd")
var WeedsDeckOnce = preload("res://src/fortune/data/weeds_start_deck.gd")
var WeedsDeckTurn = preload("res://src/fortune/data/weed_deck_turn_start.gd")

# Kaleidoscope
var EndTurnRandomize = preload("res://src/fortune/data/end_turn_randomize_colors.gd")
var EndTurnSwap = preload("res://src/fortune/data/end_turn_swap_colors.gd")
var EndTurnRotate = preload("res://src/fortune/data/end_turn_rotate_colors.gd")

# Destroy, Piercing
var DestroyOnePlant = load("res://src/fortune/data/destroy_one_plant.tres")
var DestroyTwoPlants = load("res://src/fortune/data/destroy_two.tres")
var PiercingDestroyTwoTiles = load("res://src/fortune/data/piercing_destroy_two.tres")
var PiercingFour = load("res://src/fortune/data/piercing_four.tres")
var PiercingTwo = load("res://src/fortune/data/piercing_two.tres")

#Other
var Catastrophe = load("res://src/fortune/data/double_purple_target.tres")
var IncreaseRitual10 = preload("res://src/fortune/data/increase_ritual_target.gd")

var simple_builders = {}

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func create_simple_attacks():
	for i in range(0, 3):
		simple_builders[i] = []
	for fortune in data_fetcher.get_all_fortunes():
		if fortune.type == Fortune.FortuneType.BadFortune:
			var simpleattack = SimpleAttackBuilder.new().every_turn_fortune(fortune).rank(fortune.rank)
			simple_builders[fortune.rank].append(simpleattack)

func get_simple_attack_year(year: int, misfortune: bool):
	if !misfortune:
		match year + 1:
			2, 3:
				get_simple_attack([0])
			4, 5:
				get_simple_attack([1])
			6:
				get_simple_attack([1, 0])
			7:
				get_simple_attack([2])
			8:
				get_simple_attack([2, 0])
			9:
				get_simple_attack([2, 1])
			10:
				get_simple_attack([3])
			_:
				get_simple_attack([3, 2, 1])
	else:
		match year + 1:
			2, 3:
				get_simple_attack([0])
			4:
				get_simple_attack([1])
			5:
				get_simple_attack([1, 0])
			6:
				get_simple_attack([1, 1])
			7:
				get_simple_attack([2, 0])
			8:
				get_simple_attack([2, 1])
			9:
				get_simple_attack([2, 2])
			10:
				get_simple_attack([3, 2, 2])
			_:
				get_simple_attack([3, 2, 1, 0])

func get_simple_attack(ranks: Array[int]) -> AttackPattern:
	var builder = SimpleAttackBuilder.new()
	for rank in ranks:
		var options: Array[SimpleAttackBuilder] = simple_builders[rank]
		var eligible = []
		for opt in options:
			if builder.compatible(opt):
				eligible.append(opt)
			
		var i = randi_range(0, eligible.size())
		builder.combine(eligible[i])
	return builder.build()
