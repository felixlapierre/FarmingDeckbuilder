extends Node2D

func _ready() -> void:

	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_farm_tiles_card_played() -> void:
	$Cards.play_card()


func _on_end_turn_button_pressed() -> void:
	$Cards.discard_hand()
	await get_tree().create_timer(0.3).timeout
	$FarmTiles.process_one_week()
	await get_tree().create_timer(0.3).timeout
	$Cards.draw_hand()
