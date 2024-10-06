extends Control

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
		if fortune_display.global_position.x > 1300:
			fortune_display.global_position.x -= fortune_display.size.x + 10
		if fortune_display.global_position.y > 800:
			fortune_display.global_position.y -= fortune_display.size.y + 30

func setup(fortune: Fortune):
	$Fortune/VBox/Name.text = fortune.name
	$Fortune/VBox/Description.text = fortune.text
	$Fortune/VBox/Texture.texture = fortune.texture
	$Panel/Margin/Button.texture_normal = fortune.texture

func setup_custom(name: String, text: String, texture: Texture2D, count: int):
	fortune_name.text = name
	fortune_descr.text = text
	fortune_texture.texture = texture
	button.texture_normal = texture
	if count > 0:
		$Label.text = str(count)
		$Label.visible = true
	else:
		$Label.visible = false

func setup_energy_fragments():
	var count = Global.ENERGY_FRAGMENTS
	var name = "Energy Fragment" + ("s" if count > 0 else "")
	var desc = "Each fragment grants one energy every 1 out of 3 turns"
	var texture = load("res://assets/custom/EnergyFrag.png")
	setup_custom(name, desc, texture, count)

func setup_card_fragments():
	var count = Global.SCROLL_FRAGMENTS
	var name = "Card Fragment" + ("s" if count > 0 else "")
	var desc = "Each fragment grants one extra card draw every 1 out of 3 turns"
	var texture = load("res://assets/custom/CardFragment.png")
	setup_custom(name, desc, texture, count)

func _on_button_mouse_entered() -> void:
	fortune_display.visible = true
	hover = true

func _on_button_mouse_exited() -> void:
	fortune_display.visible = false
	hover = false
