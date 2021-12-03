extends Node2D

var tiles_tex: ImageTexture

func _ready():
	tiles_tex = ImageTexture.new()
	var err = set_tileset("res://images/old/tileset.png", 32)
	if err != "":
		Console.write_line(err)
		get_tree().quit()
	$Layer1.set_cell(1,1,1)

func _get_atlas(texture: Texture, rect: Rect2) -> AtlasTexture:
	var atlas = AtlasTexture.new()
	atlas.set_atlas(texture)
	atlas.set_region(rect)
	return atlas

func set_tileset(path: String, tile_size: int) -> String:
	var img = Image.new()
	if img.load(path) != OK:
		return "Unable to load tileset texture %s" % path
	tiles_tex.create_from_image(img)

	var img_width = img.get_width()
	var img_height = img.get_height()
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
