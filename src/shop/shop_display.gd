extends MarginContainer

@export var structure: Structure
@export var enhance: Enhance
@export var callback: Callable
var tooltip: Tooltip

@onready var icon = $Icon
@onready var Description = $VBox/HBoxContainer/VBoxContainer/DescriptionLabel
@onready var Name = $VBox/HBoxContainer/VBoxContainer/TopBar/NameLabel
@onready var Cost = $VBox/HBoxContainer/VBoxContainer/TopBar/CostLabel
@onready var Type = $VBox/TypeLabel

# Just display the data of the passed structure and enhance
# and accept a callback to be invoked when this is clicked

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if structure != null:
		set_labels(structure.name, str(structure.cost), structure.text, "Structure",\
			structure.texture)
		$VBox/HBoxContainer.tooltip_text = structure.tooltip
	elif enhance != null:
		set_labels(enhance.name, "", enhance.get_description(), "Enhance", enhance.texture)
		$Border.modulate = Color8(181, 233, 255)
	$Icon.position = Constants.CARD_SIZE / 2
	$Icon.position.y /= 2
	$Icon.position.y += 25

func set_labels(name, cost, descr, type, texture):
		Name.text = name
		Cost.text = cost
		Description.text = descr
		Type.text = type
		$Icon.texture = texture

func set_data(data):
	if data.CLASS_NAME == "Structure":
		structure = data
	elif data.CLASS_NAME == "Enhance":
		enhance = data

func _on_h_box_container_gui_input(event: InputEvent) -> void:
	if event.is_action_pressed("leftclick"):
		callback.call()

func get_data():
	if structure != null:
		return structure
	if enhance != null:
		return enhance

func register_tooltips():
	pass
