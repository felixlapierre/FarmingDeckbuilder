extends CardData
class_name ControlWeather

var callback_after_play: Callable
var event_type_after_play = EventManager.EventType.AfterCardPlayed

var PickOption = preload("res://src/ui/pick_option.tscn")

func copy():
	var new = ControlWeather.new()
	new.assign(self)
	return new

# To be overridden by specific code seeds
func register_events(event_manager: EventManager, p_tile: Tile):

	callback_after_play = func(args: EventArgs):
		var options = []
		options.assign(WeatherDisplay.options)
		options.erase(WeatherDisplay.in_one_week if WeatherDisplay.in_one_week != WeatherDisplay.clear else WeatherDisplay.in_two_weeks)
		options.shuffle()
		
		var pick_option_ui = PickOption.instantiate()
		args.user_interface.add_child(pick_option_ui)
		
		var on_pick = func(selected):
			args.user_interface.remove_child(pick_option_ui)
			if WeatherDisplay.in_one_week != WeatherDisplay.clear:
				WeatherDisplay.in_one_week = selected
			else:
				WeatherDisplay.in_two_weeks = selected
			args.user_interface.update()

		pick_option_ui.setup("Choose a weather effect", options.slice(0, 3), on_pick, null)

	event_manager.register_listener(event_type_after_play, callback_after_play)

func unregister_events(event_manager: EventManager):
	event_manager.unregister_listener(event_type_after_play, callback_after_play)
