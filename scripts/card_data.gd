extends Resource

class_name CardData

@export var type: String
@export var name: String
@export var rarity: String
@export var cost: int
@export var yld: int
@export var time: int
@export var size: int
@export var text: String
@export var texture: Texture2D
@export var seed_texture: int
@export var targets: Array[String]
@export var effects: Array[Dictionary]

func _init(p_type = "CARD", p_name = "PlaceholderCardName", p_rarity = "common", p_cost = 1, p_yld = 1,\
	p_time = 1, p_size = 1, p_text = "", p_texture = null, p_seed_texture = 1, p_targets = [], p_effects = []):
		type = p_type
		name = p_name
		rarity = p_rarity
		cost = p_cost
		yld = p_yld
		time = p_time
		size = p_size
		text = p_text
		texture = p_texture
		seed_texture = p_seed_texture
		targets.assign(p_targets)
		effects.assign(p_effects)

func get_effect(effect_name):
	for effect in effects:
		if effect.name == effect_name:
			return effect
	return null
