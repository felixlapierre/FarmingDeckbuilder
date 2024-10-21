extends Resource

class_name EventArgs

var farm: Farm
var turn_manager: TurnManager
var cards: Cards
var specific: SpecificArgs

func _init(p_farm: Farm = null, p_turn_manager: TurnManager = null, p_cards: Cards = null, p_specific_args: SpecificArgs = null):
	farm = p_farm
	turn_manager = p_turn_manager
	cards = p_cards
	specific = p_specific_args

class SpecificArgs:
	var tile: Tile
	var harvest_args: HarvestArgs
	var destroy_args: DestroyArgs
	var play_args: PlayArgs
	var pick_args: PickArgs
	func _init(p_tile: Tile):
		tile = p_tile

class HarvestArgs:
	var yld: float
	var purple: bool
	var delay: bool
	var green: float
	func _init(p_yld: float = 0.0, p_purple: bool = false, p_delay: bool = false):
		yld = p_yld
		purple = p_purple
		delay = p_delay
		green = 0.0

class DestroyArgs:
	var protect: bool
	func _init(p_protect: bool = false):
		protect = p_protect

class PlayArgs:
	var card: CardData
	func _init(p_card: CardData = null):
		card = p_card

class PickArgs:
	var options: Array[CardData]
	func _init(p_options = []):
		options = []
		options.assign(p_options)
