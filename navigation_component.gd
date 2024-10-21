extends Node2D

var target = null
var local_target = null
var current_position = null
const POSITION_PRECISION = 20
const PATFHINDING_PERIOD_MS = 200
@onready var last_patfhinding_tick = Time.get_ticks_msec()

# DIRECTION INERTIA!
var current_bearing = 0
const ROTATION_SPEED_RAD_S = 4*PI
const FAST_ROTATION_ANGLE = .25*PI
const SLOW_ROTATION_RATIO = .1

@onready var navigation_agent: NavigationAgent2D = $NavigationAgent2D


func _rotation_step(target : float, delta : float):
	#print ("angles are: target " , target, ", curr ", current_bearing)
	var diff = Geometry.angle_diff(target, current_bearing)
	var delta_movement = delta * ROTATION_SPEED_RAD_S
	if abs(diff) < FAST_ROTATION_ANGLE: 
		delta_movement *= SLOW_ROTATION_RATIO
		
	if diff > 0: 
		current_bearing += delta_movement
	else: 
		current_bearing -= delta_movement
	current_bearing = Geometry.wrap_angle(current_bearing)


# PUBLIC METHODS
func setup(size):
	NavigationMap.setup(size)

func is_setup():
	return NavigationMap.is_setup
	
func set_target(input_position):
	if input_position:
		target = input_position
		print("set target as ", target)
		navigation_agent.target_position = input_position
		##print("setting target to ", input_position)
		NavigationServer2D.agent_set_avoidance_enabled(navigation_agent, true)

	
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
		
		# Updating the pathfinding only every X ms.
		# TODO - either use a timer or an int counter, if this proves to be 
		# too computationally intensive. 
		if Time.get_ticks_msec() - last_patfhinding_tick > PATFHINDING_PERIOD_MS:
			local_target = navigation_agent.get_next_path_position()
			last_patfhinding_tick = Time.get_ticks_msec()
		
		if get_parent().position.distance_to(target) < POSITION_PRECISION:
			local_target = null
			
		if local_target:
			print("local target is ", local_target)
			var target_bearing = (local_target - get_parent().position).angle()
			_rotation_step(target_bearing, delta)
	
	pass


## PRIVATE METHODS
func _update_local_target(input_position):
	#if not input_position: return
	current_position = input_position
	
	if not target: 
		return
		
	# Setting step_target
	return NavigationMap.get_next_step(current_position, target)
