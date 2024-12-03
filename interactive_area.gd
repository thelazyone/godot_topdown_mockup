extends Control

signal option_area_hover(ranges: Array)
signal option_area_left

var current_option_index: int = -1
var current_card_counter: int = -1

@onready var dice_container = %DiceContainer

func show_dialog(card_counter):
	current_card_counter = card_counter
	
	# Initial check - if the whole thing has been completed, calling "you won!"
	if card_counter >= LevelData.level_cards.size():
		print("End of test demo! Back to splashscreen!")
		get_tree().paused = false
		get_tree().change_scene_to_file("res://scenes/end.tscn")
		return


	# Show the InteractiveArea
	_center_dialog()
	visible = true
	z_index = 99

	# Ensure it processes during pause
	process_mode = Node.PROCESS_MODE_ALWAYS

	# Clear any existing children
	for n in get_children():
		n.queue_free()

	print("Adding buttons to the interactive area!")

	# Create a container for the options
	var hbox = HBoxContainer.new()
	add_child(hbox)
	hbox.anchor_left = ANCHOR_BEGIN
	hbox.anchor_right = ANCHOR_END
	hbox.anchor_top = ANCHOR_BEGIN
	hbox.anchor_bottom = ANCHOR_END
	hbox.process_mode = Node.PROCESS_MODE_ALWAYS

	# Iterate over the options in card_data
	var option_counter: int = 0
	for option in LevelData.level_cards[card_counter].options:
		var option_button = Button.new()
		option_button.set_h_size_flags(Control.SIZE_EXPAND_FILL)
		option_button.set_v_size_flags(Control.SIZE_EXPAND_FILL)
		option_button.set_process(Node.PROCESS_MODE_ALWAYS)
		option_button.set_focus_mode(Control.FOCUS_ALL)
		option_button.set_clip_contents(true)

		# Style the button to have a black background
		var style = StyleBoxFlat.new()
		style.set_border_color(Color.BLACK)
		style.set_border_width_all(2)
		option_button.add_theme_stylebox_override("normal", style)

		# Create a VBoxContainer to hold the cost display and the text
		var vbox = VBoxContainer.new()
		option_button.add_child(vbox)
		vbox.set_anchors_preset(Control.PRESET_FULL_RECT)
		vbox.set_h_size_flags(Control.SIZE_EXPAND)
		vbox.set_v_size_flags(Control.SIZE_EXPAND)
		vbox.set_alignment(BoxContainer.ALIGNMENT_CENTER)

		# Generate the cost display
		var cost_container = Control.new()
		vbox.add_child(cost_container)
		cost_container.set_anchors_preset(Control.PRESET_FULL_RECT)
		cost_container.set_custom_minimum_size(Vector2(150, 150))
		option_button.set_process(Node.PROCESS_MODE_ALWAYS)
		_generate_dice(cost_container, option.cost)

		# Create the Label for the option text
		var option_label = Label.new()
		option_label.text = option.title  # Use option.title or option.text as needed
		option_label.set_h_size_flags(Control.SIZE_EXPAND_FILL)
		option_label.set_v_size_flags(Control.SIZE_EXPAND_FILL)
		option_label.set_autowrap_mode(TextServer.AUTOWRAP_WORD)
		option_label.set_horizontal_alignment(HORIZONTAL_ALIGNMENT_CENTER)
		option_label.add_theme_font_size_override("font_size", 18)
		option_label.add_theme_color_override("font_color", Color.RED)
		vbox.add_child(option_label)

		# Check if the option is valid using is_valid_assignment()
		var is_valid = DiceMath.dice_satisfy_slots(LevelData.dice_values, option.cost)
		if not is_valid:
			option_button.disabled = true  # Disable the button
			option_button.modulate = Color(0.5, 0.5, 0.5, 1)  # Grey out the button

		# Connect the button's pressed signal
		var current_option = option  # Capture the current option
		option_button.pressed.connect(_on_interactive_button_pressed.bind(option_counter, current_option.cost, current_option.effect))

		# Connect mouse_entered and mouse_exited signals for highlighting dice
		option_button.mouse_entered.connect(_on_option_mouse_entered.bind(current_option.cost))
		option_button.mouse_exited.connect(_on_option_mouse_exited)

		hbox.add_child(option_button)

		option_counter += 1  # Increment the option counter

func _on_interactive_button_pressed(option_index: int, cost: Array, effect: Callable):

	if DiceMath.dice_satisfy_slots(LevelData.dice_values, cost):
		print("There are enough dice for this!")
	else:
		print("Not enough dice!")
		return

	# Store the selected option index for later use
	current_option_index = option_index

	# Inform the dice_container that we are in selection mode
	dice_container.start_dice_selection(cost, effect)

	# Connect to the dice_selection_complete and dice_selection_canceled signals
	dice_container.dice_selection_complete.connect(_on_dice_selection_complete)
	dice_container.dice_selection_canceled.connect(_on_dice_selection_canceled)

	# Disable all option buttons to prevent interaction during dice selection
	for child in get_children():
		if child is Button:
			child.disabled = true

func _on_dice_selection_complete():
	print("Dice selection complete, proceeding to generate the new sector")

	# Hide the InteractiveArea
	visible = false

	# Proceed to generate the new sector
	# Resume the game
	get_tree().paused = false

	# Generate the new sector and increment the counter
	if current_option_index == -1:
		print("Invalid option selected")
		return

	var selected_option = LevelData.level_cards[current_card_counter].options[current_option_index]
	%InfiniteMap._generate_new_sector(selected_option.spawn)
	var main = get_node("/root/Main");
	selected_option.effect.call(main)
	
	# Reset selection state
	current_option_index = -1
	current_card_counter = -1

	# Disconnect signals
	if dice_container.dice_selection_complete.is_connected(_on_dice_selection_complete):
		dice_container.dice_selection_complete.disconnect(_on_dice_selection_complete)
	if dice_container.dice_selection_canceled.is_connected(_on_dice_selection_canceled):
		dice_container.dice_selection_canceled.disconnect(_on_dice_selection_canceled)

	dice_container.end_dice_selection()

func _on_dice_selection_canceled():
	print("Dice selection canceled, returning to options")

	# Reset stored option choice
	current_option_index = -1

	# Re-enable all option buttons
	for child in get_children():
		if child is Button:
			child.disabled = false

	# Disconnect signals
	if dice_container.dice_selection_complete.is_connected(_on_dice_selection_complete):
		dice_container.dice_selection_complete.disconnect(_on_dice_selection_complete)
	if dice_container.dice_selection_canceled.is_connected(_on_dice_selection_canceled):
		dice_container.dice_selection_canceled.disconnect(_on_dice_selection_canceled)

func _on_option_mouse_entered(cost):
	emit_signal("option_area_hover", cost)

func _on_option_mouse_exited():
	emit_signal("option_area_left")

func _center_dialog():
	position = %Camera.position - size / 2
	position.y -= get_viewport_rect().size.y / 8

func _generate_dice(target_control: Control, intervals: Array):
	# Clear existing dice
	for child in target_control.get_children():
		child.queue_free()

	var dice_size = Vector2(50, 50)  # Size of each dice

	# Use an HBoxContainer to arrange dice
	var hbox = HBoxContainer.new()
	hbox.set_alignment(BoxContainer.ALIGNMENT_CENTER)
	hbox.add_theme_constant_override("separation", 40)
	hbox.set_anchors_preset(Control.PRESET_FULL_RECT)
	target_control.add_child(hbox)


	# Create dice labels
	if intervals.is_empty():
		intervals.append([])
	for interval in intervals:
		# Determine text to display
		var text = ""
		if typeof(interval) == TYPE_ARRAY and interval.size() == 2:
			if interval[0] == interval[1]:
				text = str(interval[0])
			else:
				text = "%d-%d" % [interval[0], interval[1]]
		else:
			text = "FREE"

		# Create a Panel to represent the dice
		var dice_panel = Panel.new()
		#dice_panel.set_anchors_preset(Control.PRESET_FULL_RECT)
		dice_panel.custom_minimum_size = dice_size
		dice_panel.size_flags_vertical = Control.SIZE_SHRINK_CENTER

		# Style the dice panel
		var panel_style = StyleBoxFlat.new()
		panel_style.bg_color = Color(0.2, 0.2, 0.2, 1)  # Dark grey background
		panel_style.set_corner_radius_all(5)
		panel_style.border_color = Color.BLACK
		panel_style.set_border_width_all(2)
		dice_panel.add_theme_stylebox_override("panel", panel_style)

		# Create the Label for the dice text
		var dice_label = Label.new()
		dice_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		dice_label.size_flags_vertical = Control.SIZE_EXPAND_FILL
		dice_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		dice_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		dice_label.autowrap_mode = true
		dice_label.add_theme_font_size_override("font_size", 20)
		dice_label.add_theme_color_override("font_color", Color(1, 1, 1, 1))
		dice_label.text = text
		dice_label.set_anchors_preset(Control.PRESET_FULL_RECT)

		# Add the label to the panel
		dice_panel.add_child(dice_label)

		# Add the panel to the hbox
		
		hbox.add_child(dice_panel)
