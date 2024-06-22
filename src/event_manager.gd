extends Node
class_name EventManager

var farm: Farm
var turn_manager: TurnManager
var cards: Cards

var on_year_start_listeners: Array[Callable] = []
var on_turn_end_listeners: Array[Callable] = []

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

func setup(p_farm: Farm, p_turn_manager: TurnManager, p_cards: Cards):
	farm = p_farm
	turn_manager = p_turn_manager
	cards = p_cards

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func register_on_year_start(callback: Callable):
	on_year_start_listeners.append(callback)

func unregister_on_year_start(callback: Callable):
	on_year_start_listeners.erase(callback)
	
func notify_year_start():
	for listener in on_year_start_listeners:
		listener.call(farm, turn_manager, cards)

func register_on_turn_end(callback: Callable):
	on_turn_end_listeners.append(callback)

func unregister_on_turn_end(callback: Callable):
	on_turn_end_listeners.erase(callback)
	
func notify_turn_end():
	for listener in on_turn_end_listeners:
		listener.call(farm, turn_manager, cards)
