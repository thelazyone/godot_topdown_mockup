extends Control

signal option_area_hover(ranges : Array)
signal option_area_left


func show_dialog(card_counter):
	
	# Show the InteractiveArea
	_center_dialog()
	visible = true
	
	# Ensure it processes during pause
	process_mode = Node.PROCESS_MODE_ALWAYS
	
	# Clear any existing children
	for n in get_children():
		#remove_child(n)
		n.queue_free()

	# Set up the InteractiveArea properties (optional styling)
	anchor_left = 0
	anchor_right = 1
	anchor_top = 0
	anchor_bottom = 1
	modulate = Color(0, 0, 0, 0.5)  # Semi-transparent background

	print("Adding buttons to the interactive area!")

	# Create the buttons
	var button_texts = ["More Enemies", "Nah I'm Good"]  # Replace with actual options
	var button_width = 150
	var button_height = 50
	var spacing = 20
	var total_width = button_width * button_texts.size() + spacing * (button_texts.size() - 1)
	var start_x = (size.x - total_width) / 2

	# Create a container for the options
	var hbox = HBoxContainer.new()
	hbox.anchor_left = 0
	hbox.anchor_right = 1
	hbox.anchor_top = 0
	hbox.anchor_bottom = 1
	hbox.process_mode = Node.PROCESS_MODE_ALWAYS
	add_child(hbox)

	# Iterate over the options in card_data
	for option in LevelData.level_cards[card_counter].options:
		# Create a Button to represent the option as a big rectangle
		var option_button = Button.new()
		option_button.text = ""  # We'll add labels inside
		option_button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		option_button.size_flags_vertical = Control.SIZE_EXPAND_FILL
		option_button.process_mode = Node.PROCESS_MODE_ALWAYS
		option_button.focus_mode = Control.FOCUS_ALL
		option_button.clip_contents = true  # So content doesn't overflow
		option_button.custom_minimum_size = Vector2(200, 200)  # Adjust size as needed

		# Style the button to look like a big rectangle
		var style = StyleBoxFlat.new()
		style.bg_color = Color(0.9, 0.9, 0.9)  # Light gray background
		style.set_border_width_all(2)
		style.border_color = Color.BLACK
		option_button.add_theme_stylebox_override("normal", style)

		# Create a VBoxContainer to hold the cost display and the text
		var vbox = VBoxContainer.new()
		vbox.anchor_left = 0
		vbox.anchor_right = 1
		vbox.anchor_top = 0
		vbox.anchor_bottom = 1
		vbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		vbox.size_flags_vertical = Control.SIZE_EXPAND_FILL
		vbox.alignment = BoxContainer.ALIGNMENT_CENTER
		option_button.add_child(vbox)

		# Generate the cost display
		var cost_container = Control.new()
		cost_container.custom_minimum_size = Vector2(150, 60)  # Adjust as needed
		cost_container.process_mode = Node.PROCESS_MODE_ALWAYS
		_generate_dice(cost_container, option.cost)
		vbox.add_child(cost_container)

		# Create the Label for the option text
		var option_label = Label.new()
		option_label.text = option.title  # Use option.title or option.text as needed
		option_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		option_label.size_flags_vertical = Control.SIZE_EXPAND_FILL
		option_label.autowrap_mode = true
		option_label.add_theme_font_size_override("font_size", 18)
		vbox.add_child(option_label)

		# Check if the option is valid using is_valid_assignment()
		var is_valid = DiceMath.dice_satisfy_slots(LevelData.dice_values, option.cost)
		if not is_valid:
			option_button.disabled = true  # Disable the button
			option_button.modulate = Color(0.5, 0.5, 0.5, 1)  # Grey out the button

		# Connect the button's pressed signal
		var current_option = option  # Capture the current option
		option_button.pressed.connect(_on_interactive_button_pressed.bind(current_option.cost, current_option.effect))
		
		# Connect mouse_entered and mouse_exited signals for highlighting dice
		option_button.mouse_entered.connect(_on_option_mouse_entered.bind(current_option.cost))
		option_button.mouse_exited.connect(_on_option_mouse_exited)

		hbox.add_child(option_button)
		
func _on_option_mouse_entered(cost):
	emit_signal("option_area_hover", cost)

func _on_option_mouse_exited():
	emit_signal("option_area_left")

func _generate_dice(target_control: Control, intervals: Array):
	# Clear existing dice
	for child in target_control.get_children():
		child.queue_free()

	var spacing = 10  # Space between dice
	var dice_size = Vector2(50, 50)  # Size of each dice

	# Use an HBoxContainer to arrange dice
	var hbox = HBoxContainer.new()
	hbox.anchor_left = 0.5
	hbox.anchor_right = 0.5
	hbox.anchor_top = 0.5
	hbox.anchor_bottom = 0.5
	hbox.alignment = BoxContainer.AlignmentMode.ALIGNMENT_CENTER
	target_control.add_child(hbox)

	# Create dice labels
	for interval in intervals:
		var dice_label = Label.new()
		dice_label.custom_minimum_size = dice_size
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

		hbox.add_child(dice_label)


func _center_dialog():
	position = %Camera.position - size/2

func _on_interactive_button_pressed(cost : Array, effect : Callable):
	print("Button pressed, cost is ", cost ,", calling effect")
	
	if DiceMath.dice_satisfy_slots(LevelData.dice_values, cost):
		print("There are enough dice for this!")
	else: 
		print("not enough dice!")
		return
	
	if effect == null or !effect.is_valid():
		print("Effect is null or invalid")

	# Hide and clear the InteractiveArea
	visible = false
	for n in get_children():
		n.queue_free()
	
	# Resume the game
	get_tree().paused = false
	
	# Generate the new sector and increment the counter
	var call_result = effect.call()
	var horde = []
	if typeof(call_result) != TYPE_ARRAY:
		print("Card Function is not returning an array!")
	else:
		horde = call_result
	%InfiniteMap._generate_new_sector(horde)
