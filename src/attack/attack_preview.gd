extends Node2D
class_name AttackPreview

@onready var PromptLabel = $CurrentTurn/VBox/PromptLabel
@onready var AmountLabel = $CurrentTurn/VBox/HBox/AmountLabel
@onready var AttackParticles = $CurrentTurn/AttackParticles

var FutureTurnPreview = preload("res://src/attack/future_turn_preview.tscn")
var FortuneHover = preload("res://src/fortune/fortune_hover.tscn")

var turn_manager: TurnManager
var mage_fortune: Fortune
var attack: AttackPattern

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func setup(p_turn_manager: TurnManager, p_mage_fortune: Fortune):
	turn_manager = p_turn_manager

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func update():
	AttackParticles.emitting = false
	if turn_manager.target_blight > 0:
		AmountLabel.text = str(turn_manager.purple_mana) + " / " + str(turn_manager.target_blight) + " [img]res://assets/custom/PurpleMana.png[/img]"
	else:
		AmountLabel.text = str(turn_manager.purple_mana) + "[img]res://assets/custom/PurpleMana.png[/img]"
	if turn_manager.purple_mana < turn_manager.target_blight:
		PromptLabel.text = "Blight Attack!"
		AttackParticles.emitting = true
	elif turn_manager.purple_mana > turn_manager.target_blight and turn_manager.flag_defer_excess:
		PromptLabel.text = "Defer: " + str(turn_manager.purple_mana - turn_manager.target_blight) + Helper.blue_mana()
	elif turn_manager.purple_mana > turn_manager.target_blight and turn_manager.target_blight == 0 and mage_fortune.name != "Lunar Priest":
		PromptLabel.text = "Wasted"
	elif turn_manager.purple_mana > turn_manager.target_blight and mage_fortune.name == "Lunar Priest":
		PromptLabel.text = "Excess: " + str((turn_manager.purple_mana - turn_manager.target_blight) * mage_fortune.strength) + Helper.mana_icon()
	else:
		PromptLabel.text = "Safe!"

func set_attack(p_attack: AttackPattern):
	attack = p_attack
	var pattern = attack.get_blight_pattern()
	var fortunes = attack.get_fortunes()
	for i in range(1, Global.FINAL_WEEK):
		var preview = FutureTurnPreview.instantiate()
		preview.setup(i, pattern[i], fortunes[i])
		$NextTurns/List.add_child(preview)
	update_fortunes(fortunes[0])

func next_week():
	var next = $NextTurns/List.get_child(0)
	$NextTurns/List.remove_child(next)
	var fortunes = attack.fortunes[turn_manager.week]
	update_fortunes(fortunes)
	update()

func update_fortunes(fortunes: Array[Fortune]):
	for node in $CurrentTurn/VBox/Fortunes.get_children():
		$CurrentTurn/VBox/Fortunes.remove_child(node)
	for fortune in fortunes:
		var hover = FortuneHover.instantiate()
		hover.setup(fortune)
		$CurrentTurn/VBox/Fortunes.add_child(hover)
	
