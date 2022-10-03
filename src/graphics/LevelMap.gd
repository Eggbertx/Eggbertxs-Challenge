extends Node2D

var tiles_tex: ImageTexture

func _ready():
	tiles_tex = ImageTexture.new()
	for y in range(32):
		for x in range(32):
			$Layer1.set_cell(x,y,Objects.FLOOR)

	var err = set_tileset("res://res/old/tileset.png", 32)
	if err != "":
		Console.write_line(err)
		get_tree().quit()

func _get_atlas(texture: Texture, rect: Rect2) -> AtlasTexture:
	var atlas = AtlasTexture.new()
	atlas.set_atlas(texture)
	atlas.set_region(rect)
	return atlas

func set_tileset(path: String, tile_size: int) -> String:
	var img:Image
	if path.begins_with("res://"):
		var stream_tex:StreamTexture = load(path)
		if stream_tex == null:
			return "Could not load tileset texture %s" % path
		tiles_tex.create_from_image(stream_tex.get_data())
	else:
		img = Image.new()
		if img.load(path) != OK:
			return "Unable to load tileset texture %s" % path
		tiles_tex.create_from_image(img)

	var img_width = tiles_tex.get_width()
	var img_height = tiles_tex.get_height()
	if img_width % tile_size > 0 or img_height % tile_size > 0:
		return "Tileset has an invalid size, tile width and height must be multiples of %d" % tile_size

	var tileset = TileSet.new()
	var x = 0
	var y = 0
	for t in range(111):
		var atlas = _get_atlas(tiles_tex, Rect2(x, y, tile_size, tile_size))

		tileset.create_tile(t)
		tileset.tile_set_texture(t, atlas)
		if y + tile_size == img_height:
			y = 0
			x += tile_size
		else:
			y += tile_size
	$Layer1.tile_set = tileset
	$Layer2.tile_set = tileset
	return ""

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
