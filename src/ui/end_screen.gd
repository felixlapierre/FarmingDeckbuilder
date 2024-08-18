extends Node2D

@onready var Title = $Panel/VBoxContainer/Title
@onready var Description = $Panel/VBoxContainer/Description
@onready var Stats = $Panel/VBoxContainer/Grid/Stats
@onready var Deck = $Panel/VBoxContainer/Grid/Deck

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
	
func setup(turn_manager: TurnManager, deck: Array[CardData]):
	# Title
	if turn_manager.blight_damage < 5:
		Title.text = "You Win! :)"
		Description.text = "The Blight has been cleansed"
	else:
		Title.text = "You Lose! :("
		Description.text = "Your farm was overtaken by the Blight"
	
	Stats.clear()
	Deck.clear()
	
	Stats.append_text("Year: " + str(turn_manager.year) + "\n")
	Stats.append_text("Week: " + str(turn_manager.week) + "\n")
	Stats.append_text("Damage: " + str(turn_manager.blight_damage) + "\n")
	Stats.append_text("Farm: " + Global.FARM_TYPE + "\n")
	var difficulty = "Easy" if Global.DIFFICULTY == 0 else "Normal"
	Stats.append_text("Difficulty: " + difficulty)
	
	Deck.append_text("Deck: " + "\n")
	var cards = {}
	for card in deck:
		if cards.has(card.name):
			cards[card.name] += 1
		else:
			cards[card.name] = 1
	
	for cardname in cards.keys():
		Deck.append_text(cardname + " x" + str(cards[cardname]) + "\n")
