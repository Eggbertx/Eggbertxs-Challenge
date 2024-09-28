extends Node2D

class_name MapCharacter

const move_delay = 0.3

var player_controlled := false
var map: LevelMap
var last_move_time := 0.0
var camera: Camera2D
var sprite: AnimatedSprite2D

func _init(level_map: LevelMap, map_camera: Camera2D = null):
	map = level_map
	camera = map_camera
	player_controlled = map_camera == null
	sprite = AnimatedSprite2D.new()
	sprite.sprite_frames = SpriteFrames.new()
	
	sprite.sprite_frames.add_animation("north")
	sprite.sprite_frames.add_animation("west")
	sprite.sprite_frames.add_animation("south")
	sprite.sprite_frames.add_animation("east")
	sprite.offset.x = 16
	sprite.offset.y = 16

func _get_game_state() -> int:
	return map.get_game_state()

func add_sprite_frame(direction:String, frame: Texture2D, at_position: int = -1):
	sprite.sprite_frames.add_frame(direction, frame, 1, at_position)

func try_move(direction: String):
	map.request_move(direction)


func check_movement():
	if not player_controlled:
		return

	if Input.is_key_pressed(KEY_UP):
		sprite.animation = "north"
		try_move("north")
	if Input.is_key_pressed(KEY_LEFT):
		sprite.animation = "west"
		try_move("west")
	if Input.is_key_pressed(KEY_DOWN):
		sprite.animation = "south"
		try_move("south")
	if Input.is_key_pressed(KEY_RIGHT):
		sprite.animation = "east"
		try_move("east")

func check_exit():
	if not player_controlled:
		return
	if _get_game_state() == GameState.STATE_PAUSED:
		var player_tiles := map.get_player_tiles()
		if player_tiles[0] == Objects.EXIT or player_tiles[1] == Objects.EXIT:
			print("Loading next level")


func _process(delta: float):
	match _get_game_state():
		GameState.STATE_PLAYING, GameState.STATE_PAUSED:

			last_move_time += delta
			if last_move_time >= move_delay:
				last_move_time = 0.0
			if Input.is_action_just_pressed("ui_up", false)\
			or Input.is_action_just_pressed("ui_left", false)\
			or Input.is_action_just_pressed("ui_down", false)\
			or Input.is_action_just_pressed("ui_right", false):
				map.change_game_state(GameState.STATE_PLAYING)
				last_move_time = 0
			if last_move_time == 0.0:
				check_movement()
		GameState.STATE_LEVEL_EXIT:
			if Input.is_action_just_pressed("ui_accept", false):
				map.next_level_requested.emit()
				check_exit()
