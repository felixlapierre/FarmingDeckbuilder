extends Node2D

var PLAYSPACE = preload("res://src/playspace.tscn")

var playspace
@onready var tutorial_game = $TutorialGame
@onready var menu_root = $Root
@onready var introduction = $Introduction
@onready var difficulty_options = $Root/Grid/Panel/VBox/Margin/VBox/DifficultyBox/DiffOptions

@onready var Stats = $Root/Grid/ContPanel/VBox/Margin/VBox/Grid/StatsLabel
@onready var Deck = $Root/Grid/ContPanel/VBox/Margin/VBox/Grid/DeckLabel
@onready var ContinueButton = $Root/Grid/ContPanel/VBox/Margin/VBox/ContinueButton
@onready var TutorialsCheck = $Root/Grid/SettingsPanel/Margin/VBox/TutorialsCheck
@onready var DebugCheck = $Root/Grid/SettingsPanel/Margin/VBox/DebugCheck

var difficulty_text = [
	"Base difficulty",
	"Increase [img]res://assets/custom/YellowMana.png[/img] Ritual Target and [img]res://assets/custom/PurpleMana.png[/img] Blight Attack\n", 
	"Blight damaged tiles heal slower\n",
	"Increased misfortune\n",
	"Add Final Ritual on year 11"]

var mage_fortune: MageAbility = load("res://src/fortune/characters/novice.gd").new();

# Called when the node enters the scene tree for the first time.
func _ready():
	populate_continue_preview()
	Settings.load_settings()
	TutorialsCheck.button_pressed = Settings.TUTORIALS_ENABLED
	DebugCheck.button_pressed = Settings.DEBUG

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func _on_diff_options_item_selected(index):
	Global.DIFFICULTY = index

func _on_start_button_pressed():
	menu_root.visible = false
	playspace = PLAYSPACE.instantiate()
	connect_main_menu_signal(playspace)
	add_child(playspace)
	playspace.user_interface.mage_fortune = mage_fortune
	Global.reset()
	playspace.start_new_game()

func _on_continue_button_pressed():
	menu_root.visible = false
	playspace = PLAYSPACE.instantiate()
	connect_main_menu_signal(playspace)
	add_child(playspace)
	Global.reset()
	playspace.load_game()


func _on_type_options_item_selected(index):
	match index:
		0:
			Global.FARM_TYPE = "FOREST"
		1:
			Global.FARM_TYPE = "RIVERLANDS"
		2:
			Global.FARM_TYPE = "WILDERNESS"
		3:
			Global.FARM_TYPE = "MOUNTAINS"

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
	var difficulty = "Easy" if save_json.state.difficulty == 0 else "Normal"
	Stats.append_text("Difficulty: " + difficulty)
	
	#Also preselect options
	$Root/Grid/Panel/VBox/Margin/VBox/DifficultyBox/DiffOptions.selected = save_json.state.difficulty
	_on_diff_options_item_selected(save_json.state.difficulty)
	$Root/Grid/Panel/VBox/Margin/VBox/FarmTypeBox/TypeOptions.selected = get_index_of_farm_type(save_json.state.farm_type)
	_on_type_options_item_selected(get_index_of_farm_type(save_json.state.farm_type))
	if save_json.state.has("mage"):
		$Root/Grid/Panel/VBox/Margin/VBox/CharacterBox/CharOptions.selected = save_json.state.mage.rank
		_on_char_options_item_selected(save_json.state.mage.rank)
	else:
		$Root/Grid/Panel/VBox/Margin/VBox/CharacterBox/CharOptions.selected = 0
		_on_char_options_item_selected(0)

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

func _on_tutorials_check_pressed() -> void:
	Settings.TUTORIALS_ENABLED = TutorialsCheck.button_pressed
	Settings.save_settings()

func _on_debug_check_pressed() -> void:
	Settings.DEBUG = DebugCheck.button_pressed
	Settings.save_settings()


func _on_tutorial_button_pressed():
	menu_root.visible = false
	introduction.visible = true
	Global.FARM_TYPE = "FOREST"

func _on_story_start_button_pressed() -> void:
	introduction.visible = false
	playspace = PLAYSPACE.instantiate()
	playspace.set_script(load("res://src/tutorial/tutorial_game.gd"))
	connect_main_menu_signal(playspace)
	playspace.user_interface.mage_fortune = load("res://src/fortune/characters/blank_mage.gd")
	Global.reset()
	add_child(playspace)
	playspace.start_new_game()

func connect_main_menu_signal(playspace):
	playspace.on_main_menu.connect(func():
		remove_child(playspace)
		menu_root.visible = true
		var difficulty = Global.DIFFICULTY if Global.DIFFICULTY != -1 else 0
		$Root/Grid/Panel/VBox/Margin/VBox/DifficultyBox/DiffOptions.selected = difficulty
		_on_diff_options_item_selected(difficulty)
		$Root/Grid/Panel/VBox/Margin/VBox/FarmTypeBox/TypeOptions.selected = get_index_of_farm_type(Global.FARM_TYPE)
		_on_type_options_item_selected(get_index_of_farm_type(Global.FARM_TYPE))
		)


func _on_char_options_item_selected(index: int) -> void:
	match index:
		0:
			mage_fortune = load("res://src/fortune/characters/novice.gd").new()
		1:
			mage_fortune = load("res://src/fortune/characters/ice_mage.gd").new()
		2:
			mage_fortune = load("res://src/fortune/characters/fire_mage.gd").new()
		3:
			mage_fortune = load("res://src/fortune/characters/blight_mage.gd").new()
		4:
			mage_fortune = load("res://src/fortune/characters/water_mage.gd").new()
		5:
			mage_fortune = load("res://src/fortune/characters/chaos_mage.gd").new()
		6:
			mage_fortune = load("res://src/fortune/characters/lunar_mage.gd").new()
		7:
			mage_fortune = load("res://src/fortune/characters/void_mage.gd").new()
