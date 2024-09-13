extends CardData
class_name RandomSeed

var callback: Callable
var event_type = EventManager.EventType.BeforeCardPlayed

# To be overridden by specific code seeds
func register_events(event_manager: EventManager, p_tile: Tile):
	callback = func(args: EventArgs):
		var cards = DataFetcher.get_all_cards()
		var candidates = []
		for card in cards:
			if card.type == "SEED" and card.rarity != "basic":
				candidates.append(card)
		candidates.shuffle()
		for i in range(self.strength):
			args.cards.draw_specific_card_from(candidates[i], args.cards.get_global_mouse_position())
	event_manager.register_listener(event_type, callback)

func unregister_events(event_manager: EventManager):
	event_manager.unregister_listener(event_type, callback)

func copy():
	var new = RandomSeed.new()
	new.assign(self)
	return new

func can_strengthen_custom_effect():
	return true
