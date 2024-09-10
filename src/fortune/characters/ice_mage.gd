extends Fortune
class_name IceMageFortune

var icon = preload("res://assets/card/frostcut.png")

func _init() -> void:
	super("Ice Mage", Fortune.FortuneType.GoodFortune, "Your hand is not discarded at the end of the turn", 1, icon)

func register_fortune(event_manager: EventManager):
	Global.END_TURN_DISCARD = false

func unregister_fortune(event_manager: EventManager):
	Global.END_TURN_DISCARD = true
