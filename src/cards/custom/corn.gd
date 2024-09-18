extends CardData
class_name Corn

var tile: Tile
var callback: Callable
var callback_harvest: Callable

# To be overridden by specific code seeds
func register_seed_events(event_manager: EventManager, p_tile: Tile):
	tile = p_tile
	var cards_burned_count = 0
	# On card played
	callback = func(args: EventArgs):
		var card = args.specific.play_args.card
		if card.get_effect("burn") != null or card.get_effect("fleeting") != null:
			cards_burned_count += 1
	callback_harvest = func(args: EventArgs):
		if tile == args.specific.tile:
			for i in range(cards_burned_count):
				args.cards.drawcard()
			
	# On harvest
	event_manager.register_listener(EventManager.EventType.BeforeCardPlayed, callback)
	event_manager.register_listener(EventManager.EventType.OnPlantHarvest, callback_harvest)

func unregister_seed_events(event_manager: EventManager):
	event_manager.unregister_listener(EventManager.EventType.BeforeCardPlayed, callback)
	event_manager.unregister_listener(EventManager.EventType.OnPlantHarvest, callback_harvest)

func copy():
	var new = Corn.new();
	new.assign(self)
	return new

func can_strengthen_custom_effect():
	return false
