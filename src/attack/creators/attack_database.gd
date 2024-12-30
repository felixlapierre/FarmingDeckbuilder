extends Node
class_name AttackDatabase

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
	# Weeds once
	add(SimpleAttackBuilder.new().fortune_once(AddWeeds.new(10))\
		.easy(2).normal(1).build())
	
	# Weeds every 3 turns
	add(SimpleAttackBuilder.new().fortune_every(AddWeeds.new(10), 3)\
		.easy(3).hard(2).build())
	
	# Weeds every 2 turns
	add(SimpleAttackBuilder.new().fortune_odd(AddWeeds.new(10))\
		.normal(3).mastery(2).build())
	
	# Weeds every turn
	add(SimpleAttackBuilder.new().fortune_every_turn(AddWeeds.new(10))\
		.easy(4).hard(3).build())

	# Fill farm with weeds once
	add(SimpleAttackBuilder.new().fortune_once(WeedsEntireFarm.new())\
		.easy(3).normal(3).hard(3).mastery(2).build())

	# Fill your farm with weeds every x turn
	add(SimpleAttackBuilder.new().fortune_every(WeedsEntireFarm.new(), 3)\
		.normal(5).hard(4).mastery(3).build())
	add(SimpleAttackBuilder.new().fortune_every(WeedsEntireFarm.new(), 2)\
		.easy(6).hard(5).mastery(4).build())
	add(SimpleAttackBuilder.new().fortune_every_turn(WeedsEntireFarm.new())\
		.hard(6).mastery(7).build())
	
	# Weeds whenever you play a card
	add(simple_every(WeedsEveryCard.new(1)).normal(4).hard(3).mastery(2).build())
	add(simple_every(WeedsEveryCard.new(2)).normal(5).hard(4).mastery(3).build())
	
	# Blightroot
	add(SimpleAttackBuilder.new().fortune_once(AddBlightroot.new(1)).easy(2).normal(1).build())
	add(SimpleAttackBuilder.new().fortune_every_turn(AddBlightroot.new(1)).easy(3).normal(2).hard(1).build())
	
	#Deathcap
	add(SimpleAttackBuilder.new().fortune_every_turn(AddDeathcap.new(1)).easy(6).normal(5).hard(4).mastery(3).build())
	add(SimpleAttackBuilder.new().fortune_once(AddDeathcap.new(8)).hard(3).mastery(3).build())
	add(SimpleAttackBuilder.new().fortune_once(AddDeathcap.new(16)).mastery(5).build())
	
	# Destroy
	add(simple_every(DestroyPlants.new(1)).easy(3).normal(2).hard(1).mastery(1).build())
	add(simple_every(DestroyPlants.new(2)).easy(5).normal(4).hard(3).mastery(3).build())
	add(SimpleAttackBuilder.new().fortune_even(Helper.pick_random([DestroyRow.new(), DestroyCol.new()])).easy(8).normal(7).hard(6).mastery(5).build())
	add(simple_every(Helper.pick_random([DestroyRow.new(), DestroyCol.new()])).normal(8).hard(7).mastery(6).build())
	
	add(simple_every(DestroyTiles.new(1)).easy(3).normal(3).hard(2).mastery(1).build())
	add(simple_every(DestroyTiles.new(2)).easy(7).normal(6).hard(5).mastery(4).build())
	
	# Kaleidoscope
	add(SimpleAttackBuilder.new().fortune_once(EndTurnRandomizeColors.new()).easy(4).normal(2).hard(2).mastery(1).build())
	add(simple_every(EndTurnSwapColors.new()).easy(3).normal(3).hard(2).mastery(2).build())
	add(simple_every(EndTurnRotateColors.new()).easy(6).normal(5).hard(4).mastery(2).build())
	
	# Disruption
	add(SimpleAttackBuilder.new().fortune_even(BlockRitual.new(1)).hard(6).mastery(5).build())
	add(SimpleAttackBuilder.new().fortune_even(Counter.new(3)).hard(6).mastery(5).build())
	add(simple_every(IncreaseRitualTarget.new(0.1)).easy(5).hard(4).mastery(3).build())
	
	# Hand and deck manipulation
	add(simple_every(EndTurnBurn.new()).easy(6).normal(6).hard(5).mastery(4).build())
	
	# Plants
	add(SimpleAttackBuilder.new().fortune_odd(AddCorpseFlower.new()).easy(8).normal(7).hard(6).mastery(5).build())
	add(simple_every(AddCorpseFlower.new(1)).hard(8).mastery(7).build())
	
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
			.fortune_once(Helper.pick_random([EndTurnRandomizeColors.new(), AddWeeds.new(10), AddDarkThornsDeck.new(1)]))\
			.fortune_every_turn(Helper.pick_random([AddBlightroot.new(1), EndTurnSwapColors.new(), DestroyPlants.new(1)]))\
			.build())
	
	add(SimpleAttackBuilder.new().fortune_once(AddBlightroot.new(1))\
				.fortune_even(DestroyPlants.new(1))\
				.fortune_odd(IncreaseRitualTarget.new(0.1)).hard(4).mastery(3).build())
	
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
	add(SimpleAttackBuilder.new().fortune_even(Helper.pick_random([DestroyRow.new(), DestroyCol.new(), AddCorpseFlower.new()]))\
				.fortune_once(WeedsEntireFarm.new())\
				.normal(7).hard(6).mastery(5).build())
	add(SimpleAttackBuilder.new().fortune_every_turn(Helper.pick_random([DestroyRow.new(), DestroyCol.new(), AddCorpseFlower.new()]))\
				.fortune_even(Helper.pick_random([EndTurnBurn.new(), BlockRitual.new(1.0), Counter.new(3)]))\
				.hard(8).mastery(8).build())
