extends Fortune
class_name WeedsDeckTurnStart

var callback: Callable
var event_type = EventManager.EventType.BeforeTurnStart
var weeds = preload("res://src/fortune/unique/weed.tres")

func _init() -> void:
	super("Cursed Grimoire", FortuneType.BadFortune, "Add a Weeds card to your deck at the start of each turn", 1)

func register_fortune(event_manager: EventManager):
	callback = add_weed_to_deck
	event_manager.register_listener(event_type, callback)

func unregister_fortune(event_manager: EventManager):
	event_manager.unregister_listener(event_type, callback)

func add_weed_to_deck(args: EventArgs):
	args.cards.deck_cards.append(weeds.copy())
