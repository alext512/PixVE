extends Node2D

# Modify these values based on the number of frames and layers
var num_frames = 7
var num_layers = 5
var button_size = Vector2(50, 50)  # Minimum size for all buttons


# UI control elements
var clip_list1
var clip_list2

# GridContainer to hold the buttons
#var grid
var frame_layer_table_hbox

# Dialog for reordering frames or layers.
var dialog = AcceptDialog.new()


func _ready():
	var main_vbox = VSplitContainer.new() # Contains everything
	add_child(main_vbox)
	main_vbox.custom_minimum_size = get_viewport_rect().size # Fill the entire window

	# Create the HBoxContainer
	var clip_canvas_h_splitbox = HSplitContainer.new()#HBoxContainer.new() # Contains the clip lists and the canvas
	main_vbox.add_child(clip_canvas_h_splitbox)
	clip_canvas_h_splitbox.size_flags_vertical = Control.SIZE_EXPAND_FILL


	# Create the Clip List
	
	var clip_lists_v_splitbox = VSplitContainer.new() # Contains both clip lists (Basic and Complex)
	clip_canvas_h_splitbox.add_child(clip_lists_v_splitbox)
	clip_lists_v_splitbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	clip_lists_v_splitbox.size_flags_stretch_ratio = 0.2  # 20% of the space
	
	# Create 2 lists
	var clip_list_scroll1 = ScrollContainer.new()
	clip_lists_v_splitbox.add_child(clip_list_scroll1)
	clip_list_scroll1.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	clip_list_scroll1.size_flags_vertical = Control.SIZE_EXPAND_FILL
	clip_list1 = VBoxContainer.new()
	clip_list_scroll1.add_child(clip_list1)
	

# Create an 'Add' button for the first list
	var add_button1 = Button.new()
	add_button1.text = "Add"
	clip_list1.add_child(add_button1)

# Connect the button's 'pressed' signal to a method that will create new buttons
	add_button1.connect("pressed", Callable(self, "_on_add_button1_pressed"))


	
	var clip_list_scroll2 = ScrollContainer.new()
	clip_lists_v_splitbox.add_child(clip_list_scroll2)
	clip_list_scroll2.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	clip_list_scroll2.size_flags_vertical = Control.SIZE_EXPAND_FILL
	clip_list2 = VBoxContainer.new()
	clip_list_scroll2.add_child(clip_list2)
	
	# Create an 'Add' button for the first list
	var add_button2 = Button.new()
	add_button2.text = "Add"
	clip_list2.add_child(add_button2)
	
	# Connect the button's 'pressed' signal to a method that will create new buttons
	add_button2.connect("pressed", Callable(self, "_on_add_button2_pressed"))
	
	

	# Create the Canvas
	var scroll_container_canvas = ScrollContainer.new()
	clip_canvas_h_splitbox.add_child(scroll_container_canvas)
	scroll_container_canvas.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	scroll_container_canvas.size_flags_vertical = Control.SIZE_EXPAND_FILL
	var canvas = Panel.new()
	scroll_container_canvas.add_child(canvas)
	canvas.custom_minimum_size = Vector2(1000, 1000)
	

	# Create the Frame Table
	frame_layer_table_hbox = HBoxContainer.new()
	var scroll_container_frame_table = ScrollContainer.new()
	var frame_table_vbox = VBoxContainer.new()
	main_vbox.add_child(scroll_container_frame_table)
	#main_vbox.add_child(frame_table_vbox)
	scroll_container_frame_table.add_child(frame_table_vbox)
	scroll_container_frame_table.size_flags_vertical = Control.SIZE_EXPAND_FILL
	scroll_container_frame_table.size_flags_horizontal = Control.SIZE_EXPAND_FILL


	# Add your frame table code here


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
	
	# Debug button
	var debug_button = Button.new()
	debug_button.text = "Debug"
	debug_button.custom_minimum_size = button_size
	debug_button.connect("pressed", Callable(self, "_on_debug_button_pressed"))
	frame_table_hbox.add_child(debug_button)


	# Module window for reordering frames or layers
	var line_edit = LineEdit.new()
	line_edit.set_name("Input")  # So we can find it later
	dialog.add_child(line_edit)
	add_child(dialog)

	dialog.connect("confirmed", Callable(self, "_on_dialog_confirmed"))

	
	frame_layer_table_hbox = HBoxContainer.new()
	#frame_table_vbox.add_child(frame_labels)
	frame_table_vbox.add_child(frame_layer_table_hbox)
	
	var placeholder_button = Button.new()
	
	frame_layer_table_hbox.add_child(VBoxContainer.new()) # Adding the first column of the frame layer table that has the layer labels.
	
	#frame_labels.add_child(placeholder_button)
	frame_layer_table_hbox.get_child(0).add_child(placeholder_button)
	placeholder_button.custom_minimum_size = button_size
	placeholder_button.text = "="
	
	
	# Creating frame labels
	for i in range(num_frames):
		var frame_label = NumberedLabelButton.new(i+1) #STARTS FROM 1

		var callable = Callable(self, "_on_frame_label_button_pressed").bind(frame_label)
		frame_label.connect("pressed", callable)
		frame_label.text = str(frame_label.number)
		frame_layer_table_hbox.add_child(VBoxContainer.new()) # IMPORTANT: starting with 1 since 0 is for the layer labels
		#frame_labels.add_child(frame_label)
		frame_layer_table_hbox.get_child(i+1).add_child(frame_label)
		frame_label.custom_minimum_size = button_size
		#frame_labels_buttons.append(frame_label)
		
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
		var callable_for_gui_input = Callable(self, "_on_button_gui_input_label_frame")
		
		# Connect the frame_label's gui_input signal to the _on_button_gui_input method
		frame_label.gui_input.connect(callable_for_gui_input.bind(popup_menu))
		
	var main_hbox = HBoxContainer.new()
	frame_table_vbox.add_child(main_hbox)

	#layer_labels = VBoxContainer.new()
	#main_hbox.add_child(layer_labels)


	# Creating layer labels
	for i in range(num_layers):
		var layer_label = NumberedLabelButton.new(i+1) # layer number STARTING FROM 1
		#layer_label.connect("pressed", Callable(self, "_on_layer_label_button_pressed"))
		var callable = Callable(self, "_on_layer_label_button_pressed").bind(layer_label)
		layer_label.connect("pressed", callable)
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
		var callable_for_gui_input = Callable(self, "_on_button_gui_input_label_layer")
		
		# Connect the frame_label's gui_input signal to the _on_button_gui_input method
		layer_label.gui_input.connect(callable_for_gui_input.bind(popup_menu))

	#grid = GridContainer.new()
	
	
	#grid.columns = num_frames
	#main_hbox.add_child(grid)

	
	# Create buttons for frames and layers
	for i in range(num_layers):
		#frame_layers_buttons.append([])  # Append a new array for each layer
		for j in range(num_frames):
			var button = NumberedFrameLayerButton.new(j+1, i+1) #STARTS FROM 1,1
			button.custom_minimum_size = button_size
			button.text = str(button.get_frame()) + " " + str(button.get_layer())
			#button.connect("pressed", Callable(self, "_on_frame_layer_button_pressed"))
			
			#popup_menu.id_pressed.connect(callable_for_popup.bind(layer_label))
			var callable = Callable(self, "_on_frame_layer_button_pressed").bind(button) 
			button.connect("pressed", callable)
			frame_layer_table_hbox.get_child(j+1).add_child(button) # remember, 0 is for labels of layers
			#grid.add_child(button)
			# Add the button to the correct sub-array in the 2D array
			#frame_layers_buttons[i].append(button)
			
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
			var callable_for_gui_input_frame_layer = Callable(self, "_on_button_gui_input_frame_layer")
			
			# Connect the frame_label's gui_input signal to the _on_button_gui_input method
			button.gui_input.connect(callable_for_gui_input_frame_layer.bind(popup_menu_frame_layer))
			
			
			


func _on_add_frame_button_pressed():
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
	var callable_for_gui_input = Callable(self, "_on_button_gui_input_label_frame")
	
	# Connect the frame_label's gui_input signal to the _on_button_gui_input method
	frame_label.gui_input.connect(callable_for_gui_input.bind(popup_menu))
		
	# Add a new button for each layer
	for i in range(frame_layer_table_hbox.get_child(0).get_child_count()):
		if i != 0: # 0 IS FOR LABEL (do we need to add 1 to the loop? check)
			var button = NumberedFrameLayerButton.new(frame_layer_table_hbox.get_child_count() - 1, i)
			button.custom_minimum_size = button_size
			var callable2 = Callable(self, "_on_frame_layer_button_pressed").bind(button)
			button.connect("pressed", callable2)
			frame_layer_table_hbox.get_child(frame_layer_table_hbox.get_child_count() - 1).add_child(button)
			#grid.add_child(button)
			button.text = str(button.get_frame()) + " " + str(button.get_layer())
			
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
			var callable_for_gui_input_frame_layer = Callable(self, "_on_button_gui_input_frame_layer")
			
			# Connect the frame_label's gui_input signal to the _on_button_gui_input method
			button.gui_input.connect(callable_for_gui_input_frame_layer.bind(popup_menu_frame_layer))
			
		


func _on_add_layer_button_pressed():
	#num_layers += 1

	# Add a new layer label
	var layer_label = NumberedLabelButton.new(frame_layer_table_hbox.get_child(0).get_child_count())
	var callable = Callable(self, "_on_frame_label_button_pressed").bind(layer_label)
	layer_label.connect("pressed", callable)
	layer_label.text = str(layer_label.get_number())
	
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
	var callable_for_gui_input = Callable(self, "_on_button_gui_input_label_layer")
	
	# Connect the frame_label's gui_input signal to the _on_button_gui_input method
	layer_label.gui_input.connect(callable_for_gui_input.bind(popup_menu))
	
	
	for i in range(frame_layer_table_hbox.get_child_count()):
		if i != 0:
			var button = NumberedFrameLayerButton.new(i, frame_layer_table_hbox.get_child(0).get_child_count() - 1)#Button.new()
			button.custom_minimum_size = button_size
			#button.connect("pressed", Callable(self, "_on_frame_layer_button_pressed"))
			var callable2 = Callable(self, "_on_frame_layer_button_pressed").bind(button)
			button.connect("pressed", callable2)
			frame_layer_table_hbox.get_child(i).add_child(button) #remem
			#grid.add_child(button)
			button.text = str(button.get_frame()) + " " + str(button.get_layer())
			
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
			var callable_for_gui_input_frame_layer = Callable(self, "_on_button_gui_input_frame_layer")
			
			# Connect the frame_label's gui_input signal to the _on_button_gui_input method
			button.gui_input.connect(callable_for_gui_input_frame_layer.bind(popup_menu_frame_layer))
			
			

func _on_debug_button_pressed():
	print("DEBUG")

func _on_add_button1_pressed() -> void:
	var new_button = Button.new()
	new_button.text = "New Button"
	clip_list1.add_child(new_button)

	# Create a PopupMenu for the new button
	var popup_menu = PopupMenu.new()
	new_button.add_child(popup_menu)
	

	# Add an item to the PopupMenu
	popup_menu.add_item("Delete clip")

	# Create a callable that references the _on_popup_menu_item_pressed method on this object
	var callable_for_popup = Callable(self, "_on_popup_menu_item_pressed")

	# Connect the signal to the callable
	popup_menu.id_pressed.connect(callable_for_popup.bind(new_button))

	# Create a callable that references the _on_button_gui_input method on this object
	var callable_for_gui_input = Callable(self, "_on_button_gui_input")

	# Connect the new_button's gui_input signal to the _on_button_gui_input method
	new_button.gui_input.connect(callable_for_gui_input.bind(popup_menu))


# Add clip buttons
func _on_add_button2_pressed() -> void:
	var new_button = Button.new()
	new_button.text = "New Button"
	clip_list2.add_child(new_button)
	
	# Create a PopupMenu for the new button
	var popup_menu = PopupMenu.new()
	new_button.add_child(popup_menu)

	# Add an item to the PopupMenu
	popup_menu.add_item("Delete clip")

	# Create a callable that references the _on_popup_menu_item_pressed method on this object
	var callable_for_popup = Callable(self, "_on_popup_menu_item_pressed")

	# Connect the signal to the callable
	popup_menu.id_pressed.connect(callable_for_popup.bind(new_button))

	# Create a callable that references the _on_button_gui_input method on this object
	var callable_for_gui_input = Callable(self, "_on_button_gui_input")

	# Connect the new_button's gui_input signal to the _on_button_gui_input method
	new_button.gui_input.connect(callable_for_gui_input.bind(popup_menu))
	
	
func _on_button_gui_input(event, popup_menu: PopupMenu):
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_RIGHT and event.pressed:
	# If the event is a right mouse button press, show the popup menu
		#popup_menu.popup()
		popup_menu.set_position(get_global_mouse_position())
		popup_menu.popup()

func _on_popup_menu_item_pressed(id : int, button_to_delete : Button) -> void:
	if id == 0:  # The ID of the "Delete clip" item
	# Delete the button
		button_to_delete.queue_free()




func _on_button_gui_input_label_frame(event, popup_menu: PopupMenu):
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_RIGHT and event.pressed:
	# If the event is a right mouse button press, show the popup menu
		popup_menu.set_position(get_global_mouse_position())
		popup_menu.popup()


func _on_popup_menu_item_pressed_label_frame(id : int, label_to_delete: NumberedLabelButton) -> void:
	if id == 0:  # The ID of the "Delete Frame" or "Delete Layer" item
	# Delete the label
	#frame_layers_buttons
		frame_layer_table_hbox.get_child(label_to_delete.get_number()).queue_free()
		# REORDER THE NUMBERS HERE IF YOU WANT
		#label_to_delete.queue_free()
		# Add here any other logic you need for updating the other UI elements


func _on_button_gui_input_label_layer(event, popup_menu: PopupMenu):
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_RIGHT and event.pressed:
	# If the event is a right mouse button press, show the popup menu
		popup_menu.set_position(get_global_mouse_position())
		popup_menu.popup()


func _on_popup_menu_item_pressed_label_layer(id : int, label_selected: NumberedLabelButton) -> void:
	if id == 0:
		dialog.get_node("Input").text = str(label_selected.get_number())  # Pre-fill the current index
		dialog.popup_centered()  # Show the dialog
	if id == 1:  # The ID of the "Delete Frame" or "Delete Layer" item
	# Delete the label
		for i in range(frame_layer_table_hbox.get_child_count()):
				frame_layer_table_hbox.get_child(i).get_child(label_selected.get_number()).queue_free()
		# AFTER DELETION, REORDER THE NUMBERS HERE IF YOU WANT
		# Add here any other logic you need for updating the other UI elements

func _on_dialog_confirmed():
	var new_index = int(dialog.get_node("Input").text)
	# Now use `new_index` to rearrange your frames or layers
	# This function will be called when the user confirms the dialog.
		
func _on_button_gui_input_frame_layer(event, popup_menu: PopupMenu):
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_RIGHT and event.pressed:
	# If the event is a right mouse button press, show the popup menu
		popup_menu.set_position(get_global_mouse_position())
		popup_menu.popup()

func _on_popup_menu_item_pressed_frame_layer(id : int, frame_layer_button: NumberedFrameLayerButton) -> void:
	if id == 0:  # The ID of the "Delete Frame" or "Delete Layer" item
	# Delete the label
		print("frames_layers_UI pressed popum menu of frame layer " + str(frame_layer_button.get_frame()) + " " + str(frame_layer_button.get_layer()))
		# Add here any other logic you need for updating the other UI elements
		
		

func _on_frame_layer_button_pressed(button : NumberedFrameLayerButton) -> void:
	print("frames layers UI, frame and layer: " + str(button.get_frame()) + " " + str(button.get_layer()))

func _on_frame_label_button_pressed(button : NumberedLabelButton) -> void:
	print("frames layers UI, frame label: " + str(button.get_number()))

func _on_layer_label_button_pressed(button : NumberedLabelButton) -> void:
	print("frames layers UI, layer label: " + str(button.get_number()))
	
	
	
# Functions for readability purposes
func create_container(container_type, size_flags_horizontal, size_flags_vertical):
	var container = container_type.new()
	container.size_flags_horizontal = size_flags_horizontal
	container.size_flags_vertical = size_flags_vertical
	return container


