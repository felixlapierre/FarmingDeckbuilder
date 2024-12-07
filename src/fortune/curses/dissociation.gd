extends Fortune
class_name Dissociation

var icon = preload("res://assets/custom/Temp.png")

func _init() -> void:
	super("Dissociation", Fortune.FortuneType.BadFortune, "Draw 1 fewer card per turn", 1, icon, 1.0)

func register_fortune(event_manager: EventManager):
	Constants.BASE_HAND_SIZE -= 1

func unregister_fortune(event_manager: EventManager):
	Constants.BASE_HAND_SIZE += 1
