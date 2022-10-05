extends Node2D

class_name LevelMap

enum { NORTH, WEST, SOUTH, EAST }

signal player_move_attempted

var tiles_tex: ImageTexture
var player_pos = Vector2(0, 0)
var player_layer = 0
var viewport_offset: Vector2 # the base offset of the map view

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

func get_tile(x: int, y: int, layer: int) -> int:
	if layer == 1:
		return $Layer1.get_cell(x, y)
	return $Layer2.get_cell(x, y)

func set_tile(x: int, y: int, layer: int, tileID: int):
	if layer == 1:
		$Layer1.set_cell(x, y, tileID)
	else:
		$Layer2.set_cell(x, y, tileID)

func change_tile_location(x1: int, y1: int, l1: int, x2: int, y2: int, l2: int):
	var tile: int
	if l1 == 1:
		tile = $Layer1.get_cell(x1, y1)
		$Layer1.set_cell(x1, y1, -1)
	else:
		tile = $Layer2.get_cell(x1, y1)
		$Layer2.set_cell(x1, y1, -1)
	if l2 == 1:
		$Layer1.set_cell(x2, y2, tile)
	else:
		$Layer2.set_cell(x2, y2, tile)

func shift_player(direction: int):
	shift_tile(player_pos.x, player_pos.y, player_layer, direction)
	match direction:
		NORTH:
			player_pos.y -= 1
		WEST:
			player_pos.x -= 1
		SOUTH:
			player_pos.y += 1
		EAST:
			player_pos.x += 1

func shift_tile(x: int, y: int, layer: int, direction: int):
	var new_x = x
	var new_y = y
	match direction:
		NORTH:
			if y <= 0:
				return
			new_y = y - 1
		WEST:
			if x <= 0:
				return
			new_x = x - 1
		SOUTH:
			if y >= 31:
				return
			new_y = y + 1
		EAST:
			if x >= 31:
				return
			new_x = x + 1
	change_tile_location(x, y, layer, new_x, new_y, layer)


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

func center_camera():
	var camera_x = 0
	var camera_y = 0
	if player_pos.x <= 4:
		camera_x = 0
	else:
		camera_x = (player_pos.x - 4) * 32
	if player_pos.y <= 4:
		camera_y = 0
	else:
		camera_y = (player_pos.y - 4) * 32
	transform.origin.x = viewport_offset.x - camera_x
	transform.origin.y = viewport_offset.y - camera_y

func _on_LevelMap_player_move_attempted(direction: int):
	match direction:
		NORTH:
			if player_pos.y < 1:
				return
		WEST:
			if player_pos.x < 1:
				return
		SOUTH:
			if player_pos.y >= 31:
				return
		EAST:
			if player_pos.x >= 31:
				return

	shift_player(direction)
	center_camera()
