extends Node2D

var PLAYSPACE = preload("res://src/playspace.tscn")

@onready var playspace = $Playspace
@onready var menu_root = $Root
@onready var difficulty_options = $Root/VBox/Panel/VBox/Margin/VBox/DifficultyBox/DiffOptions
@onready var difficulty_description = $Root/VBox/Panel/VBox/Margin/VBox/DiffDescription

var difficulty_text = [
	"Base difficulty",
	"Increase [img]res://assets/custom/YellowMana.png[/img] Ritual Target and [img]res://assets/custom/PurpleMana.png[/img] Blight Attack\n", 
	"Blight damaged tiles heal slower\n",
	"Increased misfortune\n",
	"Add Final Ritual on year 11"]

# Called when the node enters the scene tree for the first time.
func _ready():
	$Root/VBox/ContinueButton.disabled = not FileAccess.file_exists("user://savegame.save")

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func _on_diff_options_item_selected(index):
	difficulty_description.clear()
	if index == 0:
		difficulty_description.append_text(difficulty_text[0])
	else:
		for i in range(1, index + 1):
			difficulty_description.append_text(difficulty_text[i])


func _on_start_button_pressed():
	menu_root.visible = false
	playspace.visible = true
	playspace.start_new_game()

func _on_continue_button_pressed():
	menu_root.visible = false
	playspace.visible = true
	playspace.load_game()
