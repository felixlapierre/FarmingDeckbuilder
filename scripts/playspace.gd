extends Node2D

var total_yield = 500
var week = 1
var energy = 3
var yield_counter = 0

var Shop = preload("res://scenes/shop.tscn")
var shop_instance
var shop_structure_place_callback

func _ready() -> void:
	update()
	$Cards.draw_hand()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_farm_tiles_card_played(card) -> void:
	if card.type == "STRUCTURE":
		Global.selected_card = Global.NO_CARD
		await get_tree().create_timer(1).timeout
		shop_structure_place_callback.call()
		set_ui_visible(true)


	else:
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
	yield_counter = 0
	update()


func _on_farm_tiles_on_yield_gained(yield_amount) -> void:
	total_yield += yield_amount
	yield_counter += yield_amount
	update()
	
func update():
	$Stats/VBox/YieldLabel.text = "Total Yield: " + str(int(total_yield))
	$Stats/VBox/TurnLabel.text = "Week: " + str(week)
	$Stats/VBox/EnergyLabel.text = "Energy: " + str(energy) + " / " + str(Constants.MAX_ENERGY)
	$YieldCounter.text = str(yield_counter)
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
	if item.type == "SEED" or item.type == "ACTION":
		$Cards.add_card_from_shop(item.data)

func _on_shop_on_money_spent(amount) -> void:
	total_yield -= amount
	update()

func _on_shop_on_card_removed(card) -> void:
	$Cards.remove_hand_card(card)
	$Shop.set_deck($Cards.get_hand_info())

func _on_shop_on_structure_place(item, callback) -> void:
	Global.selected_card = item.data
	shop_structure_place_callback = callback
	set_ui_visible(false)
	
func set_ui_visible(visible):
	$Cards.propagate_call("set_visible", [visible])
	$ShopButton.visible = visible
	$Deck.visible = visible
	$EndTurnButton.visible = visible
	$Shop.visible = visible

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("transform"):
		Global.shape = (Global.shape + 1) % 3
	elif event.is_action_pressed("rotate"):
		Global.rotate = (Global.rotate + 1) % 4
