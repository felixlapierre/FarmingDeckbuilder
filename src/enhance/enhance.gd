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
	targets.assign(p_targets)
	texture = p_texture

func copy():
	var n_targets = []
	for target in targets:
		n_targets.append(target)
	return Enhance.new(name, rarity, strength, n_targets, texture)

func is_card_eligible(card: CardData):
	match name:
		"Size":
			return card.size < 9
		"Discount":
			return card.cost > 0
		"GrowSpeed", "FlatYield":
			return card.type == "SEED"
		"SpreadGrow", "SpreadHarvest":
			return card.get_effect("spread") == null and card.type == "SEED"
		"Remembrance":
			return card.get_effect("remembrance") == null
		"Springbound":
			return card.get_effect("springbound") == null
		"Obliviate":
			return card.get_effect("obliviate") == null
		"RemoveObliviate":
			return card.get_effect("obliviate") != null
		"Strength":
			for effect in card.effects:
				if effect.strength != 0:
					return true
			return false
		_:
			return true
