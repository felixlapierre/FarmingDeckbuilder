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
	RemoveAnyCard,
	RemoveSpecificCard,
	CopyAnyCard,
	GainMoney,
	LoseMoney,
	AddCommonCard,
	AddRareCard,
	GainBlight,
	RemoveBlight,
	AddEnhance,
	AddEnhanceToRandom,
	AddEnhanceToAll,
	AddStructure,
	AddUncommonCard
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

func get_text() -> String:
	var result: String = text
	if card != null:
		result = result.replace("${CARDNAME}", card.name)
	if enhance != null:
		result = result.replace("${ENHANCE}", enhance.name)
	return result

func check_prerequisite(deck: Array[CardData], turn_manager: TurnManager):
	match type:
		UpgradeType.RemoveBlight:
			return turn_manager.blight_damage >= strength
		UpgradeType.RemoveSpecificCard:
			return deck.has(card)
		_:
			return true

func get_tooltip():
	match type:
		Upgrade.UpgradeType.EnergyFragment:
			return "Energy Fragment: Gain an extra energy every 3 turns"
		_:
			return ""
