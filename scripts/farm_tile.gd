extends MarginContainer

var state = Constants.TileState.Empty # Store the state of the farm tile
var grid_location: Vector2
var TILE_SIZE = Vector2(56, 56);
var FARM_DIMENSIONS = Vector2(6, 6);
var objects_image = "res://assets/1616tinygarden/objects.png"

var seed = null # To contain information about the seed being grown here

var seed_base_yield
var seed_grow_time
var current_yield
var current_grow_progress
var current_multiplier = 1.0
var irrigated = false
var IRRIGATED_MULTIPLIER = 0.4

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _on_tile_button_mouse_entered() -> void:
	$"../../".on_tile_hover(grid_location)

func _on_tile_button_mouse_exited() -> void:
	$"../../".clear_overlay()

func _on_tile_button_gui_input(event: InputEvent) -> void:
	if event.is_action_pressed("leftclick"):
		$"../../".use_card(Global.selected_card, grid_location)

func plant_seed_animate(planted_seed):
	plant_seed(planted_seed)
	$PlantSprite.scale = Vector2(0, 0)
	var tween = get_tree().create_tween()
	tween.tween_property($PlantSprite, "scale", Vector2(1, 1), 0.1);

func plant_seed(planted_seed):
	if state != Constants.TileState.Empty:
		return
	seed = planted_seed
	seed_grow_time = float(seed.time)
	seed_base_yield = float(seed.yield)
	current_grow_progress = 0.0
	current_yield = 0.0
	state = Constants.TileState.Growing
	$PlantSprite.visible = true
	$PlantSprite.texture = load(objects_image)
	$PlantSprite.region_enabled = true
	update_plant_sprite()
	
func grow_one_week():
	if state == Constants.TileState.Growing:
		current_grow_progress += 1.0
		current_yield += seed_base_yield / seed_grow_time * current_multiplier
		current_multiplier = 1.0
		if irrigated:
			current_multiplier += IRRIGATED_MULTIPLIER
		update_plant_sprite()
		grow_animation()
		if current_grow_progress == seed_grow_time:
			state = Constants.TileState.Mature

func grow_animation():
	var tween = get_tree().create_tween()
	tween.tween_property($PlantSprite, "scale", Vector2(0.8, 1.2), 0.1)
	tween.tween_property($PlantSprite, "scale", Vector2(1, 1), 0.1)

func update_plant_sprite():
	var stage = int(current_grow_progress / seed_grow_time * 3)
	var y
	var h
	match stage:
		0:
			y = 32
			h = 16
		1:
			h = 16
			y = 48
		2:
			y = 64
			h = 32
		3:
			y = 96
			h = 32
		
	$PlantSprite.set_region_rect(Rect2(seed.texture * 16, y, 16, h))
	$PlantSprite.offset = Vector2(0, -8 if h == 16 else -14)

func harvest():
	if state == Constants.TileState.Mature:
		state = Constants.TileState.Empty
		$'../..'.gain_yield(current_yield)
		seed_base_yield = 0
		seed_grow_time = 0
		current_grow_progress = 0.0
		current_yield = 0.0
		$PlantSprite.visible = false
		if seed.effects.has("recurring"):
			plant_seed(seed)
			current_grow_progress = seed.effects.recurring.progress
			current_yield = current_grow_progress * seed_base_yield / seed_grow_time
			update_plant_sprite()
			grow_animation()

func irrigate():
	if !irrigated:
		current_multiplier += IRRIGATED_MULTIPLIER
		irrigated = true
		$IrrigateOverlay.visible = true

func lose_irrigate():
	irrigated = false
	$IrrigateOverlay.visible = false

func build_structure(card):
	state = Constants.TileState.Structure
	$PlantSprite.texture = load(card.texture)
	$PlantSprite.visible = true
	var rest_position = $PlantSprite.position
	$PlantSprite.position += Vector2(0, -500)
	var tween = get_tree().create_tween()
	tween.tween_property($PlantSprite, "position", rest_position, 0.6).set_trans(Tween.TRANS_BOUNCE)
