extends Node
class_name Blessings

var blessings: Array[Fortune]
var curses: Array[Fortune] 

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	blessings = []
	curses = []

func register_listeners(event_manager: EventManager):
	for blessing in blessings:
		blessing.register_fortune(event_manager)
	for curse in curses:
		curse.register_fortune(event_manager)

func unregister_listeners(event_manager: EventManager):
	for blessing in blessings:
		blessing.unregister_fortune(event_manager)
	for curse in curses:
		curse.unregister_fortune(event_manager)

func get_blessings() -> Array[Fortune]: 
	return blessings

func get_curses() -> Array[Fortune]:
	return curses

func save_data() -> Dictionary:
	return {
		"blessings": blessings.map(func(blessing: Fortune):
			return blessing.save_data()),
		"curses": curses.map(func(curse: Fortune):
			return curse.save_data())
	}

func load_data(data: Dictionary):
	blessings.assign(data.blessings.map(func(blessing_data):
			return load(blessing_data.path).new().load_data(blessing_data)))
	curses.assign(data.curses.map(func(curse_data):
			return load(curse_data.path).new().load_data(curse_data)))

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
