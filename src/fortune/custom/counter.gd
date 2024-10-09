extends Fortune

var callback_card_played: Callable
var event_type_card_played = EventManager.EventType.AfterCardPlayed
var texture_display = load("res://assets/fortune/CounterFortune.png")

func _init() -> void:
	super("Counter", FortuneType.BadFortune, "Increase [img]res://assets/custom/BlightAttack.png[/img] by 5 whenever you play a card", -1, texture_display)

func register_fortune(event_manager: EventManager):
	callback_card_played = func(args: EventArgs):
		args.turn_manager.target_blight += 3
	
	event_manager.register_listener(event_type_card_played, callback_card_played)

func unregister_fortune(event_manager: EventManager):
	event_manager.unregister_listener(event_type_card_played, callback_card_played)
