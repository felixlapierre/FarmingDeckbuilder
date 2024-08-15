extends Node2D

var victory = false

var card_database
var deck: Array[CardData] = []

@onready var turn_manager: TurnManager = $TurnManager
@onready var user_interface: UserInterface = $UserInterface
@onready var background = $Background
@onready var background2 = $Background2

var helper = preload("res://src/farm/startup_helper.gd")

var spring_tileset = preload("res://assets/1616tinygarden/tileset.png")
var summer_tileset = preload("res://assets/1616tinygarden/tileset-summer.png")
var fall_tileset = preload("res://assets/1616tinygarden/tileset-fall.png")
var winter_tileset = preload("res://assets/1616tinygarden/tileset-winter.png")
var winter_night_tileset = preload("res://assets/1616tinygarden/tileset-winter-night.png")

func _ready() -> void:
	randomize()
	card_database = preload("res://src/cards/cards_database.gd")
	$EventManager.setup($FarmTiles, $TurnManager, $Cards)
	$UserInterface.setup($EventManager, $TurnManager, deck)
	$UserInterface.update()
	$FarmTiles.setup($EventManager)
	background2.unique_tileset()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _on_farm_tiles_card_played(card) -> void:
	if card.CLASS_NAME == "Structure":
		Global.selected_structure = null
		await get_tree().create_timer(1).timeout
		$UserInterface.shop_structure_place_callback.call()
		$UserInterface.set_winter_visible(true)
	else:
		$TurnManager.energy -= card.cost if card.cost >= 0 else $TurnManager.energy
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
	if turn_manager.year >= (Global.FINAL_YEAR if Global.DIFFICULTY < Constants.DIFFICULTY_FINAL_RITUAL else Global.FINAL_YEAR + 1):
		on_win()
		return
	$Cards.discard_hand()
	$Cards.do_winter_clear()
	await get_tree().create_timer(1.5).timeout
	
	$Cards.set_cards_visible(false)
	$FarmTiles.do_winter_clear()
	$TurnManager.end_year()
	$UserInterface.end_year()
	set_background_texture()
	save_game()

func start_year():
	victory = false
	$UserInterface.start_year()
	save_game()
	$EventManager.notify(EventManager.EventType.BeforeYearStart)
	$TurnManager.start_new_year()
	$Cards.set_deck_for_year(deck)
	$Cards.draw_hand($TurnManager.get_cards_drawn(), $TurnManager.week)
	$Cards.set_cards_visible(true)
	$UserInterface.update()
	$EventManager.notify(EventManager.EventType.AfterYearStart)
	$EventManager.notify(EventManager.EventType.BeforeTurnStart)
	set_background_texture()

func _on_farm_tiles_on_energy_gained(amount) -> void:
	$TurnManager.energy += amount
	$UserInterface.update()

func on_lose():
	$Cards.discard_hand()
	$Cards.do_winter_clear()
	$UserInterface/UI/EndTurnButton.visible = false
	$UserInterface/GameEndContainer.visible = true
	$UserInterface/GameEndContainer/ResultLabel.text = "You Lose :("
	$UserInterface/UI/Deck.visible = false
	$UserInterface/UI/RitualPanel.visible = false

func on_win():
	$Cards.discard_hand()
	$Cards.do_winter_clear()
	$UserInterface/UI/EndTurnButton.visible = false
	$UserInterface/GameEndContainer.visible = true
	$UserInterface/GameEndContainer/ResultLabel.text = "You Win! The Blight has been cleansed!"
	$UserInterface/UI/Deck.visible = false
	$UserInterface/UI/RitualPanel.visible = false

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
		Upgrade.UpgradeType.AddSpecificCard:
			deck.append(upgrade.card)
			pass
		_:
			print(upgrade.text)

func on_turn_end():
	$EventManager.notify(EventManager.EventType.BeforeGrow)
	$Cards.discard_hand()
	await get_tree().create_timer(0.3).timeout
	await $FarmTiles.process_one_week(turn_manager.week)
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
	
	if $TurnManager.blight_damage >= Constants.MAX_BLIGHT:
		on_lose()
	$TurnManager.set_blight_targeted_tiles($FarmTiles)
	#$UserInterface.update()
	#await get_tree().create_timer(1).timeout
	$UserInterface.update()
	$UserInterface.turn_ending = false
	$Cards.draw_hand($TurnManager.get_cards_drawn(), $TurnManager.week)
	$EventManager.notify(EventManager.EventType.BeforeTurnStart)
	if victory == true:
		end_year()
	set_background_texture()

func _on_user_interface_on_blight_removed() -> void:
	$FarmTiles.remove_blight_from_all_tiles()

func save_game():
	var save_json = {}
	save_json.deck = []
	for card in deck:
		save_json.deck.append(card.save_data())
	
	save_json.structures = []
	for tile in $FarmTiles.get_all_tiles():
		if tile.structure != null:
			save_json.structures.append(tile.structure.save_data())
	
	save_json.state = {
		"year": turn_manager.year,
		"week": turn_manager.week,
		"energy_fragments": Global.ENERGY_FRAGMENTS,
		"draw_fragments": Global.SCROLL_FRAGMENTS,
		"blight": turn_manager.blight_damage,
		"winter": user_interface.is_winter(),
		"difficulty": Global.DIFFICULTY,
		"farm_type": Global.FARM_TYPE,
		"farm_topleft": {
			"x": Global.FARM_TOPLEFT.x,
			"y": Global.FARM_TOPLEFT.y
		},
		"farm_botright": {
			"x": Global.FARM_BOTRIGHT.x,
			"y": Global.FARM_BOTRIGHT.y
		}
	}
	user_interface.save_data(save_json)

	var save_game = FileAccess.open("user://savegame.save", FileAccess.WRITE)
	save_game.store_line(JSON.stringify(save_json))

func load_game():
	if not FileAccess.file_exists("user://savegame.save"):
		return null
	deck.clear()
	var save_game = FileAccess.open("user://savegame.save", FileAccess.READ)
	var save_data = save_game.get_line()
	var json = JSON.new()
	var parse_result = json.parse(save_data)
	if not parse_result == OK:
		print("JSON Parse Error: ", json.get_error_message())
		return
	var save_json = json.get_data()
	for entry in save_json.deck:
		var card = load(entry.path).new();
		card.load_data(entry)
		deck.append(card)
	for data in save_json.structures:
		var structure = load(data.path).new()
		structure.load_data(data)
		$FarmTiles.tiles[data.x][data.y].build_structure(structure, structure.rotate)

	turn_manager.year = int(save_json.state.year)
	turn_manager.week = int(save_json.state.week)
	turn_manager.blight_damage = int(save_json.state.blight)
	Global.ENERGY_FRAGMENTS = int(save_json.state.energy_fragments)
	Global.SCROLL_FRAGMENTS = int(save_json.state.draw_fragments)
	Global.DIFFICULTY = int(save_json.state.difficulty)
	Global.FARM_TYPE = save_json.state.farm_type
	Global.FARM_TOPLEFT = Vector2(save_json.state.farm_topleft.x, save_json.state.farm_topleft.y)
	Global.FARM_BOTRIGHT = Vector2(save_json.state.farm_botright.x, save_json.state.farm_botright.y)

	StartupHelper.load_farm($FarmTiles, $EventManager)
	$UserInterface.load_data(save_json)
	if !save_json.state.winter:
		start_year()

func start_new_game():
	if FileAccess.file_exists("user://savegame.save"):
		DirAccess.remove_absolute("user://savegame.save")
	for card in StartupHelper.get_starter_deck():
		deck.append(card)
	StartupHelper.setup_farm($FarmTiles, $EventManager)
	start_year()

func set_background_texture():
	var old_texture
	var new_texture
	if $UserInterface/Winter.visible == true:
		old_texture = background2.get_background_texture()
		new_texture = spring_tileset
	if turn_manager.week == Global.SPRING_WEEK:
		old_texture = background2.get_background_texture()
		new_texture = spring_tileset
	elif turn_manager.week == Global.SUMMER_WEEK:
		old_texture = spring_tileset
		new_texture = summer_tileset
	elif turn_manager.week == Global.FALL_WEEK:
		old_texture = summer_tileset
		new_texture = fall_tileset
	elif turn_manager.week == Global.WINTER_WEEK:
		old_texture = fall_tileset
		new_texture = winter_tileset
	if new_texture != old_texture:
		background.set_background_texture(old_texture)
		background2.set_background_texture(new_texture)
		background2.tween_to_visible(1.0)
