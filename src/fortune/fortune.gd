extends Resource
class_name Fortune

enum FortuneType {
	GoodFortune,
	MinorBadFortune,
	MajorBadFortune
}

@export var name: String
@export var type: FortuneType
@export var text: String

func _init(p_name = "", p_type = FortuneType.GoodFortune, p_text = ""):
	name = p_name
	type = p_type
	text = p_text

func register_fortune(event_manager: EventManager):
	pass

func unregister_fortune(event_manager: EventManager):
	pass
