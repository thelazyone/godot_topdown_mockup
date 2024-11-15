extends Control

var tween: Tween
var mouse_over = false

func _ready():
	# Ensure the card can receive mouse input
	mouse_filter = Control.MouseFilter.MOUSE_FILTER_PASS
	
	# Create a Tween for animations
	tween = Tween.new()
	
func _process(delta: float) -> void:
	
	if !mouse_over and get_rect().has_point(get_global_mouse_position()):
		mouse_over = true
		_on_mouse_entered()
	elif mouse_over and !get_rect().has_point(get_global_mouse_position()):
		mouse_over = false
		_on_mouse_exited()
	

func set_content(data: CardData):
	get_node("Panel/Title").text = data.title
	get_node("Panel/Text1").text = data.text_1 # TODO add cost_1
	get_node("Panel/Text2").text = data.text_2 # TODO add cost_2

func _on_mouse_entered():
	print("mouse entered card ", self)

	# Animate the card moving into view
	var tween = create_tween()
	tween.tween_property( \
		self, "position:y", 0, 0.3 \
		).set_trans(Tween.TransitionType.TRANS_SINE).set_ease(Tween.EaseType.EASE_OUT)

func _on_mouse_exited():
	print("mouse exited card ", self)

	# Animate the card moving partially off-screen
	var offscreen_y = -size.y * 0.8  # Adjust as needed
	var tween = create_tween()
	tween.tween_property(
		self, "position:y", offscreen_y, 0.3
	).set_trans(Tween.TransitionType.TRANS_SINE).set_ease(Tween.EaseType.EASE_IN)
