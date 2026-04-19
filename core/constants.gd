extends Node

const PLAYER_ECHO_COLOR: Color = Color(0.0, 1.228, 1.103);
const KEY_ECHO_COLOR: Color = Color(0.0, 1.0, 0.298);
const MONSTER_ECHO_COLOR: Color = Color(1.0, 0.0, 0.0);

enum CollisionLayers { LEVEL = 1, PLAYER = 2, MONSTER = 3, KEY = 4, ECHO_SIGNAL = 5, ECHO_SIGNAL_RECEIVER = 6 };