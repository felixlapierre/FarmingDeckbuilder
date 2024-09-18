extends MageAbility
class_name NoviceFortune

var icon = preload("res://assets/custom/YellowMana.png")

func _init() -> void:
	super("Novice", Fortune.FortuneType.GoodFortune, "Draw 1 extra card each turn", 0, icon)

func register_fortune(event_manager: EventManager):
	Constants.BASE_HAND_SIZE = 6

func unregister_fortune(event_manager: EventManager):
	Constants.BASE_HAND_SIZE = 5
