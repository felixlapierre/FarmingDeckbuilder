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
	if card.cost == 99:
		return false
	if card.enhances.size() > 1:
		return false
	match name:
		"Size":
			return card.size < 9
		"Discount":
			return card.cost > 0
		"GrowSpeed", "FlatYield", "Regrow":
			return card.type == "SEED"
		"SpreadGrow", "SpreadHarvest":
			return card.get_effect("spread") == null and card.type == "SEED"
		"Remembrance":
			return card.get_effect("remembrance") == null
		"Springbound":
			return card.get_effect("springbound") == null
		"Burn":
			return card.get_effect("obliviate") == null
		"RemoveBurn":
			return card.get_effect("obliviate") != null
		"Strength":
			for effect in card.effects:
				if effect.strength != 0:
					return true
			return false
		_:
			return true

func get_description():
	match name:
		"Size":
			return "Increase the size of the area affected by a card"
		"Discount":
			return "Reduce a card's Cost by 1"
		"GrowSpeed":
			return "Make a seed grow 1 week faster"
		"FlatYield":
			return "Increase a seed's yield by 1"
		"SpreadGrow":
			return "Give a seed 50% chance to spread on grow"
		"SpreadHarvest":
			return "Give a seed 100% chance to spread on harvest"
		"Frozen":
			return "Add Frozen to a card (Card is not discarded at the end of the turn)"
		"Springbound":
			return "Add Springbound to a card (Card will always be drawn on the first week of Spring)"
		"Burn":
			return "Add Burn to a card (Card is temporarily removed from your deck when played)"
		"RemoveBurn":
			return "Remove Burn from a card"
		"Strength":
			return "Increase the strength of a card's special effects"
		"Regrow":
			return "Add Regrow 3 to a card (Card is re-planted with +3 base yield when harvested)"
		_:
			return "TODO"

func save_data() -> Dictionary:
	var data = {
		"path": get_script().get_path(),
		"name": name,
		"rarity": rarity,
		"strength": strength,
		"targets": targets,
		"texture": texture.resource_path if texture != null else null
	}
	return data

func load_data(data: Dictionary) -> Enhance:
	name = data.name
	rarity = data.rarity
	strength = data.strength
	targets.assign(data.targets)
	texture = load(data.texture) if data.texture != null else null
	return self
