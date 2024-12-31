extends Fortune
class_name IncreaseBlightStrength

var fortune_texture = preload("res://assets/custom/Temp.png")

func _init(strength: float = 1.0) -> void:
	super("Cataclysm", Fortune.FortuneType.BadFortune, "Blight attack strength increased by {STR_PER}", 0, fortune_texture, strength)

func register_fortune(event_manager: EventManager):
	pass

func unregister_fortune(event_manager: EventManager):
	pass
