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
	$EventManager.setup($FarmTiles, $TurnManager)
	$FortuneTeller.setup($EventManager)
	for card in starting_deck:
		for i in range(card.count):
			deck.append(card_database.get_card_by_name(card.name, card.type))
	for i in Constants.MAX_BLIGHT:
		var sprite = TextureRect.new()
		sprite.texture = load("res://assets/custom/BlightEmpty.png")
		sprite.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
		$UI/BlightDamage.add_child(sprite)
	update()
	start_year()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_farm_tiles_card_played(card) -> void:
	if card.CLASS_NAME == "Structure":
		Global.selected_structure = null
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
	

	$Cards.draw_hand(get_cards_drawn(), $TurnManager.week)
	
	energy = get_max_energy()

	if damage:
		$UI/BlightDamage.visible = true
		var img = $UI/BlightDamage.get_child($TurnManager.blight_damage - 1)
		img.texture = load("res://assets/custom/Blight.png")
		$FarmTiles.destroy_blighted_tiles()
	update()
	if $TurnManager.blight_damage >= Constants.MAX_BLIGHT:
		on_lose()
	$FarmTiles.set_blight_target_tiles(Constants.BASE_BLIGHT_DAMAGE if $TurnManager.target_blight > 0 else 0)
	await get_tree().create_timer(1).timeout
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
	$UI/Stats/VBox/YearLabel.text = "Year: " + str($TurnManager.year) + " / 10"
	$UI/Stats/VBox/TurnLabel.text = "Week: " + str($TurnManager.week)
	$UI/Stats/VBox/EnergyHbox/EnergyLabel.text = "Energy: " + str(energy) + " / " + str(Constants.MAX_ENERGY + int(float(Global.ENERGY_FRAGMENTS) / 3))
	for child in $UI/Stats/VBox/EnergyHbox/Fragments.get_children():
		$UI/Stats/VBox/EnergyHbox/Fragments.remove_child(child)
	for i in range(Global.ENERGY_FRAGMENTS % 3):
		var fragment = TextureRect.new()
		fragment.texture = load("res://assets/custom/EnergyFrag.png")
		fragment.expand_mode = TextureRect.EXPAND_FIT_WIDTH
		$UI/Stats/VBox/EnergyHbox/Fragments.add_child(fragment)
	
	$UI/Stats/VBox/CardsHbox/CardsLabel.text = "Cards: " + str(get_cards_drawn()) + " / " + str(Constants.BASE_HAND_SIZE + int(float(Global.SCROLL_FRAGMENTS) / 3))
	for child in $UI/Stats/VBox/CardsHbox/Fragments.get_children():
		$UI/Stats/VBox/CardsHbox/Fragments.remove_child(child)
	for i in range(Global.SCROLL_FRAGMENTS % 3):
		var fragment = TextureRect.new()
		fragment.texture = load("res://assets/custom/CardFragment.png")
		fragment.expand_mode = TextureRect.EXPAND_FIT_WIDTH
		$UI/Stats/VBox/CardsHbox/Fragments.add_child(fragment)
		
	$UI/BlightCounter/Label.text = str($TurnManager.purple_mana)\
		 + " / " + str($TurnManager.target_blight)\
		 + " <-- " + str($TurnManager.next_turn_blight)
	$UI/RitualCounter/Label.text = str($TurnManager.ritual_counter)
	$Shop.update_labels()
	$Winter/FarmUpgradeButton.disabled = $UpgradeShop.lock
	$Winter/NextYearButton.disabled = !$UpgradeShop.lock


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

func _on_shop_on_structure_place(structure, callback) -> void:
	Global.selected_structure = structure
	Global.selected_card = null
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
	$FortuneTeller.unregister_fortunes()
	$FortuneTeller.create_fortunes()
	$TurnManager.end_year()
	$UI.visible = false
	$Winter.visible = true
	$UpgradeShop.lock = false
	update()

func start_year():
	victory = false
	$FortuneTeller.register_fortunes()
	$TurnManager.start_new_year()
	$Cards.set_deck_for_year(deck)
	$Cards.draw_hand(get_cards_drawn(), $TurnManager.week)
	energy = get_max_energy()
	$UI.visible = true
	$Cards.visible = true
	$Winter.visible = false
	$EventManager.notify_year_start()
	update()


func _on_farm_upgrade_button_pressed() -> void:
	if !$UpgradeShop.lock:
		$UpgradeShop.visible = true

func _on_farm_tiles_on_energy_gained(amount) -> void:
	energy += amount
	update()


func _on_skip_button_pressed() -> void:
	Global.selected_card = null
	end_year()

func on_lose():
	$Cards.discard_hand()
	$Cards.do_winter_clear()
	$UI/EndTurnButton.visible = false
	$LoseContainer.visible = true
	$UI/Deck.visible = false
	$UI/RitualCounter.visible = false


func _on_farm_tiles_on_card_draw(number_of_cards, card) -> void:
	for i in range(number_of_cards):
		$Cards.drawcard()

func upgrade_shop_close():
	$UpgradeShop.visible = false
	update()

func on_upgrade(upgrade: Upgrade):
	if upgrade.name == "expand":
		match int(upgrade.strength):
			0:
				Global.FARM_TOPLEFT.y -= 1
			1:
				Global.FARM_BOTRIGHT.x += 1
			2:
				Global.FARM_BOTRIGHT.y += 1
			3:
				Global.FARM_TOPLEFT.x -= 1
		$FarmTiles.on_expand_farm()

func get_cards_drawn():
	var cards_drawn = Constants.BASE_HAND_SIZE
	if (Global.SCROLL_FRAGMENTS % 3 > ($TurnManager.week-1) % 3):
		cards_drawn += 1
	cards_drawn += int(float(Global.SCROLL_FRAGMENTS) / 3)
	return cards_drawn

func get_max_energy():
	var new_energy = Constants.MAX_ENERGY
	if (Global.ENERGY_FRAGMENTS % 3 > ($TurnManager.week-1) % 3):
		new_energy += 1
	new_energy += int(float(Global.ENERGY_FRAGMENTS) / 3)
	return new_energy


func _on_fortune_teller_button_pressed() -> void:
	$FortuneTeller.visible = true


func _on_fortune_teller_on_close() -> void:
	$FortuneTeller.visible = false
