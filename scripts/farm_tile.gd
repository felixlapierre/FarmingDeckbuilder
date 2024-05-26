extends MarginContainer

enum {
	Empty,
	Destroyed,
	Growing,
	Mature
}
var state = Empty # Store the state of the farm tile
var grid_location: Vector2
var TILE_SIZE = Vector2(56, 56);
var FARM_DIMENSIONS = Vector2(6, 6);
var objects_image = "res://assets/1616tinygarden/objects.png"

var seed = null # To contain information about the seed being grown here

var seed_base_yield
var seed_grow_time
var current_yield
var current_grow_progress

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
		if Global.selected_card.type == "Seed":
			$"../../".use_card(Global.selected_card, grid_location)

func plant_seed(planted_seed):
	seed = planted_seed
	seed_grow_time = seed.time
	seed_base_yield = seed.yield
	current_grow_progress = 0.0
	current_yield = 0.0
	state = Growing
	$PlantSprite.texture = load(objects_image)
	$PlantSprite.region_enabled = true
	$PlantSprite.set_region_rect(Rect2(seed.texture * 16, 32, 16, 16))
	
func grow_one_week():
	if state == Growing:
		current_grow_progress += 1.0
		current_yield += seed_base_yield / seed_grow_time
		var stage = int(current_grow_progress / seed_grow_time * 3)
		var y
		var h
		match stage:
			0:
				y = 32
				h = 16
			1:
				y = 48
				h = 16
			2:
				y = 64
				h = 32
			3:
				y = 96
				h = 32
			
		$PlantSprite.set_region_rect(Rect2(seed.texture * 16, y, 16, h))
		$PlantSprite.offset = Vector2(8, 8 if h == 16 else 3)
		if current_grow_progress == seed_grow_time:
			state = Mature
