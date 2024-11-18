extends Control

var tween: Tween
var mouse_over = false
var is_active = false
var is_spent = false

func _ready():
	# Ensure the card can receive mouse input
	mouse_filter = Control.MouseFilter.MOUSE_FILTER_PASS
	
func _process(delta: float) -> void:
	if !mouse_over and get_rect().has_point(get_global_mouse_position()):
		mouse_over = true
		_on_mouse_entered()
	elif mouse_over and !get_rect().has_point(get_global_mouse_position()):
		mouse_over = false
		_on_mouse_exited()
	
func set_content(data: CardData):
	get_node("Panel/Title").text = data.title
	
	# Currently only allowing two options, so it's kind of clanky.
	
	if data.options.size() > 0:
		get_node("Panel/Text1").text = data.options[0].text
		_generate_dice(get_node("Panel/Control1"), data.options[0].cost)
	
	if data.options.size() > 1:
		get_node("Panel/Text2").text = data.options[1].text
		_generate_dice(get_node("Panel/Control2"), data.options[1].cost)
		
func _generate_dice(target_control: Control, intervals: Array):
	
	# Clear existing dice
	for child in target_control.get_children():
		child.queue_free()

	var spacing = 10  # Space between dice
	var dice_size = Vector2(50, 50)  # Size of each dice
	var dice_nodes = []  # Store dice nodes to calculate total width

	# Create dice labels
	for interval in intervals:
		var dice_label = Label.new()
		dice_label.custom_minimum_size = dice_size
		dice_label.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
		dice_label.size_flags_vertical = Control.SIZE_SHRINK_CENTER
		dice_label.autowrap_mode = true
		dice_label.add_theme_font_size_override("font_size", 20)

		# Determine text to display
		var text = ""
		if typeof(interval) == TYPE_ARRAY and interval.size() == 2:
			# It's an interval [a, b]
			text = "%d-%d" % [interval[0], interval[1]]
		elif typeof(interval) == TYPE_INT or typeof(interval) == TYPE_FLOAT:
			# It's a single number
			text = str(interval)
		else:
			# Invalid data, skip this element
			continue

		dice_label.text = text

		# Style the dice square
		var style = StyleBoxFlat.new()
		style.bg_color = Color.WHITE
		style.border_color = Color.BLACK
		style.set_border_width_all(2)
		dice_label.add_theme_stylebox_override("panel", style)
		dice_label.add_theme_color_override("font_color", Color.BLACK)

		dice_nodes.append(dice_label)

	# Calculate total width to center the dice
	var total_width = (dice_size.x + spacing) * dice_nodes.size() - spacing
	var start_x = (target_control.size.x - total_width) / 2

	# Position and add dice labels to the target control
	for i in range(dice_nodes.size()):
		var dice_label = dice_nodes[i]
		dice_label.position = Vector2(start_x + i * (dice_size.x + spacing), 0)
		target_control.add_child(dice_label)
	
func update_draw():
	if is_active:
		$Panel.get_theme_stylebox("panel")
		
func _on_mouse_entered():
	# Animate the card moving into view
	var tween = create_tween()
	tween.tween_property( \
		self, "position:y", 0, 0.3 \
		).set_trans(Tween.TransitionType.TRANS_SINE).set_ease(Tween.EaseType.EASE_OUT)

func _on_mouse_exited():
	# Animate the card moving partially off-screen
	var offscreen_y = -size.y * 0.8  # Adjust as needed
	var tween = create_tween()
	tween.tween_property(
		self, "position:y", offscreen_y, 0.3
	).set_trans(Tween.TransitionType.TRANS_SINE).set_ease(Tween.EaseType.EASE_IN)
