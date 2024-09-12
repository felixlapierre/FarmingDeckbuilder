extends MageAbility
class_name BlankMage
var icon = preload("res://assets/custom/Temp.png")
func _init() -> void:
	super("", Fortune.FortuneType.GoodFortune, "", -1, icon)
