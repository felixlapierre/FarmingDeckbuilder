extends Node2D

var victory = false

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
	},
	{
		"name": "earthrite",
		"type": "action",
		"count": 1
	}
]

func _ready() -> void:
	card_database = preload("res://src/cards/cards_database.gd")
	$EventManager.setup($FarmTiles, $TurnManager)
	$UserInterface.setup($EventManager, $TurnManager, deck)
	for card in starting_deck:
		for i in range(card.count):
			deck.append(card_database.get_card_by_name(card.name, card.type))
	$UserInterface.update()
	start_year()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_farm_tiles_card_played(card) -> void:
	if card.CLASS_NAME == "Structure":
		Global.selected_structure = null
		$UserInterface.shop_structure_place_callback.call()
		await get_tree().create_timer(1).timeout
		$UserInterface.set_winter_visible(true)
		$UserInterface/Shop.visible = true
	else:
		$TurnManager.energy -= card.cost
		$UserInterface.update()
		$Cards.play_card()
		if victory == true:
			end_year()

func _on_farm_tiles_on_yield_gained(yield_amount, purple) -> void:
	if purple:
		$TurnManager.gain_purple_mana(yield_amount)
	else:
		var ritual_complete = $TurnManager.gain_yellow_mana(yield_amount)
		if ritual_complete:
			victory = true
	$UserInterface.update()
	

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("transform"):
		Global.shape = (Global.shape + 1) % 3
	elif event.is_action_pressed("rotate"):
		Global.rotate = (Global.rotate + 1) % 4
	
func end_year():
	$Cards.discard_hand()
	$Cards.do_winter_clear()
	await get_tree().create_timer(1.5).timeout
	
	$Cards.propagate_call("set_visible", [false])
	$FarmTiles.do_winter_clear()
	$TurnManager.end_year()
	$UserInterface.end_year()


func start_year():
	victory = false
	$TurnManager.start_new_year()
	$Cards.set_deck_for_year(deck)
	$Cards.draw_hand($TurnManager.get_cards_drawn(), $TurnManager.week)
	$Cards.propagate_call("set_visible", [true])
	$UserInterface.start_year()
	$EventManager.notify_year_start()

func _on_farm_tiles_on_energy_gained(amount) -> void:
	$TurnManager.energy += amount
	$UserInterface.update()

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

func on_upgrade(upgrade: Upgrade):
	if upgrade.type == Upgrade.UpgradeType.ExpandFarm:
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
	else:
		print(upgrade.text)

func on_turn_end():
	$Cards.discard_hand()
	await get_tree().create_timer(0.3).timeout
	await $FarmTiles.process_one_week()
	await get_tree().create_timer(0.1).timeout
	
	if victory == true:
		end_year()
		$UserInterface.turn_ending = false
		return
	var damage = $TurnManager.end_turn()
	if damage:
		$UserInterface.damage_taken()
		$FarmTiles.destroy_blighted_tiles()

	$Cards.draw_hand($TurnManager.get_cards_drawn(), $TurnManager.week)
	
	if $TurnManager.blight_damage >= Constants.MAX_BLIGHT:
		on_lose()
	$FarmTiles.set_blight_target_tiles(Constants.BASE_BLIGHT_DAMAGE if $TurnManager.target_blight > 0 else 0)
	await get_tree().create_timer(1).timeout
	$UserInterface.update()
	$UserInterface.turn_ending = false
