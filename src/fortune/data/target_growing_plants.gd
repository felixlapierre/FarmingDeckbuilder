extends Fortune

func _init() -> void:
	super("Focused", FortuneType.BadFortune, "Blight will only target growing plants", 0)

func register_fortune(event_manager: EventManager):
	Global.BLIGHT_FLAG_THREATEN_GROWING = true

func unregister_fortune(event_manager: EventManager):
	Global.BLIGHT_FLAG_THREATEN_GROWING = false
