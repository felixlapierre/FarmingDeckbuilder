extends Node
class_name AttacksAdvanced

# Plants
var StartWithWeeds = preload("res://src/fortune/data/weeds_on_farm.gd").new()
var BlightrootOnce = preload("res://src/fortune/data/blightroot_once.gd").new()
var BlightrootTurnStart = preload("res://src/fortune/data/blightroot_turn_start.gd").new()
var DeathcapTurnStart = preload("res://src/fortune/data/deathcap_turnstart.gd").new()
var WeedsEntireFarm = preload("res://src/fortune/data/weeds_entire_farm.gd").new()
var AddCorpseFlower = preload("res://src/fortune/data/corpse_flower.gd").new()

# Cards
var ObliviateRightmost = preload("res://src/fortune/data/end_turn_obliviate.gd").new()
var WeedsDeckOnce = preload("res://src/fortune/data/weeds_start_deck.gd").new()
var WeedsDeckTurn = preload("res://src/fortune/data/weed_deck_turn_start.gd").new()

# Kaleidoscope
var EndTurnRandomize = preload("res://src/fortune/data/end_turn_randomize_colors.gd").new()
var EndTurnSwap = preload("res://src/fortune/data/end_turn_swap_colors.gd").new()
var EndTurnRotate = preload("res://src/fortune/data/end_turn_rotate_colors.gd")

# Destroy, Piercing
var DestroyOnePlant = load("res://src/fortune/data/destroy_one_plant.tres")
var DestroyTwoPlants = load("res://src/fortune/data/destroy_two.tres")
#var PiercingDestroyTwoTiles = load("res://src/fortune/data/piercing_destroy_two.tres")
#var PiercingFour = load("res://src/fortune/data/piercing_four.tres")
#var PiercingTwo = load("res://src/fortune/data/piercing_two.tres")
var DestroyRow = load("res://src/fortune/data/destroy_row.gd").new()
var DestroyCol = load("res://src/fortune/data/destroy_col.gd").new()

#Other
var Catastrophe = load("res://src/fortune/data/double_purple_target.tres")
var IncreaseRitual10 = preload("res://src/fortune/data/increase_ritual_target.gd").new()
var BlockRitual = load("res://src/fortune/custom/block_ritual.gd").new()
var Counter = load("res://src/fortune/custom/counter.gd").new()

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func get_advanced_attack_year(year: int):
	#For now let's hard code each year
	match year + 1 + Mastery.Misfortune:
		2:
			#return SimpleAttackBuilder.new().fortune_every_turn(EndTurnRotate.new()).build()
			var fortune = pick_random([StartWithWeeds, BlightrootOnce])
			var option1 = SimpleAttackBuilder.new().fortune_once(fortune)\
				.fortune_at(fortune, 4)\
				.fortune_at(fortune, 7)\
				.fortune_at(fortune, 10).build()
			var option2 = SimpleAttackBuilder.new().fortune_every_turn(pick_random([DestroyOnePlant]))\
				.fortune_once(pick_random([EndTurnRandomize, IncreaseRitual10])).build()
			return pick_random([option1, option2])
		3:
			return SimpleAttackBuilder.new().fortune_once(pick_random([EndTurnRandomize, StartWithWeeds, WeedsDeckOnce]))\
				.fortune_every_turn(pick_random([BlightrootTurnStart, EndTurnSwap, DestroyOnePlant])).build()
		4:
			return SimpleAttackBuilder.new().fortune_once(BlightrootOnce)\
				.fortune_even(DestroyOnePlant)\
				.fortune_odd(IncreaseRitual10).build()
		5:
			return SimpleAttackBuilder.new().fortune_every_turn(BlightrootOnce)\
				.fortune_odd(EndTurnSwap)\
				.fortune_even(ObliviateRightmost).build()
		6:
			return SimpleAttackBuilder.new().fortune_every_turn(DestroyOnePlant)\
				.fortune_random(ObliviateRightmost)\
				.fortune_random(BlightrootTurnStart)\
				.fortune_random(DeathcapTurnStart)\
				.build()
		7:
			return SimpleAttackBuilder.new().fortune_every_turn(pick_random([ObliviateRightmost, EndTurnRotate.new(), DeathcapTurnStart]))\
				.fortune_even(DestroyTwoPlants).build()
		8:
			return SimpleAttackBuilder.new().fortune_even(pick_random([DestroyRow, DestroyCol, AddCorpseFlower]))\
				.fortune_once(WeedsEntireFarm)\
				.build()
		9:
			return SimpleAttackBuilder.new().fortune_odd(pick_random([DestroyRow, DestroyCol, AddCorpseFlower]))\
				.fortune_even(pick_random([ObliviateRightmost, BlockRitual, Counter]))\
				.build()
		10:
			return pick_random([SimpleAttackBuilder.new().fortune_odd(DestroyRow).fortune_even(DestroyCol).build(),\
				SimpleAttackBuilder.new().fortune_every_turn(AddCorpseFlower).build()])
		11:
			return SimpleAttackBuilder.new()\
				.fortune_every_turn(pick_random([DestroyRow, DestroyCol, AddCorpseFlower]))\
				.fortune_even(IncreaseRitual10)\
				.build()
		12:
			return SimpleAttackBuilder.new()\
				.fortune_every_turn(pick_random([DestroyRow, DestroyCol, AddCorpseFlower]))\
				.fortune_even(pick_random([IncreaseRitual10, EndTurnRotate.new()]))\
				.fortune_odd(Counter)\
				.build()
		13:
			return SimpleAttackBuilder.new()\
				.fortune_every_turn(pick_random([DestroyRow, DestroyCol, AddCorpseFlower]))\
				.fortune_even(IncreaseRitual10)\
				.fortune_odd(Counter)\
				.fortune_once(StartWithWeeds)\
				.fortune_at(WeedsEntireFarm, 3)\
				.build()
		_:
			return SimpleAttackBuilder.new()\
				.fortune_every_turn(pick_random([DestroyRow, DestroyCol, AddCorpseFlower]))\
				.fortune_every_turn(IncreaseRitual10)\
				.fortune_odd(pick_random([Counter, ObliviateRightmost, EndTurnRotate.new()]))\
				.fortune_once(pick_random([StartWithWeeds, BlightrootTurnStart]))\
				.fortune_at(WeedsEntireFarm, 3)\
				.build()
			

func pick_random(array):
	var index = randi_range(0, array.size() - 1)
	return array[index]
