extends Node2D

@export var MAX_HEALTH = 10
@onready var health = MAX_HEALTH

func receive_damage(value : float):
	health -= value
	if health <= 0: 
		get_parent().die() 
		return true
	return false


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
