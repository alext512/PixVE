extends Node2D

# Modify these values based on the number of frames and layers
var num_frames = 7
var num_layers = 5
var button_size = Vector2(50, 50)  # Minimum size for all buttons

# GridContainer to hold the buttons
var grid

# Containers for the labels
var frame_labels
var layer_labels


func _ready():
	var main_vbox = VBoxContainer.new()
	add_child(main_vbox)
	main_vbox.custom_minimum_size = get_viewport_rect().size # Fill the entire window

	# Create the HBoxContainer
	var hbox = HBoxContainer.new()
	main_vbox.add_child(hbox)
	hbox.size_flags_vertical = Control.SIZE_EXPAND_FILL


	# Create the Clip List
	var clip_list = VBoxContainer.new()
	hbox.add_child(clip_list)
	clip_list.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	clip_list.size_flags_stretch_ratio = 0.2  # 20% of the space


	# Add a ColorRect to the clip_list
	var clip_list_bg = ColorRect.new()
	clip_list.add_child(clip_list_bg)

	clip_list_bg.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	clip_list_bg.size_flags_vertical = Control.SIZE_EXPAND_FILL
	clip_list_bg.color = Color(1, 0, 0, 1)  

	# Create the Canvas
	var canvas = VBoxContainer.new()
	hbox.add_child(canvas)
	canvas.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	canvas.size_flags_stretch_ratio = 0.8  # 80% of the space


	# Add a ColorRect to the canvas
	var canvas_bg = ColorRect.new()
	canvas.add_child(canvas_bg)

	canvas_bg.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	canvas_bg.size_flags_vertical = Control.SIZE_EXPAND_FILL
	canvas_bg.color = Color(0, 1, 0, 1)

	# Create the Frame Table
	var frame_table_vbox = VBoxContainer.new()
	main_vbox.add_child(frame_table_vbox)
	frame_table_vbox.size_flags_vertical = Control.SIZE_EXPAND_FILL


	# Add your frame table code here

	
	"""var vbox = VBoxContainer.new()
	add_child(vbox)"""

	var frame_table_hbox = HBoxContainer.new()
	frame_table_vbox.add_child(frame_table_hbox)

	# Add "Add Layer" button
	var add_layer_button = Button.new()
	add_layer_button.text = "Add Layer"
	add_layer_button.custom_minimum_size = button_size
	add_layer_button.connect("pressed", Callable(self, "_on_add_layer_button_pressed"))
	frame_table_hbox.add_child(add_layer_button)

	# Add "Add Frame" button
	var add_frame_button = Button.new()
	add_frame_button.text = "Add Frame"
	add_frame_button.custom_minimum_size = button_size
	add_frame_button.connect("pressed", Callable(self, "_on_add_frame_button_pressed"))
	frame_table_hbox.add_child(add_frame_button)


	frame_labels = HBoxContainer.new()
	frame_table_vbox.add_child(frame_labels)

	var placeholder_button = Button.new()
	frame_labels.add_child(placeholder_button)
	placeholder_button.custom_minimum_size = button_size
	placeholder_button.text = "="
	
	for i in range(num_frames):
		var frame_label = Button.new()
		frame_label.text = str(i+1)
		frame_labels.add_child(frame_label)
		frame_label.custom_minimum_size = button_size

	var main_hbox = HBoxContainer.new()
	frame_table_vbox.add_child(main_hbox)

	layer_labels = VBoxContainer.new()
	main_hbox.add_child(layer_labels)


	
	for i in range(num_layers):
		var layer_label = Button.new()
		layer_label.text = str(i+1)
		layer_labels.add_child(layer_label)
		layer_label.custom_minimum_size = button_size

	grid = GridContainer.new()
	grid.columns = num_frames
	main_hbox.add_child(grid)

	
	# Create buttons for frames and layers
	for i in range(num_layers):
		for j in range(num_frames):
			var button = Button.new()
			button.custom_minimum_size = button_size
			grid.add_child(button)

func _on_add_frame_button_pressed():
	num_frames += 1
	grid.columns = num_frames  # Update the number of columns to account for the new frame

	# Add a new button for each layer
	for i in range(num_layers):
		var button = Button.new()
		button.custom_minimum_size = button_size
		grid.add_child(button)
		
	# Add a new frame label
	var frame_label = Button.new()
	frame_label.text = str(num_frames)
	frame_labels.add_child(frame_label)
	frame_label.custom_minimum_size = button_size

func _on_add_layer_button_pressed():
	num_layers += 1

	# Add a new layer label
	var layer_label = Button.new()
	layer_label.text = str(num_layers)
	layer_labels.add_child(layer_label)
	layer_label.custom_minimum_size = button_size

	# Add a new button for each frame
	for i in range(num_frames):
		var button = Button.new()
		button.custom_minimum_size = button_size
		grid.add_child(button)
