extends PanelContainer

var FortuneHover = preload("res://src/fortune/fortune_hover.tscn")

# Called when the node enters the scene tree for the first time.
func _ready():
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func setup(week: int, attack: int, fortunes: Array[Fortune]):
	for fortune in $VBox/Attack/Fortunes.get_children():
		$VBox/Attack/Fortunes.remove_child(fortune)
	$VBox/Attack/Turns.text = str(week)
	$VBox/Attack/Attack.clear()
	if attack == 0:
		$VBox/Attack/Attack.append_text("[color=dimgray]")
	$VBox/Attack/Attack.append_text(str(attack))
	$VBox/Attack/AttackImg.visible = attack > 0
	for fortune in fortunes:
		var hover = FortuneHover.instantiate()
		$VBox/Attack/Fortunes.add_child(hover)
		hover.setup(fortune)

func decrement_week():
	var turn = int($VBox/Attack/Turns.text) - 1
	$VBox/Attack/Turns.text = str(turn)
