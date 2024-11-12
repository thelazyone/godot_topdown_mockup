extends Node2D

const start_1 = Vector2(100,300)
const start_2 = Vector2(1000, 300)
const start_goons = 8	
const max_goons =8
const max_bugs = 16
#const start_goons = 1	
#const max_goons =1
#const max_bugs = 1

var cumulateTime = 0

const CAMERA_MARGIN : float = 200
var current_camera_position : float = 0
		
func _ready() -> void:
	add_units(start_goons, UnitParams.Types.SOLDIER, 1, start_1)
	add_units(1,  UnitParams.Types.TOTEM, 2, start_2)

func add_units(number : int, type : UnitParams.Types, faction : int, i_position : Vector2) :
	for i in range(number):
		$UnitFactory.create_unit(UnitParams.get_unit_params(type), i_position + Vector2(10 * i, 0), faction, self)

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
	current_camera_position = $InfiniteMap.get_camera_position()
	
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
		if bugs_counter < max_bugs:
			add_units(min(max_bugs - bugs_counter, 16), UnitParams.Types.BUG, 2, start_2 + Vector2(current_camera_position, 0))
		cumulateTime = 0
		
	pass
