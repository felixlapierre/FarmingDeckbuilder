extends Fortune
class_name IncreasePurple

@export var strength: float = 1.0

func register_fortune(event_manager: EventManager):
	Global.BLIGHT_TARGET_MULTIPLIER *= strength

func unregister_fortune(event_manager: EventManager):
	Global.BLIGHT_TARGET_MULTIPLIER /= strength

func save_data() -> Dictionary:
	var dict = super.save_data()
	dict.strength = strength
	return dict

func load_data(data) -> Fortune:
	super.load_data(data)
	strength = data.strength
	return self
