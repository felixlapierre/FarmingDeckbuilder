extends Resource
class_name Fortune

enum FortuneType {
	GoodFortune,
	BadFortune
}

var temp: Texture2D = preload("res://assets/custom/Temp.png")

@export var name: String
@export var type: FortuneType
@export var text: String
@export var rank: int
@export var texture: Texture2D

func _init(p_name = "", p_type = FortuneType.GoodFortune, p_text = "", p_rank = 0, p_texture = temp):
	name = p_name
	type = p_type
	text = p_text
	rank = p_rank
	texture = p_texture

func register_fortune(event_manager: EventManager):
	pass

func unregister_fortune(event_manager: EventManager):
	pass
