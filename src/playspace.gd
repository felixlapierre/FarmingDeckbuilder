extends Node2D
class_name Playspace

var victory = false

var card_database
var deck: Array[CardData] = []

signal on_main_menu

@onready var turn_manager: TurnManager = $TurnManager
@onready var user_interface: UserInterface = $UserInterface
@onready var background = $Background
@onready var farm: Farm = $FarmTiles
@onready var cards: Cards = $Cards
@onready var event_manager: EventManager = $EventManager

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
	$UserInterface.setup($EventManager, $TurnManager, deck, $Cards)
	$UserInterface.update()
	$FarmTiles.setup($EventManager)
	$TurnManager.setup($EventManager)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if Global.pressed:
		Global.pressed_time += delta
	else:
		Global.pressed_time = 0.0

func _on_farm_tiles_card_played(card) -> void:
	if card.CLASS_NAME == "Structure":
		Global.selected_structure = null
		await $UserInterface.shop_structure_place_callback.call()
		$UserInterface.set_winter_visible(true)
	else:
		$TurnManager.energy -= card.cost if card.cost >= 0 else $TurnManager.energy
		$Cards.play_card()
		$UserInterface.update()
		if victory == true:
			end_year(false)

func _on_farm_tiles_on_yield_gained(args: EventArgs.HarvestArgs) -> void:
	if args.purple:
		$TurnManager.gain_purple_mana(args.yld, args.delay)
	else:
		var ritual_complete = $TurnManager.gain_yellow_mana(args.yld, args.delay)
		if ritual_complete:
			victory = true
	$UserInterface.update()

func _input(event: InputEvent) -> void:
	if event is InputEventScreenTouch:
		Global.MOBILE = true
	if event is InputEventMouseButton and event.pressed:
		Global.notify_click_callback()
	if event.is_action_pressed("transform"):
		Global.shape = (Global.shape + 1) % 3
	elif event.is_action_pressed("rotate"):
		Global.rotate = (Global.rotate + 1) % 4
	elif event.is_action_pressed("flip"):
		Global.flip = (Global.flip + 1) % 2
	
func end_year(endless: bool):
	if turn_manager.year == Global.FINAL_YEAR and !endless:
		on_win()
		return
	$Cards.discard_hand()
	$Cards.do_winter_clear()
	$UserInterface.before_end_year()
	await get_tree().create_timer(0.5 if Settings.DEBUG else 3).timeout

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
	turn_manager.start_new_year();
	$EventManager.notify(EventManager.EventType.BeforeYearStart)
	$Cards.set_deck_for_year(deck)
	$Cards.draw_hand($TurnManager.get_cards_drawn(), $TurnManager.week)
	$Cards.set_cards_visible(true)
	$EventManager.notify(EventManager.EventType.AfterYearStart)
	$EventManager.notify(EventManager.EventType.BeforeTurnStart)
	$UserInterface.update()
	set_background_texture()

func _on_farm_tiles_on_energy_gained(amount) -> void:
	$TurnManager.energy += amount
	$UserInterface.update()

func on_lose():
	$Cards.discard_hand()
	$Cards.do_winter_clear()
	$UserInterface/UI/EndTurnButton.visible = false
	$UserInterface/EndScreen.visible = true
	$UserInterface/EndScreen.setup(turn_manager, deck, $FarmTiles)
	$UserInterface/EndScreen.do_unlocks(turn_manager, deck)
	$UserInterface/UI/Deck.visible = false
	$UserInterface/UI/RitualPanel.visible = false

func on_win():
	$Cards.discard_hand()
	$Cards.do_winter_clear()
	$UserInterface/UI/EndTurnButton.visible = false
	$UserInterface/EndScreen.visible = true
	$UserInterface/EndScreen.setup(turn_manager, deck, $FarmTiles)
	$UserInterface/EndScreen.do_unlocks(turn_manager, deck)
	$UserInterface/EndScreen.on_endless_mode.connect(func(): on_endless())
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
			$UserInterface.on_expand_farm()
		Upgrade.UpgradeType.RemoveAnyCard:
			$UserInterface.select_card_to_remove()
		Upgrade.UpgradeType.CopyAnyCard:
			$UserInterface.select_card_to_copy()
		Upgrade.UpgradeType.RemoveSpecificCard:
			deck.erase(upgrade.card)
		Upgrade.UpgradeType.EnergyFragment:
			Global.ENERGY_FRAGMENTS += int(upgrade.strength)
			user_interface.create_fortune_display()
		Upgrade.UpgradeType.CardFragment:
			Global.SCROLL_FRAGMENTS += int(upgrade.strength)
			user_interface.create_fortune_display()
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
	if Global.END_TURN_DISCARD:
		$Cards.discard_hand()
	else:
		$Cards.remove_fleeting()
		$Cards.unselect_current_card()
	await get_tree().create_timer(0.3).timeout
	await $FarmTiles.process_one_week(turn_manager.week)
	await get_tree().create_timer(0.1).timeout
	$EventManager.notify(EventManager.EventType.AfterGrow)
	if victory == true:
		end_year(false)
		$UserInterface.turn_ending = false
		return
	$EventManager.notify(EventManager.EventType.OnTurnEnd)
	var damage = $TurnManager.end_turn()
	if damage:
		$UserInterface.update_damage()
		$TurnManager.set_blight_targeted_tiles($FarmTiles)
		$TurnManager.destroy_blighted_tiles($FarmTiles)
	
	if $TurnManager.blight_damage >= Constants.MAX_BLIGHT:
		on_lose()
	#$UserInterface.update()
	#await get_tree().create_timer(1).timeout
	$UserInterface.turn_ending = false
	$Cards.draw_hand($TurnManager.get_cards_drawn(), $TurnManager.week)
	$EventManager.notify(EventManager.EventType.BeforeTurnStart)
	if victory == true:
		end_year(false)
	set_background_texture()
	$UserInterface.update()

func _on_user_interface_on_blight_removed() -> void:
	$FarmTiles.remove_blight_from_all_tiles()

func save_game():
	var save_json = {}
	save_json.deck = []
	for card in deck:
		save_json.deck.append(card.save_data())
	
	save_json.structures = []
	save_json.blight_tiles = []
	for tile: Tile in $FarmTiles.get_all_tiles():
		if tile.structure != null:
			save_json.structures.append(tile.structure.save_data())
		if tile.blighted:
			save_json.blight_tiles.append({
				"x": tile.grid_location.x,
				"y": tile.grid_location.y
			})
	
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
	save_json.mastery = Mastery.save_data()
	save_json.misc = {
		"wilderness_plant": Global.WILDERNESS_PLANT.save_data() if Global.WILDERNESS_PLANT != null else null
	}

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
	for data in save_json.blight_tiles:
		$FarmTiles.tiles[data.x][data.y].set_blighted()

	turn_manager.year = int(save_json.state.year)
	turn_manager.week = int(save_json.state.week)
	turn_manager.blight_damage = int(save_json.state.blight)
	Global.ENERGY_FRAGMENTS = int(save_json.state.energy_fragments)
	Global.SCROLL_FRAGMENTS = int(save_json.state.draw_fragments)
	Global.DIFFICULTY = int(save_json.state.difficulty)
	Global.FARM_TYPE = save_json.state.farm_type
	Global.FARM_TOPLEFT = Vector2(save_json.state.farm_topleft.x, save_json.state.farm_topleft.y)
	Global.FARM_BOTRIGHT = Vector2(save_json.state.farm_botright.x, save_json.state.farm_botright.y)

	Mastery.load_data(save_json.mastery)
	if save_json.misc.wilderness_plant != null:
		Global.WILDERNESS_PLANT = load(save_json.misc.wilderness_plant.path).new()
		Global.WILDERNESS_PLANT.load_data(save_json.misc.wilderness_plant)

	StartupHelper.load_farm($FarmTiles, $EventManager)
	$UserInterface.load_data(save_json)
	user_interface.mage_fortune.register_fortune($EventManager)
	if !save_json.state.winter:
		start_year()

func start_new_game():
	if FileAccess.file_exists("user://savegame.save"):
		DirAccess.remove_absolute("user://savegame.save")
	for card in StartupHelper.get_starter_deck():
		deck.append(card)
	user_interface.mage_fortune.modify_deck_callback.call(deck)
	StartupHelper.setup_farm($FarmTiles, $EventManager)
	user_interface.mage_fortune.register_fortune($EventManager)
	start_year()

func set_background_texture():
	var texture
	if $UserInterface/Winter.visible == true:
		texture = spring_tileset
	if turn_manager.week == Global.SPRING_WEEK:
		texture = spring_tileset
	elif turn_manager.week == Global.SUMMER_WEEK:
		texture = summer_tileset
	elif turn_manager.week == Global.FALL_WEEK:
		texture = fall_tileset
	elif turn_manager.week == Global.WINTER_WEEK:
		texture = winter_tileset
	background.set_background_texture(texture)


func _on_farm_tiles_try_move_structure(tile: Tile) -> void:
	$UserInterface.try_move_structure(tile)

func _on_user_interface_on_main_menu() -> void:
	on_main_menu.emit()

func on_endless():
	$UserInterface/EndScreen.visible = false
	$UserInterface/UI/EndTurnButton.visible = true
	$UserInterface/UI/Deck.visible = true
	$UserInterface/UI/RitualPanel.visible = true
	end_year(true)


func _on_cards_on_card_clicked():
	if Settings.CLICK_MODE and Global.selected_card != null and Global.selected_card.size < 1:
		await get_tree().create_timer(0.1).timeout
		$FarmTiles.hovered_tile = $FarmTiles.tiles[2][2]
		$FarmTiles.show_select_overlay()
