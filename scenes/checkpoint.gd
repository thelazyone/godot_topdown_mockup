extends Node2D

@export var CONTROL_FACTION : float = 0.5
@export var CONTROL_SPEED = 0.3
@export var CONTROL_AREA : float = 100

var kill_if_blue : bool = false

func _ready() -> void:
	add_to_group("checkpoints")
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	
	# Checking if one faction has a majority of troops on it
	var all_goons = get_tree().get_nodes_in_group("goons")
	var count_1 : float = 0
	var count_2 : float = 0
	for goon in all_goons:
		if goon.global_position.distance_to(global_position) < CONTROL_AREA:
			match goon.FACTION:
				1: count_1 += 1
				2: count_2 += 1
				
	if count_1 != 0 or count_2 != 0:
		CONTROL_FACTION += (count_1 - count_2) / (count_1 + count_2) * delta * CONTROL_SPEED
		CONTROL_FACTION = clamp(CONTROL_FACTION, 0., 1.)
		
		# Call required to force the redraw of the circle with the new colour 
		queue_redraw()
	
	if kill_if_blue:
		if CONTROL_FACTION == 1.:
			queue_free()
	
	# If it reaches negative positions,
	if global_position.x < 20:
		queue_free()

func _draw():
	
	# Color is grey when in the middle, blue when controleld byfaction 1, red when 2.
	var color = Color.GRAY
	if CONTROL_FACTION < 0.5:
		color = color.lerp(Color.RED, (1. - 2.*CONTROL_FACTION))
	else:
		color = color.lerp(Color.BLUE, (2. * CONTROL_FACTION - 1))
	
	draw_circle(Vector2(20,20), 20.0, color)
