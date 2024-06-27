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
	func _init(p_tile: Tile):
		tile = p_tile
