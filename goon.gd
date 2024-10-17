extends CharacterBody2D

@export var SPEED = 100
@export var POSITION_ACC = 8
@export var FACTION : int = 0

@export var RANGE = 200

@onready var nav = $NavigationComponent
@onready var strat = $StrategyComponent



func set_move_order(coordinates):
	strat.defend(coordinates)

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	nav.setup(get_viewport().size, POSITION_ACC)
	add_to_group("goons")
	
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	
	nav.set_target(strat.get_next_move())
	var local_target = nav.get_move(position)
	if local_target :
		velocity = (local_target-position).normalized() * SPEED
		$Image.rotation = velocity.angle() + PI/2
	else:
		velocity = Vector2.ZERO
		
	move_and_slide()
