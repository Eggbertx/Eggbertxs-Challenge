extends Node2D

class_name LevelMap

signal game_state_changed
signal update_chips_left
signal player_reached_exit
signal next_level_requested
signal update_hint_status
signal pickup_item
signal remove_item

const DEFAULT_TILESET_PATH = "res://res/tiles.png"
const DEFAULT_TILESET_SIZE = 32
const move_delay = 0.3
var tiles_tex: ImageTexture
var player_pos = Vector2(0, 0)
var tileset: TileSet
var tileset_src: TileSetAtlasSource
var player_layer = 0
var chips_left = 0
var player_character: MapCharacter
var on_hint = false
var hint_text = ""
var water_boots = false
var fire_boots = false
var ice_boots = false
var force_boots = false
var blue_keys = 0
var red_keys = 0
var green_keys = 0
var yellow_keys = 0

func _ready():
	tileset = TileSet.new()
	tileset_src = TileSetAtlasSource.new()
	player_character = MapCharacter.new()
	tiles_tex = ImageTexture.new()
	for y in range(32):
		for x in range(32):
			$Layer1.set_cell(0, Vector2i(x, y), Objects.FLOOR)

	var err = set_tileset(DEFAULT_TILESET_PATH, DEFAULT_TILESET_SIZE)
	if err != "":
		#Console.write_line(err)
		get_tree().quit()

func _get_atlas(texture: Texture2D, rect: Rect2) -> AtlasTexture:
	var atlas = AtlasTexture.new()
	atlas.set_atlas(texture)
	# atlas.set_region_enabled(rect)
	return atlas

func change_game_state(new_state: int):
	$GameState.change_state(new_state)

func get_game_state() -> int:
	return $GameState.current_state()

func get_tile(x: int, y: int, layer: int) -> int:
	if layer == 1:
		return $Layer1.get_cell(x, y)
	return $Layer2.get_cell(x, y)

func get_player_tiles():
	return [
		$Layer1.get_cell(player_pos.x, player_pos.y),
		$Layer2.get_cell(player_pos.x, player_pos.y)
	]

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

func change_character_location(character: MapCharacter, x: int, y: int, layer: int, is_player: bool):
	character.position.x = x * 32
	character.position.y = y * 32
	if layer == 1:
		character.parent = $Layer1
	else:
		character.parent = $Layer2
	if is_player:
		player_pos.x = x
		player_pos.y = y
		player_layer = layer


func shift_tile(x: int, y: int, layer: int, direction: String):
	var new_x = x
	var new_y = y
	match direction:
		"north":
			if y <= 0:
				return
			new_y = y - 1
		"west":
			if x <= 0:
				return
			new_x = x - 1
		"south":
			if y >= 31:
				return
			new_y = y + 1
		"east":
			if x >= 31:
				return
			new_x = x + 1
	change_tile_location(x, y, layer, new_x, new_y, layer)


func set_tileset(path: String, tile_size: int) -> String:
	var img:Image
	if path.begins_with("res://"):
		tiles_tex = ImageTexture.create_from_image(Image.load_from_file(path))
		if tiles_tex == null:
			return "Could not load tileset texture %s" % path
	else:
		img = Image.new()
		if img.load(path) != OK:
			return "Unable to load tileset texture %s" % path
		tiles_tex = ImageTexture.create_from_image(img)

	var img_width = tiles_tex.get_width()
	var img_height = tiles_tex.get_height()
	if img_width % tile_size > 0 or img_height % tile_size > 0:
		return "Tileset has an invalid size, tile width and height must be multiples of %d" % tile_size

	var x = 0
	var y = 0
	var atlases = []
	for t in range(112):
		atlases.push_back(_get_atlas(tiles_tex, Rect2(x, y, tile_size, tile_size)))
		tileset_src.create_tile(Vector2i(x, y), Vector2i(tile_size, tile_size))
		# tileset.tile_set_texture(t, atlas)
		if y + tile_size == img_height:
			y = 0
			x += tile_size
		else:
			y += tile_size
	$Layer1.tile_set = tileset
	$Layer2.tile_set = tileset

	player_character.add_sprite_frame("north", atlases[Objects.CHIP_N])
	player_character.add_sprite_frame("west", atlases[Objects.CHIP_W])
	player_character.add_sprite_frame("south", atlases[Objects.CHIP_S])
	player_character.add_sprite_frame("east", atlases[Objects.CHIP_E])
	return ""

# sets the player position when the map is first loaded, replacing the Objects.CHIP_E tile
# with a sprite
func init_player_pos(x: int, y: int, layer: int, direction: String):
	player_character.position.x = x * 32
	player_character.position.y = y * 32
	player_pos.x = x
	player_pos.y = y
	player_layer = layer
	player_character.player_controlled = true
	if player_character.parent != null:
		player_character.parent.remove_child(player_character)
	if layer == 1:
		$Layer1.add_child(player_character)
		$Layer1.set_cell(x, y, -1)
	else:
		$Layer2.add_child(player_character)
		$Layer2.set_cell(x, y, -1)
	
	player_character.sprite.animation = direction
	player_character.show()
	player_character.z_index = 1
	on_hint = tile_has_hint(x, y)
	emit_signal("update_hint_status", on_hint)

func tile_has_hint(x: int, y: int):
	return get_tile(x, y, 1) == Objects.HINT or get_tile(x, y, 2) == Objects.HINT

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

func request_move(direction: String):
	var new_x = player_pos.x
	var new_y = player_pos.y
	# next_x and next_y are used for checking the thing immediately after the destination.
	# So for example, if the tile at (new_x,new_y) is DIRT_MOVABLE and the tile at
	# (next_x,next_y) is FLOOR, it'll move, but if it's WALL, it won't
	var next_x = player_pos.x
	var next_y = player_pos.y
	match direction:
		"north":
			if player_pos.y < 1:
				return
			new_y = player_pos.y - 1
			next_y = player_pos.y - 2
		"west":
			if player_pos.x < 1:
				return
			new_x = player_pos.x - 1
			next_x = player_pos.x - 2
		"south":
			if player_pos.y >= 31:
				return
			new_y = player_pos.y + 1
			next_y = player_pos.y + 2
		"east":
			if player_pos.x >= 31:
				return
			new_x = player_pos.x + 1
			next_x = player_pos.x + 2
		_:
			pass
	var dest_tile = get_tile(new_x, new_y, player_layer)
	var next_tile = get_tile(next_x, next_y, player_layer)
	match dest_tile:
		Objects.FLOOR, Objects.HINT, -1:
			pass
		Objects.WALL:
			return
		Objects.COMPUTER_CHIP:
			if chips_left > 0:
				emit_signal("update_chips_left", chips_left - 1)
			set_tile(new_x, new_y, player_layer, Objects.FLOOR)
		Objects.DIRT_MOVABLE:
			match next_tile:
				Objects.FLOOR, Objects.HINT, -1:
					shift_tile(new_x, new_y, player_layer, direction)
				_:
					return
		Objects.EXIT:
			emit_signal("player_reached_exit")
			$GameState.change_state(GameState.STATE_LEVEL_EXIT)
		Objects.DOOR_BLUE:
			if blue_keys > 0:
				set_tile(new_x, new_y, player_layer, Objects.FLOOR)
				blue_keys -= 1
				if blue_keys == 0:
					emit_signal("remove_item", Objects.KEY_BLUE)
			else:
				return
		Objects.DOOR_RED:
			if red_keys > 0:
				set_tile(new_x, new_y, player_layer, Objects.FLOOR)
				red_keys -= 1
				if red_keys == 0:
					emit_signal("remove_item", Objects.KEY_RED)
			else:
				return
		Objects.DOOR_GREEN:
			if green_keys > 0:
				set_tile(new_x, new_y, player_layer, Objects.FLOOR)
			else:
				return
		Objects.DOOR_YELLOW:
			if yellow_keys > 0:
				set_tile(new_x, new_y, player_layer, Objects.FLOOR)
				yellow_keys -= 1
				if yellow_keys == 0:
					emit_signal("remove_item", Objects.KEY_YELLOW)
			else:
				return
		Objects.SOCKET:
			if chips_left > 0:
				return
			set_tile(new_x, new_y, player_layer, Objects.FLOOR)
		Objects.KEY_BLUE:
			emit_signal("pickup_item", Objects.KEY_BLUE)
			blue_keys += 1
			set_tile(new_x, new_y, player_layer, Objects.FLOOR)
		Objects.KEY_RED:
			emit_signal("pickup_item", Objects.KEY_RED)
			red_keys += 1
			set_tile(new_x, new_y, player_layer, Objects.FLOOR)
		Objects.KEY_GREEN:
			emit_signal("pickup_item", Objects.KEY_GREEN)
			green_keys += 1
			set_tile(new_x, new_y, player_layer, Objects.FLOOR)
		Objects.KEY_YELLOW:
			emit_signal("pickup_item", Objects.KEY_YELLOW)
			yellow_keys += 1
			set_tile(new_x, new_y, player_layer, Objects.FLOOR)
		_:
			print("Unhandled destination tile: %d" % dest_tile)
			return
	if on_hint and !tile_has_hint(new_x, new_y):
		on_hint = false
		emit_signal("update_hint_status", false)
	elif !on_hint and tile_has_hint(new_x, new_y):
		on_hint = true
		emit_signal("update_hint_status", true)
	change_character_location(player_character, new_x, new_y, player_layer, true)

func _on_LevelMap_update_chips_left(left: int):
	chips_left = left

func _on_GameState_game_state_changed(new_state: int, old_state: int):
	emit_signal("game_state_changed", new_state, old_state)
