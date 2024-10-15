extends Sprite2D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func set_background_texture(texture: Texture2D):
	if texture != null:
		var tileset: TileSet = $TileMap.tile_set
		var src: TileSetAtlasSource = tileset.get_source(0)
		src.texture = texture
