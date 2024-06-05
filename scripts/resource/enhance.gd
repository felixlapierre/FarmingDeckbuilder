extends Resource
class_name Enhance

const CLASS_NAME = "Enhance"

@export var name: String
@export var rarity: String
@export var strength: float
# Optional
@export var targets: Array[String]
@export var texture: Texture2D


func _init(p_name = "name", p_rarity = "common", p_strength = 1.0, p_targets = [], p_texture = null):
	name = p_name
	rarity = p_rarity
	strength = p_strength
	targets = p_targets
	texture = p_texture

func copy():
	var n_targets = []
	for target in targets:
		n_targets.append(target)
	return Enhance.new(name, rarity, strength, n_targets, texture)
