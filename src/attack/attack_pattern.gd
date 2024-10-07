extends Resource
class_name AttackPattern

var blight_pattern: Array[int] = []
var fortunes: = []
var rank: int = 0
var simple_attack_callback: Callable

var current_fortunes = []

func get_fortunes():
	return fortunes

func compute_fortunes(year: int):
	fortunes = []
	for i in range(1, Global.FINAL_WEEK + 1):
		fortunes.append(get_fortunes_at_week(i))

func get_fortunes_at_week(week: int) -> Array[Fortune]:
	if !simple_attack_callback.is_null():
		return simple_attack_callback.call(week)
	return []

func register_fortunes(event_manager: EventManager, week: int):
	unregister_fortunes(event_manager)
	current_fortunes.append_array(get_fortunes_at_week(week))
	for fortune: Fortune in current_fortunes:
		fortune.register_fortune(event_manager)

func unregister_fortunes(event_manager: EventManager):
	for fortune: Fortune in current_fortunes:
		fortune.unregister_fortune(event_manager)
	current_fortunes.clear()

func get_blight_pattern():
	return blight_pattern

func compute_blight_pattern(year: int):
	blight_pattern = [0]
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
	# Winter
	blight_pattern.append(40)
	for i in range(blight_pattern.size()):
		blight_pattern[i] = blight_pattern[i] * get_multiplier(year)

func get_multiplier(year: int):
	var year_multiplier = 1.0 + (year - 1) * 0.1
	var difficulty_multiplier = Global.BLIGHT_TARGET_MULTIPLIER * \
		(1.2 if Global.DIFFICULTY > Constants.DIFFICULTY_INCREASE_TARGETS else 1.0)
	return year_multiplier * difficulty_multiplier
