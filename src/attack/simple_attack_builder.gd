extends Node
class_name SimpleAttackBuilder

var fortunes_once = []
var fortunes_every_turn = []
var myrank = 1

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func fortune_once(fortune: Fortune) -> SimpleAttackBuilder:
	fortunes_once.append(fortune)
	return self

func fortune_every_turn(fortune: Fortune) -> SimpleAttackBuilder:
	fortunes_every_turn.append(fortune)
	return self

func rank(p_rank: int) -> SimpleAttackBuilder:
	myrank = p_rank
	return self

func combine(other: SimpleAttackBuilder) -> SimpleAttackBuilder:
	fortunes_once.append_array(other.fortunes_once)
	fortunes_every_turn.append_array(other.fortunes_every_turn)
	return self

func compatible(other: SimpleAttackBuilder) -> bool:
	for fortune in other.fortunes_every_turn:
		if fortunes_every_turn.has(fortune) or fortunes_every_turn.any(func(current):
			return fortune.name.split(" ")[0] == current.name.split(" ")[0]):
			return false
	return true

func build() -> AttackPattern:
	var attack = AttackPattern.new()
	attack.simple_attack_callback = func(week: int):
		var result: Array[Fortune] = []
		if week == 1:
			result.append_array(fortunes_once)
		result.append_array(fortunes_every_turn)
		return result
	attack.rank = myrank
	return attack
	
