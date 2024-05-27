extends Node2D

var total_yield = 1100.0
var week = 1
var energy = 3

var Shop = preload("res://scenes/shop.tscn")
var shop_instance

func _ready() -> void:
	update()
	$Cards.draw_hand()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_farm_tiles_card_played(card) -> void:
	energy -= card.cost
	update()
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
	update()


func _on_farm_tiles_on_yield_gained(yield_amount) -> void:
	total_yield += yield_amount
	update()
	
func update():
	$Stats/VBox/YieldLabel.text = "Total Yield: " + str(int(total_yield))
	$Stats/VBox/TurnLabel.text = "Week: " + str(week)
	$Stats/VBox/EnergyLabel.text = "Energy: " + str(energy) + " / " + str(Constants.MAX_ENERGY)
	$Shop.player_money = total_yield
	$Shop.update_labels()


func _on_shop_button_button_up() -> void:
	$Shop.set_deck($Cards.get_hand_info())
	$Shop.visible = true

func _on_shop_on_shop_closed() -> void:
	$Shop.visible = false

func _on_shop_on_item_bought(item) -> void:
	total_yield -= item.cost
	update()
	if item.type == "CARD":
		$Cards.add_card_from_shop(item.data)

func _on_shop_on_money_spent(amount) -> void:
	total_yield -= amount
	update()


func _on_shop_on_card_removed(card) -> void:
	$Cards.remove_hand_card(card)
	$Shop.set_deck($Cards.get_hand_info())
