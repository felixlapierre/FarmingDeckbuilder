extends Structure
class_name Toolshed

var callback: Callable

var event_type = EventManager.EventType.BeforeTurnStart
var rusty_hoe = preload("res://src/structure/unique/rusty_hoe.tres")

func _init():
	super()

func copy():
	return Toolshed.new()

func register_events(event_manager: EventManager, tile: Tile):
	callback = func(args: EventArgs):
		args.cards.draw_specific_card(rusty_hoe.copy())
		args.cards.reorganize_hand()
	event_manager.register_listener(event_type, callback)

func unregister_events(event_manager: EventManager):
	event_manager.unregister_listener(event_type, callback)
