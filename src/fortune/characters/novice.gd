extends MageAbility
class_name NoviceFortune

var icon = preload("res://assets/custom/YellowMana.png")

func _init() -> void:
	super("Novice", Fortune.FortuneType.GoodFortune, "Draw 1 extra card each turn", 0, icon, 1.0)
	text = "Draw " + str(strength) + " extra cards each turn"

func register_fortune(event_manager: EventManager):
	Constants.BASE_HAND_SIZE = 5 + int(strength)

func unregister_fortune(event_manager: EventManager):
	Constants.BASE_HAND_SIZE = 5

func upgrade_power():
	strength += 1.0
	Constants.BASE_HAND_SIZE = 5 + int(strength)
	text = "Draw " + str(strength) + " extra cards each turn"
