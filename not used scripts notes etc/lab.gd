"""
func add_new_frame_to_framelayer_table(frame_layer_table_hbox):
	frame_layer_table_hbox.add_child(VBoxContainer.new()) # Adding a new column to the frameLayer table of the selected clip.
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
		if i != 0: # 0 IS FOR LABEL
			var button = construct_button(NumberedFrameLayerButton.new(frame_layer_table_hbox.get_child_count() - 1, i), "", button_size, "_on_frame_layer_button_pressed")
			frame_layer_table_hbox.get_child(frame_layer_table_hbox.get_child_count() - 1).add_child(button)
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

func add_new_layer_to_framelayer_table(frame_layer_table_hbox):
	# Add a new layer label
	var layer_label = construct_button(NumberedLabelButton.new(frame_layer_table_hbox.get_child(0).get_child_count()), str(frame_layer_table_hbox.get_child(0).get_child_count()), button_size, "_on_layer_label_button_pressed")
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
			var button = construct_button(NumberedFrameLayerButton.new(i, frame_layer_table_hbox.get_child(0).get_child_count() - 1), "", button_size, "_on_frame_layer_button_pressed")
			frame_layer_table_hbox.get_child(i).add_child(button) #remem
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
"""
