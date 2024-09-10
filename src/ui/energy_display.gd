extends Node2D

var mod_white = Color8(255, 255, 255)
var mod_black = Color8(0, 0, 0)
var mod_red = Color8(255, 0, 0)

var flashing = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func set_energy(energy: int):
	var color = "black"
	if energy == 0:
		$Sprite2D.modulate = mod_black
		color = "red"
	else:
		$Sprite2D.modulate = mod_white
	$Label.text = "[color=" + color + "]" + str(energy) + "[/color]"

func no_energy():
	flashing = true
	for i in range(5):
		await get_tree().create_timer(0.05).timeout
		$Label.text = "[color=white]0[/color]"
		$Sprite2D.modulate = mod_red
		await get_tree().create_timer(0.05).timeout
		$Label.text = "[color=red]0[/color]"
		$Sprite2D.modulate = mod_black
	await get_tree().create_timer(1.0).timeout
	flashing = false
