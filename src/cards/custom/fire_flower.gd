extends CardData
class_name FireFlower

var PickOption = preload("res://src/ui/pick_option.tscn")

var callback: Callable
var event_type = EventManager.EventType.AfterCardPlayed

func register_events(event_manager: EventManager, p_tile: Tile):
	callback = func(args: EventArgs):
		var pick_option_ui = PickOption.instantiate()
		args.user_interface.add_child(pick_option_ui)
		var prompt = "Pick a card to Burn"

		pick_option_ui.setup(prompt, args.cards.get_hand_info(), func(selected):
			args.cards.remove_card_with_info(selected.card_info)
			args.cards.notify_card_burned(selected)
			args.user_interface.remove_child(pick_option_ui), null)
	event_manager.register_listener(event_type, callback)

func unregister_events(event_manager: EventManager):
	event_manager.unregister_listener(event_type, callback)

func copy():
	var new = FireFlower.new();
	new.assign(self)
	return new
