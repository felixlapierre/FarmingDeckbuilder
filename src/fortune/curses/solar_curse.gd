extends Fortune
class_name SolasCurse

var icon = preload("res://assets/custom/Temp.png")

func _init() -> void:
	super("Solas' Curse", Fortune.FortuneType.GoodFortune, "Seasons last 3 weeks instead of 4", 1, icon, 1.0)

func register_fortune(event_manager: EventManager):
	Global.SUMMER_WEEK = 4
	Global.FALL_WEEK = 7
	Global.WINTER_WEEK = 10
	Global.FINAL_WEEK = 10

func unregister_fortune(event_manager: EventManager):
	Global.SUMMER_WEEK = 5
	Global.FALL_WEEK = 9
	Global.WINTER_WEEK = 13
	Global.FINAL_WEEK = 13
