extends Fortune
class_name DestroyRow

var callback_turn_start: Callable
var callback_after_grow: Callable
var type_after_grow = EventManager.EventType.AfterGrow
var type_turn_start = EventManager.EventType.BeforeTurnStart
var fortune_texture = load("res://assets/custom/Temp.png")

func _init() -> void:
	super("Blast Row", FortuneType.BadFortune, "Destroy one row of plants", 3, fortune_texture)

func register_fortune(event_manager: EventManager):
	callback_turn_start = func(args: EventArgs):
		# Pick Row
		var min = Global.FARM_TOPLEFT.x
		var max = Global.FARM_BOTRIGHT.x
		var index = randi_range(min, max)
		
		var targeted_tiles = []
		for tile in args.farm.get_all_tiles():
			if tile.state != Enums.TileState.Inactive and tile.state != Enums.TileState.Structure and !tile.is_protected()\
				and (tile.seed == null or tile.seed.get_effect("corrupted") == null)\
				and tile.grid_location.x == index:
				targeted_tiles.append(tile)
		for i in range(targeted_tiles.size()):
			targeted_tiles[i].set_destroy_targeted(true)
	event_manager.register_listener(type_turn_start, callback_turn_start)
	
	callback_after_grow = func(args: EventArgs):
		for tile in args.farm.get_all_tiles():
			if tile.destroy_targeted and !tile.is_protected():
				tile.destroy_plant()
				tile.set_destroy_targeted(false)
	event_manager.register_listener(type_after_grow, callback_after_grow)

func unregister_fortune(event_manager: EventManager):
	event_manager.unregister_listener(type_turn_start, callback_turn_start)
	event_manager.unregister_listener(type_after_grow, callback_after_grow)
