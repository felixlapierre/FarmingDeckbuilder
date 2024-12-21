extends MarginContainer
signal clicked

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func setup(fortune: Fortune):
	$VBox/Name.text = fortune.name
	$VBox/Description.text = fortune.text
	$VBox/Texture.texture = fortune.texture

func _on_list_gui_input(event: InputEvent) -> void:
	if event.is_action_pressed("leftclick"):
		clicked.emit()