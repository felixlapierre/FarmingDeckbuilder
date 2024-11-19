extends Node2D

var spring1 = Color8(199, 183, 101)
var spring2 = Color8(161, 199, 101)
var summer = Color8(67, 163, 84)
var fall = Color8(186, 199, 101)
var winter = Color8(226, 226, 226)

var ground_tween_time = 1.0

var trees = []
var snows = []

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$Ground.modulate = spring1
	$Ground.visible = true
	trees = [$Tree, $Tree2, $Tree3]
	snows = [$Snow1, $Snow2, $Snow3, $Snow4, $Snow5]

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func do_week(week: int):
	do_ground(week)
	do_trees(week)
	do_snow(week)
	pass
	
func do_snow(week: int):
	var animation = null
	match week:
		1:
			animation = "spring1"
		2:
			animation = "spring2"
		13:
			animation = "winter"
	if animation != null:
		for snow in snows:
			snow.play(animation)

func do_winter(current_week: int):
	do_ground(13)
	var animation = "skip-spring1"
	var tween = create_tween()
	match current_week:
		1:
			animation = "skip-spring1"
			tween.tween_property($Ground, "modulate", spring2, 0.5)
			tween.tween_property($Ground, "modulate", summer, 0.5)
			tween.tween_property($Ground, "modulate", fall, 0.5)
			tween.tween_property($Ground, "modulate", winter, 0.5)
		2:
			animation = "skip-spring2"
			tween.tween_property($Ground, "modulate", summer, 0.5)
			tween.tween_property($Ground, "modulate", fall, 0.5)
			tween.tween_property($Ground, "modulate", winter, 0.5)
		3, 4, 5, 6, 7, 8, 9:
			animation = "skip-summer"
			tween.tween_property($Ground, "modulate", fall, 0.5)
			tween.tween_property($Ground, "modulate", winter, 0.5)
		10, 11, 12:
			animation = "winter"
			tween.tween_property($Ground, "modulate", winter, 1.0)
		_:
			animation = "winter2"
			$Ground.modulate = winter
	if current_week <= 12:
		tween.tween_callback(func(): do_snow(13))
	for tree in trees:
		tree.play(animation)

func load_winter():
	$Ground.modulate = winter
	for tree in trees:
		tree.play("winter2")

func do_trees(week: int):
	var animation = null
	match week:
		1:
			animation = "spring1"
		2:
			animation = "spring2"
		3:
			animation = "summer"
		9:
			animation = "pre-fall"
		10:
			animation = "fall"
		12:
			animation = "pre-winter"
		13:
			animation = "winter"
	if animation != null:
		for tree in trees:
			tree.play(animation)
	pass

func do_ground(week: int):
	var color = spring1
	match week:
		1:
			color = spring1
		2:
			color = spring2
		3, 4, 5, 6, 7, 8, 9:
			color = summer
		10, 11, 12:
			color = fall
		_:
			color = winter
	var tween = create_tween()
	tween.tween_property($Ground, "modulate", color, ground_tween_time)

func set_background_texture(texture: Texture2D):
	if texture != null:
		var tileset: TileSet = $TileMap.tile_set
		var src: TileSetAtlasSource = tileset.get_source(0)
		src.texture = texture
