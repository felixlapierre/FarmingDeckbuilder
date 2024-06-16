extends Resource
class_name GameEvent

@export var name: String
@export_multiline var text: String
@export var flavor_text_1: String
@export var flavor_text_2: String
@export var flavor_text_3: String
@export var option1: Array[Upgrade]
@export var option2: Array[Upgrade]
@export var option3: Array[Upgrade]

func _init(p_name = "name", p_text = "text", p_flavor_1 = "", p_flavor_2 = "", p_flavor_3 = "", \
	p_option1 = [], p_option2 = [], p_option3 = []) -> void:
	name = p_name
	text = p_text
	flavor_text_1 = p_flavor_1
	flavor_text_2 = p_flavor_2
	flavor_text_3 = p_flavor_3
	option1.append_array(p_option1)
	option2.append_array(p_option2)
	option3.append_array(p_option3)

