extends Resource
class_name Effect

@export var name: String

# Optional, depends on effect
@export var strength: float = 0

# Optional, depends on effect, always needed for structure
# Values: turn_start, before_grow, after_grow
# plant, grow, harvest
@export var on: String

# Optional, required for structure
# Values: self, adjacent, nearby
@export var range: String = "self"

# Should only be defined through at_location to avoid modifying what's on the seed
var grid_location: Vector2

# Will be defined during code execution for certain effects
@export var card: CardData = null

func _init(p_name = "", p_strength = 0.0, p_on = "", p_range = "self", p_grid_location = Vector2.ZERO, p_card = null):
	name = p_name
	strength = p_strength
	range = p_range
	on = p_on
	grid_location = p_grid_location
	card = p_card

# Creates a copy of this effect at the given location
func copy() -> Effect:
	var copy = Effect.new()
	copy.name = name
	copy.strength = strength
	copy.range = range
	copy.on = on
	copy.grid_location = grid_location
	copy.card = card.copy() if card != null else null
	return copy

func set_location(new_location: Vector2) -> Effect:
	grid_location = new_location
	return self

func set_card(new_card: CardData) -> Effect:
	if card == null and new_card != null:
		card = new_card
	return self

func sort(a: Effect, b: Effect):
	# return true if a is less than b
	var priority = ["irrigate", "plant"]
	var a_prio = priority.find(a, 0)
	var b_prio = priority.find(b, 0)
	#if a_prio == b_prio:
	#	return randi_range(0, 1) < 1
	#else:
	#	return a_prio > b_prio
	return a_prio > b_prio

func get_short_description():
	match name:
		"plant":
			if on == "harvest":
				return "On harvest, re-plant seed with +%s yield" % strength
		"obliviate", "remembrance", "springbound":
			return name.capitalize()
		"energy":
			return "Gain " + str(strength) + " energy" + get_on_text()
		"draw":
			return "Draw " + str(strength) + " card" + ("s" if strength > 1 else "") + get_on_text()
		"spread":
			return str(strength*100) + "% chance to spread" + get_on_text()
		"increase_yield":
			return "Increase yield by " + str(strength * 100) + "%"
		"harvest":
			return "Harvest target plants"
		"harvest_delay":
			return "Harvest fully grown plants and gain the yield next week"
		"grow":
			return "Grow targeted plants" + (" " + str(strength) + " times" if strength > 1 else "")
		"add_yield":
			return "Add " + get_strength_text() + " yield" + get_on_text()
		"irrigate":
			return "Irrigate tiles for " + str(strength) + " weeks"
		"absorb":
			return "Benefits " + str(strength*100) + "% more from irrigation"
		"destroy_tile":
			return "Destroy tile" + get_on_text()
		"destroy_plant":
			return "Destroy plant" + get_on_text()
		"replant":
			return "Replant target plants"
		"add_recurring":
			return "Add 'Recurring' to target plants"
		"draw_target":
			return "Add " + get_strength_text() + " cop" + ("y" if strength == 1 else "ies") + " of target plant's seed to your hand"
		"add_blight_yield":
			return "Add " + get_strength_text() + "×Blight to seed base yield"
		"fleeting":
			return "Obliviate on play or discard"
		_:
			return ""

func get_on_text():
	return " on " + on if on.length() > 0 else ""

func get_strength_text():
	if strength >= 0:
		return str(strength)
	elif strength == -1:
		return "X"
	else:
		return str(strength * -1) + "X"

func save_data():
	return {
		"path": get_script().get_path(),
		"name": name,
		"strength": strength,
		"on": on,
		"range": range
	}

func load_data(data):
	name = data.name
	strength = data.strength
	on = data.on
	range = data.range
