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
		"obliviate", "remembrance", "harvest":
			return name.capitalize()
		"energy":
			return "Gain " + str(strength) + " energy on " + on
		"draw":
			return "Draw " + str(strength) + " cards on " + on
		"spread":
			return str(strength*100) + "% chance to spread on " + on
		_:
			return "OOPS no description"

# Only name as property:
# harvest
# obliviate
# remembrance

# These ones only have strength as a property
# multiply_yield
# draw
# grow
# add_yield
# irrigate
# recurring
# energy
# absorb

# spread
# on: (grow)

# for any structure also add
# on: (before_grow, after_grow, turn_start)
# range: (adjacent, nearby)

