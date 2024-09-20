extends Structure
class_name Dreamcatcher

var callback: Callable

var event_type = EventManager.EventType.AfterCardPlayed

func _init():
	super()

func copy():
	var copy = Dreamcatcher.new()
	copy.assign(self)
	return copy

func register_events(event_manager: EventManager, tile: Tile):
	callback = func(args: EventArgs):
		var card = args.specific.play_args.card
		if card.get_effect("burn") != null or card.get_effect("fleeting") != null:
			args.cards.drawcard()
	event_manager.register_listener(event_type, callback)

func unregister_events(event_manager: EventManager):
	event_manager.unregister_listener(event_type, callback)
