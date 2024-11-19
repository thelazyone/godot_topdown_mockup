extends Node2D

const start_1 = Vector2(100,300)
const start_2 = Vector2(1000, 300)
const start_goons = 16	

var cumulateTime = 0

const CAMERA_MARGIN : float = 200
var current_camera_position : float = 0
		
func _ready() -> void:
	
	
	# Testing the new UI TODO TBR
	LevelData.dice_values = [1, 1, 1, 2, 3, 4, 5, 5, 6]
	$UI/DiceContainer.display_dice(LevelData.dice_values)
	
	pass

func add_units(number : int, type : UnitParams.Types, i_id: int, faction : int, i_position : Vector2) :
	for i in range(number):
		$UnitFactory.create_unit(UnitParams.get_unit_params(type), i_position + Vector2(10 * i, 0), i_id, faction, self)

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
	var goon_found = false
	for goon in goons: 
		if goon.FACTION == 1 and goon.global_position.x < leftmost_pos:
			leftmost_pos = goon.global_position.x
			goon_found = true
	if goon_found: 
		$InfiniteMap.move_camera(leftmost_pos - CAMERA_MARGIN)
	current_camera_position = $InfiniteMap.get_camera_position()
		
	pass
