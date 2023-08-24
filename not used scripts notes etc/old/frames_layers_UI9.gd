extends Node2D

# Variables used and handled often:
var basic_clips_list # Contains clip buttons (ClipButton) of the basic clips.
var complex_clips_list # Contains clip buttons (ClipButton) of the complex clips.
var selected_clip # active/ selected clip. The selected clip is rendered on the canvas. Click on a clip button to select a clip.
var selected_frame # The selected frame of the selected clip is rendered on the canvas. Click on a frame label to change selected frame.
var selected_layer # The selected layer.
var zoom_level # Zoom level of the canvas. Use ctrl + mouse wheel on the canvas to zoom in.
var user_message # NOT FULLY IMPLEMENTED YET
var project_images_path # Path where images/ spritesheet files should be saved, so that BasicClips can access them (subfolders are fine). BasicClips save a path of the image/ spritesheet, relative to this folder.

# Variables used often, but not changed:
var button_size = Vector2(50, 50)  # Minimum size for all buttons
var canvas

# Variables used mostly once:
var scroll_container_frame_table
var frame_table_vbox
var clips_canvas_frame_layer_splitbox
var main_vbox
var starting_canvas_size # The size of the canvas in pixels. Later the user should be able to change the canvas size.

# Helper variables
var mouse_clicked_in_canvas
var color_bg
var color_text
var file_dialog
var dialog


func _process(delta):
	if mouse_clicked_in_canvas: # NOT FULLY IMPLEMENTED: This is for setting offsets of clips by moving the rendered images on the canvas.
		# Do something continuously while mouse button is held down
		print("Mouse button is held down")

func _ready():
	# Setting some default values:
	project_images_path = ""
	user_message = AcceptDialog.new()
	mouse_clicked_in_canvas = false
	starting_canvas_size = Vector2(160, 144)
	zoom_level = 2
	
	# When resizing the window, this should be made so that the UI elements will correctly stretch to the space available:
	var callable_for_window_resize = Callable(self, "_on_viewport_size_changed")
	get_tree().root.connect("size_changed", callable_for_window_resize)
	
	# Creating the UI
	main_vbox = VBoxContainer.new() # Contains everything
	add_child(main_vbox)
	main_vbox.custom_minimum_size = get_viewport_rect().size # Fill the entire window
	# ======================MENU BAR======================
	var menu_bar = HBoxContainer.new()
	main_vbox.add_child(menu_bar)
	# --------------Create the first menu button for "File"-----------
	var file_menu_button = MenuButton.new()
	file_menu_button.text = "File"
	menu_bar.add_child(file_menu_button)
	# Create a popup menu for the "File" button
	var file_popup_menu = file_menu_button.get_popup()
	file_popup_menu.add_item("New Project")
	file_popup_menu.add_item("Open Project")
	file_popup_menu.add_item("Save Project As")
	file_popup_menu.add_item("Save Project")
	file_popup_menu.add_item("Close Project")
	#Connecting signals for file menu
	var callable_for_file_popup = Callable(self, "_on_popup_file_menu_item_pressed")
	file_popup_menu.id_pressed.connect(callable_for_file_popup)
	var callable_for_gui_input_file_popup = Callable(self, "_on_button_gui_input_left_click")
	# -----------------Create the second menu button for "Edit"---------------
	var edit_menu_button = MenuButton.new()
	edit_menu_button.text = "Edit"
	menu_bar.add_child(edit_menu_button)
	# Create a popup menu for the "Edit" button
	var edit_popup_menu = edit_menu_button.get_popup()
	edit_popup_menu.add_item("Undo")
	edit_popup_menu.add_item("Redo")
	edit_popup_menu.add_item("Cut")
	edit_popup_menu.add_item("Copy")
	edit_popup_menu.add_item("Paste")
	#Connecting signals for Edit menu
	var callable_for_edit_popup = Callable(self, "_on_popup_edit_menu_item_pressed")
	edit_popup_menu.id_pressed.connect(callable_for_edit_popup)
	var callable_for_gui_input_edit_popup = Callable(self, "_on_button_gui_input_left_click")
	# --------------Create the third menu button for "Project"----------------
	var project_menu_button = MenuButton.new()
	project_menu_button.text = "Project"
	menu_bar.add_child(project_menu_button)
	# Create a popup menu for the "Project" button
	var project_popup_menu = project_menu_button.get_popup()
	project_popup_menu.add_item("Configure images path")
	project_popup_menu.add_item("Other stuff")
	#Connecting signals for Project menu
	var callable_for_project_popup = Callable(self, "_on_popup_project_menu_item_pressed")
	project_popup_menu.id_pressed.connect(callable_for_project_popup)
	var callable_for_gui_input_project_popup = Callable(self, "_on_button_gui_input_left_click")
	
	
	# ==================Rest of the UI======================
	clips_canvas_frame_layer_splitbox = VSplitContainer.new() # Parent control node contaiing everything except the menu bar (canvas, clip list, framelayer table)
	main_vbox.add_child(clips_canvas_frame_layer_splitbox)
	clips_canvas_frame_layer_splitbox.size_flags_vertical = Control.SIZE_EXPAND_FILL
	clips_canvas_frame_layer_splitbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	# Create the HBoxContainer
	var clip_canvas_h_splitbox = HSplitContainer.new() # Contains the clip lists and the canvas
	clips_canvas_frame_layer_splitbox.add_child(clip_canvas_h_splitbox)
	clip_canvas_h_splitbox.size_flags_vertical = Control.SIZE_EXPAND_FILL
	# -------------Create the Clip List------------
	var clip_lists_v_splitbox = create_container(VSplitContainer, Control.SIZE_EXPAND_FILL, Control.SIZE_EXPAND_FILL)
	clip_lists_v_splitbox.size_flags_stretch_ratio = 0.2  # 20% of the space
	clip_canvas_h_splitbox.add_child(clip_lists_v_splitbox)
	# Create 2 lists (for Basic and Complex clips)
	# .......Basic Clips list......
	var clip_list_scroll1 = create_container(ScrollContainer, Control.SIZE_EXPAND_FILL, Control.SIZE_EXPAND_FILL)
	clip_lists_v_splitbox.add_child(clip_list_scroll1)
	basic_clips_list = VBoxContainer.new()
	clip_list_scroll1.add_child(basic_clips_list)
	# Create an 'Add' button for the first list
	var add_button1 = construct_button(Button.new(), "Add Basic Clip", button_size, "_on_add_basic_clip_pressed")
	basic_clips_list.add_child(add_button1)
	# .......Complex Clips list.......
	var clip_list_scroll2 = create_container(ScrollContainer, Control.SIZE_EXPAND_FILL, Control.SIZE_EXPAND_FILL)
	clip_lists_v_splitbox.add_child(clip_list_scroll2)
	complex_clips_list = VBoxContainer.new()
	clip_list_scroll2.add_child(complex_clips_list)
	# Create an 'Add' button for the first list
	var add_button2 = construct_button(Button.new(), "Add Complex Clip", button_size, "_on_add_complex_clip_pressed")
	complex_clips_list.add_child(add_button2)
	# ---------------Create the Canvas-----------
	var scroll_container_canvas = create_container(ScrollContainer, Control.SIZE_EXPAND_FILL, Control.SIZE_EXPAND_FILL)
	clip_canvas_h_splitbox.add_child(scroll_container_canvas)
	canvas = Panel.new()
	canvas.set_name("Canvas")
	scroll_container_canvas.add_child(canvas)
	canvas.custom_minimum_size = Vector2(starting_canvas_size.x * zoom_level, starting_canvas_size.y * zoom_level)
	# ---------------Create the Frame Table------------------
	scroll_container_frame_table = create_container(ScrollContainer, Control.SIZE_EXPAND_FILL, Control.SIZE_EXPAND_FILL)
	frame_table_vbox = VBoxContainer.new()
	clips_canvas_frame_layer_splitbox.add_child(scroll_container_frame_table)
	scroll_container_frame_table.add_child(frame_table_vbox)
	# Add your frame table code here
	var frame_table_hbox = HBoxContainer.new() # Contains the buttons e.g. add layer, add frame etc.
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
	# Reconstruct frame layer table button
	var reconstruct_frame_layer_table_button = construct_button(Button.new(), "Reconstruct Table", button_size, "_on_reconstruct_frame_layer_table_button_pressed")
	frame_table_hbox.add_child(reconstruct_frame_layer_table_button)
	# Note: At that point, frame_table_vbox does not yet have a frame layer table. It is added later (e.g. when you create and select a clip_

	
func contruct_frame_layer_table_clip(frames, layers, clip):
	# This function creates the frame layer table from 0, including frame labels, layer labels, and frame layer cells.
	# After the creation of the table, this table is directly referenced by the clip (yes, the clip references the whole UI element of the frame layer table instead of having a 2D array of frameLayer)
	# At the end, this table is added as a child to frame_table_vbox (and the previous table is removed from child)
	# Parameters: frames (of the clip), layers (of the clip), clip.
	# Structure of the framelayer table: "|" are elements of the 2d array
	#  0123456789....
	# 0|||||||||| <-Frame labels
	# 1||||||||||
	# 2||||||||||
	# 3||||||||||
	# 4||||||||||
	# .^
	# .Layer labels
	# .All the rest: FrameLayer cells
	# The table is similar to a 2D array (it is in fact it is a node tree with similar structure).
	# It consists of columns (e.g. column 0, column 1, 2... etc) Each column has children/ elements
	# Column 0 contains labels of layers. The first element of each column is the label of each frame. The element 0,0 is the placeholder "=", since there is no frame or layer there.
	# All the other elements are the frameLayers (more precisely, frameLayer buttons, which also reference the frameLayer)
	# Therefore, the first frame is in fact the child 1 of frame_layer_table_hbox_clip (and not child 0, since child 0 contains the labels)
	# Similarly, the first framelayer of the first frame, is  child 1 of the child 1 (since child 0 of child 1 has the label of the frame).
	#
	# TODO: Consider using the add frame and add layer functions to replace some parts of this code.
	#
	# Constructing the table
	var frame_layer_table_hbox_clip # The table
	frame_layer_table_hbox_clip = HBoxContainer.new()
	var placeholder_button = construct_button(Button.new(), "=", button_size, "_placeholder_function") # This button does nothing, it just occupies the space.
	frame_layer_table_hbox_clip.add_child(VBoxContainer.new()) # Adding the first column of the frame layer table that has the layer labels.
	frame_layer_table_hbox_clip.get_child(0).add_child(placeholder_button)
	# ----------Creating frame labels (it is the first (0) column)-----------
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
	# -----------Creating layer labels (it is the first (0) child of each column)---------
	for i in range(layers):
		var layer_label = construct_button(NumberedLabelButton.new(i+1), str(i+1), button_size, "_on_layer_label_button_pressed") #STARTS FROM 1
		layer_label.text = str(layer_label.number)
		frame_layer_table_hbox_clip.get_child(0).add_child(layer_label)
		layer_label.custom_minimum_size = button_size
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
	# -------------Create buttons for Frame Layer cells (NumberedFrameLayerButton) (change the name?)-------------
	for i in range(layers):
		for j in range(frames):
			var button = construct_button(NumberedFrameLayerButton.new(j+1, i+1), "", button_size, "_on_frame_layer_button_pressed") #STARTS FROM 1 #str(j+1) + " " + str(i+1)
			# Add the button to the correct sub-array in the 2D array
			frame_layer_table_hbox_clip.get_child(j+1).add_child(button) # remember, 0 is for labels of layers
			# Create a PopupMenu for the frame_label button
			var popup_menu_frame_layer = PopupMenu.new()
			button.add_child(popup_menu_frame_layer)
			# Add an item to the PopupMenu
			popup_menu_frame_layer.add_item("Select clip")
			popup_menu_frame_layer.add_item("Choose offset")
			# Create a callable that references the _on_popup_menu_item_pressed method on this object
			var callable_for_popup_frame_layer = Callable(self, "_on_popup_menu_item_pressed_frame_layer")
			# Connect the signal to the callable
			popup_menu_frame_layer.id_pressed.connect(callable_for_popup_frame_layer.bind(button))
			# Create a callable that references the _on_button_gui_input method on this object
			var callable_for_gui_input_frame_layer = Callable(self, "_on_button_gui_input")
			# Connect the frame_label's gui_input signal to the _on_button_gui_input method
			button.gui_input.connect(callable_for_gui_input_frame_layer.bind(popup_menu_frame_layer))
			# If the clip is in fact BasicClip, we do this so that frameLayers reference the same basicClip, so that they can access the image. There might be better ways to do it, but it's fine for now.
			if clip is BasicClip && i == 0: # Basic clips have only 1 layer, so i == 0 could be ommitted.
				button.frameLayer.clip_used = clip
	return frame_layer_table_hbox_clip # Clips should be able to reference this.

func _on_add_frame_button_pressed(arg1 = null): #(TODO: check removing the argument)
	if selected_clip == null || !(selected_clip is ComplexClip): # This ONLY works when a ComplexClip is selected, otherwise, it doesn't work.
		print("frames layers UI No ComplexClip selected!")
		return
	#num_frames += 1
	#grid.columns = num_frames  # Update the number of columns to account for the new frame
	selected_clip.frame_layer_table_hbox.add_child(VBoxContainer.new())
	
	# Add a new frame label
	var frame_label = NumberedLabelButton.new(selected_clip.frame_layer_table_hbox.get_child_count() - 1)
	var callable = Callable(self, "_on_frame_label_button_pressed").bind(frame_label)
	frame_label.connect("pressed", callable)
	frame_label.text = str(frame_label.get_number())
	selected_clip.frame_layer_table_hbox.get_child(selected_clip.frame_layer_table_hbox.get_child_count() - 1).add_child(frame_label)
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
	for i in range(selected_clip.frame_layer_table_hbox.get_child(0).get_child_count()):
		if i != 0: # 0 IS FOR LABEL (do we need to add 1 to the loop? check)
			var button = construct_button(NumberedFrameLayerButton.new(selected_clip.frame_layer_table_hbox.get_child_count() - 1, i), "", button_size, "_on_frame_layer_button_pressed") #str(selected_clip.frame_layer_table_hbox.get_child_count() - 1) + " " + str(i)
			selected_clip.frame_layer_table_hbox.get_child(selected_clip.frame_layer_table_hbox.get_child_count() - 1).add_child(button)
			
				# Create a PopupMenu for the frame_label button
			var popup_menu_frame_layer = PopupMenu.new()
			button.add_child(popup_menu_frame_layer)
				
			# Add an item to the PopupMenu
			popup_menu_frame_layer.add_item("Select clip")
			popup_menu_frame_layer.add_item("Choose offset")
				
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
	var layer_label = construct_button(NumberedLabelButton.new(selected_clip.frame_layer_table_hbox.get_child(0).get_child_count()), str(selected_clip.frame_layer_table_hbox.get_child(0).get_child_count()), button_size, "_on_layer_label_button_pressed")

	
	#layer_labels.add_child(layer_label)
	layer_label.custom_minimum_size = button_size
	selected_clip.frame_layer_table_hbox.get_child(0).add_child(layer_label)
	# Add a new button for each frame
	
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
	
	
	for i in range(selected_clip.frame_layer_table_hbox.get_child_count()):
		if i != 0:
			var button = construct_button(NumberedFrameLayerButton.new(i, selected_clip.frame_layer_table_hbox.get_child(0).get_child_count() - 1), "", button_size, "_on_frame_layer_button_pressed") #str(i) + " " + str(selected_clip.frame_layer_table_hbox.get_child(0).get_child_count() - 1)
			

			selected_clip.frame_layer_table_hbox.get_child(i).add_child(button) #remem
			
			# Create a PopupMenu for the frame_label button
			var popup_menu_frame_layer = PopupMenu.new()
			button.add_child(popup_menu_frame_layer)
				
			# Add an item to the PopupMenu
			popup_menu_frame_layer.add_item("Select clip")
			popup_menu_frame_layer.add_item("Choose offset")
				
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
	if basic_clips_list.is_a_parent_of(clip_button):
		basic_clips_list.remove_child(clip_button)
	if complex_clips_list.is_a_parent_of(clip_button):
		complex_clips_list.remove_child(clip_button)
	clip_button.queue_free()
	reconstruct_frame_table_attributes()
	
func _on_popup_menu_item_pressed(id : int, button_to_delete : Button) -> void:
	if id == 0:  # The ID of the "Delete clip" item
	# Delete the button
		button_to_delete.queue_free()






func _on_popup_menu_item_pressed_label_frame(id : int, label_selected: NumberedLabelButton) -> void:
	if id == 0:
		create_dialog_window_for_frame_or_layer_reorder("reorder_frame", label_selected.get_number())
	elif id == 1:  # The ID of the "Delete Frame" or "Delete Layer" item
	# Delete the label
	#frame_layers_buttons
		var node_to_delete = selected_clip.frame_layer_table_hbox.get_child(label_selected.get_number())
		selected_clip.frame_layer_table_hbox.remove_child(node_to_delete)
		node_to_delete.queue_free()
		reconstruct_frame_table_attributes()
		# REORDER THE NUMBERS HERE IF YOU WANT
		# Add here any other logic you need for updating the other UI elements




func _on_popup_menu_item_pressed_label_layer(id : int, label_selected: NumberedLabelButton) -> void:
	if id == 0:
		create_dialog_window_for_frame_or_layer_reorder("reorder_layer", label_selected.get_number())
	elif id == 1:  # The ID of the "Delete Frame" or "Delete Layer" item
	# Delete the label
		for i in range(selected_clip.frame_layer_table_hbox.get_child_count()):
				#selected_clip.frame_layer_table_hbox.get_child(i).get_child(label_selected.get_number()).queue_free()
			var node_to_delete = selected_clip.frame_layer_table_hbox.get_child(i).get_child(label_selected.get_number())
			selected_clip.frame_layer_table_hbox.get_child(i).remove_child(node_to_delete)
			node_to_delete.queue_free()
		reconstruct_frame_table_attributes()
		# AFTER DELETION, REORDER THE NUMBERS HERE IF YOU WANT
		# Add here any other logic you need for updating the other UI elements


func _on_popup_menu_item_pressed_frame_layer(id : int, frame_layer_button: NumberedFrameLayerButton) -> void:
	if id == 0:  # Select clip
		if dialog != null:
			dialog.queue_free()
		dialog = AcceptDialog.new()
		var vbox = VBoxContainer.new()
		vbox.set_name("vbox")
		dialog.add_child(vbox)
		var hbox_name = HBoxContainer.new()
		hbox_name.set_name("hbox_name")
		var label_name = Label.new()
		label_name.text = "Write the clip's name here: "
		
		var line_edit_name = LineEdit.new()
		line_edit_name.set_name("InputName") #we need to retrieve it later
		
		hbox_name.add_child(label_name)
		hbox_name.add_child(line_edit_name)
		vbox.add_child(hbox_name)
		
		
		var hbox_frame = HBoxContainer.new()
		hbox_frame.set_name("hbox_frame")
		var label_frame = Label.new()
		label_frame.text = "Frame of clip: "
		var line_edit_frame = LineEdit.new()
		line_edit_frame.set_name("InputFrame") # If dimension is not valid integer, it will be 0 (because of the int(x) function). A dimension of 0 (and generally dimensions smaller than the image), means the image is a single image, and not a spritesheet.
		hbox_frame.add_child(label_frame)
		hbox_frame.add_child(line_edit_frame)
		vbox.add_child(hbox_frame)

		add_child(dialog)
		var callable = Callable(self, "_on_dialog_confirmed_select_clip_for_framelayer").bind(dialog, frame_layer_button)
		dialog.connect("confirmed", callable)
		dialog.popup_centered()
	if id == 1:
		if dialog != null:
			dialog.queue_free()
		dialog = AcceptDialog.new()
		var vbox = VBoxContainer.new()
		vbox.set_name("vbox")
		dialog.add_child(vbox)
		var hbox_offset_x = HBoxContainer.new()
		hbox_offset_x.set_name("hbox_offset_x")
		var label_offset_x = Label.new()
		label_offset_x.text = "Write the x offset (0,0 is top-left corner): "
		
		var line_edit_offset_x = LineEdit.new()
		line_edit_offset_x.set_name("InputOffsetX") #we need to retrieve it later
		
		hbox_offset_x.add_child(label_offset_x)
		hbox_offset_x.add_child(line_edit_offset_x)
		vbox.add_child(hbox_offset_x)
		
		
		
		
		var hbox_offset_y = HBoxContainer.new()
		hbox_offset_y.set_name("hbox_offset_y")
		var label_offset_y = Label.new()
		label_offset_y.text = "Write the y offset (0,0 is top-left corner): "
		
		var line_edit_offset_y = LineEdit.new()
		line_edit_offset_y.set_name("InputOffsetY") #we need to retrieve it later
		
		hbox_offset_y.add_child(label_offset_y)
		hbox_offset_y.add_child(line_edit_offset_y)
		vbox.add_child(hbox_offset_y)
		


		add_child(dialog)
		var callable = Callable(self, "_on_dialog_confirmed_select_offset_for_framelayer").bind(dialog, frame_layer_button)
		dialog.connect("confirmed", callable)
		dialog.popup_centered()
		
func _on_dialog_confirmed_select_clip_for_framelayer(dialog, frame_layer_button):
	
	var line_edit = dialog.get_node("vbox/hbox_name/InputName")
	var text_input = line_edit.text
	
	var frame_selected = int(dialog.get_node("vbox/hbox_frame/InputFrame").text)
	
	for i in range(1, basic_clips_list.get_child_count()):
		if text_input == basic_clips_list.get_child(i).clip.clip_name:
			#_select_selected_clip(basic_clips_list.get_child(i).clip)
			print("found1 ", text_input, " " , basic_clips_list.get_child(i).clip.clip_name)
			frame_layer_button.frameLayer.clip_used = basic_clips_list.get_child(i).clip
			frame_layer_button.frameLayer.frame_of_clip = frame_selected
			
			var button_style = StyleBoxFlat.new()
			button_style.bg_color = frame_layer_button.frameLayer.clip_used.color_bg
			frame_layer_button.add_theme_stylebox_override("normal", button_style)
			frame_layer_button.add_theme_color_override("font_color", frame_layer_button.frameLayer.clip_used.color_text)
			frame_layer_button.add_theme_color_override("font_focus_color", frame_layer_button.frameLayer.clip_used.color_text)
			frame_layer_button.text = str(frame_layer_button.frameLayer.frame_of_clip)
			
			return
	for i in range(1, complex_clips_list.get_child_count()):
		if text_input == complex_clips_list.get_child(i).clip.clip_name:
			print("found2 ", text_input, " " , complex_clips_list.get_child(i).clip.clip_name)
			frame_layer_button.frameLayer.clip_used = complex_clips_list.get_child(i).clip
			frame_layer_button.frameLayer.frame_of_clip = frame_selected
			var button_style = StyleBoxFlat.new()
			button_style.bg_color = frame_layer_button.frameLayer.clip_used.color_bg
			frame_layer_button.add_theme_stylebox_override("normal", button_style)
			frame_layer_button.add_theme_color_override("font_color", frame_layer_button.frameLayer.clip_used.color_text)
			frame_layer_button.add_theme_color_override("font_focus_color", frame_layer_button.frameLayer.clip_used.color_text)
			frame_layer_button.text = str(frame_layer_button.frameLayer.frame_of_clip)
			
			return

func _on_dialog_confirmed_select_offset_for_framelayer(dialog, frame_layer_button):
	var x_offset = int(dialog.get_node("vbox/hbox_offset_x/InputOffsetX").text)
	var y_offset = int(dialog.get_node("vbox/hbox_offset_y/InputOffsetY").text)
	
	frame_layer_button.frameLayer.offset_framelayer = Vector2(x_offset, y_offset)

func _on_frame_layer_button_pressed(button : NumberedFrameLayerButton) -> void:
	print("frames layers UI, frame and layer: " + str(button.get_frame()) + " " + str(button.get_layer()))
	print("frames layers UI, frame and layer offset: " + str(button.frameLayer.offset_framelayer))
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
	if dialog != null:
		dialog.queue_free()
	dialog = AcceptDialog.new()
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
			selected_clip.frame_layer_table_hbox.move_child(selected_clip.frame_layer_table_hbox.get_child(frame_or_layer_to_reorder), new_index) # TODO: WE NEED ADDITIONAL CHECKS
			reconstruct_frame_table_attributes()
		elif type == "reorder_layer":
			for i in range(selected_clip.frame_layer_table_hbox.get_child_count()):
				selected_clip.frame_layer_table_hbox.get_child(i).move_child(selected_clip.frame_layer_table_hbox.get_child(i).get_child(frame_or_layer_to_reorder), new_index)
				reconstruct_frame_table_attributes()
	else:
		print("frames layers UI Invalid input")

func reconstruct_frame_table_attributes():
	for i in range(selected_clip.frame_layer_table_hbox.get_child_count()):
		for j in range(selected_clip.frame_layer_table_hbox.get_child(i).get_child_count()):
			if i == 0: #layer labels
				if j != 0: #1st label is the placeholder
					selected_clip.frame_layer_table_hbox.get_child(i).get_child(j).set_number(j) # Setting layer labels
			elif j == 0:
				selected_clip.frame_layer_table_hbox.get_child(i).get_child(j).set_number(i) # Setting Frame labels
			else:
				selected_clip.frame_layer_table_hbox.get_child(i).get_child(j).set_frame(i)
				selected_clip.frame_layer_table_hbox.get_child(i).get_child(j).set_layer(j)
				var frameLayer_button = selected_clip.frame_layer_table_hbox.get_child(i).get_child(j)
				var frameLayer = frameLayer_button.frameLayer
				if frameLayer.clip_used != null:
					#check if clip exists:
					var clip_exists = false
					for k in range (1, basic_clips_list.get_child_count()):
						if frameLayer.clip_used == basic_clips_list.get_child(k).clip:
							clip_exists = true
							break
					for k in range (1, complex_clips_list.get_child_count()):
						if frameLayer.clip_used == complex_clips_list.get_child(k).clip:
							clip_exists = true
							break
					
					if clip_exists && !(selected_clip is BasicClip):
						var button_style = StyleBoxFlat.new()
						#var frameLayer_button = selected_clip.frame_layer_table_hbox.get_child(i)
						button_style.bg_color = frameLayer.clip_used.color_bg
						frameLayer_button.add_theme_stylebox_override("normal", button_style)
						frameLayer_button.add_theme_color_override("font_color", frameLayer.clip_used.color_text)
						frameLayer_button.add_theme_color_override("font_focus_color", frameLayer.clip_used.color_text)
					else:
						pass
						#var button_style = StyleBoxFlat.new()
						##var frameLayer_button = selected_clip.frame_layer_table_hbox.get_child(i)
						#button_style.bg_color = Color(0.5, 0.5, 0.5, 1) #deleted clip
						#frameLayer_button.add_theme_stylebox_override("normal", button_style)
						#frameLayer_button.add_theme_color_override("font_color", Color(0, 0, 0, 1))
						#frameLayer_button.add_theme_color_override("font_focus_color", Color(0,0,0,1))

func _on_reconstruct_frame_layer_table_button_pressed(arg1 = null):
	for i in range(selected_clip.frame_layer_table_hbox.get_child_count()):
		for j in range(selected_clip.frame_layer_table_hbox.get_child(i).get_child_count()):
			if i == 0: #layer labels
				if j != 0: #1st label is the placeholder
					selected_clip.frame_layer_table_hbox.get_child(i).get_child(j).text = str(j) # Setting layer labels
			elif j == 0:
				selected_clip.frame_layer_table_hbox.get_child(i).get_child(j).text = str(i) # Setting Frame labels
			else:
				pass
				#selected_clip.frame_layer_table_hbox.get_child(i).get_child(j).text = str(i) + " " + str(j)
				

func _placeholder_function(arg1 = null):
	print("frames_layers_UI.gd placeholder clicked!")


func create_new_clip(clip_type):
	if clip_type == "BasicClip":
		load_image_file_for_basic_clip() # after selection of the image, the dialog for naming and setting dimensions is called.

	elif clip_type == "ComplexClip":
		if dialog != null:
			dialog.queue_free()
		dialog = AcceptDialog.new()
		
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
		
		
		var hbox_colors = HBoxContainer.new()
		hbox_colors.set_name("hbox_colors")
		var label_colors = Label.new()
		label_colors.text = "Colors: "

		var color_picker_button_color_bg = ColorPickerButton.new()
		color_picker_button_color_bg.set_pick_color(Color(1, 1, 1, 1))
		color_picker_button_color_bg.set_name("color_picker_bg")
		color_picker_button_color_bg.custom_minimum_size = button_size
		hbox_colors.add_child(label_colors)
		hbox_colors.add_child(color_picker_button_color_bg)
		

		var color_picker_button_color_text = ColorPickerButton.new()
		color_picker_button_color_text.set_pick_color(Color(0, 0, 0, 1))
		color_picker_button_color_text.set_name("color_picker_text")
		color_picker_button_color_text.custom_minimum_size = button_size
		hbox_colors.add_child(color_picker_button_color_text)
		
		vbox.add_child(hbox_colors)
		
		add_child(dialog)
		var callable = Callable(self, "_on_dialog_confirmed_create_new_clip").bind(dialog, clip_type)
		dialog.connect("confirmed", callable)
		dialog.popup_centered()
		

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
	#popup_menu.add_item("Edit")
	#popup_menu.add_item("Reorder clip") # THE SAME CODE EXISTS WHEN LOADING A PROJECT

	# Create a callable that references the _on_popup_menu_item_pressed method on this object

	if clip_type == "BasicClip":
		popup_menu.add_item("Edit")
		popup_menu.add_item("Reorder clip")
		popup_menu.add_item("Change image")

		# Possibly add additional options for BasicClip
		clip_button = ClipButton.new()#text_input, BasicClip)
		
		clip_button.clip = BasicClip.new()
		clip_button.set_clip_name(text_input)
		
		construct_button(clip_button, text_input, button_size, "_select_selected_clip")
		var line_edit_dim1 = dialog.get_node("vbox/hbox_dim1/InputDim1")
		var line_edit_dim2 = dialog.get_node("vbox/hbox_dim2/InputDim2")
		clip_button.clip.image = image
		var relative_path = path.replace(project_images_path, "")
		clip_button.clip.path = relative_path
		print("frames_layers_ui a " + str(image.get_size()))
		clip_button.clip.set_image_dimensions(Vector2(int(line_edit_dim1.text), int(line_edit_dim2.text)))#dimensions = Vector2(int(line_edit_dim1.text), int(line_edit_dim2.text))
		var callable_for_popup = Callable(self, "_on_basic_clip_popup_menu_item_pressed")
		popup_menu.id_pressed.connect(callable_for_popup.bind(clip_button))
		
		basic_clips_list.add_child(clip_button)
		
		print("frame layers UI debug " + str(clip_button.clip.get_sprites()))
		#clip_button.clip.frame_layer_table_hbox = contruct_frame_layer_table_clip(clip_button.clip.get_sprites(), 1, clip_button.clip)



		
		#load_image_file(clip_button.clip) #The new BasicClip is an attribute of clip_button. We need to select an image for it.
		# TODO: Handle error image (currently, the basic clip will still be created even if invalid image selected)
		# EXECUTED BEFORE INPUT of name/dimensions INSTEAD
		
	elif clip_type == "ComplexClip":
		popup_menu.add_item("Edit")
		popup_menu.add_item("Reorder clip")
		# Possibly add additional options for ComplexClip
		clip_button = ClipButton.new()#text_input, ComplexClip)
		clip_button.clip = ComplexClip.new()
		clip_button.set_clip_name(text_input)
		
		var callable_for_popup = Callable(self, "_on_complex_clip_popup_menu_item_pressed")
		popup_menu.id_pressed.connect(callable_for_popup.bind(clip_button))
		complex_clips_list.add_child(clip_button)
		construct_button(clip_button, text_input, button_size, "_select_selected_clip")
		#default some falues
		#clip_button.clip.frame_layer_table_hbox = contruct_frame_layer_table_clip(4, 2, clip_button.clip)
		
		#adding colors

	clip_button.add_child(popup_menu)
	var callable_for_gui_input = Callable(self, "_on_button_gui_input")
	clip_button.gui_input.connect(callable_for_gui_input.bind(popup_menu))
	#selected_clip = clip_button.clip
	
	#frame_table_vbox.add_child(
	# To change the background color of the button
	#var button_style = StyleBoxFlat.new()
	#button_style.bg_color = color_bg
	#clip_button.add_stylebox_override("normal", button_style)
	
	# To change the text color of the button
	clip_button.clip.color_bg = dialog.get_node("vbox/hbox_colors/color_picker_bg").get_pick_color()
	clip_button.clip.color_text = dialog.get_node("vbox/hbox_colors/color_picker_text").get_pick_color()
	
	# To change the background color of the button
	var button_style = StyleBoxFlat.new()
	button_style.bg_color = clip_button.clip.color_bg
	clip_button.add_theme_stylebox_override("normal", button_style)
	clip_button.add_theme_color_override("font_color", clip_button.clip.color_text)
	clip_button.add_theme_color_override("font_focus_color", clip_button.clip.color_text)
	
	if clip_type == "BasicClip":
		clip_button.clip.frame_layer_table_hbox = contruct_frame_layer_table_clip(clip_button.clip.get_sprites(), 1, clip_button.clip)
	elif clip_type == "ComplexClip":
		clip_button.clip.frame_layer_table_hbox = contruct_frame_layer_table_clip(4, 2, clip_button.clip)
	_select_selected_clip(clip_button)

func _on_basic_clip_popup_menu_item_pressed(id : int, clip_button : Button) -> void:
	if id == 0: #rename
		if dialog != null:
			dialog.queue_free()

		dialog = AcceptDialog.new()

		var vbox = VBoxContainer.new()
		vbox.set_name("vbox")
		dialog.add_child(vbox)

		var hbox_name = HBoxContainer.new()
		hbox_name.set_name("hbox_name")
		
		var label_name = Label.new()
		label_name.text = "Name: "
		var line_edit_name = LineEdit.new()
		line_edit_name.set_name("InputName")
		line_edit_name.text = clip_button.clip.clip_name
		hbox_name.add_child(label_name)
		hbox_name.add_child(line_edit_name)
		vbox.add_child(hbox_name)

		var hbox_dim1 = HBoxContainer.new()
		hbox_dim1.set_name("hbox_dim1")
		
		var label_dim1 = Label.new()
		label_dim1.text = "Width: "
		var line_edit_dim1 = LineEdit.new()
		line_edit_dim1.text = str(clip_button.clip.dimensions.x)
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
		line_edit_dim2.text = str(clip_button.clip.dimensions.y)
		hbox_dim2.add_child(label_dim2)
		hbox_dim2.add_child(line_edit_dim2)
		vbox.add_child(hbox_dim2)
		
		
		
		var hbox_colors = HBoxContainer.new()
		hbox_colors.set_name("hbox_colors")
		var label_colors = Label.new()
		label_colors.text = "Colors: "
		#if color_picker_button_color_bg != null:
		#	color_picker_button_color_bg.queue_free()
		var color_picker_button_color_bg = ColorPickerButton.new()
		color_picker_button_color_bg.set_pick_color(clip_button.clip.color_bg)
		color_picker_button_color_bg.set_name("color_picker_bg")
		color_picker_button_color_bg.custom_minimum_size = button_size
		#color_picker_button_color_bg.set_name("ColorPickerButtonColor_bg")
		hbox_colors.add_child(label_colors)
		hbox_colors.add_child(color_picker_button_color_bg)
		

		var color_picker_button_color_text = ColorPickerButton.new()
		color_picker_button_color_text.set_pick_color(clip_button.clip.color_text)
		color_picker_button_color_text.set_name("color_picker_text")
		color_picker_button_color_text.custom_minimum_size = button_size
		#color_picker_button_color_text.set_name("ColorPickerButtonColor_text")
		hbox_colors.add_child(color_picker_button_color_text)
		
		vbox.add_child(hbox_colors)
		
		#var callable_color_bg = Callable(self, "_on_clip_color_bg_selected").bind(color_picker_button_color_bg)
		#color_picker_button_color_bg.text = "bg color"
		#color_picker_button_color_bg.connect("color_changed", callable_color_bg)
		
		#var callable_color_text = Callable(self, "_on_clip_color_text_selected").bind(color_picker_button_color_text)
		#color_picker_button_color_text.text = "text color"
		#color_picker_button_color_text.connect("color_changed", callable_color_text)
		
		add_child(dialog)
		var callable = Callable(self, "_on_dialog_confirmed_edit_basic_clip").bind(dialog, clip_button)
		dialog.connect("confirmed", callable)
		dialog.popup_centered()


			
			
			
			
			
			
		#dialog = AcceptDialog.new()
		#var line_edit = LineEdit.new()
		#line_edit.set_name("Input") #we need to retrieve it later
		#dialog.add_child(line_edit)
		#add_child(dialog)
		#var callable = Callable(self, "_on_dialog_confirmed_name_clip").bind(dialog, clip_button)
		#dialog.connect("confirmed", callable)
		#dialog.popup_centered()
		pass
	if id == 1:
		delete_clip_button(clip_button)



func _on_complex_clip_popup_menu_item_pressed(id : int, clip_button : Button) -> void:
	if id == 0: #rename
		if dialog != null:
			dialog.queue_free()
		dialog = AcceptDialog.new()
		
		var vbox = VBoxContainer.new()
		vbox.set_name("vbox")
		dialog.add_child(vbox)
		
		var hbox_name = HBoxContainer.new()
		hbox_name.set_name("hbox_name")
		var label_name = Label.new()
		label_name.text = "Name: "
		
		var line_edit_name = LineEdit.new()
		line_edit_name.text = clip_button.clip.clip_name
		
		line_edit_name.set_name("InputName") #we need to retrieve it later
		
		hbox_name.add_child(label_name)
		hbox_name.add_child(line_edit_name)
		vbox.add_child(hbox_name)
		
		
		var hbox_colors = HBoxContainer.new()
		hbox_colors.set_name("hbox_colors")
		var label_colors = Label.new()
		label_colors.text = "Colors: "
		#if color_picker_button_color_bg != null:
		#	color_picker_button_color_bg.queue_free()
		var color_picker_button_color_bg = ColorPickerButton.new()
		color_picker_button_color_bg.set_pick_color(clip_button.clip.color_bg)
		color_picker_button_color_bg.set_name("color_picker_bg")
		color_picker_button_color_bg.custom_minimum_size = button_size
		hbox_colors.add_child(label_colors)
		hbox_colors.add_child(color_picker_button_color_bg)
		

		var color_picker_button_color_text = ColorPickerButton.new()
		color_picker_button_color_text.set_pick_color(clip_button.clip.color_text)
		color_picker_button_color_text.set_name("color_picker_text")
		color_picker_button_color_text.custom_minimum_size = button_size
		hbox_colors.add_child(color_picker_button_color_text)
		
		vbox.add_child(hbox_colors)
		
		add_child(dialog)
		var callable = Callable(self, "_on_dialog_confirmed_edit_complex_clip").bind(dialog, clip_button)
		dialog.connect("confirmed", callable)
		dialog.popup_centered()

	if id == 1:
		delete_clip_button(clip_button)


func _on_dialog_confirmed_edit_basic_clip(dialog, clip_button):
	var line_edit = dialog.get_node("vbox/hbox_name/InputName")
	var text_input = line_edit.text
	if text_input == "":
		print("clip name cannot be empty")
		return
	else:
		for i in range(basic_clips_list.get_child_count()):
			if i == 0: # the 0 index is for the "add clip"
				continue
			if text_input == basic_clips_list.get_child(i).clip.clip_name:
				if clip_button.clip != basic_clips_list.get_child(i).clip:
					print("clip name already exists. Please select another name.")
					return
		for i in range(complex_clips_list.get_child_count()):
			if i == 0: # the 0 index is for the "add clip"
				continue
			if text_input == complex_clips_list.get_child(i).clip.clip_name:
				if clip_button.clip != complex_clips_list.get_child(i).clip:
					print("clip name already exists. Please select another name.")
					return
	clip_button.set_clip_name(text_input)
	clip_button.clip.color_bg = dialog.get_node("vbox/hbox_colors/color_picker_bg").get_pick_color()
	clip_button.clip.color_text = dialog.get_node("vbox/hbox_colors/color_picker_text").get_pick_color()
	var button_style = StyleBoxFlat.new()
	button_style.bg_color = clip_button.clip.color_bg
	clip_button.add_theme_stylebox_override("normal", button_style)
	clip_button.add_theme_color_override("font_color", clip_button.clip.color_text)
	clip_button.add_theme_color_override("font_focus_color", clip_button.clip.color_text)
	var line_edit_dim1 = dialog.get_node("vbox/hbox_dim1/InputDim1")
	var line_edit_dim2 = dialog.get_node("vbox/hbox_dim2/InputDim2")
	clip_button.clip.set_image_dimensions(Vector2(int(line_edit_dim1.text),int(line_edit_dim2.text)))
	
	

func _on_dialog_confirmed_edit_complex_clip(dialog, clip_button):
	var line_edit = dialog.get_node("vbox/hbox_name/InputName")
	var text_input = line_edit.text
	if text_input == "":
		print("clip name cannot be empty")
		return
	else:
		for i in range(basic_clips_list.get_child_count()):
			if i == 0: # the 0 index is for the "add clip"
				continue
			if text_input == basic_clips_list.get_child(i).clip.clip_name:
				if clip_button.clip != basic_clips_list.get_child(i).clip:
					print("clip name already exists. Please select another name.")
					return
		for i in range(complex_clips_list.get_child_count()):
			if i == 0: # the 0 index is for the "add clip"
				continue
			if text_input == complex_clips_list.get_child(i).clip.clip_name:
				if clip_button.clip != complex_clips_list.get_child(i).clip:
					print("clip name already exists. Please select another name.")
					return
	clip_button.set_clip_name(text_input)
	clip_button.clip.color_bg = dialog.get_node("vbox/hbox_colors/color_picker_bg").get_pick_color()
	clip_button.clip.color_text = dialog.get_node("vbox/hbox_colors/color_picker_text").get_pick_color()
	var button_style = StyleBoxFlat.new()
	button_style.bg_color = clip_button.clip.color_bg
	clip_button.add_theme_stylebox_override("normal", button_style)
	clip_button.add_theme_color_override("font_color", clip_button.clip.color_text)
	clip_button.add_theme_color_override("font_focus_color", clip_button.clip.color_text)
	

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
	if project_images_path == "":
		# Create a new instance of AcceptDialog
		if dialog != null:
			dialog.queue_free()
		dialog = AcceptDialog.new()

		# Set the dialog text
		dialog.dialog_text = "Please first set the path where images should be saved (Project->Configure images path). The relevant images should be saved in there."

		# Add the dialog as a child of the current scene
		add_child(dialog)

		# Show the dialog
		dialog.popup_centered()
		return
	file_dialog = FileDialog.new()
	add_child(file_dialog)
	
	file_dialog.access = FileDialog.ACCESS_FILESYSTEM
	file_dialog.file_mode = FileDialog.FILE_MODE_OPEN_FILE
	file_dialog.current_path = project_images_path + "/"  # Set initial directory
	print("current_path ", project_images_path)
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
		if clip_button.clip.color_bg == null && clip_button.clip.color_text:
			data["basic_clips"].append({
				"clip_name": clip_button.clip.clip_name,
				"dimensions": {"x": clip_button.clip.dimensions.x, "y": clip_button.clip.dimensions.y},
				"path": clip_button.clip.path,
				"color_bg": "#FFFFFF",
				"color_text": "#000000"
		})
		else:
			data["basic_clips"].append({
				"clip_name": clip_button.clip.clip_name,
				"dimensions": {"x": clip_button.clip.dimensions.x, "y": clip_button.clip.dimensions.y},
				"path": clip_button.clip.path,
				"color_bg": clip_button.clip.color_bg.to_html(true),
				"color_text": clip_button.clip.color_text.to_html(true)
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
		if clip_button.clip.color_bg == null && clip_button.clip.color_text:
			data["complex_clips"].append({
				"frames": clip_frames,
				"layers": clip_layers,
				"clip_name": clip_button.clip.clip_name,
				"frame_layer_table": frame_layer_data,
				"color_bg": "#FFFFFF",
				"color_text": "#000000"
			})
		else:
			data["complex_clips"].append({
				"frames": clip_frames,
				"layers": clip_layers,
				"clip_name": clip_button.clip.clip_name,
				"frame_layer_table": frame_layer_data,
				"color_bg": clip_button.clip.color_bg.to_html(true),
				"color_text": clip_button.clip.color_text.to_html(true)
			})
		
	data["project_images_path"] = project_images_path
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
	
	var selected_clip_button #the last clip loaded is selected
	
	#removing current clips
	for i in range(1, basic_clips_list.get_child_count()):
		basic_clips_list.get_child(i).queue_free()
		
	for i in range(1, complex_clips_list.get_child_count()):
		complex_clips_list.get_child(i).queue_free()
		
		
	project_images_path = data["project_images_path"]
	# Load basic_clips
	for basic_clip_data in data["basic_clips"]:
		var clip = BasicClip.new()  # or whatever your constructor is
		clip.clip_name = basic_clip_data["clip_name"]
		clip.dimensions = Vector2(basic_clip_data["dimensions"]["x"], basic_clip_data["dimensions"]["y"])
		clip.path = basic_clip_data["path"]

		var image = Image.new()
		if image.load(project_images_path + clip.path) == OK:
			clip.image = image

		else:
			print("while loading, image of BasicClip ", clip.clip_name, " could not be loaded.")
			print("path that couldn't be loaded: " , project_images_path + clip.path)
			print("aaa", project_images_path)
			print("uuu", clip.path)
		clip.set_image_dimensions(clip.dimensions)
		
		var clip_button = ClipButton.new()#text_input, BasicClip)
		
		
		selected_clip_button = clip_button
		clip_button.clip = clip
		if !(basic_clip_data.has("color_bg") && basic_clip_data.has("color_text")):
			clip_button.clip.color_bg = Color(1, 1, 1, 1)
			clip_button.clip.color_text = Color(0, 0, 0, 1)
		else:
			clip_button.clip.color_bg = basic_clip_data["color_bg"]
			clip_button.clip.color_text = basic_clip_data["color_text"]
		var button_style = StyleBoxFlat.new()
		button_style.bg_color = clip_button.clip.color_bg
		clip_button.add_theme_stylebox_override("normal", button_style)
		clip_button.add_theme_color_override("font_color", clip_button.clip.color_text)
		clip_button.add_theme_color_override("font_focus_color", clip_button.clip.color_text)
		
		
		clip.frame_layer_table_hbox = contruct_frame_layer_table_clip(clip.get_sprites(), 1, clip)

		clip_button.set_clip_name(clip.clip_name)
		basic_clips_list.add_child(clip_button)
		
		construct_button(clip_button, clip.clip_name, button_size, "_select_selected_clip") #Setting name twice?
		var popup_menu = PopupMenu.new()
		popup_menu.add_item("Edit")
		popup_menu.add_item("Reorder clip")
		popup_menu.add_item("Change image")
		var callable_for_popup = Callable(self, "_on_basic_clip_popup_menu_item_pressed")
		popup_menu.id_pressed.connect(callable_for_popup.bind(clip_button))
		
		
		clip_button.add_child(popup_menu)
		var callable_for_gui_input = Callable(self, "_on_button_gui_input")
		clip_button.gui_input.connect(callable_for_gui_input.bind(popup_menu))
			
		
		
	# Load complex_clips
	var frame_layer_button_placeholders = []  # list of FrameLayer objects that have a placeholder for clip_used
	#This is because we first need to load all clips before we reference clips to FrameLayers.
	for complex_clip_data in data["complex_clips"]:
		var clip = ComplexClip.new()  # or whatever your constructor is
		clip.clip_name = complex_clip_data["clip_name"]

		var clip_button = ClipButton.new()#text_input, BasicClip)
		selected_clip_button = clip_button
		clip_button.clip = clip
		if !(complex_clip_data.has("color_bg") && complex_clip_data.has("color_text")):
			clip_button.clip.color_bg = Color(1, 1, 1, 1)
			clip_button.clip.color_text = Color(0, 0, 0, 1)
		else:
			clip_button.clip.color_bg = complex_clip_data["color_bg"]
			clip_button.clip.color_text = complex_clip_data["color_text"]
		var button_style = StyleBoxFlat.new()
		button_style.bg_color = clip_button.clip.color_bg
		clip_button.add_theme_stylebox_override("normal", button_style)
		clip_button.add_theme_color_override("font_color", clip_button.clip.color_text)
		clip_button.add_theme_color_override("font_focus_color", clip_button.clip.color_text)

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
				#frame_layer_placeholders.append(frame_layer)#frame_layer_row.append(frame_layer)
				clip.frame_layer_table_hbox.get_child(frame_layer_data["frame"]).get_child(frame_layer_data["layer"]).frameLayer = frame_layer #append(frame_layer_row)
				frame_layer_button_placeholders.append(clip.frame_layer_table_hbox.get_child(frame_layer_data["frame"]).get_child(frame_layer_data["layer"]))
				# we are saving the buttons so that we can change the colors as well


		
		clip_button.set_clip_name(clip.clip_name)
		complex_clips_list.add_child(clip_button)
		
		construct_button(clip_button, clip.clip_name, button_size, "_select_selected_clip") #Setting name twice?
		var popup_menu = PopupMenu.new()
		popup_menu.add_item("Edit")
		popup_menu.add_item("Reorder clip") 
		var callable_for_popup = Callable(self, "_on_complex_clip_popup_menu_item_pressed")
		popup_menu.id_pressed.connect(callable_for_popup.bind(clip_button))
		
		
		clip_button.add_child(popup_menu)
		var callable_for_gui_input = Callable(self, "_on_button_gui_input")
		clip_button.gui_input.connect(callable_for_gui_input.bind(popup_menu))
	
	var debug_test = false
	for frame_layer_button in frame_layer_button_placeholders:
		var frame_layer = frame_layer_button.frameLayer
		var clip_name = frame_layer.clip_used
		for i in range(1, complex_clips_list.get_child_count()): # Remember, the 1st one is the "add clip" button.
			if clip_name == complex_clips_list.get_child(i).clip.clip_name:
				frame_layer.clip_used = complex_clips_list.get_child(i).clip
				#var frameLayer_Button = clip.frame_layer_table_hbox.get_child(frame_layer_data["frame"]).get_child(frame_layer_data["layer"])
				var button_style_frame_layer = StyleBoxFlat.new()
				button_style_frame_layer.bg_color = frame_layer.clip_used.color_bg
				frame_layer_button.add_theme_stylebox_override("normal", button_style_frame_layer)
				frame_layer_button.add_theme_color_override("font_color", frame_layer.clip_used.color_text)
				frame_layer_button.add_theme_color_override("font_focus_color", frame_layer.clip_used.color_text)
				
				frame_layer_button.text = str(frame_layer_button.frameLayer.frame_of_clip)
				if !debug_test:
					debug_test = true
				else:
					pass
					#print("There seems to be a second clip with the same name. This shouldn't happen.")

		for i in range(1, basic_clips_list.get_child_count()): # Remember, the 1st one is the "add clip" button.
			if clip_name == basic_clips_list.get_child(i).clip.clip_name:
				frame_layer.clip_used = basic_clips_list.get_child(i).clip
				var button_style_frame_layer = StyleBoxFlat.new()
				button_style_frame_layer.bg_color = frame_layer.clip_used.color_bg
				frame_layer_button.add_theme_stylebox_override("normal", button_style_frame_layer)
				frame_layer_button.add_theme_color_override("font_color", frame_layer.clip_used.color_text)
				frame_layer_button.add_theme_color_override("font_focus_color", frame_layer.clip_used.color_text)
				
				frame_layer_button.text = str(frame_layer_button.frameLayer.frame_of_clip)
				if !debug_test:
					debug_test = true
				else:
					pass
					#print("There seems to be a second clip with the same name. This shouldn't happen.")
				
	_select_selected_clip(selected_clip_button)
	


func _on_viewport_size_changed(): # Re-renders the UI elements when window is resized.
	main_vbox.custom_minimum_size = get_viewport_rect().size # Fill the entire window
	# Do whatever you need to do when the window changes!
	print ("Viewport size changed")

func _on_popup_project_menu_item_pressed(id: int):
	if id == 0:
		print("reconfigure path")
		# Remove the old FileDialog if it exists. This deletes the existing connections.
		if file_dialog != null:
			file_dialog.queue_free()
		file_dialog = FileDialog.new()
		add_child(file_dialog)
		file_dialog.access = FileDialog.ACCESS_FILESYSTEM
		file_dialog.file_mode = FileDialog.FILE_MODE_OPEN_DIR 
		var callable = Callable(self, "_on_file_selected_for_change_image_path")
		file_dialog.connect("dir_selected", callable)
		file_dialog.popup_centered(Vector2(800, 600))


func _on_file_selected_for_change_image_path(path):
	project_images_path = path
	print("new project path: " , project_images_path)
	
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
	if (path.find(project_images_path) == -1):
		# Create a new instance of AcceptDialog
		if dialog != null:
			dialog.queue_free()
		dialog = AcceptDialog.new()

		# Set the dialog text
		dialog.dialog_text = "You can only select images inside the selected project folder, or its subfolders."

		# Add the dialog as a child of the current scene
		add_child(dialog)

		# Show the dialog
		dialog.popup_centered()
	if image.load(path) == OK:

		print("frame layer ui Image size: ", image.get_size())

		if dialog != null:
			dialog.queue_free()
		dialog = AcceptDialog.new()

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
		
		
		
		var hbox_colors = HBoxContainer.new()
		hbox_colors.set_name("hbox_colors")
		var label_colors = Label.new()
		label_colors.text = "Colors: "
		#if color_picker_button_color_bg != null:
		#	color_picker_button_color_bg.queue_free()
		var color_picker_button_color_bg = ColorPickerButton.new()
		color_picker_button_color_bg.set_pick_color(Color(1, 1, 1, 1))
		color_picker_button_color_bg.set_name("color_picker_bg")
		color_picker_button_color_bg.custom_minimum_size = button_size
		#color_picker_button_color_bg.set_name("ColorPickerButtonColor_bg")
		hbox_colors.add_child(label_colors)
		hbox_colors.add_child(color_picker_button_color_bg)
		

		var color_picker_button_color_text = ColorPickerButton.new()
		color_picker_button_color_text.set_pick_color(Color(0, 0, 0, 1))
		color_picker_button_color_text.set_name("color_picker_text")
		color_picker_button_color_text.custom_minimum_size = button_size
		#color_picker_button_color_text.set_name("ColorPickerButtonColor_text")
		hbox_colors.add_child(color_picker_button_color_text)
		
		vbox.add_child(hbox_colors)
		
		#var callable_color_bg = Callable(self, "_on_clip_color_bg_selected").bind(color_picker_button_color_bg)
		#color_picker_button_color_bg.text = "bg color"
		#color_picker_button_color_bg.connect("color_changed", callable_color_bg)
		
		#var callable_color_text = Callable(self, "_on_clip_color_text_selected").bind(color_picker_button_color_text)
		#color_picker_button_color_text.text = "text color"
		#color_picker_button_color_text.connect("color_changed", callable_color_text)
		
		add_child(dialog)
		var callable = Callable(self, "_on_dialog_confirmed_create_new_clip").bind(dialog, "BasicClip", image, path)
		dialog.connect("confirmed", callable)
		dialog.popup_centered()
	else:
		print("frames layers UI image not OK.")

#func _on_clip_color_bg_selected(button):
#	print("gettin color")
#	color_bg = button.get_pick_color()
	
#func _on_clip_color_text_selected(button):
#	print("gettin color")
#	color_text = button.get_pick_color()
	

func _select_selected_clip(button : ClipButton):
	if selected_clip != null:
		frame_table_vbox.remove_child(selected_clip.frame_layer_table_hbox)
	var clip = button.clip
	selected_clip = clip
	frame_table_vbox.add_child(selected_clip.frame_layer_table_hbox)
	selected_frame = 1
	selected_layer = 1
	render_frame(selected_frame)
	reconstruct_frame_table_attributes()
	
	
func render_frame(frame):
	if selected_clip != null:
		for child in canvas.get_children(): #removing the already rendered stuff.
			canvas.remove_child(child)
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
			
