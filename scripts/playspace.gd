extends Node2D

var energy = 3
var victory = false
var turn_ending = false

var card_database
var deck = []
var starting_deck = [
	{
		"name": "carrot",
		"type": "seed",
		"count": 3
	},
	{
		"name": "blueberry",
		"type": "seed",
		"count": 3
	},
	{
		"name": "scythe",
		"type": "action",
		"count": 3
	},
	{
		"name": "pumpkin",
		"type": "seed",
		"count": 1
	}
]

var Shop = preload("res://scenes/shop.tscn")
var shop_instance
var shop_structure_place_callback

func _ready() -> void:
	card_database = preload("res://scripts/cards_database.gd")
	for card in starting_deck:
		for i in range(card.count):
			deck.append(card_database.get_card_by_name(card.name, card.type))
	update()
	start_year()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_farm_tiles_card_played(card) -> void:
	if card.type == "STRUCTURE":
		Global.selected_card = null
		shop_structure_place_callback.call()
		await get_tree().create_timer(1).timeout
		set_winter_visible(true)
		$Shop.visible = true
	else:
		energy -= card.cost
		update()
		$Cards.play_card()
		if victory == true:
			end_year()

func _on_end_turn_button_pressed() -> void:
	if turn_ending:
		return
	turn_ending = true
	Global.selected_card = null
	$Cards.discard_hand()
	await get_tree().create_timer(0.3).timeout
	await $FarmTiles.process_one_week()
	await get_tree().create_timer(0.1).timeout
	
	if victory == true:
		end_year()
		turn_ending = false
		return
	var damage = $TurnManager.end_turn()
	$Cards.draw_hand()
	energy = Constants.MAX_ENERGY

	if damage:
		print("Took Damage")
	update()
	turn_ending = false

func _on_farm_tiles_on_yield_gained(yield_amount, purple) -> void:
	if purple:
		$TurnManager.gain_purple_mana(yield_amount)
	else:
		var ritual_complete = $TurnManager.gain_yellow_mana(yield_amount)
		if ritual_complete:
			victory = true
	update()
	
func update():
	$UI/Stats/VBox/TurnLabel.text = "Week: " + str($TurnManager.week)
	$UI/Stats/VBox/EnergyLabel.text = "Energy: " + str(energy) + " / " + str(Constants.MAX_ENERGY)
	$UI/BlightCounter/Label.text = str($TurnManager.purple_mana)\
		 + " / " + str($TurnManager.target_blight)\
		 + " <-- " + str($TurnManager.next_turn_blight)
	$UI/RitualCounter/Label.text = str($TurnManager.ritual_counter)
	$Shop.update_labels()


func _on_shop_button_button_up() -> void:
	$Shop.set_deck(deck)
	$Shop.visible = true
	set_winter_visible(false)

func _on_shop_on_shop_closed() -> void:
	$Shop.visible = false
	set_winter_visible(true)

func _on_shop_on_item_bought(item) -> void:
	deck.append(item)

func _on_shop_on_money_spent(amount) -> void:
	update()

func _on_shop_on_card_removed(card) -> void:
	deck.erase(card)
	$Shop.set_deck(deck)

func _on_shop_on_structure_place(item, callback) -> void:
	Global.selected_card = item
	shop_structure_place_callback = callback
	set_winter_visible(false)
	$Shop.visible = false
	
func set_ui_visible(visible):
	$Cards.propagate_call("set_visible", [visible])
	$Winter/ShopButton.visible = visible
	$UI/Deck.visible = visible
	$UI/EndTurnButton.visible = visible
	$Shop.visible = visible
	$UI/BlightCounter.visible = visible
	$UI/RitualCounter.visible = visible

func set_winter_visible(visible):
	$Winter.visible = visible

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("transform"):
		Global.shape = (Global.shape + 1) % 3
	elif event.is_action_pressed("rotate"):
		Global.rotate = (Global.rotate + 1) % 4

func get_blight_at_week(week):
	return 0 if week < 5 else randi_range(0, 1) * (week * randi_range(1,3))

func _on_farm_tiles_on_preview_yield(yellow, purple) -> void:
	$UI/Preview.visible = yellow + purple > 0
	$UI/Preview/Panel/HBox/PreviewYellow.text = "+" + str(yellow)
	$UI/Preview/Panel/HBox/PreviewPurple.text = "+" + str(purple)
	
func end_year():
	$Cards.discard_hand()
	$Cards.do_winter_clear()
	await get_tree().create_timer(1.5).timeout

	$FarmTiles.do_winter_clear()
	$Shop.fill_shop()
	$TurnManager.end_year()
	$UI.visible = false
	$Winter.visible = true

func start_year():
	victory = false
	energy = Constants.MAX_ENERGY
	$TurnManager.start_new_year()
	$Cards.set_deck_for_year(deck)
	$Cards.draw_hand()
	update()
	$UI.visible = true
	$Cards.visible = true
	$Winter.visible = false


func _on_farm_upgrade_button_pressed() -> void:
	pass # Replace with function body.


func _on_farm_tiles_on_energy_gained(amount) -> void:
	energy += amount


func _on_skip_button_pressed() -> void:
	Global.selected_card = null
	end_year()
