extends PanelContainer
class_name Alert

@onready var AlertLabel = $AlertLabel

var current_text: String = ""

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	reposition()

func set_text(text: String):
	current_text = text
	AlertLabel.clear()
	AlertLabel.append_text("[center]" + text + "[/center]")
	visible = true

func clear(text: String):
	if current_text == text:
		visible = false

func reposition():
	position.x = Constants.VIEWPORT_SIZE.x / 2 - AlertLabel.size.x / 2
	
