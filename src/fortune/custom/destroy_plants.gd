extends Fortune
class_name DestroyPlants

@export var count: int

var callback_turn_start: Callable
var callback_after_grow: Callable
var type_after_grow = EventManager.EventType.AfterGrow
var type_turn_start = EventManager.EventType.BeforeTurnStart

func _init() -> void:
	super()

func register_fortune(event_manager: EventManager):
	callback_turn_start = func(args: EventArgs):
		var targeted_tiles = []
		for tile in args.farm.get_all_tiles():
			if !tile.blight_targeted and [Enums.TileState.Growing, Enums.TileState.Mature].has(tile.state)\
				and tile.seed_base_yield != 0.0:
				targeted_tiles.append(tile)
		targeted_tiles.shuffle()
		for i in range(min(count, targeted_tiles.size())):
			targeted_tiles[i].set_destroy_targeted(true)
	event_manager.register_listener(type_turn_start, callback_turn_start)
	
	callback_after_grow = func(args: EventArgs):
		for tile in args.farm.get_all_tiles():
			if tile.destroy_targeted:
				tile.destroy_plant()
				tile.set_destroy_targeted(false)
	event_manager.register_listener(type_after_grow, callback_after_grow)

func unregister_fortune(event_manager: EventManager):
	event_manager.unregister_listener(type_turn_start, callback_turn_start)
	event_manager.unregister_listener(type_after_grow, callback_after_grow)

func save_data() -> Dictionary:
	var data = super.save_data()
	data.count = count
	return data

func load_data(data):
	super.load_data(data)
	count = data.count
