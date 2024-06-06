extends MarginContainer
class_name Tile

var state = Enums.TileState.Empty # Store the state of the farm tile
var grid_location: Vector2
var TILE_SIZE = Vector2(56, 56);
var FARM_DIMENSIONS = Vector2(6, 6);
var objects_image = "res://assets/1616tinygarden/objects.png"

var seed = null # To contain information about the seed being grown here
var structure: Structure = null

var seed_base_yield
var seed_grow_time
var current_yield
var current_grow_progress
var current_multiplier = 1.0
var irrigated = false
var IRRIGATED_MULTIPLIER = 0.4
var purple = false
var structure_rotate = 0
var permanent_multiplier = 0.0

signal tile_hovered

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	do_active_check()

func do_active_check():
	if grid_location.x < Global.FARM_TOPLEFT.x\
		or grid_location.x > Global.FARM_BOTRIGHT.x\
		or grid_location.y < Global.FARM_TOPLEFT.y\
		or grid_location.y > Global.FARM_BOTRIGHT.y:
		state = Enums.TileState.Inactive
		$Farmland.visible = false
		$TileButton.visible = false
		return
	$PurpleOverlay.visible = purple
	$Farmland.visible = true
	$TileButton.visible = true
	if grid_location.x == Global.FARM_TOPLEFT.x:
		$Farmland.region_rect.position.x = 0
	elif grid_location.x == Global.FARM_BOTRIGHT.x:
		$Farmland.region_rect.position.x = 48
	else:
		$Farmland.region_rect.position.x = 16

	if grid_location.y == Global.FARM_TOPLEFT.y:
		$Farmland.region_rect.position.y = 0
	elif grid_location.y == Global.FARM_BOTRIGHT.y:
		$Farmland.region_rect.position.y = 48
	else:
		$Farmland.region_rect.position.y = 16
	if state == Enums.TileState.Inactive:
		state = Enums.TileState.Empty

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _on_tile_button_mouse_entered() -> void:
	tile_hovered.emit(self)

func _on_tile_button_mouse_exited() -> void:
	tile_hovered.emit(null)

func _on_tile_button_gui_input(event: InputEvent) -> void:
	if event.is_action_pressed("leftclick"):
		$"../../".use_card(grid_location)

func plant_seed_animate(planted_seed) -> Array[Effect]:
	var effects = plant_seed(planted_seed)
	$PlantSprite.scale = Vector2(0, 0)
	var tween = get_tree().create_tween()
	tween.tween_property($PlantSprite, "scale", Vector2(1, 1), 0.1);
	return effects

func plant_seed(planted_seed) -> Array[Effect]:
	var effects: Array[Effect] = []
	if state == Enums.TileState.Empty:
		seed = planted_seed
		effects.append_array(get_effects("plant"))
		seed_grow_time = float(seed.time)
		seed_base_yield = float(seed.yld)
		current_grow_progress = 0.0
		current_yield = 0.0
		permanent_multiplier = 0.0
		state = Enums.TileState.Growing
		$PlantSprite.visible = true
		$PlantSprite.texture = load(objects_image)
		$PlantSprite.region_enabled = true
		update_plant_sprite()
	return effects
	
func grow_one_week() -> Array[Effect]:
	var effects: Array[Effect] = []
	if state == Enums.TileState.Growing:
		effects.append_array(get_effects("grow"))
		current_grow_progress += 1.0
		current_yield += seed_base_yield / seed_grow_time * (current_multiplier + permanent_multiplier)
		current_multiplier = 1.0
		if irrigated:
			current_multiplier += IRRIGATED_MULTIPLIER
		update_plant_sprite()
		grow_animation()
		if current_grow_progress == seed_grow_time:
			state = Enums.TileState.Mature
	return effects

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
		
	$PlantSprite.set_region_rect(Rect2(seed.seed_texture * 16, y, 16, h))
	$PlantSprite.offset = Vector2(0, -8 if h == 16 else -14)

func harvest() -> Array[Effect]:
	var effects: Array[Effect] = []
	if state == Enums.TileState.Mature:
		effects.append_array(get_effects("harvest"))
		state = Enums.TileState.Empty
		$'../..'.gain_yield(current_yield, purple)
		seed_base_yield = 0
		seed_grow_time = 0
		current_grow_progress = 0.0
		current_yield = 0.0
		$PlantSprite.visible = false
		seed = null
	return effects

func irrigate():
	if !irrigated:
		current_multiplier += IRRIGATED_MULTIPLIER
		irrigated = true
		$IrrigateOverlay.visible = true

func lose_irrigate():
	irrigated = false
	$IrrigateOverlay.visible = false

func build_structure(n_structure, rotate):
	state = Enums.TileState.Structure
	structure = n_structure
	structure_rotate = rotate
	$PlantSprite.texture = n_structure.texture
	$PlantSprite.visible = true
	$PlantSprite.region_enabled = false
	var rest_position = $PlantSprite.position
	$PlantSprite.position += Vector2(0, -200)
	$PlantSprite.offset = Vector2(0, -8)
	var tween = get_tree().create_tween()
	tween.tween_property($PlantSprite, "position", rest_position, 0.6).set_trans(Tween.TRANS_BOUNCE)\
		.set_ease(Tween.EASE_OUT)

func preview_harvest() -> int:
	return current_yield if state == Enums.TileState.Mature else 0

func do_winter_clear():
	if state == Enums.TileState.Growing or state == Enums.TileState.Mature:
		state = Enums.TileState.Empty
		seed = null
		current_grow_progress = 0.0
		current_yield = 0.0
		var current_multiplier = 1.0
		var irrigated = false
		$PlantSprite.visible = false
		lose_irrigate()

func multiply_yield(strength):
	current_yield *= strength
func add_yield(strength):
	current_yield += strength

func get_turn_start_effects() -> Array[Effect]: 
	return get_effects("turn_start")

func get_before_grow_effects() -> Array[Effect]:
	return get_effects("before_grow")

func get_after_grow_effects() -> Array[Effect]:
	return get_effects("after_grow")

func get_effects(time) -> Array[Effect]:
	var effects_generated: Array[Effect] = []
	#TODO: Fix this unholy indentation
	if structure != null:
		for effect in structure.effects:
			if effect.on == time:
				if effect.range == "adjacent":
					var shape = Helper.get_tile_shape_rotated(structure.size, Enums.CursorShape.Elbow, structure_rotate)
					effects_generated.append_array(get_effects_in_shape(effect, shape))
	
	if seed != null:
		for effect in seed.effects:
			if effect.on == time:
				effects_generated.append(effect.copy().set_location(grid_location).set_card(seed))

	return effects_generated

func get_effects_in_shape(effect: Effect, shape):
	var effects: Array[Effect] = []
	for s in shape:
		var target = s + grid_location
		if Helper.in_bounds(target):
			effects.append(effect.copy().set_location(target).set_card(seed))
	return effects

func increase_permanent_mult(factor):
	permanent_multiplier += factor
	
