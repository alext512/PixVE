class_name CommonFunctions

func construct_button(button, button_text, custom_minimum_size, on_pressed_func_call):
	button.text = button_text
	button.custom_minimum_size = custom_minimum_size
	var callable = Callable(self, on_pressed_func_call).bind(button)
	button.connect("pressed", callable)
	return button
