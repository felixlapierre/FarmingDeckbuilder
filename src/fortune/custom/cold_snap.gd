extends Fortune
class_name ColdSnap

var callback: Callable

var texture_display = load("res://assets/custom/Temp.png")

func _init() -> void:
	super("Cold Snap", FortuneType.BadFortune, "Plants do not grow at the end of this turn.", -1, texture_display)

func register_fortune(event_manager: EventManager):
	Global.BLOCK_GROW = true

func unregister_fortune(event_manager: EventManager):
	Global.BLOCK_GROW = false
