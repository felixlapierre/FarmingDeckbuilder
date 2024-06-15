extends Resource
class_name Upgrade

@export var type: UpgradeType
@export var text: String
@export var strength: float
@export var card: CardData
@export var enhance: Enhance

enum UpgradeType {
	Nothing,
	ExpandFarm,
	EnergyFragment,
	CardFragment,
	GainReroll,
	AddSpecificCard,
	RemoveAnyCard
}

func _init(p_type = UpgradeType.Nothing, p_text = "text", p_strength = 1.0, p_card = null, p_enhance = null):
	type = p_type
	text = p_text
	strength = p_strength
	card = p_card
	enhance = p_enhance

func copy():
	var n_card = card.copy() if card != null else null
	var n_enhance = enhance.copy() if enhance != null else null
	return Upgrade.new(type, text, strength, n_card, n_enhance)
