extends Resource
class_name AttackPattern

var blight_pattern: Array[int] = []
var fortunes: Array[Fortune] = []
var rank: int = 0
var simple_attack_callback: Callable

func get_fortunes():
	return fortunes

func compute_fortunes(year: int):
	var fortunes = []
	for i in range(1, Global.FINAL_WEEK):
		fortunes.append(get_fortunes_at_week(i))
	return fortunes

func get_fortunes_at_week(week: int) -> Array[Fortune]:
	if simple_attack_callback != null:
		return simple_attack_callback.call(week)
	return []

func get_blight_pattern():
	return blight_pattern

func compute_blight_pattern(year: int):
	var blight_pattern = [0]
	var charge: float = 0.0
	var chance = 0.0
	for i in range(1, Global.FINAL_WEEK):
		charge += 10.0
		chance += 0.3
		if (year < 4 and i < 3) or (year < 10 and i < 2):
			blight_pattern.append(0)
		elif i == Global.FINAL_WEEK - 1:
			blight_pattern.append(charge)
			charge = 0.0
		elif randf() < chance:
			chance = 0.0
			var amount = int(randf_range(0.4, 0.8) * charge)
			charge -= amount
			blight_pattern.append(amount)
		else:
			blight_pattern.append(0)
	return blight_pattern
