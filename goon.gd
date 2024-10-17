extends CharacterBody2D

@export var SPEED = 100
@export var POSITION_ACC = 16

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
		print("moving")
	else:
		print("not moving")
		velocity = Vector2.ZERO
		
	move_and_slide()
