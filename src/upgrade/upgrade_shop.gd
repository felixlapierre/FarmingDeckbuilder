extends Node2D

signal on_close
signal on_upgrade

var lock = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$Panel.position = Constants.VIEWPORT_SIZE / 2 - $Panel.size / 2

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

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
	Global.ENERGY_FRAGMENTS += 1
	lock = true
	on_close.emit()

func _on_draw_pressed() -> void:
	Global.SCROLL_FRAGMENTS += 1
	lock = true
	on_close.emit()


func _on_skip_pressed() -> void:
	# TODO gain balance
	lock = true
	on_close.emit()
