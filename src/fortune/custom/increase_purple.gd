extends Fortune
class_name IncreasePurple

func register_fortune(event_manager: EventManager):
	Global.BLIGHT_TARGET_MULTIPLIER *= strength

func unregister_fortune(event_manager: EventManager):
	Global.BLIGHT_TARGET_MULTIPLIER /= strength
