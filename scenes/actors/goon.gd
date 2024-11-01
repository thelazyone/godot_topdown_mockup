extends CharacterBody2D

@export var SPEED = 100
@export var FACTION : int = 0

@export var WEAPON_RANGE = 300
@export var SPOTTING_RANGE = 200
@export var SPLAT : Resource = null
const SHOW_LOF : bool = true

# @onready var nav = $NavigationComponent
@onready var strat = $StrategyComponent
@onready var shoot = $ShootComponent

# Rotation handling
var current_bearing = 0
const ROTATION_SPEED_RAD_S = 4*PI
const FAST_ROTATION_ANGLE = .25*PI
const SLOW_ROTATION_RATIO = .1

# An overview of the sub-components:
#
# NavigationComponent (nav): interacts with the map (and its NavigationRegion) to
# provide the player with the next optimal movement direction to reach the set target.
# This means that if the target is moving it should be updated before the query.
# - set_target(position) to update the target
# - get_move() to retrieve the next intermediate target
# - get_move(position) to do both of the above at ounce.
#
# StrategyComponent (strat): deals with the internal logic of individual goons. Should
# be approached as a black box, with the only interfaces being
# - get_next_move() to retrieve the next movement to reach (in conflict with nav!)
# - is_shooting() to check if the unit is shooting.
# TODO both of these are wrong, the real interface should be something like
# - get_interests() returning a vector of directions and interests in each
# or rather, keeping the interest inside the strat:
# - get_next_move() and get_next_shoot_target
# if we decide to go more in a decoupled direction between movement and shooting.
#
# Either way the current use is 
# nav.get_move(strat.get_next_move())


func set_move_order(coordinates):
	strat.go_to(coordinates, 100)
	
func die():
	var new_splat = SPLAT.instantiate()
	new_splat.position = position
	new_splat.rotation = randf() * 2*PI
	get_parent().add_child(new_splat) 
	queue_free()

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	add_to_group("goons")
	strat.navigation_component = $NavigationComponent
	
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	# Movement
	# var local_target = nav.get_move(strat.get_next_move())
	var local_target = strat.get_next_move()
	if local_target:
		get_node("DebugDirection").points = [Vector2.ZERO, local_target - position]
	

	if local_target :
		
		# Updating the bearing
		var target_bearing = (local_target - position).angle()
		_apply_rotation_step(target_bearing, delta)		
		$Image.rotation = current_bearing + PI/2
		
		# Speed is in the direction of the facing, rather than directly towards the target
		velocity = Vector2(1,0).rotated(current_bearing) * SPEED
	else:
		velocity = Vector2.ZERO
	
	# Showing if attacking:
	var shooting_target = strat.is_shooting()
	
	if SHOW_LOF: 
		$LineOfSight.visible = false
		if shooting_target:
			$LineOfSight.visible = true
			$LineOfSight.points = [Vector2.ZERO, shooting_target - position]
		
	if shooting_target:
		# Handling the attack.
		shoot.try_shoot((shooting_target-position).angle())
		
	# Applying the physics rules
	move_and_slide()
	
	
# Private methods	
	
func _apply_rotation_step(target : float, delta : float):
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
