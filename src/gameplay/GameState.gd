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

var _current_state = STATE_PAUSED

func change_state(new_state: int):
	if _current_state == new_state:
		return
	var old_state = _current_state
	@warning_ignore("int_as_enum_without_cast")
	_current_state = new_state
	emit_signal("game_state_changed", new_state, old_state)

func current_state() -> int:
	return _current_state
