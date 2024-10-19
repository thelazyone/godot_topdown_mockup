extends CharacterBody2D

@export var SPEED = 100
@export var FACTION : int = 0

@export var WEAPON_RANGE = 300
@export var SPOTTING_RANGE = 200
@export var SPLAT : Resource = null

@onready var nav = $NavigationComponent
@onready var strat = $StrategyComponent
@onready var shoot = $ShootComponent



func set_move_order(coordinates):
	strat.defend(coordinates)
	
func die():
	var new_splat = SPLAT.instantiate()
	new_splat.position = position
	get_parent().add_child(new_splat) 
	queue_free()

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	add_to_group("goons")
	
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	
	# Movement
	nav.set_target(strat.get_next_move())
	var local_target = nav.get_move(position)

	if local_target :
		velocity = (local_target-position).normalized() * SPEED
		$Image.rotation = velocity.angle() + PI/2
		$Image.rotation = nav.current_bearing + PI/2
	else:
		velocity = Vector2.ZERO
	
	# Showing if attacking:
	var shooting_target = strat.get_shoot_target()
	$LineOfSight.visible = false
	if shooting_target:
		$LineOfSight.visible = true
		$LineOfSight.points = [Vector2.ZERO, shooting_target - position]
		
		# Handling the attack.
		shoot.try_shoot((shooting_target-position).angle())


	move_and_slide()
