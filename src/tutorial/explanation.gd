extends Node2D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func set_text(text: String):
	$PCont/MarginCont/Exp.clear()
	$PCont/MarginCont/Exp.append_text(text)

func set_exp_size(x: int, y: int):
	$PCont/MarginCont/Exp.custom_minimum_size = Vector2(x, y)

func set_theme(theme: Theme):
	$PCont/MarginCont/Exp.theme = theme
