extends Resource
class_name Upgrade

@export var name: String
@export var strength: float
@export var card: CardData
@export var enhance: Enhance

func _init(p_name = "name", p_strength = 1.0, p_card = null, p_enhance = null):
	name = p_name
	strength = p_strength
	card = p_card
	enhance = p_enhance
	
func copy():
	var n_card = card.copy() if card != null else null
	var n_enhance = enhance.copy() if enhance != null else null
	return Upgrade.new(name, strength, n_card, n_enhance)
