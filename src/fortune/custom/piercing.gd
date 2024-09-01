extends Fortune
class_name Piercing

@export var count: int = 0
@export var also_destroy_tile: bool = false

var callback: Callable
var event_type = EventManager.EventType.AfterGrow

func _init() -> void:
	super()

func register_fortune(event_manager: EventManager):
	callback = func(args: EventArgs):
		var targeted_tiles = []
		for tile in args.farm.get_all_tiles():
			if tile.blight_targeted:
				targeted_tiles.append(tile)
		targeted_tiles.shuffle()
		for i in range(min(count, targeted_tiles.size())):
			var tile: Tile = targeted_tiles[i]
			if also_destroy_tile:
				tile.destroy()
			else:
				tile.destroy_plant()
	event_manager.register_listener(event_type, callback)

func unregister_fortune(event_manager: EventManager):
	event_manager.unregister_listener(event_type, callback)

func save_data() -> Dictionary:
	var dict = super.save_data()
	dict.count = count
	dict.also_destroy_tile = also_destroy_tile
	return dict

func load_data(data) -> Fortune:
	super.load_data(data)
	count = data.count
	also_destroy_tile = data.also_destroy_tile
	return self
