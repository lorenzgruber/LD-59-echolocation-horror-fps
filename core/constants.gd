extends Node

const PLAYER_ECHO_COLOR: Color = Color(0.0, 1.228, 1.103);
const KEY_ECHO_COLOR_1: Color = Color(0.0, 1.0, 0.298);
const KEY_ECHO_COLOR_2: Color = Color(0.0, 0.6509804, 1.0);
const KEY_ECHO_COLOR_3: Color = Color(0.8666667, 0.0, 1.0);
const MONSTER_ECHO_COLOR: Color = Color(1.0, 0.0, 0.0);

const DEATH_ANIMATION_DURATION: float = 0.5

enum CollisionLayers { 
	LEVEL = 1,
	PLAYER = 2,
	MONSTER = 3,
	KEY = 4,
	ECHO_SIGNAL = 5,
	ECHO_SIGNAL_RECEIVER = 6,
	INTERACTABLE = 7,
	FOOTSTEP = 8,
	FOOTSTEP_RECEIVER = 9
};