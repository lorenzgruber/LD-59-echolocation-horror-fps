class_name EchoPing

var origin: Vector3
var radius: float
var max_radius: float
var visibility: float
var emitting : bool;

const ECHO_SPEED := 10.0;

func _init(_origin: Vector3, _max_radius: float) -> void:
	self.origin = _origin;
	self.radius = 0.0;
	self.max_radius = _max_radius;
	self.visibility = 1.0;
	self.emitting = true;

func process(delta: float) -> void:
	if (emitting):
		radius += delta * ECHO_SPEED;
		
		if (radius >= max_radius):
			emitting = false;		
