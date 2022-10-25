extends Node2D

class_name MapCharacter

const move_delay = 0.3

var player_controlled = false
var parent: Node2D
var last_move_time = 0

var camera: Camera2D
var sprite: AnimatedSprite

func _init(player_character = false):
	player_controlled = player_character
	sprite = AnimatedSprite.new()
	sprite.frames = SpriteFrames.new()
	sprite.frames.add_animation("north")
	sprite.frames.add_animation("west")
	sprite.frames.add_animation("south")
	sprite.frames.add_animation("east")
	sprite.offset.x = 16
	sprite.offset.y = 16


func _enter_tree():
	parent = get_parent()
	if camera == null:
		camera = Camera2D.new()
		camera.limit_top = 0
		camera.limit_left = 0
		camera.limit_bottom = 32 * 32 + 52
		camera.limit_right = 32 * 32 + 32*6
		self.add_child(camera)
		camera.position.x = 32*3
		camera.position.y = 6
		self.add_child(sprite)

	if player_controlled:
		camera.make_current()

	

func add_sprite_frame(direction:String, frame: Texture, at_position: int = -1):
	sprite.frames.add_frame(direction, frame, at_position)

func try_move(direction: String):
	if parent is TileMap:
		parent.get_parent().request_move(direction)
	else:
		parent.request_move(direction)

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

func _process(delta):
	last_move_time += delta
	if last_move_time >= move_delay:
		last_move_time = 0.0
	if Input.is_action_just_pressed("ui_up", false)\
	or Input.is_action_just_pressed("ui_left", false)\
	or Input.is_action_just_pressed("ui_down", false)\
	or Input.is_action_just_pressed("ui_right", false):
		last_move_time = 0

	if last_move_time == 0.0:
		check_movement()
