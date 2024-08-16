extends Fortune

var callable
var farm_ref: Farm

var kaleidoscope_texture = preload("res://assets/fortune/kaleidoscope1.png")
func _init() -> void:
	super("Kaleidoscope", FortuneType.BadFortune, "Swap purple and yellow zones at end of turn", 1, kaleidoscope_texture)

func register_fortune(event_manager: EventManager):
	callable = func(args):
		farm_ref = args.farm
		for tile: Tile in farm_ref.get_node("Tiles").get_children():
			tile.purple = !tile.purple
			tile.update_purple_overlay()
	event_manager.register_listener(EventManager.EventType.OnTurnEnd, callable)

func unregister_fortune(event_manager: EventManager):
	event_manager.unregister_listener(EventManager.EventType.OnTurnEnd, callable)
	if farm_ref != null:
		for tile: Tile in farm_ref.get_node("Tiles").get_children():
			tile.purple = tile.grid_location.x >= Constants.PURPLE_GTE_INDEX
			tile.update_purple_overlay()
