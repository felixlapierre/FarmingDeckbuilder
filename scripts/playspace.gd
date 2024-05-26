extends Node2D

var total_yield = 0.0
var week = 1
var energy = 3

var Shop = preload("res://scenes/shop.tscn")
var shop_instance

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


func _on_shop_button_button_up() -> void:
	shop_instance = Shop.instantiate()
	shop_instance.on_shop_closed.connect(_on_shop_on_shop_closed)
	shop_instance.on_item_bought.connect(_on_shop_on_item_bought)
	self.add_child(shop_instance)

func _on_shop_on_shop_closed() -> void:
	self.remove_child(shop_instance)

func _on_shop_on_item_bought(card_name) -> void:
	$Cards.add_card_from_shop(card_name)
