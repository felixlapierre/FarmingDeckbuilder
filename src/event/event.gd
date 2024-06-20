extends Resource
class_name GameEvent

@export var name: String
@export_multiline var text: String
@export var flavor_text_1: String
@export var flavor_text_2: String
@export var flavor_text_3: String
@export var option1: Array[Upgrade]
@export var option2: Array[Upgrade]
@export var option3: Array[Upgrade]
@export var prerequisite: GameEvent

func _init(p_name = "name", p_text = "text", p_flavor_1 = "", p_flavor_2 = "", p_flavor_3 = "", \
	p_option1 = [], p_option2 = [], p_option3 = [], p_prerequisite = null) -> void:
	name = p_name
	text = p_text
	flavor_text_1 = p_flavor_1
	flavor_text_2 = p_flavor_2
	flavor_text_3 = p_flavor_3
	option1.append_array(p_option1)
	option2.append_array(p_option2)
	option3.append_array(p_option3)
	prerequisite = p_prerequisite

func maybe_setup_random_card(card_database: DataFetcher):
	_setup_option(option1, card_database)
	_setup_option(option2, card_database)
	_setup_option(option3, card_database)

func _setup_option(option: Array[Upgrade], card_database: DataFetcher):
	for upgrade in option:
		upgrade.setup_random_values(card_database)

func check_upgrade_prerequisite(deck: Array[CardData], turn_manager: TurnManager):
	return check_option_prerequisite(option1, deck, turn_manager)\
		and check_option_prerequisite(option2, deck, turn_manager)\
		and check_option_prerequisite(option3, deck, turn_manager)

func check_option_prerequisite(option: Array[Upgrade], deck: Array[CardData], turn_manager: TurnManager):
	for upgrade in option:
		if upgrade.check_prerequisite(deck, turn_manager) == false:
			return false
	return true
	
