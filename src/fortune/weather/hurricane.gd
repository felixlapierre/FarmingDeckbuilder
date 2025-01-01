extends Fortune
class_name HurricaneWeather

var callback: Callable
var event_type = EventManager.EventType.BeforeTurnStart

var display_texture = preload("res://assets/card/slash.png")

func _init() -> void:
	super("Hurricane", Fortune.FortuneType.GoodFortune, "Turn start: Harvest all plants on your farm", 0, display_texture, strength)

func register_fortune(event_manager: EventManager):
	callback = func(args: EventArgs):
		for tile in args.farm.get_all_tiles():
			if tile.state == Enums.TileState.Mature:
				args.farm.effect_queue.append_array(tile.harvest(false))
		args.farm.process_effect_queue()
	event_manager.register_listener(event_type, callback)

func unregister_fortune(event_manager: EventManager):
	event_manager.unregister_listener(event_type, callback)
