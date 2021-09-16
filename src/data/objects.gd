extends Node

class_name Objects

const WATER = 0x03
const FIRE = 0x04
const WALL_INVIS_NOAPPEAR = 0x05 # Invisible Wall (won't appear)
const BLOCKED_N = 0x06
const BLOCKED_W = 0x07
const BLOCKED_S = 0x08
const BLOCKED_E = 0x09
const DIRT_MOVABLE = 0x0A
const DIRT = 0x0B
const ICE = 0x0C
const FORCE_S = 0x0D
const CLONING_BLK_N = 0x0E
const CLONING_BLK_W = 0x0F
const CLONING_BLK_S = 0x10
const CLONING_BLK_E = 0x11
const FORCE_N = 0x12
const FORCE_E = 0x13
const FORCE_W = 0x14
const EXIT = 0x15
const DOOR_BLUE = 0x16
const DOOR_RED = 0x17
const DOOR_GREEN = 0x18
const DOOR_YELLOW = 0x19
const SLIDE_SE = 0x1A
const SLIDE_SW = 0x1B
const SLIDE_NW = 0x1C
const SLIDE_NE = 0x1D
const BLOCK_TO_TILE = 0x1E # Blue Block, becomes Tile
const BLOCK_TO_WALL = 0x1F # Blue Block, becomes Wall
const _UNUSED = 0x20
const THIEF = 0x21
const SOCKET = 0x22
const BUTTON_GREEN = 0x23 # Green Button - doors
const BUTTON_RED = 0x24 # Red Button - cloning
const SWITCH_CLOSED = 0x25 # Switch Block, Closed
const SWITCH_OPEN = 0x26 # Switch Block, Open
const BUTTON_TRAPS = 0x27 # Brown Button - Traps
const BUTTON_TANKS = 0x28 # Blue Button - Tanks
const TELEPORT = 0x29
const BOMB = 0x2A
const TRAP = 0x2B
const WALL_INVIS = 0x2C # Invisible Wall (Will appear)
const GRAVEL = 0x2D
const PASS_ONCE = 0x2E
const HINT = 0x2F
const BLOCKED_SE = 0x30
const CLONER = 0x31 # Cloning Machine
const FORCE_ALL = 0x32 # Force All Direction
const DROWNING = 0x33 # Drowning Chip
const BURNED = 0x34 # Burned Chip
const BURNED2 = 0x35 # Burned Chip(2)
const _UNUSED2 = 0x36
const _UNUSED3 = 0x37
const _UNUSED4 = 0x38
const CHIP_IN_EXIT = 0x39 # Chip in Exit - end game
const END_GAME = 0x3A # Exit - end game
const END_GAME2 = 0x3B # Exit - end game
const SWIMMING_N = 0x3C # Chip Swimming (N)
const SWIMMING_W = 0x3D # Chip Swimming (W)
const SWIMMING_S = 0x3E # Chip Swimming (S)
const SWIMMING_E = 0x3F # Chip Swimming (E)
const BUG_N = 0x40
const BUG_W = 0x41
const BUG_S = 0x42
const BUG_E = 0x43
const FIREBUG_N = 0x44
const FIREBUG_W = 0x45
const FIREBUG_S = 0x46
const FIREBUG_E = 0x47
const BALL_N = 0x48 # Pink Ball (N)
const BALL_W = 0x49 # Pink Ball (W)
const BALL_S = 0x4A # Pink Ball (S)
const BALL_E = 0x4B # Pink Ball (E)
const TANK_N = 0x4C
const TANK_W = 0x4D
const TANK_S = 0x4E
const TANK_E = 0x4F
const GHOST_N = 0x50
const GHOST_W = 0x51
const GHOST_S = 0x52
const GHOST_E = 0x53
const FROG_N = 0x54
const FROG_W = 0x55
const FROG_S = 0x56
const FROG_E = 0x57
const DUMBBELL_N = 0x58
const DUMBBELL_W = 0x59
const DUMBBELL_S = 0x5A
const DUMBBELL_E = 0x5B
const BLOB_N = 0x5C
const BLOB_W = 0x5D
const BLOB_S = 0x5E
const BLOB_E = 0x5F
const CENTIPEDE_N = 0x60
const CENTIPEDE_W = 0x61
const CENTIPEDE_S = 0x62
const CENTIPEDE_E = 0x63
const KEY_BLUE = 0x64
const KEY_RED = 0x65
const KEY_GREEN = 0x66
const KEY_YELLOW = 0x67
const FLIPPERS = 0x68
const FIRE_BOOTS = 0x69
const ICE_SKATES = 0x6A
const SUCTION_BOOTS = 0x6B
const CHIP_N = 0x6C
const CHIP_W = 0x6D
const CHIP_S = 0x6E
const CHIP_E = 0x6F

# returns true if the given tile id represents a recognized tile type, false otherwise
func valid_tile_value(tile: int):
	return tile >= 0\
		&& tile != _UNUSED\
		&& tile != _UNUSED2\
		&& tile != _UNUSED3\
		&& tile != _UNUSED4\
		&& tile <= CHIP_E

func _ready():
	pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
