extends Node2D


var astar: AStar2D
var target = null
var local_target = null
var current_position = null

var viewport_size = null
var position_accuracy = 0 # TODO check if still necessary?

# DIRECTION INERTIA!
var current_bearing = 0
const ROTATION_SPEED_RAD_S = 1*PI

func _wrap_angle(angle) -> float:
	return fmod(angle + 3*PI, 2*PI) - 3*PI
	
func _angle_diff(angle1, angle2) -> float:
	return fmod(fmod(angle1, 2 * PI) - fmod(angle2, 2 * PI) + 3 * PI, 2 * PI) - PI
	
func _rotation_step(target : float, delta : float):
	#print ("angles are: target " , target, ", curr ", current_bearing)
	var diff = _angle_diff(target, current_bearing)
	print ("delta is ", delta * ROTATION_SPEED_RAD_S)
	if diff > 0: 
		print("add")
		current_bearing += delta * ROTATION_SPEED_RAD_S
	else: 
		print("sub")
		current_bearing -= delta * ROTATION_SPEED_RAD_S
	current_bearing = _wrap_angle(current_bearing)
	print("debug_bearing ", current_bearing)


# PUBLIC METHODS


func setup(size, precision):
	viewport_size = size
	position_accuracy = precision
	astar = AStar2D.new()
	_create_map(astar)

func is_setup():
	return viewport_size != null
	
func set_target(input_position):
	if input_position:
		target = input_position

func get_move(input_position):
	#if not target: return # TODO TBR?
	

	# If no target, not moving
	if not local_target:
		return null
		
	# Updating the debug direction.
	get_parent().get_node("DebugDirection").points = [Vector2.ZERO, local_target - get_parent().position]
	
	## If moving "away" from the target, just rotating:
	#if (local_target - get_parent().position).dot(Vector2(1., 0.).rotated(current_bearing)) < 0:
		#return null
	
	return get_parent().position + Vector2(1., 0.).rotated(current_bearing)


# NODE LOOPS


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	
	# Updating the current bearing
	if target:
		# TODO limit this call, doesn't need to happen every frame!
		local_target = _update_local_target(get_parent().position)
		if local_target:
			var target_bearing = (local_target - get_parent().position).angle()
			
			#print ("current bearing is ", current_bearing, " target bearing is ", target_bearing)
			print ("difference would be ", _angle_diff(current_bearing, target_bearing))
			_rotation_step(target_bearing, delta)
	
	pass


## PRIVATE METHODS

func _generate_id(pos): #generates unique id for each position - just trust the math
	var x = pos.x
	var y = pos.y
	return (x + y) * (x + y + 1) / 2 + y
	
func _create_map(map : AStar2D): 
	# Creating the astar points.
	var map_size_x = viewport_size.x / position_accuracy
	var map_size_y = viewport_size.y / position_accuracy
	for xi in range(map_size_x):
		for yi in range(map_size_y):
			var pos = Vector2(xi, yi)
			astar.add_point(_generate_id(pos), pos)
			astar.set_point_disabled(_generate_id(pos), false)
			
			# Check if point is colliding with terrain
			var elements = get_tree().get_nodes_in_group("terrain")
			for element in elements:
				#var local_point = element.get_node("Hitbox").to_local(_get_pos_from_node(pos))
				#if Geometry2D.is_point_in_polygon(local_point, element.get_node("Hitbox").get_polygon()):
				var local_point = element.get_node("Avoid").to_local(_get_pos_from_node(pos))
				if Geometry2D.is_point_in_polygon(local_point, element.get_node("Avoid").get_polygon()):
					astar.set_point_disabled(_generate_id(pos), true)
					break
						#or with every neighbouring cell, if "diagonalEnabled" is true
	var neighbours = [Vector2(1, 0), Vector2(-1, 0), Vector2(0,1), Vector2(0,-1)]
	neighbours.append_array([Vector2(1, 1), Vector2(-1, -1), Vector2(-1,1), Vector2(1,-1)])
	
	for xi in range(map_size_x):
		for yi in range(map_size_y):
			var pos = Vector2(xi, yi)
			for n in neighbours:
				var next_pos = pos + n
				if next_pos.x >= 0 && next_pos.x < map_size_x:
					if next_pos.y >= 0 && next_pos.y < map_size_y:
						astar.connect_points(_generate_id(pos), _generate_id(next_pos), false)
						
func _get_node_from_pos(float_pos : Vector2) -> Vector2:
	return Vector2(round(float_pos.x/position_accuracy), round(float_pos.y/position_accuracy))

func _get_pos_from_node(pos : Vector2) -> Vector2:
	return Vector2(pos.x * position_accuracy, pos.y * position_accuracy)
	
func _update_local_target(input_position):
	#if not input_position: return
	current_position = input_position
	
	if not target: 
		return
	
	var path = astar.get_point_path(_generate_id(_get_node_from_pos(current_position)), _generate_id(_get_node_from_pos(target)))
	
	if not path: 
		return
	
	if path.size() < 2:
		return
	
	# Setting step_target
	return _get_pos_from_node(path[1])
