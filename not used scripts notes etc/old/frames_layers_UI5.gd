extends Node2D

# Modify these values based on the number of frames and layers
#var num_frames = 7
#var num_layers = 5
var button_size = Vector2(50, 50)  # Minimum size for all buttons


# UI control elements
var basic_clips_list
var complex_clips_list

var scroll_container_frame_table
var frame_table_vbox

var clips_canvas_frame_layer_splitbox

# GridContainer to hold the buttons
#var grid
var frame_layer_table_hbox # for loading images of BasicClips (?)
var file_dialog# = FileDialog.new()

# Dialog for reordering frames or layers.

var selected_clip

var main_vbox

var commonFunctions

var selected_frame
var selected_layer

var canvas

var zoom_level

var starting_canvas_size

var mouse_clicked_in_canvas

var user_message

func _process(delta):
	if mouse_clicked_in_canvas:
		# Do something continuously while mouse button is held down
		print("Mouse button is held down")
		


func _ready():
	user_message = AcceptDialog.new()
	mouse_clicked_in_canvas = false
	starting_canvas_size = Vector2(160, 144)
	zoom_level = 2
	commonFunctions = CommonFunctions.new()
	var callable_for_window_resize = Callable(self, "_on_viewport_size_changed")
	get_tree().root.connect("size_changed", callable_for_window_resize)
	#add_child(file_dialog) # For choosing imaqge for basic clips
	
	# Set the mode to open a file
	#file_dialog.rect_min_size = Vector2(800, 600)  # Change this to your desired size
	#file_dialog.popup_centered(Vector2(800, 600))  # Change this to your desired size
	
	#file_dialog.window_title = "Open an Image"  # Set a custom window title
	main_vbox = VBoxContainer.new() #VSplitContainer.new() # Contains everything
	add_child(main_vbox)
	main_vbox.custom_minimum_size = get_viewport_rect().size # Fill the entire window
	# MENU BAR
	var menu_bar = HBoxContainer.new()
	main_vbox.add_child(menu_bar)
	# Create the first menu button for "File"
	var file_menu_button = MenuButton.new()
	file_menu_button.text = "File"
	menu_bar.add_child(file_menu_button)

	# Create a popup menu for the "File" button
	var file_popup_menu = file_menu_button.get_popup() #PopupMenu.new()#file_menu_button.get_popup()
	#file_menu_button.add_child(file_popup_menu)
	file_popup_menu.add_item("New Project")
	file_popup_menu.add_item("Open Project")
	file_popup_menu.add_item("Save Project As")
	file_popup_menu.add_item("Save Project")
	file_popup_menu.add_item("Close Project")
	
	
	var callable_for_file_popup = Callable(self, "_on_popup_file_menu_item_pressed")
	file_popup_menu.id_pressed.connect(callable_for_file_popup)
	var callable_for_gui_input_file_popup = Callable(self, "_on_button_gui_input_left_click")
	#file_menu_button.gui_input.connect(callable_for_gui_input_file_popup.bind(file_popup_menu))
	#file_popup_menu.connect("id_pressed", self, "_on_menu_item_selected")

	# Create the second menu button for "Edit"
	var edit_menu_button = MenuButton.new()
	edit_menu_button.text = "Edit"
	menu_bar.add_child(edit_menu_button)

	# Create a popup menu for the "Edit" button
	var edit_popup_menu = edit_menu_button.get_popup() #PopupMenu.new() #edit_menu_button.get_popup()
	#edit_menu_button.add_child(edit_popup_menu)
	edit_popup_menu.add_item("Undo")
	edit_popup_menu.add_item("Redo")
	edit_popup_menu.add_item("Cut")
	edit_popup_menu.add_item("Copy")
	edit_popup_menu.add_item("Paste")
	
	var callable_for_edit_popup = Callable(self, "_on_popup_edit_menu_item_pressed")
	edit_popup_menu.id_pressed.connect(callable_for_edit_popup)
	var callable_for_gui_input_edit_popup = Callable(self, "_on_button_gui_input_left_click")
	#edit_menu_button.gui_input.connect(callable_for_gui_input_edit_popup.bind(edit_popup_menu))
	
	
	# Create the third menu button for "Project"
	var project_menu_button = MenuButton.new()
	project_menu_button.text = "Edit"
	menu_bar.add_child(project_menu_button)

	# Create a popup menu for the "Edit" button
	var project_popup_menu = project_menu_button.get_popup() #PopupMenu.new() #edit_menu_button.get_popup()
	#project_menu_button.add_child(project_popup_menu)
	project_popup_menu.add_item("Configure images path")
	project_popup_menu.add_item("Other stuff")

	
	var callable_for_project_popup = Callable(self, "_on_project_edit_menu_item_pressed")
	project_popup_menu.id_pressed.connect(callable_for_project_popup)
	var callable_for_gui_input_project_popup = Callable(self, "_on_button_gui_input_left_click")
	#edit_menu_button.gui_input.connect(callable_for_gui_input_edit_popup.bind(edit_popup_menu))

	clips_canvas_frame_layer_splitbox = VSplitContainer.new()
	main_vbox.add_child(clips_canvas_frame_layer_splitbox)
	clips_canvas_frame_layer_splitbox.size_flags_vertical = Control.SIZE_EXPAND_FILL
	clips_canvas_frame_layer_splitbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL

	# Create the HBoxContainer
	var clip_canvas_h_splitbox = HSplitContainer.new()#HBoxContainer.new() # Contains the clip lists and the canvas
	clips_canvas_frame_layer_splitbox.add_child(clip_canvas_h_splitbox)
	clip_canvas_h_splitbox.size_flags_vertical = Control.SIZE_EXPAND_FILL


	# Create the Clip List
	var clip_lists_v_splitbox = create_container(VSplitContainer, Control.SIZE_EXPAND_FILL, Control.SIZE_EXPAND_FILL)
	clip_lists_v_splitbox.size_flags_stretch_ratio = 0.2  # 20% of the space
	clip_canvas_h_splitbox.add_child(clip_lists_v_splitbox)
	
	# Create 2 lists
	var clip_list_scroll1 = create_container(ScrollContainer, Control.SIZE_EXPAND_FILL, Control.SIZE_EXPAND_FILL)
	clip_lists_v_splitbox.add_child(clip_list_scroll1)
	basic_clips_list = VBoxContainer.new()
	clip_list_scroll1.add_child(basic_clips_list)
	

# Create an 'Add' button for the first list
	
	var add_button1 = construct_button(Button.new(), "Add Basic Clip", button_size, "_on_add_basic_clip_pressed")
	basic_clips_list.add_child(add_button1)

	
	var clip_list_scroll2 = create_container(ScrollContainer, Control.SIZE_EXPAND_FILL, Control.SIZE_EXPAND_FILL)
	clip_lists_v_splitbox.add_child(clip_list_scroll2)
	complex_clips_list = VBoxContainer.new()
	clip_list_scroll2.add_child(complex_clips_list)
	
	# Create an 'Add' button for the first list
	var add_button2 = construct_button(Button.new(), "Add Complex Clip", button_size, "_on_add_complex_clip_pressed")
	complex_clips_list.add_child(add_button2)
	

	# Create the Canvas
	var scroll_container_canvas = create_container(ScrollContainer, Control.SIZE_EXPAND_FILL, Control.SIZE_EXPAND_FILL)
	clip_canvas_h_splitbox.add_child(scroll_container_canvas)
	canvas = Panel.new()
	canvas.set_name("Canvas")
	scroll_container_canvas.add_child(canvas)
	canvas.custom_minimum_size = Vector2(starting_canvas_size.x * zoom_level, starting_canvas_size.y * zoom_level)
	

	# Create the Frame Table

	scroll_container_frame_table = create_container(ScrollContainer, Control.SIZE_EXPAND_FILL, Control.SIZE_EXPAND_FILL)
	
	frame_table_vbox = VBoxContainer.new()
	clips_canvas_frame_layer_splitbox.add_child(scroll_container_frame_table)
	scroll_container_frame_table.add_child(frame_table_vbox)


	# Add your frame table code here
	var frame_table_hbox = HBoxContainer.new()
	frame_table_vbox.add_child(frame_table_hbox)

	# Add "Add Layer" button
	var add_layer_button = construct_button(Button.new(), "Add Layer", button_size, "_on_add_layer_button_pressed")
	frame_table_hbox.add_child(add_layer_button)

	# Add "Add Frame" button
	var add_frame_button = construct_button(Button.new(), "Add Frame", button_size, "_on_add_frame_button_pressed")
	frame_table_hbox.add_child(add_frame_button)
	
	# Debug button
	var debug_button = construct_button(Button.new(), "Debug", button_size, "_on_debug_button_pressed")
	frame_table_hbox.add_child(debug_button)
	
	var reconstruct_frame_layer_table_button = construct_button(Button.new(), "Reconstruct Table", button_size, "_on_reconstruct_frame_layer_table_button_pressed")
	frame_table_hbox.add_child(reconstruct_frame_layer_table_button)


"""
	frame_layer_table_hbox = HBoxContainer.new()
	frame_table_vbox.add_child(frame_layer_table_hbox)
	
	var placeholder_button = construct_button(Button.new(), "=", button_size, "_placeholder_function")
	frame_layer_table_hbox.add_child(VBoxContainer.new()) # Adding the first column of the frame layer table that has the layer labels.
	frame_layer_table_hbox.get_child(0).add_child(placeholder_button)
	
	
	# Creating frame labels
	for i in range(num_frames):
		var frame_label = construct_button(NumberedLabelButton.new(i+1), str(i+1), button_size, "_on_frame_label_button_pressed") #STARTS FROM 1

		frame_layer_table_hbox.add_child(VBoxContainer.new()) # IMPORTANT: starting with 1 since 0 is for the layer labels
		frame_layer_table_hbox.get_child(i+1).add_child(frame_label)
		
		# Create a PopupMenu for the frame_label button
		var popup_menu = PopupMenu.new()
		frame_label.add_child(popup_menu)
		
		# Add an item to the PopupMenu
		popup_menu.add_item("Reorder frame")
		popup_menu.add_item("Delete frame")
		
		# Create a callable that references the _on_popup_menu_item_pressed method on this object
		var callable_for_popup = Callable(self, "_on_popup_menu_item_pressed_label_frame")
		
		# Connect the signal to the callable
		popup_menu.id_pressed.connect(callable_for_popup.bind(frame_label))
		# Create a callable that references the _on_button_gui_input method on this object
		var callable_for_gui_input = Callable(self, "_on_button_gui_input")
		
		# Connect the frame_label's gui_input signal to the _on_button_gui_input method
		frame_label.gui_input.connect(callable_for_gui_input.bind(popup_menu))
		
	var main_hbox = HBoxContainer.new()
	frame_table_vbox.add_child(main_hbox)

	#layer_labels = VBoxContainer.new()
	#main_hbox.add_child(layer_labels)


	# Creating layer labels
	for i in range(num_layers):
		var layer_label = construct_button(NumberedLabelButton.new(i+1), str(i+1), button_size, "_on_layer_label_button_pressed") #STARTS FROM 1
		layer_label.text = str(layer_label.number)
		frame_layer_table_hbox.get_child(0).add_child(layer_label)
		#layer_labels.add_child(layer_label)
		layer_label.custom_minimum_size = button_size
		#frame_labels_buttons.append(layer_label)
		
		
		# Create a PopupMenu for the layer_label button
		var popup_menu = PopupMenu.new()
		layer_label.add_child(popup_menu)
		
		# Add an item to the PopupMenu
		popup_menu.add_item("Reorder layer")
		popup_menu.add_item("Delete layer")
		
		# Create a callable that references the _on_popup_menu_item_pressed method on this object
		var callable_for_popup = Callable(self, "_on_popup_menu_item_pressed_label_layer")
		
		# Connect the signal to the callable
		popup_menu.id_pressed.connect(callable_for_popup.bind(layer_label))
		# Create a callable that references the _on_button_gui_input method on this object
		var callable_for_gui_input = Callable(self, "_on_button_gui_input")
		
		# Connect the frame_label's gui_input signal to the _on_button_gui_input method
		layer_label.gui_input.connect(callable_for_gui_input.bind(popup_menu))

	#grid = GridContainer.new()
	
	
	#grid.columns = num_frames
	#main_hbox.add_child(grid)

	
	# Create buttons for frames and layers
	for i in range(num_layers):
		#frame_layers_buttons.append([])  # Append a new array for each layer
		for j in range(num_frames):
			var button = construct_button(NumberedFrameLayerButton.new(j+1, i+1), str(j+1) + " " + str(i+1), button_size, "_on_frame_layer_button_pressed") #STARTS FROM 1
			NumberedFrameLayerButton.new(j+1, i+1) #STARTS FROM 1,1

			frame_layer_table_hbox.get_child(j+1).add_child(button) # remember, 0 is for labels of layers


			# Add the button to the correct sub-array in the 2D array
			
			# Create a PopupMenu for the frame_label button
			var popup_menu_frame_layer = PopupMenu.new()
			button.add_child(popup_menu_frame_layer)
				
			# Add an item to the PopupMenu
			popup_menu_frame_layer.add_item("Do stuff here")
				
			# Create a callable that references the _on_popup_menu_item_pressed method on this object
			var callable_for_popup_frame_layer = Callable(self, "_on_popup_menu_item_pressed_frame_layer")
			
			# Connect the signal to the callable
			popup_menu_frame_layer.id_pressed.connect(callable_for_popup_frame_layer.bind(button))
			# Create a callable that references the _on_button_gui_input method on this object
			var callable_for_gui_input_frame_layer = Callable(self, "_on_button_gui_input")
			
			# Connect the frame_label's gui_input signal to the _on_button_gui_input method
			button.gui_input.connect(callable_for_gui_input_frame_layer.bind(popup_menu_frame_layer))
			"""
			
"""
func contruct_frame_layer_table_basic_clip(basic_clip):

	var frame_layer_table_hbox_clip


	frame_layer_table_hbox_clip = HBoxContainer.new()
	frame_table_vbox.add_child(frame_layer_table_hbox_clip)
	
	var placeholder_button = construct_button(Button.new(), "=", button_size, "_placeholder_function")
	frame_layer_table_hbox_clip.add_child(VBoxContainer.new()) # Adding the first column of the frame layer table that has the layer labels.
	frame_layer_table_hbox_clip.get_child(0).add_child(placeholder_button)
	
"""
	
func contruct_frame_layer_table_clip(frames, layers, clip):

	var frame_layer_table_hbox_clip


	frame_layer_table_hbox_clip = HBoxContainer.new()
	frame_table_vbox.add_child(frame_layer_table_hbox_clip)
	
	var placeholder_button = construct_button(Button.new(), "=", button_size, "_placeholder_function")
	frame_layer_table_hbox_clip.add_child(VBoxContainer.new()) # Adding the first column of the frame layer table that has the layer labels.
	frame_layer_table_hbox_clip.get_child(0).add_child(placeholder_button)
	
		# Creating frame labels
	for i in range(frames):
		var frame_label = construct_button(NumberedLabelButton.new(i+1), str(i+1), button_size, "_on_frame_label_button_pressed") #STARTS FROM 1

		frame_layer_table_hbox_clip.add_child(VBoxContainer.new()) # IMPORTANT: starting with 1 since 0 is for the layer labels
		frame_layer_table_hbox_clip.get_child(i+1).add_child(frame_label)
		
		# Create a PopupMenu for the frame_label button
		var popup_menu = PopupMenu.new()
		frame_label.add_child(popup_menu)
		
		# Add an item to the PopupMenu
		popup_menu.add_item("Reorder frame")
		popup_menu.add_item("Delete frame")
		
		# Create a callable that references the _on_popup_menu_item_pressed method on this object
		var callable_for_popup = Callable(self, "_on_popup_menu_item_pressed_label_frame")
		
		# Connect the signal to the callable
		popup_menu.id_pressed.connect(callable_for_popup.bind(frame_label))
		# Create a callable that references the _on_button_gui_input method on this object
		var callable_for_gui_input = Callable(self, "_on_button_gui_input")
		
		# Connect the frame_label's gui_input signal to the _on_button_gui_input method
		frame_label.gui_input.connect(callable_for_gui_input.bind(popup_menu))
		
	var main_hbox = HBoxContainer.new()
	frame_table_vbox.add_child(main_hbox)

	
		# Creating layer labels
	for i in range(layers):
		var layer_label = construct_button(NumberedLabelButton.new(i+1), str(i+1), button_size, "_on_layer_label_button_pressed") #STARTS FROM 1
		layer_label.text = str(layer_label.number)
		frame_layer_table_hbox_clip.get_child(0).add_child(layer_label)
		#layer_labels.add_child(layer_label)
		layer_label.custom_minimum_size = button_size
		#frame_labels_buttons.append(layer_label)
		
		
		# Create a PopupMenu for the layer_label button
		var popup_menu = PopupMenu.new()
		layer_label.add_child(popup_menu)
		
		# Add an item to the PopupMenu
		popup_menu.add_item("Reorder layer")
		popup_menu.add_item("Delete layer")
		
		# Create a callable that references the _on_popup_menu_item_pressed method on this object
		var callable_for_popup = Callable(self, "_on_popup_menu_item_pressed_label_layer")
		
		# Connect the signal to the callable
		popup_menu.id_pressed.connect(callable_for_popup.bind(layer_label))
		# Create a callable that references the _on_button_gui_input method on this object
		var callable_for_gui_input = Callable(self, "_on_button_gui_input")
		
		# Connect the frame_label's gui_input signal to the _on_button_gui_input method
		layer_label.gui_input.connect(callable_for_gui_input.bind(popup_menu))
	
	#grid = GridContainer.new()
	
	
	#grid.columns = num_frames
	#main_hbox.add_child(grid)

	
	# Create buttons for frames and layers
	for i in range(layers):
		#frame_layers_buttons.append([])  # Append a new array for each layer
		for j in range(frames):
			var button = construct_button(NumberedFrameLayerButton.new(j+1, i+1), str(j+1) + " " + str(i+1), button_size, "_on_frame_layer_button_pressed") #STARTS FROM 1
			#NumberedFrameLayerButton.new(j+1, i+1) #STARTS FROM 1,1

			frame_layer_table_hbox_clip.get_child(j+1).add_child(button) # remember, 0 is for labels of layers


			# Add the button to the correct sub-array in the 2D array
			
			# Create a PopupMenu for the frame_label button
			var popup_menu_frame_layer = PopupMenu.new()
			button.add_child(popup_menu_frame_layer)
				
			# Add an item to the PopupMenu
			popup_menu_frame_layer.add_item("Do stuff here")
				
			# Create a callable that references the _on_popup_menu_item_pressed method on this object
			var callable_for_popup_frame_layer = Callable(self, "_on_popup_menu_item_pressed_frame_layer")
			
			# Connect the signal to the callable
			popup_menu_frame_layer.id_pressed.connect(callable_for_popup_frame_layer.bind(button))
			# Create a callable that references the _on_button_gui_input method on this object
			var callable_for_gui_input_frame_layer = Callable(self, "_on_button_gui_input")
			
			# Connect the frame_label's gui_input signal to the _on_button_gui_input method
			button.gui_input.connect(callable_for_gui_input_frame_layer.bind(popup_menu_frame_layer))
			if clip is BasicClip && i == 0: # Basic clips have only 1 layer, so i == 0 could be ommitted. The code is a bit complicated here, but it is done so that the same code could be reused.
				button.frameLayer.clip_used = clip
	return frame_layer_table_hbox_clip # Clips should be able to reference this.

func _on_add_frame_button_pressed(arg1 = null):
	if selected_clip == null || !(selected_clip is ComplexClip): # This ONLY works when a ComplexClip is selected, otherwise, it doesn't work.
		print("frames layers UI No ComplexClip selected!")
		return
	#num_frames += 1
	#grid.columns = num_frames  # Update the number of columns to account for the new frame
	frame_layer_table_hbox.add_child(VBoxContainer.new())
	
	# Add a new frame label
	var frame_label = NumberedLabelButton.new(frame_layer_table_hbox.get_child_count() - 1)
	var callable = Callable(self, "_on_frame_label_button_pressed").bind(frame_label)
	frame_label.connect("pressed", callable)
	frame_label.text = str(frame_label.get_number())
	frame_layer_table_hbox.get_child(frame_layer_table_hbox.get_child_count() - 1).add_child(frame_label)
	frame_label.custom_minimum_size = button_size
	
	# Create a PopupMenu for the frame_label button
	var popup_menu = PopupMenu.new()
	frame_label.add_child(popup_menu)
		
	# Add an item to the PopupMenu
	popup_menu.add_item("Reorder frame")
	popup_menu.add_item("Delete frame")
		
	# Create a callable that references the _on_popup_menu_item_pressed method on this object
	var callable_for_popup = Callable(self, "_on_popup_menu_item_pressed_label_frame")
	
	# Connect the signal to the callable
	popup_menu.id_pressed.connect(callable_for_popup.bind(frame_label))
	# Create a callable that references the _on_button_gui_input method on this object
	var callable_for_gui_input = Callable(self, "_on_button_gui_input")
	
	# Connect the frame_label's gui_input signal to the _on_button_gui_input method
	frame_label.gui_input.connect(callable_for_gui_input.bind(popup_menu))
		
	# Add a new button for each layer
	for i in range(frame_layer_table_hbox.get_child(0).get_child_count()):
		if i != 0: # 0 IS FOR LABEL (do we need to add 1 to the loop? check)
			var button = construct_button(NumberedFrameLayerButton.new(frame_layer_table_hbox.get_child_count() - 1, i), str(frame_layer_table_hbox.get_child_count() - 1) + " " + str(i), button_size, "_on_frame_layer_button_pressed")
			frame_layer_table_hbox.get_child(frame_layer_table_hbox.get_child_count() - 1).add_child(button)
			
				# Create a PopupMenu for the frame_label button
			var popup_menu_frame_layer = PopupMenu.new()
			button.add_child(popup_menu_frame_layer)
				
			# Add an item to the PopupMenu
			popup_menu_frame_layer.add_item("Do stuff here")
				
			# Create a callable that references the _on_popup_menu_item_pressed method on this object
			var callable_for_popup_frame_layer = Callable(self, "_on_popup_menu_item_pressed_frame_layer")
			
			# Connect the signal to the callable
			popup_menu_frame_layer.id_pressed.connect(callable_for_popup_frame_layer.bind(button))
			# Create a callable that references the _on_button_gui_input method on this object
			var callable_for_gui_input_frame_layer = Callable(self, "_on_button_gui_input")
			
			# Connect the frame_label's gui_input signal to the _on_button_gui_input method
			button.gui_input.connect(callable_for_gui_input_frame_layer.bind(popup_menu_frame_layer))
			
		


func _on_add_layer_button_pressed(arg1 = null):
	if selected_clip == null || !(selected_clip is ComplexClip): # This ONLY works when a ComplexClip is selected, otherwise, it doesn't work.
		print("frames layers UI No ComplexClip selected!")
		return
	#num_layers += 1

	# Add a new layer label
	var layer_label = construct_button(NumberedLabelButton.new(frame_layer_table_hbox.get_child(0).get_child_count()), str(frame_layer_table_hbox.get_child(0).get_child_count()), button_size, "_on_frame_label_button_pressed")

	
	#layer_labels.add_child(layer_label)
	layer_label.custom_minimum_size = button_size
	frame_layer_table_hbox.get_child(0).add_child(layer_label)
	# Add a new button for each frame
	
		# Create a PopupMenu for the layer_label button
	var popup_menu = PopupMenu.new()
	layer_label.add_child(popup_menu)
		
	# Add an item to the PopupMenu
	popup_menu.add_item("Reorder layer")
	popup_menu.add_item("Delete layer")
		
	# Create a callable that references the _on_popup_menu_item_pressed method on this object
	var callable_for_popup = Callable(self, "_on_popup_menu_item_pressed_label_frame")
		
	# Connect the signal to the callable
	popup_menu.id_pressed.connect(callable_for_popup.bind(layer_label))
	# Create a callable that references the _on_button_gui_input method on this object
	var callable_for_gui_input = Callable(self, "_on_button_gui_input")
	
	# Connect the frame_label's gui_input signal to the _on_button_gui_input method
	layer_label.gui_input.connect(callable_for_gui_input.bind(popup_menu))
	
	
	for i in range(frame_layer_table_hbox.get_child_count()):
		if i != 0:
			var button = construct_button(NumberedFrameLayerButton.new(i, frame_layer_table_hbox.get_child(0).get_child_count() - 1), str(i) + " " + str(frame_layer_table_hbox.get_child(0).get_child_count() - 1), button_size, "_on_frame_layer_button_pressed")
			

			frame_layer_table_hbox.get_child(i).add_child(button) #remem
			
			# Create a PopupMenu for the frame_label button
			var popup_menu_frame_layer = PopupMenu.new()
			button.add_child(popup_menu_frame_layer)
				
			# Add an item to the PopupMenu
			popup_menu_frame_layer.add_item("Do stuff here")
				
			# Create a callable that references the _on_popup_menu_item_pressed method on this object
			var callable_for_popup_frame_layer = Callable(self, "_on_popup_menu_item_pressed_frame_layer")
			
			# Connect the signal to the callable
			popup_menu_frame_layer.id_pressed.connect(callable_for_popup_frame_layer.bind(button))
			# Create a callable that references the _on_button_gui_input method on this object
			var callable_for_gui_input_frame_layer = Callable(self, "_on_button_gui_input")
			
			# Connect the frame_label's gui_input signal to the _on_button_gui_input method
			button.gui_input.connect(callable_for_gui_input_frame_layer.bind(popup_menu_frame_layer))
			

func _on_debug_button_pressed(arg1 = null):
	print("DEBUG")

func _on_add_basic_clip_pressed(arg1 = null) -> void:
	create_new_clip("BasicClip")
	#load_image_file


# Add clip buttons
func _on_add_complex_clip_pressed(arg1 = null) -> void:
	create_new_clip("ComplexClip")
	
	
func _on_button_gui_input(event, popup_menu: PopupMenu):
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_RIGHT and event.pressed:
	# If the event is a right mouse button press, show the popup menu
		popup_menu.set_position(get_global_mouse_position())
		popup_menu.popup()

func _on_button_gui_input_left_click(event, popup_menu: PopupMenu):
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
	# If the event is a right mouse button press, show the popup menu
		#popup_menu.set_position(get_global_mouse_position())
		popup_menu.popup()


	
func delete_clip_button(clip_button):
	clip_button.queue_free()
	
func _on_popup_menu_item_pressed(id : int, button_to_delete : Button) -> void:
	if id == 0:  # The ID of the "Delete clip" item
	# Delete the button
		button_to_delete.queue_free()






func _on_popup_menu_item_pressed_label_frame(id : int, label_selected: NumberedLabelButton) -> void:
	if id == 0:
		create_dialog_window_for_frame_or_layer_reorder("reorder_frame", label_selected.get_number())
	elif id == 0:  # The ID of the "Delete Frame" or "Delete Layer" item
	# Delete the label
	#frame_layers_buttons
		frame_layer_table_hbox.get_child(label_selected.get_number()).queue_free()
		# REORDER THE NUMBERS HERE IF YOU WANT
		# Add here any other logic you need for updating the other UI elements




func _on_popup_menu_item_pressed_label_layer(id : int, label_selected: NumberedLabelButton) -> void:
	if id == 0:
		create_dialog_window_for_frame_or_layer_reorder("reorder_layer", label_selected.get_number())
	elif id == 1:  # The ID of the "Delete Frame" or "Delete Layer" item
	# Delete the label
		for i in range(frame_layer_table_hbox.get_child_count()):
				frame_layer_table_hbox.get_child(i).get_child(label_selected.get_number()).queue_free()
		# AFTER DELETION, REORDER THE NUMBERS HERE IF YOU WANT
		# Add here any other logic you need for updating the other UI elements


func _on_popup_menu_item_pressed_frame_layer(id : int, frame_layer_button: NumberedFrameLayerButton) -> void:
	if id == 0:  # The ID of the "Delete Frame" or "Delete Layer" item
	# Delete the label
		print("frames_layers_UI pressed popum menu of frame layer " + str(frame_layer_button.get_frame()) + " " + str(frame_layer_button.get_layer()))
		# Add here any other logic you need for updating the other UI elements
		
		

func _on_frame_layer_button_pressed(button : NumberedFrameLayerButton) -> void:
	print("frames layers UI, frame and layer: " + str(button.get_frame()) + " " + str(button.get_layer()))
	selected_frame = button.get_frame()
	selected_layer = button.get_layer()

func _on_frame_label_button_pressed(button : NumberedLabelButton) -> void:
	print("frames layers UI, frame label: " + str(button.get_number()))
	selected_frame = button.get_number()
	render_frame(selected_frame)

func _on_layer_label_button_pressed(button : NumberedLabelButton) -> void:
	print("frames layers UI, layer label: " + str(button.get_number()))
	selected_layer = button.get_number()
	
	
	
# Functions for readability purposes
func create_container(container_type, size_flags_horizontal, size_flags_vertical):
	var container = container_type.new()
	container.size_flags_horizontal = size_flags_horizontal
	container.size_flags_vertical = size_flags_vertical
	return container

	
func construct_button(button, button_text, custom_minimum_size, on_pressed_func_call): # WARNING: THE SAME FUNCTION EXISTS IN ComplexClip (and Basic Clip)
	button.text = button_text
	button.custom_minimum_size = custom_minimum_size
	var callable = Callable(self, on_pressed_func_call).bind(button)
	button.connect("pressed", callable)
	return button

func create_dialog_window_for_frame_or_layer_reorder(type, init_frame_or_layer_number):
	var dialog = AcceptDialog.new()
	var line_edit = LineEdit.new()
	line_edit.set_name("Input") #we need to retrieve it later
	line_edit.text = str(init_frame_or_layer_number)
	dialog.add_child(line_edit)
	add_child(dialog)
	dialog.dialog_text = "test text:"
	var callable = Callable(self, "_on_dialog_confirmed_frame_or_layer_reorder").bind(dialog, type, init_frame_or_layer_number)
	dialog.connect("confirmed", callable)
	dialog.popup_centered()
	
	


func _on_dialog_confirmed_frame_or_layer_reorder(dialog, type, frame_or_layer_to_reorder):
	var line_edit = dialog.get_node("Input")
	var text_input = line_edit.text
	var new_index = int(text_input)
	if new_index !=0 :#is_int(text_input):
		if type == "reorder_frame":
			frame_layer_table_hbox.move_child(frame_layer_table_hbox.get_child(frame_or_layer_to_reorder), new_index) # TODO: WE NEED ADDITIONAL CHECKS
			reconstruct_frame_table_attributes()
		elif type == "reorder_layer":
			for i in range(frame_layer_table_hbox.get_child_count()):
				frame_layer_table_hbox.get_child(i).move_child(frame_layer_table_hbox.get_child(i).get_child(frame_or_layer_to_reorder), new_index)
				reconstruct_frame_table_attributes()
	else:
		print("frames layers UI Invalid input")

func reconstruct_frame_table_attributes():
	for i in range(frame_layer_table_hbox.get_child_count()):
		for j in range(frame_layer_table_hbox.get_child(i).get_child_count()):
			if i == 0: #layer labels
				if j != 0: #1st label is the placeholder
					frame_layer_table_hbox.get_child(i).get_child(j).set_number(j) # Setting layer labels
			elif j == 0:
				frame_layer_table_hbox.get_child(i).get_child(j).set_number(i) # Setting Frame labels
			else:
				frame_layer_table_hbox.get_child(i).get_child(j).set_frame(i)
				frame_layer_table_hbox.get_child(i).get_child(j).set_layer(j)

func _on_reconstruct_frame_layer_table_button_pressed(arg1 = null):
	for i in range(frame_layer_table_hbox.get_child_count()):
		for j in range(frame_layer_table_hbox.get_child(i).get_child_count()):
			if i == 0: #layer labels
				if j != 0: #1st label is the placeholder
					frame_layer_table_hbox.get_child(i).get_child(j).text = str(j) # Setting layer labels
			elif j == 0:
				frame_layer_table_hbox.get_child(i).get_child(j).text = str(i) # Setting Frame labels
			else:
				frame_layer_table_hbox.get_child(i).get_child(j).text = str(i) + " " + str(j)
				

func _placeholder_function(arg1 = null):
	print("frames_layers_UI.gd placeholder clicked!")


func create_new_clip(clip_type):
	if clip_type == "BasicClip":
		load_image_file_for_basic_clip() # after selection of the image, the dialog for naming and setting dimensions is called.
		"""
		var dialog = AcceptDialog.new()

		var vbox = VBoxContainer.new()
		dialog.add_child(vbox)

		var hbox_name = HBoxContainer.new()
		var label_name = Label.new()
		label_name.text = "Name: "
		var line_edit_name = LineEdit.new()
		line_edit_name.set_name("InputName")
		hbox_name.add_child(label_name)
		hbox_name.add_child(line_edit_name)
		vbox.add_child(hbox_name)

		var hbox_dim1 = HBoxContainer.new()
		var label_dim1 = Label.new()
		label_dim1.text = "Width: "
		var line_edit_dim1 = LineEdit.new()
		line_edit_dim1.set_name("InputDim1") # If dimension is not valid integer, it will be 0 (because of the int(x) function). A dimension of 0 (and generally dimensions smaller than the image), means the image is a single image, and not a spritesheet.
		hbox_dim1.add_child(label_dim1)
		hbox_dim1.add_child(line_edit_dim1)
		vbox.add_child(hbox_dim1)

		var hbox_dim2 = HBoxContainer.new()
		var label_dim2 = Label.new()
		label_dim2.text = "Height: "
		var line_edit_dim2 = LineEdit.new()
		line_edit_dim2.set_name("InputDim2") # see InputDim1
		hbox_dim2.add_child(label_dim2)
		hbox_dim2.add_child(line_edit_dim2)
		vbox.add_child(hbox_dim2)

		add_child(dialog)

		var callable = Callable(self, "_on_dialog_confirmed_create_new_clip").bind(dialog, clip_type)
		dialog.connect("confirmed", callable)
		dialog.popup_centered()
"""
	elif clip_type == "ComplexClip":
		var dialog = AcceptDialog.new()
		
		var vbox = VBoxContainer.new()
		vbox.set_name("vbox")
		dialog.add_child(vbox)
		
		var hbox_name = HBoxContainer.new()
		hbox_name.set_name("hbox_name")
		var label_name = Label.new()
		label_name.text = "Name: "
		
		var line_edit_name = LineEdit.new()
		line_edit_name.set_name("InputName") #we need to retrieve it later
		
		hbox_name.add_child(label_name)
		hbox_name.add_child(line_edit_name)
		vbox.add_child(hbox_name)
		
		
		#var vbox = VBoxContainer.new()
		
		#dialog.add_child(line_edit)
		add_child(dialog)
		var callable = Callable(self, "_on_dialog_confirmed_create_new_clip").bind(dialog, clip_type)
		dialog.connect("confirmed", callable)
		dialog.popup_centered()
	#var new_button = Button.new()
	#new_button.text = "New Button"
	#clip_list1.add_child(new_button)

func _on_dialog_confirmed_create_new_clip(dialog, clip_type, image = null, path = null):
	var line_edit = dialog.get_node("vbox/hbox_name/InputName")
	var text_input = line_edit.text
	#var new_index = int(text_input)
	if text_input == "":
		print("clip name cannot be empty")
		return
	else: # like that, Basic and Complex clips CANNOT have same names. Is that desirable?
		for i in range(basic_clips_list.get_child_count()):
			if i == 0: # the 0 index is for the "add clip"
				continue
			if text_input == basic_clips_list.get_child(i).clip.clip_name:
				print("clip name already exists. Please select another name.")
				return
		for i in range(complex_clips_list.get_child_count()):
			if i == 0: # the 0 index is for the "add clip"
				continue
			if text_input == complex_clips_list.get_child(i).clip.clip_name:
				print("clip name already exists. Please select another name.")
				return

	var clip_button
	#clip_button.text = text_input
	var popup_menu = PopupMenu.new()
	popup_menu.add_item("Rename clip")
	popup_menu.add_item("Delete clip")
	if clip_type == "BasicClip":
		# Possibly add additional options for BasicClip
		clip_button = ClipButton.new()#text_input, BasicClip)
		clip_button.clip = BasicClip.new()
		clip_button.clip.set_clip_name(text_input)
		
		construct_button(clip_button, text_input, button_size, "_select_selected_clip")
		var line_edit_dim1 = dialog.get_node("vbox/hbox_dim1/InputDim1")
		var line_edit_dim2 = dialog.get_node("vbox/hbox_dim2/InputDim2")
		clip_button.clip.image = image
		clip_button.clip.path = path
		print("frames_layers_ui a " + str(image.get_size()))
		clip_button.clip.set_image_dimensions(Vector2(int(line_edit_dim1.text), int(line_edit_dim2.text)))#dimensions = Vector2(int(line_edit_dim1.text), int(line_edit_dim2.text))
		var callable_for_popup = Callable(self, "_on_basic_clip_popup_menu_item_pressed")
		popup_menu.id_pressed.connect(callable_for_popup.bind(clip_button))
		
		basic_clips_list.add_child(clip_button)
		
		print("frame layers UI debug " + str(clip_button.clip.get_sprites()))
		clip_button.clip.frame_layer_table_hbox = contruct_frame_layer_table_clip(clip_button.clip.get_sprites(), 1, clip_button.clip)
		
		
		
		#load_image_file(clip_button.clip) #The new BasicClip is an attribute of clip_button. We need to select an image for it.
		# TODO: Handle error image (currently, the basic clip will still be created even if invalid image selected)
		# EXECUTED BEFORE INPUT of name/dimensions INSTEAD
		
	elif clip_type == "ComplexClip":
		# Possibly add additional options for ComplexClip
		clip_button = ClipButton.new()#text_input, ComplexClip)
		clip_button.clip = ComplexClip.new()
		clip_button.set_clip_name(text_input)
		
		var callable_for_popup = Callable(self, "_on_complex_clip_popup_menu_item_pressed")
		popup_menu.id_pressed.connect(callable_for_popup.bind(clip_button))
		complex_clips_list.add_child(clip_button)
		construct_button(clip_button, text_input, button_size, "_select_selected_clip")
		#default some falues
		clip_button.clip.frame_layer_table_hbox = contruct_frame_layer_table_clip(4, 2, clip_button.clip)
	clip_button.add_child(popup_menu)
	var callable_for_gui_input = Callable(self, "_on_button_gui_input")
	clip_button.gui_input.connect(callable_for_gui_input.bind(popup_menu))
	selected_clip = clip_button.clip
	


func _on_basic_clip_popup_menu_item_pressed(id : int, clip_button : Button) -> void:
	if id == 0: #rename
		var dialog = AcceptDialog.new()
		var line_edit = LineEdit.new()
		line_edit.set_name("Input") #we need to retrieve it later
		dialog.add_child(line_edit)
		add_child(dialog)
		var callable = Callable(self, "_on_dialog_confirmed_name_clip").bind(dialog, clip_button)
		dialog.connect("confirmed", callable)
		dialog.popup_centered()
		pass
	if id == 1:
		delete_clip_button(clip_button)

func _on_complex_clip_popup_menu_item_pressed(id : int, clip_button : Button) -> void:
	if id == 0: #rename
		var dialog = AcceptDialog.new()
		var line_edit = LineEdit.new()
		line_edit.set_name("Input") #we need to retrieve it later
		dialog.add_child(line_edit)
		add_child(dialog)
		var callable = Callable(self, "_on_dialog_confirmed_name_clip").bind(dialog, clip_button)
		dialog.connect("confirmed", callable)
		dialog.popup_centered()
	if id == 1:
		delete_clip_button(clip_button)

func _on_dialog_confirmed_name_clip(dialog, clip_button):
	var line_edit = dialog.get_node("Input")
	var text_input = line_edit.text
	if text_input == "":
		print("clip name cannot be empty")
		return
	else:
		for i in range(basic_clips_list.get_child_count()):
			if i == 0: # the 0 index is for the "add clip"
				continue
			if text_input == basic_clips_list.get_child(i).clip.clip_name:
				print("clip name already exists. Please select another name.")
				return
		for i in range(complex_clips_list.get_child_count()):
			if i == 0: # the 0 index is for the "add clip"
				continue
			if text_input == complex_clips_list.get_child(i).clip.clip_name:
				print("clip name already exists. Please select another name.")
				return
	clip_button.set_clip_name(text_input)

func _on_popup_file_menu_item_pressed(id: int):
	if id == 0:
		print("New Project selected.")
	elif id == 1:
		print("Open Project selected.")
		load_project()
	elif id == 2:
		print("Save Project As.")
		save_project_as()
	elif id == 3:
		print("Save Project selected.")
	elif id == 3:
		print("Close Project selected.")

func _on_popup_edit_menu_item_pressed(id: int):
	if id == 0:
		print("Undo selected.")
	elif id == 1:
		print("Redo selected.")
	elif id == 2:
		print("Cut selected.")
	elif id == 3:
		print("Copy selected.")
	elif id == 4:
		print("Paste selected.")



		
func load_image_file(basic_clip):
	# Remove the old FileDialog if it exists. This deletes the existing connections.
	if file_dialog != null:
		file_dialog.queue_free()
	file_dialog = FileDialog.new()
	add_child(file_dialog)
	file_dialog.access = FileDialog.ACCESS_FILESYSTEM
	file_dialog.file_mode = FileDialog.FILE_MODE_OPEN_FILE
	var callable = Callable(self, "_on_file_selected_for_basic_clip").bind(basic_clip)
	file_dialog.connect("file_selected", callable)
	file_dialog.popup_centered(Vector2(800, 600))
	
func load_image_file_for_basic_clip():
	# Remove the old FileDialog if it exists. This deletes the existing connections.
	if file_dialog != null:
		file_dialog.queue_free()
	file_dialog = FileDialog.new()
	add_child(file_dialog)
	file_dialog.access = FileDialog.ACCESS_FILESYSTEM
	file_dialog.file_mode = FileDialog.FILE_MODE_OPEN_FILE
	var callable = Callable(self, "_on_file_selected_for_basic_clip_and_create_clip")
	file_dialog.connect("file_selected", callable)
	file_dialog.popup_centered(Vector2(800, 600))
	
func save_project_as():
	# Remove the old FileDialog if it exists. This deletes the existing connections.
	if file_dialog != null:
		file_dialog.queue_free()
	file_dialog = FileDialog.new()
	add_child(file_dialog)
	file_dialog.access = FileDialog.ACCESS_FILESYSTEM
	file_dialog.file_mode = FileDialog.FILE_MODE_SAVE_FILE 
	var callable = Callable(self, "_on_file_selected_for_save_project_as")
	file_dialog.connect("file_selected", callable)
	file_dialog.popup_centered(Vector2(800, 600))
	
func load_project():
	# Remove the old FileDialog if it exists. This deletes the existing connections.
	if file_dialog != null:
		file_dialog.queue_free()
	file_dialog = FileDialog.new()
	add_child(file_dialog)
	file_dialog.access = FileDialog.ACCESS_FILESYSTEM
	file_dialog.file_mode = FileDialog.FILE_MODE_OPEN_FILE 
	var callable = Callable(self, "_on_file_selected_for_load_project")
	file_dialog.connect("file_selected", callable)
	file_dialog.popup_centered(Vector2(800, 600))

func save_write_to_file(file):
	#saving as JSON. 
	var data = {}  # Initialize an empty dictionary
	# Add basic_clips array to the dictionary
	data["basic_clips"] = []  # Initialize an empty array
	for i in range(1, basic_clips_list.get_child_count()):
		var clip_button = basic_clips_list.get_child(i)
		#var basic_clip = clip_button.clip
		data["basic_clips"].append({
			"clip_name": clip_button.clip.clip_name,
			"dimensions": {"x": clip_button.clip.dimensions.x, "y": clip_button.clip.dimensions.y},
			"path": clip_button.clip.path
		})
		# Add complex_clips array to the dictionary
	data["complex_clips"] = []  # Initialize an empty array
	for k in range(1, complex_clips_list.get_child_count()):#clip_button in complex_clips_list:
		var clip_button = complex_clips_list.get_child(k)
		var complex_clip = clip_button.clip
		var clip_frames = complex_clip.frame_layer_table_hbox.get_child_count() -1 #-1 because of labels
		var clip_layers = complex_clip.frame_layer_table_hbox.get_child(0).get_child_count() -1
		var frame_layer_data = []  # This will be an array of arrays
		#for frame_layer_row in clip_button.clip.frame_layer_table_hbox:
		for i in range(1, clip_button.clip.frame_layer_table_hbox.get_child_count()): #skipping the 1st element, which is labels
			var frame_layer_row = clip_button.clip.frame_layer_table_hbox.get_child(i)
			var frame_layer_row_data = []  # This will be an array of dictionaries
			#for frame_layer in frame_layer_row:
			for j in range(1, frame_layer_row.get_child_count()): #skipping 1st elements, which is labels.
				var frame_layer_button = frame_layer_row.get_child(j)
				if frame_layer_button.frameLayer.clip_used == null:
					pass
				else:
					frame_layer_row_data.append({
						"frame": frame_layer_button.frameLayer.frame_number,#i, #STARTS FROM 1
						"layer": frame_layer_button.frameLayer.layer_number,#j, #STARTS FROM 1
						"clip_used" : frame_layer_button.frameLayer.clip_used.clip_name,
						"frame_of_clip": frame_layer_button.frameLayer.frame_of_clip,
						"offset_framelayer": {
							"x": frame_layer_button.frameLayer.offset_framelayer.x,
							"y": frame_layer_button.frameLayer.offset_framelayer.y,
						}
					})
			frame_layer_data.append(frame_layer_row_data)
		data["complex_clips"].append({
			"frames": clip_frames,
			"layers": clip_layers,
			"clip_name": clip_button.clip.clip_name,
			"frame_layer_table": frame_layer_data
		})
		
	var json_text = JSON.stringify(data)  # Convert dictionary to JSON text
	
	file.store_string(json_text)  # Write JSON text to file

	file.close()

	


func load_open_file(file):
	# Read the entire file content into a string
	var json_text = file.get_as_text()
	# Parse the JSON text to reconstruct the dictionary
	var json_object = JSON.new()
	var parse_err = json_object.parse(json_text) # possibly use the err to check
	var data = json_object.get_data()#.result
	print(json_text)
	
	#removing current clips
	for i in range(1, basic_clips_list.get_child_count()):
		basic_clips_list.get_child(i).queue_free()
		
	for i in range(1, complex_clips_list.get_child_count()):
		complex_clips_list.get_child(i).queue_free()
		
	# Load basic_clips
	for basic_clip_data in data["basic_clips"]:
		var clip = BasicClip.new()  # or whatever your constructor is
		clip.clip_name = basic_clip_data["clip_name"]
		clip.dimensions = Vector2(basic_clip_data["dimensions"]["x"], basic_clip_data["dimensions"]["y"])
		clip.path = basic_clip_data["path"]

		var image = Image.new()
		if image.load(clip.path) == OK:
			clip.image = image

		else:
			print("while loading, image of BasicClip ", clip.clip_name, " could not be loaded.")
		clip.set_image_dimensions(clip.dimensions)
		clip.frame_layer_table_hbox = contruct_frame_layer_table_clip(clip.get_sprites(), 1, clip)
		var clip_button = ClipButton.new()#text_input, BasicClip)
		clip_button.clip = clip
		clip_button.set_clip_name(clip.clip_name)
		basic_clips_list.add_child(clip_button)
		
			
		
		
	# Load complex_clips
	var frame_layer_placeholders = []  # list of FrameLayer objects that have a placeholder for clip_used
	#This is because we first need to load all clips before we reference clips to FrameLayers.
	for complex_clip_data in data["complex_clips"]:
		var clip = ComplexClip.new()  # or whatever your constructor is
		clip.clip_name = complex_clip_data["clip_name"]
		#clip.frames = complex_clip_data["frames"]
		#clip.layers = complex_clip_data["layers"]
		# Load frame_layer_table
		clip.frame_layer_table_hbox = contruct_frame_layer_table_clip(complex_clip_data["frames"], complex_clip_data["layers"], clip)
		#var frame_layer_with_temp_clip = []
		for frame_layer_row_data in complex_clip_data["frame_layer_table"]:
			#var frame_layer_row = []  # or however you create a new row
			for frame_layer_data in frame_layer_row_data:
				var frame_layer = FrameLayer.new(frame_layer_data["frame"], frame_layer_data["layer"])  # or whatever your constructor is
				#frame_layer_placeholders.append(frame_layer)
				#frame_layer.frame = frame_layer_data["frame"]
				#frame_layer.layer = frame_layer_data["layer"]
				frame_layer.clip_used = frame_layer_data["clip_used"]  # temporarily storing it as string. After loading all clips, it will be loaded as a clip.
				frame_layer.frame_of_clip = frame_layer_data["frame_of_clip"]
				frame_layer.offset_framelayer = Vector2(frame_layer_data["offset_framelayer"]["x"], frame_layer_data["offset_framelayer"]["y"])
				frame_layer_placeholders.append(frame_layer)#frame_layer_row.append(frame_layer)
				clip.frame_layer_table_hbox.get_child(frame_layer_data["frame"]).get_child(frame_layer_data["layer"]).frameLayer = frame_layer #append(frame_layer_row)
		# Add clip to complex_clips_list (you will need to implement this)
		var clip_button = ClipButton.new()#text_input, BasicClip)
		clip_button.clip = clip
		clip_button.set_clip_name(clip.clip_name)
		complex_clips_list.add_child(clip_button)
	for frame_layer in frame_layer_placeholders:
		var clip_name = frame_layer.clip_used
		for i in range(1, complex_clips_list.get_child_count()): # Remember, the 1st one is the "add clip" button.
			var debug_test = false
			if clip_name == complex_clips_list.get_child(i).clip.clip_name:
				frame_layer.clip_used = complex_clips_list.get_child(i).clip
				if !debug_test:
					debug_test = true
				else:
					print("There seems to be a second clip with the same name. This shouldn't happen.")
				
	
		
		
	
	

func _on_viewport_size_changed():
	main_vbox.custom_minimum_size = get_viewport_rect().size # Fill the entire window
	#main_vbox.rect_min_size = get_viewport_rect().size
	# Do whatever you need to do when the window changes!
	print ("Viewport size changed")

func _on_project_edit_menu_item_pressed(id: int):
	if id == 0:
		print("reconfigure path")
#func _notification(what):
	#if what == NOTIFICATION_WM_SIZE_CHANGED:
	#	main_vbox.rect_min_size = get_viewport_rect().size

func _on_file_selected_for_save_project_as(path):
	var file = FileAccess.open(path, FileAccess.WRITE)
	var err = file.get_error()
	# Check for errors
	if err == OK:
		pass
		#user_message.text = "Saved successfully."
	else:
		if err == ERR_CANT_OPEN:
			user_message.text = "Could not open the file."
			print("Could not open the file.")
			return
		elif err == ERR_UNCONFIGURED:
			user_message.text = "FileAccess object is unconfigured."
			print("FileAccess object is unconfigured.")
			return
		elif err == ERR_UNAVAILABLE:
			user_message.text = "Operation is not available/allowed on this platform."
			print("Operation is not available/allowed on this platform.")
			return
		elif err == ERR_BUSY:
			user_message.text = "Called operation is busy. Try again later."
			print("Called operation is busy. Try again later.")
			return
		elif err == ERR_FILE_ALREADY_IN_USE:
			user_message.text = "File is already in use (might be opened by other thread)."
			print("File is already in use (might be opened by other thread).")
			return
		elif err == ERR_FILE_CANT_OPEN:
			user_message.text = "File failed to open."
			print("File failed to open.")
			return
		else:
			user_message.text = "Save failed."
			return
	# Write to the file
	save_write_to_file(file)

	
func _on_file_selected_for_save_project(path):
	pass
	#var file = FileAccess.open(path, FileAccess.WRITE)
	#file.open(path, FileAccess.WRITE)
	# Write your data to the file here
	#file.close()

func _on_file_selected_for_load_project(path):
	var file = FileAccess.open(path, FileAccess.READ)
	var err = file.get_error()
	# Check for errors
	if err == OK:
		var content = file.get_as_text()
		print("loading project...")
		#user_message.text = "Saved successfully."
	else:
		if err == ERR_CANT_OPEN:
			user_message.text = "Could not open the file."
			print("Could not open the file.")
			return
		elif err == ERR_UNCONFIGURED:
			user_message.text = "FileAccess object is unconfigured."
			print("FileAccess object is unconfigured.")
			return
		elif err == ERR_UNAVAILABLE:
			user_message.text = "Operation is not available/allowed on this platform."
			print("Operation is not available/allowed on this platform.")
			return
		elif err == ERR_BUSY:
			user_message.text = "Called operation is busy. Try again later."
			print("Called operation is busy. Try again later.")
			return
		elif err == ERR_FILE_ALREADY_IN_USE:
			user_message.text = "File is already in use (might be opened by other thread)."
			print("File is already in use (might be opened by other thread).")
			return
		elif err == ERR_FILE_CANT_OPEN:
			user_message.text = "File failed to open."
			print("File failed to open.")
			return
		else:
			user_message.text = "Load failed."
			return
	load_open_file(file)



func _on_file_selected_for_basic_clip_and_create_clip(path):
	var image = Image.new()
	if image.load(path) == OK:

		print("frame layer ui Image size: ", image.get_size())

		
		var dialog = AcceptDialog.new()

		var vbox = VBoxContainer.new()
		vbox.set_name("vbox")
		dialog.add_child(vbox)

		var hbox_name = HBoxContainer.new()
		hbox_name.set_name("hbox_name")
		
		var label_name = Label.new()
		label_name.text = "Name: "
		var line_edit_name = LineEdit.new()
		line_edit_name.set_name("InputName")
		hbox_name.add_child(label_name)
		hbox_name.add_child(line_edit_name)
		vbox.add_child(hbox_name)

		var hbox_dim1 = HBoxContainer.new()
		hbox_dim1.set_name("hbox_dim1")
		var label_dim1 = Label.new()
		label_dim1.text = "Width: "
		var line_edit_dim1 = LineEdit.new()
		line_edit_dim1.set_name("InputDim1") # If dimension is not valid integer, it will be 0 (because of the int(x) function). A dimension of 0 (and generally dimensions smaller than the image), means the image is a single image, and not a spritesheet.
		hbox_dim1.add_child(label_dim1)
		hbox_dim1.add_child(line_edit_dim1)
		vbox.add_child(hbox_dim1)

		var hbox_dim2 = HBoxContainer.new()
		hbox_dim2.set_name("hbox_dim2")
		var label_dim2 = Label.new()
		label_dim2.text = "Height: "
		var line_edit_dim2 = LineEdit.new()
		line_edit_dim2.set_name("InputDim2") # see InputDim1
		hbox_dim2.add_child(label_dim2)
		hbox_dim2.add_child(line_edit_dim2)
		vbox.add_child(hbox_dim2)

		add_child(dialog)

		var callable = Callable(self, "_on_dialog_confirmed_create_new_clip").bind(dialog, "BasicClip", image, path)
		dialog.connect("confirmed", callable)
		dialog.popup_centered()
	else:
		print("frames layers UI image not OK.")



func _select_selected_clip(button : ClipButton):
	frame_table_vbox.remove_child(selected_clip.frame_layer_table_hbox)
	var clip = button.clip
	selected_clip = clip
	frame_table_vbox.add_child(selected_clip.frame_layer_table_hbox)
	selected_frame = 1
	selected_layer = 1
	render_frame(selected_frame)
	
	
func render_frame(frame):
	if selected_clip != null:
		selected_clip.render_frame(frame, Vector2(0,0), canvas, zoom_level)
	print("frames layers UI selected frame: " , frame)

func _input(event):
	if event is InputEventMouseButton:
		if event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
			var mouse_pos = event.position
			var local_pos = mouse_pos - canvas.get_global_position()
			if Rect2(Vector2(), canvas.custom_minimum_size).has_point(local_pos):#canvas.to_local(mouse_pos)):
				print("frames layers ui Left mouse button pressed inside the canvas")
				mouse_clicked_in_canvas = true
		elif !event.pressed and event.button_index == MOUSE_BUTTON_LEFT and mouse_clicked_in_canvas:
			mouse_clicked_in_canvas = false
			print("frames layers ui Left mouse button released")
			
		if event.is_pressed() and Input.is_key_pressed(KEY_CTRL):
			if event.button_index == MOUSE_BUTTON_WHEEL_UP:
				zoom_level +=1
				if zoom_level >10:
					zoom_level = 10
				else:
					canvas.custom_minimum_size = Vector2(starting_canvas_size.x * zoom_level, starting_canvas_size.y * zoom_level)
					render_frame(selected_frame)
				print("frame layer ui zoom level: ", zoom_level)
				get_viewport().set_input_as_handled()  # stop the event from propagating further
			elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
				zoom_level -=1
				render_frame(selected_frame)
				if zoom_level <1:
					zoom_level = 1
				else:
					canvas.custom_minimum_size = Vector2(starting_canvas_size.x * zoom_level, starting_canvas_size.y * zoom_level)
					render_frame(selected_frame)
				get_viewport().set_input_as_handled()  # stop the event from propagating further
				print("frame layer ui zoom level: ", zoom_level)
			
"""
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		var mouse_pos = event.position
		var local_pos = mouse_pos - canvas.get_global_position()
		if Rect2(Vector2(), canvas.custom_minimum_size).has_point(local_pos):#canvas.to_local(mouse_pos)):
			print("Left mouse button pressed inside the canvas")
			mouse_clicked_in_canvas = true
		elif !event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
			mouse_clicked_in_canvas = false
			print("Left mouse button released inside the canvas")
	if event is InputEventMouseButton:
		if event.is_pressed() and Input.is_key_pressed(KEY_CTRL):
			if event.button_index == MOUSE_BUTTON_WHEEL_UP:
				zoom_level +=1
				if zoom_level >10:
					zoom_level = 10
				else:
					canvas.custom_minimum_size = Vector2(starting_canvas_size.x * zoom_level, starting_canvas_size.y * zoom_level)
					render_frame(selected_frame)
				print("frame layer ui zoom level: ", zoom_level)
				get_viewport().set_input_as_handled()  # stop the event from propagating further
			elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
				zoom_level -=1
				render_frame(selected_frame)
				if zoom_level <1:
					zoom_level = 1
				else:
					canvas.custom_minimum_size = Vector2(starting_canvas_size.x * zoom_level, starting_canvas_size.y * zoom_level)
					render_frame(selected_frame)
				get_viewport().set_input_as_handled()  # stop the event from propagating further
				print("frame layer ui zoom level: ", zoom_level)
		
func _unhandled_input(event):
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		var mouse_pos = event.position
		var local_pos = mouse_pos - canvas.get_global_position()
		if Rect2(Vector2(), canvas.custom_minimum_size).has_point(local_pos):#canvas.to_local(mouse_pos)):
			print("Left mouse button pressed inside the canvas")
			"""
