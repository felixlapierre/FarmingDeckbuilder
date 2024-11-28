extends Resource
class_name CustomEvent

var name: String
var text: String

var turn_manager: TurnManager
var user_interface: UserInterface
var cards_database: DataFetcher

class Option:
	var name: String
	var hover: Node
	var on_select: Callable
	func _init(p_name: String, p_hover: Node, p_select: Callable):
		name = p_name
		hover = p_hover
		on_select = p_select

func _init(p_name: String, p_description: String):
	name = p_name
	text = p_description

func setup(p_turn_manager: TurnManager, p_user_interface, p_card_database: DataFetcher):
	turn_manager = p_turn_manager
	user_interface = p_user_interface
	cards_database = p_card_database

func get_options():
	# An option should have
	# The text to display (string)
	# What should I display on hover (unsure? callback?)
	# What should I do when the option is selected (callback.)
	pass

func check_prerequisites():
	# Completed event
	# Blight damage at certain level
	# Based on year
	# Based on card in deck?
	pass
