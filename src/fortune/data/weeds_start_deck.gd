extends Fortune
class_name WeedsStartDeck

var callback: Callable
var event_type = EventManager.EventType.AfterYearStart
var weeds = preload("res://src/fortune/unique/weed.tres")

func _init() -> void:
	super("Cursed Scrolls", FortuneType.MinorBadFortune, "Add 2 Weeds to your deck for this year")

func register_fortune(event_manager: EventManager):
	callback = add_daylily
	event_manager.register_listener(event_type, callback)

func unregister_fortune(event_manager: EventManager):
	event_manager.unregister_listener(event_type, callback)

func add_daylily(args: EventArgs):
	args.cards.deck_cards.append(weeds.copy())
	args.cards.deck_cards.append(weeds.copy())
