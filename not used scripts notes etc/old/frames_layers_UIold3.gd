#button.set_focus_mode(Control.FOCUS_NONE)
#for i in range(1, basic_clip_subfolder.get_child_count()): # Remember, the 1st one is the "add clip" button.
extends Node2D
# TODO:
#_on_subfolder_popup_menu_item_pressed
# Variables used and handled often:
#var basic_clips_list # Contains clip buttons (ClipButton) of the basic clips.
#var complex_clips_list # Contains clip buttons (ClipButton) of the complex clips.
var selected_clip # active/ selected clip. The selected clip is rendered on the canvas. Click on a clip button to select a clip.
var selected_frame # The selected frame of the selected clip is rendered on the canvas. Click on a frame label to change selected frame.
var selected_layer # The selected layer.
var selected_framelayer_button

var stored_framelayer_buttons_for_moving

var copied_stored_framelayer_buttons_for_moving

var framelayer_selection_frame #these are used when the user clicks and drags to select multiple framelayers while in select mode.
var framelayer_selection_layer

var start_selection_frame
var end_selection_frame
var start_selection_layer
var end_selection_layer

var framelayer_is_selected # when true, only the framelayer will be rendered.
#var zoom_level # Zoom level of the canvas. Use ctrl + mouse wheel on the canvas to zoom in.
var user_message # NOT FULLY IMPLEMENTED YET- TODO: BETTER DELETE IT
var project_images_path # Path where images/ spritesheet files should be saved, so that BasicClips can access them (subfolders are fine). BasicClips save a path of the image/ spritesheet, relative to this folder.
#var message_log # A singleton "Logger" was created instead.

# Variables used often, but not changed:
var button_size = Vector2(50, 50)  # Minimum size for all buttons
var canvas
var frame_layer_table_hbox # need to hold this reference so that it can be removed from child
var scroll_container_canvas

# Variables used mostly once:
var scroll_container_frame_table
var frame_table_vbox
#var clips_canvas_frame_layer_splitbox
var main_vbox
var starting_canvas_size # The size of the canvas in pixels. Later the user should be able to change the canvas size.

# Helper variables
var mouse_clicked_in_canvas
var canvas_initial_clicked_corrected_pos
var initial_framelayer_offset # just a helper that is used at canvas to create the correct offset
var color_bg
var color_text
var file_dialog
var dialog
var mouse_pointer_canvas_pos # this is used to set the offset by clicking inside the canvas.


# We need these here. The tool settings depend on the tool selected, so they need to be hidden when another tool is selected.
var tool_settings_scroll_container
var tool_settings_assign_mode
var roll_frames_checkbutton
var roll_frames_vbox
var assign_local_referenced_clip_checkbutton
#var keep_offset
var absolute_offset_x_spinbox
var absolute_offset_y_spinbox
var assign_mode_vbox
var clip_to_assign_locally
var keep_offset_of_existing_framelayer_checkbox
var keep_offset_of_starting_framelayer_checkbox
var absolute_offset_checkbox
var infinite_roll_frames
var reverse_order
var starting_frame_spinbox
var clip_to_assign_label

enum Tool_modes {SELECT_MODE, ASSIGN_MODE, MOVE_MODE}

var tool_mode

var clip_to_assign # when assign mode is active, this clip will be getting assigned to framelayers on click

var dragging_assigning # mouse button is kept pressed while assigning.

var last_updated_framelayer_button # for assigning.
var current_frame_of_clip_to_assign

var distance_between_frame_layers = 54 # button width (50) + distance between buttons (4). This is used to calculate click and drag when assigning clips to framelayers, and when reordering.
	# TODO: IMPORTANT: THE BUTTON SIZE SHOULD REMAIN THE SAME. MAKE SURE IT DOES, EVEN IF THE TEXT INSIDE GETS LONG.
var is_moving_frames

var is_moving_layers

var frame_to_be_moved

var layer_to_be_moved

var selecting_framelayers


var basic_clip_subfolder
var complex_clip_subfolder
var text_clip_subfolder

#OLD DATA
var basic_clips_list
var complex_clips_list
var text_clips_list
var audio_clips_list
var special_clips_list
# OLD DATA END


var simple_tree_clips_dictionary
var editable_tree_clips_dictionary
var shortcut_tree_clips_dictionary

var basic_clip_popup_menu
var complex_clip_popup_menu
var text_clip_popup_menu
var basic_clip_popup_menu_shortcut
var complex_clip_popup_menu_shortcut
var text_clip_popup_menu_shortcut
var subfolder_popup_menu_editable
var subfolder_popup_menu_shortcut
var subfolder_popup_menu_simple
var tree_empty_space_popup_menu_editable
var tree_empty_space_popup_menu_shortcut


var parent_of_new_tree_item

var editable_clip_tree
var simple_clip_tree
var shortcut_clip_tree

var last_selected_tree_item

var popup_parent
var first_framelayer_offset 

func _process(delta):

	if Input.is_key_pressed(KEY_ESCAPE):
		var message = "Esc key pressed"
		var deselected = false
		
		# Deselecting everything:
		for fr in stored_framelayer_buttons_for_moving:
			deselected = true
			var new_stylebox = fr.get_theme_stylebox("normal")#.border_color = Color(1, 1, 1, 1)
			new_stylebox.border_width_bottom = 0
			new_stylebox.border_width_top = 0
			new_stylebox.border_width_left = 0
			new_stylebox.border_width_right = 0
		framelayer_selection_frame = selected_frame
		framelayer_selection_layer = selected_layer
		stored_framelayer_buttons_for_moving = []
		if deselected == true:
			message = message + ", deselecting framelayers..."
		Logger.log_message(message)
			
	if mouse_clicked_in_canvas: # This is for setting offsets of clips by moving the rendered images on the canvas.
		# Do something continuously while mouse button is held down
		var current_mouse_pos = get_global_mouse_position()
		var current_local_pos = current_mouse_pos - canvas.get_global_position()
		#print("Mouse button is held down at position: ", current_local_pos)
		
		var current_local_zoom_corrected_pos = Vector2(round(current_local_pos.x/canvas.get_zoom_level()), round(current_local_pos.y/canvas.get_zoom_level()))
		#print("Modified Mouse button is held down at position: ", current_local_zoom_corrected_pos)
		
		
		var modify_offset_pos = current_local_zoom_corrected_pos - canvas_initial_clicked_corrected_pos
		
		if selected_clip != null:
			var referenced_frameLayer = selected_clip.frame_layer_table_hbox.get_child(selected_frame).get_child(selected_layer).frameLayer
			var referenced_clip = referenced_frameLayer.get_clip()
			if referenced_frameLayer.offset_framelayer != initial_framelayer_offset + modify_offset_pos:
				referenced_frameLayer.offset_framelayer = initial_framelayer_offset + modify_offset_pos
				#canvas_initial_clicked_corrected_pos = canvas_initial_clicked_corrected_pos + modify_offset_pos
				Logger.log_canvas_movement_message("Relative Move: " + str(modify_offset_pos) + " | Absolute Position: " + str(referenced_frameLayer.offset_framelayer))
				if framelayer_is_selected:
					render_framelayer(selected_frame, selected_layer)
				else:
					render_frame(selected_frame)
		#print("Mouse button is held down")
	if selecting_framelayers:
		if selected_clip !=null:
			var relevant_framelayer_position = selected_clip.frame_layer_table_hbox.get_child(selected_frame).get_child(selected_layer).get_global_position()
			var global_position_difference = get_global_mouse_position() - relevant_framelayer_position
			var frame_difference = round((round(global_position_difference.x - 25) - 2) / 54) # again, 54 = 50 (button size) + 4 (space between buttons) 
			
			var layer_difference = round((round(global_position_difference.y - 25) - 2) / 54)
			
			var temp_framelayer_selection_frame = selected_frame + frame_difference
			var temp_framelayer_selection_layer = selected_layer + layer_difference
			
			if temp_framelayer_selection_frame >= selected_clip.frame_layer_table_hbox.get_child_count():
				temp_framelayer_selection_frame = selected_clip.frame_layer_table_hbox.get_child_count() - 1
			if temp_framelayer_selection_frame <= 0:
				temp_framelayer_selection_frame = 1
			
			if temp_framelayer_selection_layer >= selected_clip.frame_layer_table_hbox.get_child(0).get_child_count():
				temp_framelayer_selection_layer = selected_clip.frame_layer_table_hbox.get_child(0).get_child_count() - 1
			if temp_framelayer_selection_layer <= 0:
				temp_framelayer_selection_layer = 1
			
			#var cond1 = framelayer_selection_frame != selected_frame + frame_difference) || (framelayer_selection_layer != selected_layer + layer_difference
			#var cond2 = 
			
			if (framelayer_selection_frame != temp_framelayer_selection_frame) || (framelayer_selection_layer != temp_framelayer_selection_layer):
				# means that it needs to reajust the selected framelayers
				framelayer_selection_frame = temp_framelayer_selection_frame#selected_frame + frame_difference
				framelayer_selection_layer = temp_framelayer_selection_layer#selected_layer + layer_difference
				var start_frame
				var end_frame
				var start_layer
				var end_layer
				
				if selected_frame > framelayer_selection_frame:
					start_frame = framelayer_selection_frame
					end_frame = selected_frame
				else:
					start_frame = selected_frame
					end_frame = framelayer_selection_frame
					
				if selected_layer > framelayer_selection_layer:
					start_layer = framelayer_selection_layer
					end_layer = selected_layer
				else:
					start_layer = selected_layer
					end_layer = framelayer_selection_layer
				
				start_selection_frame = start_frame
				end_selection_frame = end_frame
				start_selection_layer = start_layer
				end_selection_layer = end_layer
				
				
				print(start_frame, " ", start_layer , " " , end_frame , " ", end_layer)
				#if stored_framelayer_buttons_for_moving != null:
				for fr in stored_framelayer_buttons_for_moving:
					var new_stylebox_normal = fr.get_theme_stylebox("normal")#.border_color = Color(1, 1, 1, 1)
					var new_stylebox_hover = fr.get_theme_stylebox("hover")
					new_stylebox_normal.border_width_bottom = 0
					new_stylebox_normal.border_width_top = 0
					new_stylebox_normal.border_width_left = 0
					new_stylebox_normal.border_width_right = 0
					new_stylebox_hover.border_width_bottom = 0
					new_stylebox_hover.border_width_top = 0
					new_stylebox_hover.border_width_left = 0
					new_stylebox_hover.border_width_right = 0
					#fr.add_theme_stylebox_override("normal", new_stylebox_normal)
					#fr.add_theme_stylebox_override("hover", new_stylebox_hover)
				stored_framelayer_buttons_for_moving = []
				for i in range(start_frame, end_frame + 1): #+1 because we need to include both start and end frame
					for j in range(start_layer, end_layer + 1):
						var frame_layer_button = selected_clip.frame_layer_table_hbox.get_child(i).get_child(j)
						stored_framelayer_buttons_for_moving.append(frame_layer_button)
						#var new_stylebox = StyleBoxFlat.new()
						#new_stylebox.border_color = Color(1, 1, 1, 1)
						var new_stylebox_normal = frame_layer_button.get_theme_stylebox("normal")#.border_color = Color(1, 1, 1, 1)
						var new_stylebox_hover = frame_layer_button.get_theme_stylebox("hover")
						new_stylebox_normal.border_width_bottom = 4
						new_stylebox_normal.border_width_top = 4
						new_stylebox_normal.border_width_left = 4
						new_stylebox_normal.border_width_right = 4
						new_stylebox_hover.border_width_bottom = 4
						new_stylebox_hover.border_width_top = 4
						new_stylebox_hover.border_width_left = 4
						new_stylebox_hover.border_width_right = 4
						#frame_layer_button.add_theme_stylebox_override("normal", new_stylebox_normal)
						#frame_layer_button.add_theme_stylebox_override("hover", new_stylebox_hover)
	if is_moving_frames:
		# make the checks first:
		var child_count_check = selected_clip.frame_layer_table_hbox.get_child_count()
		var relevant_frame_position = selected_clip.frame_layer_table_hbox.get_child(frame_to_be_moved).get_child(0).get_global_position()
		# ^position of the frame's label
		var global_position_difference = get_global_mouse_position() - relevant_frame_position
		# ^this difference determines how far the mouse pointer is compared to the location of the frame to be changed.
		# Since the position of an element such as the frame label is calculated from top-right, the size of the button is 50 and the space between buttons 4, we need to do the following:
		var movement = 0
		if global_position_difference.x > 50:
			movement = 1
			# 50 the button size, 4/2 is half the distance of the space
		elif global_position_difference.x < -4:
			movement = -1
		if frame_to_be_moved + movement < child_count_check && frame_to_be_moved + movement > 0:
			reorder_frame(frame_to_be_moved, frame_to_be_moved + movement)
			frame_to_be_moved = frame_to_be_moved + movement
	elif is_moving_layers:
		# make the checks first:
		var child_count_check = selected_clip.frame_layer_table_hbox.get_child(0).get_child_count()
		#if layer_to_be_moved < child_count_check && layer_to_be_moved > 0:
		var relevant_layer_position = selected_clip.frame_layer_table_hbox.get_child(0).get_child(layer_to_be_moved).get_global_position()
		var global_position_difference = get_global_mouse_position() - relevant_layer_position
		var movement = 0
		if global_position_difference.y > 50:
			movement = 1
		elif global_position_difference.y < -4:
			movement = -1
		if layer_to_be_moved + movement < child_count_check && layer_to_be_moved + movement > 0:
			reorder_layer(layer_to_be_moved, layer_to_be_moved + movement)
			layer_to_be_moved = layer_to_be_moved + movement
	
	if dragging_assigning:
		var starting_pos = last_updated_framelayer_button.get_global_position()
		var pos_difference = get_global_mouse_position() - starting_pos
		var movement = 0
		if pos_difference.x > 50:
			movement = 1
			# 50 the button size, 4/2 is half the distance of the space
		elif pos_difference.x < -4:
			movement = -1
		if movement != 0:
			var number_of_frames = selected_clip.frame_layer_table_hbox.get_child_count() -1
			var current_frame = last_updated_framelayer_button.frameLayer.frame_number
			var current_layer = last_updated_framelayer_button.frameLayer.layer_number
			
			var number_of_frames_of_assigning_clip = clip_to_assign.frame_layer_table_hbox.get_child_count() -1
			if current_frame + movement >= number_of_frames || current_frame + movement < 1:
				pass
			else:
				current_frame = current_frame + movement
				if roll_frames_checkbutton.is_pressed():
					if infinite_roll_frames.is_pressed():
						if reverse_order.is_pressed():
							current_frame_of_clip_to_assign = current_frame_of_clip_to_assign - movement
						else:
							current_frame_of_clip_to_assign = current_frame_of_clip_to_assign + movement
					else:
						if reverse_order.is_pressed():
							current_frame_of_clip_to_assign = current_frame_of_clip_to_assign - movement
						else:
							current_frame_of_clip_to_assign = current_frame_of_clip_to_assign + movement
						current_frame_of_clip_to_assign = (int(current_frame_of_clip_to_assign - 1) % int(number_of_frames_of_assigning_clip)) + 1
						if current_frame_of_clip_to_assign <= 0:
							current_frame_of_clip_to_assign += number_of_frames_of_assigning_clip
				else:
					pass # assign the same frame of the clip
				last_updated_framelayer_button = selected_clip.frame_layer_table_hbox.get_child(current_frame).get_child(current_layer)
				print("trying to assing: ", clip_to_assign.clip_name)
				
				var offset = Vector2(0,0)
				if absolute_offset_checkbox.is_pressed():
					offset = Vector2(absolute_offset_x_spinbox.value, absolute_offset_y_spinbox.value)
				elif keep_offset_of_existing_framelayer_checkbox.is_pressed():
					offset = last_updated_framelayer_button.frameLayer.offset_framelayer
				elif keep_offset_of_starting_framelayer_checkbox.is_pressed():
					offset = first_framelayer_offset
				last_updated_framelayer_button.frameLayer.offset_framelayer = offset
				if assign_local_referenced_clip_checkbutton.is_pressed():
					if clip_to_assign_locally != null:
						assign_clip_to_framelayer(clip_to_assign_locally, current_frame_of_clip_to_assign, last_updated_framelayer_button, selected_clip)
				else:
					assign_clip_to_framelayer(clip_to_assign, current_frame_of_clip_to_assign, last_updated_framelayer_button, selected_clip)
				

					

func _ready():
	popup_parent = Node.new()
	add_child(popup_parent)
	
	simple_tree_clips_dictionary = {}
	editable_tree_clips_dictionary = {}
	shortcut_tree_clips_dictionary = {}
	
	copied_stored_framelayer_buttons_for_moving = []
	
	basic_clips_list = VBoxContainer.new()
	complex_clips_list = VBoxContainer.new()
	text_clips_list = VBoxContainer.new()
	audio_clips_list = VBoxContainer.new()
	special_clips_list = VBoxContainer.new()
	is_moving_frames = false
	is_moving_layers = false
	
	stored_framelayer_buttons_for_moving = []
	
	tool_mode = Tool_modes.SELECT_MODE
	framelayer_is_selected = false
	# Setting some default values:
	project_images_path = ""
	user_message = AcceptDialog.new()
	mouse_clicked_in_canvas = false
	starting_canvas_size = Vector2(160, 144)
	#canvas.zoom_level = 2
	
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
	#var callable_for_gui_input_file_popup = Callable(self, "_on_button_gui_input_left_click")
	# -----------------Create the second menu button for "Edit"---------------
	var edit_menu_button = MenuButton.new()
	edit_menu_button.text = "Edit"
	menu_bar.add_child(edit_menu_button)
	# Create a popup menu for the "Edit" button
	var edit_popup_menu = edit_menu_button.get_popup()
	edit_popup_menu.add_item("-")
	#edit_popup_menu.add_item("Undo")
	#edit_popup_menu.add_item("Redo")
	#edit_popup_menu.add_item("Cut")
	#edit_popup_menu.add_item("Copy")
	#edit_popup_menu.add_item("Paste")
	#Connecting signals for Edit menu
	var callable_for_edit_popup = Callable(self, "_on_popup_edit_menu_item_pressed")
	edit_popup_menu.id_pressed.connect(callable_for_edit_popup)
	#var callable_for_gui_input_edit_popup = Callable(self, "_on_button_gui_input_left_click")
	# --------------Create the third menu button for "Project"----------------
	var project_menu_button = MenuButton.new()
	project_menu_button.text = "Project"
	menu_bar.add_child(project_menu_button)
	# Create a popup menu for the "Project" button
	var project_popup_menu = project_menu_button.get_popup()
	project_popup_menu.add_item("Configure images path")
	#Connecting signals for Project menu
	var callable_for_project_popup = Callable(self, "_on_popup_project_menu_item_pressed")
	project_popup_menu.id_pressed.connect(callable_for_project_popup)
	#var callable_for_gui_input_project_popup = Callable(self, "_on_button_gui_input_left_click")
	# --------------Create the fourth menu button for "View"----------------
	var view_menu_button = MenuButton.new()
	view_menu_button.text = "View"
	menu_bar.add_child(view_menu_button)
	# Create a popup menu for the "Project" button
	var view_popup_menu = view_menu_button.get_popup()
	view_popup_menu.add_item("Configure grid")
	view_popup_menu.add_item("Change canvas size")
	#Connecting signals for Project menu
	var callable_for_view_popup = Callable(self, "_on_popup_view_menu_item_pressed")
	view_popup_menu.id_pressed.connect(callable_for_view_popup)
	#var callable_for_gui_input_view_popup = Callable(self, "_on_button_gui_input_left_click")
	
	# ==================Rest of the UI======================
	var debug_box_splitbox = create_container(VSplitContainer, Control.SIZE_EXPAND_FILL, Control.SIZE_EXPAND_FILL)
	
	var clips_canvas_frame_layer_splitbox = create_container(VSplitContainer, Control.SIZE_EXPAND_FILL, Control.SIZE_EXPAND_FILL) # Parent control node contaiing everything except the menu bar (canvas, clip list, framelayer table)
	debug_box_splitbox.add_child(clips_canvas_frame_layer_splitbox)
	
	#main_vbox.add_child(clips_canvas_frame_layer_splitbox)
	main_vbox.add_child(debug_box_splitbox)
	# Create the HBoxContainer
	var clip_canvas_h_splitbox = create_container(HSplitContainer, Control.SIZE_EXPAND_FILL, Control.SIZE_EXPAND_FILL) # Contains the clip lists and the canvas
	clips_canvas_frame_layer_splitbox.add_child(clip_canvas_h_splitbox)
	# -------------Create the Clip List------------
	# Create TabContainer
	var tab_container = TabContainer.new()

	clip_canvas_h_splitbox.add_child(tab_container)
	clip_canvas_h_splitbox.split_offset = 200
	# Create ScrollContainers for each clip type
	
	"""
	var clip_types = ["Basic", "Complex", "Text", "Audio", "Special"]

	var clip_lists = [basic_clips_list, complex_clips_list, text_clips_list, audio_clips_list, special_clips_list]
	var clip_tabs_names = ["B", "C", "T", "A", "S"]
	#for clip_type in ["Basic", "Complex", "Audio", "Text", "Special"]:
	for i in range (5):
		var clip_type = clip_types[i]
		var scroll_container = ScrollContainer.new()
		#clip_lists[i] = VBoxContainer.new()
		var clip_list = clip_lists[i]
		var add_button = construct_button(Button.new(), "Add " + clip_type + " Clip", button_size, "_on_add_" + clip_type.to_lower() + "_clip_pressed")   
		clip_list.add_child(add_button)
		scroll_container.add_child(clip_list)
		tab_container.add_child(scroll_container)
		tab_container.set_tab_title(tab_container.get_tab_count() - 1, clip_tabs_names[i])#clip_type + " Clips")
"""
	#var callable_for_tree_clicked = Callable(self, "_on_tree_clicked")
	# Tree containing all clips. The user can organise them in subfolders. Each clip is represented by a single tree item.
	editable_clip_tree = CustomTree.new()

	editable_clip_tree.tree_type = "editable"
	#editable_clip_tree.connect("item_mouse_selected", callable_for_tree_clicked)
		
	editable_clip_tree.custom_minimum_size = Vector2(200, 200)
	var editable_clip_tree_container = VBoxContainer.new()
	editable_clip_tree.size_flags_vertical = Control.SIZE_EXPAND_FILL
	tab_container.add_child(editable_clip_tree_container)
	tab_container.set_tab_title(tab_container.get_tab_count() - 1, "Organised")
	editable_clip_tree_container.add_child(editable_clip_tree)
	var editable_clip_tree_root = editable_clip_tree.create_item()
	#editable_clip_tree.hide_root = true
	editable_clip_tree.allow_rmb_select = true
	
	
	# simple_clip_tree contains all clips, and it's not editable by the user..
	simple_clip_tree = CustomTree.new()

	simple_clip_tree.tree_type = "simple"
	#simple_clip_tree.connect("item_mouse_selected", callable_for_tree_clicked)
	simple_clip_tree.custom_minimum_size = Vector2(200, 200)
	
	var simple_clip_tree_container = VBoxContainer.new()
	tab_container.add_child(simple_clip_tree_container)
	tab_container.set_tab_title(tab_container.get_tab_count() - 1, "Simple")
	simple_clip_tree_container.add_child(simple_clip_tree)
	var simple_clip_tree_root = simple_clip_tree.create_item()
	simple_clip_tree.hide_root = false
	basic_clip_subfolder = simple_clip_tree.create_item(simple_clip_tree_root)
	basic_clip_subfolder.set_text(0, "Basic Clips")
	complex_clip_subfolder = simple_clip_tree.create_item(simple_clip_tree_root)
	complex_clip_subfolder.set_text(0, "Complex Clips")
	text_clip_subfolder = simple_clip_tree.create_item(simple_clip_tree_root)
	text_clip_subfolder.set_text(0, "Text Clips")
	
	#text_clip_subfolder.set_text(1, "Text Clips2")
	

	
	simple_clip_tree.allow_rmb_select = true

	
	shortcut_clip_tree = CustomTree.new()

	shortcut_clip_tree.tree_type = "shortcut"
	#shortcut_clip_tree.connect("item_mouse_selected", callable_for_tree_clicked)
	shortcut_clip_tree.custom_minimum_size = Vector2(200, 200)
	
	#var shortcut_clip_tree_tab_container = TabContainer.new()
	
	#var shortcut_clip_tree_container = VBoxContainer.new()
	var shortcut_clip_tree_root = shortcut_clip_tree.create_item()
	
	shortcut_clip_tree.hide_root = false
	shortcut_clip_tree.allow_rmb_select = true
	
	editable_clip_tree.columns = 2
	simple_clip_tree.columns = 2
	shortcut_clip_tree.columns = 2
	
	addign_dictionaries_to_trees()
	"""
	# complete_tree contains all clips, without subfolders.
	var complete_tree = CustomTree.new()
	complete_tree.custom_minimum_size = Vector2(200, 200)
	
	var container = VBoxContainer.new()
	tab_container.add_child(container)
	tab_container.set_tab_title(tab_container.get_tab_count() - 1, "Simple")
	container.add_child(complete_tree)
	var root = complete_tree.create_item()
	var basic_clip_subfolder = complete_tree.create_item(root)
	basic_clip_subfolder.set_text(0, "Basic Clips")
	var complex_clip_subfolder = complete_tree.create_item(root)
	basic_clip_subfolder.set_text(0, "Complex Clips")
	var text_clip_subfolder = complete_tree.create_item(root)
	basic_clip_subfolder.set_text(0, "Text Clips")
	
	
	
	# initialize a VBoxContainer
	var container = VBoxContainer.new()
	#var clip_directory_system_scroll = ScrollContainer.new()
	tab_container.add_child(container)
	tab_container.set_tab_title(tab_container.get_tab_count() - 1, "F")
	



	# initialize a Tree for the directory structure
	var directory_tree = CustomTree.new()
	
	# Set the minimum size for the Tree
	directory_tree.custom_minimum_size = Vector2(200, 200)


	# add them as children to the container
	container.add_child(directory_tree)
	
	# create a root item for the tree
	var root = directory_tree.create_item()

	# create some items
	var folder1 = directory_tree.create_item(root)
	folder1.set_text(0, "Folder 1")

	var folder2 = directory_tree.create_item(root)
	folder2.set_text(0, "Folder 2")

	# create a subitem
	var subfolder1 = directory_tree.create_item(folder1)
	subfolder1.set_text(0, "Subfolder 1")
	#subfolder1.set_text(1, "Subfolder 1")
	subfolder1.set_custom_color(0, Color(1, 0, 0, 1)) # red
	subfolder1.set_custom_bg_color(0, Color(0, 1, 0, 0.5)) # semi-transparent green background
	#directory_tree.custom_colors = true
	
	"""
	tab_container.show()





	# ---------------Create the Canvas-----------
	var scroll_container_canvas_tools = create_container(ScrollContainer, Control.SIZE_EXPAND_FILL, Control.SIZE_EXPAND_FILL)
	clip_canvas_h_splitbox.add_child(scroll_container_canvas_tools)
	#scroll_container_canvas_tools.size_flags_stretch_ratio = 0.6
	canvas = Canvas.new()
	canvas.set_name("Canvas")
	var hsplitbox_canvas_tools = create_container(HSplitContainer, Control.SIZE_EXPAND_FILL, Control.SIZE_EXPAND_FILL)
	scroll_container_canvas_tools.add_child(hsplitbox_canvas_tools)
	
	scroll_container_canvas = ScrollContainer.new()
	#scroll_container_canvas.size_flags_stretch_ratio = 0.6
	scroll_container_canvas.add_child(canvas)
	hsplitbox_canvas_tools.add_child(scroll_container_canvas)
	hsplitbox_canvas_tools.split_offset = 300
	canvas.custom_minimum_size = Vector2(starting_canvas_size.x * canvas.get_zoom_level(), starting_canvas_size.y * canvas.get_zoom_level())
	canvas.grid.custom_minimum_size = Vector2(starting_canvas_size.x * canvas.get_zoom_level(), starting_canvas_size.y * canvas.get_zoom_level())
	#scroll_container_canvas.custom_minimum_size = Vector2(starting_canvas_size.x * canvas.zoom_level, starting_canvas_size.y * canvas.zoom_level)
	# ---------------Create tools list-----------------------
	#var scroll_container_tools = create_container(ScrollContainer, Control.SIZE_EXPAND_FILL, Control.SIZE_EXPAND_FILL)
	#scroll_container_tools.size_flags_stretch_ratio = 0.2
	var vsplit_container_shortcut_clip_tree_and_settings = create_container(HSplitContainer, Control.SIZE_EXPAND_FILL, Control.SIZE_EXPAND_FILL)
	
	
	# Change: Tool buttons were removed (their functions now take place through key shortcuts). This section will be removed. If, later, there is need of tools, think about it later.
	"""
	var tools_scroll_container = create_container(ScrollContainer, Control.SIZE_EXPAND_FILL, Control.SIZE_EXPAND_FILL)
	
	
	var tools_list = VBoxContainer.new()#create_container(ScrollContainer, Control.SIZE_EXPAND_FILL, Control.SIZE_EXPAND_FILL)#VBoxContainer.new()
	hsplitbox_canvas_tools.add_child(vsplit_container_tools_and_settings)
	vsplit_container_tools_and_settings.add_child(tools_scroll_container)
	tools_scroll_container.add_child(tools_list)
	var tool_select_mode = construct_button(Button.new(), "Select mode", button_size, "_on_tool_select_mode_pressed")
	var tool_assign_mode = construct_button(Button.new(), "Assign mode", button_size, "_on_tool_assign_mode_pressed")
	var tool_move_mode = construct_button(Button.new(), "Move mode", button_size, "_on_tool_move_mode_pressed")
	tools_list.add_child(tool_select_mode)
	tools_list.add_child(tool_assign_mode)
	tools_list.add_child(tool_move_mode)
	"""
	var shortcut_clip_tree_vbox = VBoxContainer.new()
	shortcut_clip_tree_vbox.add_child(shortcut_clip_tree)
	var shortcut_clip_tree_scroll_container = create_container(ScrollContainer, Control.SIZE_EXPAND_FILL, Control.SIZE_EXPAND_FILL)
	var shortcut_clip_tree_tab_container = TabContainer.new()
	shortcut_clip_tree_tab_container.add_child(shortcut_clip_tree_vbox)
	shortcut_clip_tree_tab_container.set_tab_title(0, "Shortcuts")
	
	vsplit_container_shortcut_clip_tree_and_settings.add_child(shortcut_clip_tree_tab_container)#shortcut_clip_tree_vbox)
	shortcut_clip_tree_vbox.custom_minimum_size = Vector2(200, 200)
	hsplitbox_canvas_tools.add_child(vsplit_container_shortcut_clip_tree_and_settings)
	shortcut_clip_tree_tab_container.show()
	#----------------Create tools settings-------------------
	tool_settings_scroll_container = create_container(ScrollContainer, Control.SIZE_EXPAND_FILL, Control.SIZE_EXPAND_FILL)
	tool_settings_assign_mode = VBoxContainer.new()
	#tool_settings_scroll_container.add_child(tool_settings_assign_mode)
	vsplit_container_shortcut_clip_tree_and_settings.add_child(tool_settings_scroll_container)
	#var assign_one_frame = CheckButton.new()
	
	keep_offset_of_existing_framelayer_checkbox = CheckBox.new()
	keep_offset_of_existing_framelayer_checkbox.text = "keep offset of existing framelayer"
	
	var callable_keep_offset_of_existing_framelayer_checkbox = Callable(self, "_on_keep_offset_of_existing_framelayer_checkbox_pressed")
	keep_offset_of_existing_framelayer_checkbox.connect("pressed", callable_keep_offset_of_existing_framelayer_checkbox)
	
	roll_frames_vbox = VBoxContainer.new()
	roll_frames_checkbutton = CheckButton.new()
	var callable_roll_frames_checkbutton = Callable(self, "_on_roll_frames_checkbutton_toggled")
	roll_frames_checkbutton.connect("pressed", callable_roll_frames_checkbutton)
	infinite_roll_frames = CheckBox.new()
	reverse_order = CheckBox.new()
	roll_frames_checkbutton.text = "Roll frames"
	infinite_roll_frames.text = "Infinite"
	reverse_order.text = "Reverse order"
	clip_to_assign_label = Label.new()
	clip_to_assign_label.text = "Clip to be assigned (click a clip while pressing shift): "
	var starting_frame = Label.new()
	starting_frame.set_text("Starting frame:")
	starting_frame_spinbox = SpinBox.new()
	starting_frame_spinbox.min_value = 1
	starting_frame_spinbox.max_value = 1000
	var starting_frame_hbox = HBoxContainer.new()
	starting_frame_hbox.add_child(starting_frame)
	starting_frame_hbox.add_child(starting_frame_spinbox)
	
	var absolute_offset_hbox = HBoxContainer.new()
	absolute_offset_checkbox = CheckBox.new()
	absolute_offset_checkbox.text = "absolute offset (overrides the rest)"
	var callable_absolute_offset_checkbox = Callable(self, "_on_absolute_offset_checkbox_pressed")
	absolute_offset_checkbox.connect("pressed", callable_absolute_offset_checkbox)
	var absolute_offset_x_label = Label.new()
	absolute_offset_x_label.set_text("X:")
	absolute_offset_x_spinbox = SpinBox.new()
	absolute_offset_x_spinbox.min_value = 1
	absolute_offset_x_spinbox.max_value = 10000
	var absolute_offset_y_label = Label.new()
	absolute_offset_y_label.set_text("Y:")
	absolute_offset_y_spinbox = SpinBox.new()
	absolute_offset_y_spinbox.min_value = 1
	absolute_offset_y_spinbox.max_value = 10000
	absolute_offset_hbox.add_child(absolute_offset_checkbox)
	absolute_offset_hbox.add_child(absolute_offset_x_label)
	absolute_offset_hbox.add_child(absolute_offset_x_spinbox)
	absolute_offset_hbox.add_child(absolute_offset_y_label)
	absolute_offset_hbox.add_child(absolute_offset_y_spinbox)
	
	assign_mode_vbox = VBoxContainer.new()
	assign_local_referenced_clip_checkbutton = CheckButton.new()
	var callable_assign_selected_clip_checkbutton = Callable(self, "_on_assign_selected_clip_checkbutton_toggled")
	assign_local_referenced_clip_checkbutton.connect("pressed", callable_assign_selected_clip_checkbutton)
	keep_offset_of_starting_framelayer_checkbox = CheckBox.new()
	
	var callable_keep_offset_of_starting_framelayer_checkbox = Callable(self, "_on_keep_offset_of_starting_framelayer_checkbox_pressed")
	keep_offset_of_starting_framelayer_checkbox.connect("pressed", callable_keep_offset_of_starting_framelayer_checkbox)
	
	assign_local_referenced_clip_checkbutton.text = "assign local referenced clip"
	keep_offset_of_starting_framelayer_checkbox.text = "keep offset of starting framelayer"
	
	
	tool_settings_assign_mode.add_child(clip_to_assign_label)
	tool_settings_assign_mode.add_child(starting_frame_hbox)
	tool_settings_assign_mode.add_child(absolute_offset_hbox)
	tool_settings_assign_mode.add_child(keep_offset_of_existing_framelayer_checkbox)

	tool_settings_assign_mode.add_child(roll_frames_vbox)#roll_frames_checkbutton)
	tool_settings_assign_mode.add_child(assign_mode_vbox)
	roll_frames_vbox.add_child(roll_frames_checkbutton)
	assign_mode_vbox.add_child(assign_local_referenced_clip_checkbutton)
	#tool_settings_assign_mode.add_child(assign_local_referenced_clip_checkbutton)

	#grid_enabled_check.text = "Enable Grid"
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
	#var debug_button = construct_button(Button.new(), "Debug", button_size, "_on_debug_button_pressed")
	#frame_table_hbox.add_child(debug_button)
	# Reconstruct frame layer table button
	var reassign_frame_layer_table_labels_button = construct_button(Button.new(), "Reassign Labels", button_size, "_on_reassign_frame_layer_table_labels_button_pressed")
	frame_table_hbox.add_child(reassign_frame_layer_table_labels_button)
	# Note: At that point, frame_table_vbox does not yet have a frame layer table. It is added later (e.g. when you create and select a clip_

	# Creating debug box # was created as a singleton (Logger)
	#message_log = RichTextLabel.new()
	#message_log.bbcode_enabled = true
	#message_log.scroll_active = true
	#message_log.custom_minimum_size = Vector2(50, 50) # Set to a suitable size for your UI.

	# Now, create a ScrollContainer node and configure it.
	#var scroll_container = ScrollContainer.new()
	##scroll_container.custom_minimum_size = Vector2(200, 50) # Same size as the message_log.
	#scroll_container.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	#scroll_container.size_flags_vertical = Control.SIZE_EXPAND_FILL
	# Add the message_log node to the ScrollContainer.
	#scroll_container.add_child(message_log)
	Logger.set_parent(debug_box_splitbox)
	debug_box_splitbox.split_offset = 250
	tool_settings_scroll_container.add_child(tool_settings_assign_mode)
	construct_popup_menus_of_clips()
#func log_message(message):
#	message_log.append_text("\n" + message)
#	message_log.scroll_to_line(message_log.get_line_count())

func _on_tree_clicked_editable(position, mouse_button_index, basic_popup, complex_popup, text_popup, subfolder_popup):
	print("editable tree clicked")
	last_selected_tree_item = editable_clip_tree.get_selected()
	if mouse_button_index == MOUSE_BUTTON_RIGHT:
		if editable_tree_clips_dictionary.has(last_selected_tree_item): # so the selected item is not a subfolder
			var clip = editable_tree_clips_dictionary[last_selected_tree_item]
			if clip is BasicClip:
				basic_popup.set_position(get_global_mouse_position())
				basic_popup.popup()
			elif clip is ComplexClip:
				complex_popup.set_position(get_global_mouse_position())
				complex_popup.popup()
			elif clip is TextClip:
				text_popup.set_position(get_global_mouse_position())
				text_popup.popup()
		else: #a subfolder was right-clicked
			subfolder_popup_menu_editable.set_position(get_global_mouse_position())
			subfolder_popup_menu_editable.popup()
	elif mouse_button_index == MOUSE_BUTTON_LEFT:
		if editable_tree_clips_dictionary.has(last_selected_tree_item): # so the selected item is not a subfolder
			var clip = editable_tree_clips_dictionary[last_selected_tree_item]
			if tool_mode == Tool_modes.SELECT_MODE || tool_mode == Tool_modes.MOVE_MODE:
				_select_selected_clip(clip)
			elif tool_mode == Tool_modes.ASSIGN_MODE:
				print("assigning")
				clip_to_assign = clip
				clip_to_assign_label.text = "Clip to be assigned: " + clip.clip_name


func _on_tree_clicked_simple(position, mouse_button_index, basic_popup, complex_popup, text_popup):
	last_selected_tree_item = simple_clip_tree.get_selected()
	if mouse_button_index == MOUSE_BUTTON_RIGHT:
		if simple_tree_clips_dictionary.has(last_selected_tree_item): # so the selected item is not a subfolder
			var clip = simple_tree_clips_dictionary[last_selected_tree_item]
			if clip is BasicClip:
				basic_popup.set_position(get_global_mouse_position())
				basic_popup.popup()
			elif clip is ComplexClip:
				complex_popup.set_position(get_global_mouse_position())
				complex_popup.popup()
			elif clip is TextClip:
				text_popup.set_position(get_global_mouse_position())
				text_popup.popup()
		else: #a subfolder was right-clicked- do nothing, because the simple tree is not editable
			pass
	elif mouse_button_index == MOUSE_BUTTON_LEFT:
		if simple_tree_clips_dictionary.has(last_selected_tree_item): # so the selected item is not a subfolder
			var clip = editable_tree_clips_dictionary[last_selected_tree_item]
			if tool_mode == Tool_modes.SELECT_MODE || tool_mode == Tool_modes.MOVE_MODE:
				_select_selected_clip(clip)
			elif tool_mode == Tool_modes.ASSIGN_MODE:
				print("assigning")
				clip_to_assign = clip
				clip_to_assign_label.text = "Clip to be assigned: " + clip.clip_name



func _on_tree_clicked_shortcut(position, mouse_button_index, basic_popup, complex_popup, text_popup, subfolder_popup):
	last_selected_tree_item = shortcut_clip_tree.get_selected()
	if mouse_button_index == MOUSE_BUTTON_RIGHT:
		if shortcut_tree_clips_dictionary.has(last_selected_tree_item): # so the selected item is not a subfolder
			var clip = shortcut_tree_clips_dictionary[last_selected_tree_item]
			if clip is BasicClip:
				basic_popup.set_position(get_global_mouse_position())
				basic_popup.popup()
			elif clip is ComplexClip:
				complex_popup.set_position(get_global_mouse_position())
				complex_popup.popup()
			elif clip is TextClip:
				text_popup.set_position(get_global_mouse_position())
				text_popup.popup()
		else: #a subfolder was right-clicked
			subfolder_popup_menu_shortcut.set_position(get_global_mouse_position())
			subfolder_popup_menu_shortcut.popup()
	elif mouse_button_index == MOUSE_BUTTON_LEFT:
		if shortcut_tree_clips_dictionary.has(last_selected_tree_item): # so the selected item is not a subfolder
			var clip = shortcut_tree_clips_dictionary[last_selected_tree_item]
			if tool_mode == Tool_modes.SELECT_MODE || tool_mode == Tool_modes.MOVE_MODE:
				_select_selected_clip(clip)
			elif tool_mode == Tool_modes.ASSIGN_MODE:
				print("assigning")
				clip_to_assign = clip
				clip_to_assign_label.text = "Clip to be assigned: " + clip.clip_name


func _on_tree_clicked(position, mouse_button_index, tree, basic_popup, complex_popup, text_popup, subfolder_popup_menu):
	if mouse_button_index == MOUSE_BUTTON_RIGHT:
		print("clicked")
		last_selected_tree_item = tree.get_selected()
		#if tree == editable_clip_tree:
		if simple_tree_clips_dictionary.has(last_selected_tree_item) || editable_tree_clips_dictionary.has(last_selected_tree_item) || shortcut_tree_clips_dictionary.has(last_selected_tree_item): #meaning the selected TreeItem is not a subfolder:
			var clip# = editable_tree_clips_dictionary[last_selected_tree_item]
			if simple_tree_clips_dictionary.has(last_selected_tree_item):
				clip = simple_tree_clips_dictionary[last_selected_tree_item]
			elif editable_tree_clips_dictionary.has(last_selected_tree_item):
				clip = editable_tree_clips_dictionary[last_selected_tree_item]
			elif shortcut_tree_clips_dictionary.has(last_selected_tree_item):
				clip = shortcut_tree_clips_dictionary[last_selected_tree_item]
			if clip is BasicClip:
				basic_popup.set_position(get_global_mouse_position())
				basic_popup.popup()
			elif clip is ComplexClip:
				complex_popup.set_position(get_global_mouse_position())
				complex_popup.popup()
			elif clip is TextClip:
				text_popup.set_position(get_global_mouse_position())
				text_popup.popup()
		else:
			if tree == editable_clip_tree || tree == shortcut_clip_tree:
				subfolder_popup_menu_editable.set_position(get_global_mouse_position())
				subfolder_popup_menu_editable.popup()
			elif tree == shortcut_clip_tree:
				subfolder_popup_menu_shortcut.set_position(get_global_mouse_position())
				subfolder_popup_menu_shortcut.popup()
			else:
				Logger.log_message("cannot edit this list.")
	elif mouse_button_index == MOUSE_BUTTON_LEFT:
		print("clicked")
		if simple_tree_clips_dictionary.has(last_selected_tree_item) || editable_tree_clips_dictionary.has(last_selected_tree_item) || shortcut_tree_clips_dictionary.has(last_selected_tree_item): #meaning the selected TreeItem is not a subfolder:
			if tool_mode == Tool_modes.SELECT_MODE || tool_mode == Tool_modes.MOVE_MODE:
				_select_selected_clip(get_clip_from_tree_item(last_selected_tree_item))
			elif tool_mode == Tool_modes.ASSIGN_MODE:
				print("assigning")
				clip_to_assign = get_clip_from_tree_item(last_selected_tree_item)
				clip_to_assign_label.text = "Clip to be assigned: " + get_clip_from_tree_item(last_selected_tree_item).clip_name
				
func _on_tree_empty_clicked_editable(position, mouse_button_index, tree, popup):
	if mouse_button_index == MOUSE_BUTTON_RIGHT:
		print("empty clicked")
		var global_pos = tree.get_global_position() + position
		tree_empty_space_popup_menu_editable.set_position(global_pos)
		tree_empty_space_popup_menu_editable.popup()

func _on_tree_empty_clicked_shortcut(position, mouse_button_index, tree, popup):
	if mouse_button_index == MOUSE_BUTTON_RIGHT:
		print("empty clicked")
		var global_pos = tree.get_global_position() + position
		tree_empty_space_popup_menu_shortcut.set_position(global_pos)
		tree_empty_space_popup_menu_shortcut.popup()

func _on_tree_empty_space_popup_menu_item_pressed_editable(id):
	print("popuppp")
	if id == 0:
		var clip = BasicClip.new()
		#recently_created_tree_item = editable_clip_tree.create_item(editable_clip_tree.get_root()) # we know it's the editable_clip_tree, because only there you can create new clips.
		parent_of_new_tree_item = editable_clip_tree.get_root()
		#dialog_for_choosing_image_path_of_basic_clip(clip)
		#var clip = BasicClip.new()
		dialog_for_creating_or_editing_basic_clip(clip)
		print("create basic clip")
	elif id == 1:
		#recently_created_tree_item = editable_clip_tree.create_item(editable_clip_tree.get_root()) # we know it's the editable_clip_tree, because only there you can create new clips.
		parent_of_new_tree_item = editable_clip_tree.get_root()
		var clip = ComplexClip.new()
		dialog_for_creating_or_editing_complex_clip(clip)
		print("create complex clip")
	elif id == 2:
		#recently_created_tree_item = editable_clip_tree.create_item(editable_clip_tree.get_root()) # we know it's the editable_clip_tree, because only there you can create new clips.
		parent_of_new_tree_item = editable_clip_tree.get_root()
		print("create text clip")
	elif id == 3:
		#recently_created_tree_item = editable_clip_tree.create_item(editable_clip_tree.get_root()) # we know it's the editable_clip_tree, because only there you can create new clips.
		#parent_of_new_tree_item = editable_clip_tree.get_root()
		create_or_rename_folder_in_editable_or_shortcut_tree(editable_clip_tree.get_root())
		print("create folder")

func _on_tree_empty_space_popup_menu_item_pressed_shortcut(id):
	if id == 0:
		create_or_rename_folder_in_editable_or_shortcut_tree(shortcut_clip_tree.get_root())
		
func create_or_rename_folder_in_editable_or_shortcut_tree(parent_tree_item, rename_folder = false):
	print("trying to create folder.." + parent_tree_item.get_text(0))
	if dialog !=null:
		dialog.queue_free()
	dialog = AcceptDialog.new()
	add_child(dialog)
	var vbox = VBoxContainer.new()
	dialog.add_child(vbox)
	
	var label = Label.new()
	label.text = "Folder Name:"
	vbox.add_child(label)

	var line_edit = LineEdit.new()
	vbox.add_child(line_edit)
	
	var callable_for_create_folder_for_editable_tree = Callable(self, "_on_dialog_confirmed_create_or_rename_folder_for_editable_or_shortcut_tree")
	dialog.connect("confirmed", callable_for_create_folder_for_editable_tree.bind(parent_tree_item, line_edit, rename_folder))
	dialog.popup_centered(Vector2(200, 100))
	
func _on_dialog_confirmed_create_or_rename_folder_for_editable_or_shortcut_tree(parent_tree_item, line_edit, remane_folder):
	var folder_name = line_edit.text
	var folder_name_exists = has_child_tree_item_with_name(parent_tree_item, folder_name)
	if folder_name == "":
		Logger.log_message("Cannot use an empty name.")
		return
	if !folder_name_exists:
		if !remane_folder:
			var new_folder = parent_tree_item.get_tree().create_item(parent_tree_item)
			new_folder.set_text(0, folder_name)
		else:
			parent_tree_item.set_text(0, folder_name)
	else:
		Logger.log_message("A folder or clip with this name already exists there.")
	#editable_clip_tree.create_item(parent_of_new_tree_item)
	
func has_child_tree_item_with_name(parent_item, name):
	for i in range(parent_item.get_child_count()):
		if parent_item.get_child(i).get_text(0) == name:
			return true
	return false

	
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
	#var frame_layer_table_hbox_clip # The table TODO: DELETE LINE
	var frame_layer_table_hbox_clip = HBoxContainer.new()
	var placeholder_button = construct_button(Button.new(), "=", button_size, "_placeholder_function", true) # This button does nothing, it just occupies the space.
	frame_layer_table_hbox_clip.add_child(VBoxContainer.new()) # Adding the first column of the frame layer table that has the layer labels.
	frame_layer_table_hbox_clip.get_child(0).add_child(placeholder_button)
	for i in range(frames):
		add_new_frame_to_framelayer_table(frame_layer_table_hbox_clip)
	for i in range(layers):
		add_new_layer_to_framelayer_table(frame_layer_table_hbox_clip)
	clip.frame_layer_table_hbox = frame_layer_table_hbox_clip
	print("clip name ", clip.clip_name)
	print("table ", frame_layer_table_hbox_clip.get_child_count())
	


func add_new_frame_to_framelayer_table(frame_layer_table_hbox):
	frame_layer_table_hbox.add_child(VBoxContainer.new()) # Adding a new column to the frameLayer table of the selected clip.
	# Add a new frame label
	var frame_label = NumberedLabelButton.new(frame_layer_table_hbox.get_child_count() - 1)
	var callable = Callable(self, "_on_frame_label_button_pressed").bind(frame_label)
	frame_label.connect("button_down", callable)
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
		if i != 0: # 0 IS FOR LABEL
			var button = construct_button(NumberedFrameLayerButton.new(frame_layer_table_hbox.get_child_count() - 1, i), "", button_size, "_on_frame_layer_button_pressed", true)
			frame_layer_table_hbox.get_child(frame_layer_table_hbox.get_child_count() - 1).add_child(button)
			# Create a PopupMenu for the frame_label button
			var popup_menu_frame_layer = PopupMenu.new()
			button.add_child(popup_menu_frame_layer)
			# Add an item to the PopupMenu
			#popup_menu_frame_layer.add_item("Select clip")
			popup_menu_frame_layer.add_item("Choose offset")
			popup_menu_frame_layer.add_item("Remove clip")
			# Create a callable that references the _on_popup_menu_item_pressed method on this object
			var callable_for_popup_frame_layer = Callable(self, "_on_popup_menu_item_pressed_frame_layer")
			# Connect the signal to the callable
			popup_menu_frame_layer.id_pressed.connect(callable_for_popup_frame_layer.bind(button))
			# Create a callable that references the _on_button_gui_input method on this object
			var callable_for_gui_input_frame_layer = Callable(self, "_on_button_gui_input")
			# Connect the frame_label's gui_input signal to the _on_button_gui_input method
			button.gui_input.connect(callable_for_gui_input_frame_layer.bind(popup_menu_frame_layer))

func add_new_layer_to_framelayer_table(frame_layer_table_hbox):
	# Add a new layer label
	var layer_label = construct_button(NumberedLabelButton.new(frame_layer_table_hbox.get_child(0).get_child_count()), str(frame_layer_table_hbox.get_child(0).get_child_count()), button_size, "_on_layer_label_button_pressed", true)
	layer_label.custom_minimum_size = button_size
	frame_layer_table_hbox.get_child(0).add_child(layer_label)
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
	# Add a new button for each frame
	for i in range(frame_layer_table_hbox.get_child_count()):
		if i != 0:
			var button = construct_button(NumberedFrameLayerButton.new(i, frame_layer_table_hbox.get_child(0).get_child_count() - 1), "", button_size, "_on_frame_layer_button_pressed", true)
			frame_layer_table_hbox.get_child(i).add_child(button) #remem
			# Create a PopupMenu for the frame_label button
			var popup_menu_frame_layer = PopupMenu.new()
			button.add_child(popup_menu_frame_layer)
			# Add an item to the PopupMenu
			#popup_menu_frame_layer.add_item("Select clip")
			popup_menu_frame_layer.add_item("Choose offset")
			popup_menu_frame_layer.add_item("Remove clip")
			# Create a callable that references the _on_popup_menu_item_pressed method on this object
			var callable_for_popup_frame_layer = Callable(self, "_on_popup_menu_item_pressed_frame_layer")
			# Connect the signal to the callable
			popup_menu_frame_layer.id_pressed.connect(callable_for_popup_frame_layer.bind(button))
			# Create a callable that references the _on_button_gui_input method on this object
			var callable_for_gui_input_frame_layer = Callable(self, "_on_button_gui_input")
			# Connect the frame_label's gui_input signal to the _on_button_gui_input method
			button.gui_input.connect(callable_for_gui_input_frame_layer.bind(popup_menu_frame_layer))

# Functions for readability purposes
func create_container(container_type, size_flags_horizontal, size_flags_vertical):
	var container = container_type.new()
	container.size_flags_horizontal = size_flags_horizontal
	container.size_flags_vertical = size_flags_vertical
	return container

	
func construct_button(button, button_text, custom_minimum_size, on_pressed_func_call, clip_text = false): # WARNING: THE SAME FUNCTION EXISTS IN ComplexClip (and Basic Clip)
	button.text = button_text
	button.custom_minimum_size = custom_minimum_size
	button.clip_text = clip_text
	var callable = Callable(self, on_pressed_func_call).bind(button)
	button.connect("button_down", callable)
	return button



#===TODO: Move these
func _on_add_frame_button_pressed(arg1 = null): #(TODO: check removing the argument)
	if selected_clip == null || !(selected_clip is ComplexClip): # This ONLY works when a ComplexClip is selected, otherwise, it doesn't work. Basic clips have set numbers of frames (depending on the spritesheet size, and the dimentions set), and only 1 layer.
		print("frames layers UI No ComplexClip selected!")
		return
	add_new_frame_to_framelayer_table(selected_clip.frame_layer_table_hbox)
	#add_new_frame_to_clip(selected_clip)


func _on_add_layer_button_pressed(arg1 = null):
	if selected_clip == null || !(selected_clip is ComplexClip): # This ONLY works when a ComplexClip is selected, otherwise, it doesn't work.
		print("frames layers UI No ComplexClip selected!")
		return
	add_new_layer_to_framelayer_table(selected_clip.frame_layer_table_hbox)

func _on_debug_button_pressed(arg1 = null): # for debugging purposes
	print("DEBUG")


func dialog_for_creating_or_editing_text_clip(clip):# the callable may not be needed, font_callable): #the callable is not necessary?
	
	# Relevant node paths:
	# dialog.get_node("vbox/hbox0/line_edit0") name
	# dialog.get_node("vbox/hbox1/line_edit1") font image
	# dialog.get_node("vbox/hbox2/line_edit2") font file
	# dialog.get_node("vbox/hbox2/line_edit3") horizontal size of textbox
	# dialog.get_node("vbox/hbox_colors/color_picker_bg")
	# dialog.get_node("vbox/hbox_colors/color_picker_text")
	# dialog.get_node("vbox/hbox4/text_edit") text
	# Create the dialog
	if dialog != null:
		dialog.queue_free()
	var dialog = AcceptDialog.new()
	
	var font_callable = Callable(self, "_on_dialog_confirmed_create_or_modify_text_clip").bind(dialog, clip)

	
	self.add_child(dialog)
	dialog.title = "Configure Text"
	#dialog.custom_minimum_size = Vector2(400, 200)

	# Create a VBoxContainer to arrange components vertically
	var vbox = VBoxContainer.new()
	vbox.set_name("vbox")
	dialog.add_child(vbox)
	
	# Add components for clip name
	var hbox0 = HBoxContainer.new()
	hbox0.set_name("hbox0")
	vbox.add_child(hbox0)
	
	var label0 = Label.new()
	label0.text = "Name:"
	hbox0.add_child(label0)
	
	var line_edit0 = LineEdit.new()
	line_edit0.set_name("line_edit0")
	hbox0.add_child(line_edit0)
	line_edit0.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	
	# Add components for font image path
	var hbox1 = HBoxContainer.new()
	hbox1.set_name("hbox1")
	vbox.add_child(hbox1)
	
	var label1 = Label.new()
	label1.text = "Font image path:"
	hbox1.add_child(label1)
	
	var line_edit1 = LineEdit.new()
	line_edit1.set_name("line_edit1")
	hbox1.add_child(line_edit1)
	line_edit1.size_flags_horizontal = Control.SIZE_EXPAND_FILL

	var button1 = Button.new()
	button1.text = "Select"
	hbox1.add_child(button1)
	var callable1 = Callable(self, "_on_select_image_path_pressed").bind(line_edit1)
	button1.connect("button_down", callable1)

	# Add components for font data path
	var hbox2 = HBoxContainer.new()
	hbox2.set_name("hbox2")
	vbox.add_child(hbox2)
	
	var label2 = Label.new()
	label2.text = "Font data path:"
	hbox2.add_child(label2)
	
	var line_edit2 = LineEdit.new()
	line_edit2.set_name("line_edit2")
	hbox2.add_child(line_edit2)
	line_edit2.size_flags_horizontal = Control.SIZE_EXPAND_FILL

	var button2 = Button.new()
	button2.text = "Select"
	hbox2.add_child(button2)
	var callable2 = Callable(self, "_on_select_font_data_path_pressed").bind(line_edit2)
	button2.connect("button_down", callable2)
	
	
	
	# Add components for horizontal size of textbox
	var hbox3 = HBoxContainer.new()
	hbox3.set_name("hbox3")
	vbox.add_child(hbox3)
	
	var label3 = Label.new()
	label3.text = "textbox size:"
	hbox3.add_child(label3)
	
	var line_edit3 = SpinBox.new()
	line_edit3.min_value = 1
	line_edit3.max_value = 4000
	line_edit3.set_name("line_edit3")
	hbox3.add_child(line_edit3)
	line_edit3.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	
	
	var hbox_colors = HBoxContainer.new()
	hbox_colors.set_name("hbox_colors")
	var label_colors = Label.new()
	label_colors.text = "Colors: "
	
	var color_picker_button_color_bg = ColorPickerButton.new()
	if clip.clip_name != null: # if it is not a new clip.
		color_picker_button_color_bg.set_pick_color(clip.color_bg)
	else:
		color_picker_button_color_bg.set_pick_color(Color(1, 1, 1, 1))
	color_picker_button_color_bg.set_name("color_picker_bg")
	color_picker_button_color_bg.custom_minimum_size = button_size
	hbox_colors.add_child(label_colors)
	hbox_colors.add_child(color_picker_button_color_bg)
	
	
	var color_picker_button_color_text = ColorPickerButton.new()
	if clip.clip_name != null: # if it is not a new clip.
		color_picker_button_color_text.set_pick_color(clip.color_text)
	else:
		color_picker_button_color_text.set_pick_color(Color(0, 0, 0, 1))
	color_picker_button_color_text.set_name("color_picker_text")
	color_picker_button_color_text.custom_minimum_size = button_size
	hbox_colors.add_child(color_picker_button_color_text)
	
	vbox.add_child(hbox_colors)
	
	
	
	
	
	var hbox4 = HBoxContainer.new()
	hbox4.set_name("hbox4")
	vbox.add_child(hbox4)
	
	hbox4.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	hbox4.size_flags_vertical = Control.SIZE_EXPAND_FILL
	
	var label4 = Label.new()
	label4.text = "Text:"
	hbox4.add_child(label4)
	
	var text_edit = TextEdit.new()
	text_edit.set_name("text_edit")
	hbox4.add_child(text_edit)
	#text_edit.rect_min_size = Vector2(200, 100)
	text_edit.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	#text_edit.size_flags_vertical = Control.SIZE_EXPAND_FILL
	
	if clip.clip_name != null:
		# ADD THE EXISTING VALUES HERE IF AN EXISTING CLIP IS MODIFIED
		line_edit0.set_text(clip.clip_name)
		line_edit1.set_text(clip.image_path)
		line_edit2.set_text(clip.font_data_path)
		line_edit3.set_value(clip.textbox_size)
		#color_picker_button_color_bg.set_pick_color(color_bg)
		#color_picker_button_color_text.set_pick_color(color_text)
		var text_array = clip.texts
		var joined_text = ""
		for i in range(len(text_array)):
			if i != 0:
				joined_text += "\n\n"
			joined_text += text_array[i]
		text_edit.set_text(joined_text)
	print("1")
	dialog.connect("confirmed", font_callable)
	# Show the dialog
	dialog.popup_centered(Vector2(200, 200))

func _on_select_image_path_pressed_for_basic_clip(line_edit):
	# Remove the old FileDialog if it exists. This deletes the existing connections.
	if file_dialog != null:
		file_dialog.queue_free()
	if project_images_path == "": # The user needs to first choose the path of the folder where images should be located.
		if dialog != null:
			dialog.queue_free()
		dialog = AcceptDialog.new()
		dialog.dialog_text = "Please first set the path where images should be saved (Project->Configure images path). The relevant images should be saved in there."
		Logger.log_message("Project path needs to be set first.")
		add_child(dialog)
		dialog.popup_centered()
		return
	
	file_dialog = FileDialog.new()
	add_child(file_dialog)
	file_dialog.access = FileDialog.ACCESS_FILESYSTEM
	file_dialog.file_mode = FileDialog.FILE_MODE_OPEN_FILE
	file_dialog.filters = ["*.png ; PNG Images"]
	file_dialog.current_path = project_images_path + "/"  # Set initial directory
	var callable = Callable(self, "_on_dialog_confirmed_select_image_path").bind(line_edit)
	file_dialog.connect("file_selected", callable)
	file_dialog.popup_centered(Vector2(800, 600))
	
	
func _on_select_image_path_pressed(line_edit1):
	if file_dialog != null:
		file_dialog.queue_free()
	file_dialog = FileDialog.new()
	add_child(file_dialog)
	file_dialog.access = FileDialog.ACCESS_FILESYSTEM
	file_dialog.file_mode = FileDialog.FILE_MODE_OPEN_FILE
	file_dialog.filters = ["*.png ; PNG Images"]
	file_dialog.current_path = project_images_path + "/"  # Set initial directory
	print("current_path ", project_images_path)
	var callable = Callable(self, "_on_dialog_confirmed_select_image_path").bind(line_edit1)
	file_dialog.connect("file_selected", callable)
	file_dialog.popup_centered(Vector2(800, 600))

func _on_dialog_confirmed_select_image_path(absolute_path, line_edit1):
	#var image = Image.new()
	if (absolute_path.find(project_images_path) == -1): # The file is not inside the project's images folder
		Logger.log_message("The file(s) needs to be located within " + project_images_path +". To select a new project folder, please fo to project -> Configure files path")
		return
	#if image.load(absolute_path) == OK: # Image is loaded here
		#var relative_path = absolute_path.replace(project_images_path + "/", "")
	line_edit1.text = absolute_path
	#else:
	#	print("image not OK.") #Todo: Consider error message here.
	#	return

func _on_dialog_confirmed_select_image_path_for_basic_clip_old(absolute_path, line_edit):
	var image = Image.new()
	if (absolute_path.find(project_images_path) == -1): # The file is not inside the project's images folder
		Logger.log_message("The file(s) needs to be located within " + project_images_path +". To select a new project folder, please fo to project -> Configure files path")
		return
	if image.load(absolute_path) == OK: # Image is loaded here
		var relative_path = absolute_path.replace(project_images_path + "/", "")
		line_edit.text = relative_path
	else:
		print("image not OK.") #Todo: Consider error message here.
		return

func _on_select_font_data_path_pressed(line_edit2):
	if file_dialog != null:
		file_dialog.queue_free()
	file_dialog = FileDialog.new()
	add_child(file_dialog)
	file_dialog.access = FileDialog.ACCESS_FILESYSTEM
	file_dialog.file_mode = FileDialog.FILE_MODE_OPEN_FILE
	file_dialog.filters = ["*.txt ; TXT Images"]
	file_dialog.current_path = project_images_path + "/"  # Set initial directory
	var callable = Callable(self, "_on_dialog_confirmed_select_font_data_path").bind(line_edit2)
	file_dialog.connect("file_selected", callable)
	file_dialog.popup_centered(Vector2(800, 600))

func _on_dialog_confirmed_select_font_data_path(absolute_path, line_edit2):
	if (absolute_path.find(project_images_path) == -1): # The file is not inside the project's images folder
		print("not in path")
		Logger.log_message("The file(s) needs to be located within " + project_images_path +". To select a new project folder, please fo to project -> Configure files path")
		return
	#var relative_path = absolute_path.replace(project_images_path + "/", "")
	line_edit2.text = absolute_path


	
func _on_dialog_confirmed_create_or_modify_text_clip(dialog, clip):
	var clip_name =  dialog.get_node("vbox/hbox0/line_edit0").text
	var font_image_path = dialog.get_node("vbox/hbox1/line_edit1").text
	var font_file_path = dialog.get_node("vbox/hbox2/line_edit2").text
	var textbox_size = dialog.get_node("vbox/hbox3/line_edit3").value #but it's not a line edit...
	var color_bg = dialog.get_node("vbox/hbox_colors/color_picker_bg").get_pick_color()
	var color_text = dialog.get_node("vbox/hbox_colors/color_picker_text").get_pick_color()
	var text_array_temp =  dialog.get_node("vbox/hbox4/text_edit").text # contains user generated text, with double newlines
	var text_array = text_array_temp.split("\n\n")
	
	create_or_modify_text_clip(clip, clip_name, font_image_path, font_file_path, textbox_size, color_bg, color_text, text_array)
	
func create_or_modify_text_clip(clip, clip_name, font_image_path, font_file_path, textbox_size, color_bg, color_text, text_array):
	print("create or mod text  clip")
	
	for clip_in_dict in simple_tree_clips_dictionary.values(): #remember, simple_tree_clips_dictionary contains all clips.
		if clip_name == clip_in_dict.clip_name:
			Logger.log_message("clip name " + clip_name + " already exists. Please select another name.")
			return

	if clip.clip_name == null: #meaning a new clip is created
		var popup_menu = PopupMenu.new()
		popup_parent.add_child(popup_menu)
		popup_menu.add_item("Edit")
		popup_menu.add_item("Delete clip")
		var callable_for_popup = Callable(self, "_on_text_clip_popup_menu_item_pressed")
		popup_menu.id_pressed.connect(callable_for_popup.bind(clip))
		
		#recently_created_tree_item = editable_clip_tree.create_item(editable_clip_tree.get_root()) # we know it's the editable_clip_tree, because only there you can create new clips.
		#parent_of_new_tree_item = editable_clip_tree.get_root()
		var new_tree_item = editable_clip_tree.create_item(parent_of_new_tree_item)
		editable_tree_clips_dictionary[new_tree_item] = clip
		new_tree_item.set_text(1, "Text Clip")
		
		var tree_item_for_text_clips_tree = text_clip_subfolder.get_tree().create_item(text_clip_subfolder)
		simple_tree_clips_dictionary[tree_item_for_text_clips_tree] = clip
		tree_item_for_text_clips_tree.set_text(1, "Text Clip")
		
	print("font image path: " + font_image_path)
	print("font path: " + font_file_path)
	var absolute_path_image = font_image_path
	var absolute_path_font_data = font_file_path 
	var relative_path_image = absolute_path_image.replace(project_images_path + "/", "")
	var relative_path_font_data = absolute_path_font_data.replace(project_images_path + "/", "")
		
	clip.clip_name = clip_name
	clip.image_path = relative_path_image
	clip.font_data_path = relative_path_font_data
	clip.textbox_size = textbox_size
	clip.color_bg = color_bg
	clip.color_text = color_text
	clip.texts = text_array
	
	change_names_and_colors_in_all_dictionaries(clip, clip_name, color_bg, color_text)
	# TODO: CONTINUE HERE
	
	
	
	# TODO IMPORTANT: Later, the file will be chosed by file chooser. When this is implemented, the above check is necessary (check if project's path is part of the absolute path)
	

	var image = Image.new()
	if image.load(absolute_path_image) == OK: # Image is loaded here
		clip.font_image = image
		print("FONT IMAGE WAS OK ")
	else:
		Logger.log_message("Image of the font with path " + absolute_path_image + " could not be loaded.")
		return
	
	# Load the font data.
	print("abs path " + absolute_path_font_data)
	var file = FileAccess.open(absolute_path_font_data, FileAccess.READ)
	var err = file.get_error()
	if err != OK:
		Logger.log_message("txt file of the font with path " + absolute_path_image + " could not be loaded.")
		return
	var font_data_text = file.get_as_text()
	file.close()
	clip.font_data_text = font_data_text
	
	
	clip.construct_texts()
	contruct_frame_layer_table_clip(clip.texts.size(), 1, clip)
	reconstruct_frame_table_attributes() # to recolor the frame table if needed
	
	
	return clip



func _on_button_gui_input(event, popup_menu: PopupMenu):
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_RIGHT and event.pressed:
	# If the event is a right mouse button press, show the popup menu. Used for various popup menus in the application.
		popup_menu.set_position(get_global_mouse_position())
		popup_menu.popup()

func _on_button_gui_input_left_click(event, popup_menu: PopupMenu): # DELETE?
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
	# If the event is a right mouse button press, show the popup menu. Used for menu bar popups.
		popup_menu.popup()


func delete_clip(clip):
	var simple_tree_items_to_delete = []
	var editable_tree_items_to_delete = []
	var shortcut_tree_items_to_delete = []
	for key in simple_tree_clips_dictionary.keys():
		if simple_tree_clips_dictionary[key] == clip:
			simple_tree_items_to_delete.append(key)
	for key in editable_tree_clips_dictionary.keys():
		if editable_tree_clips_dictionary[key] == clip:
			editable_tree_items_to_delete.append(key)
	for key in shortcut_tree_clips_dictionary.keys():
		if shortcut_tree_clips_dictionary[key] == clip:
			shortcut_tree_items_to_delete.append(key)
			
	for tree_item in simple_tree_items_to_delete:
		tree_item.get_parent().remove_child(tree_item)
		simple_tree_clips_dictionary.erase(tree_item)
		
	for tree_item in editable_tree_items_to_delete:
		tree_item.get_parent().remove_child(tree_item)
		editable_tree_clips_dictionary.erase(tree_item)
		
	for tree_item in shortcut_tree_items_to_delete:
		tree_item.get_parent().remove_child(tree_item)
		shortcut_tree_clips_dictionary.erase(tree_item)
			

func _on_popup_menu_item_pressed(id : int, button_to_delete : Button) -> void:
	# TODO: not used.
	if id == 0:  # The ID of the "Delete clip" item
	# Delete the button
		button_to_delete.queue_free()
#===End of TODO: Move these




#==============================REORDERING FRAMES OR LABELS==================================
func _on_popup_menu_item_pressed_label_frame(id : int, label_selected: NumberedLabelButton) -> void:
	if id == 0: # reorder frame
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
# -------------
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
# -----------------
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
# ----------------------------
func _on_dialog_confirmed_frame_or_layer_reorder(dialog, type, frame_or_layer_to_reorder):
	var line_edit = dialog.get_node("Input")
	var text_input = line_edit.text
	var new_index = int(text_input)
	if new_index !=0 :#is_int(text_input):
		if type == "reorder_frame":
			reorder_frame(frame_or_layer_to_reorder, new_index)
			#selected_clip.frame_layer_table_hbox.move_child(selected_clip.frame_layer_table_hbox.get_child(frame_or_layer_to_reorder), new_index) # TODO: WE NEED ADDITIONAL CHECKS
			#reconstruct_frame_table_attributes()
		elif type == "reorder_layer":
			reorder_layer(frame_or_layer_to_reorder, new_index)
			#for i in range(selected_clip.frame_layer_table_hbox.get_child_count()):
			#	selected_clip.frame_layer_table_hbox.get_child(i).move_child(selected_clip.frame_layer_table_hbox.get_child(i).get_child(frame_or_layer_to_reorder), new_index)
			#	reconstruct_frame_table_attributes()
	else:
		print("frames layers UI Invalid input")

func reorder_frame(original_position, new_position):
	selected_clip.frame_layer_table_hbox.move_child(selected_clip.frame_layer_table_hbox.get_child(original_position), new_position) # TODO: WE NEED ADDITIONAL CHECKS
	reconstruct_frame_table_attributes()
	
func reorder_layer(original_position, new_position):
	for i in range(selected_clip.frame_layer_table_hbox.get_child_count()):
		selected_clip.frame_layer_table_hbox.get_child(i).move_child(selected_clip.frame_layer_table_hbox.get_child(i).get_child(original_position), new_position)
		reconstruct_frame_table_attributes() # TODO: Does this need to be here, or outside the loop is fine?
	render_frame(selected_frame)

#=========================END OF REORDERING FRAMES OR LABELS==================================


#========================FRAMELAYER POPUP MENU==========================
#-------------frameLayer Popup
func _on_popup_menu_item_pressed_frame_layer(id : int, frame_layer_button: NumberedFrameLayerButton) -> void:
	if id == 100:  # This is no longer used.
		# Select clip for frameLayer
		# Relevant node paths:
		# dialog.get_node("vbox/hbox_name/InputName")
		# dialog.get_node("vbox/hbox_frame/InputFrame")
		# TODO: If a clip is already loaded, preload the data in the dialog window.
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
		
		var label_instructions = Label.new()

		hbox_name.add_child(label_instructions)
		hbox_name.add_child(label_name)
		hbox_name.add_child(line_edit_name)
		vbox.add_child(hbox_name)
		
		var hbox_frame = HBoxContainer.new()
		hbox_frame.set_name("hbox_frame")
		var label_frame = Label.new()
		label_frame.text = "Frame of clip: "
		var line_edit_frame = LineEdit.new()
		line_edit_frame.set_name("InputFrame")
		hbox_frame.add_child(label_frame)
		hbox_frame.add_child(line_edit_frame)
		vbox.add_child(hbox_frame)

		add_child(dialog)
		var callable = Callable(self, "_on_dialog_confirmed_select_clip_for_framelayer").bind(dialog, frame_layer_button)
		dialog.connect("confirmed", callable)
		dialog.popup_centered()
	if id == 0: # set offset of frameLayer
		# Relevant node paths:
		# dialog.get_node("vbox/hbox_offset_x/InputOffsetX")
		# dialog.get_node("vbox/hbox_offset_y/InputOffsetY")
		# TODO: If a clip is already loaded, preload the data in the dialog window.
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
	if id == 1:
		remove_clip_from_framelayer(frame_layer_button)
		render_frame(selected_frame)
		
#------------------- Select clip and frame for frameLayer
func assign_clip_to_framelayer(clip, frame_selected, frame_layer_button, parent_clip = null): # parent clip is only for checking circular references.
	# TODO: Make the necessary checks here for cycle references?
	if parent_clip== null || !clip.arg_clip_is_child_of_self(parent_clip):
		frame_layer_button.frameLayer.clip_used = clip
		frame_layer_button.frameLayer.frame_of_clip = frame_selected
		var button_style = StyleBoxFlat.new()
		button_style.bg_color = frame_layer_button.frameLayer.get_clip().color_bg
		frame_layer_button.add_theme_stylebox_override("normal", button_style)
		frame_layer_button.add_theme_color_override("font_color", frame_layer_button.frameLayer.get_clip().color_text)
		frame_layer_button.add_theme_color_override("font_focus_color", frame_layer_button.frameLayer.get_clip().color_text)
		frame_layer_button.text = str(frame_layer_button.frameLayer.frame_of_clip)
		render_framelayer(frame_layer_button.frameLayer.frame_number, frame_layer_button.frameLayer.layer_number)
	else:
		Logger.log_message("circular reference detected. Clip is not referenced.")

func remove_clip_from_framelayer(frame_layer_button):
	var fr = frame_layer_button.frameLayer
	var new_framelayer_button = NumberedFrameLayerButton.new(fr.frame_number, fr.layer_number)
	new_framelayer_button = construct_button(new_framelayer_button, "", button_size, "_on_frame_layer_button_pressed", true)
	
	var parent = selected_clip.frame_layer_table_hbox.get_child(fr.frame_number)
	
	var old_button = selected_clip.frame_layer_table_hbox.get_child(fr.frame_number).get_child(fr.layer_number)
	
	var old_position = old_button.get_index()
	print("INDEX ", old_position)
	
	parent.remove_child(old_button)
	
	parent.add_child(new_framelayer_button)
	parent.move_child(new_framelayer_button, old_position)
	
	
func _on_dialog_confirmed_select_clip_for_framelayer_old(dialog, frame_layer_button):
	var line_edit = dialog.get_node("vbox/hbox_name/InputName")
	var text_input = line_edit.text
	
	var frame_selected = int(dialog.get_node("vbox/hbox_frame/InputFrame").text)
	
	for i in range(0, basic_clip_subfolder.get_child_count()):
		if text_input == get_clip_from_tree_item(basic_clip_subfolder.get_child(i)).clip_name:
			assign_clip_to_framelayer(basic_clip_subfolder.get_child(i), frame_selected, frame_layer_button, selected_clip)

			return
	for i in range(0, complex_clip_subfolder.get_child_count()):
		if text_input == get_clip_from_tree_item(complex_clip_subfolder.get_child(i)).clip_name:
			assign_clip_to_framelayer(basic_clip_subfolder.get_child(i), frame_selected, frame_layer_button, selected_clip)
			return
#------------ Assign offset of frameLayer
func _on_dialog_confirmed_select_offset_for_framelayer(dialog, frame_layer_button):
	var x_offset = int(dialog.get_node("vbox/hbox_offset_x/InputOffsetX").text)
	var y_offset = int(dialog.get_node("vbox/hbox_offset_y/InputOffsetY").text)
	
	frame_layer_button.frameLayer.offset_framelayer = Vector2(x_offset, y_offset)
#========================END OF FRAMELAYER POPUP MENU==========================


#====================FRAMELAYER TABLE BUTTONS PRESS=================
func _on_frame_layer_button_pressed(button : NumberedFrameLayerButton) -> void:
	if tool_mode == Tool_modes.SELECT_MODE:
		print("frames layers UI, frame and layer: " + str(button.get_frame()) + " " + str(button.get_layer()))
		print("frames layers UI, frame and layer offset: " + str(button.frameLayer.offset_framelayer))
		selected_frame = button.get_frame()
		selected_layer = button.get_layer()
		selected_framelayer_button = button # for copying pasting
		framelayer_selection_frame = selected_frame
		framelayer_selection_layer = selected_layer
		framelayer_is_selected = true
		selecting_framelayers = true
		for fr in stored_framelayer_buttons_for_moving:
			#var new_stylebox = fr.get_theme_stylebox("normal")#.border_color = Color(1, 1, 1, 1)
			#new_stylebox.border_width_bottom = 0
			#new_stylebox.border_width_top = 0
			#new_stylebox.border_width_left = 0
			#new_stylebox.border_width_right = 0
			var new_stylebox_normal = fr.get_theme_stylebox("normal")#.border_color = Color(1, 1, 1, 1)
			var new_stylebox_hover = fr.get_theme_stylebox("hover")
			new_stylebox_normal.border_width_bottom = 0
			new_stylebox_normal.border_width_top = 0
			new_stylebox_normal.border_width_left = 0
			new_stylebox_normal.border_width_right = 0
			new_stylebox_hover.border_width_bottom = 0
			new_stylebox_hover.border_width_top = 0
			new_stylebox_hover.border_width_left = 0
			new_stylebox_hover.border_width_right = 0
			#fr.add_theme_stylebox_override("normal", new_stylebox)
		stored_framelayer_buttons_for_moving = []
		#render_frame(selected_frame)
		render_framelayer(selected_frame, selected_layer)
		# TODO: Maybe render ONLY the frameLayer?
	elif tool_mode == Tool_modes.ASSIGN_MODE:
		first_framelayer_offset = button.frameLayer.offset_framelayer
		clip_to_assign_locally = button.frameLayer.clip_used
		if clip_to_assign == null:
			Logger.log_message("no clip selected to assign")
		else:
			dragging_assigning = true
			last_updated_framelayer_button = button
			current_frame_of_clip_to_assign = starting_frame_spinbox.value
			
			
			
			
			var offset = Vector2(0,0)
			if absolute_offset_checkbox.is_pressed():
				offset = Vector2(absolute_offset_x_spinbox.value, absolute_offset_y_spinbox.value)
			elif keep_offset_of_existing_framelayer_checkbox.is_pressed():
				offset = last_updated_framelayer_button.frameLayer.offset_framelayer
			elif keep_offset_of_starting_framelayer_checkbox.is_pressed():
				offset = first_framelayer_offset #clip_to_assign_locally.frameLayer.offset_framelayer
			last_updated_framelayer_button.frameLayer.offset_framelayer = offset
			if assign_local_referenced_clip_checkbutton.is_pressed():
				if clip_to_assign_locally != null:
					assign_clip_to_framelayer(clip_to_assign_locally, current_frame_of_clip_to_assign, last_updated_framelayer_button, selected_clip)
			else:
				assign_clip_to_framelayer(clip_to_assign, current_frame_of_clip_to_assign, last_updated_framelayer_button, selected_clip)
			#assign_clip_to_framelayer(clip_to_assign, starting_frame_spinbox.value, button, selected_clip)
			# TODO: ASSIGN ASSIGNED CLIP HERE
	elif tool_mode == Tool_modes.MOVE_MODE:
		if start_selection_frame == null:
			Logger.log_message("no framelayers selected to move")
		else:
			var move_to_frame = button.get_frame()
			var move_to_layer = button.get_layer()
			var new_stored_framelayer_buttons_for_moving = []
			for framelayer_button in stored_framelayer_buttons_for_moving:
				remove_clip_from_framelayer(framelayer_button)
				var new_frame = framelayer_button.frameLayer.frame_number - start_selection_frame + move_to_frame
				var new_layer = framelayer_button.frameLayer.layer_number - start_selection_layer + move_to_layer
				if new_frame < selected_clip.frame_layer_table_hbox.get_child_count() && new_layer <selected_clip.frame_layer_table_hbox.get_child(0).get_child_count():
					var parent = selected_clip.frame_layer_table_hbox.get_child(new_frame)
					var old_child = parent.get_child(new_layer)
					var old_position = old_child.get_index()
					parent.remove_child(old_child)
					parent.add_child(framelayer_button)
					parent.move_child(framelayer_button, old_position)
					framelayer_button.frameLayer.frame_number = new_frame
					framelayer_button.frameLayer.layer_number = new_layer
					new_stored_framelayer_buttons_for_moving.append(framelayer_button)
			stored_framelayer_buttons_for_moving = new_stored_framelayer_buttons_for_moving
			#end_selection_frame = end_selection_frame - (start_selection_frame - move_to_frame) #is this used anywhere here?
			#end_selection_layer = end_selection_layer - (start_selection_layer - move_to_layer)
			start_selection_frame = move_to_frame # or you can retrieve this from the 1st element in stored_framelayer_buttons_for_moving
			start_selection_layer = move_to_layer
				#^ to allow for further movements




func assigning_selection_to_framelayer():
	
	var move_to_frame = selected_framelayer_button.get_frame()
	var move_to_layer = selected_framelayer_button.get_layer()

	var temp_deep_copy = []
	stored_framelayer_buttons_for_moving = [] # doing this because allowing movement right after pasting may cause problems, because framelayers are reassiged.
	for framelayer_button in copied_stored_framelayer_buttons_for_moving:
		var copied_framelayer_button = framelayer_button.create_deep_copy()
		temp_deep_copy.append(copied_framelayer_button)
	
	# the first framelayer_button contains the "start_selection_frame
	var start_selection_frame_for_pasting = temp_deep_copy[0].frameLayer.frame_number
	var start_selection_layer_for_pasting = temp_deep_copy[0].frameLayer.layer_number
	for framelayer_button in temp_deep_copy:
		#remove_clip_from_framelayer(framelayer_button)
		
		var new_frame = framelayer_button.frameLayer.frame_number - start_selection_frame_for_pasting + move_to_frame
		var new_layer = framelayer_button.frameLayer.layer_number - start_selection_layer_for_pasting + move_to_layer
		
		if new_frame < selected_clip.frame_layer_table_hbox.get_child_count() && new_layer <selected_clip.frame_layer_table_hbox.get_child(0).get_child_count():
			#print("tryin to paste ", framelayer_button.frameLayer.get_clip().clip_name)
			
			#assign_clip_to_framelayer(framelayer_button, new_frame, new_layer)
			var old_framelayer_button = frame_layer_table_hbox.get_child(new_frame).get_child(new_layer)

			var clip = framelayer_button.frameLayer.clip_used
			var frame_selected = framelayer_button.frameLayer.frame_of_clip
			var frame_layer_button = old_framelayer_button
			if framelayer_button.frameLayer.get_clip() != null:
				assign_clip_to_framelayer(clip, frame_selected, frame_layer_button)
			framelayer_button.frameLayer.frame_number = new_frame
			framelayer_button.frameLayer.layer_number = new_layer
			

	
func _on_frame_label_button_pressed(button : NumberedLabelButton) -> void:
	#if tool_mode == Tool_modes.SELECT_MODE:
	print("frames layers UI, frame label: " + str(button.get_number()))
	selected_frame = button.get_number()
	framelayer_is_selected = false
	render_frame(selected_frame)
	#elif tool_mode == Tool_modes.MOVE_MODE:
	start_frame_movement(button)
		

func _on_layer_label_button_pressed(button : NumberedLabelButton) -> void:
	#if tool_mode == Tool_modes.SELECT_MODE:
	print("frames layers UI, layer label: " + str(button.get_number()))
	selected_layer = button.get_number()
	framelayer_is_selected = false
	render_frame(selected_frame)
	#elif tool_mode == Tool_modes.MOVE_MODE:
	start_layer_movement(button)
		
func start_frame_movement(button):
	is_moving_frames = true
	frame_to_be_moved = button.number

func start_layer_movement(button):
	is_moving_layers = true
	layer_to_be_moved = button.number
#====================END OF FRAMELAYER TABLE BUTTONS PRESS=================
	


func reconstruct_frame_table_attributes():
	# Reconstructs the attributes of frameLayer table of the selected clip. It runs in the collowing cases:
	# IMPORTANT: It does not change the numbers written on the labels (e.g. when reordering frames or layers).
	# 1) when a frame or layer is deleted
	# 2) when a clip is deleted (removing the references of the clip)
	# 3) when a new clip is selected.
	# 4) when frames or layers are reordered
	# 5) when a clip is edited (because the colors may be edited)
	# 6) TODO: When a clip is deleted
	# The reconstruction includes:
	# Assigning the correct numbers to frame and layer labels,
	# 
	# TODO: Note that the frameLayer tables of clips that are not selected do not get updated, so this is something that needs to be considered when saving.
	# TODO2: See what should happen if the currently selected clip is deleted.
	if selected_clip == null: # this happens e.g. when loading a save
		return
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
				if frameLayer.get_clip() != null:
					#check if clip exists:
					var clip_exists = false
					for k in range (0, basic_clip_subfolder.get_child_count()):
						if frameLayer.get_clip() == get_clip_from_tree_item(basic_clip_subfolder.get_child(k)):
							clip_exists = true
							break
					for k in range (0, complex_clip_subfolder.get_child_count()):
						if frameLayer.get_clip() == get_clip_from_tree_item(complex_clip_subfolder.get_child(k)):
							clip_exists = true
							break
					
					if clip_exists && !(selected_clip is BasicClip):
						var button_style = StyleBoxFlat.new()
						#var frameLayer_button = selected_clip.frame_layer_table_hbox.get_child(i)
						button_style.bg_color = frameLayer.get_clip().color_bg
						frameLayer_button.add_theme_stylebox_override("normal", button_style)
						frameLayer_button.add_theme_color_override("font_color", frameLayer.get_clip().color_text)
						frameLayer_button.add_theme_color_override("font_focus_color", frameLayer.get_clip().color_text)
					else:
						# TODO: implement what should be done if referenced clip doesn't exist (it is deleted)
						pass
						#var button_style = StyleBoxFlat.new()
						##var frameLayer_button = selected_clip.frame_layer_table_hbox.get_child(i)
						#button_style.bg_color = Color(0.5, 0.5, 0.5, 1) #deleted clip
						#frameLayer_button.add_theme_stylebox_override("normal", button_style)
						#frameLayer_button.add_theme_color_override("font_color", Color(0, 0, 0, 1))
						#frameLayer_button.add_theme_color_override("font_focus_color", Color(0,0,0,1))

func _on_reassign_frame_layer_table_labels_button_pressed(arg1 = null):
	if selected_clip == null:
		return
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




#============================ CREATING A NEW CLIP, AND MODIFYING CLIPS =========================
# Creating a clip. The relevant functions for creating a clip are both used for creation and for edition of clips. Here is the order that these functions are called:
# Creating a complex clip:
# a) Click "add complex clip"
# b) _on_add_complex_clip_pressed(). Here, a new clip is created (this clip doesn't serve a specific purpose. Its name is null, and this allows the program to recognise that a new clip is created instead of modifying an existing one), and then:
# c) dialog_for_creating_or_editing_complex_clip(clip) (the dialog is created)
# d) _on_dialog_confirmed_create_or_edit_clip(dialog, clip) (this function is used for both basic and complex clips, and for both creating and modifying clips.)
# e) create_complex_clip(name_text_input, color_bg, color_text) : Here, a new clip is created with these attributes. This function is also used when loading clips.

# Creating a basic clip:
# a) Click "add basic clip"
# b) _on_add_basic_clip_pressed(). Here, a new clip is created (this clip doesn't serve a specific purpose. Its name is null, and this allows the program to recognise that a new clip is created instead of modifying an existing one), and then:
# c) dialog_for_choosing_image_path_of_basic_clip(clip) : A window that allow the user to choose a file. Also used when the user wants to modify the path to the file of a BasicClip.
# d) _on_dialog_confirmed_choosing_image_path_of_basic_clip(file_dialog, clip)
# Again, the clip variable is checked: If the name is null, it is a new clip so it proceeds to the next step of:
# c) dialog_for_creating_or_editing_basic_clip(clip) (the dialog is created)
# d) _on_dialog_confirmed_create_or_edit_clip(dialog, clip) (this function is used for both basic and complex clips, and for both creating and modifying clips.)
# e) create_basic_clip(clip_name, dimentions, path, color_bg, color_text) : Here, a new clip is created with these attributes. This function is also used when loading clips.
# f) modify_basic_clip

# Modifying a complex clip:
# a) Right click on a complex clip and click Edit
# b) _on_basic_clip_popup_menu_item_pressed(id, button) (the 1st option (0) of the popup menu)
# c) dialog_for_creating_or_editing_complex_clip(clip)
# d) _on_dialog_confirmed_create_or_edit_clip(dialog, clip)
# e) modify_complex_clip(clip, name_text_input, color_bg, color_text)

# Modifying a basic clip:
# a) Right click on a basic clip and click Edit
# b) _on_basic_clip_popup_menu_item_pressed(id, button) (the 1st option (0) of the popup menu)
# c) dialog_for_creating_or_editing_basic_clip(clip)
# d) _on_dialog_confirmed_create_or_edit_clip(dialog, clip)
# e) modify_basic_clip(clip, clip_name, dimensions, color_bg, color_text)



func dialog_for_creating_or_editing_complex_clip(clip):#is_new_clip, existing_name = null, existing_color_bg = null, existing_color_text = null):
	# The clip parameter is either an existing clip, or a new clip created before this function is called.
	# This function serves 2 purposes: Both creation and edit of a clip.
	# Relevant node paths:
	# get_node("vbox/hbox_name/InputName")
	# get_node("vbox/hbox_colors/color_picker_bg")
	# get_node("vbox/hbox_colors/color_picker_text")
	
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
	if clip.clip_name != null: # if it is not a new clip.
		line_edit_name.text = clip.clip_name
	line_edit_name.set_name("InputName") #we need to retrieve it later
	
	hbox_name.add_child(label_name)
	hbox_name.add_child(line_edit_name)
	vbox.add_child(hbox_name)
	
	
	var hbox_colors = HBoxContainer.new()
	hbox_colors.set_name("hbox_colors")
	var label_colors = Label.new()
	label_colors.text = "Colors: "
	
	var color_picker_button_color_bg = ColorPickerButton.new()
	if clip.clip_name != null: # if it is not a new clip.
		color_picker_button_color_bg.set_pick_color(clip.color_bg)
	else:
		color_picker_button_color_bg.set_pick_color(Color(1, 1, 1, 1))
	color_picker_button_color_bg.set_name("color_picker_bg")
	color_picker_button_color_bg.custom_minimum_size = button_size
	hbox_colors.add_child(label_colors)
	hbox_colors.add_child(color_picker_button_color_bg)
	
	
	var color_picker_button_color_text = ColorPickerButton.new()
	if clip.clip_name != null: # if it is not a new clip.
		color_picker_button_color_text.set_pick_color(clip.color_text)
	else:
		color_picker_button_color_text.set_pick_color(Color(0, 0, 0, 1))
	color_picker_button_color_text.set_name("color_picker_text")
	color_picker_button_color_text.custom_minimum_size = button_size
	hbox_colors.add_child(color_picker_button_color_text)
	
	vbox.add_child(hbox_colors)
	
	add_child(dialog)
	var callable = Callable(self, "_on_dialog_confirmed_create_or_edit_complex_clip").bind(dialog, clip)
	dialog.connect("confirmed", callable)
	dialog.popup_centered()
	


func _on_dialog_confirmed_create_or_edit_basic_clip(dialog, clip):
	var name_text_input = dialog.get_node("vbox/hbox_name/InputName").text
	# Check if name is empty (should not be), or if a clip with that name already exists. Clips, whether being complex or basic, cannot have the same name.
		
	if name_text_input == clip.clip_name:
		# This happens if e.g. the user wants to change some other attribute, e.g. the colors of the clip, and leaves the name as is.
		pass
	elif name_text_input == "" && name_text_input == null:
		print("clip name cannot be empty")
		return
	else: # Basic and Complex clips CANNOT have same names.
		for i in range(basic_clip_subfolder.get_child_count()):
			if i == 0: # the 0 index is for the "add clip"
				continue
			if name_text_input == get_clip_from_tree_item(basic_clip_subfolder.get_child(i)).clip_name:
				print("clip name already exists. Please select another name.")
				return
		for i in range(complex_clip_subfolder.get_child_count()):
			if i == 0: # the 0 index is for the "add clip"
				continue
			if name_text_input == get_clip_from_tree_item(complex_clip_subfolder.get_child(i)).clip_name:
				print("clip name already exists. Please select another name.")
				return
				
	#name_text_input
	var color_bg = dialog.get_node("vbox/hbox_colors/color_picker_bg").get_pick_color()
	var color_text = dialog.get_node("vbox/hbox_colors/color_picker_text").get_pick_color()
	if clip is BasicClip:
		var dim1 = int(dialog.get_node("vbox/hbox_dim1/InputDim1").value)
		var dim2 = int(dialog.get_node("vbox/hbox_dim2/InputDim2").value)
		var dimensions = Vector2(dim1, dim2)
		
		var absolute_path = dialog.get_node("vbox/hbox_path/line_edit_path").text
		
		var image = Image.new()
		var relative_path = absolute_path.replace(project_images_path + "/", "")
		if image.load(absolute_path) == OK: # Image is loaded here
			pass
		else:
			if absolute_path == null:
				Logger.log_message("Path cannot be empty.") #Todo: Consider error message here.
			else:
				Logger.log_message("Could not load image of path " + absolute_path + " of clip " + clip.clip_name) #Todo: Consider error message here.
			return
		
		if clip.clip_name == null: # creating a new clip
			print("debug some stuff here... ", name_text_input, dimensions, relative_path, color_bg, color_text)
			var new_clip = create_basic_clip(name_text_input, dimensions, absolute_path, color_bg, color_text) # The path to the image should already be retrieved by now.
			#contruct_frame_layer_table_clip(clip._sprites, 1, clip)
			#render_frame(selected_frame)
			_select_selected_clip(new_clip)
		else:
			modify_basic_clip(clip, name_text_input, absolute_path, dimensions, color_bg, color_text)
			pass
	
	pass

func _on_dialog_confirmed_create_or_edit_complex_clip(dialog, clip):
	var name_text_input = dialog.get_node("vbox/hbox_name/InputName").text
	# Check if name is empty (should not be), or if a clip with that name already exists. Clips, whether being complex or basic, cannot have the same name.
		
	if name_text_input == clip.clip_name:
		# This happens if e.g. the user wants to change some other attribute, e.g. the colors of the clip, and leaves the name as is.
		pass
	elif name_text_input == "":
		print("clip name cannot be empty")
		return
	else: # Basic and Complex clips CANNOT have same names. # TODO: you can simply loop through the values of the simple or editable dictionary.
		for i in range(basic_clip_subfolder.get_child_count()):
			if i == 0: # the 0 index is for the "add clip"
				continue
			if name_text_input == get_clip_from_tree_item(basic_clip_subfolder.get_child(i)).clip_name:
				print("clip name already exists. Please select another name.")
				return
		for i in range(complex_clip_subfolder.get_child_count()):
			if i == 0: # the 0 index is for the "add clip"
				continue
			if name_text_input == get_clip_from_tree_item(complex_clip_subfolder.get_child(i)).clip_name:
				print("clip name already exists. Please select another name.")
				return
				
	#name_text_input
	var color_bg = dialog.get_node("vbox/hbox_colors/color_picker_bg").get_pick_color()
	var color_text = dialog.get_node("vbox/hbox_colors/color_picker_text").get_pick_color()
	if clip is ComplexClip:
		if clip.clip_name == null: # creating a new clip
			var complex_clip = create_complex_clip(name_text_input, color_bg, color_text) # We need such a function for other purposes as well, such as loading.
			_select_selected_clip(complex_clip)
		else:
			modify_complex_clip(clip, name_text_input, color_bg, color_text)
		pass
	
	pass


func construct_popup_menus_of_clips():

	basic_clip_popup_menu = PopupMenu.new()
	popup_parent.add_child(basic_clip_popup_menu)
	basic_clip_popup_menu.add_item("Edit Basic Clip", 0)
	#basic_clip_popup_menu.add_item("Change image", 1)
	basic_clip_popup_menu.add_item("Delete clip", 1)
	var callable_for_basic_clip_popup = Callable(self, "_on_basic_clip_popup_menu_item_pressed")
	basic_clip_popup_menu.id_pressed.connect(callable_for_basic_clip_popup)

	complex_clip_popup_menu = PopupMenu.new()
	popup_parent.add_child(complex_clip_popup_menu)
	complex_clip_popup_menu.add_item("Edit Complex Clip", 0)
	complex_clip_popup_menu.add_item("Delete clip", 1)
	var callable_for_complex_clip_popup = Callable(self, "_on_complex_clip_popup_menu_item_pressed")
	complex_clip_popup_menu.id_pressed.connect(callable_for_complex_clip_popup)
	
	text_clip_popup_menu = PopupMenu.new()
	popup_parent.add_child(text_clip_popup_menu)
	text_clip_popup_menu.add_item("Edit Text Clip", 0)
	text_clip_popup_menu.add_item("Delete clip", 1)
	var callable_for_text_clip_popup = Callable(self, "_on_text_clip_popup_menu_item_pressed")
	text_clip_popup_menu.id_pressed.connect(callable_for_text_clip_popup)
	
	
	
	basic_clip_popup_menu_shortcut = PopupMenu.new()
	popup_parent.add_child(basic_clip_popup_menu_shortcut)
	basic_clip_popup_menu_shortcut.add_item("Edit Basic Clip", 0)
	#basic_clip_popup_menu.add_item("Change image", 1)
	basic_clip_popup_menu_shortcut.add_item("Delete shortcut", 1)
	var callable_for_basic_clip_popup_shortcut = Callable(self, "_on_basic_clip_popup_menu_item_pressed_shortcut")
	basic_clip_popup_menu_shortcut.id_pressed.connect(callable_for_basic_clip_popup_shortcut)

	complex_clip_popup_menu_shortcut = PopupMenu.new()
	popup_parent.add_child(complex_clip_popup_menu_shortcut)
	complex_clip_popup_menu_shortcut.add_item("Edit Complex Clip", 0)
	complex_clip_popup_menu_shortcut.add_item("Delete shortcut", 1)
	var callable_for_complex_clip_popup_shortcut = Callable(self, "_on_complex_clip_popup_menu_item_pressed")
	complex_clip_popup_menu_shortcut.id_pressed.connect(callable_for_complex_clip_popup_shortcut)
	
	text_clip_popup_menu_shortcut = PopupMenu.new()
	popup_parent.add_child(text_clip_popup_menu_shortcut)
	text_clip_popup_menu_shortcut.add_item("Edit Text Clip", 0)
	text_clip_popup_menu_shortcut.add_item("Delete shortcut", 1)
	var callable_for_text_clip_popup_shortcut = Callable(self, "_on_text_clip_popup_menu_item_pressed")
	text_clip_popup_menu_shortcut.id_pressed.connect(callable_for_text_clip_popup_shortcut)
	
	
	
	
	
	subfolder_popup_menu_editable = PopupMenu.new()
	popup_parent.add_child(subfolder_popup_menu_editable)
	subfolder_popup_menu_editable.add_item("Create Folder", 0)
	subfolder_popup_menu_editable.add_item("Rename", 1)
	subfolder_popup_menu_editable.add_item("Delete", 2)
	subfolder_popup_menu_editable.add_item("Create Basic Clip", 3)
	subfolder_popup_menu_editable.add_item("Create Complex Clip", 4)
	subfolder_popup_menu_editable.add_item("Create Text Clip", 5)
	#subfolder_popup_menu_editable.add_item("Create Folder", 6)
	
	var callable_for_subfolder_popup_editable = Callable(self, "_on_subfolder_popup_menu_item_pressed_editable")
	subfolder_popup_menu_editable.id_pressed.connect(callable_for_subfolder_popup_editable)
	
	
	subfolder_popup_menu_shortcut = PopupMenu.new()
	popup_parent.add_child(subfolder_popup_menu_shortcut)
	subfolder_popup_menu_shortcut.add_item("Create", 0)
	subfolder_popup_menu_shortcut.add_item("Rename", 1)
	subfolder_popup_menu_shortcut.add_item("Delete", 2)
	
	var callable_for_subfolder_popup_shortcut = Callable(self, "_on_subfolder_popup_menu_item_pressed_shortcut")
	subfolder_popup_menu_shortcut.id_pressed.connect(callable_for_subfolder_popup_shortcut)
	
	
	
	
	
	tree_empty_space_popup_menu_editable = PopupMenu.new()
	popup_parent.add_child(tree_empty_space_popup_menu_editable)
	tree_empty_space_popup_menu_editable.add_item("Create Basic Clip", 0)
	tree_empty_space_popup_menu_editable.add_item("Create Complex Clip", 1)
	tree_empty_space_popup_menu_editable.add_item("Create Text Clip", 2)
	tree_empty_space_popup_menu_editable.add_item("Create Folder", 3)
	var callable_for_tree_empty_space_popup_editable = Callable(self, "_on_tree_empty_space_popup_menu_item_pressed_editable")
	tree_empty_space_popup_menu_editable.id_pressed.connect(callable_for_tree_empty_space_popup_editable)
	
	
	
	tree_empty_space_popup_menu_shortcut = PopupMenu.new()
	popup_parent.add_child(tree_empty_space_popup_menu_shortcut)
	tree_empty_space_popup_menu_shortcut.add_item("Create Folder", 0)
	var callable_for_tree_empty_space_popup_shortcut = Callable(self, "_on_tree_empty_space_popup_menu_item_pressed_shortcut")
	tree_empty_space_popup_menu_shortcut.id_pressed.connect(callable_for_tree_empty_space_popup_shortcut)
	
	
	print("popups created")
	
	var callable_for_tree_clicked_editable = Callable(self, "_on_tree_clicked_editable")
	var callable_for_tree_clicked_simple = Callable(self, "_on_tree_clicked_simple")
	var callable_for_tree_clicked_shortcut = Callable(self, "_on_tree_clicked_shortcut")
	
	editable_clip_tree.connect("item_mouse_selected", callable_for_tree_clicked_editable.bind(basic_clip_popup_menu, complex_clip_popup_menu, text_clip_popup_menu, subfolder_popup_menu_editable))
	simple_clip_tree.connect("item_mouse_selected", callable_for_tree_clicked_simple.bind(basic_clip_popup_menu, complex_clip_popup_menu, text_clip_popup_menu, subfolder_popup_menu_simple))
	shortcut_clip_tree.connect("item_mouse_selected", callable_for_tree_clicked_shortcut.bind(basic_clip_popup_menu_shortcut, complex_clip_popup_menu_shortcut, text_clip_popup_menu_shortcut, subfolder_popup_menu_shortcut))
	

	var callable_for_tree_empty_space_clicked_editable = Callable(self, "_on_tree_empty_clicked_editable")
	editable_clip_tree.connect("empty_clicked", callable_for_tree_empty_space_clicked_editable.bind(editable_clip_tree, tree_empty_space_popup_menu_editable))

	var callable_for_tree_empty_space_clicked_shortcut = Callable(self, "_on_tree_empty_clicked_shortcut")
	shortcut_clip_tree.connect("empty_clicked", callable_for_tree_empty_space_clicked_shortcut.bind(shortcut_clip_tree, tree_empty_space_popup_menu_shortcut))


func create_basic_clip(clip_name, dimensions, path, color_bg, color_text):
	var clip = BasicClip.new()

	basic_clip_popup_menu = PopupMenu.new()
	popup_parent.add_child(basic_clip_popup_menu)
	basic_clip_popup_menu.add_item("Edit Basic Clip", 1)
	basic_clip_popup_menu.add_item("Change image", 2)
	basic_clip_popup_menu.add_item("Delete clip", 3)
	var callable_for_basic_clip_popup = Callable(self, "_on_basic_clip_popup_menu_item_pressed")
	basic_clip_popup_menu.id_pressed.connect(callable_for_basic_clip_popup.bind(clip))
	
	#editable_tree_clips_dictionary[recently_created_tree_item] = clip
	#recently_created_tree_item.set_text(1, "Basic Clip")
	var new_tree_item = editable_clip_tree.create_item(parent_of_new_tree_item)
	editable_tree_clips_dictionary[new_tree_item] = clip
	new_tree_item.set_text(1, "Basic Clip")
	
	var tree_item_for_basic_clips_tree = basic_clip_subfolder.get_tree().create_item(basic_clip_subfolder)
	simple_tree_clips_dictionary[tree_item_for_basic_clips_tree] = clip
	tree_item_for_basic_clips_tree.set_text(1, "Basic Clip")
	
	
	#var callable_for_created_tree_item_clip = Callable(self, "_on_tree_item_right_clicked")
	#recently_created_tree_item
	
	print("constructing1..................")
	modify_basic_clip(clip, clip_name, path, dimensions, color_bg, color_text)
	return clip




func get_keys_from_value(dict: Dictionary, value):
	var keys = []
	for key in dict.keys():
		if dict[key] == value:
			keys.append(key)
	return keys

func change_names_and_colors_in_all_dictionaries(clip, clip_name, color_bg, color_text):
	var tree_items = []
	for tree_item in simple_tree_clips_dictionary.keys():
		if simple_tree_clips_dictionary[tree_item] == clip:
			tree_items.append(tree_item)
	for tree_item in editable_tree_clips_dictionary .keys():
		if editable_tree_clips_dictionary[tree_item] == clip:
			tree_items.append(tree_item)
	for tree_item in shortcut_tree_clips_dictionary.keys():
		if shortcut_tree_clips_dictionary[tree_item] == clip:
			tree_items.append(tree_item)
			
	for tree_item in tree_items:
		tree_item.set_custom_color(1, color_text)
		tree_item.set_custom_bg_color(1, color_bg)
		tree_item.set_text(0, clip_name)

func modify_basic_clip(clip, clip_name, path, dimensions, color_bg, color_text):
	print("1")
	clip.clip_name = clip_name
	clip.color_bg = color_bg
	clip.color_text = color_text
	change_names_and_colors_in_all_dictionaries(clip, clip_name, color_bg, color_text)
	
	print("2")
	var absolute_path = path
	#check the image again. The check might not be necessary.
	var image = Image.new()
	print("3")
	if image.load(absolute_path) == OK: # Image is loaded here
		var relative_path = absolute_path.replace(project_images_path + "/", "")
		clip.path = relative_path
		clip.image = image
		print("IMAGE WAS OK ", clip.dimensions)
		clip.set_image_dimensions(clip.dimensions) # Image changed, so we need to do this
		# we do not yet know the dimensions, so we do not yet run the clip's function set_image_dimensions(dim).
		# With further refactoring of the code these steps could be done differently, and possibly more efficiently.
		# Specifically, the file dialog could be called through the clip creation/ or clip editing dialog.
	else:
		print("Could not load image of path " + absolute_path + " of clip " + clip.clip_name)
		Logger.log_message("Could not load image of path " + absolute_path + " of clip " + clip.clip_name) #Todo: Consider error message here.
		return
	
	
	clip.set_image_dimensions(dimensions)
	print("constructing2..................")
	contruct_frame_layer_table_clip(clip._sprites, 1, clip)
	reconstruct_frame_table_attributes() # to recolor the frame table if needed


func create_complex_clip(clip_name, color_bg, color_text, frames = 4, layers = 2):
	var clip = ComplexClip.new()

	#editable_tree_clips_dictionary[recently_created_tree_item] = clip
	#recently_created_tree_item.set_text(1, "Complex Clip")
	var new_tree_item = editable_clip_tree.create_item(parent_of_new_tree_item)
	editable_tree_clips_dictionary[new_tree_item] = clip
	new_tree_item.set_text(1, "Complex Clip")
	
	var tree_item_for_complex_clips_tree = complex_clip_subfolder.get_tree().create_item(complex_clip_subfolder)
	simple_tree_clips_dictionary[tree_item_for_complex_clips_tree] = clip
	tree_item_for_complex_clips_tree.set_text(1, "Complex Clip")

	contruct_frame_layer_table_clip(frames, layers, clip)
	reconstruct_frame_table_attributes() 
	modify_complex_clip(clip, clip_name, color_bg, color_text)
	return clip

func modify_complex_clip(clip, clip_name, color_bg, color_text):
	clip.clip_name = clip_name
	clip.color_bg = color_bg
	clip.color_text = color_text

	change_names_and_colors_in_all_dictionaries(clip, clip_name, color_bg, color_text)
	

func dialog_for_choosing_image_path_of_basic_clip_old(clip):
	# Remove the old FileDialog if it exists. This deletes the existing connections.
	if file_dialog != null:
		file_dialog.queue_free()
	if project_images_path == "": # The user needs to first choose the path of the folder where images should be located.
		if dialog != null:
			dialog.queue_free()
		dialog = AcceptDialog.new()
		dialog.dialog_text = "Please first set the path where images should be saved (Project->Configure images path). The relevant images should be saved in there."
		Logger.log_message("Project path needs to be set first.")
		add_child(dialog)
		dialog.popup_centered()
		return
	
	file_dialog = FileDialog.new()
	add_child(file_dialog)
	file_dialog.access = FileDialog.ACCESS_FILESYSTEM
	file_dialog.file_mode = FileDialog.FILE_MODE_OPEN_FILE
	file_dialog.filters = ["*.png ; PNG Images"]
	file_dialog.current_path = project_images_path + "/"  # Set initial directory
	var callable = Callable(self, "_on_dialog_confirmed_choosing_image_path_of_basic_clip").bind(clip)
	file_dialog.connect("file_selected", callable)
	file_dialog.popup_centered(Vector2(800, 600))

func _on_dialog_confirmed_choosing_image_path_of_basic_clip_old(path, clip):
	pass
	#assign_image_to_basic_clip(path, clip)


func assign_image_to_basic_clip_old(absolute_path, clip):
	print("path: ", absolute_path)
	var image = Image.new()
	if (absolute_path.find(project_images_path) == -1): # The file is not inside the project's images folder
		print("not in path")
		if dialog != null:
			dialog.queue_free()
		dialog = AcceptDialog.new()
		dialog.dialog_text = "You can only select images inside the selected project folder, or its subfolders."
		add_child(dialog)
		dialog.popup_centered()
		return
	if image.load(absolute_path) == OK: # Image is loaded here
		var relative_path = absolute_path.replace(project_images_path + "/", "")
		clip.path = relative_path
		clip.image = image
		print("IMAGE WAS OK ", clip.dimensions)
		clip.set_image_dimensions(clip.dimensions) # Image changed, so we need to do this
		# we do not yet know the dimensions, so we do not yet run the clip's function set_image_dimensions(dim).
		# With further refactoring of the code these steps could be done differently, and possibly more efficiently.
		# Specifically, the file dialog could be called through the clip creation/ or clip editing dialog.
	else:
		Logger.log_message("Could not load image of path " + absolute_path + " of clip " + clip.clip_name) #Todo: Consider error message here.
		return
	if clip.clip_name == null: # is a new clip
		dialog_for_creating_or_editing_basic_clip(clip)
	else: 
		contruct_frame_layer_table_clip(clip._sprites, 1, clip)
		render_frame(selected_frame)
		pass 
		


func dialog_for_creating_or_editing_basic_clip(clip):
	# Relevant node paths:
	# get_node("vbox/hbox_dim1/InputDim1")
	# get_node("vbox/hbox_dim2/InputDim2")
	# get_node("vbox/hbox_name/InputName")
	# get_node("vbox/hbox_colors/color_picker_bg")
	# get_node("vbox/hbox_colors/color_picker_text")
	
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
	if clip.clip_name != null:
		line_edit_name.text = clip.clip_name
	line_edit_name.set_name("InputName")
	hbox_name.add_child(label_name)
	hbox_name.add_child(line_edit_name)
	vbox.add_child(hbox_name)
	
	
	var hbox_path = HBoxContainer.new()
	hbox_path.set_name("hbox_path")
	vbox.add_child(hbox_path)
	
	var path_label = Label.new()
	path_label.text = "Image path: "
	hbox_path.add_child(path_label)

	var line_edit_path = LineEdit.new()
	if clip.path != null && clip.path != "":
		line_edit_path.text = project_images_path + "/" + clip.path
	line_edit_path.set_name("line_edit_path")
	hbox_path.add_child(line_edit_path)
	line_edit_path.size_flags_horizontal = Control.SIZE_EXPAND_FILL

	var button_path = Button.new()
	button_path.text = "Select"
	hbox_path.add_child(button_path)
	var callable1 = Callable(self, "_on_select_image_path_pressed_for_basic_clip").bind(line_edit_path)
	button_path.connect("button_down", callable1)
	
	
	
	var hbox_dim1 = HBoxContainer.new()
	hbox_dim1.set_name("hbox_dim1")
	var label_dim1 = Label.new()
	label_dim1.text = "Width: "
	var line_edit_dim1 = SpinBox.new()
	line_edit_dim1.min_value = 1
	line_edit_dim1.max_value = 1000
	
	if clip.clip_name != null:
		line_edit_dim1.value = int(clip.dimensions.x)
	line_edit_dim1.set_name("InputDim1") # If dimension is not valid integer, it will be 0 (because of the int(x) function). A dimension of 0 (and generally dimensions smaller than the image), means the image is a single image, and not a spritesheet.
	hbox_dim1.add_child(label_dim1)
	hbox_dim1.add_child(line_edit_dim1)
	vbox.add_child(hbox_dim1)
	var hbox_dim2 = HBoxContainer.new()
	hbox_dim2.set_name("hbox_dim2")
	var label_dim2 = Label.new()
	label_dim2.text = "Height: "
	var line_edit_dim2 = SpinBox.new()
	line_edit_dim2.min_value = 1
	line_edit_dim2.max_value = 1000
	
	if clip.clip_name != null:
		line_edit_dim2.value = int(clip.dimensions.y)
	line_edit_dim2.set_name("InputDim2") # see InputDim1
	hbox_dim2.add_child(label_dim2)
	hbox_dim2.add_child(line_edit_dim2)
	vbox.add_child(hbox_dim2)
	
	var hbox_colors = HBoxContainer.new()
	hbox_colors.set_name("hbox_colors")
	var label_colors = Label.new()
	label_colors.text = "Colors: "
	
	var color_picker_button_color_bg = ColorPickerButton.new()
	if clip.clip_name != null:
		color_picker_button_color_bg.set_pick_color(clip.color_bg)
	else:
		color_picker_button_color_bg.set_pick_color(Color(1, 1, 1, 1))
	color_picker_button_color_bg.set_name("color_picker_bg")
	color_picker_button_color_bg.custom_minimum_size = button_size
	hbox_colors.add_child(label_colors)
	hbox_colors.add_child(color_picker_button_color_bg)
	
	var color_picker_button_color_text = ColorPickerButton.new()
	if clip.clip_name != null:
		color_picker_button_color_text.set_pick_color(clip.color_text)
	else:
		color_picker_button_color_text.set_pick_color(Color(0, 0, 0, 1))
	color_picker_button_color_text.set_name("color_picker_text")
	color_picker_button_color_text.custom_minimum_size = button_size
	hbox_colors.add_child(color_picker_button_color_text)
	vbox.add_child(hbox_colors)
	add_child(dialog)
	
	var callable = Callable(self, "_on_dialog_confirmed_create_or_edit_basic_clip").bind(dialog, clip)
	if file_dialog != null:
		file_dialog.queue_free()
	dialog.connect("confirmed", callable)
	dialog.popup_centered()

func get_clip_from_tree_item(tree_item):
	var clip
	if !simple_tree_clips_dictionary.has(tree_item)&&!editable_tree_clips_dictionary.has(tree_item)&&!shortcut_tree_clips_dictionary.has(tree_item):
		clip = Clip.new()
		return clip
	if tree_item.get_tree() == simple_clip_tree:
		clip = simple_tree_clips_dictionary[tree_item]
	if tree_item.get_tree() == editable_clip_tree:
		clip = editable_tree_clips_dictionary[tree_item]
	if tree_item.get_tree() == shortcut_clip_tree:
		clip = shortcut_tree_clips_dictionary[tree_item]
	return clip
func _on_basic_clip_popup_menu_item_pressed(id):
	#print(last_selected_tree_item.get_text(0))
	var clip = get_clip_from_tree_item(last_selected_tree_item)
	if id == 0: #rename
		dialog_for_creating_or_editing_basic_clip(clip)
	if id == 1:
		delete_clip(clip)

func _on_text_clip_popup_menu_item_pressed(id):
	var clip = simple_tree_clips_dictionary[last_selected_tree_item]
	if id == 0: #rename
		dialog_for_creating_or_editing_text_clip(clip)
	if id == 1:
		delete_clip(clip)

func _on_complex_clip_popup_menu_item_pressed(id):
	var clip = editable_tree_clips_dictionary[last_selected_tree_item]
	if id == 0: #rename
		dialog_for_creating_or_editing_complex_clip(clip)
	if id == 1:
		delete_clip(clip)
		
		
func _on_basic_clip_popup_menu_item_pressed_shortcut(id):
	#print(last_selected_tree_item.get_text(0))
	var clip = get_clip_from_tree_item(last_selected_tree_item)
	if id == 0: #rename
		dialog_for_creating_or_editing_basic_clip(clip)
	if id == 1:
		var tree_node_to_delete = last_selected_tree_item
		tree_node_to_delete.get_parent().remove_child(tree_node_to_delete)
		Logger.log_message("Shortcut removed.")


func _on_text_clip_popup_menu_item_pressed_shortcut(id):
	var clip = simple_tree_clips_dictionary[last_selected_tree_item]
	if id == 0: #rename
		dialog_for_creating_or_editing_text_clip(clip)
	if id == 1:
		var tree_node_to_delete = last_selected_tree_item
		tree_node_to_delete.get_parent().remove_child(tree_node_to_delete)
		Logger.log_message("Shortcut removed.")

func _on_complex_clip_popup_menu_item_pressed_shortcut(id):
	var clip = simple_tree_clips_dictionary[last_selected_tree_item]
	if id == 0: #rename
		dialog_for_creating_or_editing_complex_clip(clip)
	if id == 1:
		var tree_node_to_delete = last_selected_tree_item
		tree_node_to_delete.get_parent().remove_child(tree_node_to_delete)
		Logger.log_message("Shortcut removed.")


func _on_subfolder_popup_menu_item_pressed_editable(id):
	#var clip = simple_tree_clips_dictionary[last_selected_tree_item]
	if id == 0: #create
		#dialog_for_creating_or_editing_complex_clip(clip)
		create_or_rename_folder_in_editable_or_shortcut_tree(editable_clip_tree.get_selected())
		Logger.log_message("create folder")
	if id == 1: #rename
		#dialog_for_creating_or_editing_complex_clip(clip)
		create_or_rename_folder_in_editable_or_shortcut_tree(editable_clip_tree.get_selected(), true)
		Logger.log_message("rename folder")
	if id == 2:
		
		var tree_node_to_delete = last_selected_tree_item
		if tree_node_to_delete.get_child_count() == 0:
			tree_node_to_delete.get_parent().remove_child(tree_node_to_delete)
		else:
			Logger.log_message("Cannot delete folder that contains items.")
	if id == 3:
		Logger.log_message("create basic")
		parent_of_new_tree_item = last_selected_tree_item
		var clip = BasicClip.new()
		dialog_for_creating_or_editing_basic_clip(clip)
	if id == 4:
		parent_of_new_tree_item = last_selected_tree_item
		var clip = ComplexClip.new()
		dialog_for_creating_or_editing_complex_clip(clip)
		Logger.log_message("create complex")
	if id == 5:
		parent_of_new_tree_item = last_selected_tree_item
		var clip = TextClip.new()
		dialog_for_creating_or_editing_text_clip(clip)
		Logger.log_message("create text")
		


func _on_subfolder_popup_menu_item_pressed_shortcut(id):
	if id == 0: #create
		#dialog_for_creating_or_editing_complex_clip(clip)
		create_or_rename_folder_in_editable_or_shortcut_tree(shortcut_clip_tree.get_selected())
		Logger.log_message("create folder")
	if id == 1: #rename
		create_or_rename_folder_in_editable_or_shortcut_tree(shortcut_clip_tree.get_selected(), true)
		Logger.log_message("rename folder")
	if id == 2:
		var tree_node_to_delete = last_selected_tree_item
		if tree_node_to_delete.get_child_count() == 0:
			tree_node_to_delete.get_parent().remove_child(tree_node_to_delete)
		else:
			Logger.log_message("Cannot delete folder that contains items.")


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
		

# ================= SAVE FILE ========================
func save_project_as():
	# Remove the old FileDialog if it exists. This deletes the existing connections.
	if file_dialog != null:
		file_dialog.queue_free()
	file_dialog = FileDialog.new()
	add_child(file_dialog)
	file_dialog.access = FileDialog.ACCESS_FILESYSTEM
	file_dialog.file_mode = FileDialog.FILE_MODE_SAVE_FILE 
	file_dialog.filters = ["*.pixv ; Save file"]
	var callable = Callable(self, "_on_file_selected_for_save_project_as")
	file_dialog.connect("file_selected", callable)
	file_dialog.popup_centered(Vector2(800, 600))
	
func _on_file_selected_for_save_project_as(path):
	var file = FileAccess.open(path, FileAccess.WRITE)
	var err = file.get_error()
	# Check for errors
	if err == OK:
		pass
	else:
		print("Save failed.")
		return
	# Write to the file
	save_write_to_file(file)


func save_tree_paths(tree):
	var save_data = []
	_save_paths_recursive(tree.get_root(), [], save_data)
	return save_data



func _save_paths_recursive(item, current_path, save_data):
	if item != null:
		# Create a new dictionary to store this item's data
		
		# Append this item's text to the path before we recurse
		current_path.append(item.get_text(0))
		
		var item_data = {
			"path": current_path.duplicate(),
			"type": "folder" if get_clip_from_tree_item(item).clip_name == null else "file"
		}
		save_data.append(item_data)



		# Recurse into this item's children
		for i in range(item.get_child_count()):
			_save_paths_recursive(item.get_child(i), current_path, save_data)

		# Remove this item's text from the path after we're done with it
		current_path.pop_back()




func get_tree_item_path(item):
	var path = []
	while item:
		var node_info = {}
		node_info["name"] = item.get_text(0)  # Or whichever column has the name
		node_info["type"] = "folder" if item.get_children() else "file"
		path.insert(0, node_info)
		item = item.get_parent()
	return path
	
func save_write_to_file(file):
	#saving as JSON. 
	var data = {}  # Initialize an empty dictionary
	# Add basic_clips array to the dictionary
	data["editable_tree"] = save_tree_paths(editable_clip_tree)#get_tree_item_path(editable_clip_tree.get_root())
	data["shortcut_tree"] = save_tree_paths(shortcut_clip_tree)#get_tree_item_path(shortcut_clip_tree.get_root())
	data["basic_clips"] = []  # Initialize an empty array
	for i in range(0, basic_clip_subfolder.get_child_count()): # starts with 1 BECAUSE 1st BUTTON IS THE ADD CLIP BUTTON
		var tree_item = basic_clip_subfolder.get_child(i)
		var clip = get_clip_from_tree_item(tree_item)
		if clip.color_bg == null: # For older save files, where color of clips was not implemented.
			
			data["basic_clips"].append({
				"clip_name": clip.clip_name,
				"dimensions": {"x": clip.dimensions.x, "y": clip.dimensions.y},
				"path": clip.path,
				"color_bg": "#FFFFFF",
				"color_text": "#000000"
		})
		else:
			print(str(clip.color_bg) + " eeee " + str(clip.color_text))
			data["basic_clips"].append({
				"clip_name": clip.clip_name,
				"dimensions": {"x": clip.dimensions.x, "y": clip.dimensions.y},
				"path": clip.path,
				"color_bg": clip.color_bg.to_html(true),
				"color_text": clip.color_text.to_html(true)
			})
	
	data["text_clips"] = []  # Initialize an empty array
	for i in range(0, text_clip_subfolder.get_child_count()): # starts with 1 BECAUSE 1st BUTTON IS THE ADD CLIP BUTTON
		var tree_item = text_clip_subfolder.get_child(i)
		var clip = get_clip_from_tree_item(tree_item)
		if clip.color_bg == null: # For older save files, where color of clips was not implemented.
			data["text_clips"].append({
				"clip_name": clip.clip_name,
				"image_path": clip.image_path,
				"font_data_path": clip.font_data_path,
				"texts": clip.texts,
				"textbox_size": clip.textbox_size,
				"color_bg": "#FFFFFF",
				"color_text": "#000000"
		})
		else:
			data["text_clips"].append({
				"clip_name": clip.clip_name,
				"image_path": clip.image_path,
				"font_data_path": clip.font_data_path,
				"texts": clip.texts,
				"textbox_size": clip.textbox_size,
				"color_bg": clip.color_bg.to_html(true),
				"color_text": clip.color_text.to_html(true)
			})
	
	
		# Add complex_clips array to the dictionary
	data["complex_clips"] = []  # Initialize an empty array
	for k in range(0, complex_clip_subfolder.get_child_count()): # starts with 1 BECAUSE 1st BUTTON IS THE ADD CLIP BUTTON
		var tree_item = complex_clip_subfolder.get_child(k)
		var clip = get_clip_from_tree_item(tree_item)
		var complex_clip = clip
		var clip_frames = complex_clip.frame_layer_table_hbox.get_child_count() -1 #-1 because of labels of the frame table, which add an additional frame and layer.
		var clip_layers = complex_clip.frame_layer_table_hbox.get_child(0).get_child_count() -1
		var frame_layer_data = []  # This will be an array of arrays

		for i in range(1, clip.frame_layer_table_hbox.get_child_count()): #skipping the 1st element, which is labels
			var frame_layer_row = clip.frame_layer_table_hbox.get_child(i)
			var frame_layer_row_data = []  # This will be an array of dictionaries
			for j in range(1, frame_layer_row.get_child_count()): #skipping 1st elements, which is labels.
				var frame_layer_button = frame_layer_row.get_child(j)
				if frame_layer_button.frameLayer.get_clip() == null:
					pass
				else:
					# check if clip exists. In some cases, the frameLayer may reference a clip that has already been deleted, and we don't want that.
					var clip_exists = false
					for l in range (0, basic_clip_subfolder.get_child_count()):
						var tree_item2 = basic_clip_subfolder.get_child(l)
						var clip2 = get_clip_from_tree_item(tree_item)
						if frame_layer_button.frameLayer.get_clip() == clip2:
							clip_exists = true
							break
					for l in range (0, complex_clip_subfolder.get_child_count()):
						var tree_item2 = complex_clip_subfolder.get_child(l)
						var clip2 = get_clip_from_tree_item(tree_item)
						if frame_layer_button.frameLayer.get_clip() == clip2:
							clip_exists = true
							break
					for l in range (0, text_clip_subfolder.get_child_count()):
						var tree_item2 = text_clip_subfolder.get_child(l)
						var clip2 = get_clip_from_tree_item(tree_item)
						if frame_layer_button.frameLayer.get_clip() == clip2:
							clip_exists = true
							break
					if clip_exists:
						frame_layer_row_data.append({
							"frame": frame_layer_button.frameLayer.frame_number,#i, #STARTS FROM 1
							"layer": frame_layer_button.frameLayer.layer_number,#j, #STARTS FROM 1
							"clip_used" : frame_layer_button.frameLayer.get_clip().clip_name,
							"frame_of_clip": frame_layer_button.frameLayer.frame_of_clip,
							"offset_framelayer": {
								"x": frame_layer_button.frameLayer.offset_framelayer.x,
								"y": frame_layer_button.frameLayer.offset_framelayer.y,
							}
						})
			frame_layer_data.append(frame_layer_row_data)
		if clip.color_bg == null:
			data["complex_clips"].append({
				"frames": clip_frames,
				"layers": clip_layers,
				"clip_name": clip.clip_name,
				"frame_layer_table": frame_layer_data,
				"color_bg": "#FFFFFF",
				"color_text": "#000000"
			})
		else:
			data["complex_clips"].append({
				"frames": clip_frames,
				"layers": clip_layers,
				"clip_name": clip.clip_name,
				"frame_layer_table": frame_layer_data,
				"color_bg": clip.color_bg.to_html(true),
				"color_text": clip.color_text.to_html(true)
			})
	data["project_images_path"] = project_images_path
	var json_text = JSON.stringify(data)  # Convert dictionary to JSON text
	file.store_string(json_text)  # Write JSON text to file
	file.close()
# ================= END OF SAVE FILE ========================


# ================== LOAD FILE ========================
func load_project():
	if file_dialog != null:
		file_dialog.queue_free() # Remove the old FileDialog if it exists. This deletes the existing connections.
	file_dialog = FileDialog.new()
	add_child(file_dialog)
	file_dialog.access = FileDialog.ACCESS_FILESYSTEM
	file_dialog.file_mode = FileDialog.FILE_MODE_OPEN_FILE 
	file_dialog.filters = ["*.pixv ; Save file"]
	file_dialog.current_path = "D:/Github Projects/Pixel-Video-Editor"
	var callable = Callable(self, "_on_file_selected_for_load_project")
	file_dialog.connect("file_selected", callable)
	file_dialog.popup_centered(Vector2(800, 600))

func _on_file_selected_for_load_project(path):
	var file = FileAccess.open(path, FileAccess.READ)
	var err = file.get_error()
	# Check for errors
	if err == OK:
		var content = file.get_as_text()
		print("loading project...")
	else:
		print("Load failed.")
		return
	load_open_file(file)


"""
func load_tree_from_paths_editable(root, paths_data):
	var path_to_tree_item = { [] : root }

	for item_data in paths_data:
		var path = item_data["path"]
		var parent_path = path.duplicate()
		parent_path.remove(parent_path.size() - 1)       
		var parent_tree_item = path_to_tree_item[parent_path]
		var new_tree_item
		if item_data["type"] == "file":
			for i in range(editable_clip_tree.get_root().get_child_count()):
				var child_item = parent_tree_item.get_child(i)
				if child_item.get_text(0) == path[path.size() - 1]:
					editable_clip_tree.get_root().child_item.remove_child(child_item)
					parent_tree_item.add_child(child_item)
					new_tree_item = child_item
		else:
			new_tree_item = editable_clip_tree.create_item(parent_tree_item)
			new_tree_item.set_text(0, path[path.size() - 1])
		
		path_to_tree_item[path] = new_tree_item
		if item_data["type"] == "file":
			pass
		# do something special for files here, e.g. load_clip_into_tree_item()
"""



func load_tree_paths(paths_data, root, tree, tree_type): #tree type is either "editable" or "shortcut". Make enum?
	if tree_type != "editable" && tree_type != "shortcut":
		print("code error: tree_type needs to be either editable or shortcut")
	var path_to_item_map = {}  # Mapping of paths to corresponding tree items

	for data in paths_data:
		var path = data["path"]
		var item_type = data["type"]

		var parent_path = path.duplicate()
		parent_path.pop_back()

		var parent_item
		if parent_path.size() > 0:
			parent_item = path_to_item_map[parent_path]
		else:
			parent_item = root

		var tree_item
		if tree_type == "editable" and item_type == "file":
			#tree_item = find_file_item_in_tree(root, path[-1])
			tree_item = find_file_item_in_dictionary(path[-1])
			if tree_item:
				# Remove the old TreeItem from its parent
				tree_item.get_parent().remove_child(tree_item)
				
				# Add the TreeItem under the new parent
				parent_item.add_child(tree_item)
		else:
			if path[-1] == "": #prevent creating an extra "root"
				tree_item = root
			else:
				tree_item = tree.create_item(parent_item)
		#print("yesss" + str(move_files))
		tree_item.set_text(0, path[-1])
		if tree_type == "shortcut" and item_type == "file":
			#Find the clip type in editable 
			var editable_tree_item = find_file_item_in_dictionary(path[-1])
			tree_item.set_text(1, editable_tree_item.get_text(1))
			# check if
		#if get_clip_from_tree_item(tree_item).clip_name != null: #meaning the clip exists:
			
		#	var editable_tree_item = find_file_item_in_dictionary(path[-1])
		#	print("yesss" + str(move_files) + editable_tree_item.get_text(1))
		#	tree_item.set_text(1, "FEDGDGHHFDGFHG")#editable_tree_item.get_text(1)) # This is useful for creating the text of the 2nd column for Shortcut clip list. It does nothing for the editable clip list. Maybe there is an easier way to do this?

		path_to_item_map[path] = tree_item

func find_file_item_in_dictionary(filename):
	for tree_item in editable_tree_clips_dictionary.keys():
		if tree_item.get_text(0) == filename:
			return tree_item
	return null



func find_file_item_in_tree_old(root, filename):
	if root.get_text(0) == filename:
		return root
	for i in range(root.get_child_count()):
		var result = find_file_item_in_tree_old(root.get_child(i), filename)
		if result:
			return result
	return null

"""func load_tree_paths(tree, paths_data):
	var path_to_item_map = {}
	
	for item_data in paths_data:
		var path = item_data["path"]
		var type = item_data["type"]
		
		var parent_path = path.duplicate()
		parent_path.pop_back()
		var parent_item = null
		
		if parent_path.size() > 0:
			parent_item = path_to_item_map[parent_path]
		var new_item = tree.create_item(parent_item)
		new_item.set_text(0, path[path.size()-1])
		new_item.set_metadata(0, type)
		
		path_to_item_map[path] = new_item
"""

func addign_dictionaries_to_trees():
	editable_clip_tree.simple_dict = simple_tree_clips_dictionary
	editable_clip_tree.editable_dict = editable_tree_clips_dictionary
	editable_clip_tree.shortcut_dict = shortcut_tree_clips_dictionary

	simple_clip_tree.simple_dict = simple_tree_clips_dictionary
	simple_clip_tree.editable_dict = editable_tree_clips_dictionary
	simple_clip_tree.shortcut_dict = shortcut_tree_clips_dictionary

	shortcut_clip_tree.simple_dict = simple_tree_clips_dictionary
	shortcut_clip_tree.editable_dict = editable_tree_clips_dictionary
	shortcut_clip_tree.shortcut_dict = shortcut_tree_clips_dictionary

func load_open_file(file):
	last_selected_tree_item = editable_clip_tree.get_root()
	# Read the entire file content into a string
	var json_text = file.get_as_text()
	# Parse the JSON text to reconstruct the dictionary
	var json_object = JSON.new()
	var parse_err = json_object.parse(json_text) # possibly use the err to check for mistakes. Not implemented right now.
	var data = json_object.get_data()
	var error_message = ""
	print(json_text) #debugging
	var selected_clip #the last clip loaded is selected
	#removing current clips
	#for i in range(1, basic_clip_subfolder.get_child_count()):
	while basic_clip_subfolder.get_children():
		basic_clip_subfolder.remove_child(basic_clip_subfolder.get_children()[0])
	while complex_clip_subfolder.get_children():
		complex_clip_subfolder.remove_child(complex_clip_subfolder.get_children()[0])
	while text_clip_subfolder.get_children():
		text_clip_subfolder.remove_child(text_clip_subfolder.get_children()[0])
	simple_tree_clips_dictionary = {}
	editable_tree_clips_dictionary = {}
	shortcut_tree_clips_dictionary = {}
	#editable_clip_tree.clear()
	#simple_clip_tree.clear()
	#shortcut_clip_tree.clear()
	
	addign_dictionaries_to_trees()
	
	# Load the path to the folder where images are stored
	project_images_path = data["project_images_path"]
	# Load basic_clips
	if data.has("basic_clips"):
		for basic_clip_data in data["basic_clips"]:
			var loaded_color_bg
			var loaded_color_text
			if !(basic_clip_data.has("color_bg")): # for old saves that do not store the colors of clips
				loaded_color_bg = Color(1, 1, 1, 1)
				loaded_color_text = Color(0, 0, 0, 1)
			else:
				loaded_color_bg = Color(basic_clip_data["color_bg"])
				loaded_color_text = Color(basic_clip_data["color_text"])
			
			var clip_name = basic_clip_data["clip_name"]
			var dimensions = Vector2(basic_clip_data["dimensions"]["x"], basic_clip_data["dimensions"]["y"])
			var path = basic_clip_data["path"]
			
			selected_clip = create_basic_clip(clip_name, dimensions, project_images_path + "/" + path, loaded_color_bg, loaded_color_text)
			# We use project_images_path + path because we need the absolute path.
			# At the end, the last loaded clip will be selected.
	
	if data.has("text_clips"):
		for text_clip_data in data["text_clips"]:
			var loaded_color_bg
			var loaded_color_text
			if !(text_clip_data.has("color_bg")): # for old saves that do not store the colors of clips
				loaded_color_bg = Color(1, 1, 1, 1)
				loaded_color_text = Color(0, 0, 0, 1)
			else:
				loaded_color_bg = Color(text_clip_data["color_bg"])
				loaded_color_text = Color(text_clip_data["color_text"])
			
			var clip_name = text_clip_data["clip_name"]
			var image_path = text_clip_data["image_path"]
			var font_data_path = text_clip_data["font_data_path"]
			var texts = text_clip_data["texts"]
			var textbox_size = text_clip_data["textbox_size"]
			
			var clip = TextClip.new()
			selected_clip = create_or_modify_text_clip(clip, clip_name, image_path, font_data_path, textbox_size, loaded_color_bg, loaded_color_text, texts)#create_basic_clip(clip_name, dimensions, project_images_path + path, loaded_color_bg, loaded_color_text)
			#print("absolute path: ", project_images_path + path)
			# We use project_images_path + path because we need the absolute path.
			# At the end, the last loaded clip will be selected.
			
	# Load complex_clips
	var frame_layer_button_placeholders = []  # list of FrameLayer objects that have a placeholder for clip_used
	#This is because we first need to load all clips before we reference clips to FrameLayers.
	var clip_placeholders = [] # keeps the parent clips of the above framelayer buttons, so that circular references can be checked.
	if data.has("complex_clips"):
		for complex_clip_data in data["complex_clips"]:
			
			var clip_name = complex_clip_data["clip_name"]
			var loaded_color_bg
			var loaded_color_text
			if !(complex_clip_data.has("color_bg")):
				loaded_color_bg = Color(1, 1, 1, 1)
				loaded_color_text = Color(0, 0, 0, 1)
			else:
				loaded_color_bg = Color(complex_clip_data["color_bg"])
				loaded_color_text = Color(complex_clip_data["color_text"])
			print("clippp nameee " + clip_name)
			var clip = create_complex_clip(clip_name, loaded_color_bg, loaded_color_text, complex_clip_data["frames"], complex_clip_data["layers"])
			selected_clip = clip
			
			# Looping through the frame layers of the complex clip to assign references to clips.
			for frame_layer_row_data in complex_clip_data["frame_layer_table"]:
				for frame_layer_data in frame_layer_row_data:
					var frame_layer = FrameLayer.new(frame_layer_data["frame"], frame_layer_data["layer"])
					frame_layer.clip_used = frame_layer_data["clip_used"]  # temporarily storing it as string. After loading all clips, it will be loaded as a clip. This is because not all clips are loaded yet.
					frame_layer.frame_of_clip = frame_layer_data["frame_of_clip"]
					frame_layer.offset_framelayer = Vector2(frame_layer_data["offset_framelayer"]["x"], frame_layer_data["offset_framelayer"]["y"])
					clip.frame_layer_table_hbox.get_child(frame_layer_data["frame"]).get_child(frame_layer_data["layer"]).frameLayer = frame_layer #append(frame_layer_row)
					frame_layer_button_placeholders.append(clip.frame_layer_table_hbox.get_child(frame_layer_data["frame"]).get_child(frame_layer_data["layer"]))
					clip_placeholders.append(clip)


		#for frame_layer_button in frame_layer_button_placeholders:
		for k in range(frame_layer_button_placeholders.size()):
			var frame_layer_button = frame_layer_button_placeholders[k]
			var parent_clip = clip_placeholders[k]
			
			var frame_layer = frame_layer_button.frameLayer
			var clip_name = frame_layer.clip_used
			for i in range(0, complex_clip_subfolder.get_child_count()): # Remember, the 1st one is the "add clip" button.
				if clip_name == get_clip_from_tree_item(complex_clip_subfolder.get_child(i)).clip_name:
					var clip_to_be_referenced = get_clip_from_tree_item(complex_clip_subfolder.get_child(i))
					# test if found clip already references parent clip, in which case do not proceed because of circular reference.
					if clip_to_be_referenced.arg_clip_is_child_of_self(parent_clip):
						print("Circular references detected while loading file! The relevant references are cleared.")
						error_message = "Circular references detected while loading file! The relevant references are cleared."
						remove_clip_from_framelayer(frame_layer_button)
					else:
						
						frame_layer.clip_used = get_clip_from_tree_item(complex_clip_subfolder.get_child(i))
						#var frameLayer_Button = clip.frame_layer_table_hbox.get_child(frame_layer_data["frame"]).get_child(frame_layer_data["layer"])
						var button_style_frame_layer = StyleBoxFlat.new()
						button_style_frame_layer.bg_color = frame_layer.get_clip().color_bg
						frame_layer_button.add_theme_stylebox_override("normal", button_style_frame_layer)
						frame_layer_button.add_theme_color_override("font_color", frame_layer.get_clip().color_text)
						frame_layer_button.add_theme_color_override("font_focus_color", frame_layer.get_clip().color_text)
						
						frame_layer_button.text = str(frame_layer_button.frameLayer.frame_of_clip)

			for i in range(0, basic_clip_subfolder.get_child_count()): # Remember, the 1st one is the "add clip" button.
				# Checking for circular references is not needed here, since basic clips do not contain references.
				print("this clip name here is " + basic_clip_subfolder.get_child(i).get_text(0))
				var clip = get_clip_from_tree_item(basic_clip_subfolder.get_child(i))
				if clip_name == clip.clip_name:
					frame_layer.clip_used = get_clip_from_tree_item(basic_clip_subfolder.get_child(i))
					var button_style_frame_layer = StyleBoxFlat.new()
					button_style_frame_layer.bg_color = frame_layer.get_clip().color_bg
					frame_layer_button.add_theme_stylebox_override("normal", button_style_frame_layer)
					frame_layer_button.add_theme_color_override("font_color", frame_layer.get_clip().color_text)
					frame_layer_button.add_theme_color_override("font_focus_color", frame_layer.get_clip().color_text)
					frame_layer_button.text = str(frame_layer_button.frameLayer.frame_of_clip)
	if error_message != "":
		print("Error message ", error_message, " should appear here")
	_select_selected_clip(selected_clip)

	#while editable_clip_tree.get_root().get_child_count() > 0:
	#	editable_clip_tree.get_root().remove_child(editable_clip_tree.get_root().get_child(0))

	
	#editable_clip_tree.clear()


	if data.has("editable_tree"):
		load_tree_paths(data["editable_tree"], editable_clip_tree.get_root(), editable_clip_tree, "editable")
	if data.has("shortcut_tree"):
		load_tree_paths(data["shortcut_tree"], shortcut_clip_tree.get_root(), shortcut_clip_tree, "shortcut")
		
# ================== END OF LOAD FILE ========================

#=================== TOOL FUNCTIONS ==========================
func _on_tool_select_mode_pressed(arg1 = null):
	#tool_mode = Tool_modes.SELECT_MODE
	while tool_settings_scroll_container.get_child_count() > 0: # removing the possible existing tool settings
		tool_settings_scroll_container.remove_child(tool_settings_scroll_container.get_child(0))
	pass

func _on_tool_assign_mode_pressed(arg1 = null):
	#tool_mode = Tool_modes.ASSIGN_MODE
	while tool_settings_scroll_container.get_child_count() > 0: # removing the possible existing tool settings
		tool_settings_scroll_container.remove_child(tool_settings_scroll_container.get_child(0))
	tool_settings_scroll_container.add_child(tool_settings_assign_mode)
	pass

func _on_tool_move_mode_pressed(arg1 = null):
	#tool_mode = Tool_modes.MOVE_MODE
	while tool_settings_scroll_container.get_child_count() > 0: # removing the possible existing tool settings
		tool_settings_scroll_container.remove_child(tool_settings_scroll_container.get_child(0))
	pass

func _on_roll_frames_checkbutton_toggled():
	if roll_frames_checkbutton.is_pressed():
		#tool_settings_assign_mode.add_child(infinite_roll_frames)
		#tool_settings_assign_mode.add_child(reverse_order)
		roll_frames_vbox.add_child(infinite_roll_frames)
		roll_frames_vbox.add_child(reverse_order)
	else:
		roll_frames_vbox.remove_child(infinite_roll_frames)
		roll_frames_vbox.remove_child(reverse_order)
		#while tool_settings_assign_mode.get_child_count() > 3: # removing the possible existing tool settings
		#	tool_settings_assign_mode.remove_child(tool_settings_assign_mode.get_child(3))
	pass

func _on_assign_selected_clip_checkbutton_toggled():
	if assign_local_referenced_clip_checkbutton.is_pressed():
		assign_mode_vbox.add_child(keep_offset_of_starting_framelayer_checkbox)
	else:
		assign_mode_vbox.remove_child(keep_offset_of_starting_framelayer_checkbox)
		#while tool_settings_assign_mode.get_child_count() > 5: # removing the possible existing tool settings
		#	tool_settings_assign_mode.remove_child(tool_settings_assign_mode.get_child(3))
	pass

func _on_absolute_offset_checkbox_pressed():
	keep_offset_of_starting_framelayer_checkbox.button_pressed  = false
	keep_offset_of_starting_framelayer_checkbox.button_pressed  = false
func _on_keep_offset_of_starting_framelayer_checkbox_pressed():
	absolute_offset_checkbox.button_pressed  = false
	keep_offset_of_starting_framelayer_checkbox.button_pressed  = false
func _on_keep_offset_of_existing_framelayer_checkbox_pressed():
	absolute_offset_checkbox.button_pressed  = false
	keep_offset_of_starting_framelayer_checkbox.button_pressed  = false

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

func _on_popup_view_menu_item_pressed(id: int):
	if id == 0:
		print("configure grid")
	# Initialize grid setting controls
		if dialog != null:
			dialog.queue_free()
		dialog = AcceptDialog.new()
		var grid_enabled_check = CheckButton.new()
		grid_enabled_check.text = "Enable Grid"
		if canvas.grid.grid_color.a == 0: #grid is disabled/invisible
			grid_enabled_check.button_pressed = false
		else:
			grid_enabled_check.button_pressed = true
		var callable_checkbox = Callable(self, "_on_grid_enabled_toggled")
		grid_enabled_check.connect("button_down", callable_checkbox)

		var grid_width_input = SpinBox.new()
		grid_width_input.min_value = 1
		grid_width_input.max_value = 1000
		grid_width_input.value = canvas.grid.grid_size.x
		var callable_width = Callable(self, "_on_grid_width_changed")
		grid_width_input.connect("value_changed", callable_width)

		var grid_height_input = SpinBox.new()
		grid_height_input.min_value = 1
		grid_height_input.max_value = 1000
		grid_height_input.value = canvas.grid.grid_size.y
		
		var callable_height = Callable(self, "_on_grid_height_changed")
		grid_height_input.connect("value_changed", callable_height)
		
		var grid_offset_x_input = SpinBox.new()
		grid_offset_x_input.min_value = 1
		grid_offset_x_input.max_value = 1000
		grid_offset_x_input.value = canvas.grid.grid_offset.x
		var callable_offset_x = Callable(self, "_on_grid_offset_x_changed")
		grid_offset_x_input.connect("value_changed", callable_offset_x)

		var grid_offset_y_input = SpinBox.new()
		grid_offset_y_input.min_value = 1
		grid_offset_y_input.max_value = 1000
		grid_offset_y_input.value = canvas.grid.grid_offset.y
		var callable_offset_y = Callable(self, "_on_grid_offset_y_changed")
		grid_offset_y_input.connect("value_changed", callable_offset_y)

		# Add them to the dialog
		var grid_width_label = Label.new()
		grid_width_label.set_text("Grid Width")
		var grid_height_label = Label.new()
		grid_height_label.set_text("Grid Height")
		
		var grid_offset_x_label = Label.new()
		grid_offset_x_label.set_text("Offset x")
		var grid_offset_y_label = Label.new()
		grid_offset_y_label.set_text("Offset y")
		
		var vbox = VBoxContainer.new()
		var checkbox_hbox = HBoxContainer.new()
		var dimensions_hbox = HBoxContainer.new()
		var offset_hbox = HBoxContainer.new()
		
		dialog.add_child(vbox)
		vbox.add_child(checkbox_hbox)
		vbox.add_child(dimensions_hbox)
		vbox.add_child(offset_hbox)
		
		checkbox_hbox.add_child(grid_enabled_check)
		dimensions_hbox.add_child(grid_width_label)
		dimensions_hbox.add_child(grid_width_input)
		dimensions_hbox.add_child(grid_height_label)
		dimensions_hbox.add_child(grid_height_input)
		offset_hbox.add_child(grid_offset_x_label)
		offset_hbox.add_child(grid_offset_x_input)
		offset_hbox.add_child(grid_offset_y_label)
		offset_hbox.add_child(grid_offset_y_input)
		
		add_child(dialog)
		dialog.popup_centered()


func _on_file_selected_for_change_image_path(path):
	project_images_path = path
	print("new project path: " , project_images_path)
	
	
func _on_file_selected_for_save_project(path):
	pass


func _select_selected_clip(clip):
	if selected_clip != null:
		frame_table_vbox.remove_child(frame_layer_table_hbox) #selected_clip.frame_layer_table_hbox)
	
	selected_clip = clip
	frame_layer_table_hbox = selected_clip.frame_layer_table_hbox
	frame_table_vbox.add_child(frame_layer_table_hbox)
	selected_frame = 1
	selected_layer = 1
	framelayer_is_selected = false
	stored_framelayer_buttons_for_moving = []
	copied_stored_framelayer_buttons_for_moving = []
	selected_framelayer_button = null
	render_frame(selected_frame)
	reconstruct_frame_table_attributes()
	
func render_frame(frame):
	if selected_clip != null:
		canvas.remove_children()
		#for child in canvas.get_children(): #removing the already rendered stuff.
			#canvas.remove_child(child)
		selected_clip.render_frame(frame, Vector2(0,0), canvas, canvas.get_zoom_level())
	print("frames layers UI selected frame: " , frame)

func render_framelayer(frame, layer):
	if selected_clip != null:
		canvas.remove_children()
		#for child in canvas.get_children(): #removing the already rendered stuff.
		#	canvas.remove_child(child)
		var referenced_frameLayer = selected_clip.frame_layer_table_hbox.get_child(frame).get_child(layer).frameLayer
		var referenced_clip = referenced_frameLayer.get_clip()
		if referenced_clip != null:
			referenced_clip.render_frame(referenced_frameLayer.frame_of_clip, referenced_frameLayer.offset_framelayer, canvas, canvas.get_zoom_level())

func _input(event):
	if event.is_action_pressed("move_key"):
		tool_mode = Tool_modes.MOVE_MODE
		Logger.log_message("move mode active")
	elif event.is_action_released("move_key"):
		Logger.log_message("move mode stopped")
		tool_mode = Tool_modes.SELECT_MODE
		#tool_mode = Tool_modes.ASSIGN_MODE
	if event.is_action_pressed("assign_key"):
		tool_mode = Tool_modes.ASSIGN_MODE
		Logger.log_message("assign mode active")
	elif event.is_action_released("assign_key"):
		Logger.log_message("assign mode stopped")
		tool_mode = Tool_modes.SELECT_MODE
		
	if event.is_action_pressed("copy_keys"):
		if stored_framelayer_buttons_for_moving.size() == 0:
			Logger.log_message("Nothing to copy")
		elif selected_framelayer_button == null:
			Logger.log_message("pasting location not selected") # I think this should never happen
		else:
			Logger.log_message("copying selection...")
			for framelayer_button in stored_framelayer_buttons_for_moving:
				var copied_framelayer_button = framelayer_button.create_deep_copy()
				copied_stored_framelayer_buttons_for_moving.append(copied_framelayer_button)

		#var stored_framelayer_buttons_for_moving
		#var copied_framelayer_buttons_for_moving
		
	if event.is_action_pressed("paste_keys"):
		if copied_stored_framelayer_buttons_for_moving.size() == 0:
			Logger.log_message("Nothing to paste")
		else:
			Logger.log_message("pasting selection...")
			assigning_selection_to_framelayer()


	if Input.is_key_pressed(KEY_DELETE):
		for framelayer_button in stored_framelayer_buttons_for_moving:
			remove_clip_from_framelayer(framelayer_button)
		render_frame(selected_frame)
	if event is InputEventMouseButton:
		if event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
			var mouse_pos = event.position
			var local_pos = mouse_pos - canvas.get_global_position()
			#if Rect2(Vector2(), canvas.custom_minimum_size).has_point(local_pos):#canvas.to_local(mouse_pos)):
			if Rect2(Vector2(), scroll_container_canvas.size).has_point(local_pos):
				if selected_clip == null:
					return
				print("frames layers ui Left mouse button pressed inside the canvas")
				mouse_clicked_in_canvas = true
				var current_mouse_pos = get_global_mouse_position()
				var current_local_pos = current_mouse_pos - canvas.get_global_position()
				canvas_initial_clicked_corrected_pos = Vector2(round(current_local_pos.x/canvas.get_zoom_level()), round(current_local_pos.y/canvas.get_zoom_level()))
				var referenced_frameLayer = selected_clip.frame_layer_table_hbox.get_child(selected_frame).get_child(selected_layer).frameLayer
				initial_framelayer_offset = referenced_frameLayer.offset_framelayer
		elif !event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
			if mouse_clicked_in_canvas:
				mouse_clicked_in_canvas = false
				var referenced_frameLayer = selected_clip.frame_layer_table_hbox.get_child(selected_frame).get_child(selected_layer).frameLayer
				Logger.log_canvas_movement_message("Moved to: " + str(referenced_frameLayer.offset_framelayer))
			if is_moving_frames:
				is_moving_frames = false
			if is_moving_layers:
				is_moving_layers = false
			if selecting_framelayers:
				selecting_framelayers = false
			if dragging_assigning:
				dragging_assigning = false

			print("frames layers ui Left mouse button released")
		if event.pressed and event.button_index == MOUSE_BUTTON_RIGHT:
			pass
		elif !event.pressed and event.button_index == MOUSE_BUTTON_MASK_RIGHT:
			pass
		if event.is_pressed() and Input.is_key_pressed(KEY_CTRL):
			if !mouse_clicked_in_canvas:
				if event.button_index == MOUSE_BUTTON_WHEEL_UP:
					canvas.set_zoom_level(canvas.get_zoom_level() + 1)
					if canvas.get_zoom_level() >10:
						canvas.set_zoom_level(10)
					else:
						canvas.custom_minimum_size = Vector2(starting_canvas_size.x * canvas.get_zoom_level(), starting_canvas_size.y * canvas.get_zoom_level())
						canvas.grid.custom_minimum_size = Vector2(starting_canvas_size.x * canvas.get_zoom_level(), starting_canvas_size.y * canvas.get_zoom_level())
						render_frame(selected_frame)
						canvas.grid._draw()
					print("frame layer ui zoom level: ", canvas.get_zoom_level())
					get_viewport().set_input_as_handled()  # stop the event from propagating further
				elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
					canvas.set_zoom_level(canvas.get_zoom_level() - 1)
					#render_frame(selected_frame)
					if canvas.get_zoom_level() <1:
						canvas.set_zoom_level(1)
					else:
						canvas.custom_minimum_size = Vector2(starting_canvas_size.x * canvas.get_zoom_level(), starting_canvas_size.y * canvas.get_zoom_level())
						canvas.grid.custom_minimum_size = Vector2(starting_canvas_size.x * canvas.get_zoom_level(), starting_canvas_size.y * canvas.get_zoom_level())
						render_frame(selected_frame)
						canvas.grid._draw()
					get_viewport().set_input_as_handled()  # stop the event from propagating further
					print("frame layer ui zoom level: ", canvas.get_zoom_level())
			else:
				Logger.log_message("Left mouse button is pressed- zoom is not possible.")
			

# ==================== OTHER FUNCTIONS
func _on_grid_enabled_toggled():
	print("toggled")
	canvas.toggle_grid()
	
func _on_grid_width_changed(width):
	canvas.set_grid_size(Vector2(width, canvas.grid.grid_size.y))


func _on_grid_height_changed(height):
	canvas.set_grid_size(Vector2(canvas.grid.grid_size.x, height))


func _on_grid_offset_x_changed(offset_x):
	canvas.set_grid_offset(Vector2(offset_x, canvas.grid.grid_offset.y))
	
func _on_grid_offset_y_changed(offset_y):
	canvas.set_grid_offset(Vector2(canvas.grid.grid_offset.y, offset_y))
	


# ======== UNUSED- REDUNDANT
func _placeholder_function(arg1 = null):
	print("frames_layers_UI.gd placeholder clicked!")


