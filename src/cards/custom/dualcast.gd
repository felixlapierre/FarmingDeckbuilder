extends CardData
class_name Dualcast

var tile: Tile
var callback: Callable
var callback_harvest: Callable

var card = null

# To be overridden by specific code seeds
func register_seed_events(event_manager: EventManager, p_tile: Tile):
	tile = p_tile

	# On card played
	callback = func(args: EventArgs):
		if card == null:
			card = args.specific.play_args.card

	callback_harvest = func(args: EventArgs):
		if tile == args.specific.tile and card != null:
			for i in range(strength):
				args.cards.draw_specific_card_from(card, tile.position)

	event_manager.register_listener(EventManager.EventType.BeforeCardPlayed, callback)
	event_manager.register_listener(EventManager.EventType.OnPlantHarvest, callback_harvest)

func unregister_seed_events(event_manager: EventManager):
	event_manager.unregister_listener(EventManager.EventType.BeforeCardPlayed, callback)
	event_manager.unregister_listener(EventManager.EventType.OnPlantHarvest, callback_harvest)

func copy():
	var new = Dualcast.new();
	new.assign(self)
	return new

func can_strengthen_custom_effect():
	return true
