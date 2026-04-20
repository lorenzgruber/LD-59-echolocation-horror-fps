class_name MonsterNavigationManager extends Node

var astar : AStar2D

const ROOM_COUNT := 18

func _ready() -> void:
	init_astar()	

func init_astar() -> void:
	astar = AStar2D.new()
	
	var room_markers:= get_tree().get_nodes_in_group("MonsterPatrolRooms")
	if (room_markers.size() != ROOM_COUNT):
		push_error("Expected " + str(ROOM_COUNT) + " room markers, but found " + str(room_markers.size()))
		return
	
	for i in room_markers.size():
		var marker := room_markers[i]
		astar.add_point(i + 1, vec3_to_vec2(marker.global_position), 1.0)
	
	# area 1
	astar.connect_points(1, 2, true)
	astar.connect_points(2, 3, true)
	astar.connect_points(2, 6, true)
	astar.connect_points(3, 4, true)
	astar.connect_points(3, 5, true)
	astar.connect_points(3, 6, true)
	astar.connect_points(5, 6, true)
	
	# area 2
	astar.connect_points(7, 8, true)
	astar.connect_points(7, 11, true)
	astar.connect_points(8, 9, true)
	astar.connect_points(8, 10, true)
	astar.connect_points(9, 10, true)
	astar.connect_points(10, 11, true)
	astar.connect_points(11, 12, true)
	
	# area 3
	astar.connect_points(13, 14, true)
	astar.connect_points(13, 18, true)
	astar.connect_points(14, 15, true)
	astar.connect_points(14, 16, true)
	astar.connect_points(14, 18, true)
	astar.connect_points(15, 16, true)
	astar.connect_points(16, 17, true)

func connect_area_1_and_2() -> void:
	astar.connect_points(1, 7, true)
	astar.connect_points(2, 7, true)
	
func connect_area_2_and_3() -> void:
	astar.connect_points(8, 15, true)
	astar.connect_points(9, 15, true)

func get_current_room(monster_pos: Vector3) -> int:
	return astar.get_closest_point(vec3_to_vec2(monster_pos))

func get_next_patrol_room(current_room: int, prev_room: int) -> int:
	var neightbors := astar.get_point_connections(current_room)
	
	if (neightbors.size() <= 0):
		push_error("No neightbors for room " + str(current_room))
		return -1

	# remove the previous room from the list if there are more than 1 neightbors
	if (neightbors.size() > 1):
		var prev_room_idx := neightbors.find(prev_room)
		if (prev_room_idx != -1):
			neightbors.remove_at(prev_room_idx)
			
	
	return neightbors[randi_range(0, neightbors.size() - 1)]

func get_room_position(room: int) -> Vector3:
	return vec2_to_vec3(astar.get_point_position(room))
	
func vec3_to_vec2(vec3: Vector3) -> Vector2:
	return Vector2(vec3.x, vec3.z)
	
func vec2_to_vec3(vec2: Vector2) -> Vector3:
	return Vector3(vec2.x, 1.0, vec2.y)
