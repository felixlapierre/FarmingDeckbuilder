extends Fortune
class_name NatureBounty

var icon = preload("res://assets/custom/YellowMana.png")
var callback
var event_type = EventManager.EventType.OnPlantPlanted

func _init() -> void:
	super("Nature's Bounty", Fortune.FortuneType.GoodFortune, "When a seed is planted, add +1 mana to it", 0, icon, 1.0)

func register_fortune(event_manager: EventManager):
	callback = func(args: EventArgs):
		args.specific.tile.add_yield(1)
	event_manager.register_listener(event_type, callback)

func unregister_fortune(event_manager: EventManager):
	event_manager.unregister_listener(event_type, callback)
