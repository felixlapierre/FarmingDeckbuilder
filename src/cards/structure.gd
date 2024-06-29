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

func _init(p_name = "PlaceholderCardName", p_rarity = "common", p_cost = 1,\
	p_size = 1, p_text = "", p_texture = null, p_effects = []):
		name = p_name
		rarity = p_rarity
		cost = p_cost
		size = p_size
		text = p_text
		texture = p_texture
		effects.assign(p_effects)

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

# To be overridden by specific script structures
func register_events(event_manager: EventManager, tile: Tile):
	pass

func unregister_events(event_manager: EventManager):
	pass
