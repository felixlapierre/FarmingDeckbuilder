extends Fortune
class_name BlueTrinket

var icon = preload("res://assets/fortune/CounterFortune.png")
var callback
var event_type = EventManager.EventType.AfterTurnStart

func _init() -> void:
	super("Sapphire Amulet", Fortune.FortuneType.GoodFortune, "Water 2 random unwatered tiles at the start of each turn", 0, icon, 2.0)

func register_fortune(event_manager: EventManager):
	callback = func(args: EventArgs):
		var options: Array[Tile] = []
		for tile: Tile in args.farm.get_all_tiles():
			if !tile.irrigated and tile.active_and_not_destroyed():
				options.append(tile)
		for i in range(2):
			var tile = options[randi_range(0, options.size() - 1)]
			tile.irrigate()
	event_manager.register_listener(event_type, callback)

func unregister_fortune(event_manager: EventManager):
	event_manager.unregister_listener(event_type, callback)
