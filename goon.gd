extends CharacterBody2D

var astar: AStar2D
var target = null
var step_target = null

@export var SPEED = 100
@export var POSITION_ACC = 16


func _generate_id(pos): #generates unique id for each position - just trust the math
	var x = pos.x
	var y = pos.y
	return (x + y) * (x + y + 1) / 2 + y
	
func _create_map(map : AStar2D): 
	# Viewport size is 
	var viewport_size = get_viewport().size
	
	# Creating the astar points.
	var map_size_x = viewport_size.x / POSITION_ACC
	var map_size_y = viewport_size.y / POSITION_ACC
	for xi in range(map_size_x):
		for yi in range(map_size_y):
			var pos = Vector2(xi, yi)
			astar.add_point(_generate_id(pos), pos)
			astar.set_point_disabled(_generate_id(pos), false)
	
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
	
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	astar = AStar2D.new()
	_create_map(astar)

	
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	
	# If there is no target, skip.
	if not target: return
	
	# If there is no local target, calculate one.
	if not step_target: _update_local_target()
	
	# If there is target, all good.
	if step_target: 
		var direction = (step_target - position).normalized()
		velocity = direction * SPEED
		
		# Checking if step target reached: 
		if (step_target - position).length() < POSITION_ACC:
			step_target = null
			if (target - position).length() < POSITION_ACC:
				target = null
		
		move_and_slide()
	
	# if there's no step target, stopping.
	else:
		target = null
		
	pass

	
func _update_local_target():
	# Needs a target for the step target to work!
	if not target: return
	
	var path = astar.get_point_path(_generate_id(_get_node_from_pos(position)), _generate_id(_get_node_from_pos(target)))
	
	if not path: return
	if path.size() < 2 : return
	
	# Setting step_target
	step_target = _get_pos_from_node(path[1])
