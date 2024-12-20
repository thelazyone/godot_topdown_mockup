extends Camera2D

var camera_target_position : float = 0
const CAMERA_SPEED : float = 150
const CAMERA_SPRING : float = 0.05
const CAMERA_MARGIN : float = 200
const CAMERA_UPDATE_PERIOD_S = .02
var last_update_s = 0

@onready var camera_offset_h = position.x

func update_camera_target(new_position : float):
	camera_target_position = max(camera_target_position, new_position)

func get_camera_position_h() -> float:
	return position.x - camera_offset_h
		
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	# Periodic check of position, but not too often.
	last_update_s += delta
	if last_update_s > CAMERA_UPDATE_PERIOD_S:
		last_update_s = 0
		var bounding_rect = Utilities.get_latest_containing_rect_for_faction(1)
		update_camera_target(bounding_rect.position.x - CAMERA_MARGIN)
	
	# Moving the camera if target has changed.
	_move_with_bound(delta)
		
	pass

func _move_with_bound(delta: float):
	var camera_spread = camera_target_position - get_camera_position_h()
	var elastic_speed = min(1, camera_spread * CAMERA_SPRING) * CAMERA_SPEED
	var move_amount = elastic_speed * delta * sign(camera_spread)
	position.x += min(abs(camera_spread), abs(move_amount)) * sign(camera_spread)
