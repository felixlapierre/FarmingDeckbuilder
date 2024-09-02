extends Node
class_name TurnManager

var week = 1
var year = 0

var energy: int = 3
var ritual_counter: int = 0
var purple_mana: int = 0
var target_blight: int = 0
var next_turn_blight: int = 0
var flag_defer_excess: bool = false

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
func gain_yellow_mana(amount, delay):
	flag_defer_excess = flag_defer_excess or delay
	ritual_counter -= amount
	if ritual_counter <= 0:
		ritual_counter = 0
		return true
	if flag_defer_excess and purple_mana > target_blight:
		next_turn_blight -= purple_mana - target_blight
		purple_mana = target_blight
	return false

func gain_purple_mana(amount, delay):
	flag_defer_excess = flag_defer_excess or delay
	if purple_mana + amount < 0: #meaning amount < 0
		amount += purple_mana
		purple_mana = 0
		if flag_defer_excess:
			next_turn_blight -= amount
		else:
			target_blight -= amount
	else:
		purple_mana += amount
		if flag_defer_excess and purple_mana > target_blight:
			next_turn_blight -= purple_mana - target_blight
			purple_mana = target_blight
	

# Return boolean if the player took damage
func end_turn():
	var damage = false
	if purple_mana < target_blight:
		damage = true
		if week < Global.FINAL_WEEK:
			blight_damage += 1
		else:
			blight_damage = 5
	
	var blight_remaining = target_blight - purple_mana
	blight_remaining = 0 if blight_remaining < 0 else blight_remaining
	week += 1
	purple_mana = 0
	target_blight = next_turn_blight + blight_remaining
	next_turn_blight = get_blight_requirements(week + 1, year)
	energy = get_max_energy()
	flag_defer_excess = false
	return damage

func start_new_year():
	year += 1
	week = 1
	compute_blight_pattern(week, year)
	ritual_counter = get_ritual_requirements(year)
	target_blight = get_blight_requirements(week, year)
	next_turn_blight = get_blight_requirements(week + 1, year)
	purple_mana = 0
	energy = get_max_energy()

func end_year():
	pass

func compute_blight_pattern(week, year):
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
	return

func get_ritual_requirements(year):
	var difficulty_up = Global.DIFFICULTY >= Constants.DIFFICULTY_INCREASE_TARGETS
	var amount = 20
	amount += year * 10
	if year <= 3:
		amount += 10
	if year > 2:
		amount += year * 10
		if difficulty_up:
			amount += year * 2
	if year > 6 and difficulty_up:
		amount += year * 5
	if year >= 10 and difficulty_up:
		amount += 100
	return amount

func get_blight_requirements(week, year):
	var amt = 0
	if week > blight_pattern.size():
		amt = 40 * get_blight_year_multiplier(year - 1)
	else:
		amt = blight_pattern[week - 1] * get_blight_year_multiplier(year)
	return amt * Global.BLIGHT_TARGET_MULTIPLIER * (1.2 if Global.DIFFICULTY > Constants.DIFFICULTY_INCREASE_TARGETS else 1.0)

func get_blight_year_multiplier(year):
	return 1.0 + year * 0.1

func get_max_energy():
	var new_energy = Constants.MAX_ENERGY
	if (Global.ENERGY_FRAGMENTS % 3 > (week-1) % 3):
		new_energy += 1
	new_energy += int(float(Global.ENERGY_FRAGMENTS) / 3)
	return new_energy

func get_cards_drawn():
	var cards_drawn = Constants.BASE_HAND_SIZE
	if (Global.SCROLL_FRAGMENTS % 3 > (week-1) % 3):
		cards_drawn += 1
	cards_drawn += int(float(Global.SCROLL_FRAGMENTS) / 3)
	return cards_drawn

func get_blight_at_week(week):
	return 0 if week < 5 else randi_range(0, 1) * (week * randi_range(1,3))

func set_blight_targeted_tiles(farm: Farm):
	var number_tiles = Constants.BASE_BLIGHT_DAMAGE if target_blight > 0 else 0
	var all_tiles = farm.get_all_tiles()
	all_tiles.shuffle()
	var target_tile_states = [Enums.TileState.Empty, Enums.TileState.Growing, Enums.TileState.Mature]\
		if Global.DIFFICULTY < 1 else [Enums.TileState.Growing]
	var valid_targets = []
	for tile in all_tiles:
		tile.set_blight_targeted(false)
		if target_tile_states.has(tile.state):
			valid_targets.append(tile)
	# In case we are targeting only growing plants and there aren't enough
	while valid_targets.size() < number_tiles:
		for tile in all_tiles:
			if [Enums.TileState.Empty, Enums.TileState.Mature].has(tile.state):
				valid_targets.append(tile)
				if valid_targets.size() >= number_tiles:
					break
	for i in range(number_tiles):
		valid_targets[i].set_blight_targeted(true)

func destroy_blighted_tiles(farm: Farm):
	farm.destroy_blighted_tiles()
