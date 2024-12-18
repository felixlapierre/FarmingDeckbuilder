extends Structure
class_name PurpleTotem

var purple_mana = 0

var callback: Callable
var callback2: Callable
var callback3: Callable

var event_type = EventManager.EventType.OnTurnEnd
var event2 = EventManager.EventType.BeforeTurnStart
var event3 = EventManager.EventType.BeforeYearStart

func _init():
	super()

func copy():
	var copy = PurpleTotem.new()
	copy.assign(self)
	return copy

func register_events(event_manager: EventManager, tile: Tile):
	callback = func(args: EventArgs):
		if args.turn_manager.flag_defer_excess:
			purple_mana = 0
		else:
			purple_mana = args.turn_manager.purple_mana - args.turn_manager.target_blight
			purple_mana = 0 if purple_mana < 0 else purple_mana
	callback2 = func(args: EventArgs):
		args.turn_manager.purple_mana += purple_mana * 0.80
		if purple_mana > 0:
			tile.play_effect_particles()
	callback3 = func(args: EventArgs):
		purple_mana = 0
	event_manager.register_listener(event_type, callback)
	event_manager.register_listener(event2, callback2)
	event_manager.register_listener(event3, callback3)

func unregister_events(event_manager: EventManager):
	event_manager.unregister_listener(event_type, callback)
	event_manager.unregister_listener(event2, callback2)
	event_manager.unregister_listener(event3, callback3)
