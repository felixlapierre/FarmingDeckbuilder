extends Fortune
class_name ClearWeather

var display_texture = preload("res://assets/custom/Temp.png")

func _init() -> void:
	super("Clear Skies", Fortune.FortuneType.GoodFortune, "No weather this turn", 0, display_texture, strength)
