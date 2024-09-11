extends CardData
class_name DrawBlight

@export var strength = 0

var callback: Callable
var event_type = EventManager.EventType.BeforeCardPlayed

# To be overridden by specific code seeds
func register_events(event_manager: EventManager, p_tile: Tile):
	callback = func(args: EventArgs):
		for i in range(args.turn_manager.blight_damage + strength):
			args.cards.drawcard()
	event_manager.register_listener(event_type, callback)

func unregister_events(event_manager: EventManager):
	event_manager.unregister_listener(event_type, callback)

func get_description() -> String:
	var descr = super.get_description()
	return descr.replace("{STRENGTH}", str(strength) + ", plus " if strength > 0 else "")

func copy():
	var new = DrawBlight.new()
	new.assign(self)
	return new
