extends Node2D


var astar: AStar2D
var target = null
var current_position = null

var viewport_size = null
var position_accuracy = 0

# PUBLIC METHODS


func setup(size, precision):
	viewport_size = size
	position_accuracy = precision
	astar = AStar2D.new()
	_create_map(astar)

func is_setup():
	return viewport_size != null
	
func set_target(input_position):
	target = input_position

func get_move(input_position):
	if not target: return
	return _update_local_target(input_position)


# NODE LOOPS


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
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
	
	if not target: return
	
	var path = astar.get_point_path(_generate_id(_get_node_from_pos(current_position)), _generate_id(_get_node_from_pos(target)))
	
	if not path: return
	if path.size() < 2 : return
	# Setting step_target
	return _get_pos_from_node(path[1])
