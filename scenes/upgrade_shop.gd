extends Node2D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$Panel.position = Constants.VIEWPORT_SIZE / 2 - $Panel.size / 2

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
