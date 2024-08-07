extends Node2D

var offset = Vector2(30, 30)
@onready var fortune_display = $Fortune
@onready var fortune_name = $Fortune/VBox/Name
@onready var fortune_descr = $Fortune/VBox/Description
@onready var fortune_texture = $Fortune/VBox/Texture
@onready var button = $Panel/Margin/Button

var hover = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if hover:
		fortune_display.global_position = get_global_mouse_position() + offset
		print(fortune_display.size)


func setup(fortune: Fortune):
	fortune_name.text = fortune.name
	fortune_descr.text = fortune.text
	fortune_texture.texture = fortune.texture
	button.texture_normal = fortune.texture

func _on_button_mouse_entered() -> void:
	fortune_display.visible = true
	hover = true

func _on_button_mouse_exited() -> void:
	fortune_display.visible = false
	hover = false
