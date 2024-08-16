extends Fortune

var callable
var farm_ref: Farm

var rotation: int = 3
var kaleidoscope_texture = preload("res://assets/fortune/kaleidoscope2.png")
func _init() -> void:
	super("Kaleidoscope 2", FortuneType.BadFortune, "Purple and yellow zones rotate at end of turn", 2, kaleidoscope_texture)

func register_fortune(event_manager: EventManager):
	callable = func(args):
		farm_ref = args.farm
		for tile: Tile in farm_ref.get_node("Tiles").get_children():
			var quadrant = 4
			if tile.grid_location.x > 3:
				quadrant -= 1
			if tile.grid_location.y > 3:
				quadrant -= 1
			if tile.grid_location.y > 3 and tile.grid_location.x <= 3:
				quadrant -= 2
			var remainder = (quadrant + rotation)
			if remainder % 4 == 0 or remainder % 4 == 1:
				tile.purple = true
			else:
				tile.purple = false
			tile.update_purple_overlay()
		rotation = (rotation + 1) % 4
	event_manager.register_listener(EventManager.EventType.OnTurnEnd, callable)

func unregister_fortune(event_manager: EventManager):
	event_manager.unregister_listener(EventManager.EventType.OnTurnEnd, callable)
	if farm_ref != null:
		for tile: Tile in farm_ref.get_node("Tiles").get_children():
			tile.purple = tile.grid_location.x >= Constants.PURPLE_GTE_INDEX
			tile.update_purple_overlay()
