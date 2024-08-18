extends Node2D

var PLAYSPACE = preload("res://src/playspace.tscn")

@onready var playspace = $Playspace
@onready var menu_root = $Root
@onready var difficulty_options = $Root/Grid/Panel/VBox/Margin/VBox/DifficultyBox/DiffOptions
@onready var difficulty_description = $Root/Grid/Panel/VBox/Margin/VBox/DiffDescription

@onready var Stats = $Root/Grid/ContPanel/VBox/Margin/VBox/Grid/StatsLabel
@onready var Deck = $Root/Grid/ContPanel/VBox/Margin/VBox/Grid/DeckLabel
@onready var ContinueButton = $Root/Grid/ContPanel/VBox/Margin/VBox/ContinueButton

var difficulty_text = [
	"Base difficulty",
	"Increase [img]res://assets/custom/YellowMana.png[/img] Ritual Target and [img]res://assets/custom/PurpleMana.png[/img] Blight Attack\n", 
	"Blight damaged tiles heal slower\n",
	"Increased misfortune\n",
	"Add Final Ritual on year 11"]

# Called when the node enters the scene tree for the first time.
func _ready():
	populate_continue_preview()
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func _on_diff_options_item_selected(index):
	Global.DIFFICULTY = index


func _on_start_button_pressed():
	menu_root.visible = false
	playspace.visible = true
	playspace.start_new_game()

func _on_continue_button_pressed():
	menu_root.visible = false
	playspace.visible = true
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

func populate_continue_preview():
	if not FileAccess.file_exists("user://savegame.save"):
		ContinueButton.disabled = true
		return
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
	
	Deck.append_text("Deck: " + "\n")
	var cards = {}
	for card in save_json.deck:
		if cards.has(card.name):
			cards[card.name] += 1
		else:
			cards[card.name] = 1
	
	for cardname in cards.keys():
		Deck.append_text(cardname + " x" + str(cards[cardname]) + "\n")
