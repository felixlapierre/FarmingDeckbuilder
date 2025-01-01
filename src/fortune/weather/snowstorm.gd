extends Fortune
class_name SnowstormWeather

var display_texture = preload("res://assets/fortune/snowflake.png")

func _init() -> void:
	super("Snowstorm", Fortune.FortuneType.GoodFortune, "Plants will not grow naturally this turn", 0, display_texture, strength)

func register_fortune(event_manager: EventManager):
	Global.BLOCK_GROW = true

func unregister_fortune(event_manager: EventManager):
	Global.BLOCK_GROW = false
