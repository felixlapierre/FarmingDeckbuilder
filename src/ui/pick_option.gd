extends Node2D

var ShopCard = preload("res://src/shop/shop_card.tscn")
var ShopDisplay = preload("res://src/shop/shop_display.tscn")
@onready var options_container = $Center/Panel/VBox/HBox
@onready var prompt_label = $Center/Panel/VBox/PromptLabel

var on_skip: Callable

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func setup(prompt: String, items, pick_callback: Callable, skip_callback):
	prompt_label.text = prompt
	if skip_callback != null:
		on_skip = skip_callback
	$Center/Panel/VBox/SkipButton.visible = skip_callback != null
	for item in items:
		if item.CLASS_NAME == "CardData":
			var new_node = ShopCard.instantiate()
			new_node.card_data = item
			new_node.on_clicked.connect(func(option): pick_callback.call(option))
			options_container.add_child(new_node)
		elif item.CLASS_NAME == "Structure":
			var new_node = ShopDisplay.instantiate()
			new_node.set_data(item)
			new_node.callback = func(option): pick_callback.call(option)
			options_container.add_child(new_node)
		elif item.CLASS_NAME == "Enhance":
			var new_node = ShopDisplay.instantiate()
			new_node.set_data(item)
			new_node.callback = func(option): pick_callback.call(option)
			options_container.add_child(new_node)
		#TODO: Else use a generic ShopButton instead


func _on_skip_button_pressed():
	if on_skip != null:
		on_skip.call()
