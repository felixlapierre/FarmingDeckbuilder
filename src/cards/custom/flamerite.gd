extends CardData

class_name Flamerite

var callback: Callable
var event_type = EventManager.EventType.AfterCardPlayed

# To be overridden by specific code seeds
func register_events(event_manager: EventManager, p_tile: Tile):
	callback = func(args: EventArgs):
		var hand = args.cards.get_hand_info()
		args.cards.burn_hand()
		
		for i in range(hand.size()):
			for tile in args.farm.get_all_tiles():
				if tile.state == Enums.TileState.Growing or tile.state == Enums.TileState.Mature:
					tile.add_yield(strength)
			args.farm.do_animation(load("res://src/animation/frames/flamerite_sf.tres"), null)
			await args.farm.get_tree().create_timer(0.25).timeout
	event_manager.register_listener(event_type, callback)

func unregister_events(event_manager: EventManager):
	event_manager.unregister_listener(event_type, callback)

func copy():
	var new = Flamerite.new()
	new.assign(self)
	return new

func can_strengthen_custom_effect():
	return true
