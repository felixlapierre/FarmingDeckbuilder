extends Node

var week = 1
var year = 0

var ritual_counter: int = 0
var purple_mana: int = 0
var target_blight: int = 0
var next_turn_blight: int = 0

var blight_damage = 0

const TWEEN_DURATION = 0.8

var blight_pattern = []

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

# Return bool indicating if the ritual is complete
func gain_yellow_mana(amount):
	ritual_counter -= amount
	if ritual_counter < 0:
		ritual_counter = 0
		return true
	return false

func gain_purple_mana(amount):
	purple_mana += amount

# Return boolean if the player took damage
func end_turn():
	var damage = false
	if purple_mana < target_blight:
		damage = true
		blight_damage += 1
	
	purple_mana = 0
	
	var blight_remaining = target_blight - purple_mana
	blight_remaining = 0 if blight_remaining < 0 else blight_remaining
	week += 1
	target_blight = get_blight_requirements(week, year)
	next_turn_blight = get_blight_requirements(week + 1, year)
	$'../'.update()
	return damage

func start_new_year():
	year += 1
	week = 1
	compute_blight_pattern(week, year)
	print(blight_pattern)
	ritual_counter = get_ritual_requirements(year)
	target_blight = get_blight_requirements(week, year)
	next_turn_blight = get_blight_requirements(week + 1, year)
	purple_mana = 0

func end_year():
	pass

func compute_blight_pattern(week, year):
	blight_pattern = []
	if year < 3:
		blight_pattern.append_array([0, 0, 0, 0])
	elif year < 6:
		blight_pattern.append_array([0, 0, 0])
	else:
		blight_pattern.append_array([0, 0])
	
	var choice = randi_range(1, 3)
	match choice:
		1:
			blight_pattern.append_array([10, 0, 20, 0, 30, 0, 10, 0, 30])
		2:
			blight_pattern.append_array([20, 10, 0, 0, 30, 0, 10, 30, 0])
		3:
			blight_pattern.append_array([0, 10, 0, 20, 10, 0, 30, 0, 30])

func get_ritual_requirements(year):
	var amount = 20
	amount += year * 10
	if year > 3:
		amount += year * 10
	return amount

func get_blight_requirements(week, year):
	if week > blight_pattern.size():
		return 40 * get_blight_year_multiplier(year - 1)
	return blight_pattern[week - 1] * get_blight_year_multiplier(year)

func get_blight_year_multiplier(year):
	return 1.0 + year * 0.1
