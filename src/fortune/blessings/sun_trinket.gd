extends Fortune
class_name SunflowerTrinket

var icon = preload("res://assets/custom/YellowMana16.png")
var callback
var event_type = EventManager.EventType.BeforeTurnStart

func _init() -> void:
	super("Sunflower Trinket", Fortune.FortuneType.GoodFortune, "Protect the center 4 tiles of the farm from the Blight's attacks", 0, icon, 1.0)

func register_fortune(event_manager: EventManager):
	callback = func(args: EventArgs):
		var tiles = [args.farm.tiles[3][3], args.farm.tiles[3][4], args.farm.tiles[4][3], args.farm.tiles[4][4]]
		for tile: Tile in tiles:
			tile.protected = true
	event_manager.register_listener(event_type, callback)

func unregister_fortune(event_manager: EventManager):
	event_manager.unregister_listener(event_type, callback)
