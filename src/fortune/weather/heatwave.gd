extends Fortune
class_name HeatwaveWeather

var callback: Callable
var event_type = EventManager.EventType.BeforeGrow

var display_texture = preload("res://assets/mage/fire_mage.png")

func _init() -> void:
	super("Heat Wave", Fortune.FortuneType.GoodFortune, "Turn end: Burn all cards in hand. For each card Burned, add 1 [img]res://assets/custom/YellowMana.png[/img] to all plants.", 0, display_texture, 1.0)

func register_fortune(event_manager: EventManager):
	callback = func(args: EventArgs):
		var hand = args.cards.get_hand_info()
		args.cards.burn_hand()
		
		for i in range(hand.size()):
			for tile in args.farm.get_all_tiles():
				if tile.state == Enums.TileState.Growing or tile.state == Enums.TileState.Mature:
					tile.add_yield(strength)
		args.farm.do_animation(load("res://src/animation/frames/flamerite_sf.tres"), null)
	event_manager.register_listener(event_type, callback)

func unregister_fortune(event_manager: EventManager):
	event_manager.unregister_listener(event_type, callback)
