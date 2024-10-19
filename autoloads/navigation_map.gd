extends Node2D

@export var POSITION_ACC = 8
var astar: AStar2D
var viewport_size = null

var is_setup = false


func setup(size) -> bool:
	if is_setup: 
		return false
	is_setup = true
	var tic = Time.get_ticks_msec()
	print("Setting up navigation map for ", size, "...")	
	viewport_size = size
	astar = AStar2D.new()
	_create_map(astar)
	print("map created in ", Time.get_ticks_msec() - tic , "ms")
	return true
	
func get_next_step(start, end):
	var path = astar.get_point_path(_generate_id(_get_node_from_pos(start)), _generate_id(_get_node_from_pos(end)))
	if not path: 
		print("path not generated with start as ", start, " and end as ", end)
		return
	if path.size() < 2:
		return
	return _get_pos_from_node(path[1])

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


# PRIVATE FUNCTION

func _generate_id(pos): #generates unique id for each position - just trust the math
	var x = pos.x
	var y = pos.y
	return (x + y) * (x + y + 1) / 2 + y
	
func _create_map(map : AStar2D): 
	# Creating the astar points.
	var map_size_x = viewport_size.x / POSITION_ACC
	var map_size_y = viewport_size.y / POSITION_ACC
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
	return Vector2(round(float_pos.x/POSITION_ACC), round(float_pos.y/POSITION_ACC))

func _get_pos_from_node(pos : Vector2) -> Vector2:
	return Vector2(pos.x * POSITION_ACC, pos.y * POSITION_ACC)
	
