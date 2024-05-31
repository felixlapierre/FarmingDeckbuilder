extends Node2D

var total_yield = 500
var week = 1
var energy = 3
var yield_counter = 0
var blight_counter = 0
var target_blight = 0
var ritual_counter = 0
var next_turn_blight = 0

var card_database
var deck = []
var starting_deck = [
	{
		"name": "carrot",
		"type": "seed",
		"count": 2
	},
	{
		"name": "blueberry",
		"type": "seed",
		"count": 2
	},
	{
		"name": "scythe",
		"type": "action",
		"count": 3
	},
	{
		"name": "watermelon",
		"type": "seed",
		"count": 1
	},
	{
		"name": "coffee",
		"type": "seed",
		"count": 1
	},
	{
		"name": "mint",
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
	ritual_counter = 30

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_farm_tiles_card_played(card) -> void:
	if card.type == "STRUCTURE":
		Global.selected_card = null
		await get_tree().create_timer(1).timeout
		shop_structure_place_callback.call()
		set_winter_visible(true)
		$Shop.visible = true


	else:
		energy -= card.cost
		update()
		$Cards.play_card()


func _on_end_turn_button_pressed() -> void:
	target_blight -= blight_counter
	blight_counter = 0
	Global.selected_card = null
	$Cards.discard_hand()
	await get_tree().create_timer(0.3).timeout
	await $FarmTiles.process_one_week()
	await get_tree().create_timer(0.1).timeout
	if ritual_counter <= 0:
		# End the year
		end_year()
		return
	$Cards.draw_hand()
	week += 1
	energy = Constants.MAX_ENERGY
	yield_counter = 0

	if target_blight > 0:
		print("Took Damage")
	target_blight = 0
	target_blight = next_turn_blight
	next_turn_blight = get_blight_at_week(week)
	update()


func _on_farm_tiles_on_yield_gained(yield_amount, purple) -> void:
	if purple:
		blight_counter += yield_amount
	else:
		total_yield += yield_amount
		yield_counter += yield_amount
		ritual_counter -= yield_amount
	update()
	
func update():
	$UI/Stats/VBox/YieldLabel.text = "Total Yield: " + str(int(total_yield))
	$UI/Stats/VBox/TurnLabel.text = "Week: " + str(week)
	$UI/Stats/VBox/EnergyLabel.text = "Energy: " + str(energy) + " / " + str(Constants.MAX_ENERGY)
	$UI/BlightCounter/Label.text = str(blight_counter) + " / " + str(target_blight) + " <-- " + str(next_turn_blight)
	$UI/RitualCounter/Label.text = str(ritual_counter)
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
	total_yield -= amount
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
	$FarmTiles.do_winter_clear()
	$UI.visible = false
	$Cards.do_winter_clear()
	$Winter.visible = true
	$Shop.fill_shop()
	next_turn_blight = 0

func start_year():
	$UI.visible = true
	$Cards.visible = true
	$Winter.visible = false
	ritual_counter = 30
	$Cards.set_deck_for_year(deck)
	$Cards.draw_hand()
	week = 1
	update()


func _on_farm_upgrade_button_pressed() -> void:
	pass # Replace with function body.


func _on_farm_tiles_on_energy_gained(amount) -> void:
	energy += amount


func _on_skip_button_pressed() -> void:
	ritual_counter = 0
	blight_counter = 0
	Global.selected_card = null
	$Cards.discard_hand()
	end_year()
