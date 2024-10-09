extends Control

@export var value: int = 0
@export var max_value: int = 3
@export var text: String

signal on_value_updated

# Called when the node enters the scene tree for the first time.
func _ready():
	$HBox/Descr.text = text
	update_value()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func update_value():
	$HBox/Number.text = str(value)
	$HBox/Minus.disabled = value == 0
	$HBox/Plus.disabled = value >= max_value
	on_value_updated.emit(value)

func _on_plus_pressed():
	value += 1
	update_value()


func _on_minus_pressed():
	value -= 1
	update_value()
