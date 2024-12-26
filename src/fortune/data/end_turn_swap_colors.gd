extends Fortune

var callable
var farm_ref: Farm

var kaleidoscope_texture = preload("res://assets/fortune/kaleidoscope1.png")
func _init() -> void:
	super("Kaleidoscope 1", FortuneType.BadFortune, "Swap color of tiles at end of turn", 1, kaleidoscope_texture)

func register_fortune(event_manager: EventManager):
	callable = func(args):
		if Global.FARM_TYPE == "LUNARTEMPLE":
			return
		farm_ref = args.farm
		for tile: Tile in farm_ref.get_node("Tiles").get_children():
			tile.purple = !tile.purple
			tile.update_purple_overlay()
	event_manager.register_listener(EventManager.EventType.OnTurnEnd, callable)

func unregister_fortune(event_manager: EventManager):
	event_manager.unregister_listener(EventManager.EventType.OnTurnEnd, callable)
