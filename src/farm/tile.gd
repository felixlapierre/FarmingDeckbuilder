extends MarginContainer
class_name Tile

var state = Enums.TileState.Empty # Store the state of the farm tile
var grid_location: Vector2
var TILE_SIZE = Vector2(56, 56);
var FARM_DIMENSIONS = Vector2(6, 6);
var objects_image = "res://assets/1616tinygarden/objects.png"

var seed = null # To contain information about the seed being grown here
var structure: Structure = null

var seed_base_yield = 0.0
var seed_grow_time = 0.0
var current_yield = 0.0
var current_grow_progress = 0.0
var current_multiplier = 1.0
var irrigated = false
var IRRIGATED_MULTIPLIER = 0.4
var purple = false
var structure_rotate = 0
var permanent_multiplier = 0.0
var blight_targeted = false
var destroy_targeted = false

signal tile_hovered
signal on_event
signal on_yield_gained

var event_manager: EventManager

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
		$PurpleOverlay.visible = false
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
	var tween = get_tree().create_tween()
	tween.tween_property($PlantSprite, "scale", $PlantSprite.scale, 0.1);
	$PlantSprite.scale = Vector2(0, 0)
	return effects

func plant_seed(planted_seed) -> Array[Effect]:
	var effects: Array[Effect] = []
	if state == Enums.TileState.Empty:
		seed = planted_seed
		seed.register_seed_events(event_manager, self)
		effects.append_array(get_effects("plant"))
		seed_grow_time = float(seed.time)
		seed_base_yield = float(seed.yld)
		current_grow_progress = 0.0
		current_yield = 0.0
		permanent_multiplier = 0.0
		state = Enums.TileState.Growing
		if seed_grow_time == 0:
			state = Enums.TileState.Mature
			current_yield = seed_base_yield
		$PlantSprite.visible = true
		if seed.texture != null:
			$PlantSprite.texture = seed.texture
		else:
			$PlantSprite.texture = load(objects_image)
		$PlantSprite.region_enabled = true
		update_plant_sprite()
	event_manager.notify_specific_args(EventManager.EventType.OnPlantPlanted, EventArgs.SpecificArgs.new(self))
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
	event_manager.notify_specific_args(EventManager.EventType.OnPlantGrow, EventArgs.SpecificArgs.new(self))
	return effects

func grow_animation():
	var tween = get_tree().create_tween()
	tween.tween_property($PlantSprite, "scale", $PlantSprite.scale * Vector2(0.8, 1.2), 0.1)
	tween.tween_property($PlantSprite, "scale", $PlantSprite.scale * Vector2(1, 1), 0.1)

func update_plant_sprite():
	if seed.texture == null:
		var stage = 3 if seed_grow_time == 0 else int(current_grow_progress / seed_grow_time * 3)
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
		$PlantSprite.scale = Vector2(1, 1)
	else:
		var resolution = seed.texture.get_height() / 2
		var max_stage: int = seed.texture.get_width() / resolution - 1
		var current_stage = int(current_grow_progress / seed_grow_time * max_stage)
		var x = resolution * current_stage
		$PlantSprite.set_region_rect(Rect2(x, 0, resolution, resolution*2))
		$PlantSprite.offset = Vector2(0, -resolution)
		$PlantSprite.scale = Vector2(16.0 / resolution, 16.0 / resolution)

func harvest(delay) -> Array[Effect]:
	var effects: Array[Effect] = []
	var harvest_args = notify_harvest(delay)
	effects.append_array(get_effects("harvest"))
	state = Enums.TileState.Empty
	on_yield_gained.emit(self, harvest_args)
	remove_seed()
	$HarvestParticles.emitting = true
	return effects

func remove_seed():
	if seed != null:
		seed.unregister_seed_events(event_manager)
	seed_base_yield = 0
	seed_grow_time = 0
	current_grow_progress = 0.0
	current_yield = 0.0
	$PlantSprite.visible = false
	seed = null

func irrigate():
	if !irrigated:
		current_multiplier += IRRIGATED_MULTIPLIER
		irrigated = true
		$Farmland.modulate = Color8(0, 102, 255)

func lose_irrigate():
	irrigated = false
	if state != Enums.TileState.Blighted and state != Enums.TileState.Destroyed:
		$Farmland.modulate = Color8(255, 255, 255)

func build_structure(n_structure: Structure, rotate):
	state = Enums.TileState.Structure
	structure = n_structure.copy()
	structure_rotate = rotate
	structure.register_events(event_manager, self)
	structure.grid_location = grid_location
	$PlantSprite.texture = n_structure.texture
	$PlantSprite.visible = true
	$PlantSprite.region_enabled = false
	var rest_position = $PlantSprite.position
	$PlantSprite.position += Vector2(0, -200)
	$PlantSprite.offset = Vector2(0, -8)
	var tween = get_tree().create_tween()
	tween.tween_property($PlantSprite, "position", rest_position, 0.6).set_trans(Tween.TRANS_BOUNCE)\
		.set_ease(Tween.EASE_OUT)

func preview_harvest() -> float:
	if seed != null and seed.get_effect("corrupted") != null:
		return -1 * current_yield
	return current_yield

func do_winter_clear():
	if state == Enums.TileState.Growing or state == Enums.TileState.Mature or state == Enums.TileState.Destroyed:
		state = Enums.TileState.Empty
		remove_seed()
		var current_multiplier = 1.0
		lose_irrigate()

func multiply_yield(strength):
	$AddYieldParticles.emitting = true
	current_yield *= strength
func add_yield(strength):
	$AddYieldParticles.emitting = true
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
				var shape
				if effect.range == "adjacent":
					shape = Helper.get_tile_shape_rotated(structure.size, Enums.CursorShape.Elbow, structure_rotate)
				elif effect.range == "nearby":
					shape = Helper.get_tile_shape_rotated(structure.size, Enums.CursorShape.Elbow, structure_rotate)
				if shape != null:
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
	
func set_blight_targeted(value):
	blight_targeted = value
	$BlightTargetOverlay.visible = value

func set_destroy_targeted(value):
	destroy_targeted = value
	$DestroyTargetOverlay.visible = value

func set_blighted():
	notify_destroyed()
	remove_seed()
	state = Enums.TileState.Blighted
	$PlantSprite.visible = false
	$Farmland.modulate = Color8(102, 0, 102)
	$DestroyParticles.emitting = true

func destroy():
	on_event.emit()
	state = Enums.TileState.Destroyed
	$Farmland.modulate = Color8(45, 45, 45)
	notify_destroyed()
	remove_seed()
	$DestroyParticles.emitting = true

func destroy_plant():
	state = Enums.TileState.Empty
	notify_destroyed()
	remove_seed()
	$DestroyParticles.emitting = true

func update_purple_overlay():
	$PurpleOverlay.visible = purple and state != Enums.TileState.Inactive

func notify_harvest(delay: bool) -> EventArgs.HarvestArgs:
	var corrupted = seed.get_effect("corrupted") != null
	var harvest_args = EventArgs.HarvestArgs.new(-current_yield if corrupted else current_yield, purple, delay)
	var specific_args = EventArgs.SpecificArgs.new(self)
	specific_args.harvest_args = harvest_args
	event_manager.notify_specific_args(EventManager.EventType.OnPlantHarvest, specific_args)
	return harvest_args

func notify_destroyed():
	event_manager.notify_specific_args(EventManager.EventType.OnPlantDestroyed,\
		EventArgs.SpecificArgs.new(self))

func remove_blight():
	if structure != null:
		state = Enums.TileState.Structure
	else:
		state = Enums.TileState.Empty
	$Farmland.modulate = Color8(255, 255, 255)

func set_tile_size(n_size: Vector2):
	scale = n_size / Vector2(16, 16)
	$HarvestParticles.process_material.scale_min = 3.2
	$HarvestParticles.process_material.scale_max = 3.2
	$AddYieldParticles.process_material.scale_min = 2
	$AddYieldParticles.process_material.scale_max = 2
	$DestroyParticles.process_material.scale_min = 5
	$DestroyParticles.process_material.scale_max = 5
	
