extends Node

class_name GameState

signal game_state_changed

enum {
	STATE_PLAYING,
	STATE_PAUSED,
	STATE_OUT_OF_TIME,
	STATE_DEAD_MONSTER,
	STATE_DEAD_WATER,
	STATE_DEAD_FIRE,
	STATE_DEAD_BOMBS,
	STATE_DEAD_CRUSHED,
	STATE_LEVEL_EXIT
}

@export_enum(
	"Playing",
	"Paused",
	"Out of time",
	"Monster",
	"Drowned",
	"Burned",
	"Bombed",
	"Crushed",
	"Level exit"
) var _current_state:int = STATE_PAUSED
@export var current_state:int:
	get:
		return _current_state

func change_state(new_state: int):
	if _current_state == new_state:
		return
	var old_state = _current_state
	@warning_ignore("int_as_enum_without_cast")
	_current_state = new_state
	emit_signal("game_state_changed", new_state, old_state)
