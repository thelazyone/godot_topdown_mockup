extends Node2D

const start_1 = Vector2(100,300)
const start_2 = Vector2(1000, 300)
const start_goons = 8	
const max_goons =8

var cumulateTime = 0

const CAMERA_MARGIN : float = 200
var current_camera_position : float = 0
		
func _ready() -> void:
	add_goons(start_goons, start_1)


func add_goons(number : int, i_position : Vector2) :
	for i in range(number):
		$UnitFactory.create_unit(UnitParams.get_soldier(), i_position + Vector2(10 * i, 0), 1, self)

func add_bugs(number : int, i_position : Vector2) :
	for i in range(number):
		$UnitFactory.create_unit(UnitParams.get_bug(), i_position + Vector2(10 * i, 0), 2, self)


func _input(event: InputEvent) -> void:
	
	if event is InputEventMouseButton and event.button_index == 2:
		if event.is_pressed():
			var goons = get_tree().get_nodes_in_group("goons")
			for goon in goons:
				if goon.FACTION == 1:
					goon.set_move_order(get_viewport().get_mouse_position())
	
	if Input.is_action_just_pressed("debug"):
		Debug.debug_enabled = !Debug.debug_enabled
		
	if Input.is_action_just_pressed("debug_console"):
		Debug.debug_console_enabled = !Debug.debug_console_enabled

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	
	# Check the leftmost goon, and move the map accordingly.
	var goons = get_tree().get_nodes_in_group("goons")
	var leftmost_pos : float = 99999
	for goon in goons: 
		if goon.position.x < leftmost_pos:
			leftmost_pos = goon.position.x
	$InfiniteMap.move_camera(leftmost_pos - CAMERA_MARGIN)
	
	
	#REPOPULATE 
	cumulateTime += delta
	if cumulateTime > 1:
		var goons_counter = 0
		var bugs_counter = 0
		for goon in goons:
			match goon.FACTION:
				1: goons_counter += 1
				2: bugs_counter += 1
				
		#if goons_counter < max_goons:
			#add_goons(min(max_goons - goons_counter, 1), start_1 + Vector2(current_camera_position, 0))
		if bugs_counter < max_goons * 3:
			add_bugs(min(max_goons - bugs_counter, 5), start_2 + Vector2(current_camera_position, 0))
		cumulateTime = 0
		
	pass
