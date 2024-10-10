extends Node2D

var PLAYSPACE = preload("res://src/playspace.tscn")

var playspace
@onready var tutorial_game = $TutorialGame
@onready var menu_root = $Root
@onready var introduction = $Introduction
@onready var tutorial_prompt = $TutorialPrompt
@onready var difficulty_options = $Root/HBox/Panel/Margin/VBox/HBox/Margin/VBox/DifficultyBox/DiffOptions

@onready var Stats = $Root/HBox/ContPanel/VBox/Margin/VBox/Grid/StatsLabel
@onready var Deck = $Root/HBox/ContPanel/VBox/Margin/VBox/Grid/DeckLabel
@onready var ContinueButton = $Root/HBox/ContPanel/VBox/Margin/VBox/ContinueButton
@onready var TutorialsCheck = $Root/HBox/SettingsPanel/Margin/VBox/TutorialsCheck
@onready var DebugCheck = $Root/HBox/SettingsPanel/Margin/VBox/DebugCheck

@onready var ViewContinue = $Root/HBox/VBox/ViewContinue
@onready var ViewNewGame = $Root/HBox/VBox/ViewNewGame
@onready var ViewSettings = $Root/HBox/VBox/ViewSettings
@onready var ExitGame = $Root/HBox/VBox/ExitGame

@onready var NewGamePanel = $Root/HBox/Panel
@onready var ContinuePanel = $Root/HBox/ContPanel
@onready var SettingsPanel = $Root/HBox/SettingsPanel

@onready var Prompt = $Root/HBox/Panel/Margin/VBox/HBox/Details/VBox/DetailsPrompt
@onready var DetailsImg = $Root/HBox/Panel/Margin/VBox/HBox/Details/VBox/DetailsImg
@onready var DetailsDescr = $Root/HBox/Panel/Margin/VBox/HBox/Details/VBox/DetailsDescr

@onready var MasteryContainer = $Root/HBox/Panel/Margin/VBox/HBox/Margin/VBox/MasteryCont
@onready var RitualDisruption = $Root/HBox/Panel/Margin/VBox/HBox/Margin/VBox/MasteryCont/RitualDisruption
@onready var BlightAttack = $Root/HBox/Panel/Margin/VBox/HBox/Margin/VBox/MasteryCont/BlightAttack
@onready var Misfortune = $Root/HBox/Panel/Margin/VBox/HBox/Margin/VBox/MasteryCont/Misfortune
@onready var Blindness = $Root/HBox/Panel/Margin/VBox/HBox/Margin/VBox/MasteryCont/Blindness
@onready var LostPages = $"Root/HBox/Panel/Margin/VBox/HBox/Margin/VBox/MasteryCont/Lost Pages"
@onready var Memoria = $Root/HBox/Panel/Margin/VBox/HBox/Margin/VBox/MasteryCont/Memoria

var difficulty_text = [
	"Base difficulty",
	"Increase [img]res://assets/custom/YellowMana.png[/img] Ritual Target and [img]res://assets/custom/PurpleMana.png[/img] Blight Attack\n", 
	"Blight damaged tiles heal slower\n",
	"Increased misfortune\n",
	"Add Final Ritual on year 11"]

var mage_fortune: MageAbility = load("res://src/fortune/characters/novice.gd").new();
var mages_map: Dictionary = {}

# Called when the node enters the scene tree for the first time.
func _ready():
	var mages: OptionButton = $Root/HBox/Panel/Margin/VBox/HBox/Margin/VBox/CharacterBox/CharOptions
	mages.clear()

	for fortune: MageAbility in [
		load("res://src/fortune/characters/novice.gd").new(),
		load("res://src/fortune/characters/ice_mage.gd").new(),
		load("res://src/fortune/characters/water_mage.gd").new(),
		load("res://src/fortune/characters/lunar_mage.gd").new(),
		load("res://src/fortune/characters/blight_mage.gd").new(),
		load("res://src/fortune/characters/chaos_mage.gd").new(),
		load("res://src/fortune/characters/fire_mage.gd").new(),
		load("res://src/fortune/characters/void_mage.gd").new()]:
		mages_map[fortune.rank] = fortune
		$Root/HBox/Panel/Margin/VBox/HBox/Margin/VBox/CharacterBox/CharOptions.add_icon_item(fortune.icon, fortune.name, fortune.rank)
	populate_continue_preview()
	Settings.load_settings()
	Unlocks.load_unlocks()
	TutorialsCheck.button_pressed = Settings.TUTORIALS_ENABLED
	DebugCheck.button_pressed = Settings.DEBUG
	set_locked_options()
	if !Unlocks.TUTORIAL_COMPLETE:
		$Root.visible = false
		$TutorialPrompt.visible = true
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func _on_diff_options_item_selected(index):
	MasteryContainer.visible = false
	match index:
		0:
			Prompt.text = "Difficulty: Easy"
			DetailsImg.texture = load("res://assets/ui/Easy.png")
			DetailsDescr.text = "Base difficulty. Blight is more forgiving"
		1:
			Prompt.text = "Difficulty: Normal"
			DetailsImg.texture = load("res://assets/ui/Normal.png")
			DetailsDescr.text = "Ritual requires more mana to complete. Blight is more dangerous, and blighted tiles heal slower."
		2:
			Prompt.text = "Difficulty: Hard"
			DetailsImg.texture = load("res://assets/ui/Hard.png")
			DetailsDescr.text = "Ritual requires even more mana to complete. Blight is even more dangerous. Blight will use new attacks, and will change attacks from week to week."
		3:
			Prompt.text = "Difficulty: Mastery"
			DetailsImg.texture = load("res://assets/ui/Mastery.png")
			DetailsDescr.text = "Increase the difficulty as much as you can in order to reach new levels of mastery."
			MasteryContainer.visible = true
	Global.DIFFICULTY = index
	update_mastery()

func _on_start_button_pressed():
	menu_root.visible = false
	Global.reset()
	playspace = PLAYSPACE.instantiate()
	connect_main_menu_signal(playspace)
	add_child(playspace)
	playspace.user_interface.set_mage_fortune(mage_fortune)
	if Global.DIFFICULTY < 3:
		Mastery.reset()
	playspace.start_new_game()

func _on_continue_button_pressed():
	menu_root.visible = false
	Global.reset()
	playspace = PLAYSPACE.instantiate()
	connect_main_menu_signal(playspace)
	add_child(playspace)
	playspace.load_game()


func _on_type_options_item_selected(index):
	match index:
		0:
			Global.FARM_TYPE = "FOREST"
			Prompt.text = "Farm Type: Forest"
			DetailsImg.texture = load("res://assets/mage/forest.png")
			DetailsDescr.text = "Basic farm, with no special effects."
		1:
			Global.FARM_TYPE = "RIVERLANDS"
			Prompt.text = "Farm Type: Riverlands"
			DetailsImg.texture = load("res://assets/mage/riverlands.png")
			DetailsDescr.text = "A farm with ponds that take up space but water nearby plants."
		2:
			Global.FARM_TYPE = "WILDERNESS"
			Prompt.text = "Farm Type: Wilderness"
			DetailsImg.texture = load("res://assets/mage/wilderness.png")
			DetailsDescr.text = "Start with seeds already planted on the farm. Starting deck has no Seed cards. You cannot add Seed cards to your deck."
		3:
			Global.FARM_TYPE = "MOUNTAINS"
			Prompt.text = "Farm Type: Mountains"
			DetailsImg.texture = load("res://assets/fortune/mountains.png")
			DetailsDescr.text = "A very small farm. Good luck!"

func get_index_of_farm_type(type):
	match type:
		"FOREST":
			return 0
		"RIVERLANDS":
			return 1
		"WILDERNESS":
			return 2
		"MOUNTAINS":
			return 3

func populate_continue_preview():
	if not FileAccess.file_exists("user://savegame.save"):
		ContinueButton.disabled = true
		ContinuePanel.visible = false
		NewGamePanel.visible = true
		ViewContinue.disabled = false
		ViewNewGame.disabled = true
		MasteryContainer.visible = false
		return
	ContinueButton.text = "Load Saved Game"
	var save_game = FileAccess.open("user://savegame.save", FileAccess.READ)
	var save_data = save_game.get_line()
	var json = JSON.new()
	var parse_result = json.parse(save_data)
	if not parse_result == OK:
		print("JSON Parse Error: ", json.get_error_message())
		return
	var save_json = json.get_data()

	Stats.clear()
	Deck.clear()
	
	Stats.append_text("Year: " + str(save_json.state.year) + "\n")
	Stats.append_text("Week: " + str(save_json.state.week) + "\n")
	Stats.append_text("Damage: " + str(save_json.state.blight) + "\n")
	Stats.append_text("Farm: " + str(save_json.state.farm_type) + "\n")
	
	#Also preselect options
	$Root/HBox/Panel/Margin/VBox/HBox/Margin/VBox/DifficultyBox/DiffOptions.selected = save_json.state.difficulty
	_on_diff_options_item_selected(save_json.state.difficulty)
	$Root/HBox/Panel/Margin/VBox/HBox/Margin/VBox/FarmTypeBox/TypeOptions.selected = get_index_of_farm_type(save_json.state.farm_type)
	_on_type_options_item_selected(get_index_of_farm_type(save_json.state.farm_type))
	if save_json.state.has("mage"):
		$Root/HBox/Panel/Margin/VBox/HBox/Margin/VBox/CharacterBox/CharOptions.selected = save_json.state.mage.rank
		_on_char_options_item_selected(save_json.state.mage.rank)
		$Root/HBox/ContPanel/VBox/Margin/VBox/Grid/StatsLabel.append_text("Character: " + save_json.state.mage.name + " ")
	else:
		$Root/HBox/Panel/Margin/VBox/HBox/Margin/VBox/CharacterBox/CharOptions.selected = 0
		_on_char_options_item_selected(0)

	var difficulty
	Mastery.load_data(save_json.mastery)
	match int(save_json.state.difficulty):
		0:
			difficulty = "Easy"
		1:
			difficulty = "Normal"
		2:
			difficulty = "Hard"
		3:
			difficulty = "Mastery " + str(Mastery.get_total_mastery())
			$Root/HBox/Panel/Margin/VBox/HBox/Margin/VBox/MasteryCont.visible = true
	Stats.append_text("Difficulty: " + difficulty)
	Deck.append_text("Deck: " + "\n")
	var cards = {}
	for card in save_json.deck:
		if cards.has(card.name):
			cards[card.name] += 1
		else:
			cards[card.name] = 1
	
	for cardname in cards.keys():
		Deck.append_text(cardname + " x" + str(cards[cardname]) + "\n")
	
	if save_json.structures.size() > 0:
		Deck.append_text("\n")
		Deck.append_text("Structures: \n")
		var structures = {}
		for structure in save_json.structures:
			if structures.has(structure.name):
				structures[structure.name] += 1
			else:
				structures[structure.name] = 1
		for structurename in structures.keys():
			Deck.append_text(structurename + " x" + str(structures[structurename]) + "\n")
	
	# Populate mastery
	RitualDisruption.value = Mastery.RitualTarget
	RitualDisruption.update_value()
	BlightAttack.value = Mastery.BlightAttack
	BlightAttack.update_value()
	Misfortune.value = Mastery.Misfortune
	Misfortune.update_value()
	Blindness.value = Mastery.HidePreview
	Blindness.update_value()
	LostPages.value = Mastery.BlockShop
	LostPages.update_value()
	Memoria.value = Mastery.CardRemoveCost
	Memoria.update_value()
	update_mastery()
	
func _on_tutorials_check_pressed() -> void:
	Settings.TUTORIALS_ENABLED = TutorialsCheck.button_pressed
	Settings.save_settings()

func _on_debug_check_pressed() -> void:
	Settings.DEBUG = DebugCheck.button_pressed
	Settings.save_settings()
	set_locked_options()


func _on_tutorial_button_pressed():
	menu_root.visible = false
	tutorial_prompt.visible = false
	introduction.visible = true
	Global.FARM_TYPE = "FOREST"

func _on_story_start_button_pressed() -> void:
	introduction.visible = false
	Global.reset()
	playspace = PLAYSPACE.instantiate()
	playspace.set_script(load("res://src/tutorial/tutorial_game.gd"))
	connect_main_menu_signal(playspace)
	add_child(playspace)
	playspace.user_interface.set_mage_fortune(load("res://src/fortune/characters/blank_mage.gd").new())
	if Global.DIFFICULTY < 3:
		Mastery.reset()
	playspace.start_new_game()

func connect_main_menu_signal(playspace):
	playspace.on_main_menu.connect(func():
		remove_child(playspace)
		menu_root.visible = true
		var difficulty = Global.DIFFICULTY if Global.DIFFICULTY != -1 else 0
		$Root/HBox/Panel/Margin/VBox/HBox/Margin/VBox/DifficultyBox/DiffOptions.selected = difficulty
		_on_diff_options_item_selected(difficulty)
		$Root/HBox/Panel/Margin/VBox/HBox/Margin/VBox/FarmTypeBox/TypeOptions.selected = get_index_of_farm_type(Global.FARM_TYPE)
		_on_type_options_item_selected(get_index_of_farm_type(Global.FARM_TYPE))
		set_locked_options()
		populate_continue_preview()
		reset_tabs()
		_on_view_continue_pressed()
		update_mastery()
		)


func _on_char_options_item_selected(index: int) -> void:
	mage_fortune = mages_map[index]
	Prompt.text = mage_fortune.name
	DetailsImg.texture = mage_fortune.texture
	DetailsDescr.text = mage_fortune.text

func set_locked_options():
	var farms = Unlocks.FARMS_UNLOCKED
	for i in range(4):
		$Root/HBox/Panel/Margin/VBox/HBox/Margin/VBox/FarmTypeBox/TypeOptions.set_item_disabled(i, !Settings.DEBUG && !Unlocks.FARMS_UNLOCKED[str(i)])
	for i in range(4):
		$Root/HBox/Panel/Margin/VBox/HBox/Margin/VBox/DifficultyBox/DiffOptions.set_item_disabled(i, !Settings.DEBUG && !Unlocks.DIFFICULTIES_UNLOCKED[str(i)])
	for i in range(8):
		$Root/HBox/Panel/Margin/VBox/HBox/Margin/VBox/CharacterBox/CharOptions.set_item_disabled(i, !Settings.DEBUG && !Unlocks.MAGES_UNLOCKED[str(i)])


func _on_no_button_pressed() -> void:
	tutorial_prompt.visible = false
	menu_root.visible = true
	Unlocks.TUTORIAL_COMPLETE = true
	Unlocks.save_unlocks()

func reset_tabs():
	for button: Button in [ViewContinue, ViewNewGame, ViewSettings, ExitGame]:
		button.disabled = false
	for panel: PanelContainer in [NewGamePanel, ContinuePanel, SettingsPanel]:
		panel.visible = false

func _on_view_continue_pressed():
	reset_tabs()
	ViewContinue.disabled = true
	ContinuePanel.visible = true


func _on_view_new_game_pressed():
	reset_tabs()
	ViewNewGame.disabled = true
	NewGamePanel.visible = true


func _on_view_settings_pressed():
	reset_tabs()
	ViewSettings.disabled = true
	SettingsPanel.visible = true


func _on_exit_game_pressed():
	pass # Replace with function body.

func update_mastery():
	$Root/HBox/Panel/Margin/VBox/HBox/Margin/VBox/MasteryCont/MasteryLevel.text = "Mastery Level: " + str(Mastery.get_total_mastery())
	$Root/HBox/Panel/Margin/VBox/StartButton.disabled = Mastery.get_total_mastery() == 0 and Global.DIFFICULTY == 3

func _on_ritual_disruption_on_value_updated(value: int):
	Mastery.RitualTarget = value
	update_mastery()
	update_prompt("Mastery: Disruption", load("res://assets/custom/YellowMana.png"), "Each level increases mana required to complete the ritual")

func _on_blight_attack_on_value_updated(value: int):
	Mastery.BlightAttack = value
	update_mastery()
	update_prompt("Mastery: Blight Attack", load("res://assets/custom/BlightAttack.png"), "Each level increases the strength of the Blight's attacks")

func _on_misfortune_on_value_updated(value: int):
	Mastery.Misfortune = value
	update_mastery()
	update_prompt("Mastery: Misfortune", load("res://assets/fortune/CounterFortune.png"), "The Blight's special attacks will be more disruptive")

func _on_blindness_on_value_updated(value: int):
	Mastery.HidePreview = value
	update_mastery()
	update_prompt("Mastery: Blindness", load("res://assets/custom/Temp.png"), "Blight attack preview will only show the next turn.")

func _on_lost_pages_on_value_updated(value: int):
	Mastery.BlockShop = value
	update_prompt("Mastery: Lost Pages", load("res://assets/custom/CardFragment.png"), "Each level reduces the amount of options available in the shop")
	update_mastery()

func _on_memoria_on_value_updated(value: int):
	Mastery.CardRemoveCost = value
	update_prompt("Mastery: Memoria", load("res://assets/enhance/obliviate.png"), "Removing a card from your deck will cost rerolls")
	update_mastery()

func update_prompt(title: String, image: Texture2D, description: String):
	$Root/HBox/Panel/Margin/VBox/HBox/Details/VBox/DetailsPrompt.text = title
	$Root/HBox/Panel/Margin/VBox/HBox/Details/VBox/DetailsImg.texture = image
	$Root/HBox/Panel/Margin/VBox/HBox/Details/VBox/DetailsDescr.text = description
