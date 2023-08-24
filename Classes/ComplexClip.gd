class_name ComplexClip extends Clip  # Replace with the actual path to Clip.gd

#var frame_layer_cells: Array # This would be a 2D array, with one entry for each layer in each frame
 # UI element containing the frames and layers, including the frame label buttons (1, 2, 3 etc) layer label buttons (1, 2, 3 etc) as well as the framelayer cell buttons which in turn have reference to the clip.
	

#var render_offset_clip: Vector2 # A ComplexClip can have some offset, so that all its frames are "moved" a certain amount. NOTE: The framelayers also have offsets, in cases the user wants to offset selected framelayers only.
# DELETE THIS- NOT USED

# consider making a class for frame_layer_table_hbox. It is an array of hboxes (frames), each of them containing vboxes (layers), and each contain NumberedFrameLayerButtons (except the 1st frame and layer, which contain labels)


var button_size # gets the value from main script. For convenience.
func render_frame(frame: int, position : Vector2, canvas, zoom) -> void:
	var clips_number_of_frames = frame_layer_table_hbox.get_child_count() - 1 # -1 because of the labels
	var actual_frame = ((frame - 1) % clips_number_of_frames) + 1 # because they start from 1
	# If frames are higher than the clip's frames, we get the remainder of that division.
	# So e.g. trying to access frame 11 of a clip with 10 frames will get us the 1st frame.
	print("sdfsd" , frame_layer_table_hbox.get_child_count())
	#for i in range(1, frame_layer_table_hbox.get_child(frame).get_child_count()):#[frame].size): # REMEMBER: frame_layer_table_hbox has an extra "frame" columns, and "layer" row, because of the labels. The "frame" variable of the loop, actually starts from 1 because of this (instead of 0)
	for i in range(frame_layer_table_hbox.get_child(actual_frame).get_child_count() - 1, 0, -1): # REMEMBER: frame_layer_table_hbox has an extra "frame" columns, and "layer" row, because of the labels. The "frame" variable of the loop, actually starts from 1 because of this (instead of 0)
	# Also remember: frame_layer_table_hbox[frame] size contains one extra row (as we mentioned). Therefore, starting with 1 and ending with frame_layer_table_hbox[frame].size (the final loop is frame_layer_table_hbox[frame].size -1) is correct.
		#frame_layer_table_hbox[frame][i] is the framelayer cell (button)
		# The framelayer button (of class NumberedFrameLayerButton), contans the clip used, and the frame, and the offset.
		var child_clip = frame_layer_table_hbox.get_child(actual_frame).get_child(i).frameLayer.get_clip() # also consider what will happen if the framelayer is empty
		if child_clip == null:
			continue #nothing should be rendered for that framelayer
		var new_frame_to_render = frame_layer_table_hbox.get_child(actual_frame).get_child(i).frameLayer.frame_of_clip
		var offset_framelayer = frame_layer_table_hbox.get_child(actual_frame).get_child(i).frameLayer.offset_framelayer
		
		child_clip.render_frame(new_frame_to_render, offset_framelayer + position, canvas, zoom) #position keeps the offset. On the 1st call, it is usually initiated as 0,0.
		
	pass
	
func add_layer():
	pass

func add_frame():
	pass


func contruct_frame_layer_table(num_frames, num_layers):
		# Creating layer labels
	var commonFunctions = CommonFunctions.new() # construct_button needs to be used for various stuff, so we avoid writing the same code multiple times.
	for i in range(num_layers):
		var layer_label = commonFunctions.construct_button(NumberedLabelButton.new(i+1), str(i+1), button_size, "_on_layer_label_button_pressed") #STARTS FROM 1
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
			var button = commonFunctions.construct_button(NumberedFrameLayerButton.new(j+1, i+1), str(j+1) + " " + str(i+1), button_size, "_on_frame_layer_button_pressed") #STARTS FROM 1
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
			
#func _init(frames: int, cells: Array) -> void:
#	self.frames = frames
#	self.frame_layer_cells = cells

# Overrides the render_frame method from the parent class
#func render_frame(frame: int) -> void:
#	# Here you would render each layer for the given frame
#	for layer in self.frame_layer_cells[frame]:
#		layer.render_frame(frame)  # This would require the FrameLayerCell class to have a render_frame method

func construct_button(button, button_text, custom_minimum_size, on_pressed_func_call): # WARNING: THE SAME FUNCTION EXISTS IN ComplexClip (and Basic Clip)
	button.text = button_text
	button.custom_minimum_size = custom_minimum_size
	var callable = Callable(self, on_pressed_func_call).bind(button)
	button.connect("pressed", callable)
	return button
	
"""
	#arg is parent
func arg_clip_is_child_of_self(parent_clip_to_check): # when assigning a clip as reference in another clip, the parent clip should now be referenced in the newly referenced clip, to avoid circular reference.
	#This function should be executed by the newly referenced clip.
	for i in range(1, frame_layer_table_hbox.child_count()):
		for j in range(1, frame_layer_table_hbox.get_child(i).child_count()):
			var framelayer_button_to_check = frame_layer_table_hbox.get_child(i).get_child(j)
			var clip_to_check = framelayer_button_to_check.frameLayer.get_clip()
			var found_circular_reference
			if clip_to_check == null:
				continue
			elif clip_to_check is BasicClip:
				continue
			elif clip_to_check == parent_clip_to_check:
				return true
			elif clip_to_check.arg_clip_is_child_of_self(parent_clip_to_check):
				return true
	return false
	"""
	
func arg_clip_is_child_of_self(parent_clip_to_check): 
	if self == parent_clip_to_check:
		return true
	for i in range(1, frame_layer_table_hbox.get_child_count()):
		for j in range(1, frame_layer_table_hbox.get_child(i).get_child_count()):
			var framelayer_button_to_check = frame_layer_table_hbox.get_child(i).get_child(j)
			var clip_to_check = framelayer_button_to_check.frameLayer.get_clip()
			if clip_to_check == null:
				continue
			elif clip_to_check is BasicClip:
				continue
			elif clip_to_check == parent_clip_to_check:
				return true
			elif clip_to_check.arg_clip_is_child_of_self(parent_clip_to_check):
				return true
	return false


