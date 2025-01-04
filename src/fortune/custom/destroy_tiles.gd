extends Fortune
class_name DestroyTiles

var callback_turn_start: Callable
var callback_after_grow: Callable
var type_turn_start = EventManager.EventType.BeforeTurnStart

var fortune_texture = preload("res://assets/fortune/destroy-tiles.png")

func _init(strength: float = 1.0) -> void:
	super("Decay", Fortune.FortuneType.BadFortune, "Turn start: Destroy {STRENGTH} tiles on your farm", 0, fortune_texture, strength)

func register_fortune(event_manager: EventManager):
	callback_turn_start = func(args: EventArgs):
		var targeted_tiles = []
		for tile in args.farm.get_all_tiles():
			if !tile.blight_targeted and [Enums.TileState.Growing, Enums.TileState.Mature, Enums.TileState.Empty].has(tile.state)\
				and !tile.is_protected():
				targeted_tiles.append(tile)
		targeted_tiles.shuffle()
		for i in range(min(strength, targeted_tiles.size())):
			targeted_tiles[i].destroy()
	event_manager.register_listener(type_turn_start, callback_turn_start)
	

func unregister_fortune(event_manager: EventManager):
	event_manager.unregister_listener(type_turn_start, callback_turn_start)
