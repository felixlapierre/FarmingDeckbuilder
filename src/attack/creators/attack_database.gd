extends Node
class_name AttackDatabase

var add_10_weeds = AddWeeds.new(10)
var add_blightroot = AddBlightroot.new(1)
var add_deathcap = AddDeathcap.new(1)
var burn_rightmost = EndTurnBurn.new()
var weeds_entire_farm = WeedsEntireFarm.new()
var weeds_every_card = WeedsEveryCard.new(1)
var weeds_2_every_card = WeedsEveryCard.new(2)

var add_corpse_flower = AddCorpseFlower.new(1)

var destroy_one_plant = DestroyPlants.new(1)
var destroy_two_plants = DestroyPlants.new(2)
var destroy_one_tile = DestroyTiles.new(1)
var destroy_two_tiles = DestroyTiles.new(2)

var destroy_row = DestroyRow.new()
var destroy_col = DestroyCol.new()

var end_turn_swap = EndTurnSwapColors.new()
var end_turn_rotate = EndTurnRotateColors.new()
var end_turn_randomize = EndTurnRandomizeColors.new()

var increase_ritual_10 = IncreaseRitualTarget.new(0.1)
var block_ritual = BlockRitual.new(1.0)

var two_dark_thorns = AddDarkThornsDeck.new(2)
var two_blood_thorns = AddBloodThornsDeck.new(2)
var one_dark_thorn = AddDarkThornsDeck.new(1)
var one_blood_thorn = AddBloodThornsDeck.new(1)

# Store first by difficulty then week, then a list of AttackPattern
var database: Dictionary = {}

func simple_every(fortune: Fortune) -> SimpleAttackBuilder:
	return SimpleAttackBuilder.new().fortune_every_turn(fortune)

func simple_every_list(fortunes: Array[Fortune]) -> SimpleAttackBuilder:
	var builder = SimpleAttackBuilder.new()
	for fortune in fortunes:
		builder.fortune_every_turn(fortune)
	return builder

func get_attacks(difficulty: String, week: int) -> Array[AttackPattern]:
	var result: Array[AttackPattern] = []
	var diff = database.get(difficulty)
	var options = diff.get(week + 1)
	result.assign(options)
	return result

func add(attack: AttackPattern):
	for difficulty in attack.difficulty_map.keys():
		if !database.has(difficulty):
			database[difficulty] = {}
		var map = database[difficulty]
		var week = attack.difficulty_map[difficulty]
		if !map.has(week):
			map[week] = []
		map[week].append(attack)

# Create every single attack in the game lol
func populate_database():
	# Easy week 2
	add(SimpleAttackBuilder.new().fortune_once(add_10_weeds)\
		.easy(2).normal(1).hard(1).mastery(1).build())
	add(SimpleAttackBuilder.new().fortune_once(add_blightroot)\
		.easy(2).normal(1).hard(1).mastery(1).build())
	
	# Easy first boss
	add(simple_every(destroy_one_plant)\
		.easy(3).normal(2).hard(2).mastery(2).build())
	add(SimpleAttackBuilder.new().fortune_every_turn(add_blightroot)\
		.easy(3).normal(2).hard(2).mastery(2).build())
	add(simple_every(end_turn_swap)
		.easy(3).normal(2).hard(2).mastery(2).build())
	add(simple_every(DestroyTiles.new(1))
		.easy(3).normal(2).hard(2).mastery(2).build())
	add(simple_every(IncreaseRitualTarget.new(0.1))\
		.easy(3).normal(2).hard(2).mastery(2).build())
	
	# Easy year 4-5 / Normal first boss
	add(simple_every(DestroyPlants.new(1)).fortune_once(EndTurnRandomizeColors.new())\
		.easy(4).easy(5).normal(3).build())
	add(SimpleAttackBuilder.new().fortune_once(weeds_entire_farm)\
		.easy(4).easy(5).normal(3).build())
	add(simple_every(add_blightroot).fortune_once(add_10_weeds)\
		.easy(4).easy(5).normal(3).build())
	add(simple_every(end_turn_swap).fortune_once(DestroyTiles.new(5))\
		.easy(4).easy(5).normal(3).build())
	#TODO One more at least
	
	# Easy 2nd boss
	add(simple_every(burn_rightmost)\
		.easy(6).normal(5).hard(5).mastery(4).build())
	add(SimpleAttackBuilder.new().fortune_every_turn(add_deathcap)\
		.easy(6).normal(5).hard(5).mastery(4).build())
	add(simple_every(end_turn_rotate)\
		.easy(6).normal(5).hard(5).mastery(4).build())
	add(simple_every(destroy_two_plants)\
		.easy(6).normal(5).hard(5).mastery(4).build())
	
	# Easy year 7
	add(SimpleAttackBuilder.new().fortune_even(Helper.pick_random([destroy_row, destroy_col]))\
		.easy(7).build())
	add(SimpleAttackBuilder.new().fortune_odd(add_corpse_flower)\
		.easy(7).build())
	add(SimpleAttackBuilder.new().fortune_every_turn(IncreaseBlightStrength.new(0.5)).damage_multiplier(1.5)\
		.easy(7).build())
	
	# Easy final boss
	add(simple_every(add_corpse_flower)\
		.easy(8).hard(7).mastery(6).build())
	add(simple_every(Helper.pick_random([destroy_row, destroy_col]))\
		.easy(8).hard(7).mastery(6).build())
	add(SimpleAttackBuilder.new().fortune_every_turn(IncreaseBlightStrength.new(1.0)).damage_multiplier(2.0)\
		.easy(8).build())
	add(simple_every(destroy_two_tiles)
		.easy(8).mastery(6).build())
	add(simple_every_list([burn_rightmost, add_deathcap])\
		.easy(8).normal(7).hard(6).mastery(5).build())
	
	# Normal-Hard-Mastery turns 1-2 are already done
	
	# Normal 3: thorns are new
	add(simple_every(increase_ritual_10).fortune_once(Helper.pick_random([two_blood_thorns, two_dark_thorns]))\
		.normal(3).build())
	
	# Two easy 1st bosses: Normal 4, Hard 3, Mastery 3
	add(simple_every_list([destroy_one_plant, add_blightroot])\
		.normal(4).hard(3).mastery(3).build())
	add(simple_every_list([destroy_one_plant, end_turn_swap])\
		.normal(4).hard(3).mastery(3).build())
	add(simple_every_list([destroy_one_tile, increase_ritual_10])\
		.normal(4).hard(3).mastery(3).build())
	add(simple_every_list([add_blightroot, end_turn_swap])\
		.normal(4).hard(3).mastery(3).build())
	add(simple_every_list([add_blightroot, increase_ritual_10])\
		.normal(4).hard(3).mastery(3).build())
	add(simple_every_list([destroy_one_plant, increase_ritual_10])\
		.normal(4).hard(3).mastery(3).build())
	
	# Normal 5 is already done, it's easy second boss
	# Normal 2nd boss
	add(simple_every_list([burn_rightmost, add_blightroot])\
		.normal(6).hard(5).mastery(4).build())
	add(simple_every(Helper.pick_random([one_blood_thorn, one_dark_thorn]))\
		.normal(6).hard(5).mastery(4).build())
	add(simple_every(WeedsEveryCard.new(1)).fortune_every_turn(end_turn_rotate)\
		.normal(6).hard(5).mastery(4).build())
	add(simple_every_list([add_deathcap, end_turn_swap])\
		.normal(6).hard(5).mastery(4).build())
	add(simple_every_list([destroy_two_plants, increase_ritual_10])\
		.normal(6).hard(5).mastery(4).build())
	
	# Normal week 7
	add(simple_every_list([Helper.pick_random([destroy_row, destroy_col]), end_turn_swap])\
		.normal(7).build())
	add(simple_every_list([Helper.pick_random([one_dark_thorn, one_blood_thorn]), add_10_weeds])\
		.normal(7).build())
	add(simple_every_list([burn_rightmost, end_turn_rotate])\
		.normal(7).build())
	# We also have burn + deathcap from easy final boss
	
	# Normal year 8 final boss
	add(simple_every(Helper.pick_random([destroy_row, destroy_col])).fortune_once(Helper.pick_random([AddBloodThornsDeck.new(3), AddDarkThornsDeck.new(3)]))\
		.normal(8))
	add(simple_every_list([add_corpse_flower, add_blightroot])\
		.normal(8).build())
	add(simple_every_list([IncreaseBlightStrength.new(1.0), increase_ritual_10]).damage_multiplier(2.0)\
		.normal(8).build())
	add(simple_every_list([destroy_two_tiles, add_10_weeds])\
		.normal(8).build())
	add(simple_every(burn_rightmost).fortune_random(add_deathcap).fortune_random(end_turn_swap).fortune_at(weeds_entire_farm, 4)\
		.normal(8).build())
	
	# Hard: Year 4
	add(simple_every(weeds_2_every_card).hard(4).mastery(3).build())
	add(simple_every(weeds_every_card).fortune_even(block_ritual)\
		.hard(4))
	add(SimpleAttackBuilder.new().fortune_once(AddBlightroot.new(1))\
			.fortune_even(DestroyPlants.new(1))\
			.fortune_odd(IncreaseRitualTarget.new(0.1))\
			.hard(4).mastery(3).build())
	
	# Hard year 5 is normal 2nd boss
	# Hard 2nd boss
	
	# Weeds every turn
	add(SimpleAttackBuilder.new().fortune_every_turn(Add10Weeds)\
		.easy(4).hard(3).build())

	# Fill farm with weeds once
	add(SimpleAttackBuilder.new().fortune_once(WeedsEntireFarmInst)\
		.easy(3).normal(3).hard(3).mastery(2).build())

	# Fill your farm with weeds every x turn

	add(SimpleAttackBuilder.new().fortune_every(WeedsEntireFarmInst, 2)\
		.easy(6).hard(5).mastery(4).build())
	add(SimpleAttackBuilder.new().fortune_every_turn(WeedsEntireFarmInst)\
		.hard(6).mastery(7).build())
	
	# Weeds whenever you play a card
	add(simple_every(WeedsEveryCard.new(1)).normal(4).hard(3).mastery(2).build())

	
	#Deathcap

	add(SimpleAttackBuilder.new().fortune_once(AddDeathcap.new(8)).hard(3).mastery(3).build())
	add(SimpleAttackBuilder.new().fortune_once(AddDeathcap.new(16)).mastery(5).build())
	
	# Destroy
	
	# Kaleidoscope
	add(SimpleAttackBuilder.new().fortune_once(EndTurnRandomizeColors.new()).easy(4).normal(2).hard(2).mastery(1).build())


	
	# Disruption
	add(SimpleAttackBuilder.new().fortune_even(BlockRitual.new(1)).hard(6).mastery(5).build())
	add(SimpleAttackBuilder.new().fortune_even(Counter.new(3)).hard(6).mastery(5).build())
	
	# Hand and deck manipulation

	
	# Plants


	
	# Combinations
	
	# Week 5 easy
	for attack: SimpleAttackBuilder in [simple_every_list([AddBlightroot.new(1), DestroyPlants.new(1)]),
		simple_every_list([AddBlightroot.new(1), EndTurnSwapColors.new()])]:
		add(attack.easy(5).normal(4).hard(3).build())
	
	# Week 7 easy
	for attack: SimpleAttackBuilder in [
		simple_every_list([EndTurnBurn.new(), Helper.pick_random([DestroyPlants.new(1), DestroyTiles.new(1), AddBlightroot.new(1)])]),
		simple_every_list([IncreaseRitualTarget.new(0.1), Helper.pick_random([DestroyPlants.new(1), DestroyTiles.new(1), AddBlightroot.new(1)])])
	]:
		add(attack.easy(7).normal(6).hard(5).build())
	
	# Hard
	add(SimpleAttackBuilder.new().fortune_every_turn(Helper.pick_random([DestroyPlants.new(1)]))\
			.fortune_once(Helper.pick_random([EndTurnRandomizeColors.new(), AddBlightroot.new(2)]))\
			.hard(2).mastery(2).build())
	add(SimpleAttackBuilder.new()\
			.fortune_once(Helper.pick_random([EndTurnRandomizeColors.new(), Add10Weeds, AddDarkThornsDeck.new(1)]))\
			.fortune_every_turn(Helper.pick_random([AddBlightroot.new(1), EndTurnSwapColors.new(), DestroyPlants.new(1)]))\
			.hard(3).mastery(2).build())
	

	
	add(SimpleAttackBuilder.new().fortune_every_turn(AddBlightroot.new(1))\
				.fortune_odd(EndTurnSwapColors.new())\
				.fortune_even(EndTurnBurn.new()).hard(5).mastery(4).build())

	add(SimpleAttackBuilder.new().fortune_every_turn(DestroyPlants.new(1))\
				.fortune_random(EndTurnBurn.new())\
				.fortune_random(AddBlightroot.new(1))\
				.fortune_random(AddDeathcap.new(1))\
				.hard(6).mastery(5).build())
	add(SimpleAttackBuilder.new().fortune_every_turn(Helper.pick_random([EndTurnBurn.new(), EndTurnRotateColors.new(), AddDeathcap.new(1)]))\
				.fortune_even(DestroyPlants.new(2)).hard(7).mastery(6).build())
	add(SimpleAttackBuilder.new().fortune_even(Helper.pick_random([destroy_row, destroy_col, AddCorpseFlower.new()]))\
				.fortune_once(WeedsEntireFarmInst)\
				.normal(7).hard(6).mastery(5).build())
	add(SimpleAttackBuilder.new().fortune_every_turn(Helper.pick_random([destroy_row, destroy_col, AddCorpseFlower.new()]))\
				.fortune_even(Helper.pick_random([EndTurnBurn.new(), BlockRitual.new(1.0), Counter.new(3)]))\
				.hard(8).mastery(8).build())
