extends CharacterBody2D

@export var SPEED = 500
@export var POSITION_ACC = 8

@onready var nav = $NavigationComponent

var target = null


func set_move_target(coordinates):
	target = coordinates
	nav.set_target(target)

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	nav.setup(get_viewport().size, POSITION_ACC)
	
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	
	#print("calling get_move with position ", position)
	var local_target = nav.get_move(position)
	if local_target :
		velocity = (local_target-position).normalized() * SPEED
		$Image.rotation = velocity.angle() + PI/2
	else:
		velocity = Vector2.ZERO
		
	move_and_slide()
