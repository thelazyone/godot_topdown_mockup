extends Area2D

@export var RADIUS = 5
@export var SPEED = 500
@export var DURATION_MS = 1000
@export var DAMAGE = 2
@export var NOCLIP_TIME_MS = 100

@onready var start_time = Time.get_ticks_msec()

var velocity = Vector2.ZERO

func shoot(angle : float):
	position = Vector2(0,0).rotated(angle)
	velocity = Vector2(1,0).rotated(angle )*SPEED
	get_node("CollisionShape2D").disabled = true 

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	self.body_entered.connect(_deal_damage)
	pass # Replace with function body.

func _draw() -> void:
	draw_circle(Vector2(0,0), 2.0, Color.WHITE)
	

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	
	position = position + velocity * delta
	
	# Ignoring all checks before the projectile is far enough from the shooter
	if Time.get_ticks_msec() - start_time < NOCLIP_TIME_MS:
		return
		
	# Enabling the collision shape: 
	get_node("CollisionShape2D").disabled = false
		
	#var targets = get_colliding_bodies()
	#if not targets.is_empty():
		#print("HIT SOMETHING!")
		#for target in targets:
			## Only first target receives damage, the others are safe!
			#if target.has_node("HealthComponent"):
				#target.get_node("HealthComponent").receive_damage(DAMAGE)
				#print("target ", target, " hit!")
				##queue_free()
		#
	# Check if projectile should disappear
	if Time.get_ticks_msec() - start_time > DURATION_MS:
		queue_free()

func _deal_damage(body):
	if body.has_node("HealthComponent"):
		body.get_node("HealthComponent").receive_damage(DAMAGE)
		queue_free()
