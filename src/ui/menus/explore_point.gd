extends Node2D
class_name ExplorePoint

signal on_select

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func setup(name: String):
	$Button.text = name

func _on_button_pressed():
	on_select.emit()
