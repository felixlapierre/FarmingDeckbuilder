extends MageAbility
class_name IceMageFortune

var icon = preload("res://assets/card/frostcut.png")

func _init() -> void:
	super("Frost Witch", Fortune.FortuneType.GoodFortune, "Your hand is not discarded at the end of the turn. Set maximum hand size to 8.", 1, icon)

func register_fortune(event_manager: EventManager):
	Global.END_TURN_DISCARD = false
	Global.MAX_HAND_SIZE = 8

func unregister_fortune(event_manager: EventManager):
	Global.END_TURN_DISCARD = true
	Global.MAX_HAND_SIZE = 10
