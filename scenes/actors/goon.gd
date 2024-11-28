extends CharacterBody2D

@export var NAME : String = ""
@export var ID : int = 0
@export var SPEED = 100
@export var FACTION : int = 0

@export var WEAPON_RANGE = 300
@export var SPOTTING_RANGE = 200
@export var SPLAT : Resource = null

@onready var nav = $NavigationComponent
@onready var decision = $DecisionComponent
@onready var strat = $StrategyComponent
@onready var shoot = $ShootComponent
@onready var field = $FieldsComponent
@onready var health = $HealthComponent

var default_facing_right = true

# Rotation handling
var current_bearing = 0
const ROTATION_SPEED_RAD_S = 4*PI
const FAST_ROTATION_ANGLE = .25*PI
const SLOW_ROTATION_RATIO = .1

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
	strat.navigation_component = nav 		## TODO TBR
	strat.fields_component = field			## TODO TBR
	field.navigation_component = nav
	field.strategy_component = strat
	decision.navigation_component = nav
	
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	
	# Get Latest Decision
	var current_decision = decision.get_decision()
	var local_movement = Vector2.ZERO
	var shooting_target = null
	
	var target_position = null
	
	match current_decision.type:
		Decision.Types.IDLE:
			# Do nothing.
			pass
		Decision.Types.MOVE:
			match typeof(current_decision.target):
				TYPE_VECTOR2:
					target_position = current_decision.target
				TYPE_OBJECT:
					target_position = current_decision.target.global_position
			pass
		Decision.Types.PURSUE:
			target_position = current_decision.target.global_position
			pass
		Decision.Types.COVER:
			target_position = current_decision.target.global_position
			pass
		Decision.Types.ATTACK:
			# Nothing for now, but i know it's wrong TODO.
			shooting_target = current_decision.target.global_position
			pass
		_: 
			
			print("Unknown decision: ", current_decision)
	
	# Calculating the pathfinding.
	local_movement = nav.get_move(target_position)
	
	# Movement
	if local_movement :
		# Updating the bearing
		# This is good to do even if the image doesn't move.
		var target_bearing = (local_movement - position).angle()
		_apply_rotation_step(target_bearing, delta)		
		
		# Speed is in the direction of the facing, rather than directly towards the target
		velocity = Vector2(1,0).rotated(current_bearing) * SPEED
	else:
		velocity = Vector2.ZERO
	
	# Flipping the image if necessary
	if velocity.x < 0:
		$Image.flip_h = true
	elif velocity.x > 0:
		$Image.flip_h = false
	else:
		$Image.flip_h = !default_facing_right
	
	# Showing if attacking:
	#var shooting_target = strat.get_shooting_target()
	
	if Debug.debug_enabled: 
		$LineOfSight.visible = false
		if shooting_target:
			$LineOfSight.visible = true
			$LineOfSight.points = [Vector2.ZERO, shooting_target - position]
	else: 
		$LineOfSight.visible = false
		
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
