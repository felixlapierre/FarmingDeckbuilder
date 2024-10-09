extends Node2D
class_name AttackPreview

@onready var PromptLabel = $CurrentTurn/VBox/PromptLabel
@onready var AmountLabel = $CurrentTurn/VBox/HBox/AmountLabel
@onready var AttackParticles = $CurrentTurn/AttackParticles
@onready var AttackImg = $CurrentTurn/VBox/HBox/Attack
var FutureTurnPreview = preload("res://src/attack/future_turn_preview.tscn")
var FortuneHover = preload("res://src/fortune/fortune_hover.tscn")

var turn_manager: TurnManager
var mage_fortune: Fortune
var attack: AttackPattern

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func setup(p_turn_manager: TurnManager, p_mage_fortune: Fortune, event_manager: EventManager):
	turn_manager = p_turn_manager
	mage_fortune = p_mage_fortune
	event_manager.register_listener(EventManager.EventType.OnTurnEnd, func(args):
		next_week())

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func update():
	AttackParticles.emitting = false
	AttackImg.modulate = Color8(94, 102, 115)
	if turn_manager.target_blight > 0:
		AmountLabel.text = str(turn_manager.purple_mana) + " / " + str(turn_manager.target_blight)
	else:
		AmountLabel.text = str(turn_manager.purple_mana)
	if turn_manager.purple_mana < turn_manager.target_blight:
		PromptLabel.text = "Blight Attack!"
		AttackParticles.emitting = true
		AttackImg.modulate = Color8(255, 255, 255)
	elif turn_manager.purple_mana > turn_manager.target_blight and turn_manager.flag_defer_excess:
		PromptLabel.text = "Defer: " + str(turn_manager.purple_mana - turn_manager.target_blight) + Helper.blue_mana()
	elif turn_manager.purple_mana > turn_manager.target_blight and turn_manager.target_blight == 0 and mage_fortune.name != "Lunar Priest":
		PromptLabel.text = "Wasted"
	elif turn_manager.purple_mana > turn_manager.target_blight and mage_fortune.name == "Lunar Priest":
		PromptLabel.text = "Excess: " + str((turn_manager.purple_mana - turn_manager.target_blight) * mage_fortune.strength) + Helper.mana_icon()
	else:
		PromptLabel.text = "Safe!"

func yield_preview(args):
	var yellow = args.yellow
	var purple = args.purple
	var blightamt = turn_manager.purple_mana + purple
	if purple != 0:
		AmountLabel.text = "[color=9f78e3]"+ str(blightamt) + " / " + str(turn_manager.target_blight)
	else:
		AmountLabel.text = str(turn_manager.purple_mana) + " / " + str(turn_manager.target_blight)


func set_attack(p_attack: AttackPattern):
	if p_attack == null:
		return
	attack = p_attack
	var pattern = attack.get_blight_pattern()
	var fortunes = attack.get_fortunes()
	for child in $NextTurns/List.get_children():
		$NextTurns/List.remove_child(child)
	for i in range(1, Global.FINAL_WEEK):
		var preview = FutureTurnPreview.instantiate()
		preview.setup(i, pattern[i], fortunes[i])
		$NextTurns/List.add_child(preview)
		if (i > 3 if Mastery.HidePreview < 1 else i >= 0):
			preview.visible = false
	update_fortunes(fortunes[0])

func next_week():
	var next = $NextTurns/List.get_child(0)
	$NextTurns/List.remove_child(next)
	var i = 0
	for preview in $NextTurns/List.get_children():
		preview.decrement_week()
		preview.visible = i <= 2 if Mastery.HidePreview < 1 else i == 0
		i += 1
	var fortunes = attack.fortunes[turn_manager.week]
	update_fortunes(fortunes)
	update()

func update_fortunes(fortunes: Array[Fortune]):
	for node in $CurrentTurn/VBox/Fortunes.get_children():
		$CurrentTurn/VBox/Fortunes.remove_child(node)
	for fortune in fortunes:
		var hover = FortuneHover.instantiate()
		$CurrentTurn/VBox/Fortunes.add_child(hover)
		hover.setup(fortune)


func _on_next_turns_mouse_entered():
	if Mastery.HidePreview >= 1: return
	for child in $NextTurns/List.get_children():
		child.visible = true

func _on_next_turns_mouse_exited():
	if Mastery.HidePreview >= 1: return
	for i in range(0, $NextTurns/List.get_child_count()):
		if i > 2:
			$NextTurns/List.get_child(i).visible = false
