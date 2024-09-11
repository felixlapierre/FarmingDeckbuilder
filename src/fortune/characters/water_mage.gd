extends MageAbility
class_name WaterMage

var icon = preload("res://assets/card/water.png")

func _init() -> void:
	super("Water Mage", Fortune.FortuneType.GoodFortune, "Watered tiles cannot be targeted by the Blight", 4, icon)

func register_fortune(event_manager: EventManager):
	Global.IRRIGATE_PROTECTED = true

func unregister_fortune(event_manager: EventManager):
	Global.IRRIGATE_PROTECTED = false
