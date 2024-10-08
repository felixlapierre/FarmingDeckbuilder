extends Node
class_name SimpleAttackBuilder

var attack: SimpleAttack

func _init():
	attack = SimpleAttack.new()

func fortune_once(fortune: Fortune) -> SimpleAttackBuilder:
	attack.fortunes_once.append(fortune)
	return self

func fortune_every_turn(fortune: Fortune) -> SimpleAttackBuilder:
	attack.fortunes_every_turn.append(fortune)
	return self

func fortune_even(fortune: Fortune) -> SimpleAttackBuilder:
	attack.fortunes_even.append(fortune)
	return self

func fortune_odd(fortune: Fortune) -> SimpleAttackBuilder:
	attack.fortunes_odd.append(fortune)
	return self

func fortune_random(fortune: Fortune) -> SimpleAttackBuilder:
	attack.fortunes_random.append(fortune)
	return self

func fortune_at(fortune: Fortune, week: int) -> SimpleAttackBuilder:
	attack.fortunes_at.append({
		"week": week,
		"fortune": fortune
	})
	return self

func rank(p_rank: int) -> SimpleAttackBuilder:
	attack.rank = p_rank
	return self

func combine(other: SimpleAttackBuilder) -> SimpleAttackBuilder:
	attack.fortunes_once.append_array(other.attack.fortunes_once)
	attack.fortunes_every_turn.append_array(other.attack.fortunes_every_turn)
	return self

func compatible(other: SimpleAttackBuilder) -> bool:
	for fortune in other.attack.fortunes_every_turn:
		if attack.fortunes_every_turn.has(fortune) or attack.fortunes_every_turn.any(func(current):
			return fortune.name.split(" ")[0] == current.name.split(" ")[0]):
			return false
	return true

func build() -> AttackPattern:
	attack.fortunes_random.shuffle()
	return attack
