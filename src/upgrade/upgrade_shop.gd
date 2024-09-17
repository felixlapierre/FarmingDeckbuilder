extends Node2D

signal on_close
signal on_upgrade

var lock = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$Panel.position = Constants.VIEWPORT_SIZE / 2 - $Panel.size / 2
	$Explanation.position = $Panel.position + Vector2($Panel.size.x + 20, $Panel.size.y / 2)
	$Explanation/PCont/MarginCont/Exp.clear()
	$Explanation/PCont/MarginCont/Exp.append_text("[color=gold]Energy Fragment[/color]: Each fragment grants one energy every 1 out of 3 turns\n")
	$Explanation/PCont/MarginCont/Exp.append_text("[color=gold]Card Fragment[/color]: Each fragment grants one extra card draw every 1 out of 3 turns")

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func update():
	$Panel/VBox/ExpandUp.disabled = Global.FARM_TOPLEFT.y <= 0
	$Panel/VBox/ExpandLeft.disabled = Global.FARM_TOPLEFT.x <= 0
	$Panel/VBox/ExpandRight.disabled = Global.FARM_BOTRIGHT.x >= Constants.FARM_DIMENSIONS.x - 1
	$Panel/VBox/ExpandDown.disabled = Global.FARM_BOTRIGHT.y >= Constants.FARM_DIMENSIONS.y - 1

func _on_click_out_button_pressed() -> void:
	on_close.emit()

func expand_up():
	$Panel/VBox/ExpandUp.disabled = true
	on_upgrade.emit(load("res://src/upgrade/data/expand_up.tres"))
	lock = true
	on_close.emit()
	
func expand_down():
	$Panel/VBox/ExpandDown.disabled = true
	on_upgrade.emit(load("res://src/upgrade/data/expand_down.tres"))
	lock = true
	on_close.emit()

func expand_left():
	$Panel/VBox/ExpandLeft.disabled = true
	on_upgrade.emit(load("res://src/upgrade/data/expand_left.tres"))
	lock = true
	on_close.emit()

func expand_right():
	$Panel/VBox/ExpandRight.disabled = true
	on_upgrade.emit(load("res://src/upgrade/data/expand_right.tres"))
	lock = true
	on_close.emit()

func _on_energy_pressed() -> void:
	on_upgrade.emit(load("res://src/upgrade/data/energy_fragment.tres"))
	lock = true
	on_close.emit()

func _on_draw_pressed() -> void:
	on_upgrade.emit(load("res://src/upgrade/data/card_fragment.tres"))
	lock = true
	on_close.emit()


func _on_skip_pressed() -> void:
	on_upgrade.emit(load("res://src/upgrade/data/gain_3_rerolls.tres"))
	lock = true
	on_close.emit()
