extends Resource
class_name Fortune

enum FortuneType {
	GoodFortune,
	BadFortune
}

@export var name: String
@export var type: FortuneType
@export var text: String
@export var rank: int

func _init(p_name = "", p_type = FortuneType.GoodFortune, p_text = "", p_rank = 0):
	name = p_name
	type = p_type
	text = p_text
	rank = p_rank

func register_fortune(event_manager: EventManager):
	pass

func unregister_fortune(event_manager: EventManager):
	pass
