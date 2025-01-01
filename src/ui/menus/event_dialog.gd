extends Node2D

var option_buttons: Array[Button]
var confirm_button: Button
var title: Label
var flavor_text: RichTextLabel
var flavor_cont: MarginContainer
var hover_node: Node

var confirm_callback: Callable

# Called when the node enters the scene tree for the first time.
func _ready():
	option_buttons = [$Center/Panel/VBox/HBox/VBoxContainer/Option1,\
		 $Center/Panel/VBox/HBox/VBoxContainer/Option2,\
		$Center/Panel/VBox/HBox/VBoxContainer/Option3,\
		$Center/Panel/VBox/HBox/VBoxContainer/Option4,\
		$Center/Panel/VBox/HBox/VBoxContainer/Option5]
	
	confirm_button = $Center/Panel/VBox/HBox/VBoxContainer/Confirm
	flavor_text = $Center/Panel/VBox/HBox/Margin/FlavorText
	flavor_cont = $Center/Panel/VBox/HBox/Margin
	
	title = $Center/Panel/VBox/Title

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func set_event(event: CustomEvent):
	var options: Array[CustomEvent.Option] = []
	options.assign(event.get_options())
	flavor_text.clear()
	flavor_text.append_text(event.text)
	title.text = event.name
	confirm_button.visible = false
	flavor_text.visible = true
	if hover_node != null:
		flavor_cont.remove_child(hover_node)
		hover_node = null
	for i in range(option_buttons.size()):
		if i < options.size():
			var option = options[i]
			option_buttons[i].visible = true
			option_buttons[i].text = option.name
			option_buttons[i].pressed.connect(func():
				confirm_callback = option.on_select
				confirm_button.visible = true
				if hover_node != null:
					flavor_cont.remove_child(hover_node)
					hover_node = null
				if option.hover != null:
					hover_node = option.hover
					flavor_cont.add_child(hover_node)
					flavor_text.visible = false
				else:
					flavor_text.visible = true
				)
		else:
			option_buttons[i].visible = false


func _on_confirm_pressed():
	$"../".visible = false
	confirm_callback.call()
