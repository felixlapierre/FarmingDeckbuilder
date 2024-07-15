extends Node2D
class_name Tooltip

@onready var label: RichTextLabel = $Panel/Margin/Label

var t: float = 0.0

var hovered = false
var HOVER_DELAY = 0.5

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if hovered:
		t += delta
		if t > HOVER_DELAY:
			self.visible = true
			var mouse_position = get_global_mouse_position()
			position = mouse_position + Vector2(15, 15)

func display_tooltip(text: String):
	label.clear()
	hovered = true
	if text.length() > 0:
		label.append_text(text)
	else:
		label.append_text("Error")

func clear_tooltip():
	self.visible = false
	hovered = false
	t = 0.0

func register_tooltip(node: Control, text: String):
	node.mouse_entered.connect(func():
		display_tooltip(text))
	node.mouse_exited.connect(func():
		clear_tooltip())
