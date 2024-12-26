extends Control
class_name OptionPrevie

var description: RichTextLabel

# Called when the node enters the scene tree for the first time.
func _ready():
	description = $VBox/Description

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func text_preview(text: String):
	description = $VBox/Description
	description.clear()
	description.append_text("[center]")
	description.append_text(text)
	return self

func nodes_preview(text: String, nodes: Array[Node]):
	for node in nodes:
		$VBox/HBox.add_child(node)
	return text_preview(text)
