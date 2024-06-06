extends Node2D

signal on_close
signal on_upgrade

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$Panel.position = Constants.VIEWPORT_SIZE / 2 - $Panel.size / 2

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _on_click_out_button_pressed() -> void:
	on_close.emit()

func expand_up():
	on_upgrade.emit(Upgrade.new("expand", 0, null, null))
	on_close.emit()
	
func expand_down():
	on_upgrade.emit(Upgrade.new("expand", 2, null, null))
	on_close.emit()

func expand_left():
	on_upgrade.emit(Upgrade.new("expand", 3, null, null))
	on_close.emit()

func expand_right():
	on_upgrade.emit(Upgrade.new("expand", 1, null, null))
	on_close.emit()
