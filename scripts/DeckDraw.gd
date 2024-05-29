extends TextureButton

var Decksize = INF

var CardSize = Vector2(250, 350)
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _gui_input(event: InputEvent):
	if Input.is_action_just_released("leftclick"):
		if Decksize > 0:
			Decksize = $'../../Cards/'.draw_one_card()
			if Decksize == 0:
				disabled = true
