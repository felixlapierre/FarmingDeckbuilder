extends PanelContainer

var FortuneHover = preload("res://src/fortune/fortune_hover.tscn")

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func setup(week: int, attack: int, fortunes: Array[Fortune]):
	$VBox/Attack/Turns.text = str(week)
	$VBox/Attack/Attack.clear()
	$VBox/Attack/Attack.append_text(str(attack))
	for fortune in fortunes:
		var hover = FortuneHover.instantiate()
		hover.setup(fortune)
		$VBox/Attack/Fortunes.add_child(hover)
