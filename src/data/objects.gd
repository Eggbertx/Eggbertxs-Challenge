extends Node

class_name Objects

enum {
	FLOOR,
	WALL,
	COMPUTER_CHIP,
	WATER,
	FIRE,
	WALL_INVIS_NOAPPEAR
	BLOCKED_N,
	BLOCKED_W,
	BLOCKED_S,
	BLOCKED_E,
	DIRT_MOVABLE,
	DIRT_FLOOR,
	ICE_FLOOR,
	FORCE_SOUTH,
	CLONING_BLK_N,
	CLONING_BLK_W,
	CLONING_BLK_S,
	CLONING_BLK_E,
	FORCE_N,
	FORCE_E,
	FORCE_W,
	EXIT,
	DOOR_BLUE,
	DOOR_RED,
	DOOR_GREEN,
	DOOR_YELLOW,
	SLIDE_SE,
	SLIDE_SW,
	SLIDE_NW,
	SLIDE_NE,
	BLOCK_TO_FLOOR, # Blue Block, becomes FLOOR when pushed
	BLOCK_TO_WALL # Blue Block, becomes WALL when pushed
	COMBINATION, # shows Chip or a monster, see https://wiki.bitbusters.club/Combination
	THIEF,
	SOCKET,
	BUTTON_GREEN, # Green Button - triggers doors
	BUTTON_RED, # Red Button - cloning
	SWITCH_CLOSED,
	SWITCH_OPEN,
	BUTTON_TRAPS, # Brown Button - triggers traps
	BUTTON_TANKS, # Blue Button - triggers tanks
	TELEPORT,
	BOMB,
	TRAP,
	WALL_INVIS,  # Invisible wall (Will appear when pushed)
	GRAVEL,
	PASS_ONCE,
	HINT,
	BLOCKED_SE,
	CLONER,
	FORCE_ALL, # Force All Direction
	CHIP_DROWNED,
	CHIP_BURNED,
	CHIP_BURNED2,
	UNUSED1,
	UNUSED2,
	UNUSED3,
	CHIP_EXIT, # Chip in exit - end of game
	EXIT_ENDGAME1,
	EXIT_ENDGAME2,
	CHIP_SWIMMING_N,
	CHIP_SWIMMING_W,
	CHIP_SWIMMING_S,
	CHIP_SWIMMING_E,
	BUG_N,
	BUG_W,
	BUG_S,
	BUG_E,
	FIREBUG_N,
	FIREBUG_W,
	FIREBUG_S,
	FIREBUG_E,
	BALL_N, 
	BALL_W, 
	BALL_S, 
	BALL_E,
	TANK_N,
	TANK_W,
	TANK_S,
	TANK_E,
	GLIDER_N, # aka Ghost
	GLIDER_W, # aka Ghost
	GLIDER_S, # aka Ghost
	GLIDER_E, # aka Ghost
	TEETH_N, # aka Frog
	TEETH_W, # aka Frog
	TEETH_S, # aka Frog
	TEETH_E, # aka Frog
	WALKER_N, # aka Dumbbell
	WALKER_W, # aka Dumbbell
	WALKER_S, # aka Dumbbell
	WALKER_E, # aka Dumbbell
	BLOB_N,
	BLOB_W,
	BLOB_S,
	BLOB_E,
	PARAMECIUM_N,
	PARAMECIUM_W,
	PARAMECIUM_S,
	PARAMECIUM_E,
	KEY_BLUE,
	KEY_RED,
	KEY_GREEN,
	KEY_YELLOW,
	FLIPPERS,
	FIRE_BOOTS,
	ICE_SKATES,
	SUCTION_BOOTS,
	CHIP_N,
	CHIP_W,
	CHIP_S,
	CHIP_E
}

# returns true if the given tile id represents a recognized tile type, false otherwise
func valid_tile_value(tile: int):
	return tile >= 0\
		&& tile != UNUSED1\
		&& tile != UNUSED2\
		&& tile != UNUSED3\
		&& tile <= CHIP_E

func _ready():
	pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
