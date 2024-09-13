extends CardData
class_name RandomBlightCard

var callback: Callable
var event_type = EventManager.EventType.BeforeCardPlayed

# To be overridden by specific code seeds
func register_events(event_manager: EventManager, p_tile: Tile):
	callback = func(args: EventArgs):
		var cards = DataFetcher.get_all_cards()
		var candidates = []
		candidates.append(load("res://src/cards/data/unique/dark_visions.tres"))
		candidates.append(load("res://src/event/unique/blight_rose.tres"))
		candidates.append(load("res://src/cards/data/unique/bloodrite.tres"))
		for i in range(self.strength):
			var selected = randi_range(0, candidates.size() - 1)
			args.cards.draw_specific_card_from(candidates[selected], args.cards.get_global_mouse_position())
	event_manager.register_listener(event_type, callback)

func unregister_events(event_manager: EventManager):
	event_manager.unregister_listener(event_type, callback)


func copy():
	var new = RandomBlightCard.new()
	new.assign(self)
	return new

func can_strengthen_custom_effect():
	return true
