extends Node2D

@export var PROJECTILE : Resource = null
@export var COOLDOWN_TIME_MS = 500

@onready var last_shot_tick_ms = Time.get_ticks_msec()

func try_shoot(angle):
	if Time.get_ticks_msec() - last_shot_tick_ms > COOLDOWN_TIME_MS:
		var curr_projectile = PROJECTILE.instantiate()
		add_child(curr_projectile)
		curr_projectile.FACTION = get_parent().FACTION
		
		curr_projectile.shoot(angle)
		last_shot_tick_ms = Time.get_ticks_msec()


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
