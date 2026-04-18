class_name EchoPing

var origin: Vector3
var radius: float
var max_radius: float
var visibility: float

var tree: SceneTree;

var max_radius_reached : bool;
var fading_out : bool;
var emitting : bool;

const ECHO_SPEED := 10.0;

func _init(_origin: Vector3, _max_radius: float, _tree: SceneTree) -> void:
	self.origin = _origin;
	self.radius = 0.0;
	self.max_radius = _max_radius;
	self.visibility = 1.0;
	self.max_radius_reached = false;
	self.tree = _tree;
	self.emitting = true;

func process(delta: float) -> void:
	if(!emitting): return;
	if (!max_radius_reached):
		radius += delta * ECHO_SPEED;
		if (radius >= max_radius):
			max_radius_reached = true;		
	elif !fading_out:
		fade_out();
		
func fade_out() -> void:
	fading_out = true;	
	var tween := tree.create_tween();
	tween.tween_property(self, "visibility", 0.0, 0.5).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CUBIC);
	tween.tween_callback(func() -> void: emitting = false);