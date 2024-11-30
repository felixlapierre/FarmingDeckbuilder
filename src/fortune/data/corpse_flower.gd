extends Fortune

var callback_start: Callable
var callback_end: Callable
var event_start = EventManager.EventType.BeforeTurnStart
var event_end = EventManager.EventType.OnTurnEnd
var corpse_flower = load("res://src/fortune/unique/corpse_flower.tres")
var flower_texture = preload("res://assets/fortune/CorpseFlowerFortune.png")

var targeted_tiles = []

func _init() -> void:
	super("Gluttony", FortuneType.BadFortune, "Plant a Corpse Flower on your farm", 3, flower_texture, 1.0)
	if Mastery.Misfortune > 0:
		strength += Mastery.Misfortune

func register_fortune(event_manager: EventManager):
	callback_start = func(args: EventArgs):
		var options = []
		targeted_tiles = []
		for tile in args.farm.get_all_tiles():
			if !tile.blight_targeted and [Enums.TileState.Growing, Enums.TileState.Mature, Enums.TileState.Empty].has(tile.state)\
				and !tile.is_protected() and (tile.seed == null or tile.seed.get_effect("corrupted") != null or tile.seed_base_yield != 0.0):
				options.append(tile)
		options.shuffle()
		for i in range(min(strength, options.size())):
			options[i].set_destroy_targeted(true)
			targeted_tiles.append(options[i])
	callback_end = func(args: EventArgs):
		for tile: Tile in targeted_tiles:
			if tile.destroy_targeted and !tile.is_protected():
				if tile.seed != null:
					tile.destroy_plant()
				tile.set_destroy_targeted(false)
				tile.plant_seed_animate(corpse_flower.copy())
	event_manager.register_listener(event_start, callback_start)
	event_manager.register_listener(event_end, callback_end)

func unregister_fortune(event_manager: EventManager):
	event_manager.unregister_listener(event_start, callback_start)
	event_manager.unregister_listener(event_end, callback_end)
