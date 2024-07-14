extends Control

signal option_selected

@export var text: String
@export var texture: Texture2D
@export var cost: int
@export var row: int
@export var disabled: bool
@export var callback: Callable

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if cost != 0:
		$HBox/Center/VBox/CostBox.visible = true
		$HBox/Center/VBox/CostBox/CostLabel.text = str(cost)
	else:
		$HBox/Center/VBox/CostBox.visible = false
	$HBox/Center/VBox/DescriptionLabel.text = text
	$HBox/Center/VBox/Image.texture = texture


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_h_box_gui_input(event: InputEvent) -> void:
	if event.is_action_pressed("leftclick"):
		option_selected.emit(cost, row)

func get_data():
	return null
