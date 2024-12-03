extends CharacterBody2D

@export var NAME : String = ""
@export var ID : int = 0
@export var SPEED = 100
@export var FACTION : int = 0

@export var WEAPON_RANGE = 300
@export var SPOTTING_RANGE = 200
@export var THREAT_RANGE = 400
@export var FORMATION_DISTANCE = 30
@export var SPLAT : Resource = null

@onready var nav = $NavigationComponent
@onready var decision = $DecisionComponent
@onready var shoot = $ShootComponent
@onready var field = $FieldsComponent
@onready var health = $HealthComponent

var default_facing_right = true

# Rotation handling
var current_bearing = 0
const ROTATION_SPEED_RAD_S = 4*PI
const FAST_ROTATION_ANGLE = .25*PI
const SLOW_ROTATION_RATIO = .1
	
func die():
	var new_splat = SPLAT.instantiate()
	new_splat.position = position
	new_splat.rotation = randf() * 2*PI
	get_parent().add_child(new_splat) 
	queue_free()

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	add_to_group("goons")
	
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	
	# Get Latest Decision
	var current_decision = decision.get_decision()
	var local_movement = null
	var decision_weight = 1
	var shooting_target = null
	var decision_position = null
	var speed_multiplier : float = 1
	
		
	if Debug.debug_enabled:
		$DebugRect.visible = true
		$DebugRect.global_position = current_decision.get_target_position() - Vector2(10,10)
		$DebugRect.size = Vector2(20,20)
		match current_decision.type:
			Decision.Types.IDLE:
				$DebugRect.color = Color.YELLOW
			Decision.Types.MOVE:
				$DebugRect.color = Color.GREEN
			Decision.Types.PURSUE:
				$DebugRect.color = Color.PURPLE
			Decision.Types.COVER:
				$DebugRect.color = Color.ORANGE
			Decision.Types.ATTACK:
				$DebugRect.color = Color.RED

	else:
		$DebugRect.visible = false
	
	match current_decision.type:
		Decision.Types.IDLE:
			# Do nothing.
			pass
		Decision.Types.MOVE:
			decision_position = current_decision.get_target_position()
			pass
		Decision.Types.PURSUE:
			decision_position = current_decision.target.global_position
			pass
		Decision.Types.COVER:
			decision_position = current_decision.target.global_position
			pass
		Decision.Types.ATTACK:
			# No movement for now, but i know it's wrong TODO.
			decision_position = current_decision.target.global_position
			if global_position.distance_to(decision_position) < WEAPON_RANGE:
				speed_multiplier = .1
			shooting_target = current_decision.target.global_position
			pass
		_: 
			
			print("Unknown decision: ", current_decision)
	
	# Calculating the pathfinding. This provides the Movement decision, which is then
	# Combined with the fields of other things going on.
	if decision_position != null:
		local_movement = nav.get_move(decision_position)
		if local_movement != null and global_position.distance_to(local_movement) > 30:
			field.set_decision_field(global_position.angle_to_point(local_movement), delta)
	field.set_threat_field(decision._get_targets(THREAT_RANGE), THREAT_RANGE, delta) ## TODO using private functions of decision for now -> TODO move them in a different class?
	field.set_formation_field(decision._get_targets(FORMATION_DISTANCE, FACTION), FORMATION_DISTANCE, delta) ## TODO SAME AS ABOVE
	
	# Retrieving the global result:
	var field_peak = field.get_combined_field_peak()
	
	# Movement
	if field_peak != Vector2.ZERO :
		
		# Updating the bearing
		var target_bearing = field_peak.angle()
		_apply_rotation_step(target_bearing, delta)		
		
		# Speed is in the direction of the facing, but with a dot product of the actual direction to go
		velocity = Vector2(1,0).rotated(current_bearing) * SPEED * speed_multiplier * cos(current_bearing - target_bearing)
	else:
		velocity = Vector2.ZERO
	
	# Flipping the image if necessary
	if velocity.x < -0.1:
		$Image.flip_h = true
	elif velocity.x > 0.1:
		$Image.flip_h = false
	elif velocity.x == 0:
		$Image.flip_h = !default_facing_right
	
	if Debug.debug_enabled: 
		$LineOfSight.visible = false
		if shooting_target:
			$LineOfSight.visible = true
			$LineOfSight.points = [Vector2.ZERO, shooting_target - position]
	else: 
		$LineOfSight.visible = false
		
	if shooting_target:
		
		# Handling the attack.
		shoot.try_shoot((shooting_target - position).angle())
		
	# Applying the physics rules
	move_and_slide()
	
##############################
## PRIVATE METHODS
##############################
	
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
	
	
	
	
	
##############################
## DEBUG
##############################
func _unhandled_input(event):
	if Debug.debug_enabled and event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			print("clicked ", event.global_position, " goon is ", global_position)
			if global_position.distance_to(get_global_mouse_position()) < 20:
				print("selecting goon ", self, " for debug purposes!")
				Debug.select_goon(self)
