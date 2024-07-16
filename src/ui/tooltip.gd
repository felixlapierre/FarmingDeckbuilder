extends Node2D
class_name Tooltip

@onready var label: RichTextLabel = $Panel/Margin/Label

var t: float = 0.0

var hovered = false
var HOVER_DELAY = 0.5

var tooltip_dict = {}

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
	else:
		t = 0.0

func display_tooltip(node: Control):
	label.clear()
	hovered = true
	var text = tooltip_dict[node.get_instance_id()]
	if text.length() > 0:
		label.append_text(text)
	else:
		label.append_text("Error")

func clear_tooltip():
	self.visible = false
	hovered = false

func register_tooltip(node: Control, text: String):
	# Need to be able to update the tooltip with new string
	if tooltip_dict.has(node.get_instance_id()):
		tooltip_dict[node.get_instance_id()] = text
	else:
		var callback = func():
			display_tooltip(node)
		node.mouse_entered.connect(callback)
		tooltip_dict[node.get_instance_id()] = text
		node.mouse_exited.connect(func():
			clear_tooltip())
