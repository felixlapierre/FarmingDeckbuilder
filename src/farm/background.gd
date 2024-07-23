extends Sprite2D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func unique_tileset():
	var tileset: TileSet = $TileMap.tile_set
	var newtileset = tileset.duplicate(true)
	$TileMap.tile_set = newtileset

func get_background_texture():
	return $TileMap.tile_set.get_source(0).texture

func set_background_texture(texture: Texture2D):
	var tileset: TileSet = $TileMap.tile_set
	var src: TileSetAtlasSource = tileset.get_source(0)
	src.texture = texture

func tween_to_visible(duration: float):
	modulate.a = 0
	var tween = get_tree().create_tween()
	tween.parallel().tween_property(self, "modulate:a", 1, duration)

func tween_to_invisible(duration: float):
	modulate.a = 1
	var tween = get_tree().create_tween()
	tween.parallel().tween_property(self, "modulate:a", 0, duration)
