extends Fortune
class_name DestroyTiles

var callback_turn_start: Callable
var callback_after_grow: Callable
var type_after_grow = EventManager.EventType.AfterGrow
var type_turn_start = EventManager.EventType.BeforeTurnStart

var fortune_texture = preload("res://assets/custom/Temp.png")

func _init(strength: float = 1.0) -> void:
	super("Decay", Fortune.FortuneType.BadFortune, "Turn end: Destroy {STRENGTH} tiles on your farm", 0, fortune_texture, strength)

func register_fortune(event_manager: EventManager):
	callback_turn_start = func(args: EventArgs):
		var targeted_tiles = []
		for tile in args.farm.get_all_tiles():
			if !tile.blight_targeted and [Enums.TileState.Growing, Enums.TileState.Mature, Enums.TileState.Empty].has(tile.state)\
				and !tile.is_protected():
				targeted_tiles.append(tile)
		targeted_tiles.shuffle()
		for i in range(min(strength, targeted_tiles.size())):
			targeted_tiles[i].set_destroy_targeted(true)
	event_manager.register_listener(type_turn_start, callback_turn_start)
	
	callback_after_grow = func(args: EventArgs):
		for tile in args.farm.get_all_tiles():
			if tile.destroy_targeted:
				if !tile.is_protected():
					tile.destroy()
				tile.set_destroy_targeted(false)
	event_manager.register_listener(type_after_grow, callback_after_grow)

func unregister_fortune(event_manager: EventManager):
	event_manager.unregister_listener(type_turn_start, callback_turn_start)
	event_manager.unregister_listener(type_after_grow, callback_after_grow)
