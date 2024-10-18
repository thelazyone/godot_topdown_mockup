extends Node2D

@export var HEALTH = 10

@onready var health = HEALTH

func receive_damage(value : float):
	health -= value
	print("hit received! Now health is ", health)
	if health <= 0: 
		get_parent().queue_free() # TODO handle this with a KILL method instead


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
