extends Fortune
class_name WeedsStartDeck

var callback: Callable
var event_type = EventManager.EventType.BeforeTurnStart
var weeds = preload("res://src/fortune/unique/weed.tres")
var weeds_texture = preload("res://assets/fortune/weed_card_fortune.png")

var strength = 2

func _init() -> void:
	super("Cursed Scrolls", FortuneType.BadFortune, "Add Weeds to your deck for this year", 0, weeds_texture)

func register_fortune(event_manager: EventManager):
	callback = add_daylily
	event_manager.register_listener(event_type, callback)

func unregister_fortune(event_manager: EventManager):
	event_manager.unregister_listener(event_type, callback)

func add_daylily(args: EventArgs):
	for i in range(strength):
		args.cards.deck_cards.append(weeds.copy())
