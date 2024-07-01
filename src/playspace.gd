extends Node2D

var victory = false

var card_database
var deck: Array[CardData] = []

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

func _ready() -> void:
	randomize()
	card_database = preload("res://src/cards/cards_database.gd")
	$EventManager.setup($FarmTiles, $TurnManager, $Cards)
	$UserInterface.setup($EventManager, $TurnManager, deck)
	for card in starting_deck:
		for i in range(card.count):
			deck.append(card_database.get_card_by_name(card.name, card.type))
	$UserInterface.update()
	$FarmTiles.setup($EventManager)
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

func _on_farm_tiles_on_yield_gained(yield_amount, purple, delay) -> void:
	if purple:
		$TurnManager.gain_purple_mana(yield_amount, delay)
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
	$UserInterface.start_year()
	$EventManager.notify(EventManager.EventType.BeforeYearStart)
	$TurnManager.start_new_year()
	$Cards.set_deck_for_year(deck)
	$Cards.draw_hand($TurnManager.get_cards_drawn(), $TurnManager.week)
	$Cards.propagate_call("set_visible", [true])
	$UserInterface.update()
	$EventManager.notify(EventManager.EventType.AfterYearStart)
	$EventManager.notify(EventManager.EventType.BeforeTurnStart)

func _on_farm_tiles_on_energy_gained(amount) -> void:
	$TurnManager.energy += amount
	$UserInterface.update()

func on_lose():
	$Cards.discard_hand()
	$Cards.do_winter_clear()
	$UserInterface/UI/EndTurnButton.visible = false
	$LoseContainer.visible = true
	$UserInterface/UI/Deck.visible = false
	$UserInterface/UI/RitualCounter.visible = false


func _on_farm_tiles_on_card_draw(number_of_cards, card) -> void:
	for i in range(number_of_cards):
		if card == null:
			$Cards.drawcard()
		else:
			$Cards.draw_specific_card(card)

func on_upgrade(upgrade: Upgrade):
	match upgrade.type:
		Upgrade.UpgradeType.ExpandFarm:
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
		Upgrade.UpgradeType.RemoveAnyCard:
			$UserInterface.select_card_to_remove()
		Upgrade.UpgradeType.CopyAnyCard:
			$UserInterface.select_card_to_copy()
		Upgrade.UpgradeType.AddSpecificCard, Upgrade.UpgradeType.AddCommonCard, Upgrade.UpgradeType.AddRareCard:
			deck.append(upgrade.card)
		Upgrade.UpgradeType.RemoveSpecificCard:
			deck.erase(upgrade.card)
		Upgrade.UpgradeType.EnergyFragment:
			Global.ENERGY_FRAGMENTS += int(upgrade.strength)
		Upgrade.UpgradeType.CardFragment:
			Global.SCROLL_FRAGMENTS += int(upgrade.strength)
		Upgrade.UpgradeType.GainMoney:
			$UserInterface/Shop.player_money += int(upgrade.strength)
			$UserInterface/Shop.update_labels()
		Upgrade.UpgradeType.LoseMoney:
			$UserInterface/Shop.player_money += int(upgrade.strength)
			$UserInterface/Shop.update_labels()
		Upgrade.UpgradeType.GainBlight:
			$TurnManager.blight_damage += int(upgrade.strength)
			$UserInterface.update_damage()
		Upgrade.UpgradeType.RemoveBlight:
			$TurnManager.blight_damage -= int(upgrade.strength)
			$UserInterface.update_damage()
		Upgrade.UpgradeType.AddEnhance:
			$UserInterface.select_card_to_enhance(upgrade.enhance)
		Upgrade.UpgradeType.AddEnhanceToRandom:
			var cards = []
			for card in deck:
				if upgrade.enhance.is_card_eligible(card):
					cards.append(card)
			cards.shuffle()
			var card = cards[0]
			var new_card = card.apply_enhance(upgrade.enhance.copy())
			deck.erase(card)
			deck.append(new_card)
		Upgrade.UpgradeType.AddEnhanceToAll:
			var old_cards = []
			var new_cards = []
			for card in deck:
				if upgrade.enhance.is_card_eligible(card):
					old_cards.append(card)
					var new_card = card.apply_enhance(upgrade.enhance.copy())
					new_cards.append(new_card)
			for card in old_cards:
				deck.erase(card)
			for card in new_cards:
				deck.append(card)
		_:
			print(upgrade.text)

func on_turn_end():
	$EventManager.notify(EventManager.EventType.BeforeGrow)
	$Cards.discard_hand()
	await get_tree().create_timer(0.3).timeout
	await $FarmTiles.process_one_week()
	await get_tree().create_timer(0.1).timeout
	$EventManager.notify(EventManager.EventType.AfterGrow)
	if victory == true:
		end_year()
		$UserInterface.turn_ending = false
		return
	var damage = $TurnManager.end_turn()
	if damage:
		$UserInterface.update_damage()
		$TurnManager.destroy_blighted_tiles($FarmTiles)
	$EventManager.notify(EventManager.EventType.OnTurnEnd)
	$Cards.draw_hand($TurnManager.get_cards_drawn(), $TurnManager.week)
	
	if $TurnManager.blight_damage >= Constants.MAX_BLIGHT:
		on_lose()
	$TurnManager.set_blight_targeted_tiles($FarmTiles)
	$UserInterface.update()
	await get_tree().create_timer(1).timeout
	$UserInterface.update()
	$UserInterface.turn_ending = false
	$EventManager.notify(EventManager.EventType.BeforeTurnStart)


func _on_user_interface_on_blight_removed() -> void:
	$FarmTiles.remove_blight_from_all_tiles()
