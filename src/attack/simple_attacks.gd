extends Node
class_name SimpleAttacks

var data_fetcher = preload("res://src/cards/cards_database.gd")

var simple_builders = {}

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func create_simple_attacks():
	for i in range(0, 4):
		simple_builders[i] = []
	for fortune in data_fetcher.get_all_fortunes():
		if fortune.type == Fortune.FortuneType.BadFortune:
			var simpleattack = SimpleAttackBuilder.new()
			match fortune.name:
				"Blightroot", "Ritual Disruption", "Overgrown", "Cursed Scrolls", "Weeds", "Kaleidoscope":
					simpleattack.fortune_once(fortune)
				_:
					simpleattack.fortune_every_turn(fortune)
			simpleattack.rank(fortune.rank)
			simple_builders[fortune.rank].append(simpleattack)

func get_simple_attack_year(year: int, misfortune: bool):
	if !misfortune:
		match year + 1:
			2, 3:
				return get_simple_attack([0])
			4, 5:
				return get_simple_attack([1])
			6:
				return get_simple_attack([1, 0])
			7:
				return get_simple_attack([2])
			8:
				return get_simple_attack([2])
			9:
				return get_simple_attack([2, 1])
			10:
				return get_simple_attack([2, 1])
			_:
				return get_simple_attack([2, 2])
	else:
		match year + 1:
			2, 3:
				return get_simple_attack([0])
			4:
				return get_simple_attack([1])
			5:
				return get_simple_attack([1, 0])
			6:
				return get_simple_attack([1, 1])
			7:
				return get_simple_attack([2, 0])
			8:
				return get_simple_attack([2, 1])
			9:
				return get_simple_attack([2, 2])
			10:
				return get_simple_attack([3])
			_:
				return get_simple_attack([3, 0])

func get_simple_attack(ranks: Array[int]) -> AttackPattern:
	var builder = SimpleAttackBuilder.new()
	for rank in ranks:
		var options: Array[SimpleAttackBuilder] = []
		options.assign(simple_builders[rank])
		var eligible = []
		for opt in options:
			if builder.compatible(opt):
				eligible.append(opt)
			
		var i = randi_range(0, eligible.size() - 1)
		builder.combine(eligible[i])
	return builder.build()
