extends Structure
class_name Toolshed

var callback: Callable

var event_type = EventManager.EventType.BeforeTurnStart
var rusty_hoe = preload("res://src/structure/unique/rusty_hoe.tres")

func _init():
	super()

func copy():
	var copy = Toolshed.new()
	copy.assign(self)
	return copy

func register_events(event_manager: EventManager, tile: Tile):
	callback = func(args: EventArgs):
		args.cards.draw_specific_card_from(rusty_hoe.copy(), tile.position + Constants.TILE_SIZE / 2)
		args.cards.reorganize_hand()
	event_manager.register_listener(event_type, callback)

func unregister_events(event_manager: EventManager):
	event_manager.unregister_listener(event_type, callback)
