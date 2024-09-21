extends Control

signal on_close

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func display_dialogue():
	visible = true
	$Center/Panel/GridContainer/Up.disabled = Global.FARM_TOPLEFT.y <= 0
	$Center/Panel/GridContainer/Left.disabled = Global.FARM_TOPLEFT.x <= 0
	$Center/Panel/GridContainer/Right.disabled = Global.FARM_BOTRIGHT.x >= Constants.FARM_DIMENSIONS.x - 1
	$Center/Panel/GridContainer/Down.disabled = Global.FARM_BOTRIGHT.y >= Constants.FARM_DIMENSIONS.y - 1

func _on_up_pressed() -> void:
	Global.FARM_TOPLEFT.y -= 1
	visible = false
	on_close.emit()

func _on_left_pressed() -> void:
	Global.FARM_TOPLEFT.x -= 1
	visible = false
	on_close.emit()

func _on_right_pressed() -> void:
	Global.FARM_BOTRIGHT.x += 1
	visible = false
	on_close.emit()

func _on_down_pressed() -> void:
	Global.FARM_BOTRIGHT.y += 1
	visible = false
	on_close.emit()
