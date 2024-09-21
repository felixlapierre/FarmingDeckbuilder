extends Control

signal go_to_main_menu

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_main_menu_pressed() -> void:
	go_to_main_menu.emit()


func _on_close_button_pressed() -> void:
	visible = false
