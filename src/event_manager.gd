extends Node
class_name EventManager

var farm: Farm
var turn_manager: TurnManager

var on_year_start_listeners: Array[Callable] = []

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

func setup(p_farm: Farm, p_turn_manager: TurnManager):
	farm = p_farm
	turn_manager = p_turn_manager

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func register_on_year_start(callback: Callable):
	on_year_start_listeners.append(callback)

func unregister_on_year_start(callback: Callable):
	on_year_start_listeners.erase(callback)
	
func notify_year_start():
	for listener in on_year_start_listeners:
		listener.call(farm, turn_manager)
