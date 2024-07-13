extends Resource

class_name Structure

const CLASS_NAME = "Structure"

@export var name: String
@export var rarity: String
@export var cost: int
@export var size: int
@export var text: String
@export var texture: Texture2D
@export var effects: Array[Effect]
var grid_location: Vector2
var type = "STRUCTURE"

func _init(p_name = "PlaceholderCardName", p_rarity = "common", p_cost = 1,\
	p_size = 1, p_text = "", p_texture = null, p_effects = [], p_grid_location = Vector2.ZERO):
		name = p_name
		rarity = p_rarity
		cost = p_cost
		size = p_size
		text = p_text
		texture = p_texture
		effects.assign(p_effects)
		grid_location = p_grid_location

func get_effect(effect_name):
	for effect in effects:
		if effect.name == effect_name:
			return effect
	return null

func copy():
	var n_targets = []
	var n_effects = []
	for effect in effects:
		n_effects.append(effect.copy())
	return Structure.new(name, rarity, cost, size, text, texture, n_effects)

func get_description():
	return text

# To be overridden by specific script structures
func register_events(event_manager: EventManager, tile: Tile):
	pass

func unregister_events(event_manager: EventManager):
	pass

func do_winter_clear():
	pass

func save_data(grid_location: Vector2):
	return {
		"path": get_script().get_path(),
		"name": name,
		"rarity": rarity,
		"cost": cost,
		"size": size,
		"text": text,
		"texture": texture.resource_path,
		"effects": effects.map(func(effect):
			return effect.save_data()),
		"x": grid_location.x,
		"y": grid_location.y
	}

func load_data(data):
	name = data.name
	rarity = data.rarity
	cost = data.cost
	size = data.size
	text = data.text
	texture = load(data.texture)
	effects = data.effects.map(func(effect):
		return load(effect.path).new().load_data(effect))
	grid_location = Vector2(data.x, data.y)
