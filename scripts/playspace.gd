extends Node2D

var total_yield = 0.0
var week = 1
var energy = 3

func _ready() -> void:
	update_labels()
	$Cards.draw_hand()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_farm_tiles_card_played(card) -> void:
	energy -= card.cost
	update_labels()
	$Cards.play_card()


func _on_end_turn_button_pressed() -> void:
	Global.selected_card = Global.NO_CARD
	$Cards.discard_hand()
	await get_tree().create_timer(0.3).timeout
	$FarmTiles.process_one_week()
	await get_tree().create_timer(0.3).timeout
	$Cards.draw_hand()
	week += 1
	energy = Constants.MAX_ENERGY
	update_labels()


func _on_farm_tiles_on_yield_gained(yield_amount) -> void:
	total_yield += yield_amount
	update_labels()
	
func update_labels():
	$Stats/VBox/YieldLabel.text = "Total Yield: " + str(int(total_yield))
	$Stats/VBox/TurnLabel.text = "Week: " + str(week)
	$Stats/VBox/EnergyLabel.text = "Energy: " + str(energy) + " / " + str(Constants.MAX_ENERGY)
